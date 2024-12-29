import logging
import os

import psycopg2

from dotenv import load_dotenv
from psycopg2.extras import LoggingConnection

from py_scripts.loader import load_files, archive_files
from py_scripts.scd import ddl, dwh, staging
from py_scripts import fraud

if __name__ == "__main__":
    load_dotenv()

    logging.basicConfig(level=logging.DEBUG)
    logger = logging.getLogger(__name__)

    data_dir = os.getenv("DATA_DIR") or "data"
    data_archive_dir = os.getenv("DATA_ARCHIVE_DIR") or "archive"
    ddl_file = os.getenv("DDL") or "main.ddl"

    data = load_files(data_dir)
    if data is None:
        logger.error("No data found")
        exit(1)

    db_settings = {
        "database": os.getenv("DB_DATABASE"),
        "host": os.getenv("DB_HOST"),
        "user": os.getenv("DB_USER"),
        "password": os.getenv("DB_PASSWORD"),
        "port": os.getenv("DB_PORT"),
        "connect_timeout": 10,
    }

    with psycopg2.connect(connection_factory=LoggingConnection, **db_settings) as conn:
        conn.initialize(logger)
        conn.autocommit = False

        with conn.cursor() as cursor:
            cursor.execute(
                "set statement_timeout = %s", ("5000",)
            )  # timeout in milliseconds

            logger.info("ddl initialization...")
            ddl.init(cursor, ddl_file)
            conn.commit()

            logger.info("cleaning tables...")
            staging.clean(cursor)

            logger.info("renewing clients, accounts, cards tables...")
            staging.renew_db_staging(cursor)

            logger.info("uploading transactions...")
            staging.upload_transactions(data, cursor)

            logger.info("uploading terminals...")
            staging.upload_terminals(data, cursor)

            logger.info("uploading blacklists...")
            staging.upload_blacklist(data, cursor)
            conn.commit()

            logger.info("processing dim-tables...")
            dwh.dim_tables(cursor)
            conn.commit()

            logger.info("processing fact-tables...")
            dwh.fact_tables(cursor)
            conn.commit()

            logger.info("generating fraud report...")
            fraud.expired_bad_passport(cursor, data.date)

    logger.info("Fraud report created in table: 'dndx_rep_fraud'")

    archive_files(data_dir, data_archive_dir, data.date)
