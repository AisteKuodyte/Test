USE [master]
GO
/****** Object:  Database [datawarehouse_dev]    Script Date: 6/25/2019 3:32:04 PM ******/
CREATE DATABASE [datawarehouse_dev]
GO
ALTER DATABASE [datawarehouse_dev] SET COMPATIBILITY_LEVEL = 140
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [datawarehouse_dev].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [datawarehouse_dev] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [datawarehouse_dev] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [datawarehouse_dev] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [datawarehouse_dev] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [datawarehouse_dev] SET ARITHABORT OFF 
GO
ALTER DATABASE [datawarehouse_dev] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [datawarehouse_dev] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [datawarehouse_dev] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [datawarehouse_dev] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [datawarehouse_dev] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [datawarehouse_dev] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [datawarehouse_dev] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [datawarehouse_dev] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [datawarehouse_dev] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [datawarehouse_dev] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [datawarehouse_dev] SET ALLOW_SNAPSHOT_ISOLATION ON 
GO
ALTER DATABASE [datawarehouse_dev] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [datawarehouse_dev] SET READ_COMMITTED_SNAPSHOT ON 
GO
ALTER DATABASE [datawarehouse_dev] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [datawarehouse_dev] SET  MULTI_USER 
GO
ALTER DATABASE [datawarehouse_dev] SET DB_CHAINING OFF 
GO
ALTER DATABASE [datawarehouse_dev] SET ENCRYPTION ON
GO
ALTER DATABASE [datawarehouse_dev] SET QUERY_STORE = ON
GO
ALTER DATABASE [datawarehouse_dev] SET QUERY_STORE (OPERATION_MODE = READ_WRITE, CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 30), DATA_FLUSH_INTERVAL_SECONDS = 900, INTERVAL_LENGTH_MINUTES = 60, MAX_STORAGE_SIZE_MB = 100, QUERY_CAPTURE_MODE = AUTO, SIZE_BASED_CLEANUP_MODE = AUTO)
GO
USE [datawarehouse_dev]
GO
/****** Object:  User [cla_etl]    Script Date: 6/25/2019 3:32:04 PM ******/
CREATE USER [cla_etl] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_owner] ADD MEMBER [cla_etl]
GO
/****** Object:  Schema [dim]    Script Date: 6/25/2019 3:32:05 PM ******/
CREATE SCHEMA [dim]
GO
/****** Object:  Schema [err]    Script Date: 6/25/2019 3:32:05 PM ******/
CREATE SCHEMA [err]
GO
/****** Object:  Schema [etl]    Script Date: 6/25/2019 3:32:05 PM ******/
CREATE SCHEMA [etl]
GO
/****** Object:  Schema [fact]    Script Date: 6/25/2019 3:32:05 PM ******/
CREATE SCHEMA [fact]
GO
/****** Object:  Schema [fct]    Script Date: 6/25/2019 3:32:05 PM ******/
CREATE SCHEMA [fct]
GO
/****** Object:  Schema [fin]    Script Date: 6/25/2019 3:32:05 PM ******/
CREATE SCHEMA [fin]
GO
/****** Object:  Schema [land]    Script Date: 6/25/2019 3:32:05 PM ******/
CREATE SCHEMA [land]
GO
/****** Object:  Schema [stg]    Script Date: 6/25/2019 3:32:05 PM ******/
CREATE SCHEMA [stg]
GO
/****** Object:  Schema [stg2]    Script Date: 6/25/2019 3:32:05 PM ******/
CREATE SCHEMA [stg2]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_diagramobjects]    Script Date: 6/25/2019 3:32:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

	CREATE FUNCTION [dbo].[fn_diagramobjects]() 
	RETURNS int
	WITH EXECUTE AS N'dbo'
	AS
	BEGIN
		declare @id_upgraddiagrams		int
		declare @id_sysdiagrams			int
		declare @id_helpdiagrams		int
		declare @id_helpdiagramdefinition	int
		declare @id_creatediagram	int
		declare @id_renamediagram	int
		declare @id_alterdiagram 	int 
		declare @id_dropdiagram		int
		declare @InstalledObjects	int

		select @InstalledObjects = 0

		select 	@id_upgraddiagrams = object_id(N'dbo.sp_upgraddiagrams'),
			@id_sysdiagrams = object_id(N'dbo.sysdiagrams'),
			@id_helpdiagrams = object_id(N'dbo.sp_helpdiagrams'),
			@id_helpdiagramdefinition = object_id(N'dbo.sp_helpdiagramdefinition'),
			@id_creatediagram = object_id(N'dbo.sp_creatediagram'),
			@id_renamediagram = object_id(N'dbo.sp_renamediagram'),
			@id_alterdiagram = object_id(N'dbo.sp_alterdiagram'), 
			@id_dropdiagram = object_id(N'dbo.sp_dropdiagram')

		if @id_upgraddiagrams is not null
			select @InstalledObjects = @InstalledObjects + 1
		if @id_sysdiagrams is not null
			select @InstalledObjects = @InstalledObjects + 2
		if @id_helpdiagrams is not null
			select @InstalledObjects = @InstalledObjects + 4
		if @id_helpdiagramdefinition is not null
			select @InstalledObjects = @InstalledObjects + 8
		if @id_creatediagram is not null
			select @InstalledObjects = @InstalledObjects + 16
		if @id_renamediagram is not null
			select @InstalledObjects = @InstalledObjects + 32
		if @id_alterdiagram  is not null
			select @InstalledObjects = @InstalledObjects + 64
		if @id_dropdiagram is not null
			select @InstalledObjects = @InstalledObjects + 128
		
		return @InstalledObjects 
	END
	
