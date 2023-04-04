*** Settings ***
Documentation    Queries and results for all test cases

*** Variables ***
${query_person_address_count}                   SELECT COUNT(*) AS count_rows FROM [Person].[Address];
${query_person_address_count_result}            19614

${query_person_address_unique_cities}           SELECT COUNT(DISTINCT [City]) AS  count_cities FROM [Person].[Address];
${query_person_address_unique_cities_result}    575

${query_average_lenght_of_doc}                  SELECT AVG(LEN([Document])) AS avg_lenght FROM [Production].[Document];
${query_average_lenght_of_doc_result}           31971

${query_possible_status}                        SELECT COUNT ([Status]) AS count_values FROM [Production].[Document] WHERE [STATUS] <1 OR [STATUS]>3;
${query_possible_status_result}                 0

${query_max_modified_date}                      SELECT MAX([ModifiedDate]) as max_date FROM [Production].[UnitMeasure];
${query_max_modified_date_result}               2008-04-30 00:00:00

${query_numbers_with_one_symbol}                SELECT COUNT(*) AS count_values  FROM  [Production].[UnitMeasure] WHERE LEN([UnitMeasureCode])=1;
${query_numbers_with_one_symbol_result}         4

