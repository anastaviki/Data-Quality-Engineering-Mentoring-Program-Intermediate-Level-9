*** Settings ***
Documentation    Queries and results for all test cases

*** Variables ***
${query_person_address_count}        SELECT COUNT(*) AS count_rows FROM [Person].[Address];
${query_person_address_count_result}        19614
${column_person_address_count}       '\['count_rows']'

${query_person_address_unique_cities}        SELECT COUNT(DISTINCT [City]) AS  count_cities FROM [Person].[Address];
${query_person_address_unique_cities_result}        575
${column_unique_cities_count}           '\['count_cities']'