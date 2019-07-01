
GO
/****** Object:  Schema [dim]    Script Date: 28/06/2019 09:41:19 ******/
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'dim')
EXEC sys.sp_executesql N'CREATE SCHEMA [dim]'
GO
/****** Object:  Schema [fact]    Script Date: 28/06/2019 09:41:19 ******/
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'fact')
EXEC sys.sp_executesql N'CREATE SCHEMA [fact]'
GO
/****** Object:  Schema [fin]    Script Date: 28/06/2019 09:41:19 ******/
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'fin')
EXEC sys.sp_executesql N'CREATE SCHEMA [fin]'
GO
/****** Object:  Schema [land]    Script Date: 28/06/2019 09:41:19 ******/
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'land')
EXEC sys.sp_executesql N'CREATE SCHEMA [land]'
GO
/****** Object:  Schema [stg]    Script Date: 28/06/2019 09:41:19 ******/
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'stg')
EXEC sys.sp_executesql N'CREATE SCHEMA [stg]'
GO
/****** Object:  Table [dim].[FinAccount]    Script Date: 28/06/2019 09:41:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dim].[FinAccount]') AND type in (N'U'))
BEGIN
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
END
GO
/****** Object:  Table [dim].[FinDate]    Script Date: 28/06/2019 09:41:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dim].[FinDate]') AND type in (N'U'))
BEGIN
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
END
GO
/****** Object:  Table [dim].[FinDepartment]    Script Date: 28/06/2019 09:41:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dim].[FinDepartment]') AND type in (N'U'))
BEGIN
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
END
GO
/****** Object:  Table [dim].[FinDistributionSector]    Script Date: 28/06/2019 09:41:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dim].[FinDistributionSector]') AND type in (N'U'))
BEGIN
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
END
GO
/****** Object:  Table [dim].[FinExpenseCostType]    Script Date: 28/06/2019 09:41:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dim].[FinExpenseCostType]') AND type in (N'U'))
BEGIN
CREATE TABLE [dim].[FinExpenseCostType](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Expense Cost Type] [nvarchar](50) NULL,
	[Rank] [int] NULL,
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
END
GO
/****** Object:  Table [dim].[FinFeeCategory]    Script Date: 28/06/2019 09:41:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dim].[FinFeeCategory]') AND type in (N'U'))
BEGIN
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
END
GO
/****** Object:  Table [dim].[FinIncomeSector]    Script Date: 28/06/2019 09:41:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dim].[FinIncomeSector]') AND type in (N'U'))
BEGIN
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
END
GO
/****** Object:  Table [dim].[FinIncomeType]    Script Date: 28/06/2019 09:41:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dim].[FinIncomeType]') AND type in (N'U'))
BEGIN
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
END
GO
/****** Object:  Table [dim].[FinLicenceType]    Script Date: 28/06/2019 09:41:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dim].[FinLicenceType]') AND type in (N'U'))
BEGIN
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
END
GO
/****** Object:  Table [dim].[FinLicenseFeeCountry]    Script Date: 28/06/2019 09:41:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dim].[FinLicenseFeeCountry]') AND type in (N'U'))
BEGIN
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
END
GO
/****** Object:  Table [dim].[FinTitleType]    Script Date: 28/06/2019 09:41:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dim].[FinTitleType]') AND type in (N'U'))
BEGIN
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
END
GO
/****** Object:  Table [dim].[FinUndistributedFunds]    Script Date: 28/06/2019 09:41:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dim].[FinUndistributedFunds]') AND type in (N'U'))
BEGIN
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
END
GO
/****** Object:  Table [fact].[FinFixedAsset]    Script Date: 28/06/2019 09:41:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[fact].[FinFixedAsset]') AND type in (N'U'))
BEGIN
CREATE TABLE [fact].[FinFixedAsset](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ItemCode] [nvarchar](20) NULL,
	[ItemName] [nvarchar](100) NULL,
	[ItmsGrpCode] [int] NULL,
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
	[DW_CreatedDate] [datetime] NOT NULL,
	[DW_ModifiedDate] [datetime] NOT NULL,
 CONSTRAINT [fctFinFixedAssets_pk] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
/****** Object:  Table [fact].[FinTransaction]    Script Date: 28/06/2019 09:41:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[fact].[FinTransaction]') AND type in (N'U'))
BEGIN
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
END
GO
/****** Object:  Table [fct].[finTransaction]    Script Date: 28/06/2019 09:41:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[fct].[finTransaction]') AND type in (N'U'))
BEGIN
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
END
GO
/****** Object:  Table [fin].[ExpensesBudget]    Script Date: 28/06/2019 09:41:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[fin].[ExpensesBudget]') AND type in (N'U'))
BEGIN
CREATE TABLE [fin].[ExpensesBudget](
	[Period] [nvarchar](7) NOT NULL,
	[Account] [decimal](4, 0) NOT NULL,
	[BudgetAmount] [nvarchar](8) NOT NULL,
	[Account_Name] [nvarchar](100) NOT NULL,
	[Department] [nvarchar](4) NOT NULL,
	[Cost_Type] [nvarchar](100) NOT NULL
) ON [PRIMARY]
END
GO
/****** Object:  Table [fin].[ExpensesReforcast]    Script Date: 28/06/2019 09:41:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[fin].[ExpensesReforcast]') AND type in (N'U'))
BEGIN
CREATE TABLE [fin].[ExpensesReforcast](
	[Period] [nvarchar](7) NOT NULL,
	[Account] [decimal](4, 0) NOT NULL,
	[BudgetAmount] [nvarchar](8) NOT NULL,
	[Account_Name] [nvarchar](100) NOT NULL,
	[Department] [nvarchar](4) NOT NULL,
	[Cost_Type] [nvarchar](100) NOT NULL
) ON [PRIMARY]
END
GO
/****** Object:  Table [land].[fin_AdminFeeMapping]    Script Date: 28/06/2019 09:41:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[land].[fin_AdminFeeMapping]') AND type in (N'U'))
BEGIN
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
	[CreatedDate] [datetime] NULL,
	[TaskID] [int] NULL,
	[SourceLinePosition] [int] NULL,
	[Valid] [int] NULL
) ON [PRIMARY]
END
GO
/****** Object:  Table [land].[fin_ExpensesBudget]    Script Date: 28/06/2019 09:41:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[land].[fin_ExpensesBudget]') AND type in (N'U'))
BEGIN
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
END
GO
/****** Object:  Table [land].[fin_ExpensesMapping]    Script Date: 28/06/2019 09:41:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[land].[fin_ExpensesMapping]') AND type in (N'U'))
BEGIN
CREATE TABLE [land].[fin_ExpensesMapping](
	[Account] [nvarchar](10) NULL,
	[Account_int] [int] NULL,
	[Account_isNumeric] [int] NULL,
	[BK_Count] [int] NULL,
	[Account_Name] [nvarchar](50) NULL,
	[High_Level_Account] [nvarchar](50) NULL,
	[Ranking] [nvarchar](30) NULL,
	[CreatedDate] [datetime] NULL,
	[TaskID] [int] NULL,
	[SourceLinePosition] [int] NULL,
	[Valid] [int] NOT NULL
) ON [PRIMARY]
END
GO
/****** Object:  Table [land].[fin_ExpensesReforecast]    Script Date: 28/06/2019 09:41:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[land].[fin_ExpensesReforecast]') AND type in (N'U'))
BEGIN
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
END
GO
/****** Object:  Table [land].[fin_FixedAsset]    Script Date: 28/06/2019 09:41:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[land].[fin_FixedAsset]') AND type in (N'U'))
BEGIN
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
	[CreatedDate] [datetime] NULL,
	[TaskID] [int] NULL,
	[Valid] [int] NULL
) ON [PRIMARY]
END
GO
/****** Object:  Table [land].[fin_IncomeBudget]    Script Date: 28/06/2019 09:41:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[land].[fin_IncomeBudget]') AND type in (N'U'))
BEGIN
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
	[SourceLinePosition] [int] NULL,
	[Valid] [int] NULL
) ON [PRIMARY]
END
GO
/****** Object:  Table [land].[fin_IncomeMapping]    Script Date: 28/06/2019 09:41:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[land].[fin_IncomeMapping]') AND type in (N'U'))
BEGIN
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
	[CreatedDate] [datetime] NULL,
	[TaskID] [int] NULL,
	[SourceLinePosition] [int] NULL,
	[Valid] [int] NULL
) ON [PRIMARY]
END
GO
/****** Object:  Table [land].[fin_IncomeReforecast]    Script Date: 28/06/2019 09:41:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[land].[fin_IncomeReforecast]') AND type in (N'U'))
BEGIN
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
	[SourceLinePosition] [int] NULL,
	[Valid] [int] NULL
) ON [PRIMARY]
END
GO
/****** Object:  Table [land].[fin_JDT1]    Script Date: 28/06/2019 09:41:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[land].[fin_JDT1]') AND type in (N'U'))
BEGIN
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
END
GO
/****** Object:  Table [land].[fin_OACT]    Script Date: 28/06/2019 09:41:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[land].[fin_OACT]') AND type in (N'U'))
BEGIN
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
END
GO
/****** Object:  Table [land].[fin_OFPR]    Script Date: 28/06/2019 09:41:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[land].[fin_OFPR]') AND type in (N'U'))
BEGIN
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
END
GO
/****** Object:  Table [land].[fin_OOCR]    Script Date: 28/06/2019 09:41:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[land].[fin_OOCR]') AND type in (N'U'))
BEGIN
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
END
GO
/****** Object:  Table [land].[fin_TBMapping]    Script Date: 28/06/2019 09:41:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[land].[fin_TBMapping]') AND type in (N'U'))
BEGIN
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
END
GO
/****** Object:  Table [land].[fin_UndistributedFundsMappings]    Script Date: 28/06/2019 09:41:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[land].[fin_UndistributedFundsMappings]') AND type in (N'U'))
BEGIN
CREATE TABLE [land].[fin_UndistributedFundsMappings](
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
END
GO
/****** Object:  Table [stg].[fin_ExpensesMapping]    Script Date: 28/06/2019 09:41:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[stg].[fin_ExpensesMapping]') AND type in (N'U'))
BEGIN
CREATE TABLE [stg].[fin_ExpensesMapping](
	[account] [nvarchar](10) NULL,
	[high_level_account] [nvarchar](50) NULL,
	[ranking] [nvarchar](30) NULL
) ON [PRIMARY]
END
GO
/****** Object:  Table [stg].[FinBudget]    Script Date: 28/06/2019 09:41:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[stg].[FinBudget]') AND type in (N'U'))
BEGIN
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
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dim].[DF__FinDate__DW_Crea__4D7F7902]') AND type = 'D')
BEGIN
ALTER TABLE [dim].[FinDate] ADD  DEFAULT (getdate()) FOR [DW_CreatedDate]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dim].[DF__FinDate__DW_Modi__4E739D3B]') AND type = 'D')
BEGIN
ALTER TABLE [dim].[FinDate] ADD  DEFAULT (getdate()) FOR [DW_ModifiedDate]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dim].[DF__FinDistri__DW_Cr__2942188C]') AND type = 'D')
BEGIN
ALTER TABLE [dim].[FinDistributionSector] ADD  DEFAULT (getdate()) FOR [DW_CreatedDate]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dim].[DF__FinDistri__DW_Mo__2A363CC5]') AND type = 'D')
BEGIN
ALTER TABLE [dim].[FinDistributionSector] ADD  DEFAULT (getdate()) FOR [DW_ModifiedDate]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dim].[DF__FinIncome__DW_Cr__150615B5]') AND type = 'D')
BEGIN
ALTER TABLE [dim].[FinIncomeSector] ADD  DEFAULT (getdate()) FOR [DW_CreatedDate]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dim].[DF__FinIncome__DW_Mo__15FA39EE]') AND type = 'D')
BEGIN
ALTER TABLE [dim].[FinIncomeSector] ADD  DEFAULT (getdate()) FOR [DW_ModifiedDate]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dim].[DF__FinIncome__DW_Cr__19CACAD2]') AND type = 'D')
BEGIN
ALTER TABLE [dim].[FinIncomeType] ADD  DEFAULT (getdate()) FOR [DW_CreatedDate]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dim].[DF__FinIncome__DW_Mo__1ABEEF0B]') AND type = 'D')
BEGIN
ALTER TABLE [dim].[FinIncomeType] ADD  DEFAULT (getdate()) FOR [DW_ModifiedDate]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dim].[DF__FinLicens__DW_Cr__0504B816]') AND type = 'D')
BEGIN
ALTER TABLE [dim].[FinLicenseFeeCountry] ADD  DEFAULT (getdate()) FOR [DW_CreatedDate]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dim].[DF__FinLicens__DW_Mo__05F8DC4F]') AND type = 'D')
BEGIN
ALTER TABLE [dim].[FinLicenseFeeCountry] ADD  DEFAULT (getdate()) FOR [DW_ModifiedDate]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dim].[DF__FinUndist__DW_Cr__1E8F7FEF]') AND type = 'D')
BEGIN
ALTER TABLE [dim].[FinUndistributedFunds] ADD  DEFAULT (getdate()) FOR [DW_CreatedDate]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dim].[DF__FinUndist__DW_Mo__1F83A428]') AND type = 'D')
BEGIN
ALTER TABLE [dim].[FinUndistributedFunds] ADD  DEFAULT (getdate()) FOR [DW_ModifiedDate]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[fact].[DF__FinFixedA__DW_Cr__369C13AA]') AND type = 'D')
BEGIN
ALTER TABLE [fact].[FinFixedAsset] ADD  DEFAULT (getdate()) FOR [DW_CreatedDate]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[fact].[DF__FinFixedA__DW_Mo__379037E3]') AND type = 'D')
BEGIN
ALTER TABLE [fact].[FinFixedAsset] ADD  DEFAULT (getdate()) FOR [DW_ModifiedDate]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[fact].[DF__FinTransa__DW_Cr__226010D3]') AND type = 'D')
BEGIN
ALTER TABLE [fact].[FinTransaction] ADD  DEFAULT (getdate()) FOR [DW_CreatedDate]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[fact].[DF__FinTransa__DW_Mo__2354350C]') AND type = 'D')
BEGIN
ALTER TABLE [fact].[FinTransaction] ADD  DEFAULT (getdate()) FOR [DW_ModifiedDate]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[stg].[DF__FinBudget__DW_Cr__627A95E8]') AND type = 'D')
BEGIN
ALTER TABLE [stg].[FinBudget] ADD  DEFAULT (getdate()) FOR [DW_CreatedDate]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[stg].[DF__FinBudget__DW_Mo__636EBA21]') AND type = 'D')
BEGIN
ALTER TABLE [stg].[FinBudget] ADD  DEFAULT (getdate()) FOR [DW_ModifiedDate]
END
GO
