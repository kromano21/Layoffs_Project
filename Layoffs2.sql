SELECT *
FROM layoffs_staging2;

SELECT company, MAX(total_laid_off) AS max
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC;

SELECT country, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;

SELECT YEAR(`date`), country, SUM(total_laid_off) as `sum`
FROM layoffs_staging2
GROUP BY YEAR(`date`), country
ORDER BY 3 desc;

SELECT SUBSTRING(`date`,1,7) AS `month`, sum(total_laid_off)
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `month`
ORDER BY 1 ASC;

WITH Rolling_Total AS 
(
SELECT SUBSTRING(`date`,1,7) AS `month`, sum(total_laid_off) AS total_off
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `month`
ORDER BY 1 ASC
)
SELECT `month`, total_off, SUM(total_off) OVER(ORDER BY `month`) as rolling_total
FROM Rolling_Total
GROUP BY `month`;

WITH Company_Year(company, years, total_laid_off) AS
(SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
), Company_Year_Rank AS
(SELECT *, DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
FROM Company_Year
WHERE years IS NOT NULL
ORDER BY years DESC)
SELECT *
FROM Company_Year_Rank
WHERE Ranking <= 5;

SELECT *
FROM layoffs_staging2;

SELECT location, SUM(total_laid_off) AS sum_laid_off
FROM layoffs_staging2
GROUP BY 1
ORDER BY 2 DESC;

SELECT *
FROM layoffs_staging2
WHERE company = '2U';

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

WITH Rolling_USA AS
(
SELECT SUBSTRING(`date`, 1, 7) AS `month`, SUM(total_laid_off) as sum_laid_off
FROM layoffs_staging2
WHERE country = "United States" AND SUBSTRING(`date`, 1, 7) IS NOT NULL
GROUP BY 1
ORDER BY 1 ASC
)
SELECT `month`, sum_laid_off, SUM(sum_laid_off) OVER(ORDER BY `month`) AS rolling_total
FROM Rolling_USA
GROUP BY 1
ORDER BY 1 ASC;

WITH Rolling_Non_USA AS 
(
SELECT SUBSTRING(`date`, 1, 7) AS `month`, SUM(total_laid_off) as sum_laid_off
FROM layoffs_staging2
WHERE country != "United States" AND SUBSTRING(`date`, 1, 7) IS NOT NULL
GROUP BY 1
ORDER BY 1 ASC
);



CREATE TABLE Rolling_Non_USA AS
SELECT SUBSTRING(`date`, 1, 7) AS `month`, SUM(total_laid_off) AS Non_US_Laid_Off
FROM layoffs_staging2
WHERE country != "United States" AND SUBSTRING(`date`, 1, 7) IS NOT NULL
GROUP BY 1
ORDER BY 1 ASC;

SELECT *
FROM Rolling_Non_USA;

CREATE TABLE Final_Rolling_Non_USA AS
SELECT `month`, Non_US_Laid_Off, SUM(Non_US_Laid_Off) OVER (ORDER BY `month`) AS Non_US_Rolling_Total
FROM Rolling_Non_USA
ORDER BY 1;

SELECT *
FROM Final_Rolling_Non_USA;


CREATE TABLE Rolling_USA AS 
SELECT SUBSTRING(`date`, 1, 7) AS `month`, SUM(total_laid_off) AS US_Laid_Off
FROM layoffs_staging2
WHERE country = 'United States'
GROUP BY `month`
ORDER BY `month` ASC;

CREATE TABLE Final_Rolling_USA AS 
SELECT `month`, US_Laid_Off, SUM(US_Laid_Off) OVER (ORDER BY `month`) AS US_Rolling_Total
FROM Rolling_USA
ORDER BY `month` ASC;

CREATE TABLE Final_Rolling AS
SELECT 
  t_US.`month`,
  t_US.US_Laid_off AS usa_laid_off,
  t_US.US_Rolling_Total AS usa_rolling_total,
  t_NUS.Non_US_Laid_Off AS non_usa_laid_off,
  t_NUS.Non_US_Rolling_Total AS non_usa_rolling_total
FROM Final_Rolling_USA t_US
INNER JOIN Final_Rolling_Non_USA t_NUS
ON t_US.`month` = t_NUS.`month`;

SELECT *
FROM Final_Rolling;

CREATE TABLE Final_Rolling_2 AS
SELECT SUBSTRING(`month`, 6, 2) AS `date`, usa_laid_off, usa_rolling_total, non_usa_laid_off, non_usa_rolling_total
FROM Final_Rolling;

SELECT *
FROM Final_Rolling_2;

CREATE TABLE Industry AS 
SELECT industry, SUM(total_laid_off) AS laid_off
FROM layoffs_staging2
WHERE industry != 'Other'
GROUP BY 1
ORDER BY 2 DESC;

CREATE TABLE Location AS 
SELECT location, SUM(total_laid_off) AS laid_off
FROM layoffs_staging2
GROUP BY 1
ORDER BY 2 DESC;

SELECT *
FROM Location;


SELECT *
FROM Industry;

SELECT *
FROM layoffs_staging2;