from flask import Flask, jsonify, request
import os
import psycopg2
from psycopg2.extras import RealDictCursor

app = Flask(__name__)

# Database configuration
DB_HOST = os.environ.get('DB_HOST', 'localhost')
DB_NAME = os.environ.get('DB_NAME', 'taskdb')
DB_USER = os.environ.get('DB_USER', 'postgres')
DB_PASS = os.environ.get('DB_PASS', 'password')

def get_db_connection():
    try:
        conn = psycopg2.connect(
            host=DB_HOST,
            database=DB_NAME,
            user=DB_USER,
            password=DB_PASS,
            cursor_factory=RealDictCursor
        )
        return conn
    except Exception as e:
        print(f"Error connecting to database: {e}")
        return None

@app.route('/health')
def health_check():
    conn = get_db_connection()
    if conn:
        conn.close()
        return jsonify({"status": "healthy", "db_connection": "successful"}), 200
    else:
        return jsonify({"status": "unhealthy", "db_connection": "failed"}), 500

@app.route('/api/tasks', methods=['GET'])
def get_tasks():
    conn = get_db_connection()
    if not conn:
        return jsonify({"error": "Database connection failed"}), 500
    
    try:
        with conn.cursor() as cur:
            cur.execute('SELECT * FROM tasks;')
            tasks = cur.fetchall()
        conn.close()
        return jsonify(tasks), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/api/tasks', methods=['POST'])
def create_task():
    conn = get_db_connection()
    if not conn:
        return jsonify({"error": "Database connection failed"}), 500
    
    data = request.get_json()
    title = data.get('title')
    status = data.get('status', 'todo')

    if not title:
        return jsonify({"error": "Title is required"}), 400

    try:
        with conn.cursor() as cur:
            cur.execute(
                'INSERT INTO tasks (title, status) VALUES (%s, %s) RETURNING id, title, status;',
                (title, status)
            )
            new_task = cur.fetchone()
            conn.commit()
        conn.close()
        return jsonify(new_task), 201
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    # Initialize DB table if it doesn't exist (for demo purposes)
    conn = get_db_connection()
    if conn:
        try:
            with conn.cursor() as cur:
                cur.execute('''
                    CREATE TABLE IF NOT EXISTS tasks (
                        id SERIAL PRIMARY KEY,
                        title VARCHAR(100) NOT NULL,
                        status VARCHAR(20) DEFAULT 'todo'
                    );
                ''')
                conn.commit()
            conn.close()
            print("Database initialized.")
        except Exception as e:
            print(f"Error initializing database: {e}")

    app.run(host='0.0.0.0', port=5000)
# Testing CI Pipeline
