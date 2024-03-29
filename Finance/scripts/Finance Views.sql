
/****** Object:  View [stg].[vwIncomeSector]    Script Date: 17/07/2019 23:57:16 ******/
DROP VIEW IF EXISTS [stg].[vwIncomeSector]
GO
/****** Object:  View [stg].[vwIncomeBudgetForecast]    Script Date: 17/07/2019 23:57:16 ******/
DROP VIEW IF EXISTS [stg].[vwIncomeBudgetForecast]
GO
/****** Object:  View [stg].[vwFinIncomeMapping]    Script Date: 17/07/2019 23:57:16 ******/
DROP VIEW IF EXISTS [stg].[vwFinIncomeMapping]
GO
/****** Object:  View [stg].[vwFinDistributionMapping]    Script Date: 17/07/2019 23:57:16 ******/
DROP VIEW IF EXISTS [stg].[vwFinDistributionMapping]
GO
/****** Object:  View [stg].[vwFinAdminFeeMapping]    Script Date: 17/07/2019 23:57:16 ******/
DROP VIEW IF EXISTS [stg].[vwFinAdminFeeMapping]
GO
/****** Object:  View [stg].[vwExpensesBudgetForecast]    Script Date: 17/07/2019 23:57:16 ******/
DROP VIEW IF EXISTS [stg].[vwExpensesBudgetForecast]
GO
/****** Object:  View [fin].[vwActiveDepartmentUsers]    Script Date: 17/07/2019 23:57:16 ******/
DROP VIEW IF EXISTS [fin].[vwActiveDepartmentUsers]
GO
/****** Object:  View [fct].[vwFinanceAdminFee]    Script Date: 17/07/2019 23:57:16 ******/
DROP VIEW IF EXISTS [fct].[vwFinanceAdminFee]
GO
/****** Object:  View [fact].[vwSalaryExpensesTotals]    Script Date: 17/07/2019 23:57:16 ******/
DROP VIEW IF EXISTS [fact].[vwSalaryExpensesTotals]
GO
/****** Object:  View [fact].[vwSalaryExpenses]    Script Date: 17/07/2019 23:57:16 ******/
DROP VIEW IF EXISTS [fact].[vwSalaryExpenses]
GO
/****** Object:  View [fact].[vwIncome]    Script Date: 17/07/2019 23:57:16 ******/
DROP VIEW IF EXISTS [fact].[vwIncome]
GO
/****** Object:  View [fact].[vwFinTransaction]    Script Date: 17/07/2019 23:57:16 ******/
DROP VIEW IF EXISTS [fact].[vwFinTransaction]
GO
/****** Object:  View [fact].[vwFinanceAdminFee]    Script Date: 17/07/2019 23:57:16 ******/
DROP VIEW IF EXISTS [fact].[vwFinanceAdminFee]
GO
/****** Object:  View [fact].[vwExpenses]    Script Date: 17/07/2019 23:57:16 ******/
DROP VIEW IF EXISTS [fact].[vwExpenses]
GO
/****** Object:  View [dim].[vwFinExpenditureIncomeReportMapping]    Script Date: 17/07/2019 23:57:16 ******/
DROP VIEW IF EXISTS [dim].[vwFinExpenditureIncomeReportMapping]
GO
/****** Object:  View [dim].[vwFinExpenditureIncomeReportMapping]    Script Date: 17/07/2019 23:57:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dim].[vwFinExpenditureIncomeReportMapping]'))
EXEC dbo.sp_executesql @statement = N'




CREATE View [dim].[vwFinExpenditureIncomeReportMapping]
as
select 
id,
[account code],
''Administration Charge on Account'' as Header0,
	case when Cast([account code] as int) between 6010 AND 8999 THEN ''Operating Expense''
		--WHEN Cast([account code] as  int) between 9510 AND 9525 THEN ''Net Interest Receivable''
		else ''Income''
	END AS Header1	,	

	case 
		 WHEN Cast([account code] as  int) between 9510 AND 9525 THEN ''Net Interest Receivable''
	else [account name]
	END AS Header2	,	
	[account name]
			
from dim.finAccount

where [Account Code] not like ''%0000000000000''
and [Account Code] <>''5886 - CCC ROW''
and [Account Code] <>''N/A''
and 
((Cast([account code] as int) between 6010 AND 8999 )
OR
(Cast([account code] as int) between  9510 AND 9525 )
OR
([account code] = ''9505'')
OR
([account code] = ''9530'')
OR
([account code] = ''9510'')
OR
([account code] =''9531'')
)


' 
GO
/****** Object:  View [fact].[vwExpenses]    Script Date: 17/07/2019 23:57:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[fact].[vwExpenses]'))
EXEC dbo.sp_executesql @statement = N'
CREATE VIEW [fact].[vwExpenses] AS

Select [TransId]
		,[Line_ID]
	   ,[Account]
      ,[Department]
      ,[Expense Cost Type]
      ,[AdminFeePercent]
      ,[Posting Date]
      ,[Debit]
      ,[Credit]
      ,[Contract Account]
      ,[Description]
      ,[Invoice Number]
      ,[Invoice Reference]
      ,[Document Date]
      ,[VAT Group]
      ,[VAT Amount]
      ,[BaseSum]
      ,[Expenses Budget]
      ,[Expenses Daily Budget]
      ,[Expenses Reforecast]
      ,[Expenses Daily Reforecast]
,a.[Is Salary Account],d.[department code] from fact.[fintransaction] f 
inner join dim.finaccount a on a.id=f.account
inner join dim.findepartment d on d.id=f.department
where a.[Expense High Level Account] is not null

' 
GO
/****** Object:  View [fact].[vwFinanceAdminFee]    Script Date: 17/07/2019 23:57:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[fact].[vwFinanceAdminFee]'))
EXEC dbo.sp_executesql @statement = N'


CREATE View [fact].[vwFinanceAdminFee]
AS
SELECT 
	CASE 

		WHEN FLT.[Licence Type Code] NOT IN (''L40'', ''L41'') AND FA.[Account Code] IN (''5006'', ''5007'', ''5009'', ''5011'', ''5021'', ''5026'', ''5031'', ''5041'' ) THEN 0.075
		WHEN FLT.[Licence Type Code] IN (''L40'', ''L41'') AND FA.[Account Code] IN (''5006'', ''5007'', ''5009'', ''5011'', ''5021'', ''5026'', ''5031'', ''5041'' ) THEN 0.15
		WHEN FLT.[Licence Type Code] NOT IN (''L40'', ''L41'') AND FA.[Account Code] IN ( ''5045'', ''5140'', ''5220'' ) THEN 0.11
		WHEN FLT.[Licence Type Code] IN (''L40'', ''L41'') AND FA.[Account Code] IN ( ''5045'', ''5140'', ''5220'' ) THEN 0.25
		WHEN FTT.[Title Type] =''S450'' THEN 0
		WHEN FLT.[Licence Type Code] NOT IN (''L40'', ''L41'') THEN 0.11
		ELSE 0.4
	END AS AdminFeePercent,
	Ft.ID

		
		 
FROM
	fact.finTransaction FT 
	INNER JOIN dim.finLicenceType FLT ON FLT.Id= FT.[Licence Type]
	INNER JOIN dim.finAccount FA ON FA.Id= FT.Account
	INNER JOIN dim.finTitleType fTT ON FTT.Id=FT.[Title Type]
' 
GO
/****** Object:  View [fact].[vwFinTransaction]    Script Date: 17/07/2019 23:57:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[fact].[vwFinTransaction]'))
EXEC dbo.sp_executesql @statement = N'

CREATE VIEW [fact].[vwFinTransaction] AS

Select * from fact.[fintransaction]

' 
GO
/****** Object:  View [fact].[vwIncome]    Script Date: 17/07/2019 23:57:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[fact].[vwIncome]'))
EXEC dbo.sp_executesql @statement = N'







CREATE VIEW [fact].[vwIncome] AS
SELECT
-- f.[Id]
--      ,[TransId]
--      ,[Line_ID]
--      ,[Account]
--      ,[Fee Category]
--      ,[Licence Type]
--      ,[Title Type]
--      ,[Department]
--      ,[Income Sector]
--      ,[Income Type]
--      ,[Country]
--      ,[Distribution Sector]
--      ,[Undistributed Account Code]
--      ,[Expense Cost Type]
--      ,[AdminFeePercent]
--      ,[Posting Date]
--      ,[Debit]
--      ,[Credit]
--      ,[Contract Account]
--      ,[Description]
--      ,[Invoice Number]
--      ,[Invoice Reference]
--      ,[Document Date]
--      ,[VAT Group]
--      ,[VAT Amount]
--      ,[BaseSum]
--      ,[Income Budget]
--      ,[Income Daily Budget]
--      ,[Income Reforecast]
--      ,[Income Daily Reforecast]
f.*
,a.[Expense High Level Account],a.[Is Salary Account], d.[Department Code]
from fact.[fintransaction] f 
inner join dim.finaccount a on a.id=f.account
left join dim.findepartment d on d.id=f.department
where a.[Expense High Level Account] is  null

' 
GO
/****** Object:  View [fact].[vwSalaryExpenses]    Script Date: 17/07/2019 23:57:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[fact].[vwSalaryExpenses]'))
EXEC dbo.sp_executesql @statement = N'

Create VIEW [fact].[vwSalaryExpenses] AS

Select f.*,a.[Is Salary Account] from fact.[fintransaction] f inner join dim.finaccount a on a.id=f.account
where a.[Is Salary Account]=1' 
GO
/****** Object:  View [fact].[vwSalaryExpensesTotals]    Script Date: 17/07/2019 23:57:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[fact].[vwSalaryExpensesTotals]'))
EXEC dbo.sp_executesql @statement = N'




CREATE VIEW [fact].[vwSalaryExpensesTotals] AS


SELECT 
      f.[Account]
      ,f.[Expense Cost Type]
	  ,f.Department
      ,f.[Posting Date]
	  ,d.[Department Code]
      ,sum([Debit]) [Debit]
      ,sum([Credit]) [Credit]
      ,sum([VAT Amount]) [Vat Amount]
      ,sum([BaseSum]) [BaseSum]
      ,sum([Expenses Daily Budget]) [Expenses Daily Budget]
      ,sum([Expenses Daily Reforecast]) [Expenses Daily Reforecast]
  FROM [fact].[FinTransaction] F
   inner join dim.finaccount a on a.id=f.account
   LEFT JOIN dim.FinDepartment d on d.id=f.Department
where a.[Is Salary Account]=1

Group BY 
      f.[Account]
      ,[Expense Cost Type]
	  ,f.Department
	  ,d.[Department Code]
      ,[Posting Date]
	  
' 
GO
/****** Object:  View [fct].[vwFinanceAdminFee]    Script Date: 17/07/2019 23:57:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[fct].[vwFinanceAdminFee]'))
EXEC dbo.sp_executesql @statement = N'
CREATE View [fct].[vwFinanceAdminFee]
AS
SELECT 
	CASE 

		WHEN FLT.[Licence Type Code] NOT IN (''L40'', ''L41'') AND FA.[Account Code] IN (''5006'', ''5007'', ''5009'', ''5011'', ''5021'', ''5026'', ''5031'', ''5041'' ) THEN 0.075
		WHEN FLT.[Licence Type Code] IN (''L40'', ''L41'') AND FA.[Account Code] IN (''5006'', ''5007'', ''5009'', ''5011'', ''5021'', ''5026'', ''5031'', ''5041'' ) THEN 0.15
		WHEN FLT.[Licence Type Code] NOT IN (''L40'', ''L41'') AND FA.[Account Code] IN ( ''5045'', ''5140'', ''5220'' ) THEN 0.11
		WHEN FLT.[Licence Type Code] IN (''L40'', ''L41'') AND FA.[Account Code] IN ( ''5045'', ''5140'', ''5220'' ) THEN 0.25
		WHEN FTT.[Title Type] =''S450'' THEN 0
		WHEN FLT.[Licence Type Code] NOT IN (''L40'', ''L41'') THEN 0.11
		ELSE 0.4
	END AS AdminFeePercent,
	Ft.ID

		
		 
FROM
	fct.finTransaction FT 
	INNER JOIN dim.finLicenceType FLT ON FLT.Id= FT.[Licence Type]
	INNER JOIN dim.finAccount FA ON FA.Id= FT.Account
	INNER JOIN dim.finTitleType fTT ON FTT.Id=FT.[Title Type]
' 
GO
/****** Object:  View [fin].[vwActiveDepartmentUsers]    Script Date: 17/07/2019 23:57:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[fin].[vwActiveDepartmentUsers]'))
EXEC dbo.sp_executesql @statement = N'CREATE view [fin].[vwActiveDepartmentUsers]
as 
SELECT 
      [UserName]
      ,[Department] as [Department Code]
      ,[Active]
      ,[ActivatedDate]
      ,[DeActivatedDate]
  FROM [fin].[DepartmentUser]
WHERE Active=1

' 
GO
/****** Object:  View [stg].[vwExpensesBudgetForecast]    Script Date: 17/07/2019 23:57:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[stg].[vwExpensesBudgetForecast]'))
EXEC dbo.sp_executesql @statement = N'
create view [stg].[vwExpensesBudgetForecast]
as 
select Account, DATEFROMPARTS (LEFT([Period], 4), SUBSTRING([Period], 6, 2), 1) [Period], cast([BudgetAmount] as money) [Expenses Budget], cast(0 as money) [Expenses Forecast], [Department], [Cost_Type]   
FROM [land].[fin_ExpensesBudget]
UNION ALL
select Account, DATEFROMPARTS (LEFT([Period], 4), SUBSTRING([Period], 6, 2), 1) [Period], cast(0 as money) [Expenses Budget], cast([BudgetAmount] as money) [Expenses Forecast], [Department], [Cost_Type]   
from land.fin_ExpensesReforecast

' 
GO
/****** Object:  View [stg].[vwFinAdminFeeMapping]    Script Date: 17/07/2019 23:57:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[stg].[vwFinAdminFeeMapping]'))
EXEC dbo.sp_executesql @statement = N'

create view [stg].[vwFinAdminFeeMapping]
as
SELECT distinct [Sub_sector]
      ,[Account_Code]
      ,[Fee_Categorisation]
      ,[License_Type]
      ,[Title_Type]
      ,[Income_Type]
      ,[Income_Sector]
      ,[Uk_International] [Country]
      ,[Sector_Ranking]
      ,[Licence_Fee_Country_Ranking]
      ,[Income_Type_Ranking]
      ,[Sub_sector_Ranking]
  FROM land.fin_AdminFeeMapping
  where valid=1

' 
GO
/****** Object:  View [stg].[vwFinDistributionMapping]    Script Date: 17/07/2019 23:57:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[stg].[vwFinDistributionMapping]'))
EXEC dbo.sp_executesql @statement = N'

create view [stg].[vwFinDistributionMapping]
as
SELECT distinct [Sub_sector]
      ,[Account_Code]
      ,[Fee_Categorisation]
      ,[License_Type]
      ,[Title_Type]
      ,[Income_Type]
      ,[Income_Sector]
      , [Country]
      ,[Distributions_Mapping]
	  ,[Sector_Ranking]
      ,[Licence_Fee_Country_Ranking]
      ,[Income_Type_Ranking]
      ,[Sub_sector_Ranking]
	  ,[Distributions_Mapping_Ranking]
  FROM stg2.fin_DistributionMapping
  --where
  --Valid=1
' 
GO
/****** Object:  View [stg].[vwFinIncomeMapping]    Script Date: 17/07/2019 23:57:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[stg].[vwFinIncomeMapping]'))
EXEC dbo.sp_executesql @statement = N'


CREATE VIEW [stg].[vwFinIncomeMapping]
AS
SELECT DISTINCT [Sub_sector]
      ,[Account_Code]
      ,[Fee_Categorisation]
      ,[License_Type]
      ,[Title_Type]
      ,[Income_Type]
      ,[Income_Sector]
      ,[Uk_International] [Country]
      ,[Sector_Ranking]
      ,[Licence_Fee_Country_Ranking]
      ,[Income_Type_Ranking]
      ,[Sub_sector_Ranking]

FROM land.[fin_IncomeMapping]
--WHERE Valid=1

' 
GO
/****** Object:  View [stg].[vwIncomeBudgetForecast]    Script Date: 17/07/2019 23:57:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[stg].[vwIncomeBudgetForecast]'))
EXEC dbo.sp_executesql @statement = N'
CREATE view [stg].[vwIncomeBudgetForecast]
as 
select ''Budget'' as [Type],Sub_Sector, Account_Code, [Period],Period_month,Period_year ,Income_dec Income, cast(0 as money) as Forecast, License_Type, Fee_Categorisation, Title_Type, Income_Type, Income_Sector, [Uk_International] Country   
FROM land.[fin_IncomeBudget] 
where valid=1

UNION ALL
select ''Reforecast'' as [Type],Sub_Sector, Account_Code, [Period],Period_month,Period_year,Cast(0 as money) as Income, Income_dec as Forecast, License_Type, Fee_Categorisation, Title_Type, Income_Type, Income_Sector,[Uk_International]  Country   
 from land.[fin_IncomeReForecast]
 where valid=1
' 
GO
/****** Object:  View [stg].[vwIncomeSector]    Script Date: 17/07/2019 23:57:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[stg].[vwIncomeSector]'))
EXEC dbo.sp_executesql @statement = N'


CREATE VIEW [stg].[vwIncomeSector] as
SELECT Sub_sector, [Income_Sector], MIN(Sub_sector_Ranking) Sub_sector_Ranking, MIN(Sector_Ranking) Sector_Ranking FROM
(
SELECT DISTINCT Sub_sector, [Income_Sector], Sub_sector_Ranking, Sector_Ranking FROM land.[fin_AdminFeeMapping] -- WHERE valid=1
--UNION 
--SELECT DISTINCT Sub_sector, [Income_Sector], Sub_sector_Ranking, Sector_Ranking FROM [stg2].[fin_DistributionMapping] 
UNION 
SELECT DISTINCT Sub_sector, [Income_Sector], Sub_sector_Ranking, Sector_Ranking FROM land.Fin_IncomeMapping
) x
GROUP BY Sub_sector, [Income_Sector]
' 
GO
