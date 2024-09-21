create database project;

use project;

create table cus_purchase(
transactionid int Primary key,
customerid int,
customername varchar(100),
productid int,
productname varchar(100),
productcategory varchar(100),
purchasequantity int,
purchaseprice float,
purchasedate DATE,
country varchar(100)
);
select * from cus_purchase;

Load data infile 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/customer_purchase_data.csv'
into table cus_purchase
fields terminated by ','
lines terminated by '\n'
ignore 1 lines
(transactionid ,customerid ,customername ,productid ,productname,productcategory ,purchasequantity ,purchaseprice ,purchasedate ,country 
);

-- Customers table with new primary key
CREATE TABLE customers (
    customerPK INT PRIMARY KEY,
    customerid INT,
    customername VARCHAR(100),
    country VARCHAR(100)
);

-- Products table with new primary key
CREATE TABLE Products (
    productPK INT PRIMARY KEY,
    productid INT,
    customerid int,
    productname VARCHAR(100),
    productcategory VARCHAR(100)
);

-- Transactions table referencing new primary keys
CREATE TABLE purchases (
	pruchasespk int auto_increment  primary key,
    transactionid INT,
    customerPK INT,
    productPK INT,
    customerid int,
    productid int,
    purchasequantity INT,
    purchaseprice FLOAT,
    purchasedate DATE,
	FOREIGN KEY (CustomerPK) REFERENCES Customers(CustomerPK),
    FOREIGN KEY (ProductPK) REFERENCES Products(ProductPK)
);
drop table purchase1

-- Insert data into Customers table
INSERT INTO customers (customerPK, customerid, customername, country)
SELECT 
    ROW_NUMBER() OVER (ORDER BY customerid) AS customerPK,
    customerid,
    customername,
    country
FROM (
    SELECT DISTINCT customerid, customername, country
    FROM cus_purchase
) AS distinct_customers;

select * from customers;

-- Insert data into Products table
INSERT INTO products (productPK, productid, customerid, productname, productcategory)
SELECT 
    ROW_NUMBER() OVER (ORDER BY productid) AS productPK,
    productid,
    customerid,
    productname,
    productcategory
FROM (
    SELECT DISTINCT productid, customerid, productname, productcategory
    FROM cus_purchase
) AS distinct_products;

select * from products;

-- Insert data into purchases table
INSERT INTO purchases (transactionid, customerPK, ProductPK, customerid, productid, purchasequantity, purchaseprice, purchasedate)
SELECT 
    transactionid,
    c.customerPK,
    p.productPK,
    c.customerid,
    p.productid,
    purchasequantity,
    purchaseprice,
    purchasedate
FROM cus_purchase cp
 JOIN customers c ON cp.customerid = c.customerid
 JOIN products p ON cp.productid = p.productid;
 


select * from purchases;

-- 1. total no of purchases per customer
select c.customerid, c.customername, sum(pc.purchasequantity) as tot_purchases
from customers as c
join purchases as pc
on c.customerpk = pc.customerpk
group by c.customerid, c.customername
order by tot_purchases desc;

-- 2. total sales(purchasequantity) per product
select p.productid, p.productname, sum(pc.purchasequantity) as tot_saless
from products as p
join purchases as pc
on p.productpk = pc.productpk
group by p.productid, p.productname
order by tot_saless desc;

-- 3. total saleprice for each productcategory in 2023 
select p.productcategory, sum(pc.purchaseprice) as sale_price
from products as p
join purchases as pc
on p.productpk = pc.productpk
where year(PurchaseDate) = '2023'
group by productcategory
order by sale_price desc;

-- 4. total sales of customers from each country
select c.customerid, c.customername,c.country,  sum(pc.purchasequantity) as sales
from customers as c
join purchases as pc
on c.customerpk = pc.customerpk
group by c.customerid, c.customername, c.country
order by sales desc, c.country asc ;

-- 5.filter productcategory with total purchaseprice > 500 
select p. productname, p.productcategory, pc.purchaseprice 
from products as p
join purchases as pc
on p.productpk = pc.productpk
having pc.purchaseprice  > '500'
order by pc.purchaseprice  desc, p.productcategory asc ;


select * from purchases
where customerid is null;


SELECT customerpk, productpk, customerid, productid, count(*) FROM purchases
GROUP BY customerpk, productpk, customerid, productid
having count(*) >1;
