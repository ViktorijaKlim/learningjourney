WITH
  latest_address AS (
  SELECT
    CustomerID,
    MAX(AddressID) AS Latest_address_ID
  FROM
    `tc-da-1.adwentureworks_db.customeraddress`
  GROUP BY
    CustomerID ),
  sales_summary AS (
  SELECT
    CustomerID,
    COUNT(SalesOrderID) AS Number_of_orders,
    SUM(TotalDue) AS Total_amount_with_tax,
    MAX(OrderDate) AS Last_order_date
  FROM
    `tc-da-1.adwentureworks_db.salesorderheader`
  GROUP BY
    CustomerID ),
  latest_order_date AS (
  SELECT
    MAX(OrderDate) AS Max_Order_Date
  FROM
    `tc-da-1.adwentureworks_db.salesorderheader` )
SELECT
  customer.CustomerID AS Customer_ID,
  contact.FirstName AS First_name,
  contact.LastName AS Last_name,
  CONCAT(contact.FirstName, ' ', contact.LastName) AS Full_name,
  contact.EmailAddress AS Email,
  contact.Phone AS Phone,
  customer.AccountNumber AS Account_number,
  countryregion.Name AS Country,
  stateprovince.Name AS State,
  sales_summary.Last_order_date,
  ROUND(sales_summary.Total_amount_with_tax, 2) AS Total_amount_with_tax,
  sales_summary.Number_of_orders,
  address.AddressLine1 AS Address_line1,
  SPLIT(address.AddressLine1, ' ')[
OFFSET
  (0)] AS Address_No,
  ARRAY_TO_STRING(ARRAY_SLICE(SPLIT(address.AddressLine1, ' '),
      1,
      100), ' ') AS Address_St
FROM
  `tc-da-1.adwentureworks_db.customer` AS customer
JOIN
  `tc-da-1.adwentureworks_db.individual` AS individual
ON
  customer.CustomerID = individual.CustomerID
JOIN
  `tc-da-1.adwentureworks_db.contact` AS contact
ON
  individual.ContactID = contact.ContactID
JOIN
  latest_address
ON
  customer.CustomerID = latest_address.CustomerID
JOIN
  `tc-da-1.adwentureworks_db.customeraddress` AS customeraddress
ON
  customer.CustomerID = customeraddress.CustomerID
  AND customeraddress.AddressID = latest_address.Latest_address_ID
JOIN
  `tc-da-1.adwentureworks_db.address` AS address
ON
  customeraddress.AddressID = address.AddressID
JOIN
  `tc-da-1.adwentureworks_db.stateprovince` AS stateprovince
ON
  address.StateProvinceID = stateprovince.StateProvinceID
JOIN
  `tc-da-1.adwentureworks_db.countryregion` AS countryregion
ON
  stateprovince.CountryRegionCode = countryregion.CountryRegionCode
JOIN
  latest_order_date
ON
  TRUE
LEFT JOIN
  sales_summary
ON
  customer.CustomerID = sales_summary.CustomerID
WHERE
  customer.CustomerType = 'I'
  AND ( ROUND(sales_summary.Total_amount_with_tax, 2) >= 2500
    OR sales_summary.Number_of_orders >= 5 )
  AND DATE_DIFF(latest_order_date.Max_Order_Date, sales_summary.Last_order_date, DAY) <= 365
  AND countryregion.Name IN ('Canada',
    'Mexico',
    'United States')
ORDER BY
  countryregion.Name,
  stateprovince.Name,
  sales_summary.Last_order_date;