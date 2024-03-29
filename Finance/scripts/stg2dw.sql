
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- stg.vwFinIncomeMapping
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

drop view if exists stg.vwFinIncomeMapping
GO

create view stg.vwFinIncomeMapping
as
SELECT distinct [Sub_sector]
      ,[Account_Code]
      ,[Fee_Categorisation]
      ,[License_Type]
      ,[Title_Type]
      ,[Income_Type]
      ,[Income_Sector]
      ,[Country]
      ,[Sector_Ranking]
      ,[Licence_Fee_Country_Ranking]
      ,[Income_Type_Ranking]
      ,[Sub_sector_Ranking]
  FROM [stg2].[fin_IncomeMapping]

GO

--select * from stg.vwFinIncomeMapping


---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- stg.vwFinAdminFeeMapping
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

drop view if exists stg.vwFinAdminFeeMapping
GO

create view stg.vwFinAdminFeeMapping
as
SELECT distinct [Sub_sector]
      ,[Account_Code]
      ,[Fee_Categorisation]
      ,[License_Type]
      ,[Title_Type]
      ,[Income_Type]
      ,[Income_Sector]
      ,[Country]
      ,[Sector_Ranking]
      ,[Licence_Fee_Country_Ranking]
      ,[Income_Type_Ranking]
      ,[Sub_sector_Ranking]
  FROM [stg2].fin_AdminFeeMapping

GO

 
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- stg.vwFinDistributionMapping
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

drop view if exists stg.vwFinDistributionMapping
GO

create view stg.vwFinDistributionMapping
as
SELECT distinct [Sub_sector]
      ,[Account_Code]
      ,[Fee_Categorisation]
      ,[License_Type]
      ,[Title_Type]
      ,[Income_Type]
      ,[Income_Sector]
      ,[Country]
      ,[Distributions_Mapping]
	  ,[Sector_Ranking]
      ,[Licence_Fee_Country_Ranking]
      ,[Income_Type_Ranking]
      ,[Sub_sector_Ranking]
	  ,[Distributions_Mapping_Ranking]
  FROM [stg2].fin_DistributionMapping

GO



---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- dim.FinLicenseFeeCountry
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 DROP TABLE if exists dim.FinLicenseFeeCountry
 GO

CREATE TABLE [dim].[FinLicenseFeeCountry](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Country] [nvarchar](50) NOT NULL,
	[Country Ranking] int NOT NULL,
	[DW_CreatedDate] [datetime] NOT NULL DEFAULT GETDATE(),
	[DW_ModifiedDate] [datetime] NOT NULL DEFAULT GETDATE(),
 CONSTRAINT [dimFinLicenseFeeCountry_pk] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

insert into dim.FinLicenseFeeCountry ([Country], [Country Ranking])
select distinct [Country], CAST(Licence_Fee_Country_Ranking as int) from [stg2].[fin_IncomeMapping] order by CAST(Licence_Fee_Country_Ranking as int) 

select * from dim.FinLicenseFeeCountry

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- dim.FinIncomeSector
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 DROP TABLE if exists dim.FinIncomeSector
 GO

CREATE TABLE [dim].[FinIncomeSector](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Income Sector] [varchar](30) NOT NULL,
	[Income SubSector] [varchar](50) NOT NULL,
	[Income Sector Ranking] int NOT NULL,
	[Income SubSector Ranking] int NOT NULL,
	[DW_CreatedDate] [datetime] NOT NULL DEFAULT GETDATE(),
	[DW_ModifiedDate] [datetime] NOT NULL DEFAULT GETDATE(),
 CONSTRAINT [dimFinIncomeSector_pk] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO


drop view if exists [stg].[vwIncomeSector]
GO

create view [stg].[vwIncomeSector] as
select Sub_sector, [Income_Sector], MIN(Sub_sector_Ranking) Sub_sector_Ranking, MIN(Sector_Ranking) Sector_Ranking from (
select distinct Sub_sector, [Income_Sector], Sub_sector_Ranking, Sector_Ranking from [stg2].[fin_AdminFeeMapping]
UNION 
select distinct Sub_sector, [Income_Sector], Sub_sector_Ranking, Sector_Ranking from [stg2].[fin_DistributionMapping]
UNION 
select distinct Sub_sector, [Income_Sector], Sub_sector_Ranking, Sector_Ranking from stg.vwFinIncomeMapping
) x
group by Sub_sector, [Income_Sector]
GO



