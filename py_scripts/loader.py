from datetime import datetime
from re import compile
from os import listdir, rename

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
                transactions=converted_transactions(transactions, parsed_date),
                terminals=converted_terminals(terminals, parsed_date),
                blacklist=converted_passport_blacklist(passport_blacklist, parsed_date),
            )


def archive_files(dirname: str, archive_dirname: str, date: datetime):
    rename(
        f"{dirname}/transactions_{date}.txt",
        f"{archive_dirname}/transactions_{date}.txt",
    )
    rename(
        f"{dirname}/transactions_{date}.txt",
        f"{archive_dirname}/transactions_{date}.txt",
    )
    rename(
        f"{dirname}/transactions_{date}.txt",
        f"{archive_dirname}/transactions_{date}.txt",
    )


def converted_transactions(df: DataFrame, date: datetime) -> DataFrame:
    df["amount"] = df["amount"].str.replace(",", ".", regex=False).astype(float)
    df["create_dt"] = date
    df["update_dt"] = datetime.now()
    return df


def converted_terminals(df: DataFrame, date: datetime) -> DataFrame:
    df["create_dt"] = date
    df["update_dt"] = datetime.now()
    return df


def converted_passport_blacklist(df: DataFrame, date: datetime) -> DataFrame:
    df["create_dt"] = date
    df["update_dt"] = datetime.now()
    return df
