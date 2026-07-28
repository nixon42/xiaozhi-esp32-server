"""Device call tool"""
import requests
from typing import TYPE_CHECKING

from config.logger import setup_logging
from plugins_func.register import register_function, ToolType, ActionResponse, Action

if TYPE_CHECKING:
    from core.connection import ConnectionHandler

TAG = __name__
logger = setup_logging()

call_device_function_desc = {
    "type": "function",
    "function": {
        "name": "call_device",
        "description": (
            "Used to establish a voice call connection between devices. "
            "Call this tool when the user expresses the following intents:\n"
            "1. Outgoing call: when the user says 'call XX / dial XX / connect to XX / help me call XX', use XX as the nickname. "
            "Example: 'Call John' → nickname='John', 'Connect me to Xiao Chen' → nickname='Xiao Chen';\n"
            "2. Answering an incoming call: after the system just prompted 'You have an incoming call from XX, do you want to answer?', "
            "and the user says 'answer / accept / agree to answer / agree to connect', call this tool with XX as the nickname.\n"
            "If the user's input is neither a clear acceptance nor a clear rejection, do NOT call call_device — ask a follow-up question first."
        ),
        "parameters": {
            "type": "object",
            "properties": {
                "nickname": {"type": "string", "description": "The nickname/alias of the target device, e.g.: John, Xiao Chen"},
            },
            "required": ["nickname"],
        },
    },
}


def _request_api(url: str, params: dict, headers: dict) -> requests.Response:
    return requests.get(url, params=params, headers=headers, timeout=10)


def _failed_reply(msg: str) -> ActionResponse:
    return ActionResponse(action=Action.RESPONSE, response=msg)


def _is_answering(conn: "ConnectionHandler") -> bool:
    """Check if this is an answer-call mode (conn.incoming_call is not None)"""
    return hasattr(conn, 'incoming_call') and conn.incoming_call is not None


@register_function("call_device", call_device_function_desc, ToolType.SYSTEM_CTL)
def call_device(conn: "ConnectionHandler", nickname: str):
    caller_mac = conn.headers.get("device-id")
    if not caller_mac:
        return _failed_reply("Unable to retrieve the local MAC address")

    api_config = conn.config.get("manager-api", {})
    api_url = api_config.get("url")
    api_secret = api_config.get("secret")
    if not api_url or not api_secret:
        logger.bind(tag=TAG).error("manager-api configuration is missing")   
        return _failed_reply("Configuration error, please try again later")

    headers = {"Authorization": f"Bearer {api_secret}"}

    # Determine whether this is an outgoing call or answering an incoming call
    is_answer = _is_answering(conn)
    params = {"callerMac": caller_mac, "nickname": nickname}   
    if is_answer:
        params["answer"] = "true"

    # Look up the address book and place the call
    try:
        resp = _request_api(
            f"{api_url}/device/address-book/call",
            params=params,
            headers=headers,
        )
        result = resp.json()
    except requests.RequestException as e:
        logger.bind(tag=TAG).error(f"Call request failed: {e}")
        return _failed_reply("Call failed, please try again later")

    if result.get("code") != 0:
        return _failed_reply(result.get("msg", "Call failed"))

    data = result.get("data", {})
    if data.get("status") == "error":
        return _failed_reply(data.get("message"))

    if is_answer:
        return ActionResponse(action=Action.NONE, response="Call answered successfully")
    else:
        conn.calling = True
        return ActionResponse(action=Action.NONE, response=f"Calling {nickname}, please wait for the other party to answer")
