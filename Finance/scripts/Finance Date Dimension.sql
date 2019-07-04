exec etl.LoadDateDimension
go

Create procedure etl.LoadDateDimension
AS
-- Script to populate dim.FinDate data. 
-- Truncate and re-populate 
Truncate table dim.finDate

DECLARE @StartDate DATE = (select min(OFPR.F_RefDate) as Min_Date from stg2.[fin_OFPR] OFPR) 
DECLARE @NumberOfYears INT =(select DATEDIFF(YEAR, 2013, max(OFPR.F_RefDate))  from stg2.[fin_OFPR] OFPR)  --2013 is when the first transactions start in JDT1


SET DATEFIRST 7;
SET DATEFORMAT mdy;
SET LANGUAGE US_ENGLISH;

DECLARE @CutoffDate DATE = DATEADD(YEAR, @NumberOfYears, @StartDate);


INSERT into dim.FinDate([Date], [Quarter], AbsEntry, [Period Code], [Period Name], F_RefDate, T_RefDate) 
SELECT d.[Date],  'Q' 
+ CAST(case when CAST(RIGHT(OFPR.[Code] , 2) as int) <= 3 then 1 when CAST(RIGHT(OFPR.[Code] , 2) as int) >= 4 and CAST(RIGHT(OFPR.[Code] , 2) as int) <= 6 then 2
            when CAST(RIGHT(OFPR.[Code] , 2) as int) >=7 and CAST(RIGHT(OFPR.[Code] , 2) as int) <= 9 then 3 else 4 end as char(1)) + ' ' + LEFT(OFPR.[Code], 4),
OFPR.AbsEntry, OFPR.[Code] [Period Code], OFPR.Name [Period Name], OFPR.F_RefDate, OFPR.T_RefDate 
FROM
(
  SELECT [date] = DATEADD(DAY, rn - 1, @StartDate)
  FROM 
  (
    SELECT TOP (DATEDIFF(DAY, @StartDate, @CutoffDate)) 
      rn = ROW_NUMBER() OVER (ORDER BY s1.[object_id])
    FROM sys.all_objects AS s1
    CROSS JOIN sys.all_objects AS s2
    ORDER BY s1.[object_id]
  ) AS x
) AS d
left join stg2.[fin_OFPR] OFPR on d.[date] >= OFPR.F_RefDate and d.[date] <= OFPR.T_RefDate



-- NB: 
select * from dim.FinDate d
where [Date] = '2019-01-31' 




