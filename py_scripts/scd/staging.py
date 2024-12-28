from psycopg2.extensions import cursor

from py_scripts.models import InputData


def clean(cur: cursor):
    cur.execute("truncate table dndx_stg_accounts cascade")
    cur.execute("truncate table dndx_stg_blacklist cascade")
    cur.execute("truncate table dndx_stg_cards cascade")
    cur.execute("truncate table dndx_stg_clients cascade")
    cur.execute("truncate table dndx_stg_terminals cascade")
    cur.execute("truncate table dndx_stg_transactions cascade")
    print("Staging cleaned")


def upload(data: InputData, cur: cursor):
    cur.execute(
        """insert into dndx_stg_transactions (trans_id, trans_date, card_num, oper_type, amt, oper_result, terminal)
        values (%s, %s , %s , %s , %d , %s , %s) """,
        data.transactions[
            ['transaction_id', 'transaction_date', 'card_num', 'oper_type', 'amount', 'oper_result', 'terminal']
        ].values.tolist()
    ),
