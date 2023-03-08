


 
drop procedure if exists  Statistics_pr;

Go
CREATE PROCEDURE Statistics_pr
    @p_DatabaseName NVARCHAR(MAX),
    @p_SchemaName NVARCHAR(MAX),
    @p_TableName NVARCHAR(MAX)
AS
DECLARE @v_TablesList TABLE ([Table_Name] VARCHAR(100), [Column_name]VARCHAR(100));
	if @p_TableName ='%'
		begin 
			INSERT
			INTO @v_TablesList
			SELECT   o.Name as table_name, c.Name as column_name
			FROM     sys.columns c 
			JOIN sys.objects o ON o.object_id = c.object_id 
			join INFORMATION_SCHEMA.TABLES i on i.TABLE_NAME = o.name
			join sys.schemas s on SCHEMA_NAME(s.schema_id) = i.TABLE_SCHEMA
			where DB_NAME() = @p_DatabaseName
			and  o.type = 'U' --and i.TABLE_SCHEMA = 'hr'
			and i.TABLE_SCHEMA = @p_SchemaName
			ORDER BY o.Name, c.Name;
		end; 
	else
		begin 
			INSERT
			INTO @v_TablesList
			SELECT   o.Name as table_name, c.Name as column_name
			FROM     sys.columns c 
			JOIN sys.objects o ON o.object_id = c.object_id  
			join INFORMATION_SCHEMA.TABLES i on i.TABLE_NAME = o.name 
			join sys.schemas s on SCHEMA_NAME(s.schema_id) = i.TABLE_SCHEMA
			where DB_NAME() = @p_DatabaseName
			and  o.name = @p_TableName
			ORDER BY o.Name, c.Name;
		end; 




--DECLARE @v_Query NVARCHAR(MAX);
WITH
	tbl_list AS
	(
		SELECT
			[Table_Name],[Column_name]
			,LEAD([Column_name]) OVER (ORDER BY [Table_Name],[Column_name]) [lead_row]
		FROM @v_TablesList
	)
