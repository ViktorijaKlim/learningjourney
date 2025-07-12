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
  ON salesterritory.TerritoryID = salesorderheader.TerritoryID
GROUP BY
  Month,
  salesterritory.name,
  salesterritory.CountryRegionCode
ORDER BY
  Country_region_code;