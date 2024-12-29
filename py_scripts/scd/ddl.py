from psycopg2.extensions import cursor


def init(cur: cursor, ddl_path: str):
    with open(ddl_path, "r") as file:
        ddl_commands = file.read()

    cur.execute(ddl_commands)
