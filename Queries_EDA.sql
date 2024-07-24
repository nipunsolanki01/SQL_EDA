
## Exploratory Data Analysis (EDA) : we will explore the data 

SELECT *
FROM layoffs_staging2;

#Checking the maximum total and percentage laid off 
SELECT MAX(total_laid_off) , MAX(percentage_laid_off)
FROM layoffs_staging2;

#Checking the companies that went permanently down ( percentage_laid_off = 1 )
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;


#Grouping the same company throughout the golbe
SELECT company , SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company 
ORDER BY 2 DESC;

# Checnking the duration of layoff : starting and end date

SELECT MIN(`date`) , MAX(`date`)
FROM layoffs_staging2;    #It shows that the layoffs started during early pandemic and till 2023 starting


# Countrywise total laid offs
SELECT country , SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;


# Lyaoffs group by date on which they happened ( which happended most recently )
SELECT `date`  , SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY `date`
ORDER BY 1 DESC;


# Layoffs yearly
SELECT YEAR(`date`) , SUM(total_laid_off)
FROM layoffs_staging2
GROUP  BY YEAR(`date`)
ORDER BY 1 DESC;

## https://x.com/INCKerala/status/1815735374444134509

# Will see at what stage employees are laid of most
SELECT stage , SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC;


# Month Wise Layoffs
SELECT MONTH(`date`) , SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY MONTH(`date`); # BUT this doesn't give month of which year for that


#this is a good choice to show months on yearly basis
SELECT substring(`date` , 1, 7) AS Monthly , SUM(total_laid_off)
FROM layoffs_staging2
WHERE substring(`date` , 1, 7) IS NOT NULL
GROUP BY Monthly
ORDER BY 1 ;


#Rolling SUM , lets create a CTE

WITH ROLLING_TOTAL AS
(
	SELECT substring(`date` , 1, 7) AS Monthly , SUM(total_laid_off) AS total_off
	FROM layoffs_staging2
	WHERE substring(`date` , 1, 7) IS NOT NULL
	GROUP BY Monthly
	ORDER BY 1 
)

SELECT Monthly , total_off , SUM(total_off) OVER(ORDER BY Monthly) AS rolling_sum
FROM ROLLING_TOTAL;

# Year Wise layoffs of comapny
SELECT company , YEAR(`date`) , SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company , YEAR(`date`)
ORDER BY 3 DESC;


# Will make a CTE 
WITH COMPANY_YEAR( company , years , total_laid_off) AS
(
	SELECT company , YEAR(`date`) , SUM(total_laid_off)
	FROM layoffs_staging2
	GROUP BY company , YEAR(`date`)
) 



#We will partition them yearly or group them yearly
SELECT * , DENSE_RANK() OVER(PARTITION BY years )
FROM COMPANY_YEAR
WHERE years IS NOT NULL;


SELECT * 
FROM layoffs_staging2
WHERE country LIKE '%india%'
AND percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;