GO
/****** Object:  Table [fct].[finTransaction]    Script Date: 6/25/2019 3:32:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [fct].[finTransaction](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[TransId] [int] NULL,
	[Line_ID] [int] NULL,
	[Account] [int] NOT NULL,
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
	[AdminFeePercent] [decimal](19, 6) NULL,
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
	[DW_CreatedDate] [datetime] NOT NULL,
	[DW_ModifiedDate] [datetime] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dim].[FinAccount]    Script Date: 6/25/2019 3:32:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dim].[FinAccount](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Account Code] [nvarchar](15) NULL,
	[Account Name] [nvarchar](100) NULL,
	[Expense High Level Account] [nvarchar](50) NULL,
	[TB_Mapping] [nvarchar](50) NULL,
	[Expense Ranking] [int] NULL,
	[TB Ranking] [int] NULL,
	[DW_CreatedDate] [datetime] NOT NULL,
	[DW_ModifiedDate] [datetime] NOT NULL,
 CONSTRAINT [dimFinAccount_pk] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [IX_FinAccount] UNIQUE NONCLUSTERED 
(
	[Account Code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dim].[FinLicenceType]    Script Date: 6/25/2019 3:32:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dim].[FinLicenceType](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Licence Type Code] [nvarchar](8) NULL,
	[Licence Type] [nvarchar](30) NULL,
	[DW_CreatedDate] [datetime] NOT NULL,
	[DW_ModifiedDate] [datetime] NOT NULL,
 CONSTRAINT [dimFinLicenceType_pk] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [IX_FinLicenceType] UNIQUE NONCLUSTERED 
(
	[Licence Type Code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dim].[FinTitleType]    Script Date: 6/25/2019 3:32:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dim].[FinTitleType](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Title Type Code] [nvarchar](8) NULL,
	[Title Type] [nvarchar](30) NULL,
	[DW_CreatedDate] [datetime] NOT NULL,
	[DW_ModifiedDate] [datetime] NOT NULL,
 CONSTRAINT [dimFinTitleType_pk] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [IX_FinTitleType] UNIQUE NONCLUSTERED 
(
	[Title Type Code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [fact].[vwFinanceAdminFee]    Script Date: 6/25/2019 3:32:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


Create View [fact].[vwFinanceAdminFee]
AS
SELECT 
	CASE 

		WHEN FLT.[Licence Type Code] NOT IN ('L40', 'L41') AND FA.[Account Code] IN ('5006', '5007', '5009', '5011', '5021', '5026', '5031', '5041' ) THEN 0.075
		WHEN FLT.[Licence Type Code] IN ('L40', 'L41') AND FA.[Account Code] IN ('5006', '5007', '5009', '5011', '5021', '5026', '5031', '5041' ) THEN 0.15
		WHEN FLT.[Licence Type Code] NOT IN ('L40', 'L41') AND FA.[Account Code] IN ( '5045', '5140', '5220' ) THEN 0.11
		WHEN FLT.[Licence Type Code] IN ('L40', 'L41') AND FA.[Account Code] IN ( '5045', '5140', '5220' ) THEN 0.25
		WHEN FTT.[Title Type] ='S450' THEN 0
		WHEN FLT.[Licence Type Code] NOT IN ('L40', 'L41') THEN 0.11
		ELSE 0.4
	END AS AdminFeePercent,
	Ft.ID

		
		 
FROM
	fct.finTransaction FT 
	INNER JOIN dim.finLicenceType FLT ON FLT.Id= FT.[Licence Type]
	INNER JOIN dim.finAccount FA ON FA.Id= FT.Account
	INNER JOIN dim.finTitleType fTT ON FTT.Id=FT.[Title Type]
GO
/****** Object:  View [fct].[vwFinanceAdminFee]    Script Date: 6/25/2019 3:32:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE View [fct].[vwFinanceAdminFee]
AS
SELECT 
	CASE 

		WHEN FLT.[Licence Type Code] NOT IN ('L40', 'L41') AND FA.[Account Code] IN ('5006', '5007', '5009', '5011', '5021', '5026', '5031', '5041' ) THEN 0.075
		WHEN FLT.[Licence Type Code] IN ('L40', 'L41') AND FA.[Account Code] IN ('5006', '5007', '5009', '5011', '5021', '5026', '5031', '5041' ) THEN 0.15
		WHEN FLT.[Licence Type Code] NOT IN ('L40', 'L41') AND FA.[Account Code] IN ( '5045', '5140', '5220' ) THEN 0.11
		WHEN FLT.[Licence Type Code] IN ('L40', 'L41') AND FA.[Account Code] IN ( '5045', '5140', '5220' ) THEN 0.25
		WHEN FTT.[Title Type] ='S450' THEN 0
		WHEN FLT.[Licence Type Code] NOT IN ('L40', 'L41') THEN 0.11
		ELSE 0.4
	END AS AdminFeePercent,
	Ft.ID

		
		 
FROM
	fct.finTransaction FT 
	INNER JOIN dim.finLicenceType FLT ON FLT.Id= FT.[Licence Type]
	INNER JOIN dim.finAccount FA ON FA.Id= FT.Account
	INNER JOIN dim.finTitleType fTT ON FTT.Id=FT.[Title Type]
GO
/****** Object:  View [dim].[vwFinExpenditureIncomeReportMapping]    Script Date: 6/25/2019 3:32:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE View [dim].[vwFinExpenditureIncomeReportMapping]
as
select 
id,
[account code],
'Administration Charge on Account' as Header0,
	case when Cast([account code] as int) between 6010 AND 8999 THEN 'Operating Expense'
		--WHEN Cast([account code] as  int) between 9510 AND 9525 THEN 'Net Interest Receivable'
		else 'Income'
	END AS Header1	,	

	case 
		 WHEN Cast([account code] as  int) between 9510 AND 9525 THEN 'Net Interest Receivable'
	else [account name]
	END AS Header2	,	
	[account name]
			
from dim.finAccount

where [Account Code] not like '%0000000000000'
and [Account Code] <>'5886 - CCC ROW'
and [Account Code] <>'N/A'
and 
((Cast([account code] as int) between 6010 AND 8999 )
OR
(Cast([account code] as int) between  9510 AND 9525 )
OR
([account code] = '9505')
OR
([account code] = '9530')
OR
([account code] = '9510')

)


GO
/****** Object:  Table [fact].[FinTransaction]    Script Date: 6/25/2019 3:32:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [fact].[FinTransaction](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[TransId] [int] NULL,
	[Line_ID] [int] NULL,
	[Account] [int] NOT NULL,
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
	[AdminFeePercent] [decimal](19, 6) NULL,
	[Posting Date] [datetime2](7) NULL,
	[Debit] [decimal](22, 7) NULL,
	[Credit] [decimal](19, 6) NOT NULL,
	[Contract Account] [nvarchar](15) NULL,
	[Description] [nvarchar](50) NULL,
	[Invoice Number] [nvarchar](100) NULL,
	[Invoice Reference] [nvarchar](100) NULL,
	[Document Date] [datetime2](7) NULL,
	[VAT Group] [nvarchar](8) NULL,
	[VAT Amount] [decimal](19, 6) NULL,
	[BaseSum] [decimal](19, 6) NULL,
	[Income Budget] [decimal](19, 6) NULL,
	[Income Daily Budget] [decimal](19, 6) NULL,
	[Income Forecast] [decimal](19, 6) NULL,
	[Income Daily Forecast] [decimal](19, 6) NULL,
	[Expenses Budget] [decimal](19, 6) NULL,
	[Expenses Daily Budget] [decimal](19, 6) NULL,
	[Expenses Forecast] [decimal](19, 6) NULL,
	[Expenses Daily Forecast] [decimal](19, 6) NULL,
	[RecordType] [char](5) NULL,
	[DW_CreatedDate] [datetime] NOT NULL,
	[DW_ModifiedDate] [datetime] NOT NULL,
 CONSTRAINT [factFinTransaction_pk] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [fact].[vwFinTransaction]    Script Date: 6/25/2019 3:32:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [fact].[vwFinTransaction] AS

Select * from fact.[fintransaction]

GO
/****** Object:  Table [land].[fin_IncomeMapping]    Script Date: 6/25/2019 3:32:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [land].[fin_IncomeMapping](
	[Sub_sector] [nvarchar](50) NULL,
	[Account_Code] [nvarchar](10) NULL,
	[Fee_Categorisation] [nvarchar](50) NULL,
	[License_Type] [nvarchar](10) NULL,
	[Title_Type] [nvarchar](10) NULL,
	[BK_Count] [int] NULL,
	[Income_Type] [nvarchar](10) NULL,
	[Income_Sector] [nvarchar](30) NULL,
	[UK_International] [nvarchar](50) NULL,
	[Sector_Ranking_src] [nvarchar](10) NULL,
	[Sector_Ranking] [int] NULL,
	[Sector_Ranking_isNumeric] [int] NULL,
	[Licence_Fee_Country_Ranking_src] [nvarchar](10) NULL,
	[Licence_Fee_Country_Ranking] [int] NULL,
	[Licence_Fee_Country_Ranking_isNumeric] [int] NULL,
	[Income_Type_Ranking_src] [nvarchar](10) NULL,
	[Income_Type_Ranking] [int] NULL,
	[Income_Type_Ranking_isNumeric] [int] NULL,
	[Sub_sector_Ranking_src] [nvarchar](10) NULL,
	[Sub_sector_Ranking] [int] NULL,
	[Sub_sector_Ranking_isNumeric] [int] NULL,
	[Created] [datetime2](7) NULL,
	[TaskID] [int] NULL,
	[SourceLinePosition] [bigint] NULL,
	[Valid] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  View [stg].[vwFinIncomeMapping]    Script Date: 6/25/2019 3:32:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


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
WHERE Valid=1

GO
/****** Object:  Table [land].[fin_AdminFeeMapping]    Script Date: 6/25/2019 3:32:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [land].[fin_AdminFeeMapping](
	[Sub_sector] [nvarchar](50) NULL,
	[Account_Code] [nvarchar](10) NULL,
	[Fee_Categorisation] [nvarchar](50) NULL,
	[License_Type] [nvarchar](10) NULL,
	[Title_Type] [nvarchar](10) NULL,
	[BK_Count] [int] NULL,
	[Income_Type] [nvarchar](10) NULL,
	[Income_Sector] [nvarchar](30) NULL,
	[UK_International] [nvarchar](50) NULL,
	[Sector_Ranking_src] [nvarchar](10) NULL,
	[Sector_Ranking] [int] NULL,
	[Sector_Ranking_isNumeric] [int] NULL,
	[Licence_Fee_Country_Ranking_src] [nvarchar](10) NULL,
	[Licence_Fee_Country_Ranking] [int] NULL,
	[Licence_Fee_Country_Ranking_isNumeric] [int] NULL,
	[Income_Type_Ranking_src] [nvarchar](10) NULL,
	[Income_Type_Ranking] [int] NULL,
	[Income_Type_Ranking_isNumeric] [int] NULL,
	[Sub_sector_Ranking_src] [nvarchar](10) NULL,
	[Sub_sector_Ranking] [int] NULL,
	[Sub_sector_Ranking_isNumeric] [int] NULL,
	[Created] [datetime2](7) NULL,
	[TaskID] [int] NULL,
	[SourceLinePosition] [bigint] NULL,
	[Valid] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  View [stg].[vwFinAdminFeeMapping]    Script Date: 6/25/2019 3:32:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


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

GO
/****** Object:  Table [stg2].[fin_DistributionMapping]    Script Date: 6/25/2019 3:32:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [stg2].[fin_DistributionMapping](
	[Sub_sector] [varchar](50) NULL,
	[Account_Code] [varchar](10) NULL,
	[Fee_Categorisation] [varchar](10) NULL,
	[License_Type] [varchar](10) NULL,
	[Title_Type] [varchar](10) NULL,
	[Income_Type] [varchar](10) NULL,
	[Income_Sector] [varchar](30) NULL,
	[Country] [varchar](50) NULL,
	[Distributions_Mapping] [varchar](50) NULL,
	[Sector_Ranking] [varchar](10) NULL,
	[Licence_Fee_Country_Ranking] [varchar](10) NULL,
	[Income_Type_Ranking] [varchar](10) NULL,
	[Sub_sector_Ranking] [varchar](10) NULL,
	[Distributions_Mapping_Ranking] [varchar](10) NULL,
	[CreatedDate] [datetime] NULL,
	[TaskID] [int] NULL,
	[SourceLinePosition] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  View [stg].[vwFinDistributionMapping]    Script Date: 6/25/2019 3:32:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


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
GO
/****** Object:  View [stg].[vwIncomeSector]    Script Date: 6/25/2019 3:32:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [stg].[vwIncomeSector] as
SELECT Sub_sector, [Income_Sector], MIN(Sub_sector_Ranking) Sub_sector_Ranking, MIN(Sector_Ranking) Sector_Ranking FROM
(
SELECT DISTINCT Sub_sector, [Income_Sector], Sub_sector_Ranking, Sector_Ranking FROM land.[fin_AdminFeeMapping] WHERE valid=1
UNION 
SELECT DISTINCT Sub_sector, [Income_Sector], Sub_sector_Ranking, Sector_Ranking FROM [stg2].[fin_DistributionMapping] 
UNION 
SELECT DISTINCT Sub_sector, [Income_Sector], Sub_sector_Ranking, Sector_Ranking FROM stg.vwFinIncomeMapping
) x
GROUP BY Sub_sector, [Income_Sector]
GO
/****** Object:  Table [land].[fin_ExpensesBudget]    Script Date: 6/25/2019 3:32:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [land].[fin_ExpensesBudget](
	[Period] [nvarchar](10) NULL,
	[Account] [nvarchar](10) NULL,
	[BK_Count] [int] NULL,
	[Period_Year] [int] NULL,
	[Period_Quarter] [int] NULL,
	[Period_Month] [int] NULL,
	[Period_Valid] [int] NULL,
	[BudgetAmount_src] [nvarchar](10) NULL,
	[BudgetAmount] [float] NULL,
	[BudgetAmount_isNumeric] [int] NULL,
	[BudgetAmount_Expl] [nvarchar](20) NULL,
	[Account_Name] [nvarchar](100) NULL,
	[Department] [nvarchar](10) NULL,
	[Cost_Type] [nvarchar](100) NULL,
	[FY] [varchar](10) NULL,
	[CreatedDate] [datetime] NULL,
	[TaskID] [int] NULL,
	[SourceLinePosition] [int] NULL,
	[Valid] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [land].[fin_ExpensesReforecast]    Script Date: 6/25/2019 3:32:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [land].[fin_ExpensesReforecast](
	[Period] [nvarchar](10) NULL,
	[Account] [nvarchar](10) NULL,
	[BK_Count] [int] NULL,
	[Period_Year] [int] NULL,
	[Period_Quarter] [int] NULL,
	[Period_Month] [int] NULL,
	[Period_Valid] [int] NULL,
	[BudgetAmount_src] [nvarchar](10) NULL,
	[BudgetAmount] [float] NULL,
	[BudgetAmount_isNumeric] [int] NULL,
	[BudgetAmount_Expl] [nvarchar](20) NULL,
	[Account_Name] [nvarchar](100) NULL,
	[Department] [nvarchar](10) NULL,
	[Cost_Type] [nvarchar](100) NULL,
	[FY] [varchar](10) NULL,
	[CreatedDate] [datetime] NULL,
	[TaskID] [int] NULL,
	[SourceLinePosition] [int] NULL,
	[Valid] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  View [stg].[vwExpensesBudgetForecast]    Script Date: 6/25/2019 3:32:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create view [stg].[vwExpensesBudgetForecast]
as 
select Account, DATEFROMPARTS (LEFT([Period], 4), SUBSTRING([Period], 6, 2), 1) [Period], cast([BudgetAmount] as money) [Expenses Budget], cast(0 as money) [Expenses Forecast], [Department], [Cost_Type]   
FROM [land].[fin_ExpensesBudget]
UNION ALL
select Account, DATEFROMPARTS (LEFT([Period], 4), SUBSTRING([Period], 6, 2), 1) [Period], cast(0 as money) [Expenses Budget], cast([BudgetAmount] as money) [Expenses Forecast], [Department], [Cost_Type]   
from land.fin_ExpensesReforecast

GO
/****** Object:  Table [land].[fin_IncomeReforecast]    Script Date: 6/25/2019 3:32:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [land].[fin_IncomeReforecast](
	[Sub_sector] [nvarchar](50) NULL,
	[Account_Code] [nvarchar](10) NULL,
	[Period] [nvarchar](10) NULL,
	[Period_valid] [int] NULL,
	[Period_Year] [int] NULL,
	[Period_Quarter] [int] NULL,
	[Period_Month] [int] NULL,
	[Income_src] [nvarchar](20) NULL,
	[Income_dec] [float] NULL,
	[Income_isNumeric] [int] NULL,
	[Income_Expl] [nvarchar](20) NULL,
	[License_Type] [nvarchar](10) NULL,
	[Fee_Categorisation] [nvarchar](10) NULL,
	[Title_Type] [nvarchar](10) NULL,
	[BK_Count] [int] NULL,
	[Income_Type] [nvarchar](10) NULL,
	[Income_Sector] [nvarchar](30) NULL,
	[UK_International] [nvarchar](50) NULL,
	[FY] [char](6) NULL,
	[CreatedDate] [datetime] NULL,
	[TaskID] [int] NULL,
	[SourceLinePosition] [bigint] NULL,
	[Valid] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [land].[fin_IncomeBudget]    Script Date: 6/25/2019 3:32:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [land].[fin_IncomeBudget](
	[Sub_sector] [nvarchar](50) NULL,
	[Account_Code] [nvarchar](10) NULL,
	[Period] [nvarchar](10) NULL,
	[Period_valid] [int] NULL,
	[Period_Year] [int] NULL,
	[Period_Quarter] [int] NULL,
	[Period_Month] [int] NULL,
	[Income_src] [nvarchar](20) NULL,
	[Income_dec] [float] NULL,
	[Income_isNumeric] [int] NULL,
	[Income_Expl] [nvarchar](20) NULL,
	[License_Type] [nvarchar](10) NULL,
	[Fee_Categorisation] [nvarchar](10) NULL,
	[Title_Type] [nvarchar](10) NULL,
	[BK_Count] [int] NULL,
	[Income_Type] [nvarchar](10) NULL,
	[Income_Sector] [nvarchar](30) NULL,
	[UK_International] [nvarchar](50) NULL,
	[FY] [char](6) NULL,
	[CreatedDate] [datetime] NULL,
	[TaskID] [int] NULL,
	[SourceLinePosition] [bigint] NULL,
	[Valid] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  View [stg].[vwIncomeBudgetForecast]    Script Date: 6/25/2019 3:32:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [stg].[vwIncomeBudgetForecast]
as 
select 'Budget' as [Type],Sub_Sector, Account_Code, [Period],Period_month,Period_year ,Income_dec Income, cast(0 as money) as Forecast, License_Type, Fee_Categorisation, Title_Type, Income_Type, Income_Sector, [Uk_International] Country   
FROM land.[fin_IncomeBudget] 
where valid=1

UNION ALL
select 'Reforecast' as [Type],Sub_Sector, Account_Code, [Period],Period_month,Period_year,Cast(0 as money) as Income, Income_dec as Forecast, License_Type, Fee_Categorisation, Title_Type, Income_Type, Income_Sector,[Uk_International]  Country   
 from land.[fin_IncomeReForecast]
 where valid=1
GO
/****** Object:  Table [dbo].[FinDate]    Script Date: 6/25/2019 3:32:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FinDate](
	[Date] [date] NOT NULL,
	[Day]  AS (datepart(day,[date])),
	[Month Number] [int] NULL,
	[Month]  AS (datename(month,[date])),
	[Year] [int] NULL,
	[Fin Year] [varchar](5) NULL,
	[Quarter Number] [int] NULL,
	[Quarter] [char](7) NULL,
	[Week] [int] NULL,
	[FirstOfMonth]  AS (CONVERT([date],dateadd(month,datediff(month,(0),[date]),(0)))),
	[FirstOfYear] [date] NULL,
	[Style112]  AS (CONVERT([char](8),[date],(112))),
	[Style101]  AS (CONVERT([char](10),[date],(101))),
	[AbsEntry] [nvarchar](8) NULL,
	[Period Code] [nvarchar](30) NULL,
	[Period Name] [nvarchar](30) NULL,
	[F_RefDate] [datetime] NULL,
	[T_RefDate] [datetime] NULL,
	[DW_CreatedDate] [datetime] NOT NULL,
	[DW_ModifiedDate] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Date] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[sysdiagrams]    Script Date: 6/25/2019 3:32:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[sysdiagrams](
	[name] [sysname] NOT NULL,
	[principal_id] [int] NOT NULL,
	[diagram_id] [int] IDENTITY(1,1) NOT NULL,
	[version] [int] NULL,
	[definition] [varbinary](max) NULL,
PRIMARY KEY CLUSTERED 
(
	[diagram_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UK_principal_name] UNIQUE NONCLUSTERED 
(
	[principal_id] ASC,
	[name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dim].[FinDate]    Script Date: 6/25/2019 3:32:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dim].[FinDate](
	[Date] [date] NOT NULL,
	[Day]  AS (datepart(day,[date])),
	[Month Number]  AS (CONVERT([int],right([Period Code],(2)))),
	[Month]  AS (datename(month,[date])),
	[Year]  AS (CONVERT([int],left([Period Code],(4)))),
	[Fin Year]  AS (case when datepart(month,[date])>=(4) then (right(CONVERT([char](4),datepart(year,[Date])),(2))+'-')+right(CONVERT([char](4),datepart(year,[Date])+(1)),(2)) else (right(CONVERT([char](4),datepart(year,[Date])-(1)),(2))+'-')+right(CONVERT([char](4),datepart(year,[Date])),(2)) end),
	[Quarter Number]  AS (case when CONVERT([int],right([Period Code],(2)))<=(3) then (1) when CONVERT([int],right([Period Code],(2)))>=(4) AND CONVERT([int],right([Period Code],(2)))<=(6) then (2) when CONVERT([int],right([Period Code],(2)))>=(7) AND CONVERT([int],right([Period Code],(2)))<=(9) then (3) else (4) end),
	[Quarter] [char](7) NULL,
	[Week]  AS (case when [Date]>=CONVERT([date],left([Period Code],(4))+'0401') then datediff(week,CONVERT([date],left([Period Code],(4))+'0401'),[Date])+(1) else datediff(week,CONVERT([date],CONVERT([char](4),CONVERT([int],left([Period Code],(4)))-(1))+'0401'),[Date])+(1) end),
	[FirstOfMonth]  AS (CONVERT([date],dateadd(month,datediff(month,(0),[date]),(0)))),
	[FirstOfYear]  AS (CONVERT([date],left([Period Code],(4))+'0401')),
	[Style112]  AS (CONVERT([char](8),[date],(112))),
	[Style101]  AS (CONVERT([char](10),[date],(101))),
	[AbsEntry] [nvarchar](8) NULL,
	[Period Code] [nvarchar](30) NULL,
	[Period Name] [nvarchar](30) NULL,
	[F_RefDate] [datetime] NULL,
	[T_RefDate] [datetime] NULL,
	[DW_CreatedDate] [datetime] NOT NULL,
	[DW_ModifiedDate] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Date] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dim].[FinDepartment]    Script Date: 6/25/2019 3:32:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dim].[FinDepartment](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Department Code] [nvarchar](8) NULL,
	[Department Type] [nvarchar](30) NULL,
	[DW_CreatedDate] [datetime] NOT NULL,
	[DW_ModifiedDate] [datetime] NOT NULL,
 CONSTRAINT [dimFinDepartment_pk] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dim].[FinDistributionSector]    Script Date: 6/25/2019 3:32:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dim].[FinDistributionSector](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Distribution Sector] [varchar](30) NOT NULL,
	[Distribution SubSector] [varchar](50) NOT NULL,
	[Distributions Mapping] [varchar](50) NULL,
	[Distribution Sector Ranking] [int] NOT NULL,
	[Distribution SubSector Ranking] [int] NOT NULL,
	[Distributions_Mapping_Ranking] [int] NULL,
	[DW_CreatedDate] [datetime] NOT NULL,
	[DW_ModifiedDate] [datetime] NOT NULL,
 CONSTRAINT [dimFinDistributionSector_pk] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dim].[FinExpenseCostType]    Script Date: 6/25/2019 3:32:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dim].[FinExpenseCostType](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Expense Cost Type] [nvarchar](50) NULL,
	[DW_CreatedDate] [datetime] NOT NULL,
	[DW_ModifiedDate] [datetime] NOT NULL,
 CONSTRAINT [dimFinExpenseCostType_pk] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [IX_FinExpenseCostType] UNIQUE NONCLUSTERED 
(
	[Expense Cost Type] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dim].[FinFeeCategory]    Script Date: 6/25/2019 3:32:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dim].[FinFeeCategory](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Fee Category Code] [nvarchar](8) NULL,
	[Fee Category] [nvarchar](30) NULL,
	[DW_CreatedDate] [datetime] NOT NULL,
	[DW_ModifiedDate] [datetime] NOT NULL,
 CONSTRAINT [dimFinFeeCategory_pk] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [IX_FinFeeCategory] UNIQUE NONCLUSTERED 
(
	[Fee Category Code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dim].[FinIncomeSector]    Script Date: 6/25/2019 3:32:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dim].[FinIncomeSector](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Income Sector] [nvarchar](30) NOT NULL,
	[Income SubSector] [nvarchar](50) NOT NULL,
	[Income Sector Ranking] [int] NOT NULL,
	[Income SubSector Ranking] [int] NOT NULL,
	[DW_CreatedDate] [datetime] NOT NULL,
	[DW_ModifiedDate] [datetime] NOT NULL,
 CONSTRAINT [dimFinIncomeSector_pk] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [IX_FinIncomeSector] UNIQUE NONCLUSTERED 
(
	[Income Sector] ASC,
	[Income SubSector] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dim].[FinIncomeType]    Script Date: 6/25/2019 3:32:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dim].[FinIncomeType](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Income Type] [nvarchar](10) NOT NULL,
	[Income Type Ranking] [int] NOT NULL,
	[DW_CreatedDate] [datetime] NOT NULL,
	[DW_ModifiedDate] [datetime] NOT NULL,
 CONSTRAINT [dimFinIncomeType_pk] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [IX_FinIncomeType] UNIQUE NONCLUSTERED 
(
	[Income Type] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dim].[FinLicenseFeeCountry]    Script Date: 6/25/2019 3:32:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dim].[FinLicenseFeeCountry](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Country] [nvarchar](50) NOT NULL,
	[Country Ranking] [int] NOT NULL,
	[DW_CreatedDate] [datetime] NOT NULL,
	[DW_ModifiedDate] [datetime] NOT NULL,
 CONSTRAINT [dimFinLicenseFeeCountry_pk] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [IX_FinLicenseFeeCountry] UNIQUE NONCLUSTERED 
(
	[Country] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dim].[FinUndistributedFunds]    Script Date: 6/25/2019 3:32:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dim].[FinUndistributedFunds](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Undistributed Account Code] [nvarchar](10) NOT NULL,
	[Undistributed Fee Categorisation] [nvarchar](30) NOT NULL,
	[Undistributed Fee Country] [nvarchar](50) NOT NULL,
	[Undistributed SubSector] [nvarchar](50) NULL,
	[Fee Categorisation Ranking] [int] NOT NULL,
	[Fee Country Ranking] [int] NOT NULL,
	[SubSector Ranking] [int] NOT NULL,
	[DW_CreatedDate] [datetime] NOT NULL,
	[DW_ModifiedDate] [datetime] NOT NULL,
 CONSTRAINT [dimFinUndistributedFunds_pk] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [IX_FinUndistributedFunds] UNIQUE NONCLUSTERED 
(
	[Undistributed Account Code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [fact].[FinFixedAsset]    Script Date: 6/25/2019 3:32:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [fact].[FinFixedAsset](
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
	[DW_CreatedDate] [datetime] NOT NULL,
	[DW_ModifiedDate] [datetime] NOT NULL,
 CONSTRAINT [fctFinFixedAssets_pk] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [fin].[ExpensesBudget]    Script Date: 6/25/2019 3:32:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [fin].[ExpensesBudget](
	[Period] [nvarchar](7) NOT NULL,
	[Account] [decimal](4, 0) NOT NULL,
	[BudgetAmount] [nvarchar](8) NOT NULL,
	[Account_Name] [nvarchar](100) NOT NULL,
	[Department] [nvarchar](4) NOT NULL,
	[Cost_Type] [nvarchar](100) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [fin].[ExpensesReforcast]    Script Date: 6/25/2019 3:32:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [fin].[ExpensesReforcast](
	[Period] [nvarchar](7) NOT NULL,
	[Account] [decimal](4, 0) NOT NULL,
	[BudgetAmount] [nvarchar](8) NOT NULL,
	[Account_Name] [nvarchar](100) NOT NULL,
	[Department] [nvarchar](4) NOT NULL,
	[Cost_Type] [nvarchar](100) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [land].[fin_ExpensesMapping]    Script Date: 6/25/2019 3:32:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [land].[fin_ExpensesMapping](
	[Account] [nvarchar](10) NULL,
	[Account_int] [int] NULL,
	[Account_isNumeric] [int] NULL,
	[BK_Count] [int] NULL,
	[Account_Name] [nvarchar](50) NULL,
	[High_Level_Account] [nvarchar](50) NULL,
	[Ranking] [nvarchar](30) NULL,
	[Created] [datetime] NULL,
	[TaskID] [int] NULL,
	[SourceLinePosition] [bigint] NULL,
	[Valid] [int] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [land].[fin_FixedAsset]    Script Date: 6/25/2019 3:32:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [land].[fin_FixedAsset](
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
	[ItemCode_isPopulated] [int] NULL,
	[ItemCode_Expl] [nvarchar](20) NULL,
	[ItemName_isPopulated] [int] NULL,
	[ItemName_Expl] [nvarchar](20) NULL,
	[AssetClass_isPopulated] [int] NULL,
	[AssetClass_Expl] [nvarchar](20) NULL,
	[AssetGroup_isPopulated] [int] NULL,
	[AssetGroup_Expl] [nvarchar](20) NULL,
	[AsstStatus_isPopulated] [int] NULL,
	[AsstStatus_Expl] [nvarchar](20) NULL,
	[OcrCode_isPopulated] [int] NULL,
	[OcrCode_Expl] [nvarchar](20) NULL,
	[Valid] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [land].[fin_JDT1]    Script Date: 6/25/2019 3:32:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [land].[fin_JDT1](
	[TransId] [int] NULL,
	[TransId_isPopulated] [int] NULL,
	[Line_ID] [int] NULL,
	[Line_ID_isPopulated] [int] NULL,
	[BK_Count] [int] NULL,
	[Account] [nvarchar](15) NULL,
	[Account_isPopulated] [int] NULL,
	[Account_Expl] [nvarchar](20) NULL,
	[Debit] [decimal](19, 6) NULL,
	[Debit_isPopulated] [int] NULL,
	[Credit] [decimal](19, 6) NULL,
	[Credit_isPopulated] [int] NULL,
	[ContraAct] [nvarchar](15) NULL,
	[LineMemo] [nvarchar](50) NULL,
	[RefDate] [datetime] NULL,
	[RefDate_isPopulated] [int] NULL,
	[Ref1] [nvarchar](100) NULL,
	[Ref2] [nvarchar](100) NULL,
	[ProfitCode] [nvarchar](10) NULL,
	[TaxDate] [datetime] NULL,
	[VatGroup] [nvarchar](8) NULL,
	[BaseSum] [decimal](19, 6) NULL,
	[OcrCode2] [nvarchar](8) NULL,
	[OcrCode3] [nvarchar](8) NULL,
	[OcrCode4] [nvarchar](8) NULL,
	[TotalVat] [decimal](19, 6) NULL,
	[TaskStart] [datetime] NULL,
	[TaskID] [int] NULL,
	[Valid] [int] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [land].[fin_OACT]    Script Date: 6/25/2019 3:32:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [land].[fin_OACT](
	[AcctCode] [nvarchar](15) NULL,
	[AcctCodeValid] [int] NULL,
	[AcctCodeExpl] [nvarchar](50) NULL,
	[AcctCodeCount] [int] NULL,
	[AcctName] [nvarchar](100) NULL,
	[AcctNameValid] [int] NULL,
	[AcctNameExpl] [nvarchar](50) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[TaskID] [int] NULL,
	[Score] [int] NULL,
	[Valid] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [land].[fin_OFPR]    Script Date: 6/25/2019 3:32:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [land].[fin_OFPR](
	[AbsEntry] [int] NULL,
	[AbsEntry_Count] [int] NULL,
	[AbsEntry_isValid] [int] NULL,
	[AbsEntry_Expl] [nvarchar](20) NULL,
	[Code] [nvarchar](30) NULL,
	[Code_Year] [int] NULL,
	[Code_Month] [int] NULL,
	[Code_Quarter] [int] NULL,
	[Code_isPopulated] [int] NULL,
	[Code_Expl] [nvarchar](20) NULL,
	[Name] [nvarchar](30) NULL,
	[Name_isPopulated] [int] NULL,
	[Name_Expl] [nvarchar](20) NULL,
	[F_RefDate] [datetime2](7) NULL,
	[F_RefDate_isValid] [int] NULL,
	[F_RefDate_Expl] [nvarchar](20) NULL,
	[T_RefDate] [datetime2](7) NULL,
	[T_RefDate_isValid] [int] NULL,
	[T_RefDate_Expl] [nvarchar](20) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[TaskID] [int] NULL,
	[QualityScore] [int] NULL,
	[Valid] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [land].[fin_OOCR]    Script Date: 6/25/2019 3:32:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [land].[fin_OOCR](
	[OcrCode] [nvarchar](15) NULL,
	[OcrCodeValid] [int] NULL,
	[OcrCodeExpl] [nvarchar](50) NULL,
	[OcrCodeCount] [int] NULL,
	[OcrName] [nvarchar](100) NULL,
	[OcrNameValid] [int] NULL,
	[OcrNameExpl] [nvarchar](50) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[TaskID] [int] NULL,
	[Score] [int] NULL,
	[Valid] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [land].[fin_TBMapping]    Script Date: 6/25/2019 3:32:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [land].[fin_TBMapping](
	[Account_Code] [nvarchar](10) NULL,
	[BK_Count] [int] NULL,
	[Account_Name] [nvarchar](50) NULL,
	[TB_Mapping] [nvarchar](50) NULL,
	[Account_Rank] [nvarchar](10) NULL,
	[TB_Mapping_Rank] [nvarchar](10) NULL,
	[Created] [datetime] NULL,
	[TaskID] [int] NULL,
	[SourceLinePosition] [bigint] NULL,
	[Valid] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [stg].[FinBudget]    Script Date: 6/25/2019 3:32:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [stg].[FinBudget](
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
	[Expenses Cost Type] [int] NULL,
	[Period] [date] NULL,
	[Income Budget] [money] NULL,
	[Income Daily Budget] [numeric](38, 23) NULL,
	[Income Forecast] [money] NULL,
	[Income Daily Forecast] [numeric](38, 23) NULL,
	[Expenses Budget] [money] NULL,
	[Expenses Daily Budget] [money] NULL,
	[Expenses Forecast] [money] NULL,
	[Expenses Daily Forecast] [money] NULL,
	[RecordType] [char](2) NULL,
	[DW_CreatedDate] [datetime] NOT NULL,
	[DW_ModifiedDate] [datetime] NOT NULL,
 CONSTRAINT [fctFinBudget_pk] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [stg2].[fin_AdminFeeMapping]    Script Date: 6/25/2019 3:32:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [stg2].[fin_AdminFeeMapping](
	[Sub_sector] [varchar](50) NULL,
	[Account_Code] [varchar](10) NULL,
	[Fee_Categorisation] [varchar](10) NULL,
	[License_Type] [varchar](10) NULL,
	[Title_Type] [varchar](10) NULL,
	[Income_Type] [varchar](10) NULL,
	[Income_Sector] [varchar](30) NULL,
	[Country] [varchar](50) NULL,
	[Sector_Ranking] [varchar](10) NULL,
	[Licence_Fee_Country_Ranking] [varchar](10) NULL,
	[Income_Type_Ranking] [varchar](10) NULL,
	[Sub_sector_Ranking] [varchar](10) NULL,
	[CreatedDate] [datetime] NULL,
	[TaskID] [int] NULL,
	[SourceLinePosition] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [stg2].[fin_ExpensesBudget]    Script Date: 6/25/2019 3:32:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [stg2].[fin_ExpensesBudget](
	[Period] [varchar](10) NULL,
	[Account] [varchar](10) NULL,
	[Budget_Amount] [varchar](10) NULL,
	[Account_Name] [varchar](50) NULL,
	[Department] [varchar](50) NULL,
	[Cost_Type] [varchar](50) NULL,
	[CreatedDate] [datetime] NULL,
	[TaskID] [int] NULL,
	[SourceLinePosition] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [stg2].[fin_ExpensesMapping]    Script Date: 6/25/2019 3:32:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [stg2].[fin_ExpensesMapping](
	[Account] [varchar](10) NULL,
	[Account_Name] [varchar](50) NULL,
	[High_Level_Account] [varchar](50) NULL,
	[Ranking] [varchar](30) NULL,
	[CreatedDate] [datetime] NULL,
	[TaskID] [int] NULL,
	[SourceLinePosition] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [stg2].[fin_ExpensesReforecast]    Script Date: 6/25/2019 3:32:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [stg2].[fin_ExpensesReforecast](
	[Period] [varchar](10) NULL,
	[Account] [varchar](10) NULL,
	[Budget_Amount] [varchar](10) NULL,
	[Account_Name] [varchar](50) NULL,
	[Department] [varchar](50) NULL,
	[Cost_Type] [varchar](50) NULL,
	[CreatedDate] [datetime] NULL,
	[TaskID] [int] NULL,
	[SourceLinePosition] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [stg2].[fin_FixedAsset]    Script Date: 6/25/2019 3:32:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [stg2].[fin_FixedAsset](
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
	[SourceLinePosition] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [stg2].[fin_IncomeBudget]    Script Date: 6/25/2019 3:32:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [stg2].[fin_IncomeBudget](
	[Sub_sector] [varchar](50) NULL,
	[Account_Code] [varchar](10) NULL,
	[Period] [varchar](30) NULL,
	[Income] [varchar](10) NULL,
	[License_Type] [varchar](10) NULL,
	[Fee_Categorisation] [varchar](10) NULL,
	[Title_Type] [varchar](10) NULL,
	[Income_Type] [varchar](10) NULL,
	[Income_Sector] [varchar](10) NULL,
	[Country] [varchar](50) NULL,
	[CreatedDate] [datetime] NULL,
	[TaskID] [int] NULL,
	[SourceLinePosition] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [stg2].[fin_IncomeForecast]    Script Date: 6/25/2019 3:32:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [stg2].[fin_IncomeForecast](
	[Sub_sector] [varchar](50) NULL,
	[Account_Code] [varchar](10) NOT NULL,
	[Period] [varchar](30) NULL,
	[Income] [varchar](10) NULL,
	[License_Type] [varchar](10) NULL,
	[Fee_Categorisation] [varchar](10) NULL,
	[Title_Type] [varchar](10) NULL,
	[Income_Type] [varchar](10) NULL,
	[Income_Sector] [varchar](10) NULL,
	[Country] [varchar](50) NULL,
	[CreatedDate] [datetime] NULL,
	[TaskID] [int] NULL,
	[SourceLinePosition] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [stg2].[fin_IncomeMapping]    Script Date: 6/25/2019 3:32:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [stg2].[fin_IncomeMapping](
	[Sub_sector] [nvarchar](50) NULL,
	[Account_Code] [nvarchar](10) NULL,
	[Fee_Categorisation] [nvarchar](50) NULL,
	[License_Type] [nvarchar](10) NULL,
	[Title_Type] [nvarchar](10) NULL,
	[Income_Type] [nvarchar](10) NULL,
	[Income_Sector] [nvarchar](30) NULL,
	[Country] [nvarchar](50) NULL,
	[Sector_Ranking] [nvarchar](10) NULL,
	[Licence_Fee_Country_Ranking] [nvarchar](10) NULL,
	[Income_Type_Ranking] [nvarchar](10) NULL,
	[Sub_sector_Ranking] [nvarchar](10) NULL,
	[CreatedDate] [datetime] NULL,
	[TaskID] [int] NULL,
	[SourceLinePosition] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [stg2].[fin_JDT1]    Script Date: 6/25/2019 3:32:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [stg2].[fin_JDT1](
	[TransId] [int] NULL,
	[Line_ID] [int] NULL,
	[Account] [nvarchar](15) NULL,
	[Debit] [decimal](19, 6) NULL,
	[Credit] [decimal](19, 6) NULL,
	[ContraAct] [nvarchar](15) NULL,
	[LineMemo] [nvarchar](50) NULL,
	[RefDate] [datetime2](7) NULL,
	[Ref1] [nvarchar](100) NULL,
	[Ref2] [nvarchar](100) NULL,
	[ProfitCode] [nvarchar](8) NULL,
	[TaxDate] [datetime2](7) NULL,
	[VatGroup] [nvarchar](8) NULL,
	[BaseSum] [decimal](19, 6) NULL,
	[OcrCode2] [nvarchar](8) NULL,
	[OcrCode3] [nvarchar](8) NULL,
	[OcrCode4] [nvarchar](8) NULL,
	[TotalVat] [decimal](19, 6) NULL,
	[CreatedDate] [datetime] NULL,
	[TaskID] [int] NULL,
	[SourceLinePosition] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [stg2].[fin_OACT]    Script Date: 6/25/2019 3:32:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [stg2].[fin_OACT](
	[AcctCode] [nvarchar](15) NULL,
	[AcctName] [nvarchar](100) NULL,
	[CreatedDate] [datetime] NULL,
	[TaskID] [int] NULL,
	[SourceLinePosition] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [stg2].[fin_OFPR]    Script Date: 6/25/2019 3:32:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [stg2].[fin_OFPR](
	[AbsEntry] [nvarchar](8) NULL,
	[Code] [nvarchar](30) NULL,
	[Name] [nvarchar](30) NULL,
	[F_RefDate] [datetime] NULL,
	[T_RefDate] [datetime] NULL,
	[CreatedDate] [datetime] NULL,
	[TaskID] [int] NULL,
	[SourceLinePosition] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [stg2].[fin_OOCR]    Script Date: 6/25/2019 3:32:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [stg2].[fin_OOCR](
	[OcrCode] [nvarchar](8) NULL,
	[OcrName] [nvarchar](30) NULL,
	[CreatedDate] [datetime] NULL,
	[TaskID] [int] NULL,
	[SourceLinePosition] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [stg2].[fin_TBMapping]    Script Date: 6/25/2019 3:32:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [stg2].[fin_TBMapping](
	[Account_Code] [nvarchar](30) NULL,
	[Account_Name] [nvarchar](50) NULL,
	[TB_Mapping] [nvarchar](50) NULL,
	[Account_Rank] [nvarchar](10) NULL,
	[TB_Mapping_Rank] [nvarchar](10) NULL,
	[CreatedDate] [datetime] NULL,
	[TaskID] [int] NULL,
	[SourceLinePosition] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [stg2].[fin_UndistributedFundsMappings]    Script Date: 6/25/2019 3:32:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [stg2].[fin_UndistributedFundsMappings](
	[Sub_sector] [varchar](50) NULL,
	[Account_Code] [varchar](10) NULL,
	[Fee_Categorisation] [varchar](30) NULL,
	[Fee_Country] [varchar](50) NULL,
	[Total_Undistributed_Amount] [varchar](50) NULL,
	[Income_Sector_Ranking] [varchar](10) NULL,
	[Licence_Fee_Country_Ranking] [varchar](10) NULL,
	[Total_Undistributed_Amount_Ranking] [varchar](10) NULL,
	[Sub_sector_Ranking] [varchar](10) NULL,
	[CreatedDate] [datetime] NULL,
	[TaskID] [int] NULL,
	[SourceLinePosition] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FinDate] ADD  DEFAULT (getdate()) FOR [DW_CreatedDate]
GO
ALTER TABLE [dbo].[FinDate] ADD  DEFAULT (getdate()) FOR [DW_ModifiedDate]
GO
ALTER TABLE [dim].[FinDate] ADD  DEFAULT (getdate()) FOR [DW_CreatedDate]
GO
ALTER TABLE [dim].[FinDate] ADD  DEFAULT (getdate()) FOR [DW_ModifiedDate]
GO
ALTER TABLE [dim].[FinDistributionSector] ADD  DEFAULT (getdate()) FOR [DW_CreatedDate]
GO
ALTER TABLE [dim].[FinDistributionSector] ADD  DEFAULT (getdate()) FOR [DW_ModifiedDate]
GO
ALTER TABLE [dim].[FinIncomeSector] ADD  DEFAULT (getdate()) FOR [DW_CreatedDate]
GO
ALTER TABLE [dim].[FinIncomeSector] ADD  DEFAULT (getdate()) FOR [DW_ModifiedDate]
GO
ALTER TABLE [dim].[FinIncomeType] ADD  DEFAULT (getdate()) FOR [DW_CreatedDate]
GO
ALTER TABLE [dim].[FinIncomeType] ADD  DEFAULT (getdate()) FOR [DW_ModifiedDate]
GO
ALTER TABLE [dim].[FinLicenseFeeCountry] ADD  DEFAULT (getdate()) FOR [DW_CreatedDate]
GO
ALTER TABLE [dim].[FinLicenseFeeCountry] ADD  DEFAULT (getdate()) FOR [DW_ModifiedDate]
GO
ALTER TABLE [dim].[FinUndistributedFunds] ADD  DEFAULT (getdate()) FOR [DW_CreatedDate]
GO
ALTER TABLE [dim].[FinUndistributedFunds] ADD  DEFAULT (getdate()) FOR [DW_ModifiedDate]
GO
ALTER TABLE [fact].[FinFixedAsset] ADD  DEFAULT (getdate()) FOR [DW_CreatedDate]
GO
ALTER TABLE [fact].[FinFixedAsset] ADD  DEFAULT (getdate()) FOR [DW_ModifiedDate]
GO
ALTER TABLE [fact].[FinTransaction] ADD  DEFAULT (getdate()) FOR [DW_CreatedDate]
GO
ALTER TABLE [fact].[FinTransaction] ADD  DEFAULT (getdate()) FOR [DW_ModifiedDate]
GO
ALTER TABLE [stg].[FinBudget] ADD  DEFAULT (getdate()) FOR [DW_CreatedDate]
GO
ALTER TABLE [stg].[FinBudget] ADD  DEFAULT (getdate()) FOR [DW_ModifiedDate]
GO
/****** Object:  StoredProcedure [dbo].[sp_alterdiagram]    Script Date: 6/25/2019 3:32:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

	CREATE PROCEDURE [dbo].[sp_alterdiagram]
	(
		@diagramname 	sysname,
		@owner_id	int	= null,
		@version 	int,
		@definition 	varbinary(max)
	)
	WITH EXECUTE AS 'dbo'
	AS
	BEGIN
		set nocount on
	
		declare @theId 			int
		declare @retval 		int
		declare @IsDbo 			int
		
		declare @UIDFound 		int
		declare @DiagId			int
		declare @ShouldChangeUID	int
	
		if(@diagramname is null)
		begin
			RAISERROR ('Invalid ARG', 16, 1)
			return -1
		end
	
		execute as caller;
		select @theId = DATABASE_PRINCIPAL_ID();	 
		select @IsDbo = IS_MEMBER(N'db_owner'); 
		if(@owner_id is null)
			select @owner_id = @theId;
		revert;
	
		select @ShouldChangeUID = 0
		select @DiagId = diagram_id, @UIDFound = principal_id from dbo.sysdiagrams where principal_id = @owner_id and name = @diagramname 
		
		if(@DiagId IS NULL or (@IsDbo = 0 and @theId <> @UIDFound))
		begin
			RAISERROR ('Diagram does not exist or you do not have permission.', 16, 1);
			return -3
		end
	
		if(@IsDbo <> 0)
		begin
			if(@UIDFound is null or USER_NAME(@UIDFound) is null) -- invalid principal_id
			begin
				select @ShouldChangeUID = 1 ;
			end
		end

		-- update dds data			
		update dbo.sysdiagrams set definition = @definition where diagram_id = @DiagId ;

		-- change owner
		if(@ShouldChangeUID = 1)
			update dbo.sysdiagrams set principal_id = @theId where diagram_id = @DiagId ;

		-- update dds version
		if(@version is not null)
			update dbo.sysdiagrams set version = @version where diagram_id = @DiagId ;

		return 0
	END
	
GO
/****** Object:  StoredProcedure [dbo].[sp_creatediagram]    Script Date: 6/25/2019 3:32:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

	CREATE PROCEDURE [dbo].[sp_creatediagram]
	(
		@diagramname 	sysname,
		@owner_id		int	= null, 	
		@version 		int,
		@definition 	varbinary(max)
	)
	WITH EXECUTE AS 'dbo'
	AS
	BEGIN
		set nocount on
	
		declare @theId int
		declare @retval int
		declare @IsDbo	int
		declare @userName sysname
		if(@version is null or @diagramname is null)
		begin
			RAISERROR (N'E_INVALIDARG', 16, 1);
			return -1
		end
	
		execute as caller;
		select @theId = DATABASE_PRINCIPAL_ID(); 
		select @IsDbo = IS_MEMBER(N'db_owner');
		revert; 
		
		if @owner_id is null
		begin
			select @owner_id = @theId;
		end
		else
		begin
			if @theId <> @owner_id
			begin
				if @IsDbo = 0
				begin
					RAISERROR (N'E_INVALIDARG', 16, 1);
					return -1
				end
				select @theId = @owner_id
			end
		end
		-- next 2 line only for test, will be removed after define name unique
		if EXISTS(select diagram_id from dbo.sysdiagrams where principal_id = @theId and name = @diagramname)
		begin
			RAISERROR ('The name is already used.', 16, 1);
			return -2
		end
	
		insert into dbo.sysdiagrams(name, principal_id , version, definition)
				VALUES(@diagramname, @theId, @version, @definition) ;
		
		select @retval = @@IDENTITY 
		return @retval
	END
	
GO
/****** Object:  StoredProcedure [dbo].[sp_dropdiagram]    Script Date: 6/25/2019 3:32:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

	CREATE PROCEDURE [dbo].[sp_dropdiagram]
	(
		@diagramname 	sysname,
		@owner_id	int	= null
	)
	WITH EXECUTE AS 'dbo'
	AS
	BEGIN
		set nocount on
		declare @theId 			int
		declare @IsDbo 			int
		
		declare @UIDFound 		int
		declare @DiagId			int
	
		if(@diagramname is null)
		begin
			RAISERROR ('Invalid value', 16, 1);
			return -1
		end
	
		EXECUTE AS CALLER;
		select @theId = DATABASE_PRINCIPAL_ID();
		select @IsDbo = IS_MEMBER(N'db_owner'); 
		if(@owner_id is null)
			select @owner_id = @theId;
		REVERT; 
		
		select @DiagId = diagram_id, @UIDFound = principal_id from dbo.sysdiagrams where principal_id = @owner_id and name = @diagramname 
		if(@DiagId IS NULL or (@IsDbo = 0 and @UIDFound <> @theId))
		begin
			RAISERROR ('Diagram does not exist or you do not have permission.', 16, 1)
			return -3
		end
	
		delete from dbo.sysdiagrams where diagram_id = @DiagId;
	
		return 0;
	END
	
GO
/****** Object:  StoredProcedure [dbo].[sp_helpdiagramdefinition]    Script Date: 6/25/2019 3:32:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

	CREATE PROCEDURE [dbo].[sp_helpdiagramdefinition]
	(
		@diagramname 	sysname,
		@owner_id	int	= null 		
	)
	WITH EXECUTE AS N'dbo'
	AS
	BEGIN
		set nocount on

		declare @theId 		int
		declare @IsDbo 		int
		declare @DiagId		int
		declare @UIDFound	int
	
		if(@diagramname is null)
		begin
			RAISERROR (N'E_INVALIDARG', 16, 1);
			return -1
		end
	
		execute as caller;
		select @theId = DATABASE_PRINCIPAL_ID();
		select @IsDbo = IS_MEMBER(N'db_owner');
		if(@owner_id is null)
			select @owner_id = @theId;
		revert; 
	
		select @DiagId = diagram_id, @UIDFound = principal_id from dbo.sysdiagrams where principal_id = @owner_id and name = @diagramname;
		if(@DiagId IS NULL or (@IsDbo = 0 and @UIDFound <> @theId ))
		begin
			RAISERROR ('Diagram does not exist or you do not have permission.', 16, 1);
			return -3
		end

		select version, definition FROM dbo.sysdiagrams where diagram_id = @DiagId ; 
		return 0
	END
	
GO
/****** Object:  StoredProcedure [dbo].[sp_helpdiagrams]    Script Date: 6/25/2019 3:32:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

	CREATE PROCEDURE [dbo].[sp_helpdiagrams]
	(
		@diagramname sysname = NULL,
		@owner_id int = NULL
	)
	WITH EXECUTE AS N'dbo'
	AS
	BEGIN
		DECLARE @user sysname
		DECLARE @dboLogin bit
		EXECUTE AS CALLER;
			SET @user = USER_NAME();
			SET @dboLogin = CONVERT(bit,IS_MEMBER('db_owner'));
		REVERT;
		SELECT
			[Database] = DB_NAME(),
			[Name] = name,
			[ID] = diagram_id,
			[Owner] = USER_NAME(principal_id),
			[OwnerID] = principal_id
		FROM
			sysdiagrams
		WHERE
			(@dboLogin = 1 OR USER_NAME(principal_id) = @user) AND
			(@diagramname IS NULL OR name = @diagramname) AND
			(@owner_id IS NULL OR principal_id = @owner_id)
		ORDER BY
			4, 5, 1
	END
	
GO
/****** Object:  StoredProcedure [dbo].[sp_renamediagram]    Script Date: 6/25/2019 3:32:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

	CREATE PROCEDURE [dbo].[sp_renamediagram]
	(
		@diagramname 		sysname,
		@owner_id		int	= null,
		@new_diagramname	sysname
	
	)
	WITH EXECUTE AS 'dbo'
	AS
	BEGIN
		set nocount on
		declare @theId 			int
		declare @IsDbo 			int
		
		declare @UIDFound 		int
		declare @DiagId			int
		declare @DiagIdTarg		int
		declare @u_name			sysname
		if((@diagramname is null) or (@new_diagramname is null))
		begin
			RAISERROR ('Invalid value', 16, 1);
			return -1
		end
	
		EXECUTE AS CALLER;
		select @theId = DATABASE_PRINCIPAL_ID();
		select @IsDbo = IS_MEMBER(N'db_owner'); 
		if(@owner_id is null)
			select @owner_id = @theId;
		REVERT;
	
		select @u_name = USER_NAME(@owner_id)
	
		select @DiagId = diagram_id, @UIDFound = principal_id from dbo.sysdiagrams where principal_id = @owner_id and name = @diagramname 
		if(@DiagId IS NULL or (@IsDbo = 0 and @UIDFound <> @theId))
		begin
			RAISERROR ('Diagram does not exist or you do not have permission.', 16, 1)
			return -3
		end
	
		-- if((@u_name is not null) and (@new_diagramname = @diagramname))	-- nothing will change
		--	return 0;
	
		if(@u_name is null)
			select @DiagIdTarg = diagram_id from dbo.sysdiagrams where principal_id = @theId and name = @new_diagramname
		else
			select @DiagIdTarg = diagram_id from dbo.sysdiagrams where principal_id = @owner_id and name = @new_diagramname
	
		if((@DiagIdTarg is not null) and  @DiagId <> @DiagIdTarg)
		begin
			RAISERROR ('The name is already used.', 16, 1);
			return -2
		end		
	
		if(@u_name is null)
			update dbo.sysdiagrams set [name] = @new_diagramname, principal_id = @theId where diagram_id = @DiagId
		else
			update dbo.sysdiagrams set [name] = @new_diagramname where diagram_id = @DiagId
		return 0
	END
	
GO
/****** Object:  StoredProcedure [dbo].[sp_upgraddiagrams]    Script Date: 6/25/2019 3:32:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

	CREATE PROCEDURE [dbo].[sp_upgraddiagrams]
	AS
	BEGIN
		IF OBJECT_ID(N'dbo.sysdiagrams') IS NOT NULL
			return 0;
	
		CREATE TABLE dbo.sysdiagrams
		(
			name sysname NOT NULL,
			principal_id int NOT NULL,	-- we may change it to varbinary(85)
			diagram_id int PRIMARY KEY IDENTITY,
			version int,
	
			definition varbinary(max)
			CONSTRAINT UK_principal_name UNIQUE
			(
				principal_id,
				name
			)
		);


		/* Add this if we need to have some form of extended properties for diagrams */
		/*
		IF OBJECT_ID(N'dbo.sysdiagram_properties') IS NULL
		BEGIN
			CREATE TABLE dbo.sysdiagram_properties
			(
				diagram_id int,
				name sysname,
				value varbinary(max) NOT NULL
			)
		END
		*/

		IF OBJECT_ID(N'dbo.dtproperties') IS NOT NULL
		begin
			insert into dbo.sysdiagrams
			(
				[name],
				[principal_id],
				[version],
				[definition]
			)
			select	 
				convert(sysname, dgnm.[uvalue]),
				DATABASE_PRINCIPAL_ID(N'dbo'),			-- will change to the sid of sa
				0,							-- zero for old format, dgdef.[version],
				dgdef.[lvalue]
			from dbo.[dtproperties] dgnm
				inner join dbo.[dtproperties] dggd on dggd.[property] = 'DtgSchemaGUID' and dggd.[objectid] = dgnm.[objectid]	
				inner join dbo.[dtproperties] dgdef on dgdef.[property] = 'DtgSchemaDATA' and dgdef.[objectid] = dgnm.[objectid]
				
			where dgnm.[property] = 'DtgSchemaNAME' and dggd.[uvalue] like N'_EA3E6268-D998-11CE-9454-00AA00A3F36E_' 
			return 2;
		end
		return 1;
	END
	
