import pyodbc
import pymssql
# Some other example server values are
# server = 'localhost\sqlexpress' # for a named instance
# server = 'myserver,port' # to specify an alternate port
server = 'EPPLWARW01DC\SQLEXPRESS'
database = 'mydb'
username = 'test_user'
password = 'test_user'
# ENCRYPT defaults to yes starting in ODBC Driver 18. It's good to always specify ENCRYPT=yes on the client side to avoid MITM attacks.
#cnxn = pymssql.connect(server='EPPLWARW01DC\SQLEXPRESS', port='1433', user=username, password=password,database= 'TRN' )
cnxn = pyodbc.connect('DRIVER={SQL Server};SERVER=EPPLWARW01DC\SQLEXPRESS;DATABASE=TRN;UID=test_user;PWD=test_user')
#cnxn = pyodbc.connect('DRIVER={SQL Server};SERVER=localhost;PORT=1433;DATABASE=TRN;UID=test_user;PWD=test_user')
cursor = cnxn.cursor()
cursor.execute('Select * from hr.jobs')
row = cursor.fetchall()
print(row)
