-- DATA CLEANING 
SELECT*
FROM layoffs;
-- 1 Remove Duplicats
-- 2 standardize data
-- 3 null values or blank values
-- 4 remove any unessesary columns

CREATE TABLE layoffs_staging	-- create copy of layoffs table
LIKE layoffs;

select*
from layoffs_staging;

INSERT layoffs_staging  -- insert data from layoffs to layoffs_staging
select *
from layoffs;

-- DUPLICATES
WITH duplicate_cte AS   -- WITH AS () makes CTE which must be called RIGHT AFTER
(
SELECT *,
ROW_NUMBER() OVER( -- OVER: shows entire column
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, 'date', stage, country, funds_raised_millions) AS row_num  -- PARTITION BY: Will group ALL values by specific column
FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

-- created new table with set columns -- Table, right click , copy to clipboard , with statement
CREATE TABLE `layoffs_staging2` (  
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT *
FROM layoffs_staging2;

INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER( -- OVER: shows entire column
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, "date", stage, country, funds_raised_millions) AS row_num  -- PARTITION BY: Will group ALL values by specific column
FROM layoffs_staging;

DELETE 
FROM layoffs_staging2
WHERE row_num > 1;

SELECT *
FROM layoffs_staging2;

-- STANDARDIZING DATA: issues in data and fixing it

SELECT company,TRIM(company)         -- TRIM() removes any spaces
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);

SELECT *   
FROM layoffs_staging2
WHERE industry LIKE "Crypto%";  -- LIKE % searches for values that START with crypto

UPDATE layoffs_staging2
SET industry = "Crypto"
WHERE industry LIKE "Crypto%";
 
SELECT DISTINCT industry         -- DISTINCT will show only different values (no duplicates)
FROM layoffs_staging2
ORDER BY 1;    -- ORDER BY orders column in assending or dessending order. By 1 is by column 1 (industry) in select line

SELECT DISTINCT country, TRIM(TRAILING "." FROM country) -- TRAILING "" FROM looks for something at the end
FROM layoffs_staging2
Order by 1;

UPDATE layoffs_staging2
SET country = TRIM(TRAILING "." FROM country);

SELECT `date`,
str_to_date(`date`, "%m/%d/%Y") -- Converts string to date in this standard format month,day,year
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = str_to_date(`date`, "%m/%d/%Y");

ALTER TABLE layoffs_staging2		-- only do on staging table
MODIFY COLUMN `date` DATE;			-- modifies date from string to date format

SELECT `date`
FROM layoffs_staging2;

-- NULL AND BLANK VALUES

UPDATE layoffs_staging2
SET industry = NULL
WHERE industry ='';

SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
OR industry = "";

SELECT *
FROM layoffs_staging2
WHERE company = "Airbnb";

SELECT t1.industry, t2.industry   -- populate industry, set similar undustries to where missing
FROM layoffs_staging2 AS t1
JOIN layoffs_staging2 AS t2 
	ON t1.company = t2.company
    AND t1.location = t2.location
WHERE (t1.industry IS NULL)
AND t2.industry is NOT NULL;

UPDATE layoffs_staging2 AS t1
JOIN layoffs_staging2 AS t2 
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry is NOT NULL;

SELECT *
FROM layoffs_staging2;

-- REMOVE COLUMNS AND ROWS

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL -- IS NULL shows where null is
AND percentage_laid_off IS NULL;

DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL 
AND percentage_laid_off IS NULL;

SELECT *
FROM layoffs_staging2;

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;