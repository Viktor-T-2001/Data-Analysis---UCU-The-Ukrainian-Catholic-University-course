use AdventureWorksDW2019;

/*
   Знайти Reseller які зробили покупки, але в яких менше 10 замовлень
   Показати назву Reseller'а, Дату першого та останнього замовлення
*/
select  dr.ResellerName,
		cast(min(fr.OrderDate) as date) as FirstOrderDate, 
		cast(max(fr.OrderDate) as date) as LastOrderDate
from dbo.FactResellerSales fr
join dbo.DimReseller dr
	on dr.ResellerKey = fr.ResellerKey
group by dr.ResellerName, fr.ResellerKey
having count(distinct fr.SalesOrderNumber) < 10;

/*
   Знайти Customers в яких менше 10 інтернет замовлень
   Показати імя, прізвище Customer'а, Дату першого та останнього замовлення
*/
select  c.FirstName,
	    c.LastName,
		cast(min(s.OrderDate) as date) as FirstOrderDate, 
		cast(max(s.OrderDate) as date) as LastOrderDate
from dbo.FactInternetSales s
join dbo.DimCustomer c
	on c.CustomerKey = s.CustomerKey
group by s.CustomerKey, 
		 c.FirstName, 
		 c.LastName
having count(distinct s.SalesOrderNumber) < 10;

/*
   Для Customers з Los Angeles / San Diego - California 
   Вивести повне імя клієнта (прізвище, перша літера імені.) суму кожного інтернет замовлення SalesAmount,
   послідовність цілих чисел за датою замолень і номером замовлень (RN)
   порахувати відсоток від суми поточного замовлення клієнта від попереднього, якщо це перше замлвлення - 100%
   посортувати по RN
*/
with sales_detailed as 
(
select  s.CustomerKey,
		s.OrderDate,
		c.LastName + ' ' + left(c.FirstName, 1) + '.' as CustomerName,
		s.SalesOrderNumber,
		sum(s.SalesAmount) as SalesAmount
from dbo.FactInternetSales s
join dbo.DimCustomer c
	on s.CustomerKey = c.CustomerKey
join dbo.DimGeography g
	on g.GeographyKey = c.GeographyKey
where g.CountryRegionCode = 'US'
	  and g.StateProvinceName = 'California'
	  and ( g.City = 'Los Angeles' or g.City = 'San Diego' )
group by s.CustomerKey, 
		 s.OrderDate,
		 c.LastName + ' ' + left(c.FirstName, 1) + '.', 
		 s.SalesOrderNumber
)

select row_number() over(partition by s.CustomerKey
						 order by s.OrderDate asc, s.SalesOrderNumber asc) as rn,
	   s.CustomerKey,
	   s.CustomerName,
	   s.SalesAmount,
	   coalesce( 100 * s.SalesAmount / lag(s.SalesAmount) 
	       over(partition by s.CustomerKey
		   order by s.OrderDate asc, s.SalesOrderNumber asc), 100) as "PercentPrev"
from sales_detailed as s;

/*
  агрегувати дані для employee про продаж Reseller'ам. просумувати SalesAmount в TotalAmount та порахувати ксть опрацьованих замовлень
*/
select  EmployeeKey,
		count(distinct SalesOrderNumber) as NumOfOrders, 
		sum(SalesAmount) as TotalAmount
from dbo.FactResellerSales
group by EmployeeKey
order by TotalAmount desc;

/*
  Агрегувати Дані про дзвікни в кол центр за 2014 рік по року та по місяцях. (набори групування)
  Дані, що потрібно агрегувати у колонках: Calls,	AutomaticResponses,	Orders,	IssuesRaised,	AverageTimePerIssue
  повернути суму і середні значення.
*/
select  year("Date")				as "Year", 
		month("Date")				as "Month",
		sum(Calls)					as Sum_Calls,	
		avg(Calls)					as Avg_Calls,	
		sum(AutomaticResponses)		as Sum_AutomaticResponses,	
		avg(AutomaticResponses)		as Avg_AutomaticResponses,	
		sum(Orders)					as Sum_Orders,	
		avg(Orders)					as Avg_Orders,	
		sum(IssuesRaised)			as Sum_IssuesRaised,
		avg(IssuesRaised)			as Avg_IssuesRaised,	
		sum(AverageTimePerIssue)	as Sum_AverageTimePerIssue,
		avg(AverageTimePerIssue)	as Avg_AverageTimePerIssue
from dbo.FactCallCenter
where year("Date") = 2014
group by year("Date"), 
		 month("Date");

/*
  Отримати дані про замовлення (ProductKey, OrderDateKey, CustomerKey, SalesOrderNumber, SalesOrderLineNumber, OrderQuantity) з   FactInternetSales 
  колонку SalesAmount повернути в американських доларах (по рейтингу на кінець робочого дня (в день продажу))
*/
select  s.ProductKey, 
		s.OrderDateKey, 
		s.CustomerKey, 
		s.SalesOrderNumber, 
		s.SalesOrderLineNumber, 
		s.OrderQuantity,
		s.SalesAmount * cur.EndOfDayRate as SalesAmount
from dbo.FactInternetSales s
join dbo.FactCurrencyRate cur
	on cur.CurrencyKey = s.CurrencyKey
	and s.OrderDate = cur."Date"

/*
  Інформацію про продажі (кількість замовлень, загальна сума за місяць в канадських $) за місяць для Employee (EmployeeKey, FirstName, 
  LastName, Title)
*/
with cte_sales_USD as 
(
select s.OrderDate,
	   s.EmployeeKey,
	   s.SalesOrderNumber,
	   s.SalesAmount * cur.EndOfDayRate as SalesAmountUSD
from dbo.FactResellerSales s
join dbo.FactCurrencyRate cur
	on cur.CurrencyKey = s.CurrencyKey
	and s.OrderDate = cur."Date" 
)
select  year(s.OrderDate) as "Year",
		month(s.OrderDate) as "Month",
		s.EmployeeKey,
		e.FirstName,
		e.LastName,
		e.Title,
		count(distinct s.SalesOrderNumber) as NumOfOrders,
		sum(s.SalesAmountUSD / cur.EndOfDayRate) as SalesAmountCAD
from cte_sales_USD s
join dbo.FactCurrencyRate cur
	on s.OrderDate = cur."Date"
	and cur.CurrencyKey = 19
join dbo.DimEmployee e
	on e.EmployeeKey = s.EmployeeKey
group by year(s.OrderDate),
		month(s.OrderDate),
		s.EmployeeKey,
		e.FirstName,
		e.LastName,
		e.Title
order by "Year" asc, 
		 "Month" asc, 
		 NumOfOrders desc;

/*
  Знайти перших Customer'ів (за датою покупки) - повернути ключ Customer`ів
*/
select CustomerKey
from dbo.FactInternetSales
where OrderDate = ( select min(OrderDate)
					from dbo.FactInternetSales )
order by CustomerKey;

select top 10 CustomerKey
from dbo.FactInternetSales
order by OrderDate asc, CustomerKey;

/*
  Знайти кількість працівників які підпорядковуються кожному менеджеру. Повернути ІД менеджера, кількість працівників
*/
select ParentEmployeeKey as ManagerId,
	   count(EmployeeKey) as NumOfEmpl
from dbo.DimEmployee
where ParentEmployeeKey is not null
group by ParentEmployeeKey
order by NumOfEmpl desc;

/*
  Зробити рангування для інтернет замовлень по Номеру замовлення
*/
select  dense_rank() over(order by fs.SalesOrderNumber asc) as rn,
		fs.*
from dbo.FactInternetSales fs
order by rn;
