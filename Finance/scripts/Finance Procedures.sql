
/****** Object:  StoredProcedure [fin].[LoadLandingToDWHTransactions]    Script Date: 12/07/2019 15:01:29 ******/
DROP PROCEDURE IF EXISTS [fin].[LoadLandingToDWHTransactions]
GO
/****** Object:  StoredProcedure [fin].[LoadLandingToDWHFixedAssets]    Script Date: 12/07/2019 15:01:29 ******/
DROP PROCEDURE IF EXISTS [fin].[LoadLandingToDWHFixedAssets]
GO
/****** Object:  StoredProcedure [fin].[LoadLandingToDWHDimensions]    Script Date: 12/07/2019 15:01:29 ******/
DROP PROCEDURE IF EXISTS [fin].[LoadLandingToDWHDimensions]
GO
/****** Object:  StoredProcedure [fin].[LoadLandingToDWHDateDimension]    Script Date: 12/07/2019 15:01:29 ******/
DROP PROCEDURE IF EXISTS [fin].[LoadLandingToDWHDateDimension]
GO
/****** Object:  StoredProcedure [fin].[LoadLandingToDWHDateDimension]    Script Date: 12/07/2019 15:01:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[fin].[LoadLandingToDWHDateDimension]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [fin].[LoadLandingToDWHDateDimension] AS' 
END
GO
--EXEC fin.LoadLandingToDWHDateDimension 2

/****** Object:  StoredProcedure [fin].[LoadDateDimension]    Script Date: 6/20/2019 9:32:59 AM ******/

