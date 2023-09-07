use Northwind

/*
For each order, calculate a subtotal for each Order (identified by OrderID). This is a simple query using GROUP BY to aggregate data for each order.

--*1. Show the first name, last name and telephone number for all the employees, except those who live in UK.*--

select FirstName, LastName, HomePhone
from employees
where Country != 'UK';

--*2. Show all product details for products whose unit price is greater than $10 and quantity in stock greater than 2. Sort by product price.*--

select *
from Products
where UnitPrice > 10 and UnitsInStock > 2
order by UnitPrice;


--*3. Show the first name, last name and telephone number for the employees who started working in the company in 1992-1993.*--

select FirstName, LastName, HomePhone
from Employees
where HireDate >= '1992-01-01' and HireDate <= '1993-12-31';

--*4. Show the product name, Company name of the supplier and stock quantity of the products that have 15 or more items in stock and the Product name starts with B or C or M.*--

select ProductName, CompanyName, UnitsInStock, ProductName
from Products p inner join Suppliers s on p.SupplierID = s.SupplierID
where UnitsInStock >= 15 and (LEFT(ProductName, 1) = 'B' or LEFT(ProductName, 1) = 'C' or LEFT(ProductName, 1) = 'M');

--*5. Show all details for products whose Category Name is ' Meat/Poultry ' Or 'Dairy Products '. Sort them by product name.*--

select *
from Products p inner join Categories c on p.CategoryID = c.CategoryID
where CategoryName = 'Meat/Poultry' or CategoryName = 'Dairy Products'

--*6. Show Category name, Product name and profit for each product (how much money the company will earn if they sell all the units in stock). Sort by the profit.*--

select CategoryName, ProductName, UnitPrice * UnitsInStock
from Products p inner join Categories c on p.CategoryID = c.CategoryID
order by UnitPrice * UnitsInStock

--*7. Show the Employees' first name, last name and Category Name of the products which they have sold (show each category once).*--

select FirstName, LastName, CategoryName
from Employees e inner join Orders o on e.EmployeeID = o.EmployeeID
inner join [Order Details] od on o.OrderID = od.OrderID
inner join Products p on p.ProductID = od.ProductID
inner join Categories c on c.CategoryID = p.CategoryID
group by FirstName, LastName, c.CategoryName;

--*8. Show the first name, last name, telephone number and date of birth for the employees who are aged older than 35. Order them by last name in descending order.*--

select FirstName, LastName, HomePhone, BirthDate
from Employees
where BirthDate > 35
order by LastName desc;

--*9. Show each employee’s name, the product name for the products that he has sold and quantity that he has sold.*--

select FirstName, LastName, ProductName, Quantity
from Employees e inner join Orders o on e.EmployeeID = o.EmployeeID
inner join [Order Details] od on o.OrderID = od.OrderID and Quantity = od.Quantity
inner join Products p on od.ProductID = p.ProductID and ProductName = p.ProductName;

--*10. Show for each order item – the customer name and order id, product name, ordered quantity, product price and total price (Ordered quantity * product price) and gap between ordered date and shipped date (the gap in days). Order by order id.*--

select ContactName, o.OrderID, ProductName, Quantity, od.UnitPrice,[Total Price] = Quantity * od.UnitPrice,[Shipping Gap] =  ShippedDate - OrderDate
from Orders o inner join [Order Details] od on o.OrderID = od.OrderID
inner join Customers c on o.CustomerID = c.CustomerID 
inner join Products p on od.ProductID = p.ProductID
order by o.OrderID;

--*11. How much each customer paid for all the orders he had committed together?*--

select c.CustomerID, Payments = sum(UnitPrice*Quantity)
from Customers c inner join Orders o on c.CustomerID = o.CustomerID
inner join [Order Details] od on o.OrderID = od.OrderID
group by c.CustomerID;

--*12. In which order numbers was the ordered quantity greater than 10% of the quantity in stock?*--

select OrderID
from [Order Details] od inner join Products p on od.ProductID = p.ProductID
where Quantity > UnitsInStock * 1.1;

--*13. Show how many Employees live in each country and their average age.*--

select Country, [Count] = count(*), [Average Age] = year(GETDATE()) - avg(year(BirthDate))
from Employees
group by Country;

--*14. What would be the discount for all the London customers (together), if after 5 days of gap between the order date and shipping date they get a 5% discount per item they bought?*--

select sum(Discount + 0.05)
from [Order Details] od inner join Orders o on od.OrderID = o.OrderID
inner join Customers c on o.CustomerID = c.CustomerID
where day(OrderDate - ShippedDate) > 5 and City = 'london';

--*15. Show the product id, name, stock quantity, price and total value (product price * stock quantity) for products whose total bought quantity is greater than 500 items.*--

select p.ProductID, ProductName, UnitsInStock, p.UnitPrice, [Total Value] = (p.UnitPrice * UnitsInStock)
from Products p inner join [Order Details] od on p.ProductID = od.ProductID
where p.ProductID = od.ProductID 
group by p.ProductID, p.ProductName, p.UnitsInStock, p.UnitPrice
having sum(od.Quantity) > 500;

--*16. For each employee display the total price paid on all of his orders that hasn’t shipped yet.*--

select FirstName, LastName, [Unshipped Products Value] = SUM((Quantity * od.UnitPrice) * (1-Discount))
from Employees e inner join Orders o on e.EmployeeID = o.EmployeeID
inner join [Order Details] od on o.OrderID = od.OrderID
where ShippedDate is null or GETDATE() < ShippedDate
group by FirstName, LastName;

--*17. For each category display the total sales revenue, every year.*--

select [Year] = year(OrderDate), CategoryName, [Products Sold] = sum(Quantity + od.Quantity)
from Orders o inner join [Order Details] od on o.OrderID = od.OrderID
inner join Products p on od.ProductID = p.ProductID
inner join Categories c on p.CategoryID = c.CategoryID
group by YEAR(OrderDate), CategoryName
order by Year;

--*18. Which Product is the most popular? (number of items)*--

select top 1  ProductName, [Most Purchased] = sum(Quantity)
from Products p inner join [Order Details] od on p.ProductID = od.ProductID
group by p.ProductName
order by [Most Purchased] desc;


--*19. Which Product is the most profitable? (income)*--

select top 1  ProductName, [Most Purchased] = sum(Quantity * od.UnitPrice * (1 - Discount))
from Products p inner join [Order Details] od on p.ProductID = od.ProductID
group by p.ProductName
order by [Most Purchased] desc;

--*20. Display products that their price higher than the average price of their Category.*--

select ProductName
from Products
where UnitPrice > (select AVG(UnitPrice) from Products pr where CategoryID = CategoryID)

--*21. For each city (in which our customers live), display the yearly income average.*--

select City, [Year] = year(o.OrderDate), Average = avg((od.UnitPrice * od.Quantity) * (1+od.Discount))
from Customers c inner join Orders o on c.CustomerID = o.CustomerID
inner join [Order Details] od on o.OrderID = od.OrderID
group by City, year(o.OrderDate)
order by City;

--*22. For each month display the average sales in the same month all over the years.*--

select [Month] = month(OrderDate), [Average Sales] = AVG((Quantity * UnitPrice) * ( 1 - Discount))
from Orders o inner join [Order Details] od on o.OrderID = od.OrderID
where MONTH(OrderDate) = MONTH(OrderDate)
group by MONTH(OrderDate)



--*23. Display a list of products and OrderID of the largest order ever placed for each product.*--

select p.ProductName, OrderID
from [Order Details] od inner join Products p on od.ProductID = p.ProductID
where od.Quantity = (select Max(Quantity)
					 from [Order Details] od1
					 where od1.ProductID = od.ProductID)
*/

