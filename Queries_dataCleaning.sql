
#Project 1  : SQL -> DATA CLEANING  

CREATE DATABASE world_layoffs;

-- or create database using  create a new schema 

-- import the table from device

SELECT * 
FROM layoffs;


--  standard process of data cleaning we can modify it accoding to our requirements  
# 1. Remove Duplicates
# 2. Standardize the data
# 3. Null values or blank values
# 4. Remove any columns


# Making a staging table to perform operations because we want our main data to be unchanged and safe
CREATE TABLE layoffs_staging 
LIKE layoffs;

INSERT INTO layoffs_staging
SELECT  *  #everything
FROM layoffs;

SELECT * FROM layoffs_staging;


# We will make changes in the staging table so that the raw data still remains available if we attempt any mistake

### Step 1 :  Removing Duplicates

SELECT * , 
ROW_NUMBER() OVER(
PARTITION BY company , location , industry , total_laid_off , percentage_laid_off  , `date` , stage ,
country  , funds_raised_millions) as row_num
FROM layoffs_staging; 


WITH cte1 AS # Making a common table expression
(
SELECT * , 
ROW_NUMBER() OVER(
PARTITION BY company , location , industry , total_laid_off , percentage_laid_off  , 
`date` , stage ,country  , funds_raised_millions
) as row_num
FROM layoffs_staging
)

 
# Duplicates
SELECT * 
FROM cte1 
WHERE row_num > 1;


# Check 
SELECT *
FROM layoffs_staging
WHERE company='Casper';


#will remove the duplicate ones 
#we cannot apply delete commmand to a CTE
# we will create a new table called staging 2 with new attribute called row_num

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL ,
  `row_num` int 
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


INSERT INTO layoffs_staging2
SELECT * , 
ROW_NUMBER() OVER(
PARTITION BY company , location , industry , total_laid_off , percentage_laid_off  , 
`date` , stage ,country  , funds_raised_millions
) as row_num
FROM layoffs_staging;


# Now we have the required table called layoffs_staging2
# We will do our work in it now

# Duplicates
SELECT * FROM layoffs_staging2 WHERE row_num>1;

# Remove duplicates 
DELETE 
FROM layoffs_staging2 
WHERE row_num>1;

SELECT * FROM layoffs_staging2;



### Step 2 :  Standardizing Data : Will perform standardization attribute wise , check for the need 
### for every attribute and do the required


# Removing whitespaces from company
SELECT company , TRIM(company)
FROM layoffs_staging2;

UPDATE layoffs_staging2 
SET company = TRIM(company); 


# Checking industry and given same name to the industry of same type
SELECT DISTINCT industry FROM layoffs_staging2 ORDER BY 1;

SELECT * FROM layoffs_staging2 WHERE industry LIKE '%Crypto%';

UPDATE layoffs_staging2 
SET industry ='Crypto'
WHERE industry LIKE '%Crypto%';


# Checking location : everything looks fine
SELECT DISTINCT location 
FROM layoffs_staging2 ORDER BY 1;


# Checking Country : repeating
SELECT DISTINCT country 
FROM layoffs_staging2 order by 1;

SELECT DISTINCT country 
FROM layoffs_staging2
WHERE country LIKE '%United States%';

UPDATE layoffs_staging2
SET country = 'United States'
WHERE country LIKE '%United states%';

#or

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United Stated%';


# Standardize date column to date datatype

SELECT `date` ,
STR_TO_DATE(`date`  , '%m/%d/%Y') as date
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date` , '%m/%d/%Y');

SELECT `date` 
FROM layoffs_staging2;

#Now change it to a date column ( datatype )

-- doing this after making the date in suitable format

ALTER TABLE layoffs_staging2
MODIFY `date` DATE; #Changing datatype to DATE



###  Step 3 : Working with NULL and Blanks values ( missing values )

SELECT *
FROM layoffs_staging2;

SELECT * 
FROM layoffs_staging2
WHERE total_laid_off IS NULL;
 
# If  there are two NULL then the chances are there that the tuple is useless
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

# Will look at the tuples with industry as NULL or Blank
SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
OR industry ='';

# Make them of same type (NULL , so that we can update later )
UPDATE layoffs_staging2
SET industry = NULL
WHERE industry ='';

#Check if the same company has industry with same name 
SELECT *
FROM layoffs_staging2
WHERE company = 'Airbnb'; # yes 

# Will try to populate the data ( assuming companies with same name at same location are of same type industry )
SELECT *
FROM layoffs_staging2 AS t1
JOIN layoffs_staging2 AS t2
	ON t1.company = t2.company
    AND t1.location = t2.location
WHERE t1.industry is NULL 
AND t2.industry IS NOT NULL;

UPDATE layoffs_staging2 AS t1
JOIN layoffs_staging2 AS t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry is NULL
AND t2.industry  IS NOT NULL;



###  Step 4 : Will Remove the unneccesaary rows

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

# Delete only when you are 100% sure
DELETE 
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

# Drop the row_num

ALTER TABLE layoffs_staging2 
DROP COLUMN row_num;



# Finalised Clean data
SELECT *
FROM layoffs_staging2;


