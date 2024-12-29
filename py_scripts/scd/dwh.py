from psycopg2._psycopg import cursor


def _execute_sql(filename: str, cur: cursor):
    with open(f"sql_scripts/{filename}", "r") as file:
        query = file.read()

    cur.execute(query)


def dim_tables(cur: cursor):
    _execute_sql("accounts.sql", cur)
    _execute_sql("blacklist.sql", cur)
    _execute_sql("cards.sql", cur)
    _execute_sql("clients.sql", cur)
    _execute_sql("terminals.sql", cur)
    _execute_sql("transactions.sql", cur)


def fact_tables(cur: cursor):
    _execute_sql("fact.sql", cur)
