#include <iostream>
#include <thread>
#include <string>
#include <sqlite3.h>
using namespace std;

const char* DB = "shared.db";

void ownTable() {
    sqlite3* db; sqlite3_open(DB, &db);
    for (int i = 0; i < 5; i++) {
        string sql = "INSERT INTO t2 VALUES (" + std::to_string(i) + ",'cpp_" + std::to_string(i) + "')";
        sqlite3_exec(db, sql.c_str(), 0, 0, 0);
        cout << "[C++] write t2 row " << i << endl;
        this_thread::sleep_for(chrono::milliseconds(100));
    }
    sqlite3_close(db);
}

void race() {
    sqlite3* db; sqlite3_open(DB, &db);
    sqlite3_stmt* s;
    for (int i = 0; i < 5; i++) {
        sqlite3_exec(db, "BEGIN EXCLUSIVE", 0, 0, 0);
        sqlite3_prepare_v2(db, "SELECT counter FROM shared WHERE id=1", -1, &s, 0);
        sqlite3_step(s);
        int v = sqlite3_column_int(s, 0);
        sqlite3_finalize(s);
        cout << "[C++] read counter=" << v << endl;
        this_thread::sleep_for(chrono::milliseconds(200));
        string up = "UPDATE shared SET counter=" + std::to_string(v+1) + " WHERE id=1";
        sqlite3_exec(db, up.c_str(), 0, 0, 0);
        sqlite3_exec(db, "COMMIT", 0, 0, 0);
        cout << "[C++] write counter=" << v+1 << endl;
        this_thread::sleep_for(chrono::milliseconds(100));
    }
    sqlite3_close(db);
}

int main() {
    sqlite3* db; sqlite3_open(DB, &db);
    sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS t2 (id INTEGER, val TEXT)", 0, 0, 0);
    sqlite3_close(db);

    thread t1(ownTable), t2(race);
    t1.join(); t2.join();

    sqlite3_stmt* s;
    sqlite3_open(DB, &db);
    sqlite3_prepare_v2(db, "SELECT counter FROM shared WHERE id=1", -1, &s, 0);
    sqlite3_step(s);
    cout << "\n[C++] result: " << sqlite3_column_int(s, 0) << " (expected 10)" << endl;
    sqlite3_finalize(s);
    sqlite3_close(db);
}
