# This is a sample Python script.

# Press Shift+F10 to execute it or replace it with your code.
# Press Double Shift to search everywhere for classes, files, tool windows, actions, and settings.
import pyodbc
import pytest
import datetime
import logging


@pytest.fixture(scope='session')
def db_conn():  # connection to db
    server = r'EPPLWARW01DC\SQLEXPRESS'
    database = 'AdventureWorks2012'
    username = 'test_user'
    password = 'test_user'
    conn_str = f"DRIVER={{ODBC Driver 17 for SQL Server}};SERVER={server};" \
               f"DATABASE={database};UID={username};PWD={password}"
    # Create a connection object
    conn = pyodbc.connect(conn_str)
    yield conn
    conn.close()


@pytest.fixture(scope="module")
def logger():  # add logging function
    # Create a logger object
    logger = logging.getLogger(__name__)
    # Set the logging level to INFO
    logger.setLevel(logging.INFO)
    # Create a console handler
    formatter = logging.Formatter("%(message)s")
    console_handler = logging.StreamHandler()
    console_handler.setFormatter(formatter)
    return logger


def test_not_null_address_line2(db_conn, logger):
    cursor = db_conn.cursor()
    cursor.execute('SELECT COUNT(*) as count_values FROM [Person].[Address] WHERE [AddressLine2] IS NOT  NULL;')
    actual_value = cursor.fetchone()[0]
    expected_value = 362
    assert actual_value == expected_value, f"Expected {expected_value}, but got {actual_value}"
    cursor.close()
    logger.info("Verify the number of records with NOT NULL value in the [AddressLine2]"
                " column of the [Person].[Address] table - OK!")


def test_unique_count_address_line1_bothell(db_conn, logger):
    cursor = db_conn.cursor()
    cursor.execute("SELECT DISTINCT COUNT([AddressLine1])  AS count_addr FROM [Person].[Address]"
                   " WHERE UPPER(City) =UPPER('Bothell');")
    actual_value = cursor.fetchone()[0]
    expected_value = 26
    assert round(actual_value, 2) == expected_value, f"Expected {expected_value}, but got {actual_value}"
    cursor.close()
    logger.info("Verify count of  records in [Production].[Document] table with [FolderFlag] = 0 "
                "and length of [FileExtension] = 0 - OK!")


def test_count_of_mist_in_folders(db_conn, logger):
    cursor = db_conn.cursor()
    cursor.execute("SELECT COUNT(*) AS count_rows FROM [Production].[Document] WHERE [FolderFlag] = 0 "
                   "and len([FileExtension]) = 0;")
    actual_value = cursor.fetchone()[0]
    expected_value = 0
    assert round(actual_value, 2) == expected_value, f"Expected {expected_value}, but got {actual_value}"
    cursor.close()
    logger.info("Verify count of  records in [Production].[Document] table with [FileName] non equal "
                "to [Title]+ [FileExtension] - OK!")


def test_count_of_mist_in_names(db_conn, logger):
    cursor = db_conn.cursor()
    cursor.execute("SELECT COUNT(*) count_rows FROM [Production].[Document] "
                   "WHERE [Title]+[FileExtension] != [FileName];")
    actual_value = cursor.fetchone()[0]
    expected_value = 0
    assert round(actual_value, 2) == expected_value, f"Expected {expected_value}, but got {actual_value}"
    cursor.close()
    logger.info("Verify the number of records with NOT NULL value in the [AddressLine2] column "
                "of the [Person].[Address] table - OK!")


def test_count_of_duplicates_names(db_conn, logger):
    cursor = db_conn.cursor()
    cursor.execute("SELECT COUNT(*) as count_rows,[Name] FROM  [Production].[UnitMeasure] "
                   "GROUP BY [Name] HAVING COUNT(*)>1;")
    actual_value = cursor.fetchall()
    expected_value = 0
    assert len(actual_value) == expected_value, f"Expected {expected_value}, but got {actual_value}"
    cursor.close()
    logger.info("Verify  records in [Production].[UnitMeasure] table with duplicated values in [Name] attribute - OK!")


def test_min_value_date(db_conn, logger):
    cursor = db_conn.cursor()
    cursor.execute("SELECT MIN([ModifiedDate]) as min_date FROM [Production].[UnitMeasure];")
    actual_value = cursor.fetchone()[0]
    expected_value = datetime.datetime(2008, 4, 30, 0, 0)
    assert actual_value == expected_value, f"Expected {expected_value}, but got {actual_value}"
    cursor.close()
    logger.info("Verify the minimum value of the [ModifiedDate] column in [Production].[UnitMeasure] table - OK!")
