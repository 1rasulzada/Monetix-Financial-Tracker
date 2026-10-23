import psycopg2
from psycopg2.extras import RealDictCursor

# PostgreSQL Baza Bağlantı Ayarları
DB_HOST = "localhost"
DB_NAME = "monetix_db"
DB_USER = "postgres"
DB_PASS = "12345"  # <--- Buraya pgAdmin parolunu yaz!
DB_PORT = "5432"

def get_db_connection():
    try:
        conn = psycopg2.connect(
            host=DB_HOST,
            database=DB_NAME,
            user=DB_USER,
            password=DB_PASS,
            port=DB_PORT,
            cursor_factory=RealDictCursor
        )
        return conn
    except Exception as e:
        print(f"Baza bağlantı xətası: {e}")
        return None