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

def search_lancedb(query: str, db_dir: str):
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
        results = table.search(list(query_vector)).limit(3).to_list()
        return results
    except Exception as e:
        logger.bind(tag=TAG).error(f"LanceDB search failed: {e}")
        return []

@register_function("query_knowledge_base", QUERY_KB_FUNCTION_DESC, ToolType.SYSTEM_CTL)
def query_knowledge_base(conn, query: str = None):
    if not query:
        return ActionResponse(Action.REQLLM, "Please provide a search query.", None)

    logger.bind(tag=TAG).info(f"Semantic Search in knowledge base for: {query}")
    
    # Resolve the .lancedb directory path
    base_dir = os.path.dirname(os.path.dirname(os.path.dirname(__file__)))
    db_dir = os.path.join(base_dir, "knowledge_base", ".lancedb")
    
    results = search_lancedb(query, db_dir)
    
    if not results:
        return ActionResponse(Action.REQLLM, f"No information found in the knowledge base for: {query}", None)

    report = f"Knowledge Base Results for '{query}':\n\n"
    for idx, res in enumerate(results, 1):
        # We can also get distance/score from the result if needed
        # dist = res.get("_distance", 0)
        report += f"--- Result {idx} (from {res['filename']}) ---\n{res['text']}\n\n"
        
    return ActionResponse(Action.REQLLM, report, None)
