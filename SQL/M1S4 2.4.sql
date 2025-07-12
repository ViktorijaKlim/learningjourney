WITH
  ProvinceMaxTax AS (
  SELECT
    stateprovince.CountryRegionCode,
    stateprovince.StateProvinceID,
    MAX(salestaxrate.TaxRate) AS Max_tax_rate
  FROM
    `tc-da-1.adwentureworks_db.salestaxrate` AS salestaxrate
  JOIN
    `tc-da-1.adwentureworks_db.stateprovince` AS stateprovince
  ON
    salestaxrate.StateProvinceID = stateprovince.StateProvinceID
  GROUP BY
    stateprovince.CountryRegionCode,
    stateprovince.StateProvinceID ),
  MeanTaxRate AS (
  SELECT
    CountryRegionCode,
    AVG(Max_tax_rate) AS Mean_tax_rate,
    COUNT(*) AS Provinces_with_tax
  FROM
    ProvinceMaxTax
  GROUP BY
    CountryRegionCode ),
  AllProvinces AS (
  SELECT
    CountryRegionCode,
    COUNT(*) AS total_provinces
  FROM
    `tc-da-1.adwentureworks_db.stateprovince`
  GROUP BY
    CountryRegionCode ),
  CountryTaxSummary AS (
  SELECT
    MeanTaxRate.CountryRegionCode,
    ROUND(MeanTaxRate.Mean_tax_rate, 2) AS Mean_tax_rate,
    ROUND(SAFE_DIVIDE(MeanTaxRate.Provinces_with_tax, AllProvinces.total_provinces), 2) AS Perc_provinces_w_tax
  FROM
    MeanTaxRate
  JOIN
    AllProvinces
  ON
    MeanTaxRate.CountryRegionCode = AllProvinces.CountryRegionCode ),
  MonthlySales AS (
  SELECT
    LAST_DAY(CAST(OrderDate AS DATE), MONTH) AS Month,
    salesterritory.CountryRegionCode AS Country_region_code,
    salesterritory.Name AS Region,
    COUNT(salesorderheader.SalesOrderID) AS Number_of_orders,
    COUNT(DISTINCT salesorderheader.CustomerID) AS Number_of_customers,
    COUNT(DISTINCT salesorderheader.SalesPersonID) AS Number_of_salespersons,
    CAST(SUM(salesorderheader.TotalDue) AS INT64) AS Total_amount_with_tax
  FROM
    `tc-da-1.adwentureworks_db.salesorderheader` AS salesorderheader
  JOIN
    `tc-da-1.adwentureworks_db.salesterritory` AS salesterritory
  ON
    salesorderheader.TerritoryID = salesterritory.TerritoryID
  GROUP BY
    Month,
    salesterritory.Name,
    salesterritory.CountryRegionCode )
SELECT
  MonthlySales.Month,
  MonthlySales.Country_region_code,
  MonthlySales.Region,
  MonthlySales.Number_of_orders,
  MonthlySales.Number_of_customers,
  MonthlySales.Number_of_salespersons,
  MonthlySales.Total_amount_with_tax,
  SUM(MonthlySales.Total_amount_with_tax) OVER (PARTITION BY MonthlySales.Country_region_code ORDER BY MonthlySales.Month) AS Cumulative_Sum,
  CountryTaxSummary.mean_tax_rate,
  CountryTaxSummary.perc_provinces_w_tax
FROM
  MonthlySales
LEFT JOIN
  CountryTaxSummary
ON
  MonthlySales.Country_region_code = CountryTaxSummary.CountryRegionCode
ORDER BY
  Country_region_code,
  Month;