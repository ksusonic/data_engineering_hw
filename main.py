import logging
import os
import psycopg2

from dotenv import load_dotenv
from psycopg2.extras import LoggingConnection

import py_scripts.scd.staging as staging
from py_scripts.loader import load_files
from py_scripts.scd import ddl

if __name__ == "__main__":
    load_dotenv()

    logging.basicConfig(level=logging.DEBUG)
    logger = logging.getLogger(__name__)

    data_dir = os.getenv("DATA_DIR") or "data"
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
            conn.commit()

            logger.info("renewing staging tables...")
            staging.renew_db_staging(cursor)

            logger.info("uploading staging data from files...")
            staging.upload(data, cursor)

# # Выполнение SQL кода в базе данных без возврата результата
# cursor.execute( "INSERT INTO de11an.testtable( id, val ) VALUES ( 1, 'ABC' )" )
# conn.commit()

# # Выполнение SQL кода в базе данных с возвратом результата
# cursor.execute( "SELECT * FROM de11an.testtable" )
# records = cursor.fetchall()

# for row in records:
# 	print( row )

# ####################################################

# # Формирование DataFrame
# names = [ x[0] for x in cursor.description ]
# df = pd.DataFrame( records, columns = names )

# # Запись в файл
# df.to_excel( 'pandas_out.xlsx', sheet_name='sheet1', header=True, index=False )

# ####################################################

# # Чтение из файла
# df = pd.read_excel( 'pandas.xlsx', sheet_name='sheet1', header=0, index_col=None )

# # Запись DataFrame в таблицу базы данных
# cursor.executemany( "INSERT INTO de11an.testtable( id, val ) VALUES( %s, %s )", df.values.tolist() )
