*** Settings ***
Documentation    Contains Test Cases from file TestCasesRF.xlsx

Resource    ../resources/variables.robot

Suite Setup     Connect To Database    pymssql     ${DBName}    ${DBUser}    ${DBPass}    ${DBHost}    ${DBPort}
Suite Teardown  Disconnect From Database

*** Test Cases ***
Verify the count of records in [Person].[Address] table
     [Tags]     Table Person.Address
     [Documentation]
     ...  | *Setup*:
     ...  | 0.Connect To Database AdventureWorks2012 via pymsql
     ...  |
     ...  | *Test Steps*
     ...  | 0.Query row count for Table Person.Address
     ...  |
     ...  | *Expected result:*
     ...  | 0.Result is not empty
     ...  | 1.Numbers of rows is the same as expected
     @{result}=      query      ${query_person_address_count}
     Should Not Be Empty    ${result}
     Should Contain    ${result}[0]${column_person_address_count}     ${query_person_address_count_result}

Verify the number of unique cities in [Person].[Address] table
     [Tags]     Table Person.Address
     [Documentation]
     ...  | *Setup*:
     ...  | 0.Connect To Database AdventureWorks2012 via pymsql
     ...  |
     ...  | *Test Steps*
     ...  | 0.Query to calculate number of unique cities in [Person].[Address] table
     ...  |
     ...  | *Expected result:*
     ...  | 0.Result is not empty
     ...  | 1.Numbers of rows is the same as expected
     @{result}=      query      ${query_person_address_unique_cities}
     Should Not Be Empty    ${result}
     Should Contain    ${result}[0]${column_unique_cities_count}     ${query_person_address_unique_cities_result}
