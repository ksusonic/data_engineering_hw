from datetime import datetime
from re import compile
from os import listdir

from pandas import read_excel, read_csv, DataFrame

from py_scripts.models import InputData

TRANSACTIONS_PATTERN = compile("^transactions_(\\d{8}).txt$")


def load_files(dirname: str):
    files = listdir(dirname)
    for file in files:
        match = TRANSACTIONS_PATTERN.match(file)
        if match:
            date = match.group(1)
            parsed_date = datetime.strptime(date, "%d%m%Y")
            transactions = read_csv(f"{dirname}/transactions_{date}.txt", delimiter=";")
            terminals = read_excel(f"{dirname}/terminals_{date}.xlsx")
            passport_blacklist = read_excel(f"{dirname}/passport_blacklist_{date}.xlsx")

            return InputData(
                date=parsed_date,
                transactions=converted_transactions(transactions),
                terminals=converted_terminals(terminals),
                blacklist=converted_passport_blacklist(passport_blacklist),
            )


def converted_transactions(df: DataFrame) -> DataFrame:
    df["amount"] = df["amount"].str.replace(",", ".", regex=False).astype(float)
    return df


def converted_terminals(df: DataFrame) -> DataFrame:
    return df


def converted_passport_blacklist(df: DataFrame) -> DataFrame:
    return df
