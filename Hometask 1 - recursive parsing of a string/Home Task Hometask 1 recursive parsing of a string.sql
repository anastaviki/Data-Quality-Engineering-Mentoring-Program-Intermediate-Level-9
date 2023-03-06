WITH
	json_string AS -- data for parsing
	(
		SELECT '[{"employee_id": "5181816516151", "department_id": "1", "class": "src\bin\comp\json"}, {"employee_id": "925155", "department_id": "1", "class": "src\bin\comp\json"}, {"employee_id": "815153", "department_id": "2", "class": "src\bin\comp\json"}, {"employee_id": "967", "department_id": "", "class": "src\bin\comp\json"}]' [str]
	),
	delete_clauce_1 AS  -- CTE for delete [ symbol
	(
		SELECT STUFF(str,1, CHARINDEX ( '[' , str  ) ,'') without_first
		FROM json_string
	),
	delete_clauce_2 AS  -- CTE for delete ] symbol
	(
		SELECT  left (without_first,LEN(without_first) - CHARINDEX(']',REVERSE(without_first))) AS records
		FROM delete_clauce_1
	),
	by_record (record,records_left) as 
	(  -- RECURSIVE query 
		SELECT 
			SUBSTRING(
				records, 
				CHARINDEX('{', records) + 1,
				CHARINDEX('}', records, CHARINDEX('}', records) - 1) - CHARINDEX('{', records) - 1) AS record, -- select first record in json
			STUFF(
				records,
				1,
				CHARINDEX('}', records)+1, 
				'')  as records_left -- json without first record
		FROM 
			delete_clauce_2
		UNION ALL 
		SELECT 
			SUBSTRING(
				records_left, 
				CHARINDEX('{', records_left) + 1,
				CHARINDEX('}', records_left, CHARINDEX('}', records_left) - 1) - CHARINDEX('{', records_left) - 1) AS record, --select 1st record
			STUFF(
				records_left,
				1,
				CHARINDEX('}', records_left)+1, 
				'')  as records_left  -- json without first record
		FROM 
			by_record  -- resursive from
		WHERE  
			records_left >'' -- check if something exists in json
	)	

SELECT
	CONVERT(
		bigint, 
		SUBSTRING(
			record, 
			CHARINDEX('"employee_id": "', record) + LEN('"employee_id": "'),
			CHARINDEX('", "department_id"', record) - CHARINDEX('"employee_id": "', record) - LEN('"employee_id": "'))) as employee_id , -- parse record and find employee_id
	CONVERT(
		int,
		SUBSTRING(
			record, 
			CHARINDEX('"department_id": "', record) + LEN('"department_id": "'), 
			CHARINDEX('", "class"', record) - CHARINDEX('"department_id": "', record) - LEN('"department_id": "'))) as department_id -- parse record and find department_id
FROM 
	by_record ;






