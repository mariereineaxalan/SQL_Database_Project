USE msbx5405_finalproject;

-- Twenty Five Select Statements
-- 1. How many distinct product Ids are there for each product type?
SELECT producttype, count(productId)
FROM products
GROUP BY producttype;

-- 2. How many customers spent more than $100 on an order?
SELECT customerId, sum(paymentAmt) as "Total Spent"
FROM orders
GROUP BY customerId
ORDER BY paymentAmt;

-- 3. What customer emails have placed the most orders
SELECT c.custEmail, count(o.orderId) as "number of orders"
FROM orders AS o
JOIN customers AS c
ON o.customerId = c.customerId
GROUP BY o.customerId
ORDER BY count(o.orderId) DESC;

-- 4. What was the average price per unit where productType = Blush?
SELECT prod.producttype, AVG(price.pricePerUnit) as "Average Price"
FROM pricing as price
JOIN products as prod
ON prod.productId = price.productId
GROUP BY prod.producttype;

-- 5. How many customers have delayed orders from each city
select count(c.customerid) as "Total Delayed", o.shippingStatus, c.city
from customers as c 
inner join orders as o on o.customerid = c.customerid 
where o.shippingStatus in (select shippingStatus from returns where shippingStatus= "delayed")
GROUP BY c.city;

-- 6. What is the total revenue for orders placed in January?
Select month(orderdate) as month, sum(paymentamt)
From orders
group by month
having month = 1;

-- 7. What was the total amount paid by payment type?
Select payment_type, sum(payment_amt) as total 
from payments
group by payment_type
order by total DESC;

-- 8. What country had the most orders that weren’t cancelled over $200?
select count(o.orderid) as tot_count, c.countryCode
from country as c
inner join customers as cu on c.countryCode = cu.countryCode
inner join orders as o on o.customerid = cu.customerid
where o.shippingstatus != "Cancelled" and o.paymentamt >= 200
group by  c.countryCode;

-- 9. What is the most frequently ordered product size out of all of the products ordered in July?
select p.productsize,count(o.orderid)
from orders as o 
inner join orderdetails as od on o.orderid = od.orderid 
inner join pricing as p on p.productid = od.productid
group by p.productsize;

-- 10. Out of the customers from country code 20, how many refunded their order?
select c.customerid, o.orderid
from customers as c 
inner join orders as o on o.customerid = c.customerid 
where o.orderid in (select orderid from returns where refundamt >= 20);

-- 11. What sized product container was used the most?
SELECT productSize, count(productSize) as TotalAmt
FROM pricing
GROUP BY productSize
ORDER BY TotalAmt DESC;

-- 12. How many roles with health insurance don't have dental or vision insurance?
SELECT Job_Title, HealthIns, DentalIns, VisionIns
FROM benefits 
WHERE HealthIns = 'Full';

-- 13. Which country has the most costly employees?
Select cou.Name,
	   AVG(emp.hourlyRate) as AverageLaborRate
FROM employees as emp
RIGHT JOIN country as cou 
ON emp.countrycode = cou.countrycode
GROUP BY emp.countryCode
ORDER BY AverageLaborRate DESC;

-- 14. How many Part-time employees making less than $20.00 per hour have FULL benefits?
SELECT COUNT(*) as compensationTest
FROM
(
SELECT emp.employeeId, 
	   emp.firstName,
       emp.lastName,
       emp.hourlyRate,
       pos.Job_Title,
       ben.Job_Type,
       ben.HealthIns,
       ben.DentalIns,
       ben.VisionIns
FROM employees as emp
RIGHT JOIN positions as pos
ON emp.Jobid = pos.Job_id
RIGHT JOIN benefits as ben
ON pos.Job_Title = ben.Job_Title
WHERE ben.Job_Type = 'Part-Time' AND emp.hourlyRate < 20
) as compTest;

-- 15. Which country had the most customers who use warm undertones? 
SELECT  COUNT(proL.underTone) as WarmCount,
		cou.name
FROM country as cou
RIGHT JOIN customers as cus
ON cou.countryCode = cus.countryCode
LEFT JOIN orders as ord
ON cus.customerId = ord.customerId
LEFT JOIN orderDetails as ordd
ON ord.orderId = ordd.orderId
LEFT JOIN products as pro
ON ordd.productID = pro.productID
LEFT JOIN productline as proL
ON pro.colorId = proL.colorId
WHERE proL.underTone = 'Warm'
GROUP BY cou.name
ORDER BY WarmCount DESC;

-- 16. How many employees are not in country code 2-12?
SELECT count(employeeID) as `No. of Employees`
FROM employees
WHERE countryCode NOT IN(2,3,4,5,6,7,8,9,10,11,12);

