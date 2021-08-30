/*
Cleaning Data in SQL
About: In this Project, we will clean data from a survey containing information of over 26000+ people and their jobs. 
resulting in a database with data that can yield reliable results and drive business decisions.
Each modification is going to be listed and then compared to the original dataset to see if worked as intented; If so, then we´ll commit the changes.
*/

  -- Starting by exploring the whole dataset
SELECT *
FROM SurveyData.dbo.Survey

 -- Dropping Null columns
 
BEGIN TRAN
	ALTER TABLE SurveyCleanData.dbo.Survey
	DROP COLUMN F19,F20,F21,F22,F23,F24;
	SELECT *
	FROM SurveyData.dbo.Survey -- Original Dataset
	SELECT *
	FROM SurveyCleanData.dbo.Survey -- Cleaned Dataset
COMMIT

 -- Modify dates format, as there are no values for hours of the day, only the date
BEGIN TRAN
	ALTER TABLE SurveyCleanData.dbo.Survey
	ADD convertedtimestamp Date;
	
	UPDATE SurveyCleanData.dbo.Survey
	SET convertedTimestamp = CONVERT(Date,timestamp);

	SELECT TOP 5 convertedTimestamp
	FROM SurveyCleanData.dbo.Survey
	convertedTimestamp; -- Cleaned Dataset

	SELECT TOP 5 Timestamp FROM SurveyData.dbo.Survey; -- Original Dataset
COMMIT

-- Delete Entire NULL Rows
BEGIN TRAN
	SELECT COUNT(*) AS 'Before' FROM SurveyCleanData.dbo.Survey;

	DELETE FROM SurveyCleanData.dbo.Survey
	WHERE Timestamp IS NULL AND Age IS NULL and Industry IS NULL;

	SELECT COUNT(*) AS 'After'FROM SurveyCleanData.dbo.Survey;
COMMIT

-- Stadarizing Country names
BEGIN TRAN
	SELECT DISTINCT Country
	FROM SurveyCleanData.dbo.Survey
	Order BY country;

--Removing Unwanted Punctuations Or/And Spacing
	SELECT DISTINCT Country,Trimmed, LEN(Country)AS 'A1' ,LEN(Trimmed)AS 'A2' FROM (SELECT Country,TRIM(' ,.' FROM [Country]) AS Trimmed FROM SurveyCleanData.dbo.Survey)AS s
	Order By Country; 
--Seems that there are hidden values that TRIM function is not removing
-- So i borrowed this code from http://www.select-sql.com/mssql/how-to-find-and-remove-hidden-characters-and-invisible-whitespace-when-ltrim-rtrim-not-work.html And worked properly

	UPDATE SurveyCleanData.dbo.Survey
	SET Country =
	LTRIM (RTRIM(REPLACE(REPLACE(REPLACE(REPLACE(Country, CHAR(10), ''), CHAR(13), ''), CHAR(9), ''), CHAR(160), '')));

	-- Removing undesired characters

	UPDATE SurveyCleanData.dbo.Survey
	SET Country = TRIM('.' FROM [Country]);
	UPDATE SurveyCleanData.dbo.Survey
	SET Country = TRIM('' FROM [Country]);

	SELECT DISTINCT Country from SurveyCleanData.dbo.Survey
	ORDER BY Country;-- New
	
	SELECT DISTINCT Country from SurveyData.dbo.Survey
	ORDER BY Country;-- Old

	SELECT * FROM SurveyCleanData.dbo.Survey
	WHERE country IS NULL;

	-- Replacing country names using CASE statement
	UPDATE SurveyCleanData.dbo.Survey
	SET Country = CASE
				WHEN Country LIKE '%Un__% S__%' OR country LIKE 'U_S%' OR Country like 'USA_'OR Country like '%USA%' OR Country like 'US' OR Country like 'U. S' 
				THEN 'United States'
				WHEN Country LIKE '%Englan_%' OR Country Like '%Brita__%' OR Country Like 'Northern Ireland%' OR Country LIKE 'Scotland%'
				OR Country LIKE 'Unit_% Ki_%' OR Country like '%U_K' OR Country like 'UK' OR Country like '%UK 'OR Country LIKE '%Wales%' THEN 'United Kingdom'
				WHEN Country LIKE 'C_n%' THEN 'Canada'
				WHEN Country LIKE '%Austral_%' THEN 'Australia'
				WHEN Country LIKE 'Bra_il' THEN 'Brazil'
				WHEN Country LIKE '%New Zealand%' OR Country LIke 'NZ%' THEN 'New Zealand'
				WHEN Country LIKE 'D_nmark' THEN 'Denmark'
				WHEN Country Like '%Japan%' THEN 'Japan'
				WHEN Country Like 'Italy%' THEN 'Italy'
				WHEN Country Like 'Luxemb_%' THEN 'Luxembourg'
				WHEN Country Like 'M_xico' THEN 'Mexico'
				WHEN Country Like '%Ne__%lan%' THEN 'Netherlands'
				WHEN Country Like 'Czechia' Or Country like '%Czech%'THEN 'Czech Republic'
				ELSE Country
			END
		WHERE Country IN (SELECT Country FROM SurveyCleanData.dbo.Survey);

	SELECT  COUNT(DISTINCT Country) AS L
	FROM SurveyData.dbo.Survey -- Old

	SELECT  COUNT(DISTINCT Country) AS L
	FROM SurveyCleanData.dbo.Survey -- Cleaned