GO
/****** Object:  StoredProcedure [fin].[LoadDateDimension]    Script Date: 6/25/2019 3:32:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [fin].[LoadDateDimension] @input INT
AS
-- Script to populate dim.FinDate data. 
-- Truncate and re-populate 

TRUNCATE TABLE dim.finDate

DECLARE @StartDate DATE = (SELECT MIN(OFPR.F_RefDate) AS Min_Date FROM stg2.[fin_OFPR] OFPR) 
DECLARE @NumberOfYears INT =(SELECT DATEDIFF(YEAR, 2013, MAX(OFPR.F_RefDate)) FROM stg2.[fin_OFPR] OFPR)  --2013 is when the first transactions start in JDT1
PRINT @StartDate
PRINT @NumberOfYears


SET DATEFIRST 7;
SET DATEFORMAT mdy;
SET LANGUAGE US_ENGLISH;

DECLARE @CutoffDate DATE = DATEADD(YEAR, @NumberOfYears, @StartDate);
PRINT @CutoffDate


INSERT INTO dim.FinDate([Date], [Quarter], AbsEntry, [Period Code], [Period Name], F_RefDate, T_RefDate) 
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
LEFT JOIN stg2.[fin_OFPR] OFPR on d.[date]>=OFPR.F_RefDate AND d.[date]<=OFPR.T_RefDate

-- NB: 
--SELECT * from dim.FinDate d where [Date] = '2019-01-31' 
GO
/****** Object:  StoredProcedure [fin].[LoadDimensions]    Script Date: 6/25/2019 3:32:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [fin].[LoadDimensions] @input INT
AS

-- Script to load all the finance data model's dimensions and fact tables from staging(landing)
-- The SQL statements are ogranised in the required load order 
-- All dimensions have unique constraints enforced on business keys to make sure there is no duplication of data.

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- dim.FinLicenseFeeCountry
-- Truncate and Insert
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Truncate Table dim.FinLicenseFeeCountry

-- Insert a default record with ID=0, Country="N/A" and setting all other columns to default values
set identity_insert dim.FinLicenseFeeCountry ON
insert into dim.FinLicenseFeeCountry (Id,[Country], [Country Ranking])
values(0,'N/A',0)
set identity_insert dim.FinLicenseFeeCountry OFF

insert into dim.FinLicenseFeeCountry ([Country], [Country Ranking])
select distinct [Country], CAST(Licence_Fee_Country_Ranking as int) from [stg2].[fin_IncomeMapping] order by CAST(Licence_Fee_Country_Ranking as int) 


---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- dim.FinIncomeSector
-- Truncate and Insert
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Truncate Table dim.FinIncomeSector

-- Insert a default record with ID=0 for "Unknown" or "Not-Known" and setting all other columns to default values
set identity_insert dim.FinIncomeSector ON
insert into dim.FinIncomeSector (ID,[Income Sector], [Income SubSector], [Income Sector Ranking], [Income SubSector Ranking])
VALUES
(0,'N/A','N/A',-1,-1)

set identity_insert dim.FinIncomeSector OFF

insert into dim.FinIncomeSector ([Income Sector], [Income SubSector], [Income Sector Ranking], [Income SubSector Ranking])
select distinct [Income_Sector], [Sub_sector], [Income Sector Ranking], [Income SubSector_Ranking] from
(select [Income_Sector], [Sub_sector], 
MIN(CAST(Sector_Ranking as int)) OVER(PARTITION BY [Income_Sector]) as [Income Sector Ranking], 
MIN(CAST(Sub_sector_Ranking as int)) OVER(PARTITION BY [Sub_Sector]) as [Income SubSector_Ranking]
from [stg].vwIncomeSector group by [Income_Sector], [Sub_sector], Sector_Ranking, Sub_sector_Ranking) x 
order by [Income Sector Ranking], [Income SubSector_Ranking]


---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- dim.FinIncomeType
-- Truncate and Insert
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Truncate Table dim.FinIncomeType

-- Insert a default record with ID=0, [Income Type]="Unknown" or "Not Known" and setting all other columns to default values
set identity_insert dim.FinIncomeType ON
insert into dim.FinIncomeType (Id,[Income Type], [Income Type Ranking])
VaLUES(0,'N/A',0)

set identity_insert dim.FinIncomeType OFF

insert into dim.FinIncomeType ([Income Type], [Income Type Ranking])
select distinct [Income_Type], CAST(Income_Type_Ranking as int) from [stg2].[fin_IncomeMapping] order by CAST(Income_Type_Ranking as int)

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- dim.FinAccount
-- Truncate and Insert
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Truncate Table dim.FinAccount

-- Insert a default record with ID=0, AcctCode="Unknown" or "Not Known", AccountName="Unknown" and setting all other columns to default values
set identity_insert dim.FinAccount ON

INSERT INTO [dim].[FinAccount]
           (ID,[Account Code],[Account Name],[Expense High Level Account],[TB_Mapping],[Expense Ranking],[TB Ranking],[DW_CreatedDate],[DW_ModifiedDate])
			VALues(0,'N/A','N/A','N/A','N/A',0,0,GetDate(),GetDate())

set identity_insert dim.FinAccount OFF

INSERT INTO [dim].[FinAccount]
           ([Account Code],[Account Name],[Expense High Level Account],[TB_Mapping],[Expense Ranking],[TB Ranking],[DW_CreatedDate],[DW_ModifiedDate])
SELECT oact.AcctCode as [Account Code]
	   ,oact.AcctName as [Account Name]
	   ,exmap.[High_Level_Account] as [Expense High Level Account]
	   ,tbmap.[TB_Mapping]
	   ,CAST(exmap.Ranking as int) as [Expense Ranking] 
	   ,CAST(tbmap.[TB_Mapping_Rank] as int) as [TB Ranking] 
	   ,GETDATE() as DW_CreatedDate
	   ,GETDATE() as DW_ModifiedDate
FROM [stg2].[fin_OACT] oact
left join [stg2].[fin_ExpensesMapping] exmap on exmap.[Account] = oact.AcctCode
left join [stg2].[fin_TBMapping] tbmap on tbmap.[Account_Code] = oact.AcctCode


---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- dim.FinLicenceType
-- Truncate and Insert
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Truncate Table dim.FinLicenceType

set identity_insert dim.FinLicenceType ON
-- Insert a default record with ID=0, [Licence Type Code]="Unknown",[Licence Type]="Unknown" and setting all other columns to default values
INSERT INTO [dim].[FinLicenceType]
           (ID,[Licence Type Code],[Licence Type],[DW_CreatedDate],[DW_ModifiedDate])
VALUES		(0, 'N/A', 'N/A',GetDate(),GetDate())


set identity_insert dim.FinLicenceType OFF

INSERT INTO [dim].[FinLicenceType]
           ([Licence Type Code],[Licence Type],[DW_CreatedDate],[DW_ModifiedDate])

SELECT OCRCode as [Licence Type Code]
	   ,OCRName as [Licence Type]
	   ,GETDATE() as DW_CreatedDate
	   ,GETDATE() as DW_ModifiedDate
FROM [stg2].[fin_OOCR]
WHERE LEFT(OCRCode, 1) = 'L'


---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- dim.FinFeeCategory
-- Truncate and Insert
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Truncate Table dim.FinFeeCategory
set identity_insert dim.FinFeeCategory ON
-- Insert a default record with ID=0, [Fee Category Code]="Unknown",[Fee Category]="Unknown" and setting all other columns to default values

INSERT INTO [dim].[FinFeeCategory]
           (ID,[Fee Category Code],[Fee Category],[DW_CreatedDate],[DW_ModifiedDate])
     VALUES (0,'N/A','N/A',GetDate(),GetDate())


set identity_insert dim.FinFeeCategory OFF
INSERT INTO [dim].[FinFeeCategory]
           ([Fee Category Code],[Fee Category],[DW_CreatedDate],[DW_ModifiedDate])
SELECT OCRCode as [Fee Category Code]
	   ,OCRName as [Fee Category]
	   ,GETDATE() as DW_CreatedDate
	   ,GETDATE() as DW_ModifiedDate
FROM [stg2].[fin_OOCR]
WHERE LEFT(OCRCode, 1) = 'X'




---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- dim.FinTitleType
-- Truncate and Insert
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Truncate Table dim.FinTitleType

set identity_insert dim.FinTitleType ON
-- Insert a default record with ID=0, [Title Type Code]="Unknown",[Title Type]="Unknown" and setting all other columns to default values

INSERT INTO [dim].[FinTitleType]
           (ID,[Title Type Code],[Title Type],[DW_CreatedDate],[DW_ModifiedDate])
     VALUES (0,'N/A','N/A',GetDate(),GetDate())

set identity_insert dim.FinTitleType OFF
INSERT INTO [dim].[FinTitleType]
           ([Title Type Code],[Title Type],[DW_CreatedDate],[DW_ModifiedDate])
SELECT OCRCode as [Title Type Code]
	   ,OCRName as [Title Type]
	   ,GETDATE() as DW_CreatedDate
	   ,GETDATE() as DW_ModifiedDate
FROM [stg2].[fin_OOCR]
WHERE LEFT(OCRCode, 1) = 'S'


---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- dim.FinDepartment
-- Truncate and Insert
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Truncate Table dim.FinDepartment
set identity_insert dim.FinDepartment ON
-- Insert a default record with ID=0, [Department Code]="Unknown",[Department Type]="Unknown" and setting all other columns to default values

INSERT INTO [dim].[FinDepartment]
	(ID,[Department Code],[Department Type],[DW_CreatedDate],[DW_ModifiedDate])
     VALUES (0,'N/A','N/A',GetDate(),GetDate())
set identity_insert dim.FinDepartment OFF

INSERT INTO [dim].[FinDepartment]
	([Department Code],[Department Type],[DW_CreatedDate],[DW_ModifiedDate])
SELECT OCRCode as [Department Code]
	   ,OCRName as [Department Type]
	   ,GETDATE() as DW_CreatedDate
	   ,GETDATE() as DW_ModifiedDate
FROM [stg2].[fin_OOCR]
WHERE LEFT(OCRCode, 1) = 'D'


---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- dim.FinExpenseCostType
-- Truncate and Insert
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Truncate Table dim.FinExpenseCostType
set identity_insert dim.FinExpenseCostType ON
-- Insert a default record with ID=0, [Cost_Type] ="Unknown" and setting all other columns to default values
INSERT INTO DIM.FinExpenseCostType (Id,[Expense Cost Type],DW_CreatedDate,DW_ModifiedDate)
VALUES(0,'N/A',GetDate(),Getdate())
set identity_insert dim.FinExpenseCostType OFF

INSERT INTO DIM.FinExpenseCostType ([Expense Cost Type],DW_CreatedDate,DW_ModifiedDate)
SELECT distinct 
	   [Cost_Type] as [Expense Cost Type]
	   ,GETDATE() as DW_CreatedDate
	   ,GETDATE() as DW_ModifiedDate
FROM [stg2].[fin_ExpensesBudget]


---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- dim.[FinDistributionSector]
-- Truncate and Insert
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Truncate Table dim.FinDistributionSector
set identity_insert dim.FinDistributionSector ON
INSERT INTO [dim].[FinDistributionSector]
           (ID,[Distribution Sector],[Distribution SubSector],[Distributions Mapping],[Distribution Sector Ranking],[Distribution SubSector Ranking],[Distributions_Mapping_Ranking],[DW_CreatedDate],[DW_ModifiedDate])
     VALUES
           (0,'N/A','N/A','N/A',0,0,0,Getdate(),GetDate())


set identity_insert dim.FinDistributionSector OFF

-- Insert a default record with ID=0, [Distribution Sector] ="Unknown",[Distribution SubSector]="Unknown",[Distributions Mapping]="Unknown" and setting all other columns to default values
insert into dim.FinDistributionSector ([Distribution Sector] , [Distribution SubSector], [Distributions Mapping], 
                                          [Distribution Sector Ranking], [Distribution SubSector Ranking], [Distributions_Mapping_Ranking])
select distinct [Income_Sector], [Sub_sector], [Distributions_Mapping], 
CAST(Sector_Ranking as int), CAST(Sub_sector_Ranking as int), CAST([Distributions_Mapping_Ranking] as int)
from [stg].[vwFinDistributionMapping] order by CAST(Sector_Ranking as int), CAST(Sub_sector_Ranking as int), CAST([Distributions_Mapping_Ranking] as int)





---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- dim.FinUndistributedFunds
-- Truncate and Insert
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Truncate Table dim.FinUndistributedFunds
set identity_insert dim.FinUndistributedFunds ON

insert into dim.FinUndistributedFunds (ID,[Undistributed Account Code], [Undistributed Fee Categorisation], [Undistributed Fee Country], [Undistributed SubSector], 
                                      [Fee Categorisation Ranking], [Fee Country Ranking], [SubSector Ranking])
Values (0,'N/A','N/A','N/A','N/A',0,0,0)
set identity_insert dim.FinUndistributedFunds OFF

insert into dim.FinUndistributedFunds ([Undistributed Account Code], [Undistributed Fee Categorisation], [Undistributed Fee Country], [Undistributed SubSector], 
                                      [Fee Categorisation Ranking], [Fee Country Ranking], [SubSector Ranking])
select distinct [Account_Code], [Fee_Categorisation], [Fee_Country], [Sub_sector], 
 CAST([Income_Sector_Ranking] as int), CAST([Licence_Fee_Country_Ranking] as int), CAST(Sub_sector_Ranking as int)
from [stg2].[fin_UndistributedFundsMappings] 
order by CAST([Income_Sector_Ranking] as int), CAST([Licence_Fee_Country_Ranking] as int), CAST(Sub_sector_Ranking as int)

-- NB: [Income_Sector_Ranking] to be renamed to [Fee_Categorisation_Ranking] in STG table



GO
/****** Object:  StoredProcedure [fin].[LoadFixedAssets]    Script Date: 6/25/2019 3:32:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [fin].[LoadFixedAssets] @input INT
As
------------------------------------------------------------
--fct.FinFixedAssets
-- Truncate and Insert
-- No validations
-------------------------------------

Truncate Table fact.FinFixedAsset

INSERT INTO fact.FinFixedAsset
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


GO
/****** Object:  StoredProcedure [fin].[LoadLandingToDWHDateDimension]    Script Date: 6/25/2019 3:32:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--EXEC fin.LoadLandingToDWHDateDimension 2

/****** Object:  StoredProcedure [fin].[LoadDateDimension]    Script Date: 6/20/2019 9:32:59 AM ******/

