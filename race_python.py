import sqlite3, time, threading, sys
sys.stdout.reconfigure(encoding='utf-8')
DB = "shared.db"

def init():
    conn = sqlite3.connect(DB)
    conn.execute("CREATE TABLE IF NOT EXISTS t1 (id INTEGER, val TEXT)")
    conn.execute("CREATE TABLE IF NOT EXISTS shared (id INTEGER PRIMARY KEY, counter INTEGER)")
    conn.execute("DELETE FROM shared")
    conn.execute("INSERT INTO shared VALUES (1, 0)")
    conn.commit()

def own_table():
    conn = sqlite3.connect(DB)
    for i in range(5):
        conn.execute("INSERT INTO t1 VALUES (?, ?)", (i, f"py_{i}"))
        conn.commit()
        print(f"[Python] write t1 row {i}")
        time.sleep(0.1)

def race():
    conn = sqlite3.connect(DB)
    for i in range(5):
        conn.execute("BEGIN EXCLUSIVE")
        val = conn.execute("SELECT counter FROM shared WHERE id=1").fetchone()[0]
        print(f"[Python] read counter={val}")
        time.sleep(0.2)
        conn.execute("UPDATE shared SET counter=? WHERE id=1", (val+1,))
        conn.commit()
        print(f"[Python] write counter={val+1}")
        time.sleep(0.1)

init()
t1 = threading.Thread(target=own_table)
t2 = threading.Thread(target=race)
t1.start(); t2.start(); t1.join(); t2.join()

r = sqlite3.connect(DB).execute("SELECT counter FROM shared WHERE id=1").fetchone()[0]
print(f"\n[Python] result: {r} (expected 5)")