insert into dim.FinIncomeSector ([Income Sector], [Income SubSector], [Income Sector Ranking], [Income SubSector Ranking])
select distinct [Income_Sector], [Sub_sector], [Income Sector Ranking], [Income SubSector_Ranking] from
(select [Income_Sector], [Sub_sector], 
MIN(CAST(Sector_Ranking as int)) OVER(PARTITION BY [Income_Sector]) as [Income Sector Ranking], 
MIN(CAST(Sub_sector_Ranking as int)) OVER(PARTITION BY [Sub_Sector]) as [Income SubSector_Ranking]
from [stg].vwIncomeSector group by [Income_Sector], [Sub_sector], Sector_Ranking, Sub_sector_Ranking) x 
order by [Income Sector Ranking], [Income SubSector_Ranking]

--select count(distinct [Income SubSector]) from dim.FinIncomeSector
	
--select count(*) from dim.FinIncomeSector

--select * from dim.FinIncomeSector


---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- dim.FinIncomeType
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 DROP TABLE if exists dim.FinIncomeType
 GO

CREATE TABLE [dim].[FinIncomeType](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Income Type] [varchar](10) NOT NULL,
	[Income Type Ranking] int NOT NULL,
	[DW_CreatedDate] [datetime] NOT NULL DEFAULT GETDATE(),
	[DW_ModifiedDate] [datetime] NOT NULL DEFAULT GETDATE(),
 CONSTRAINT [dimFinIncomeType_pk] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

insert into dim.FinIncomeType ([Income Type], [Income Type Ranking])
select distinct [Income_Type], CAST(Income_Type_Ranking as int) from [stg2].[fin_IncomeMapping] order by CAST(Income_Type_Ranking as int)

select * from dim.FinIncomeType

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- dim.FinAccount
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

drop table if exists dim.FinAccount
GO

SELECT Identity(int, 1, 1) Id
	   ,oact.AcctCode as [Account Code]
	   ,oact.AcctName as [Account Name]
	   ,exmap.[High_Level_Account] as [Expense High Level Account]
	   ,tbmap.[TB_Mapping]
	   ,CAST(exmap.Ranking as int) as [Expense Ranking] 
	   ,CAST(tbmap.[TB_Mapping_Rank] as int) as [TB Ranking] 
	   ,GETDATE() as DW_CreatedDate
	   ,GETDATE() as DW_ModifiedDate
INTO dim.FinAccount
FROM [stg2].[fin_OACT] oact
left join [stg2].[fin_ExpensesMapping] exmap on exmap.[Account] = oact.AcctCode
left join [stg2].[fin_TBMapping] tbmap on tbmap.[Account_Code] = oact.AcctCode

GO

ALTER TABLE dim.FinAccount
ADD CONSTRAINT dimFinAccount_pk PRIMARY KEY (Id);
GO


--select * from dim.FinAccount


---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- dim.FinLicenceType
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

drop table if exists dim.FinLicenceType
GO

SELECT Identity(int, 1, 1) Id
	   ,OCRCode as [Licence Type Code]
	   ,OCRName as [Licence Type]
	   ,GETDATE() as DW_CreatedDate
	   ,GETDATE() as DW_ModifiedDate
INTO dim.FinLicenceType
FROM [stg2].[fin_OOCR]
WHERE LEFT(OCRCode, 1) = 'L'

GO

ALTER TABLE dim.FinLicenceType
ADD CONSTRAINT dimFinLicenceType_pk PRIMARY KEY (Id);

GO


--select * from dim.FinLicenceType



---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- dim.FinFeeCategory
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

drop table if exists dim.FinFeeCategory
GO

SELECT Identity(int, 1, 1) Id
	   ,OCRCode as [Fee Category Code]
	   ,OCRName as [Fee Category]
	   ,GETDATE() as DW_CreatedDate
	   ,GETDATE() as DW_ModifiedDate
INTO dim.FinFeeCategory
FROM [stg2].[fin_OOCR]
WHERE LEFT(OCRCode, 1) = 'X'

GO

ALTER TABLE dim.FinFeeCategory
ADD CONSTRAINT dimFinFeeCategory_pk PRIMARY KEY (Id);

GO

-- select * from dim.FinFeeCategory



---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- dim.FinTitleType
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

drop table if exists dim.FinTitleType
GO

SELECT Identity(int, 1, 1) Id
	   ,OCRCode as [Title Type Code]
	   ,OCRName as [Title Type]
	   ,GETDATE() as DW_CreatedDate
	   ,GETDATE() as DW_ModifiedDate
INTO dim.FinTitleType
FROM [stg2].[fin_OOCR]
WHERE LEFT(OCRCode, 1) = 'S'

GO

ALTER TABLE dim.FinTitleType
ADD CONSTRAINT dimFinTitleType_pk PRIMARY KEY (Id);

GO

-- select * from dim.FinTitleType


---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- dim.FinDepartment
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

drop table if exists dim.FinDepartment
GO

