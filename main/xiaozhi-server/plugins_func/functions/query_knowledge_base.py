import os
import fastembed
from config.logger import setup_logging
from plugins_func.register import register_function, ToolType, ActionResponse, Action

TAG = __name__
logger = setup_logging()

QUERY_KB_FUNCTION_DESC = {
    "type": "function",
    "function": {
        "name": "query_knowledge_base",
        "description": (
            "Queries the internal local knowledge base using Semantic Search. "
            "Use this tool when the user asks about specific personal notes, domain knowledge, manuals, or documents stored in the system. "
            "Pass the user's question as the query."
        ),
        "parameters": {
            "type": "object",
            "properties": {
                "query": {
                    "type": "string",
                    "description": "The natural language question or search query, e.g. 'How do I restart the router?'.",
                }
            },
            "required": ["query"],
        },
    },
}

def search_lancedb(query: str, db_dir: str, kb_id: str = None):
    """Search LanceDB for the most semantically relevant chunks."""
    if not os.path.exists(db_dir):
        logger.bind(tag=TAG).warning(f"LanceDB directory not found at {db_dir}")
        return []

    try:
        import lancedb
        db = lancedb.connect(db_dir)
        if "documents" not in db.table_names():
            return []
            
        table = db.open_table("documents")
        
        # Manually compute query embedding
        model = fastembed.TextEmbedding("BAAI/bge-small-en-v1.5")
        query_vector = list(model.embed([query]))[0]
        
        # Perform semantic vector search
        search = table.search(list(query_vector)).limit(3)
        if kb_id:
            search = search.where(f"kb_id = '{kb_id}'")
            
        results = search.to_list()
        
        # If no results and kb_id was provided, return empty
        # This ensures users don't see other users' data
        return results
    except Exception as e:
        logger.bind(tag=TAG).error(f"LanceDB search failed: {e}")
        return []

@register_function("query_knowledge_base", QUERY_KB_FUNCTION_DESC, ToolType.SYSTEM_CTL)
def query_knowledge_base(conn, query: str = None):
    if not query:
        return ActionResponse(Action.REQLLM, "Please provide a search query.", None)

    # In a multi-tenant setup, we use the agent_id as the knowledge base ID
    agent_id = conn.config.get("agent_id")
    logger.bind(tag=TAG).info(f"DEBUG - agent_id fetched from config: {agent_id}")
    if not agent_id:
        return ActionResponse(Action.REQLLM, "No agent_id found in config. This agent does not have a Knowledge Base assigned.", None)
        
    db_dir = os.path.join(os.path.dirname(__file__), "..", "..", "knowledge_base", ".lancedb")
    
    logger.bind(tag=TAG).info(f"Querying Knowledge Base '{agent_id}' for: {query}")
    logger.bind(tag=TAG).info(f"DEBUG - Starting LanceDB search (this may take a while on first run due to model download)...")
    results = search_lancedb(query, db_dir, kb_id=agent_id)
    logger.bind(tag=TAG).info(f"DEBUG - LanceDB search finished! Found {len(results)} results.")
    
    if not results:
        return ActionResponse(Action.REQLLM, f"No relevant information found in the knowledge base for agent {agent_id}.", None)

    report = f"Knowledge Base Results for '{query}':\n\n"
    for idx, res in enumerate(results, 1):
        # We can also get distance/score from the result if needed
        # dist = res.get("_distance", 0)
        report += f"--- Result {idx} (from {res['filename']}) ---\n{res['text']}\n\n"
        
    return ActionResponse(Action.REQLLM, report, None)
