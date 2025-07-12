SELECT
  Salesorderheader.SalesOrderID,
  Product.Name AS product_name,
  ProductCategory.Name AS category,
  ProductSubcategory.Name AS subcategory,
  Salesorderdetail.LineTotal,
  Salesorderdetail.OrderQty,
  Salesorderdetail.UnitPrice
FROM
  tc-da-1.adwentureworks_db.salesorderdetail AS Salesorderdetail
JOIN
  tc-da-1.adwentureworks_db.product AS Product
  ON Salesorderdetail.ProductID = Product.ProductID
JOIN
  tc-da-1.adwentureworks_db.salesorderheader AS Salesorderheader
  ON Salesorderdetail.SalesOrderID = Salesorderheader.SalesOrderID
LEFT JOIN
  tc-da-1.adwentureworks_db.productsubcategory AS ProductSubcategory
  ON Product.ProductSubcategoryID = ProductSubcategory.ProductSubcategoryID
LEFT JOIN
  tc-da-1.adwentureworks_db.productcategory AS ProductCategory
  ON ProductSubcategory.ProductCategoryID = ProductCategory.ProductCategoryID