SELECT Identity(int, 1, 1) Id
	   ,OCRCode as [Department Code]
	   ,OCRName as [Department Type]
	   ,GETDATE() as DW_CreatedDate
	   ,GETDATE() as DW_ModifiedDate
INTO dim.FinDepartment
FROM [stg2].[fin_OOCR]
WHERE LEFT(OCRCode, 1) = 'D'

GO

ALTER TABLE dim.FinDepartment
ADD CONSTRAINT dimFinDepartment_pk PRIMARY KEY (Id);

GO

-- select * from dim.FinDepartment


---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- dim.FinExpenseCostType
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

drop table if exists dim.FinExpenseCostType
GO

SELECT distinct Identity(int, 1, 1) Id
	   ,[Cost_Type] as [Expense Cost Type]
	   ,GETDATE() as DW_CreatedDate
	   ,GETDATE() as DW_ModifiedDate
INTO dim.FinExpenseCostType
FROM [stg2].[fin_ExpensesBudget]

GO

ALTER TABLE dim.FinExpenseCostType
ADD CONSTRAINT dimFinExpenseCostType_pk PRIMARY KEY (Id);

GO

-- select * from dim.FinExpenseCostType

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- dim.FinDistributionSubSector
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

drop table if exists dim.FinDistributionSector
GO


CREATE TABLE [dim].[FinDistributionSector](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Distribution Sector] [varchar](30) NOT NULL,
	[Distribution SubSector] [varchar](50) NOT NULL,
	[Distributions Mapping] varchar(50) NULL,
	[Distribution Sector Ranking] int NOT NULL,
	[Distribution SubSector Ranking] int NOT NULL,
	[Distributions_Mapping_Ranking] int NULL,
	[DW_CreatedDate] [datetime] NOT NULL DEFAULT GETDATE(),
	[DW_ModifiedDate] [datetime] NOT NULL DEFAULT GETDATE(),
 CONSTRAINT [dimFinDistributionSector_pk] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO


insert into dim.FinDistributionSector ([Distribution Sector] , [Distribution SubSector], [Distributions Mapping], 
                                          [Distribution Sector Ranking], [Distribution SubSector Ranking], [Distributions_Mapping_Ranking])
select distinct [Income_Sector], [Sub_sector], [Distributions_Mapping], 
CAST(Sector_Ranking as int), CAST(Sub_sector_Ranking as int), CAST([Distributions_Mapping_Ranking] as int)
from [stg].[vwFinDistributionMapping] order by CAST(Sector_Ranking as int), CAST(Sub_sector_Ranking as int), CAST([Distributions_Mapping_Ranking] as int)


--select * from dim.FinDistributionSubSector



---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- dim.FinUndistributedFunds
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

drop table if exists dim.FinUndistributedFunds
GO


CREATE TABLE [dim].[FinUndistributedFunds](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Undistributed Account Code] varchar(10) NOT NULL,
	[Undistributed Fee Categorisation] [varchar](30) NOT NULL,
	[Undistributed Fee Country] [varchar](50) NOT NULL,
	[Undistributed SubSector] varchar(50) NULL,
	[Fee Categorisation Ranking] int NOT NULL,
	[Fee Country Ranking] int NOT NULL,
	[SubSector Ranking] int NOT NULL,
	[DW_CreatedDate] [datetime] NOT NULL DEFAULT GETDATE(),
	[DW_ModifiedDate] [datetime] NOT NULL DEFAULT GETDATE(),
 CONSTRAINT [dimFinUndistributedFunds_pk] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO


insert into dim.FinUndistributedFunds ([Undistributed Account Code], [Undistributed Fee Categorisation], [Undistributed Fee Country], [Undistributed SubSector], 
                                      [Fee Categorisation Ranking], [Fee Country Ranking], [SubSector Ranking])
select distinct [Account_Code], [Fee_Categorisation], [Fee_Country], [Sub_sector], 
 CAST([Income_Sector_Ranking] as int), CAST([Licence_Fee_Country_Ranking] as int), CAST(Sub_sector_Ranking as int)
from [stg2].[fin_UndistributedFundsMappings] 
order by CAST([Income_Sector_Ranking] as int), CAST([Licence_Fee_Country_Ranking] as int), CAST(Sub_sector_Ranking as int)

-- NB: [Income_Sector_Ranking] to be renamed to [Fee_Categorisation_Ranking] in STG table



---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- fct.FinTransaction
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

drop table if exists fct.FinTransaction
GO