-- 17. What is the most commonly occurring undertone? 
SELECT 
undertone,
count(undertone) as `Count`
FROM productLine
GROUP BY undertone
ORDER BY count(undertone) DESC;

-- 18. What is the email address of the customer with the highest order amount?
SELECT customerId,custEmail, sum(o.paymentAmt) as TotOrderAmt
FROM customers
JOIN orders as o USING(customerId)
GROUP BY customerId
ORDER BY sum(o.paymentAmt) DESC;

-- 19. How many returns were made in February with an orderDate in January? 
SELECT MONTH(orderDate) as `Month`, count(returnID) as `Returns`
FROM returns
JOIN orders USING(orderId)
WHERE MONTH(orderDate) = 1;

-- 20. What are the highest and lowest salaries we pay for each jobId? If they are the same, you can put the same amount for highest and lowest.
SELECT
RANK() OVER(PARTITION BY jobId Order BY (hourlyRate*52*40) DESC) as Ranking,
jobId,
hourlyRate*52*40 as `SalaryAmt`
FROM employees
WHERE salariedInd = 1;

-- 21.Is there a product that is most frequently returned? If so, which one?
select producttype, count(distinct orderId) 'No. of Orders'
from returns r
join orders o
using (orderId)
join orderdetails od
using (orderId)
join products p
using (productId)
group by producttype
order by `No. of Orders` desc;

-- 22. Which month sees the most sales? Which sees the least? 
select month(orderDate) orderMonth, count(distinct orderId) as 'No. of Orders'
from orders
group by month(orderDate)
order by `No. of Orders` desc;

-- 23. How many orders are showing a shipping status of “Delayed”? Which warehouse has the highest volume of these orders?
with delayed_cte as (
	select distinct orderId, shippingStatus, warehouseId
	from orders o
		join customers c
		using (customerId)
		join warehouse w
		using (countryCode)
	where shippingStatus = 'Delayed'
)
select warehouseId, count(orderId) as 'No. of Orders'
from delayed_cte
group by warehouseId
order by `No. of Orders` desc;

-- 24. What is the proportion of each country’s total orders of the whole order total?
select distinct country.name as 'Country'
, count(orderId) over (partition by country.countryCode) as 'No. of Orders'
, count(orderId) over (partition by country.countryCode) / (select count(distinct orderId) as orders from orders) as 'Proportion of Orders'
from orders o
	join customers c
    using (customerId)
    join country
    using (countryCode);

-- 25. What is the company’s current revenue?
select sum(paymentAmt) as 'Total Revenue'
from orders;

-- Stored Procedures and Functions
-- 26. Stored Procedure
CREATE PROCEDURE Promo @Customer_Id
AS
SELECT Customers.Cust_Address, Customers.City, Customers.postalcode, CountryTable.countryCode WHERE ID = @Custoemr_Id
GO;

-- 27. Stored Function
CREATE FUNCTION CustomerCoupon(
	paymentAmt DECIMAL(10,2)
) 
RETURNS VARCHAR(20)
DETERMINISTIC
BEGIN
    DECLARE customercoupon VARCHAR(20);

    IF paymentAmt >= 75 THEN
		SET customercoupon = '$30 off';
    ELSEIF (paymentAmt >= 50 AND 
			credit < 75) THEN
        SET customercoupon = '$20 off';
    ELSEIF (paymentAmt >= 20 AND 
			paymentAmt < 50)  THEN
        SET customercoupon = '$10 off';
    END IF;
	-- return the customer level
	RETURN (customercoupon);
END$$
DELIMITER ;

-- 28. writing a function that concat mailing information. First name, last name, addres, city, country, and zip code.
delimiter &&
create function mail_info(
custfirstname varchar(45),
custlastname varchar(45),
custaddress varchar(100),
city varchar(50),
countryname varchar(50),
postalcode varchar(15))
returns varchar(100)
deterministic
begin 
declare mail_info varchar(100);
set mail_info = concat(custfirstname,' ',custlastname, ' ', custAddress, ' ', city, ', ', countryname, ' ', postalcode);
return (mail_info);
end &&

DELIMITER $$


-- 29. This trigger records the changes made to the employee table. If an update is made we will record which employee is updated and when so if we need to refer back to this change it is easier to reference.
CREATE TABLE employees_audit (
    id INT AUTO_INCREMENT PRIMARY KEY,
    employeeId INT NOT NULL,
    lastname VARCHAR(50) NOT NULL,
    changedat DATETIME DEFAULT NULL,
    action VARCHAR(50) DEFAULT NULL
);
CREATE TRIGGER employeeupdate_rec 
    BEFORE UPDATE ON employees
    FOR EACH ROW 
 INSERT INTO employees_audit
 SET action = 'update',
     employeeid = employeeid,
     lastname = custlastname,
     changedat = NOW();