drop procedure if exists  Statistics_pr;

Go 
CREATE PROCEDURE Statistics_pr -- create procedure with input parameters
    @p_DatabaseName NVARCHAR(MAX),
    @p_SchemaName NVARCHAR(MAX),
    @p_TableName NVARCHAR(MAX)
AS
Declare @v_PreQuery  NVARCHAR(MAX)
drop table if exists ##v_TablesList;
create table ##v_TablesList  ([Table_Name] VARCHAR(100), [Column_name]VARCHAR(100)); --create temporary table with list of tables and colunms
--DECLARE @v_TablesList TABLE ([Table_Name] VARCHAR(100), [Column_name]VARCHAR(100)); --create temporary table with list of tables and colunms


	if @p_TableName ='%'
		begin 
			SET @v_PreQuery ='INSERT
			INTO ##v_TablesList
			SELECT   o.Name as table_name, c.Name as column_name
			FROM     '+@p_DatabaseName+'.sys.columns c 
			JOIN '+@p_DatabaseName+'.sys.objects o ON o.object_id = c.object_id 
			join '+@p_DatabaseName+'.INFORMATION_SCHEMA.TABLES i on i.TABLE_NAME = o.name
			join '+@p_DatabaseName+'.sys.schemas s on s.name = i.TABLE_SCHEMA
			where 
			 o.type = ''U'' 
			and i.TABLE_SCHEMA = '''+@p_SchemaName+'''
			ORDER BY o.Name, c.Name;'
		end; 
	else
		begin 
			 SET @v_PreQuery = 
			 'INSERT
			INTO ##v_TablesList
			SELECT   o.Name as table_name, c.Name as column_name
			FROM      '+@p_DatabaseName+'.sys.columns c 
			JOIN  '+@p_DatabaseName+'.sys.objects o ON o.object_id = c.object_id  
			join  '+@p_DatabaseName+'.INFORMATION_SCHEMA.TABLES i on i.TABLE_NAME = o.name 
			join  '+@p_DatabaseName+'.sys.schemas s on s.name = i.TABLE_SCHEMA
			where  o.name = '''+@p_TableName+''' 
			ORDER BY o.Name, c.Name;'
		end; 


EXEC SP_EXECUTESQL @v_PreQuery;
Select * from  ##v_TablesList;
DECLARE @v_Query NVARCHAR(MAX); -- char for query
WITH
	tbl_list AS
	(
		SELECT
			[Table_Name],[Column_name]
			,LEAD([Column_name]) OVER (ORDER BY [Table_Name],[Column_name]) [lead_row] -- use lead to check if it is last record in temporary table
		FROM ##v_TablesList
	),