CREATE procedure [fin].[LoadLandingToDWHDateDimension] @input INT
AS
-- Script to truncate & re-populate dim.FinDate data. 

PRINT 'Procedure LoadLandingToDWHDateDimension start: ' + CONVERT(nvarchar,GETDATE(), 127)

TRUNCATE TABLE dim.finDate

DECLARE @StartDate DATE = (SELECT MIN(OFPR.F_RefDate) AS Min_Date FROM land.[fin_OFPR] OFPR WHERE Valid=1) 
DECLARE @NumberOfYears INT = (SELECT DATEDIFF(YEAR, 2013, MAX(OFPR.F_RefDate)) FROM land.[fin_OFPR] OFPR WHERE Valid=1)  --2013 is when the first transactions start in JDT1
--PRINT @StartDate

SET DATEFIRST 7;
SET DATEFORMAT mdy;
SET LANGUAGE US_ENGLISH;

DECLARE @CutoffDate DATE = DATEADD(YEAR, @NumberOfYears, @StartDate);

INSERT INTO dim.FinDate([Date], [Quarter], AbsEntry, [Period Code], [Period Name], F_RefDate, T_RefDate) 
SELECT d.[Date],  'Q' + LTRIM(STR(OFPR.Code_Quarter)) + ' ' + LEFT(OFPR.[Code], 4),
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
LEFT JOIN land.[fin_OFPR] OFPR ON d.[date]>=OFPR.F_RefDate AND d.[date]<=OFPR.T_RefDate
WHERE OFPR.Valid=1
PRINT 'Procedure LoadLandingToDWHDateDimension end:   ' + CONVERT(nvarchar,GETDATE(), 127)

