from pydantic import BaseModel
from typing import Optional
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from database import get_db_connection

app = FastAPI(title="Monetix API")

# Frontend-in (HTML/JS) API-yə rahat qoşula bilməsi üçün CORS icazəsi
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
def home():
    return {"message": "Monetix API uğurla çalışır!"}

# Bazadakı tranzaksiyaları çəkən ilk endpoint
@app.get("/api/transactions")
def get_transactions():
    conn = get_db_connection()
    if not conn:
        return {"error": "Verilənlər bazasına bağlanmaq mümkün olmadı"}
    
    cursor = conn.cursor()
    cursor.execute("""
        SELECT t.transaction_id, a.account_name, c.category_name, t.amount, t.transaction_type, t.description, t.transaction_date
        FROM transactions t
        JOIN accounts a ON t.account_id = a.account_id
        JOIN categories c ON t.category_id = c.category_id
        ORDER BY t.transaction_date DESC;
    """)
    transactions = cursor.fetchall()
    cursor.close()
    conn.close()
    return transactions
    from pydantic import BaseModel
from typing import Optional

class TransactionCreate(BaseModel):
    account_id: int
    category_id: int
    amount: float
    transaction_type: str
    description: Optional[str] = None

@app.post("/api/transactions")
def create_transaction(transaction: TransactionCreate):
    conn = get_db_connection()
    if not conn:
        return {"error": "Baza xətası"}
    
    cursor = conn.cursor()
    try:
        cursor.execute("""
            INSERT INTO transactions (account_id, category_id, amount, transaction_type, description)
            VALUES (%s, %s, %s, %s, %s)
            RETURNING transaction_id;
        """, (
            transaction.account_id,
            transaction.category_id,
            transaction.amount,
            transaction.transaction_type,
            transaction.description
        ))
        new_id = cursor.fetchone()['transaction_id']
        conn.commit()
        cursor.close()
        conn.close()
        return {"message": "Uğurla əlavə olundu", "transaction_id": new_id}
    except Exception as e:
        conn.rollback()
        cursor.close()
        conn.close()
        return {"error": str(e)}