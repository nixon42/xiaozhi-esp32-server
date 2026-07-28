import os
import lancedb
import sys

def main():
    # Use abspath to print exactly where it is looking
    db_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), "knowledge_base", ".lancedb"))
    print(f"Checking db_dir: {db_dir}")
    if not os.path.exists(db_dir):
        print(f"Directory {db_dir} does NOT exist!")
        return

    print("Files in db_dir:")
    for root, dirs, files in os.walk(db_dir):
        for f in files:
            print(os.path.join(root, f))
            
    print("\nConnecting to LanceDB...")
    try:
        db = lancedb.connect(db_dir)
        tables = db.table_names()
        print(f"Tables: {tables}")
        
        if "documents" in tables:
            t = db.open_table("documents")
            print(f"Table 'documents' has {len(t)} rows.")
            try:
                df = t.to_pandas()
                print("Row data:")
                for idx, row in df.iterrows():
                    print(f"- kb_id: {row.get('kb_id')}, filename: {row.get('filename')}")
            except Exception as e:
                print(f"Error reading rows: {e}")
        else:
            print("Table 'documents' NOT FOUND in this LanceDB instance!")
    except Exception as e:
        print(f"Error connecting to LanceDB: {e}")
            
if __name__ == "__main__":
    main()