GO
/****** Object:  StoredProcedure [fin].[LoadLandingToDWHDimensions]    Script Date: 6/25/2019 3:32:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--[fin].[LoadLandingToDWHDimensions]
--

CREATE Procedure [fin].[LoadLandingToDWHDimensions] @input INT
AS

-- Script to load all the finance data model's dimensions and fact tables FROM staging(landing)
-- The SQL statements are ogranised in the required load order 
-- All dimensions have unique constraints enforced on business keys to make sure there is no duplication of data.

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- dim.FinLicenseFeeCountry
-- Truncate and Insert
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
PRINT 'Procedure LoadLandingToDWHDimensions start: ' + CONVERT(nvarchar,GETDATE(), 127)

TRUNCATE TABLE dim.FinLicenseFeeCountry
-- Insert a default record with ID=0, Country="N/A" and setting all other columns to default VALUES
SET IDENTITY_INSERT dim.FinLicenseFeeCountry ON
INSERT INTO dim.FinLicenseFeeCountry (Id,[Country], [Country Ranking]) VALUES(0,'N/A',0)
SET IDENTITY_INSERT dim.FinLicenseFeeCountry OFF

INSERT INTO dim.FinLicenseFeeCountry ([Country], [Country Ranking])
	SELECT DISTINCT UK_International, CAST(Licence_Fee_Country_Ranking AS INT)
	FROM land.fin_IncomeMapping WHERE Valid=1
	ORDER BY CAST(Licence_Fee_Country_Ranking AS INT) 


---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- dim.FinIncomeSector
-- Truncate and Insert
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
TRUNCATE TABLE dim.FinIncomeSector
-- Insert a default record with ID=0 for "Unknown" or "Not-Known" and setting all other columns to default VALUES
SET IDENTITY_INSERT dim.FinIncomeSector ON
INSERT INTO dim.FinIncomeSector (ID,[Income Sector], [Income SubSector], [Income Sector Ranking], [Income SubSector Ranking]) VALUES (0,'N/A','N/A',-1,-1)
SET IDENTITY_INSERT dim.FinIncomeSector OFF

INSERT INTO dim.FinIncomeSector ([Income Sector], [Income SubSector], [Income Sector Ranking], [Income SubSector Ranking])
	SELECT DISTINCT [Income_Sector], [Sub_sector], [Income Sector Ranking], [Income SubSector_Ranking] FROM
	(SELECT [Income_Sector], [Sub_sector], 
	MIN(CAST(Sector_Ranking AS INT)) OVER(PARTITION BY [Income_Sector]) AS [Income Sector Ranking], 
	MIN(CAST(Sub_sector_Ranking AS INT)) OVER(PARTITION BY [Sub_Sector]) AS [Income SubSector_Ranking]
	FROM [stg].vwIncomeSector GROUP BY [Income_Sector], [Sub_sector], Sector_Ranking, Sub_sector_Ranking) x 
	ORDER BY [Income Sector Ranking], [Income SubSector_Ranking]


---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- dim.FinIncomeType
-- Truncate and Insert
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
TRUNCATE TABLE dim.FinIncomeType
-- Insert a default record with ID=0, [Income Type]="Unknown" or "Not Known" and setting all other columns to default VALUES
SET IDENTITY_INSERT dim.FinIncomeType ON
INSERT INTO dim.FinIncomeType (Id,[Income Type], [Income Type Ranking]) VALUES(0,'N/A',0)
SET IDENTITY_INSERT dim.FinIncomeType OFF

INSERT INTO dim.FinIncomeType ([Income Type], [Income Type Ranking])
	SELECT DISTINCT [Income_Type], CAST(Income_Type_Ranking AS INT) FROM land.[fin_IncomeMapping] WHERE Valid=1 ORDER BY CAST(Income_Type_Ranking AS INT)


---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- dim.FinAccount
-- Truncate and Insert
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
TRUNCATE TABLE dim.FinAccount
-- Insert a default record with ID=0, AcctCode="Unknown" or "Not Known", AccountName="Unknown" and setting all other columns to default VALUES
SET IDENTITY_INSERT dim.FinAccount ON
INSERT INTO [dim].[FinAccount]
           (ID,[Account Code],[Account Name],[Expense High Level Account],[TB_Mapping],[Expense Ranking],[TB Ranking],[DW_CreatedDate],[DW_ModifiedDate])
			VALUES(0,'N/A','N/A','N/A','N/A',0,0,GetDate(),GetDate())
SET IDENTITY_INSERT dim.FinAccount OFF

INSERT INTO [dim].[FinAccount]
           ([Account Code],[Account Name],[Expense High Level Account],[TB_Mapping],[Expense Ranking],[TB Ranking],[DW_CreatedDate],[DW_ModifiedDate])
SELECT oact.AcctCode AS [Account Code]
	   ,oact.AcctName AS [Account Name]
	   ,exmap.[High_Level_Account] AS [Expense High Level Account]
	   ,tbmap.[TB_Mapping]
	   ,CAST(exmap.Ranking AS INT) AS [Expense Ranking] 
	   ,CAST(tbmap.[TB_Mapping_Rank] AS INT) AS [TB Ranking] 
	   ,GETDATE() AS DW_CreatedDate
	   ,GETDATE() AS DW_ModifiedDate
FROM land.[fin_OACT] oact
left join land.[fin_ExpensesMapping] exmap on exmap.[Account]=oact.AcctCode and exmap.Valid=1 
left join land.[fin_TBMapping] tbmap on tbmap.[Account_Code]=oact.AcctCode and tbmap.Valid=1
WHERE oact.Valid=1 

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- dim.FinLicenceType
-- Truncate and Insert
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
TRUNCATE TABLE dim.FinLicenceType
SET IDENTITY_INSERT dim.FinLicenceType ON
-- Insert a default record with ID=0, [Licence Type Code]="Unknown",[Licence Type]="Unknown" and setting all other columns to default VALUES
INSERT INTO [dim].[FinLicenceType]
           (ID,[Licence Type Code],[Licence Type],[DW_CreatedDate],[DW_ModifiedDate]) VALUES (0, 'N/A', 'N/A',GetDate(),GetDate())
SET IDENTITY_INSERT dim.FinLicenceType OFF

INSERT INTO [dim].[FinLicenceType] ([Licence Type Code],[Licence Type],[DW_CreatedDate],[DW_ModifiedDate])
	SELECT OCRCode AS [Licence Type Code]
		   ,OCRName AS [Licence Type]
		   ,GETDATE() AS DW_CreatedDate
		   ,GETDATE() AS DW_ModifiedDate
	FROM land.[fin_OOCR]
	WHERE Valid=1 AND LEFT(OCRCode, 1)='L'


---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- dim.FinFeeCategory
-- Truncate and Insert
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
TRUNCATE TABLE dim.FinFeeCategory
SET IDENTITY_INSERT dim.FinFeeCategory ON
-- Insert a default record with ID=0, [Fee Category Code]="Unknown",[Fee Category]="Unknown" and setting all other columns to default VALUES
INSERT INTO [dim].[FinFeeCategory]
           (ID,[Fee Category Code],[Fee Category],[DW_CreatedDate],[DW_ModifiedDate]) VALUES (0,'N/A','N/A',GetDate(),GetDate())
SET IDENTITY_INSERT dim.FinFeeCategory OFF

INSERT INTO [dim].[FinFeeCategory] ([Fee Category Code],[Fee Category],[DW_CreatedDate],[DW_ModifiedDate])
	SELECT OCRCode AS [Fee Category Code]
		   ,OCRName AS [Fee Category]
		   ,GETDATE() AS DW_CreatedDate
		   ,GETDATE() AS DW_ModifiedDate
	FROM land.[fin_OOCR]
	WHERE Valid=1 AND LEFT(OCRCode, 1)='X'


---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- dim.FinTitleType
-- Truncate and Insert
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
TRUNCATE TABLE dim.FinTitleType
SET IDENTITY_INSERT dim.FinTitleType ON
-- Insert a default record with ID=0, [Title Type Code]="Unknown",[Title Type]="Unknown" and setting all other columns to default VALUES
INSERT INTO [dim].[FinTitleType]
           (ID,[Title Type Code],[Title Type],[DW_CreatedDate],[DW_ModifiedDate]) VALUES (0,'N/A','N/A',GetDate(),GetDate())
SET IDENTITY_INSERT dim.FinTitleType OFF

INSERT INTO [dim].[FinTitleType] ([Title Type Code],[Title Type],[DW_CreatedDate],[DW_ModifiedDate])
	SELECT OCRCode AS [Title Type Code]
		   ,OCRName AS [Title Type]
		   ,GETDATE() AS DW_CreatedDate
		   ,GETDATE() AS DW_ModifiedDate
	FROM land.[fin_OOCR]
	WHERE Valid=1 AND LEFT(OCRCode, 1)='S'


---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- dim.FinDepartment
-- Truncate and Insert
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
TRUNCATE TABLE dim.FinDepartment
SET IDENTITY_INSERT dim.FinDepartment ON
-- Insert a default record with ID=0, [Department Code]="Unknown",[Department Type]="Unknown" and setting all other columns to default VALUES
INSERT INTO [dim].[FinDepartment]
	(ID,[Department Code],[Department Type],[DW_CreatedDate],[DW_ModifiedDate])
     VALUES (0,'N/A','N/A',GetDate(),GetDate())
SET IDENTITY_INSERT dim.FinDepartment OFF

INSERT INTO [dim].[FinDepartment] ([Department Code],[Department Type],[DW_CreatedDate],[DW_ModifiedDate])
	SELECT OCRCode AS [Department Code]
		   ,OCRName AS [Department Type]
		   ,GETDATE() AS DW_CreatedDate
		   ,GETDATE() AS DW_ModifiedDate
	FROM land.[fin_OOCR]
	WHERE Valid=1 AND LEFT(OCRCode, 1)='D'


---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- dim.FinExpenseCostType
-- Truncate and Insert
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
TRUNCATE TABLE dim.FinExpenseCostType
SET IDENTITY_INSERT dim.FinExpenseCostType ON
-- Insert a default record with ID=0, [Cost_Type] ="Unknown" and setting all other columns to default VALUES
INSERT INTO DIM.FinExpenseCostType (Id,[Expense Cost Type],DW_CreatedDate,DW_ModifiedDate)
VALUES(0,'N/A',GetDate(),Getdate())
SET IDENTITY_INSERT dim.FinExpenseCostType OFF

INSERT INTO DIM.FinExpenseCostType ([Expense Cost Type],DW_CreatedDate,DW_ModifiedDate)
	SELECT DISTINCT 
		   [Cost_Type] AS [Expense Cost Type]
		   ,GETDATE() AS DW_CreatedDate
		   ,GETDATE() AS DW_ModifiedDate
	FROM land.[fin_ExpensesBudget]
	WHERE Valid=1


---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- dim.[FinDistributionSector]
-- Truncate and Insert
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
TRUNCATE TABLE dim.FinDistributionSector
SET IDENTITY_INSERT dim.FinDistributionSector ON
INSERT INTO [dim].[FinDistributionSector]
           (ID,[Distribution Sector],[Distribution SubSector],[Distributions Mapping],[Distribution Sector Ranking],[Distribution SubSector Ranking],[Distributions_Mapping_Ranking],[DW_CreatedDate],[DW_ModifiedDate])
     VALUES (0,'N/A','N/A','N/A',0,0,0,Getdate(),GetDate())
SET IDENTITY_INSERT dim.FinDistributionSector OFF

-- Insert a default record with ID=0, [Distribution Sector] ="Unknown",[Distribution SubSector]="Unknown",[Distributions Mapping]="Unknown" and setting all other columns to default VALUES
INSERT INTO dim.FinDistributionSector ([Distribution Sector] , [Distribution SubSector], [Distributions Mapping], 
                                          [Distribution Sector Ranking], [Distribution SubSector Ranking], [Distributions_Mapping_Ranking])
SELECT DISTINCT [Income_Sector], [Sub_sector], [Distributions_Mapping], 
CAST(Sector_Ranking AS INT), CAST(Sub_sector_Ranking AS INT), CAST([Distributions_Mapping_Ranking] AS INT)
FROM [stg].[vwFinDistributionMapping] ORDER BY CAST(Sector_Ranking AS INT), CAST(Sub_sector_Ranking AS INT), CAST([Distributions_Mapping_Ranking] AS INT)


---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- dim.FinUndistributedFunds
-- Truncate and Insert
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
TRUNCATE TABLE dim.FinUndistributedFunds

SET IDENTITY_INSERT dim.FinUndistributedFunds ON

INSERT INTO dim.FinUndistributedFunds (ID,[Undistributed Account Code], [Undistributed Fee Categorisation], [Undistributed Fee Country], [Undistributed SubSector], 
                                      [Fee Categorisation Ranking], [Fee Country Ranking], [SubSector Ranking])
VALUES (0,'N/A','N/A','N/A','N/A',0,0,0)

SET IDENTITY_INSERT dim.FinUndistributedFunds OFF

INSERT INTO dim.FinUndistributedFunds ([Undistributed Account Code], [Undistributed Fee Categorisation], [Undistributed Fee Country], [Undistributed SubSector], 
                                      [Fee Categorisation Ranking], [Fee Country Ranking], [SubSector Ranking])

SELECT 
	DISTINCT [Account_Code], [Fee_Categorisation], [Fee_Country], [Sub_sector], 
	CAST([Income_Sector_Ranking] AS INT), CAST([Licence_Fee_Country_Ranking] AS INT), CAST(Sub_sector_Ranking AS INT)
FROM 
	stg2.[fin_UndistributedFundsMappings] --WHERE Valid=1
ORDER BY CAST([Income_Sector_Ranking] AS INT), CAST([Licence_Fee_Country_Ranking] AS INT), CAST(Sub_sector_Ranking AS INT)

-- NB: [Income_Sector_Ranking] to be renamed to [Fee_Categorisation_Ranking] in STG table

PRINT 'Procedure LoadLandingToDWHDimensions end:   ' + CONVERT(nvarchar,GETDATE(), 127)
GO
/****** Object:  StoredProcedure [fin].[LoadLandingToDWHFixedAssets]    Script Date: 6/25/2019 3:32:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [fin].[LoadLandingToDWHFixedAssets] @input INT
AS
------------------------------------------------------------
-- fact.FinFixedAssets
-- Truncate and Insert
-- No validations
-------------------------------------

PRINT 'Procedure LoadLandingToDWHFixedAssets start: ' + CONVERT(nvarchar,GETDATE(), 127)

TRUNCATE TABLE fact.FinFixedAsset

INSERT INTO fact.FinFixedAsset
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
SELECT [ItemCode]
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
FROM land.[fin_FixedAsset]
WHERE Valid=1

PRINT 'Procedure LoadLandingToDWHFixedAssets end:   ' + CONVERT(nvarchar,GETDATE(), 127)
GO
/****** Object:  StoredProcedure [fin].[LoadLandingToDWHTransactions]    Script Date: 6/25/2019 3:32:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [fin].[LoadLandingToDWHTransactions] @input INT
AS
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Truncate and Insert transactions from JDT1, Budget(Reforecast) and Expense Budget(Reforecast)
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

PRINT 'Procedure LoadLandingToDWHTransactions start: ' + CONVERT(nvarchar,GETDATE(), 127)

Truncate Table [fact].[FinTransaction] 
/*** Transaction Data from JDT1

TransId and Line_Id are business keys

Validations
-----------
1. Account is mandatory column, all the other columns are optional. 

2. Referetial Integrity Check for the following columns using the join conditions in the Insert script below. 

	- [Fee Category] using join condition dim.FinFeeCategory.[Fee Category Code] = jdt1.OcrCode2 
	- [Licence Type] using join  dim.FinLicenceType.[Licence Type Code] =OcrCode3
	- [Title Type]  using join dim.FinTitleType.[Title Type Code] = j.OcrCode4
	- [Department]  using join  dim.FinDepartment.[Department Code] =ProfitCode


	- stg.vwFinIncomeMapping is used to look up the Income sector, Income sub sector. 
	- The view is built on tables updated by the source to landing ETL.
	- Referetial Integrity data check to be performed using the following columns 
						stg.vwFinIncomeMapping.Account_Code = j.Account 
						and stg.vwFinIncomeMapping.[Fee_Categorisation] = OcrCode2 
						and stg.vwFinIncomeMapping.[License_Type] =j.OcrCode3 
						and imap.[Title_Type] = stg.vwFinIncomeMapping.OcrCode4

	- [Income Sector]	dim.FinIncomeSector.[Income SubSector] = vwFinIncomeMapping.[Sub_Sector] 
						and sec.[Income Sector] = vwFinIncomeMapping.[Income_Sector]  
	- [Income Type]		dim.FinIncomeType it on it.[Income Type] = imap.[Income_Type]

	- Country, using dim.FinLicenseFeeCountry.[Country] = imap.[Country]

	-- Distribution Mapping is not being implemented in this phase. 

**/

