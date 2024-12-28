import os
import psycopg2

from dotenv import load_dotenv

import py_scripts.scd.staging as staging
from py_scripts.loader import load_files

if __name__ == '__main__':
    load_dotenv()

    data = load_files('data')
    if data is None:
        exit(1)

    pg_dsn = {
        'database': os.getenv('DB_DATABASE'),
        'host': os.getenv("DB_HOST"),
        'user': os.getenv('DB_USER'),
        'password': os.getenv('DB_PASSWORD'),
        'port': os.getenv('DB_PORT')
    }

    with psycopg2.connect(**pg_dsn) as conn:
        conn.autocommit = False

        with conn.cursor() as cursor:
            staging.clean(cursor)
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
