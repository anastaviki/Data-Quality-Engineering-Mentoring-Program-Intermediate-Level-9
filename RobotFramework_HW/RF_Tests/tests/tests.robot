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
     ...  | 1.The value with the total number of records in the [Person].[Address] table is the same as expected
     @{result}=      query      ${query_person_address_count}
     Should Not Be Empty    ${result}
     Should Be Equal As Integers    ${result}[0][0]     ${query_person_address_count_result}

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
     ...  | 1.The total number unique cities  in the [Person].[Address] table is the same as expected
     @{result}=      query      ${query_person_address_unique_cities}
     Should Not Be Empty    ${result}
     Should Be Equal As Integers    ${result}[0][0]     ${query_person_address_unique_cities_result}

Verify the average length of the documents in [Production].[Document] table
     [Tags]     Table Production.Document
     [Documentation]
     ...  | *Setup*:
     ...  | 0.Connect To Database AdventureWorks2012 via pymsql
     ...  |
     ...  | *Test Steps*
     ...  | 0.Query to calculate average length of the documents in [Production].[Document] table
     ...  |
     ...  | *Expected result:*
     ...  | 0.Result is not empty
     ...  | 1. Average value of length of  [Document] in [Production].[Document] table is the same as expected
     @{result}=      query      ${query_average_lenght_of_doc}
     Should Not Be Empty    ${result}
     Should Be Equal As Integers    ${result}[0][0]     ${query_average_lenght_of_doc_result}

Verify the possible values of [Status] attribute in [Production].[Document] table
     [Tags]     Table Production.Document
     [Documentation]
     ...  | *Setup*:
     ...  | 0.Connect To Database AdventureWorks2012 via pymsql
     ...  |
     ...  | *Test Steps*
     ...  | 0.Query to calculate  count of rows with incorrect [Status].
     ...  |
     ...  | *Expected result:*
     ...  | 0.Result is not empty
     ...  | 1. Count of rows with incorrect [Status] is the same as expected: 0
     @{result}=      query      ${query_possible_status}
     Should Not Be Empty    ${result}
     Should Be Equal As Integers    ${result}[0][0]         ${query_possible_status_result}

Verify the maximum value of the [ModifiedDate] column in [Production].[UnitMeasure] table
     [Tags]     Table Production.UnitMeasure
     [Documentation]
     ...  | *Setup*:
     ...  | 0.Connect To Database AdventureWorks2012 via pymsql
     ...  |
     ...  | *Test Steps*
     ...  | 0.Query to calculate the maximum value of the [ModifiedDate] column in [Production].[UnitMeasure] table.
     ...  |
     ...  | *Expected result:*
     ...  | 0.Result is not empty
     ...  | 1. The maximum value of the [ModifiedDate] column in [Production].[UnitMeasure] table is the same as expected.
     @{result}=      query      ${query_max_modified_date}
     Should Not Be Empty    ${result}
     Should Be Equal As Strings      ${result}[0][0]     ${query_max_modified_date_result}

Verify the numbers of rows in [Production].[UnitMeasure] table with [UnitMeasureCode] with only one symbol
     [Tags]     Table Production.UnitMeasure
     [Documentation]
     ...  | *Setup*:
     ...  | 0.Connect To Database AdventureWorks2012 via pymsql
     ...  |
     ...  | *Test Steps*
     ...  | 0.Query to calculate numbers of rows in [Production].[UnitMeasure] table with [UnitMeasureCode] with only one symbol.
     ...  |
     ...  | *Expected result:*
     ...  | 0.Result is not empty
     ...  | 1.Numbers of rows in [Production].[UnitMeasure] table with [UnitMeasureCode] with only one symbol is the same as expected.
     @{result}=      query      ${query_numbers_with_one_symbol}
     Should Not Be Empty    ${result}
     Should Be Equal As Strings      ${result}[0][0]     ${query_numbers_with_one_symbol_result}