INSERT INTO [fact].[FinTransaction] 
           ([TransId], [Line_ID], [Account], [Fee Category], [Licence Type], [Title Type], [Department], [Income Sector], [Income Type], [Country]
           ,[Distribution Sector], [Undistributed Account Code], [Expense Cost Type], [AdminFeePercent], [Posting Date], [Debit], [Credit], [Contract Account], [Description], [Invoice Number]
           ,[Invoice Reference], [Document Date], [VAT Group], [VAT Amount], [BaseSum], [Income Budget], [Income Daily Budget], [Income Forecast], [Income Daily Forecast]
           ,[Expenses Budget], [Expenses Daily Budget], [Expenses Forecast], [Expenses Daily Forecast], [RecordType])
   
SELECT  j.TransId 
		,j.Line_ID
		,isnull(a.Id,0) AS Account
		,isnull(fc.Id,0) AS [Fee Category]
		,isnull(lt.Id,0) AS [Licence Type] 
		,isnull(tt.Id,0) AS [Title Type]
		,isnull(d.Id,0) AS Department
		,isnull(sec.Id,0) AS [Income Sector]
		,isnull(it.Id,0) AS [Income Type]
		,isnull(c.Id,0) AS [Country]
		,isnull(distrSec.Id,0) AS [Distribution Sector]
		,isnull(un.Id,0) AS [Undistributed Account Code]
		,cast(null AS int) AS [Expense Cost Type]
		,CASE 

			WHEN lt.[Licence Type Code] NOT IN ('L40', 'L41') AND a.[Account Code] IN ('5006', '5007', '5009', '5011', '5021', '5026', '5031', '5041' ) THEN 0.075
			WHEN lt.[Licence Type Code] IN ('L40', 'L41') AND a.[Account Code] IN ('5006', '5007', '5009', '5011', '5021', '5026', '5031', '5041' ) THEN 0.15
			WHEN lt.[Licence Type Code] NOT IN ('L40', 'L41') AND a.[Account Code] IN ( '5045', '5140', '5220' ) THEN 0.11
			WHEN lt.[Licence Type Code] IN ('L40', 'L41') AND a.[Account Code] IN ( '5045', '5140', '5220' ) THEN 0.25
			WHEN tt.[Title Type] ='S450' THEN 0
			WHEN lt.[Licence Type Code] NOT IN ('L40', 'L41') THEN 0.11
			ELSE 0.4
			END AS AdminFeePercent
		,j.RefDate AS [Posting Date]
		,(-1.0)*ISNULL(j.Debit, 0) AS Debit
		,ISNULL(j.Credit, 0) AS Credit
		,j.ContraAct AS [Contract Account]
		,j.LineMemo AS [Description]
		,j.Ref1 AS [Invoice Number]
		,j.Ref2 AS [Invoice Reference]
		,j.TaxDate AS [Document Date]
		,j.VatGroup AS [VAT Group]
		,j.TotalVat AS [VAT Amount]
		,j.BaseSum		
		,CAST(null AS money) AS [Income Budget]
		,CAST(null AS money) AS [Income Daily Budget]
		,CAST(null AS money) AS [Income Forecast]
		,CAST(null AS money) AS [Income Daily Forecast]
		,CAST(null AS money) AS [Expenses Budget]
		,CAST(null AS money) AS [Expenses Daily Budget]
		,CAST(null AS money) AS [Expenses Forecast]
		,CAST(null AS money) AS [Expenses Daily Forecast]
		,CAST('A' AS char(2)) AS RecordType