CREATE TABLE [fct].[FinTransaction](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[TransId] [int] NULL,
	[Line_ID] [int] NULL,
	[Account] [int] NULL,
	[Fee Category] [int] NULL,
	[Licence Type] [int] NULL,
	[Title Type] [int] NULL,
	[Department] [int] NULL,
	[Income Sector] [int] NULL,
	[Income Type] [int] NULL,
	[Country] [int] NULL,
	[Distribution Sector] [int] NULL,
	[Undistributed Account Code] [int] NULL,
	[Expense Cost Type] [int] NULL,
	[AdminFeePercent] [decimal](19, 6),
	[Posting Date] [datetime2](7) NULL,
	[Debit] [numeric](22, 7) NULL,
	[Credit] [decimal](19, 6) NOT NULL,
	[Contract Account] [nvarchar](15) NULL,
	[Description] [nvarchar](50) NULL,
	[Invoice Number] [nvarchar](100) NULL,
	[Invoice Reference] [nvarchar](100) NULL,
	[Document Date] [datetime2](7) NULL,
	[VAT Group] [nvarchar](8) NULL,
	[VAT Amount] [decimal](19, 6) NULL,
	[BaseSum] [decimal](19, 6) NULL,
	[Income Budget] [money] NULL,
	[Income Daily Budget] [money] NULL,
	[Income Forecast] [money] NULL,
	[Income Daily Forecast] [money] NULL,
	[Expenses Budget] [money] NULL,
	[Expenses Daily Budget] [money] NULL,
	[Expenses Forecast] [money] NULL,
	[Expenses Daily Forecast] [money] NULL,
	[RecordType] [char](5) NULL,
	[DW_CreatedDate] [datetime] NOT NULL DEFAULT GETDATE(),
	[DW_ModifiedDate] [datetime] NOT NULL DEFAULT GETDATE(), 
	CONSTRAINT [fctFinTransaction_pk] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO



INSERT INTO [fct].[FinTransaction] 
           ([TransId], [Line_ID], [Account], [Fee Category], [Licence Type], [Title Type], [Department], [Income Sector], [Income Type], [Country]
           ,[Distribution Sector], [Undistributed Account Code], [Expense Cost Type], [AdminFeePercent], [Posting Date], [Debit], [Credit], [Contract Account], [Description], [Invoice Number]
           ,[Invoice Reference], [Document Date], [VAT Group], [VAT Amount], [BaseSum], [Income Budget], [Income Daily Budget], [Income Forecast], [Income Daily Forecast]
           ,[Expenses Budget], [Expenses Daily Budget], [Expenses Forecast], [Expenses Daily Forecast], [RecordType])
   
SELECT  j.TransId 
		,j.Line_ID
		,a.Id as Account
		,fc.Id as [Fee Category]
		,lt.Id as [Licence Type] 
		,tt.Id as [Title Type]
		,d.Id as Department
		,sec.Id as [Income Sector]
		,it.Id as [Income Type]
		,c.Id as [Country]
		,distrSec.Id as [Distribution Sector]
		,un.Id as [Undistributed Account Code]
		,expCost.ID as [Expense Cost Type]
		,CASE 

			WHEN lt.[Licence Type Code] NOT IN ('L40', 'L41') AND a.[Account Code] IN ('5006', '5007', '5009', '5011', '5021', '5026', '5031', '5041' ) THEN 0.075
			WHEN lt.[Licence Type Code] IN ('L40', 'L41') AND a.[Account Code] IN ('5006', '5007', '5009', '5011', '5021', '5026', '5031', '5041' ) THEN 0.15
			WHEN lt.[Licence Type Code] NOT IN ('L40', 'L41') AND a.[Account Code] IN ( '5045', '5140', '5220' ) THEN 0.11
			WHEN lt.[Licence Type Code] IN ('L40', 'L41') AND a.[Account Code] IN ( '5045', '5140', '5220' ) THEN 0.25
			WHEN tt.[Title Type] ='S450' THEN 0
			WHEN lt.[Licence Type Code] NOT IN ('L40', 'L41') THEN 0.11
			ELSE 0.4
			END AS AdminFeePercent
		,j.RefDate as [Posting Date]
		,(-1.0)*ISNULL(j.Debit, 0) as Debit
		,ISNULL(j.Credit, 0) as Credit
		,j.ContraAct as [Contract Account]
		,j.LineMemo as [Description]
		,j.Ref1 as [Invoice Number]
		,j.Ref2 as [Invoice Reference]
		,j.TaxDate as [Document Date]
		,j.VatGroup as [VAT Group]
		,j.TotalVat as [VAT Amount]
		,j.BaseSum		
		,CAST(null as money) as [Income Budget]
		,CAST(null as money) as [Income Daily Budget]
		,CAST(null as money) as [Income Forecast]
		,CAST(null as money) as [Income Daily Forecast]
		,CAST(null as money) as [Expenses Budget]
		,CAST(null as money) as [Expenses Daily Budget]
		,CAST(null as money) as [Expenses Forecast]
		,CAST(null as money) as [Expenses Daily Forecast]
		,CAST('A' as char(2)) as RecordType

FROM [stg2].[fin_JDT1] j --408,610
left join dim.FinAccount a on a.[Account Code] = j.Account
left join dim.FinFeeCategory fc on fc.[Fee Category Code] = j.OcrCode2
left join dim.FinLicenceType lt on lt.[Licence Type Code] = j.OcrCode3
left join dim.FinTitleType tt on tt.[Title Type Code] = j.OcrCode4
left join dim.FinDepartment d on d.[Department Code] = j.ProfitCode
left join stg.vwFinIncomeMapping imap on imap.[Account_Code] = j.Account and imap.[Fee_Categorisation] = j.OcrCode2 and imap.[License_Type] =j.OcrCode3 and imap.[Title_Type] = j.OcrCode4
left join dim.FinIncomeSector sec on sec.[Income SubSector] = imap.[Sub_Sector] and sec.[Income Sector] = imap.[Income_Sector]  
left join dim.FinIncomeType it on it.[Income Type] = imap.[Income_Type]
left join dim.FinLicenseFeeCountry c on c.[Country] = imap.[Country]
left join stg.vwFinDistributionMapping dmap on dmap.[Account_Code] = j.Account and dmap.[Fee_Categorisation] = j.OcrCode2 and dmap.[License_Type] =j.OcrCode3 and dmap.[Title_Type] = j.OcrCode4
left join dim.FinDistributionSector distrSec on distrSec.[Distribution SubSector] =  dmap.[Sub_Sector] and distrSec.[Distribution Sector] = dmap.[Income_Sector] and distrSec.[Distributions Mapping] = dmap.[Distributions_Mapping] 
left join dim.FinUndistributedFunds un on un.[Undistributed Account Code] = j.Account
left join (select distinct [Account], [Cost_Type] from [stg2].[fin_ExpensesBudget]) expBudget on expBudget.Account = j.Account
left join dim.FinExpenseCostType expCost on expCost.[Expense Cost Type] = expBudget.Cost_Type

GO

--select count(*) FROM fct.FinTransaction
--delete from fct.FinTransaction where RecordType <> 'A'

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- fct.FinBudget
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

drop table if exists [fct].[FinBudget]
GO

CREATE TABLE [fct].[FinBudget](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Account] [int] NULL,
	[Fee Category] [int] NULL,
	[Licence Type] [int] NULL,
	[Title Type] [int] NULL,
	[Income Sector] [int] NULL,
	[Income Type] [int] NULL,
	[Country] [int] NULL,
	[Distribution Sector] [int] NULL,
	[Undistributed Account Code] [int] NULL,
	[Department] [int] NULL,
	[Expenses Cost Type] int,
	[Period] [date] NULL,
	[Income Budget] [money] NULL,
	[Income Daily Budget] [numeric](38, 23) NULL,
	[Income Forecast] [money] NULL,
	[Income Daily Forecast] [numeric](38, 23) NULL,
	[Expenses Budget] money NULL,  
	[Expenses Daily Budget] money, 
	[Expenses Forecast] money,
	[Expenses Daily Forecast] money,
	[RecordType] char(2),
	[DW_CreatedDate] [datetime] NOT NULL default GETDATE(),
	[DW_ModifiedDate] [datetime] NOT NULL default GETDATE(),
    CONSTRAINT [fctFinBudget_pk] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO



drop view if exists stg.vwIncomeBudgetForecast
GO

create view stg.vwIncomeBudgetForecast
as 
select Sub_Sector, Account_Code, [Period], Income, cast(0 as money) as Forecast, License_Type, Fee_Categorisation, Title_Type, Income_Type, Income_Sector, Country   
FROM [stg2].[fin_IncomeBudget] 
UNION ALL
select Sub_Sector, Account_Code, [Period], Cast(0 as money) as Income, Income as Forecast, License_Type, Fee_Categorisation, Title_Type, Income_Type, Income_Sector, Country   
 from [stg2].[fin_IncomeForecast]

 GO


-----------------------------------------------------------------------------------------------------------------------------


drop view if exists stg.vwExpensesBudgetForecast
GO

create view stg.vwExpensesBudgetForecast
as 
select Account, DATEFROMPARTS (LEFT([Period], 4), SUBSTRING([Period], 6, 2), 1) [Period], cast([Budget_Amount] as money) [Expenses Budget], cast(0 as money) [Expenses Forecast], [Department], [Cost_Type]   
FROM [stg2].[fin_ExpensesBudget]
UNION ALL
select Account, DATEFROMPARTS (LEFT([Period], 4), SUBSTRING([Period], 6, 2), 1) [Period], cast(0 as money) [Expenses Budget], cast([Budget_Amount] as money) [Expenses Forecast], [Department], [Cost_Type]   
from [stg2].[fin_ExpensesReforecast]

 GO
 

-----------------------------------------------------------------------------------------------------------------------------


insert into fct.FinBudget (Account, [Fee Category], [Licence Type], [Title Type], [Income Sector], [Income Type], [Country], [Distribution Sector],
		                   [Undistributed Account Code], [Department], [Expenses Cost Type], [Period], [Income Budget], [Income Daily Budget], 
						   [Income Forecast], [Income Daily Forecast], [Expenses Budget],  [Expenses Daily Budget], [Expenses Forecast], [Expenses Daily Forecast], [RecordType]) 


SELECT   a.Id as Account
		,fc.Id as [Fee Category]
		,lt.Id as [Licence Type] 
		,tt.Id as [Title Type]
		,sec.Id as [Income Sector]
		,it.Id as [Income Type]
		,c.Id as [Country]
		,distrSec.Id as [Distribution Sector]
		,un.Id as [Undistributed Account Code]
		,null as [Department]	
		,null as [Expenses Cost Type]
		,convert(date, b.[Period], 105) as [Period]
		,CAST(b.[Income] as money) as [Income Budget]
		,CAST(b.[Income] as money)/CAST(DATEPART(DAY, EOMONTH(convert(date, b.[Period], 105))) as numeric) as [Income Daily Budget]
		,CAST(b.[Forecast] as money) as [Income Forecast]
		,CAST(b.[Forecast] as money)/CAST(DATEPART(DAY, EOMONTH(convert(date, b.[Period], 105))) as numeric) as [Income Daily Forecast]
		, 0 [Expenses Budget], 0 [Expenses Daily Budget], 0 [Expenses Forecast], 0 [Expenses Daily Forecast], 'B' as RecordType

FROM stg.vwIncomeBudgetForecast b 
left join dim.FinAccount a on a.[Account Code] = b.Account_Code
left join dim.FinFeeCategory fc on fc.[Fee Category Code] =  TRIM(b.[Fee_Categorisation])
left join dim.FinLicenceType lt on lt.[Licence Type Code] = TRIM(b.[License_Type])
left join dim.FinTitleType tt on tt.[Title Type Code] = TRIM(b.[Title_Type])
left join stg.vwFinIncomeMapping imap on imap.[Account_Code] = TRIM(b.Account_Code) and imap.[Fee_Categorisation] = TRIM(b.[Fee_Categorisation]) and imap.[License_Type] = TRIM(b.[License_Type]) and imap.[Title_Type] = TRIM(b.[Title_Type])
left join dim.FinIncomeSector sec on sec.[Income SubSector] = imap.[Sub_Sector] and sec.[Income Sector] = imap.[Income_Sector]  
left join dim.FinIncomeType it on it.[Income Type] = imap.[Income_Type]
left join dim.FinLicenseFeeCountry c on c.[Country] = imap.[Country]
left join stg.vwFinDistributionMapping dmap on dmap.[Account_Code] = TRIM(b.Account_Code) and dmap.[Fee_Categorisation] = TRIM(b.[Fee_Categorisation]) and dmap.[License_Type] =TRIM(b.[License_Type]) and dmap.[Title_Type] = TRIM(b.[Title_Type])
left join dim.FinDistributionSector distrSec on distrSec.[Distribution SubSector] =  dmap.[Sub_Sector] and distrSec.[Distribution Sector] = dmap.[Income_Sector]  
left join dim.FinUndistributedFunds un on un.[Undistributed Account Code] = b.Account_Code

UNION ALL -- Expenses Budget

select   a.Id as Account
		,null as [Fee Category]
		,null as [Licence Type] 
		,null as [Title Type]
		,null as [Income Sector]
		,null as [Income Type]
		,null as [Country]
		,null as [Distribution Sector]
		,null as [Undistributed Account Code]	
		,dep.Id as [Department]	
		,expCost.ID as [Expenses Cost Type]
		,expBudget.[Period]
		,0 as [Income Budget], 0 as [Income Daily Budget], 0 as [Income Forecast], 0 as [Income Daily Forecast]
		,expBudget.[Expenses Budget]
		,expBudget.[Expenses Budget]/CAST(DATEPART(DAY, EOMONTH(expBudget.[Period])) as numeric) as [Expenses Daily Budget]
		,expBudget.[Expenses Forecast]
		,expBudget.[Expenses Forecast]/CAST(DATEPART(DAY, EOMONTH(expBudget.[Period])) as numeric) as [Expenses Daily Forecast]
		,'EX' as RecordType

from stg.vwExpensesBudgetForecast expBudget
left join dim.FinAccount a on a.[Account Code] = expBudget.Account
left join dim.FinDepartment dep on dep.[Department Code] = expBudget.[Department]
left join dim.FinExpenseCostType expCost on expCost.[Expense Cost Type] = expBudget.Cost_Type

GO


--select * from fct.FinBudget


--------------------------------------------------------------------------
-- Insert month-level income Budget only
--------------------------------------------------------------------------

insert INTO fct.FinTransaction ([Account],[Fee Category], [Licence Type], [Title Type], [Income Sector], [Income Type], [Country], [Distribution Sector], [Undistributed Account Code],
								[Posting Date], [Debit], [Credit], [Income Budget], [Income Daily Budget], [Income Forecast], [Income Daily Forecast], 
								[Expenses Budget],  [Expenses Daily Budget], [Expenses Forecast], [Expenses Daily Forecast], [RecordType])
SELECT   b.Account
		,b.[Fee Category]
		,b.[Licence Type] 
		,b.[Title Type]
		,b.[Income Sector]
		,b.[Income Type]
		,b.[Country]	
		,b.[Distribution Sector]
		,b.[Undistributed Account Code]	
		,b.[Period] as [Posting Date]
		,0 as Debit
		,0 as Credit
		,b.[Income Budget], 0 as [Income Daily Budget]
		,b.[Income Forecast], 0 as [Income Daily Forecast]
		,b.[Expenses Budget], 0 as [Expenses Daily Budget]
		,b.[Expenses Forecast], 0 as [Expenses Daily Forecast]
		,b.RecordType

FROM fct.FinBudget b



--------------------------------------------------------------------------
-- Insert day-level income Budget 
--------------------------------------------------------------------------


insert INTO fct.FinTransaction  ([Account],[Fee Category], [Licence Type], [Title Type], [Income Sector], [Income Type], [Country], [Distribution Sector], [Undistributed Account Code],
								[Posting Date], [Debit], [Credit], [Income Budget], [Income Daily Budget], [Income Forecast], [Income Daily Forecast], 
								[Expenses Budget],  [Expenses Daily Budget], [Expenses Forecast], [Expenses Daily Forecast], [RecordType])
								
SELECT   b.Account
		,b.[Fee Category]
		,b.[Licence Type] 
		,b.[Title Type]
		,b.[Income Sector]
		,b.[Income Type]
		,b.[Country]
		,b.[Distribution Sector]
		,b.[Undistributed Account Code]		
		,b.[Period] as [Posting Date]
		,0 as Debit
		,0 as Credit
		, 0 as [Income Budget]
		,b.[Income Budget]/CAST(DATEPART(DAY, EOMONTH(d.[Date])) as numeric) as [Income Daily Budget]
		,0 as [Income Forecast]
		,b.[Income Forecast]/CAST(DATEPART(DAY, EOMONTH(d.[Date])) as numeric) as [Income Daily Forecast]
		,0 as [Expenses Budget]
		,b.[Expenses Budget]/CAST(DATEPART(DAY, EOMONTH(d.[Date])) as numeric) as [Expenses Daily Budget]
		,0 as [Expenses Forecast]
		,b.[Expenses Forecast]/CAST(DATEPART(DAY, EOMONTH(d.[Date])) as numeric) as [Expenses Daily Forecast]

		,CASE WHEN b.RecordType = 'B' THEN 'BD' ELSE 'ED' END as RecordType

FROM fct.FinBudget b
left join dim.FinDate d on DATEPART(MONTH, convert(date, b.[Period], 105)) =  DATEPART(MONTH, d.[Date]) 
                       and DATEPART(YEAR, convert(date, b.[Period], 105)) =  DATEPART(YEAR, d.[Date])




--------------------------------------------------------------------------
-- fct.FixedAssets
--------------------------------------------------------------------------

drop table if exists fct.FinFixedAssets
GO


CREATE TABLE [fct].[FinFixedAssets](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ItemCode] [nvarchar](20) NULL,
	[ItemName] [nvarchar](100) NULL,
	[ItmsGrpCod] [int] NULL,
	[AssetClass] [nvarchar](20) NULL,
	[AssetGroup] [nvarchar](15) NULL,
	[AsstStatus] [nvarchar](1) NULL,
	[CapDate] [datetime] NULL,
	[AcqDate] [datetime] NULL,
	[RetDate] [datetime] NULL,
	[DprStart] [datetime] NULL,
	[DprEnd] [datetime] NULL,
	[OcrCode] [nvarchar](8) NULL,
	[APC] [decimal](19, 6) NULL,
	[CreatedDate] [datetime] NULL,
	[TaskID] [int] NULL,
	[SourceLinePosition] [int] NULL,
	[DW_CreatedDate] [datetime] NOT NULL DEFAULT GETDATE(),
	[DW_ModifiedDate] [datetime] NOT NULL DEFAULT GETDATE(), 
	CONSTRAINT [fctFinFixedAssets_pk] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO


INSERT INTO fct.FinFixedAssets
      ([ItemCode]
      ,[ItemName]
      ,[ItmsGrpCod]
      ,[AssetClass]
      ,[AssetGroup]
      ,[AsstStatus]
      ,[CapDate]
      ,[AcqDate]
      ,[RetDate]
      ,[DprStart]
      ,[DprEnd]
      ,[OcrCode]
      ,[APC])
select [ItemCode]
      ,[ItemName]
      ,[ItmsGrpCod]
      ,[AssetClass]
      ,[AssetGroup]
      ,[AsstStatus]
      ,[CapDate]
      ,[AcqDate]
      ,[RetDate]
      ,[DprStart]
      ,[DprEnd]
      ,[OcrCode]
      ,[APC]
FROM [stg2].[fin_FixedAsset]


select * from fct.FinFixedAssets

--------------------------------------------------------------------------
-- TESTS
--------------------------------------------------------------------------

select top 1000 * from [fct].[FinTransaction]
where RecordType not in ('A', 'ED', 'BD')


select min(Date), max(Date) from dim.FinDate
where Year = 2019 and [Month Number] = 9

select sum(CAST([Income] as money)) as Income, count(*) FROM [stg2].[fin_IncomeBudget] 
select sum(CAST([Income] as money)) as Forecast, count(*) FROM [stg2].[fin_IncomeForecast] 

select * from [stg2].[fin_IncomeBudget] 
except
select * FROM [stg2].[fin_IncomeForecast] 


select sum([Income]) as Income, sum([Forecast]) as Forecast, count(*), sum([Daily Income]) as [Daily Income] from fct.FinBudget f
select sum([Income]) as Income, sum([Income ReForecast]) [Income ReForecast], sum([Daily Income]) as [Daily Income], sum([Daily Income Reforecast]) [Daily Income Reforecast]  FROM fct.FinTransaction

---------------------------------------------------------------------------------
GO


 select * from stg.vwIncomeBudgetForecast

select * from [dim].[FinLicenseFeeCountry]


select * from [stg2].[fin_IncomeBudget] b
left join stg.vwFinIncomeMapping imap on imap.[Account_Code] = TRIM(b.Account_Code) and imap.[Fee_Categorisation] = TRIM(b.[Fee_Categorisation]) and imap.[License_Type] = TRIM(b.[License_Type]) and imap.[Title_Type] = TRIM(b.[Title_Type])
left join dim.FinIncomeSector sec on sec.[Income SubSector] = imap.[Sub_Sector] and sec.[Income Sector] = imap.[Income_Sector]  
where sec.[Income Sector] = 'Schools'
and sec.[Income SubSector] = 'State England'


select *--sum(Income) [Income], sum([Daily Income]) [Daily Income] 
FROM fct.[finTransaction] f
left join dim.FinIncomeSector i on i.Id = f.[Income Sector] 
where i.[Income SubSector] = 'Language Schools' 
and f.RecordType = 'BD'
--and MONTH(convert(date, [Period], 105)) = 4
and YEAR([Posting Date]) <> 2018


select * from fct.FinTransaction f
where RecordType = 'BD'
and MONTH([Posting Date]) = 4
and [Income Sector] = 10

select * from [dim].[FinIncomeSector]
where [Income Sector] = 'Schools'
and [Income SubSector] = 'State England'

select * FROM [stg2].[fin_ExpensesReforecast]



select * from [stg2].[fin_IncomeForecast]

 


select count(*)  
FROM [stg2].[fin_JDT1] j 
left join stg.vwFinIncomeMapping imap on imap.[Account_Code] = j.Account and imap.[Fee_Categorisation] = j.OcrCode2 and imap.[License_Type] =j.OcrCode3 and imap.[Title_Type] = j.OcrCode4
left join dim.FinIncomeSector sec on sec.[Income SubSector] = imap.[Sub_Sector] and sec.[Income Sector] = imap.[Income_Sector]  

select count(*) from
(select distinct sec.[Income SubSector] from dim.FinIncomeSector sec) x


select count(*) from
(select * from  dim.FinIncomeSector) x

select count(*) from
(select * from  stg.vwFinIncomeMapping imap
left join dim.FinIncomeSector sec on sec.[Income Sector] = imap.[Income_Sector]
) x

 select count(*) from stg2.fin_IncomeMapping
 
select max(Date) from dim.FinDate
 /*
ALTER TABLE fct.FinTransaction
ADD CONSTRAINT fctFinTransaction_pk PRIMARY KEY (Id);

GO

select * from fct.FinTransaction
*/
