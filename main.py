import psycopg2
import pandas as pd
from datetime import datetime


if __name__ == '__main__':
    # can be replaced on datetime.today()
    date = datetime(2021, 3, 1).strftime('%d%m%Y')

    transactions = pd.read_csv(f"data/transactions_{date}.txt")
    terminals = pd.read_excel(f"data/terminals_{date}.xlsx")
    passport_blacklist = pd.read_excel(f"data/passport_blacklist_{date}.xlsx")


    with psycopg2.connect(
        database = "db",
        host =     "rc1b-o3ezvcgz5072sgar.mdb.yandexcloud.net",
        user =     "hseguest",
        password = "hsepassword",
        port =     "6432"
    ) as conn:
        conn.autocommit = False
        with conn.cursor() as cursor:
            print(cursor)


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