FROM land.[fin_JDT1] j 
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
WHERE Valid=1

-------------------------------------------------------------------
--stg.FinBudget 
--No validations required 
-------------------------------------------------------------------
truncate table stg.FinBudget 

/*** Income Budget and Reforecast Data from CSV


Validations
-----------
1. Account is mandatory column, all the other columns are optional. 

2. Referetial Integrity Check for the following columns using the join conditions in the Insert script below. 

	- [Fee Category] using join condition dim.FinFeeCategory.[Fee Category Code] = jdt1.OcrCode2 
	- [Licence Type] using join  dim.FinLicenceType.[Licence Type Code] =OcrCode3
	- [Title Type]  using join dim.FinTitleType.[Title Type Code] = j.OcrCode4
	- [Department]  using join  dim.FinDepartment.[Department Code] =ProfitCode


	- stg.vwFinIncomeMapping is used to look up the Income sector, Income sub sector. 
	- The view is built on tables updated by the source to landing ETL.
	- Referetial Integrity data check to be performed using the following columns 
						stg.vwFinIncomeMapping.Account_Code = j.Account 
						and stg.vwFinIncomeMapping.[Fee_Categorisation] = OcrCode2 
						and stg.vwFinIncomeMapping.[License_Type] =j.OcrCode3 
						and imap.[Title_Type] = stg.vwFinIncomeMapping.OcrCode4

	- [Income Sector]	dim.FinIncomeSector.[Income SubSector] = vwFinIncomeMapping.[Sub_Sector] 
						and sec.[Income Sector] = vwFinIncomeMapping.[Income_Sector]  
	- [Income Type]		dim.FinIncomeType it on it.[Income Type] = imap.[Income_Type]

	- Country, using dim.FinLicenseFeeCountry.[Country] = imap.[Country]


**/

insert into stg.FinBudget (Account, [Fee Category], [Licence Type], [Title Type], [Income Sector], [Income Type], [Country], [Distribution Sector],
		                   [Undistributed Account Code], [Department], [Expenses Cost Type], [Period], [Income Budget], [Income Daily Budget], 
						   [Income Forecast], [Income Daily Forecast], [Expenses Budget],  [Expenses Daily Budget], [Expenses Forecast], [Expenses Daily Forecast], [RecordType]) 


SELECT   
		isnull(a.Id,0) AS Account
		,isnull(fc.Id,0) AS [Fee Category]
		,isnull(lt.Id,0) AS [Licence Type] 
		,isnull(tt.Id,0) AS [Title Type]
		,isnull(sec.Id,0) AS [Income Sector]
		,isnull(it.Id,0) AS [Income Type]
		,isnull(c.Id,0) AS [Country]
		,isnull(distrSec.Id,0) AS [Distribution Sector]
		,isnull(un.Id,0) AS [Undistributed Account Code]
		,null AS [Department]	
		,null AS [Expenses Cost Type]
		,datefromparts(period_year,period_month,1)  AS [Period]
		--,convert(date, b.[Period], 105) AS [Period]
		,CAST(b.[Income] AS money) AS [Income Budget]
		,CAST(b.[Income] AS money)/CAST(DATEPART(DAY, EOMONTH(datefromparts(period_year,period_month,1) )) AS numeric) AS [Income Daily Budget]
		,CAST(b.[Forecast] AS money) AS [Income Forecast]
		,CAST(b.[Forecast] AS money)/CAST(DATEPART(DAY, EOMONTH(datefromparts(period_year,period_month,1) )) AS numeric) AS [Income Daily Forecast]
		, 0 [Expenses Budget], 0 [Expenses Daily Budget], 0 [Expenses Forecast], 0 [Expenses Daily Forecast], 'B' AS RecordType

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


/*** Expenses Budget and Reforecast Data from CSV


Validations
-----------
1. Account is mandatory column, all the other columns are optional. 

2. Referetial Integrity Check for the following columns using the join conditions in the Insert script below. 
	- Account using join condition dim.FinAccount.[Account Code]=stg.vwExpensesBudgetForecas.Account

**/
insert into stg.FinBudget (Account, [Fee Category], [Licence Type], [Title Type], [Income Sector], [Income Type], [Country], [Distribution Sector],
		                   [Undistributed Account Code], [Department], [Expenses Cost Type], [Period], [Income Budget], [Income Daily Budget], 
						   [Income Forecast], [Income Daily Forecast], [Expenses Budget],  [Expenses Daily Budget], [Expenses Forecast], [Expenses Daily Forecast], [RecordType]) 

select   isnull(a.Id,0) AS Account
		,null AS [Fee Category]
		,null AS [Licence Type] 
		,null AS [Title Type]
		,null AS [Income Sector]
		,null AS [Income Type]
		,null AS [Country]
		,null AS [Distribution Sector]
		,null AS [Undistributed Account Code]	
		,dep.Id AS [Department]	
		,expCost.ID AS [Expenses Cost Type]
		,expBudget.[Period]
		,0 AS [Income Budget], 0 AS [Income Daily Budget], 0 AS [Income Forecast], 0 AS [Income Daily Forecast]
		,expBudget.[Expenses Budget]
		,expBudget.[Expenses Budget]/CAST(DATEPART(DAY, EOMONTH(expBudget.[Period])) AS numeric) AS [Expenses Daily Budget]
		,expBudget.[Expenses Forecast]
		,expBudget.[Expenses Forecast]/CAST(DATEPART(DAY, EOMONTH(expBudget.[Period])) AS numeric) AS [Expenses Daily Forecast]
		,'EX' AS RecordType
