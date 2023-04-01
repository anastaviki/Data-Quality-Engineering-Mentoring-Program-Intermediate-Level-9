*** Settings ***

Suite Setup
Documentation     tests


Resource    ../resources/variables.robot


*** Test Cases ***
Connect to MS SQL Server using Pyodbc
     Connect To Database    pymssql     ${DBName}    ${DBUser}    ${DBPass}    ${DBHost}    ${DBPort}
