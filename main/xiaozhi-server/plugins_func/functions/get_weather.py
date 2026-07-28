import requests
from bs4 import BeautifulSoup
from config.logger import setup_logging
from plugins_func.register import register_function, ToolType, ActionResponse, Action
from core.utils.util import get_ip_info
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from core.connection import ConnectionHandler

TAG = __name__
logger = setup_logging()

GET_WEATHER_FUNCTION_DESC = {
    "type": "function",
    "function": {
        "name": "get_weather",
        "description": (
            "Retrieves the weather for a given location. The user should provide a location name, e.g. if the user says 'weather in Hangzhou', the parameter is: Hangzhou. "
            "If the user mentions a province, use its capital city by default. If the user mentions a place name that is not a province or city, use the capital of the province that place belongs to. "
            "IMPORTANT: The local 7-day weather forecast is already provided in context. Do NOT call this tool unless the user specifically asks about a different city."
        ),
        "parameters": {
            "type": "object",
            "properties": {
                "location": {
                    "type": "string",
                    "description": "Location name, e.g. Jakarta. Optional parameter, omit if not provided.",
                },
                "lang": {
                    "type": "string",
                    "description": "Language code for the response matching the user's language, e.g. zh_CN/zh_HK/en_US/ja_JP etc. Default is en_US.",
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

# Weather codes: https://dev.qweather.com/docs/resource/icons/#weather-icons
WEATHER_CODE_MAP = {
    "100": "Sunny",
    "101": "Cloudy",
    "102": "Partly Cloudy",
    "103": "Mostly Sunny",
    "104": "Overcast",
    "150": "Sunny",
    "151": "Cloudy",
    "152": "Partly Cloudy",
    "153": "Mostly Sunny",
    "300": "Showers",
    "301": "Heavy Showers",
    "302": "Thundershowers",
    "303": "Heavy Thundershowers",
    "304": "Thundershowers with Hail",
    "305": "Light Rain",
    "306": "Moderate Rain",
    "307": "Heavy Rain",
    "308": "Extreme Rain",
    "309": "Drizzle",
    "310": "Storm",
    "311": "Heavy Storm",
    "312": "Violent Storm",
    "313": "Freezing Rain",
    "314": "Light to Moderate Rain",
    "315": "Moderate to Heavy Rain",
    "316": "Heavy to Storm Rain",
    "317": "Storm to Heavy Storm",
    "318": "Heavy to Violent Storm",
    "350": "Showers",
    "351": "Heavy Showers",
    "399": "Rain",
    "400": "Light Snow",
    "401": "Moderate Snow",
    "402": "Heavy Snow",
    "403": "Snowstorm",
    "404": "Sleet",
    "405": "Rain and Snow",
    "406": "Shower Sleet",
    "407": "Snow Flurries",
    "408": "Light to Moderate Snow",
    "409": "Moderate to Heavy Snow",
    "410": "Heavy to Snowstorm",
    "456": "Shower Sleet",
    "457": "Snow Flurries",
    "499": "Snow",
    "500": "Light Fog",
    "501": "Fog",
    "502": "Haze",
    "503": "Blowing Sand",
    "504": "Floating Dust",
    "507": "Sandstorm",
    "508": "Severe Sandstorm",
    "509": "Dense Fog",
    "510": "Heavy Dense Fog",
    "511": "Moderate Haze",
    "512": "Heavy Haze",
    "513": "Severe Haze",
    "514": "Thick Fog",
    "515": "Extreme Dense Fog",
    "900": "Hot",
    "901": "Cold",
    "999": "Unknown",
}


def fetch_city_info(location, api_key, api_host):
    url = f"https://{api_host}/geo/v2/city/lookup?key={api_key}&location={location}&lang=en"
    response = requests.get(url, headers=HEADERS).json()
    if response.get("error") is not None:
        logger.bind(tag=TAG).error(
            f"Weather fetch failed, reason: {response.get('error', {}).get('detail')}"
        )
        return None
    return response.get("location", [])[0] if response.get("location") else None


def fetch_weather_page(url):
    response = requests.get(url, headers=HEADERS)
    return BeautifulSoup(response.text, "html.parser") if response.ok else None


def parse_weather_info(soup):
    city_name = soup.select_one("h1.c-submenu__location").get_text(strip=True)

    current_abstract = soup.select_one(".c-city-weather-current .current-abstract")
    current_abstract = (
        current_abstract.get_text(strip=True) if current_abstract else "Unknown"
    )

    current_basic = {}
    for item in soup.select(
        ".c-city-weather-current .current-basic .current-basic___item"
    ):
        parts = item.get_text(strip=True, separator=" ").split(" ")
        if len(parts) == 2:
            key, value = parts[1], parts[0]
            current_basic[key] = value

    temps_list = []
    for row in soup.select(".city-forecast-tabs__row")[:7]:  # Get first 7 days
        date = row.select_one(".date-bg .date").get_text(strip=True)
        weather_code = (
            row.select_one(".date-bg .icon")["src"].split("/")[-1].split(".")[0]
        )
        weather = WEATHER_CODE_MAP.get(weather_code, "Unknown")
        temps = [span.get_text(strip=True) for span in row.select(".tmp-cont .temp")]
        high_temp, low_temp = (temps[0], temps[-1]) if len(temps) >= 2 else (None, None)
        temps_list.append((date, weather, high_temp, low_temp))

    return city_name, current_abstract, current_basic, temps_list


@register_function("get_weather", GET_WEATHER_FUNCTION_DESC, ToolType.SYSTEM_CTL)
def get_weather(conn: "ConnectionHandler", location: str = None, lang: str = "en_US"):
    from core.utils.cache.manager import cache_manager, CacheType

    weather_config = conn.config.get("plugins", {}).get("get_weather", {})
    api_host = weather_config.get("api_host", "mj7p3y7naa.re.qweatherapi.com")
    api_key = weather_config.get("api_key", "a861d0d5e7bf4ee1a83d9a9e4f96d4da")
    default_location = weather_config.get("default_location", "Jakarta")
    client_ip = conn.client_ip

    # Prefer the location parameter provided by the user
    if not location:
        # Try to resolve city from client IP
        if client_ip:
            # Check cache first for IP info
            cached_ip_info = cache_manager.get(CacheType.IP_INFO, client_ip)
            if cached_ip_info:
                location = cached_ip_info.get("city")
            else:
                # Cache miss — call API to get IP info
                ip_info = get_ip_info(client_ip, logger)
                if ip_info:
                    cache_manager.set(CacheType.IP_INFO, client_ip, ip_info)
                    location = ip_info.get("city")

            if not location:
                location = default_location
        else:
            # No IP available, use default location
            location = default_location

    # Try to get the full weather report from cache
    weather_cache_key = f"full_weather_{location}_{lang}"
    cached_weather_report = cache_manager.get(CacheType.WEATHER, weather_cache_key)
    if cached_weather_report:
        return ActionResponse(Action.REQLLM, cached_weather_report, None)

    # Cache miss — fetch live weather data
    city_info = fetch_city_info(location, api_key, api_host)
    if not city_info:
        return ActionResponse(
            Action.REQLLM, f"Could not find city: {location}. Please verify the location name.", None
        )
    soup = fetch_weather_page(city_info["fxLink"])
    if not soup:
        return ActionResponse(Action.REQLLM, None, "Request failed")
    city_name, current_abstract, current_basic, temps_list = parse_weather_info(soup)

    weather_report = f"Weather for: {city_name}\n\nCurrent conditions: {current_abstract}\n"

    # Add available current weather parameters
    if current_basic:
        weather_report += "Details:\n"
        for key, value in current_basic.items():
            if value != "0":  # Filter out invalid values
                weather_report += f"  · {key}: {value}\n"

    # Add 7-day forecast
    weather_report += "\n7-Day Forecast:\n"
    for date, weather, high, low in temps_list:
        weather_report += f"{date}: {weather}, temp {low}~{high}\n"

    # Tip
    weather_report += "\n(If you need the weather for a specific day, please tell me the date.)"

    # Cache the full weather report
    cache_manager.set(CacheType.WEATHER, weather_cache_key, weather_report)

    return ActionResponse(Action.REQLLM, weather_report, None)