COMMIT

-- Standarizing Industry



BEGIN TRAN
	
	SELECT DISTINCT Industry FROM SurveyCleanData.dbo.Survey
	ORDER BY Industry;

	UPDATE SurveyCleanData.dbo.Survey
	SET Industry = CASE
		WHEN Industry LIKE 'Academi_%' THEN 'Academia'
		WHEN Industry LIKE 'Administ_%' THEN 'Administration'
		WHEN Industry LIKE 'Aero%' THEN 'Aerospace'
		WHEN Industry LIKE 'Agricul_%' THEN 'Agriculture'
		WHEN Industry LIKE 'Apparel%' THEN 'Apparel'
		WHEN Industry LIKE 'Archaeolog_%' THEN 'Archaeology'
		WHEN Industry LIKE 'Architect%' THEN 'Architecture and Engineering'
		WHEN Industry LIKE 'Archives%' THEN 'Archives'
		WHEN Industry LIKE '%Art%' THEN 'Art % Design'
		WHEN Industry LIKE 'Auto%' THEN 'Automotive'
		WHEN Industry LIKE 'Beauty%' THEN 'Beauty'
		ELSE Industry
	END
	WHERE Industry IN (SELECT Industry FROM SurveyCleanData.dbo.Survey);


	SELECT  COUNT(DISTINCT Industry) AS L
	FROM SurveyData.dbo.Survey -- Old

	SELECT  COUNT(DISTINCT Industry) AS L
	FROM SurveyCleanData.dbo.Survey -- Cleaned
COMMIT

-- Replacing Null Values in Monetary Comp With 0

BEGIN TRAN
	UPDATE SurveyCleanData.dbo.Survey
	SET MonetaryComp = 0 
	WHERE MonetaryComp IS NULL;
	SELECT MonetaryComp FROM SurveyCleanData.dbo.Survey;


-- Combining Salary and Monetary Comp Into 1 column

	SELECT Salary, MonetaryComp, Salary + MonetaryComp AS TotalSalary 
	FROM SurveyCleanData.dbo.Survey;

	ALTER TABLE SurveyCleanData.dbo.Survey
	ADD  TotalSalary Integer;

	UPDATE SurveyCleanData.dbo.Survey
	SET TotalSalary = Salary + MonetaryComp;

Commit TRAN

-- Removing currencies that are not coded
BEGIN TRAN
	SELECT * FROM SurveyCleanData.dbo.Survey
	WHERE LEN(Currency) <> 3  AND Currency NOT IN ('Other', 'AUD/NZD');

	SELECT * FROM SurveyCleanData.dbo.Survey
	WHERE LEN(CurrencyOther) = 3 AND CurrencyOther IN ('N/A') ;

	UPDATE SurveyCleanData.dbo.Survey
	SET CurrencyOther = NULL 
	WHERE LEN(CurrencyOther) = 3 AND CurrencyOther IN ('N/A') ;
COMMIT



