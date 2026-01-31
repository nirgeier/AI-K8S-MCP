```python
def __init__(self):
    self.server = Server("complete-ollama-mcp-server")
    self.db_path = "data.db"
    self.ollama_client = ollama.Client()
    self.country_data = self._load_country_data()
    self._setup_handlers()

def _load_country_data(self):
    """Load country information from CSV files for RAG retrieval."""
    data = {}
    script_dir = Path(__file__).parent
    info_types = ['capital', 'population', 'height', 'foundation_year']
    for info_type in info_types:
        try:
            file_path = script_dir / f'{info_type}.csv'
            df = pd.read_csv(file_path)
            # Convert country names to lowercase for case-insensitive matching
            data[info_type] = dict(zip(df['country'].str.lower(), df[info_type]))
        except Exception as e:
            print(f"Error loading {info_type}.csv: {e}", file=sys.stderr)
            data[info_type] = {}
    return data
```
