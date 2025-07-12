WITH
  TotalSum AS (
  SELECT
    LAST_DAY(CAST(OrderDate AS DATE), MONTH) AS Month,
    salesterritory.CountryRegionCode AS Country_region_code,
    salesterritory.name AS Region,
    COUNT(SalesOrderId) AS Number_of_orders,
    COUNT(DISTINCT salesorderheader.CustomerID) AS Number_of_customers,
    COUNT(DISTINCT salesorderheader.SalesPersonID) AS Number_of_salespersons,
    CAST(SUM(salesorderheader.TotalDue) AS INT64) AS Total_amount_with_tax
  FROM
    `tc-da-1.adwentureworks_db.salesorderheader` AS salesorderheader
  JOIN
    `tc-da-1.adwentureworks_db.salesterritory` AS salesterritory
  ON
    salesterritory.TerritoryID = salesorderheader.TerritoryID
  GROUP BY
    Month,
    salesterritory.name,
    salesterritory.CountryRegionCode )
SELECT
  Month,
  Country_region_code,
  Region,
  Number_of_orders,
  Number_of_customers,
  Number_of_salespersons,
  Total_amount_with_tax,
  SUM(Total_amount_with_tax) OVER (PARTITION BY Country_region_code, Region ORDER BY Month) AS Cumulative_sum
FROM
  TotalSum
ORDER BY
  Country_region_code,
  Region,
  Month;