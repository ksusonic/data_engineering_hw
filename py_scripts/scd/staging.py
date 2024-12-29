from psycopg2.extensions import cursor

from py_scripts.models import InputData


def clean(cur: cursor):
    cur.execute(
        """truncate table dndx_stg_accounts,
                        dndx_stg_blacklist,
                        dndx_stg_blacklist,
                        dndx_stg_cards,
                        dndx_stg_clients,
                        dndx_stg_terminals,
                        dndx_stg_transactions
        """
    )


def renew_db_staging(cur: cursor):
    cur.execute(
        """
        insert into dndx_stg_clients
        select client_id,
               last_name,
               first_name,
               patronymic,
               date_of_birth,
               passport_num,
               passport_valid_to,
               phone
        from info.clients
        """
    )

    cur.execute(
        """
        insert into dndx_stg_accounts
        select account, valid_to, client
        from info.accounts
        """
    )

    cur.execute(
        """
        insert into dndx_stg_cards
        select card_num, account
        from info.cards
        """
    )


def upload(data: InputData, cur: cursor):
    cur.executemany(
        """
        insert into dndx_stg_terminals 
        (terminal_id, terminal_type, terminal_city, terminal_address)
        values (%s, %s, %s, %s) 
        """,
        data.terminals[
            ["terminal_id", "terminal_type", "terminal_city", "terminal_address"]
        ].values.tolist(),
    )

    cur.executemany(
        """
        insert into dndx_stg_transactions
        (trans_id, trans_date, card_num, oper_type, amt, oper_result, terminal)
        values (%s, %s, %s, %s, %s, %s, %s)
        """,
        data.transactions[
            [
                "transaction_id",
                "transaction_date",
                "card_num",
                "oper_type",
                "amount",
                "oper_result",
                "terminal",
            ]
        ].values.tolist(),
    )

    cur.executemany(
        """
        insert into dndx_stg_blacklist
        (passport_num, entry_dt)
        values (%s, %s)
        """,
        data.blacklist[["passport_num", "entry_dt"]].values.tolist(),
    )