from stg.vwExpensesBudgetForecast expBudget
left join dim.FinAccount a on a.[Account Code] = expBudget.Account
left join dim.FinDepartment dep on dep.[Department Code] = expBudget.[Department]
left join dim.FinExpenseCostType expCost on expCost.[Expense Cost Type] = expBudget.Cost_Type



--------------------------------------------------------------------------
-- Insert month-level income Budget only
-- NO validations required
--------------------------------------------------------------------------

insert INTO fact.FinTransaction ([Account],[Fee Category], [Licence Type], [Title Type], [Income Sector], [Income Type], [Country], [Distribution Sector], [Undistributed Account Code],
								[Posting Date], [Debit], [Credit], [Income Budget], [Income Daily Budget], [Income Forecast], [Income Daily Forecast], 
								[Expenses Budget],  [Expenses Daily Budget], [Expenses Forecast], [Expenses Daily Forecast], [RecordType])
SELECT   isnull(b.Account,0)
		,isnull(b.[Fee Category],0)
		,isnull(b.[Licence Type] ,0)
		,isnull(b.[Title Type],0)
		,isnull(b.[Income Sector],0)
		,isnull(b.[Income Type],0)
		,isnull(b.[Country]	,0)
		,isnull(b.[Distribution Sector],0)
		,isnull(b.[Undistributed Account Code]	,0)
		,b.[Period] AS [Posting Date]
		,0 AS Debit
		,0 AS Credit
		,b.[Income Budget], 0 AS [Income Daily Budget]
		,b.[Income Forecast], 0 AS [Income Daily Forecast]
		,b.[Expenses Budget], 0 AS [Expenses Daily Budget]
		,b.[Expenses Forecast], 0 AS [Expenses Daily Forecast]
		,b.RecordType
FROM stg.FinBudget b



--------------------------------------------------------------------------
-- Insert day-level income Budget 
-- No validations required because this statement is breaking the monthly budget(which is already validated) into a daily budget.

--------------------------------------------------------------------------


insert INTO fact.FinTransaction  ([Account],[Fee Category], [Licence Type], [Title Type], [Income Sector], [Income Type], [Country], [Distribution Sector], [Undistributed Account Code],
								[Posting Date], [Debit], [Credit], [Income Budget], [Income Daily Budget], [Income Forecast], [Income Daily Forecast], 
								[Expenses Budget],  [Expenses Daily Budget], [Expenses Forecast], [Expenses Daily Forecast], [RecordType])
								
SELECT   ISNULL(b.Account,0)
		,isnull(b.[Fee Category],0)
		,isnull(b.[Licence Type] ,0)
		,isnull(b.[Title Type],0)
		,isnull(b.[Income Sector],0)
		,isnull(b.[Income Type],0)
		,isnull(b.[Country],0)
		,isnull(b.[Distribution Sector],0)
		,isnull(b.[Undistributed Account Code],0)		
		,b.[Period] AS [Posting Date]
		,0 AS Debit
		,0 AS Credit
		, 0 AS [Income Budget]
		,b.[Income Budget]/CAST(DATEPART(DAY, EOMONTH(d.[Date])) AS numeric) AS [Income Daily Budget]
		,0 AS [Income Forecast]
		,b.[Income Forecast]/CAST(DATEPART(DAY, EOMONTH(d.[Date])) AS numeric) AS [Income Daily Forecast]
		,0 AS [Expenses Budget]
		,b.[Expenses Budget]/CAST(DATEPART(DAY, EOMONTH(d.[Date])) AS numeric) AS [Expenses Daily Budget]
		,0 AS [Expenses Forecast]
		,b.[Expenses Forecast]/CAST(DATEPART(DAY, EOMONTH(d.[Date])) AS numeric) AS [Expenses Daily Forecast]

		,CASE WHEN b.RecordType = 'B' THEN 'BD' ELSE 'ED' END AS RecordType

FROM stg.FinBudget b
left join dim.FinDate d on DATEPART(MONTH, convert(date, b.[Period], 105)) =  DATEPART(MONTH, d.[Date]) 
                       and DATEPART(YEAR, convert(date, b.[Period], 105)) =  DATEPART(YEAR, d.[Date])

PRINT 'Procedure LoadLandingToDWHTransactions end:   ' + CONVERT(nvarchar,GETDATE(), 127)
GO
/****** Object:  StoredProcedure [fin].[LoadTransactions]    Script Date: 6/25/2019 3:32:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [fin].[LoadTransactions] @input INT
AS
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Truncate and Insert transactions from JDT1, Budget(Reforecast) and Expense Budget(Reforecast)
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Truncate Table [fact].[FinTransaction] 
/*** Transaction Data from JDT1

TransId and Line_Id are business keys

Validations
-----------
1. Account is mandatory column, all the other columns are optional. 

2. Referetial Integrity Check for the following columns using the join conditions in the Insert script below. 

	- [Fee Category] using join condition dim.FinFeeCategory.[Fee Category Code] = jdt1.OcrCode2 
	- [Licence Type] using join  dim.FinLicenceType.[Licence Type Code] =OcrCode3
	- [Title Type]  using join dim.FinTitleType.[Title Type Code] = j.OcrCode4
	- [Department]  using join  dim.FinDepartment.[Department Code] =ProfitCode


	- stg.vwFinIncomeMapping is used to look up the Income sector, Income sub sector. 
	- The view is built on tables updated by the source to landing ETL.
	- Referetial Integrity data check to be performed using the following columns 
						stg.vwFinIncomeMapping.Account_Code = j.Account 
						and stg.vwFinIncomeMapping.[Fee_Categorisation] = OcrCode2 
						and stg.vwFinIncomeMapping.[License_Type] =j.OcrCode3 
						and imap.[Title_Type] = stg.vwFinIncomeMapping.OcrCode4

	- [Income Sector]	dim.FinIncomeSector.[Income SubSector] = vwFinIncomeMapping.[Sub_Sector] 
						and sec.[Income Sector] = vwFinIncomeMapping.[Income_Sector]  
	- [Income Type]		dim.FinIncomeType it on it.[Income Type] = imap.[Income_Type]

	- Country, using dim.FinLicenseFeeCountry.[Country] = imap.[Country]

	-- Distribution Mapping is not being implemented in this phase. 

**/

INSERT INTO [fact].[FinTransaction] 
           ([TransId], [Line_ID], [Account], [Fee Category], [Licence Type], [Title Type], [Department], [Income Sector], [Income Type], [Country]
           ,[Distribution Sector], [Undistributed Account Code], [Expense Cost Type], [AdminFeePercent], [Posting Date], [Debit], [Credit], [Contract Account], [Description], [Invoice Number]
           ,[Invoice Reference], [Document Date], [VAT Group], [VAT Amount], [BaseSum], [Income Budget], [Income Daily Budget], [Income Forecast], [Income Daily Forecast]
           ,[Expenses Budget], [Expenses Daily Budget], [Expenses Forecast], [Expenses Daily Forecast], [RecordType])
   
SELECT  j.TransId 
		,j.Line_ID
		,isnull(a.Id,0) as Account
		,isnull(fc.Id,0) as [Fee Category]
		,isnull(lt.Id,0) as [Licence Type] 
		,isnull(tt.Id,0) as [Title Type]
		,isnull(d.Id,0) as Department
		,isnull(sec.Id,0) as [Income Sector]
		,isnull(it.Id,0) as [Income Type]
		,isnull(c.Id,0) as [Country]
		,isnull(distrSec.Id,0) as [Distribution Sector]
		,isnull(un.Id,0) as [Undistributed Account Code]
		,cast(null as int) as [Expense Cost Type]
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
FROM [stg2].[fin_JDT1] j 
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


-------------------------------------------------------------------
--stg.FinBudget 
--No validations required 
-------------------------------------------------------------------
truncate table stg.FinBudget 

/*** Income Budget and Reforecast Data from CSV


Validations
-----------
1. Account is mandatory column, all the other columns are optional. 

2. Referetial Integrity Check for the following columns using the join conditions in the Insert script below. 

	- [Fee Category] using join condition dim.FinFeeCategory.[Fee Category Code] = jdt1.OcrCode2 
	- [Licence Type] using join  dim.FinLicenceType.[Licence Type Code] =OcrCode3
	- [Title Type]  using join dim.FinTitleType.[Title Type Code] = j.OcrCode4
	- [Department]  using join  dim.FinDepartment.[Department Code] =ProfitCode


	- stg.vwFinIncomeMapping is used to look up the Income sector, Income sub sector. 
	- The view is built on tables updated by the source to landing ETL.
	- Referetial Integrity data check to be performed using the following columns 
						stg.vwFinIncomeMapping.Account_Code = j.Account 
						and stg.vwFinIncomeMapping.[Fee_Categorisation] = OcrCode2 
						and stg.vwFinIncomeMapping.[License_Type] =j.OcrCode3 
						and imap.[Title_Type] = stg.vwFinIncomeMapping.OcrCode4

	- [Income Sector]	dim.FinIncomeSector.[Income SubSector] = vwFinIncomeMapping.[Sub_Sector] 
						and sec.[Income Sector] = vwFinIncomeMapping.[Income_Sector]  
	- [Income Type]		dim.FinIncomeType it on it.[Income Type] = imap.[Income_Type]

	- Country, using dim.FinLicenseFeeCountry.[Country] = imap.[Country]


**/

insert into stg.FinBudget (Account, [Fee Category], [Licence Type], [Title Type], [Income Sector], [Income Type], [Country], [Distribution Sector],
		                   [Undistributed Account Code], [Department], [Expenses Cost Type], [Period], [Income Budget], [Income Daily Budget], 
						   [Income Forecast], [Income Daily Forecast], [Expenses Budget],  [Expenses Daily Budget], [Expenses Forecast], [Expenses Daily Forecast], [RecordType]) 


SELECT   
		isnull(a.Id,0) as Account
		,isnull(fc.Id,0) as [Fee Category]
		,isnull(lt.Id,0) as [Licence Type] 
		,isnull(tt.Id,0) as [Title Type]
		,isnull(sec.Id,0) as [Income Sector]
		,isnull(it.Id,0) as [Income Type]
		,isnull(c.Id,0) as [Country]
		,isnull(distrSec.Id,0) as [Distribution Sector]
		,isnull(un.Id,0) as [Undistributed Account Code]
		,null as [Department]	
		,null as [Expenses Cost Type]
		,datefromparts(period_year,period_month,1)  as [Period]
		--,convert(date, b.[Period], 105) as [Period]
		,CAST(b.[Income] as money) as [Income Budget]
		,CAST(b.[Income] as money)/CAST(DATEPART(DAY, EOMONTH(datefromparts(period_year,period_month,1) )) as numeric) as [Income Daily Budget]
		,CAST(b.[Forecast] as money) as [Income Forecast]
		,CAST(b.[Forecast] as money)/CAST(DATEPART(DAY, EOMONTH(datefromparts(period_year,period_month,1) )) as numeric) as [Income Daily Forecast]
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


/*** Expenses Budget and Reforecast Data from CSV


Validations
-----------
1. Account is mandatory column, all the other columns are optional. 

2. Referetial Integrity Check for the following columns using the join conditions in the Insert script below. 
	- Account using join condition dim.FinAccount.[Account Code]=stg.vwExpensesBudgetForecas.Account

**/
insert into stg.FinBudget (Account, [Fee Category], [Licence Type], [Title Type], [Income Sector], [Income Type], [Country], [Distribution Sector],
		                   [Undistributed Account Code], [Department], [Expenses Cost Type], [Period], [Income Budget], [Income Daily Budget], 
						   [Income Forecast], [Income Daily Forecast], [Expenses Budget],  [Expenses Daily Budget], [Expenses Forecast], [Expenses Daily Forecast], [RecordType]) 

select   isnull(a.Id,0) as Account
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



--------------------------------------------------------------------------
-- Insert month-level income Budget only
-- NO validations required
--------------------------------------------------------------------------

insert INTO fact.FinTransaction ([Account],[Fee Category], [Licence Type], [Title Type], [Income Sector], [Income Type], [Country], [Distribution Sector], [Undistributed Account Code],
								[Posting Date], [Debit], [Credit], [Income Budget], [Income Daily Budget], [Income Forecast], [Income Daily Forecast], 
								[Expenses Budget],  [Expenses Daily Budget], [Expenses Forecast], [Expenses Daily Forecast], [RecordType])
SELECT   isnull(b.Account,0)
		,isnull(b.[Fee Category],0)
		,isnull(b.[Licence Type] ,0)
		,isnull(b.[Title Type],0)
		,isnull(b.[Income Sector],0)
		,isnull(b.[Income Type],0)
		,isnull(b.[Country]	,0)
		,isnull(b.[Distribution Sector],0)
		,isnull(b.[Undistributed Account Code]	,0)
		,b.[Period] as [Posting Date]
		,0 as Debit
		,0 as Credit
		,b.[Income Budget], 0 as [Income Daily Budget]
		,b.[Income Forecast], 0 as [Income Daily Forecast]
		,b.[Expenses Budget], 0 as [Expenses Daily Budget]
		,b.[Expenses Forecast], 0 as [Expenses Daily Forecast]
		,b.RecordType
FROM stg.FinBudget b



--------------------------------------------------------------------------
-- Insert day-level income Budget 
-- No validations required because this statement is breaking the monthly budget(which is already validated) into a daily budget.

--------------------------------------------------------------------------


insert INTO fact.FinTransaction  ([Account],[Fee Category], [Licence Type], [Title Type], [Income Sector], [Income Type], [Country], [Distribution Sector], [Undistributed Account Code],
								[Posting Date], [Debit], [Credit], [Income Budget], [Income Daily Budget], [Income Forecast], [Income Daily Forecast], 
								[Expenses Budget],  [Expenses Daily Budget], [Expenses Forecast], [Expenses Daily Forecast], [RecordType])
								
SELECT   ISNULL(b.Account,0)
		,isnull(b.[Fee Category],0)
		,isnull(b.[Licence Type] ,0)
		,isnull(b.[Title Type],0)
		,isnull(b.[Income Sector],0)
		,isnull(b.[Income Type],0)
		,isnull(b.[Country],0)
		,isnull(b.[Distribution Sector],0)
		,isnull(b.[Undistributed Account Code],0)		
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

FROM stg.FinBudget b
left join dim.FinDate d on DATEPART(MONTH, convert(date, b.[Period], 105)) =  DATEPART(MONTH, d.[Date]) 
                       and DATEPART(YEAR, convert(date, b.[Period], 105)) =  DATEPART(YEAR, d.[Date])

GO
EXEC sys.sp_addextendedproperty @name=N'microsoft_database_tools_support', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sysdiagrams'
GO
USE [master]
GO
ALTER DATABASE [datawarehouse_dev] SET  READ_WRITE 
GO