ALTER procedure [fin].[LoadLandingToDWHDateDimension] @input INT
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
/****** Object:  StoredProcedure [fin].[LoadLandingToDWHDimensions]    Script Date: 12/07/2019 15:01:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[fin].[LoadLandingToDWHDimensions]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [fin].[LoadLandingToDWHDimensions] AS' 
END
GO
--[fin].[LoadLandingToDWHDimensions]
--

ALTER Procedure [fin].[LoadLandingToDWHDimensions] @input INT
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
	FROM land.fin_IncomeMapping 
	--WHERE Valid=1
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
	SELECT  [Income_Type], CAST(max(Income_Type_Ranking) AS INT) FROM land.[fin_IncomeMapping] --WHERE Valid=1 
	group by [Income_Type]
	--ORDER BY CAST(Income_Type_Ranking AS INT)


---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- dim.FinAccount
-- Truncate and Insert
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
TRUNCATE TABLE dim.FinAccount
-- Insert a default record with ID=0, AcctCode="Unknown" or "Not Known", AccountName="Unknown" and setting all other columns to default VALUES
SET IDENTITY_INSERT dim.FinAccount ON
INSERT INTO [dim].[FinAccount]
           (ID,[Account Code],[Account Name],[Expense High Level Account],[TB_Mapping],[Expense Ranking],[TB Ranking],[Is Salary Account],[DW_CreatedDate],[DW_ModifiedDate])
			VALUES(0,'N/A','N/A','N/A','N/A',0,0,0,GetDate(),GetDate())
SET IDENTITY_INSERT dim.FinAccount OFF

INSERT INTO [dim].[FinAccount]
           ([Account Code],[Account Name],[Expense High Level Account],[TB_Mapping],[Expense Ranking],[TB Ranking],[Is Salary Account],[DW_CreatedDate],[DW_ModifiedDate])
SELECT oact.AcctCode AS [Account Code]
	   ,oact.AcctName AS [Account Name]
	   ,exmap.[High_Level_Account] AS [Expense High Level Account]
	   ,tbmap.[TB_Mapping]
	   ,CAST(exmap.Ranking AS INT) AS [Expense Ranking] 
	   ,CAST(tbmap.[TB_Mapping_Rank] AS INT) AS [TB Ranking] 
	   ,case when exmap.[High_Level_Account] ='Staff Costs' OR exmap.[High_Level_Account] ='Directors Costs' then 1 else 0 end As [Is Salary Account]
	   ,GETDATE() AS DW_CreatedDate
	   ,GETDATE() AS DW_ModifiedDate
FROM land.[fin_OACT] oact
left join land.[fin_ExpensesMapping] exmap on exmap.[Account]=oact.AcctCode and exmap.Valid=1 
left join land.[fin_TBMapping] tbmap on tbmap.[Account_Code]=oact.AcctCode and tbmap.Valid=1
WHERE oact.Valid=1 AND oact.isHierarchyTop=0 AND oact.isHierarchyLeaf=1

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
INSERT INTO DIM.FinExpenseCostType (Id,[Expense Cost Type],[Rank],DW_CreatedDate,DW_ModifiedDate)
VALUES(0,'N/A',0,GetDate(),Getdate())
SET IDENTITY_INSERT dim.FinExpenseCostType OFF

INSERT INTO DIM.FinExpenseCostType ([Expense Cost Type],[Rank],DW_CreatedDate,DW_ModifiedDate)
	SELECT DISTINCT 
		   High_Level_Account AS [Expense Cost Type],
		   [Ranking]
		   ,GETDATE() AS DW_CreatedDate
		   ,GETDATE() AS DW_ModifiedDate
	FROM land.[fin_ExpensesMapping]
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
	DISTINCT [Account_Code],[Income_Sector] , [UKernational_Distributable_Fee_Income], [Sub_sector], 
	isnull([Income_Sector_Ranking] ,0), isnull([Licence_Fee_Country_Ranking] ,0), isnull(Sub_sector_Ranking,0)
FROM 
	[land].[fin_UndistributedFunds] --WHERE Valid=1

-- NB: [Income_Sector_Ranking] to be renamed to [Fee_Categorisation_Ranking] in STG table


---Department and user mapping
--Inser new user and department mapping
Insert INTO fin.DepartmentUser
	(UserName,Department,Active,ActivatedDate,DW_CreatedDate)
select 
	l.UserName,l.DepartmentCode,1,GetDate(),GetDAte()
from 
	land.[DepartmentUserMapping] l
	left join fin.DepartmentUser f on f.UserName=l.UserName AND l.DepartmentCode=f.Department
WHERE 
l.Valid=1 AND f.UserName IS NULL	 

--Activate a user and department mapping if it has been de-activated before
Update f
SET Active=1,ActivatedDate=GetDate(),DeActivatedDate=Null 
from 
	land.[DepartmentUserMapping] l
	INNER join fin.DepartmentUser f on f.UserName=l.UserName AND l.DepartmentCode=f.Department
WHERE 
Active=0 AND 
l.Valid=1

--Deactivate a user and department mapping 
Update f
SET Active=0,DeActivatedDate=GetDAte() 
from 
	 fin.DepartmentUser f 
	left join land.[DepartmentUserMapping] l on f.UserName=l.UserName AND l.DepartmentCode=f.Department and l.valid=1
WHERE 
l.username is null

PRINT 'Procedure LoadLandingToDWHDimensions end:   ' + CONVERT(nvarchar,GETDATE(), 127)
GO
/****** Object:  StoredProcedure [fin].[LoadLandingToDWHFixedAssets]    Script Date: 12/07/2019 15:01:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[fin].[LoadLandingToDWHFixedAssets]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [fin].[LoadLandingToDWHFixedAssets] AS' 
END
GO

ALTER PROCEDURE [fin].[LoadLandingToDWHFixedAssets] @input INT
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
      ,[ItmsGrpCode]
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
/****** Object:  StoredProcedure [fin].[LoadLandingToDWHTransactions]    Script Date: 12/07/2019 15:01:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[fin].[LoadLandingToDWHTransactions]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [fin].[LoadLandingToDWHTransactions] AS' 
END
GO
--exec [fin].[LoadLandingToDWHTransactions] 0
ALTER Procedure [fin].[LoadLandingToDWHTransactions] @input INT
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
           ,[Invoice Reference], [Document Date], [VAT Group], [VAT Amount], [BaseSum], [Income Budget], [Income Daily Budget], [Income ReForecast], [Income Daily ReForecast]
           ,[Expenses Budget], [Expenses Daily Budget], [Expenses ReForecast], [Expenses Daily ReForecast], [RecordType])
   
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
		,0--,isnull(dfect.id,0) AS [Expense Cost Type]
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
--left join (
--SELECT distinct [account]
--      ,[high_level_account]
--      ,[ranking]
--  FROM land.[fin_ExpensesMapping]
--) sfem on sfem.account=j.Account
--left join [dim].[FinExpenseCostType] dfect on dfect.[Expense Cost Type]=sfem.High_Level_Account
WHERE j.Valid=1

truncate table [fact].[FinTransactionAggregates]

INSERT INTO [fact].[FinTransactionAggregates]
           ([Account],[Fee Category],[Licence Type],[Title Type]
           ,[Department],[Income Sector],[Income Type],[Country]
           ,[Distribution Sector],[Undistributed Account Code],[Expense Cost Type],[AdminFeePercent]
           ,[Posting Date],[Debit],[Credit],[VAT Amount]
           ,[BaseSum],[Income Daily Budget],[Income Daily Reforecast]
           ,[Expenses Daily Budget],[Expenses Daily Reforecast],[DW_CreatedDate],[DW_ModifiedDate])

SELECT  isnull(a.Id,0) AS Account
		,isnull(fc.Id,0) AS [Fee Category]
		,isnull(lt.Id,0) AS [Licence Type] 
		,isnull(tt.Id,0) AS [Title Type]
		,isnull(d.Id,0) AS Department
		,isnull(sec.Id,0) AS [Income Sector]
		,isnull(it.Id,0) AS [Income Type]
		,isnull(c.Id,0) AS [Country]
		,isnull(distrSec.Id,0) AS [Distribution Sector]
		,isnull(un.Id,0) AS [Undistributed Account Code]
		,0--isnull(dfect.id,0) AS [Expense Cost Type]
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
		,j.TotalVat AS [VAT Amount]
		,j.BaseSum		
		,CAST(null AS money) AS [Income Daily Budget]
		,CAST(null AS money) AS [Income Daily Forecast]
		,CAST(null AS money) AS [Expenses Daily Budget]
		,CAST(null AS money) AS [Expenses Daily Forecast]
		,getdate()
		,getdate()
from 
	(SELECT    x.account,x.OcrCode2,x.OcrCode3,x.OcrCode4,x.ProfitCode
		,x.RefDate
		,sum(ISNULL(x.Debit, 0)) AS Debit
		,sum(ISNULL(x.Credit, 0)) AS Credit
		,sum(isnull(x.TotalVat,0)) AS TotalVat
		,sum(isnull(x.BaseSum,0))  as BaseSum		
	
FROM land.[fin_JDT1] x
WHERE x.Valid=1
group by x.account,x.OcrCode2,x.OcrCode3,x.OcrCode4,x.ProfitCode,RefDate 
	) j	
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
--left join (
--SELECT distinct [account]
--      ,[high_level_account]
--      ,[ranking]
--  FROM land.[fin_ExpensesMapping]
--) sfem on sfem.account=j.Account
--left join [dim].[FinExpenseCostType] dfect on dfect.[Expense Cost Type]=sfem.High_Level_Account

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
		,dfect.ID AS [Expenses Cost Type]
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
left join (SELECT distinct [account]
      ,[high_level_account]
      ,[ranking]
  FROM [stg].[fin_ExpensesMapping]) sfem on sfem.account=expBudget.Account
left join [dim].[FinExpenseCostType] dfect on dfect.[Expense Cost Type]=sfem.High_Level_Account



--------------------------------------------------------------------------
-- Insert month-level income Budget only
-- NO validations required
--------------------------------------------------------------------------

insert INTO fact.FinTransaction ([Account],[Fee Category], [Licence Type], [Title Type],Department, [Income Sector], [Income Type], [Country], [Distribution Sector], [Undistributed Account Code],
								[Expense Cost Type],[Posting Date], [Debit], [Credit], [Income Budget], [Income Daily Budget], [Income ReForecast], [Income Daily ReForecast], 
								[Expenses Budget],  [Expenses Daily Budget], [Expenses ReForecast], [Expenses Daily ReForecast], [RecordType])
SELECT   isnull(b.Account,0)
		,isnull(b.[Fee Category],0)
		,isnull(b.[Licence Type] ,0)
		,isnull(b.[Title Type],0)
		,isnull(b.Department,0)
		,isnull(b.[Income Sector],0)
		,isnull(b.[Income Type],0)
		,isnull(b.[Country]	,0)
		,isnull(b.[Distribution Sector],0)
		,isnull(b.[Undistributed Account Code]	,0)
		,b.[Expenses Cost Type]
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


insert INTO fact.FinTransaction  ([Account],[Fee Category], [Licence Type], [Title Type], Department,[Income Sector], [Income Type], [Country], [Distribution Sector], [Undistributed Account Code],
								[Expense Cost Type],[Posting Date], [Debit], [Credit], [Income Budget], [Income Daily Budget], [Income ReForecast], [Income Daily ReForecast], 
								[Expenses Budget],  [Expenses Daily Budget], [Expenses ReForecast], [Expenses Daily ReForecast], [RecordType])
								
SELECT   ISNULL(b.Account,0)
		,isnull(b.[Fee Category],0)
		,isnull(b.[Licence Type] ,0)
		,isnull(b.[Title Type],0)
		,isnull(b.[Department],0)
		,isnull(b.[Income Sector],0)
		,isnull(b.[Income Type],0)
		,isnull(b.[Country],0)
		,isnull(b.[Distribution Sector],0)
		,isnull(b.[Undistributed Account Code],0)		
		,b.[Expenses Cost Type]
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



INSERT INTO [fact].[FinTransactionAggregates]
           ([Account],[Fee Category],[Licence Type],[Title Type]
           ,[Department],[Income Sector],[Income Type],[Country]
           ,[Distribution Sector],[Undistributed Account Code],[Expense Cost Type],[AdminFeePercent]
           ,[Posting Date],[Debit],[Credit],[VAT Amount]
           ,[BaseSum],[Income Daily Budget],[Income Daily Reforecast]
           ,[Expenses Daily Budget],[Expenses Daily Reforecast],[DW_CreatedDate],[DW_ModifiedDate])

SELECT   ISNULL(b.Account,0)
		,isnull(b.[Fee Category],0)
		,isnull(b.[Licence Type] ,0)
		,isnull(b.[Title Type],0)
		,isnull(b.Department,0)
		,isnull(b.[Income Sector],0)
		,isnull(b.[Income Type],0)
		,isnull(b.[Country],0)
		,isnull(b.[Distribution Sector],0)
		,isnull(b.[Undistributed Account Code],0)	
		,b.[Expenses Cost Type]	
		,0 as AdminFeePercent
		,b.[Period] AS [Posting Date]
		,0 AS Debit
		,0 AS Credit
		,0 as Vat
		,0 as BaseSum
		,b.[Income Budget]/CAST(DATEPART(DAY, EOMONTH(d.[Date])) AS numeric) AS [Income Daily Budget]
		,b.[Income Forecast]/CAST(DATEPART(DAY, EOMONTH(d.[Date])) AS numeric) AS [Income Daily Forecast]
		,b.[Expenses Budget]/CAST(DATEPART(DAY, EOMONTH(d.[Date])) AS numeric) AS [Expenses Daily Budget]
		,b.[Expenses Forecast]/CAST(DATEPART(DAY, EOMONTH(d.[Date])) AS numeric) AS [Expenses Daily Forecast]
		,GetDate()
		,GetDate()
FROM stg.FinBudget b
left join dim.FinDate d on DATEPART(MONTH, convert(date, b.[Period], 105)) =  DATEPART(MONTH, d.[Date]) 
                       and DATEPART(YEAR, convert(date, b.[Period], 105)) =  DATEPART(YEAR, d.[Date])

PRINT 'Procedure LoadLandingToDWHTransactions end:   ' + CONVERT(nvarchar,GETDATE(), 127)
GO
