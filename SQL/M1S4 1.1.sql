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
    CustomerID )
SELECT
  customer.CustomerID AS Customer_ID,
  contact.FirstName AS First_name,
  contact.LastName AS Last_name,
  CONCAT(contact.FirstName, ' ', contact.LastName) AS Full_name,
  CASE
    WHEN contact.Title IS NOT NULL THEN CONCAT(contact.Title, ' ', contact.LastName)
    ELSE CONCAT('Dear ', contact.LastName)
END
  AS Addressing_Title,
  contact.EmailAddress AS Email,
  contact.Phone AS Phone,
  customer.AccountNumber AS Account_number,
  customer.CustomerType AS Customer_type,
  address.City AS City,
  stateprovince.Name AS State,
  countryregion.Name AS Country,
  address.AddressLine1 AS Address,
  address.AddressLine2 AS Address_line2,
  sales_summary.Number_of_orders,
  ROUND(sales_summary.Total_amount_with_tax, 3) AS Total_amount_with_tax,
  sales_summary.Last_order_date
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
LEFT JOIN
  sales_summary
ON
  customer.CustomerID = sales_summary.CustomerID
WHERE
  customer.CustomerType = 'I'
ORDER BY
  Total_amount_with_tax DESC
LIMIT
  200;