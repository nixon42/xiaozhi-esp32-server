import fastembed
import pyarrow as pa
import logging
import os
import re
import lancedb
import logging

logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(name)s - %(levelname)s - %(message)s")
logger = logging.getLogger("BuildKB")

TAG = "BuildKB"

def build_knowledge_base():
    base_dir = os.path.dirname(__file__)
    kb_dir = os.path.join(base_dir, "knowledge_base")
    db_dir = os.path.join(kb_dir, ".lancedb")

    logger.info("Loading FastEmbed model (BAAI/bge-small-en-v1.5)...")
    model = fastembed.TextEmbedding("BAAI/bge-small-en-v1.5")

    if not os.path.exists(kb_dir):
        logger.info(f"Directory {kb_dir} does not exist. Creating it...")
        os.makedirs(kb_dir)

    # Initialize LanceDB
    db = lancedb.connect(db_dir)
    
    # Drop existing table to rebuild from scratch
    if "documents" in db.table_names():
        db.drop_table("documents")
        
    schema = pa.schema([
        pa.field("id", pa.string()),
        pa.field("text", pa.string()),
        pa.field("vector", pa.list_(pa.float32(), 384)),
        pa.field("filename", pa.string()),
    ])
    
    table = db.create_table("documents", schema=schema)
    
    docs_to_insert = []
    chunk_id = 0

    # Read .md files
    for root, dirs, files in os.walk(kb_dir):
        # Ignore the database directory itself
        if ".lancedb" in root:
            continue
            
        for file in files:
            if file.endswith(".md"):
                filepath = os.path.join(root, file)
                try:
                    with open(filepath, "r", encoding="utf-8") as f:
                        content = f.read()
                        
                    # Chunking by double newline (paragraphs)
                    paragraphs = [p.strip() for p in re.split(r'\n\s*\n', content) if p.strip()]
                    
                    for p in paragraphs:
                        # Skip very short paragraphs
                        if len(p) < 20:
                            continue
                            
                        docs_to_insert.append({
                            "id": str(chunk_id),
                            "text": p,
                            "filename": file
                        })
                        chunk_id += 1
                        
                except Exception as e:
                    logger.error(f"Failed to read {filepath}: {e}")

    if docs_to_insert:
        logger.info(f"Computing vectors for {len(docs_to_insert)} chunks...")
        texts = [doc["text"] for doc in docs_to_insert]
        embeddings = list(model.embed(texts))
        
        for i, doc in enumerate(docs_to_insert):
            doc["vector"] = list(embeddings[i])
            
        logger.info(f"Adding {len(docs_to_insert)} chunks to LanceDB...")
        table.add(docs_to_insert)
        logger.info("Knowledge Base successfully built!")
    else:
        logger.info("No valid markdown content found to index.")

if __name__ == "__main__":
    build_knowledge_base()
