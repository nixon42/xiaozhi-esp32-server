import requests
from config.logger import setup_logging
from plugins_func.register import register_function, ToolType, ActionResponse, Action
from core.utils.util import get_ip_info
from typing import TYPE_CHECKING
import datetime

if TYPE_CHECKING:
    from core.connection import ConnectionHandler

TAG = __name__
logger = setup_logging()

GET_OPENMETEO_WEATHER_FUNCTION_DESC = {
    "type": "function",
    "function": {
        "name": "get_openmeteo_weather",
        "description": (
            "Retrieves the weather for a given location using a free open-source weather API (Open-Meteo). "
            "Use this tool when the user asks for the weather in a specific city or location. "
            "IMPORTANT: The local 7-day weather forecast might already be in context. Only call this tool if the user asks for a new location or explicit current weather."
        ),
        "parameters": {
            "type": "object",
            "properties": {
                "location": {
                    "type": "string",
                    "description": "Location name, e.g. Jakarta, Tokyo, New York. Optional parameter, omit if not provided.",
                },
                "lang": {
                    "type": "string",
                    "description": "Language code for the response, e.g. en, zh, id. Default is en.",
                },
            },
            "required": ["lang"],
        },
    },
}

HEADERS = {
    "User-Agent": (
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 "
        "(KHTML, like Gecko) Chrome/92.0.4515.107 Safari/537.36"
    )
}

WMO_CODE_MAP = {
    0: "Clear sky",
    1: "Mainly clear",
    2: "Partly cloudy",
    3: "Overcast",
    45: "Fog",
    48: "Depositing rime fog",
    51: "Drizzle: Light",
    53: "Drizzle: Moderate",
    55: "Drizzle: Dense",
    56: "Freezing Drizzle: Light",
    57: "Freezing Drizzle: Dense",
    61: "Rain: Slight",
    63: "Rain: Moderate",
    65: "Rain: Heavy",
    66: "Freezing Rain: Light",
    67: "Freezing Rain: Heavy",
    71: "Snow fall: Slight",
    73: "Snow fall: Moderate",
    75: "Snow fall: Heavy",
    77: "Snow grains",
    80: "Rain showers: Slight",
    81: "Rain showers: Moderate",
    82: "Rain showers: Violent",
    85: "Snow showers: Slight",
    86: "Snow showers: Heavy",
    95: "Thunderstorm: Slight or moderate",
    96: "Thunderstorm with slight hail",
    99: "Thunderstorm with heavy hail",
}


def fetch_geocoding(location: str):
    """Get latitude, longitude, and formatted name from Open-Meteo Geocoding API"""
    url = f"https://geocoding-api.open-meteo.com/v1/search?name={location}&count=1&language=en&format=json"
    try:
        resp = requests.get(url, headers=HEADERS, timeout=10)
        resp.raise_for_status()
        data = resp.json()
        if "results" in data and len(data["results"]) > 0:
            result = data["results"][0]
            name = result.get("name", location)
            country = result.get("country", "")
            return {
                "lat": result["latitude"],
                "lon": result["longitude"],
                "name": f"{name}, {country}".strip(", "),
                "timezone": result.get("timezone", "auto")
            }
        else:
            return None
    except Exception as e:
        logger.bind(tag=TAG).error(f"Geocoding failed for {location}: {e}")
        return None


def fetch_openmeteo_weather(lat: float, lon: float, timezone: str = "auto"):
    """Get current and daily weather from Open-Meteo"""
    url = (
        f"https://api.open-meteo.com/v1/forecast"
        f"?latitude={lat}&longitude={lon}"
        f"&current=temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,weather_code,wind_speed_10m"
        f"&daily=weather_code,temperature_2m_max,temperature_2m_min"
        f"&timezone={timezone}"
    )
    try:
        resp = requests.get(url, headers=HEADERS, timeout=10)
        resp.raise_for_status()
        return resp.json()
    except Exception as e:
        logger.bind(tag=TAG).error(f"Weather fetch failed: {e}")
        return None


@register_function("get_openmeteo_weather", GET_OPENMETEO_WEATHER_FUNCTION_DESC, ToolType.SYSTEM_CTL)
def get_openmeteo_weather(conn: "ConnectionHandler", location: str = None, lang: str = "en"):
    from core.utils.cache.manager import cache_manager, CacheType

    weather_config = conn.config.get("plugins", {}).get("get_weather", {})
    default_location = weather_config.get("default_location", "Jakarta")
    client_ip = conn.client_ip

    if not location:
        if client_ip:
            cached_ip_info = cache_manager.get(CacheType.IP_INFO, client_ip)
            if cached_ip_info:
                location = cached_ip_info.get("city")
            else:
                ip_info = get_ip_info(client_ip, logger)
                if ip_info:
                    cache_manager.set(CacheType.IP_INFO, client_ip, ip_info)
                    location = ip_info.get("city")
            if not location:
                location = default_location
        else:
            location = default_location

    weather_cache_key = f"openmeteo_weather_{location}_{lang}"
    cached_weather_report = cache_manager.get(CacheType.WEATHER, weather_cache_key)
    if cached_weather_report:
        return ActionResponse(Action.REQLLM, cached_weather_report, None)

    geo_info = fetch_geocoding(location)
    if not geo_info:
        return ActionResponse(
            Action.REQLLM, f"Could not find city: {location}. Please verify the location name.", None
        )

    weather_data = fetch_openmeteo_weather(geo_info["lat"], geo_info["lon"], geo_info["timezone"])
    if not weather_data:
        return ActionResponse(Action.REQLLM, None, "Weather request failed")

    city_name = geo_info["name"]
    current = weather_data.get("current", {})
    daily = weather_data.get("daily", {})

    weather_code = current.get("weather_code", -1)
    current_condition = WMO_CODE_MAP.get(weather_code, "Unknown")
    temp = current.get("temperature_2m", "N/A")
    feels_like = current.get("apparent_temperature", "N/A")
    humidity = current.get("relative_humidity_2m", "N/A")
    wind = current.get("wind_speed_10m", "N/A")

    weather_report = f"Weather for: {city_name}\n\n"
    weather_report += f"Current conditions: {current_condition}\n"
    weather_report += "Details:\n"
    weather_report += f"  · Temperature: {temp}°C (Feels like: {feels_like}°C)\n"
    weather_report += f"  · Humidity: {humidity}%\n"
    weather_report += f"  · Wind Speed: {wind} km/h\n"

    if daily and "time" in daily:
        weather_report += "\n7-Day Forecast:\n"
        for i in range(len(daily["time"])):
            date = daily["time"][i]
            d_code = daily["weather_code"][i]
            d_weather = WMO_CODE_MAP.get(d_code, "Unknown")
            t_max = daily["temperature_2m_max"][i]
            t_min = daily["temperature_2m_min"][i]
            
            # Format date string for better readability (e.g. Today, Tomorrow, or Day of Week)
            dt = datetime.datetime.strptime(date, "%Y-%m-%d").date()
            if dt == datetime.date.today():
                day_name = "Today"
            elif dt == datetime.date.today() + datetime.timedelta(days=1):
                day_name = "Tomorrow"
            else:
                day_name = dt.strftime("%A")
                
            weather_report += f"{date} ({day_name}): {d_weather}, temp {t_min}°C ~ {t_max}°C\n"

    weather_report += "\n(If you need the weather for a specific day, please tell me the date.)"

    cache_manager.set(CacheType.WEATHER, weather_cache_key, weather_report)

    return ActionResponse(Action.REQLLM, weather_report, None)
