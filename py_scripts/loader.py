from datetime import datetime
from re import compile
from os import listdir
from pandas import read_excel, read_csv

from py_scripts.models import InputData

TRANSACTIONS_PATTERN = compile("^transactions_(\d{8}).txt$")


def load_files(dirname: str):
    files = listdir(dirname)
    for file in files:
        match = TRANSACTIONS_PATTERN.match(file)
        if match:
            date = match.group(1)
            parsed_date = datetime.strptime(date, "%d%m%Y")
            transactions = read_csv(f"data/transactions_{date}.txt", delimiter=";")
            terminals = read_excel(f"data/terminals_{date}.xlsx")
            passport_blacklist = read_excel(f"data/passport_blacklist_{date}.xlsx")

            return InputData(
                date=parsed_date,
                transactions=transactions,
                terminals=terminals,
                passport_blacklist=passport_blacklist,
            )
