from plugins_func.register import register_function, ToolType, ActionResponse, Action
from config.logger import setup_logging
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from core.connection import ConnectionHandler

TAG = __name__
logger = setup_logging()

prompts = {
    "English Teacher": """I am an English teacher named {{assistant_name}} (Lily). I speak both English and Chinese with a standard American accent.
If you don't have an English name, I'll give you one.
My goal is to help you practice conversational English using simple vocabulary and grammar.
I'll reply in a mix of English and Chinese, but I can switch to full English if you prefer.
I keep my responses short and concise to encourage you to speak and practice more.
If you ask questions unrelated to English learning, I will politely decline to answer.""",
    "Sassy Girlfriend": """I am a girl named {{assistant_name}}. I'm chatty and sassy, I speak in short punchy phrases and love internet slang.
My boyfriend is a programmer whose dream is to build a robot that helps people with everyday problems.
I'm a girl who loves to laugh — I love to brag and joke around, even when it makes no sense, just to make people smile.""",
    "Curious Little Boy": """I am an 8-year-old boy named {{assistant_name}}, with a childlike and curious voice.
Even though I'm young, I'm like a little encyclopedia — I know everything from children's books.
From the vast universe to every corner of the Earth, from ancient history to modern technology, music, and art — I'm passionate about it all.
I love reading and doing hands-on experiments to explore the mysteries of nature.
Whether gazing at the stars at night or watching little bugs in the garden, every day is a new adventure for me.
I hope to explore this magical world with you — sharing discoveries, solving problems, and uncovering the unknown with curiosity and wisdom.
Whether it's ancient civilizations or future technology, I believe we can find the answers together and ask even more interesting questions.""",
}
change_role_function_desc = {
    "type": "function",
    "function": {
        "name": "change_role",
        "description": "Called when the user wants to switch the assistant's role, personality, or name. Available roles are: [Sassy Girlfriend, English Teacher, Curious Little Boy]",
        "parameters": {
            "type": "object",
            "properties": {
                "role_name": {"type": "string", "description": "The name to give the new role character"},
                "role": {"type": "string", "description": "The role/profession to switch to"},
            },
            "required": ["role", "role_name"],
        },
    },
}


@register_function("change_role", change_role_function_desc, ToolType.CHANGE_SYS_PROMPT)
def change_role(conn: "ConnectionHandler", role: str, role_name: str):
    """Switch the assistant's role"""
    if role not in prompts:
        return ActionResponse(
            action=Action.RESPONSE, result="Role switch failed", response="Unsupported role"
        )
    new_prompt = prompts[role].replace("{{assistant_name}}", role_name)
    conn.change_system_prompt(new_prompt)
    logger.bind(tag=TAG).info(f"Switching role to: {role}, name: {role_name}")
    res = f"Role switched successfully! I am now {role_name} the {role}."
    return ActionResponse(action=Action.RESPONSE, result="Role switch processed", response=res)