/*select year(o.OrderDate), Highest = sum(Quantity)
from [Order Details] od 
inner join orders o on od.OrderID = o.OrderID 
group by year(o.OrderDate)*/


/*select *
from  
	(select year(o1.OrderDate), c1.CustomerID, sum(od1.Quantity) as sumOFQuantity
	from Customers c1
	inner join Orders o1 on c1.CustomerID = o1.CustomerID
	inner join [Order Details] od1 on o1.OrderID = od1.OrderID
	group by year(o1.OrderDate), c1.CustomerID)*/
	
	
	
	
	/*
select o.CustomerID, year(o.OrderDate)
from Orders o inner join
(select year(o1.OrderDate) as yearO, c1.CustomerID, sum(od1.Quantity) as sumOFQuantity
from Customers c1
inner join Orders o1 on c1.CustomerID = o1.CustomerID
inner join [Order Details] od1 on o1.OrderID = od1.OrderID
group by year(o1.OrderDate), c1.CustomerID) as newT on o.CustomerID = newT.CustomerID
where newT.sumOFQuantity >= 
(select sum(od2.Quantity) as sumOFQuantity
	from Customers c2
	inner join Orders o2 on c2.CustomerID = o2.CustomerID
	inner join [Order Details] od2 on o2.OrderID = od2.OrderID
	where year(o2.OrderDate) = year(newT.yearO)
	group by year(o2.OrderDate), c2.CustomerID 
)
group by year(o.OrderDate), o.CustomerID



select newT.CustomerID, newT.yearO
from 
(select year(o1.OrderDate) as yearO, c1.CustomerID, sum(od1.Quantity) as sumOFQuantity
from Customers c1
inner join Orders o1 on c1.CustomerID = o1.CustomerID
inner join [Order Details] od1 on o1.OrderID = od1.OrderID
group by year(o1.OrderDate), c1.CustomerID) as newT
where newT.sumOFQuantity >= 
all(select innerT.sumOFQuantity
	from 
		(select year(o2.OrderDate) as yearO, c2.CustomerID, sum(od2.Quantity) as sumOFQuantity
		from Customers c2
		inner join Orders o2 on c2.CustomerID = o2.CustomerID
		inner join [Order Details] od2 on o2.OrderID = od2.OrderID
	group by year(o2.OrderDate), c2.CustomerID) as innerT
	where innerT.yearO = newT.yearO
	group by innerT.yearO, innerT.CustomerID, innerT.sumOFQuantity)
	*/