query_not_agg AS( -- generate query
SELECT
			CASE
				WHEN [lead_row] IS NOT NULL 
					THEN 'SELECT   '+ 
	''''+@p_DatabaseName +''' AS "Database name",  '+ -- select DB name
	''''+@p_SchemaName +''' AS "Schema name", '+  --Shema name
	''''+[Table_Name] + ''' AS "Table name",'+ --Table name
	'COUNT (*)  AS "Total row count", '+ -- count of rows
	''''+[Column_name] + ''' AS "Column name",'+ --column name
	'i.DATA_TYPE  AS "Data type",' -- data type of colunm
	+'count(distinct ' + [Column_name] +') AS "Count of DISTINCT values",'+ -- number of distinct values
	't1."Count of NULL values", '+  --count of null values in column
	't2."Count of empty/zero values", '+ -- count of empty or zero values in table
	't3."Only UPPERCASE strings",'+ -- count of only uppercase strings
	't4."Only LOWERCASE strings",'+ -- count of only lowercase strings
	't5."Rows with non-printable characters at the beginning/end", '+ -- count of rows with begin or end of non printable values
	'cast (t6."Most used value" as varchar) AS "Most used value",'+ -- most used value in column
	' CAST(( select  t6."% rows with most used value") as numeric(6,2))  AS "% rows with most used value",'+ --persent of most used value in column
	'cast (t7."MIN value"as varchar) AS "MIN value", cast (t7."MAX value"as varchar) AS "MAX Value"'+ -- min and max value in column
	'FROM (select COUNT(*) AS "Count of NULL values" '+
	'FROM ['+@p_DatabaseName+']. ['+@p_SchemaName+'].[' +[Table_Name]+ '] '+
	' WHERE '+ [Column_name]+' IS NULL) AS t1 ' -- subquery for calculating count of null values
	+'JOIN (SELECT SUM(CASE 
             WHEN ISNUMERIC(cast ('+[Column_name]+' as varchar)) = 1 AND cast ('+[Column_name]+'  as varchar ) =  ''0'' THEN 1 
             WHEN ISNUMERIC(cast ('+[Column_name]+' as varchar)) = 0 AND cast ('+[Column_name]+'  as varchar) =  '''' THEN 1 
			 ELSE 0
           END) AS "Count of empty/zero values" 
FROM  ['+@p_DatabaseName+'].['+@p_SchemaName+'].[' +[Table_Name]+ '])  AS t2 ON 1=1 '+ -- subquery for calculating count of empty or zero values
'JOIN (SELECT SUM(CASE 
			WHEN (ISNUMERIC(cast ('+[Column_name]+' as varchar)) = 0) THEN 0
             WHEN (ISNUMERIC(cast ('+[Column_name]+' as varchar)) = 0 AND Upper('+[Column_name]+') COLLATE Latin1_General_CS_AS = '+[Column_name]+' ) THEN 1 
			 ELSE 0
			 END)
           AS "Only UPPERCASE strings"  
FROM  ['+@p_DatabaseName+'].['+@p_SchemaName+'].[' +[Table_Name]+ ']) AS t3 ON 1 = 1 '+ -- subquery for calculating only uppercase strings
'JOIN (SELECT SUM(CASE 
			WHEN (ISNUMERIC(cast ('+[Column_name]+' as varchar)) = 0) THEN 0
             WHEN (ISNUMERIC(cast ('+[Column_name]+' as varchar)) = 0 AND Lower('+[Column_name]+') COLLATE Latin1_General_CS_AS = '+[Column_name]+' ) THEN 1 
			 ELSE 0
			 END)
           AS "Only LOWERCASE strings"  
FROM  ['+@p_DatabaseName+'].['+@p_SchemaName+'].[' +[Table_Name]+ ']) AS t4 ON 1 = 1 '  -- subquery for calculating only lowercase strings
+'JOIN (
SELECT SUM (
CASE WHEN (ISNUMERIC(cast ('+[Column_name]+' as varchar)) = 1) THEN 0
WHEN (ISNUMERIC(cast ('+[Column_name]+' as varchar)) = 0) AND 
(PATINDEX(''['+ CHAR(10)+ Char(13)+ Char(9)  + ' ]%'', ((cast ( '+[Column_name]+' as varchar) ) ))=1 
OR PATINDEX(''['+ CHAR(10)+ Char(13)+ Char(9)  + ' ]%'', REVERSE(cast ( '+[Column_name]+' as varchar)))=1) THEN 1
ELSE 0
END) AS "Rows with non-printable characters at the beginning/end"
FROM ['+@p_DatabaseName+'].['+@p_SchemaName+'].[' +[Table_Name]+ ']) AS t5 ON 1=1 '  -- subquery for calculating Rows with non-printable characters at the beginning/end
+' JOIN (
SELECT '+[Column_name] +' AS "Most used value", COUNT(*) AS count , 
       COUNT(*) * 100.0 / SUM(COUNT(*)) OVER() AS "% rows with most used value",
       SUM(CASE WHEN ' +[Column_name] + '  = popular_value THEN 1 ELSE 0 END) AS popular_count
FROM ['+@p_DatabaseName+'].['+@p_SchemaName+'].[' +[Table_Name]+ ']
CROSS APPLY (SELECT TOP 1 ' +[Column_name] + ' AS popular_value
             FROM ['+@p_DatabaseName+'].['+@p_SchemaName+'].[' +[Table_Name]+ ']
             GROUP BY ' +[Column_name] + '
             ORDER BY COUNT(*) DESC) AS most_popular
GROUP BY  ' +[Column_name] + '
)  AS t6'  -- subquery for calculating most popular value and persent of it value
+' ON t6.popular_count !=0 '
+'JOIN  (
SELECT MIN('+[Column_name]+') AS "MIN value", MAX('+[Column_name]+') AS "MAX value"
FROM ['+@p_DatabaseName+'].['+@p_SchemaName+'].[' +[Table_Name]+ '])  AS t7 ON 1 = 1' -- subquery for calculating max and min value
		+'JOIN ['+@p_DatabaseName+'].['+@p_SchemaName+'].[' +[Table_Name]+ ']  t ON 1=1 '+
	'JOIN ['+@p_DatabaseName+'].INFORMATION_SCHEMA.COLUMNS i ON i.TABLE_SCHEMA = '''+ @p_SchemaName+ 
	''' AND i.TABLE_NAME = ''' +[Table_Name]+''''+
	' AND i.COLUMN_NAME = '''+ [Column_name]+ ''''+
	'  GROUP BY  i.data_type,   t1."Count of NULL values", t2."Count of empty/zero values",t3."Only UPPERCASE strings", t4."Only LOWERCASE strings" ,
	t5."Rows with non-printable characters at the beginning/end", t6."Most used value", t6."% rows with most used value",t7."MIN value", t7."MAX value"  UNION ALL '
				ELSE  -- if last row do not use union all in string
					'SELECT   '+ 
	''''+@p_DatabaseName +''' AS "Database name",  '+
	''''+@p_SchemaName +''' AS "Schema name", '+ 
	''''+[Table_Name] + ''' AS "Table name",'+
	'COUNT (*)  AS "Total row count", '+
	''''+[Column_name] + ''' AS "Column name",'+
	'i.DATA_TYPE  AS "Data type",'
	+'count(distinct ' + [Column_name] +') AS "Count of DISTINCT values",'+
	't1."Count of NULL values", '+
	't2."Count of empty/zero values", '+
	't3."Only UPPERCASE strings",'+
	't4."Only LOWERCASE strings",'+
	't5."Rows with non-printable characters at the beginning/end", '+
	'cast (t6."Most used value" as varchar) AS "Most used value",'+
	' CAST(( select  t6."% rows with most used value") as numeric(6,2))  AS "% rows with most used value",'+
	'cast (t7."MIN value"as varchar) AS "MIN value", cast (t7."MAX value"as varchar) AS "MAX Value"'+
	'FROM (select COUNT(*) AS "Count of NULL values" '+
	'FROM  ['+@p_DatabaseName+'].['+@p_SchemaName+'].[' +[Table_Name]+ '] '+
	' WHERE '+ [Column_name]+' IS NULL) AS t1 '
	+'JOIN (SELECT SUM(CASE 
             WHEN ISNUMERIC(cast ('+[Column_name]+' as varchar)) = 1 AND cast ('+[Column_name]+'  as varchar ) =  ''0'' THEN 1 
             WHEN ISNUMERIC(cast ('+[Column_name]+' as varchar)) = 0 AND cast ('+[Column_name]+'  as varchar) =  '''' THEN 1 
			 ELSE 0
           END) AS "Count of empty/zero values" 
FROM  ['+@p_DatabaseName+'].['+@p_SchemaName+'].[' +[Table_Name]+ '])  AS t2 ON 1=1 '+
'JOIN (SELECT SUM(CASE 
			WHEN (ISNUMERIC(cast ('+[Column_name]+' as varchar)) = 0) THEN 0
             WHEN (ISNUMERIC(cast ('+[Column_name]+' as varchar)) = 0 AND Upper('+[Column_name]+') COLLATE Latin1_General_CS_AS = '+[Column_name]+' ) THEN 1 
			 ELSE 0
			 END)
           AS "Only UPPERCASE strings"  
FROM  ['+@p_DatabaseName+'].['+@p_SchemaName+'].[' +[Table_Name]+ ']) AS t3 ON 1 = 1 '+
'JOIN (SELECT SUM(CASE 
			WHEN (ISNUMERIC(cast ('+[Column_name]+' as varchar)) = 0) THEN 0
             WHEN (ISNUMERIC(cast ('+[Column_name]+' as varchar)) = 0 AND Lower('+[Column_name]+') COLLATE Latin1_General_CS_AS = '+[Column_name]+' ) THEN 1 
			 ELSE 0
			 END)
           AS "Only LOWERCASE strings"  
FROM  ['+@p_DatabaseName+'].['+@p_SchemaName+'].[' +[Table_Name]+ ']) AS t4 ON 1 = 1 '
+'JOIN (
SELECT SUM (
CASE WHEN (ISNUMERIC(cast ('+[Column_name]+' as varchar)) = 1) THEN 0
WHEN (ISNUMERIC(cast ('+[Column_name]+' as varchar)) = 0) AND 
(PATINDEX(''['+ CHAR(10)+ Char(13)+ Char(9)  + ' ]%'', ((cast ( '+[Column_name]+' as varchar) ) ))=1 
OR PATINDEX(''['+ CHAR(10)+ Char(13)+ Char(9)  + ' ]%'', REVERSE(cast ( '+[Column_name]+' as varchar)))=1) THEN 1
ELSE 0
END) AS "Rows with non-printable characters at the beginning/end"
FROM ['+@p_DatabaseName+'].['+@p_SchemaName+'].[' +[Table_Name]+ ']) AS t5 ON 1=1 '
+' JOIN (
SELECT '+[Column_name] +' AS "Most used value", COUNT(*) AS count , 
       COUNT(*) * 100.0 / SUM(COUNT(*)) OVER() AS "% rows with most used value",
       SUM(CASE WHEN ' +[Column_name] + '  = popular_value THEN 1 ELSE 0 END) AS popular_count
FROM ['+@p_DatabaseName+']. ['+@p_SchemaName+'].[' +[Table_Name]+ ']
CROSS APPLY (SELECT TOP 1 ' +[Column_name] + ' AS popular_value
             FROM ['+@p_DatabaseName+'].['+@p_SchemaName+'].[' +[Table_Name]+ ']
             GROUP BY ' +[Column_name] + '
             ORDER BY COUNT(*) DESC) AS most_popular
GROUP BY  ' +[Column_name] + '
)  AS t6 
ON t6.popular_count !=0 '
+'JOIN  (
SELECT MIN('+[Column_name]+') AS "MIN value", MAX('+[Column_name]+') AS "MAX value"
FROM ['+@p_DatabaseName+'].['+@p_SchemaName+'].[' +[Table_Name]+ '])  AS t7 ON 1 = 1'
		+'JOIN ['+@p_DatabaseName+'].['+@p_SchemaName+'].[' +[Table_Name]+ ']  t ON 1=1 '+
	'JOIN ['+@p_DatabaseName+'].INFORMATION_SCHEMA.COLUMNS i ON i.TABLE_SCHEMA = '''+ @p_SchemaName+ 
	''' AND i.TABLE_NAME = ''' +[Table_Name]+''''+
	' AND i.COLUMN_NAME = '''+ [Column_name]+ ''''+
	'  GROUP BY  i.data_type,   t1."Count of NULL values", t2."Count of empty/zero values",t3."Only UPPERCASE strings", t4."Only LOWERCASE strings" ,
	t5."Rows with non-printable characters at the beginning/end", t6."Most used value", t6."% rows with most used value",t7."MIN value", t7."MAX value"  '
			END [query_text]
		FROM tbl_list
)


SELECT -- form the query 
	@v_Query = STRING_AGG([query_text], '') WITHIN GROUP (ORDER BY [query_text])
FROM query_not_agg;

EXEC SP_EXECUTESQL @v_Query; --execute query

Return;
GO  

DECLARE @DatabaseName NVARCHAR(max), @SchemaName NVARCHAR(max), @TableName NVARCHAR(max);
SET @DatabaseName = 'TRN'
SET @SchemaName = 'hr'
SET @TableName = 'employees'

EXEC Statistics_pr @DatabaseName, @SchemaName, @TableName -- execute the procedure


