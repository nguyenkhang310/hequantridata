import mysql.connector
import os

DB_CONFIG = {
    'host': 'localhost',
    'user': 'root',
    'password': 'Nguyenkhang@123',
    'database': 'QuanLyDKHP'
}

def execute_script(filename):
    print(f"Executing {filename}...")
    try:
        conn = mysql.connector.connect(**DB_CONFIG)
        cursor = conn.cursor()
        with open(filename, 'r', encoding='utf-8') as f:
            sql = f.read()
        
        # Split by DELIMITER $$
        parts = sql.split('DELIMITER $$')
        
        for i, part in enumerate(parts):
            if i == 0:
                # Before first DELIMITER $$
                stmts = part.split(';')
                for stmt in stmts:
                    if stmt.strip():
                        cursor.execute(stmt)
                        if cursor.with_rows:
                            cursor.fetchall()
            else:
                # Inside DELIMITER $$
                subparts = part.split('DELIMITER ;')
                # subparts[0] contains the $$ delimited statements
                stmts_dollar = subparts[0].split('$$')
                for stmt in stmts_dollar:
                    if stmt.strip():
                        cursor.execute(stmt)
                        if cursor.with_rows:
                            cursor.fetchall()
                
                # subparts[1] contains the ; delimited statements
                if len(subparts) > 1:
                    stmts_semi = subparts[1].split(';')
                    for stmt in stmts_semi:
                        if stmt.strip() and not stmt.strip().upper().startswith("SELECT '"): 
                            try:
                                cursor.execute(stmt)
                                if cursor.with_rows:
                                    cursor.fetchall()
                            except Exception as e:
                                print(f"Error in trailing statements: {e}")
        
        conn.commit()
        print(f"Success {filename}")
    except Exception as e:
        print(f"Error executing {filename}: {e}")
    finally:
        if 'cursor' in locals(): cursor.close()
        if 'conn' in locals(): conn.close()

scripts = ['sql/03_Functions.sql', 'sql/04_StoredProcedures.sql', 'sql/05_Triggers.sql', 'sql/06_Views.sql']
for script in scripts:
    execute_script(script)