SELECT
			CASE
				WHEN [lead_row] IS NOT NULL 
					THEN 'Select   '+ 
	''''+@p_DatabaseName +''' as "Database name",  '+
	''''+@p_SchemaName +''' as "Schema name", '+ 
	''''+[Table_Name] + ''' as "Table name",'+
	'count (*)  as "Total row count", '+
	''''+[Column_name] + ''' as "Column name",'+
	'i.DATA_TYPE  as "Data type",'
	+'count(distinct ' + [Column_name] +') as "Count of DISTINCT values",'+
	't1."Count of NULL values", '+
	't2."Count of empty/zero values", '+
	't3."Only UPPERCASE strings",'+
	't4."Only LOWERCASE strings"'+
	'from (select COUNT(*) as "Count of NULL values" '+
	'from  ['+@p_SchemaName+'].[' +[Table_Name]+ '] '+
	' where '+ [Column_name]+' is NULL) as t1 '
	+'join (SELECT COUNT(CASE 
             WHEN ISNUMERIC('+[Column_name]+') = 1 AND '+[Column_name]+' = 0 THEN 1 
             WHEN ISNUMERIC('+[Column_name]+') = 0 AND '+[Column_name]+' = '''' THEN 1 
           END) AS "Count of empty/zero values" 
from  ['+@p_SchemaName+'].[' +[Table_Name]+ '])  as t2 on 1=1 '+
'join (SELECT sum(CASE 
			WHEN (ISNUMERIC('+[Column_name]+') = 0) THEN 0
             WHEN (ISNUMERIC('+[Column_name]+') = 0 AND Upper('+[Column_name]+') COLLATE Latin1_General_CS_AS = '+[Column_name]+' ) THEN 1 
			 else 0
			 end)
           AS "Only UPPERCASE strings"  
from  ['+@p_SchemaName+'].[' +[Table_Name]+ ']) as t3 on 1 = 1 '+
'join (SELECT sum(CASE 
			WHEN (ISNUMERIC('+[Column_name]+') = 0) THEN 0
             WHEN (ISNUMERIC('+[Column_name]+') = 0 AND Lower('+[Column_name]+') COLLATE Latin1_General_CS_AS = '+[Column_name]+' ) THEN 1 
			 else 0
			 end)
           AS "Only LOWERCASE strings"  
from  ['+@p_SchemaName+'].[' +[Table_Name]+ ']) as t4 on 1 = 1 '
		+'join ['+@p_SchemaName+'].[' +[Table_Name]+ ']  t on 1=1 '+
	'join INFORMATION_SCHEMA.COLUMNS i on i.TABLE_SCHEMA = '''+ @p_SchemaName+ 
	''' and i.TABLE_NAME = ''' +[Table_Name]+''''+
	' and i.COLUMN_NAME = '''+ [Column_name]+ ''''+
	'  group by  i.data_type,   t1."Count of NULL values", t2."Count of empty/zero values",t3."Only UPPERCASE strings", t4."Only LOWERCASE strings"  UNION ALL '
				ELSE 
					'SELECT COUNT(*) [rows_cnt], ''' + [Table_Name] + ''' [Table_Name] '' FROM [hr].[' + [Table_Name] + '] '
			END [query_text]
		FROM tbl_list



SELECT * FROM hr.countries WHERE [country_name] REGEXP '[[:space:]]'
SELECT * FROM hr.countries
WHERE country_name LIKE '^\s%' -- Check if there are any non-printable characters at the beginning of the string
OR country_name LIKE '^\s'
Select   'TRN' as "Database name",  'hr' as "Schema name", 'countries' as "Table name",count (*)  as "Total row count", 'country_id' as "Column name",i.DATA_TYPE  as "Data type",count(distinct country_id) as "Count of DISTINCT values",t1."Count of NULL values", t2."Count of empty/zero values", t3."Only UPPERCASE strings",t4."Only LOWERCASE strings"from (select COUNT(*) as "Count of NULL values" from  [hr].[countries]  where country_id is NULL) as t1 join (SELECT COUNT(CASE                WHEN ISNUMERIC(country_id) = 1 AND country_id = 0 THEN 1                WHEN ISNUMERIC(country_id) = 0 AND country_id = '' THEN 1              END) AS "Count of empty/zero values"   from  [hr].[countries])  as t2 on 1=1 join (SELECT sum(CASE      WHEN (ISNUMERIC(country_id) = 0) THEN 0               WHEN (ISNUMERIC(country_id) = 0 AND Upper(country_id) COLLATE Latin1_General_CS_AS = country_id ) THEN 1       else 0      end)             AS "Only UPPERCASE strings"    from  [hr].[countries]) as t3 on 1 = 1 join (SELECT sum(CASE      WHEN (ISNUMERIC(country_id) = 0) THEN 0               WHEN (ISNUMERIC(country_id) = 0 AND Lower(country_id) COLLATE Latin1_General_CS_AS = country_id ) THEN 1       else 0      end)             AS "Only LOWERCASE strings"    from  [hr].[countries]) as t4 on 1 = 1 join [hr].[countries]  t on 1=1 join INFORMATION_SCHEMA.COLUMNS i on i.TABLE_SCHEMA = 'hr' and i.TABLE_NAME = 'countries' and i.COLUMN_NAME = 'country_id'  group by  i.data_type,   t1."Count of NULL values", t2."Count of empty/zero values",t3."Only UPPERCASE strings", t4."Only LOWERCASE strings" 
--Select   'TRN' as "Database name",  'hr' as "Schema name", 'countries' as "Table name",count (*)  as "Total row count", 'country_id' as "Column name",i.DATA_TYPE  as "Data type",count(distinct country_id) as "Count of DISTINCT values",t1."Count of NULL values", t2."Count of empty/zero values", t3."Only UPPERCASE strings",t4."Only LOWERCASE strings"from (select COUNT(*) as "Count of NULL values" from  [hr].[countries]  where country_id is NULL) as t1 join (SELECT COUNT(CASE                WHEN ISNUMERIC(country_id) = 1 AND country_id = 0 THEN 1                WHEN ISNUMERIC(country_id) = 0 AND country_id = '' THEN 1              END) AS "Count of empty/zero values"   from  [hr].[countries])  as t2 on 1=1 join (SELECT sum(CASE      WHEN (ISNUMERIC(country_id) = 0) THEN 0               WHEN (ISNUMERIC(country_id) = 0 AND Upper(country_id) COLLATE Latin1_General_CS_AS = country_id ) THEN 1       else 0      end)             AS "Only UPPERCASE strings"    from  [hr].[countries]) as t3 on 1 = 1 join (SELECT sum(CASE      WHEN (ISNUMERIC(country_id) = 0) THEN 0               WHEN (ISNUMERIC(country_id) = 0 AND Lower(country_id) COLLATE Latin1_General_CS_AS = country_id ) THEN 1       else 0      end)             AS "Only LOWERCASE strings"    from  [hr].[countries]) as t4 on 1 = 1 join [hr].[countries]  t on 1=1 join INFORMATION_SCHEMA.COLUMNS i on i.TABLE_SCHEMA = 'hr' and i.TABLE_NAME = 'countries' and i.COLUMN_NAME = 'country_id'  group by  i.data_type,   t1."Count of NULL values", t2."Count of empty/zero values",t3."Only UPPERCASE strings"  
--Select   'TRN' as "Database name",  'hr' as "Schema name", 'countries' as "Table name",count (*)  as "Total row count", 'country_id' as "Column name",i.DATA_TYPE  as "Data type",count(distinct country_id) as "Count of DISTINCT values",t1."Count of NULL values", t2."Count of empty/zero values", t3."Only UPPERCASE strings"from (select COUNT(*) as "Count of NULL values" from  [hr].[countries]  where country_id is NULL) as t1 join (SELECT COUNT(CASE                WHEN ISNUMERIC(country_id) = 1 AND country_id = 0 THEN 1                WHEN ISNUMERIC(country_id) = 0 AND country_id = '' THEN 1              END) AS "Count of empty/zero values"   from  [hr].[countries])  as t2 on 1=1 join (SELECT sum(CASE      WHEN (ISNUMERIC(country_id) = 0) THEN 0               WHEN (ISNUMERIC(country_id) = 0 AND Upper(country_id) COLLATE Latin1_General_CS_AS = country_id ) THEN 1       else 0      end)             AS "Only UPPERCASE strings"    from  [hr].[countries]) as t3 on 1 = 1 join [hr].[countries]  t on 1=1 join INFORMATION_SCHEMA.COLUMNS i on i.TABLE_SCHEMA = 'hr' and i.TABLE_NAME = 'countries' and i.COLUMN_NAME = 'country_id'  group by  i.data_type,   t1."Count of NULL values", t2."Count of empty/zero values",t3."Only UPPERCASE strings"  
/*DECLARE @v_Query NVARCHAR(MAX);
SET @v_Query = 
'Select  '' '+ 
	@p_DatabaseName +' '' as "Database name", '' '+
	@p_SchemaName +' '' as "Schema name", '' '+
	@p_TableName +' ''  as "Table name", '+
	'COUNT(*)  FROM ['+@p_SchemaName+'].[' + @p_TableName + '] as "Total row count"'
;
--select  @v_Query;*/

--EXEC SP_EXECUTESQL @v_Query;*/

Return;
GO  


DECLARE @DatabaseName NVARCHAR(max), @SchemaName NVARCHAR(max), @TableName NVARCHAR(max);
SET @DatabaseName = 'TRN'
SET @SchemaName = 'hr'
SET @TableName = '%'--'countries'--'regions'

 
EXEC Statistics_pr @DatabaseName, @SchemaName, @TableName
 
