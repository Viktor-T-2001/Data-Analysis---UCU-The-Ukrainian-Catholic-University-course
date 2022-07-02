use AdventureWorksDW2019;

/*
  знайти деталі останнього замовлення (№ замолення, № лінійок, англійська назва продукту, кількість продукту, сума по продукту) 
  кожного клієнта (ід клієнта, повне імя клієнта)
*/
--1
with last_order as (
select row_number() over(partition by CustomerKey 
						 order by OrderDate desc, SalesOrderNumber desc) as rn,
	   SalesOrderNumber
from dbo.FactInternetSales)
select c.CustomerKey,
	   isnull(c.FirstName, '') + ' ' + isnull(c.MiddleName,'') + ' ' + isnull(c.LastName, '') as CustomerName,
       l.SalesOrderNumber,
	   s.SalesOrderLineNumber,
	   p.EnglishProductName,
	   s.OrderQuantity,
	   s.UnitPrice,
	   s.SalesAmount
from last_order as l
join dbo.FactInternetSales as s
	on s.SalesOrderNumber = l.SalesOrderNumber
join dbo.DimCustomer c
	on s.CustomerKey = c.CustomerKey
join dbo.DimProduct p
	on s.ProductKey = p.ProductKey
where l.rn = 1
order by 1, 2, 3, 4;

/*
  знайти агреговані дані (sale amount, дату замовлення, № замовлення) останнього замовлення для кожного реселера (ід, і`мя реселера) 
*/
--2
with last_order as (
select row_number() over(partition by ResellerKey 
						 order by OrderDate desc, SalesOrderNumber desc) as rn,
	   SalesOrderNumber,
	   ResellerKey
from dbo.FactResellerSales)
select l.ResellerKey,
	   r.ResellerName,
       l.SalesOrderNumber,
	   rs.OrderDate,
	   sum(rs.SalesAmount) as SalesAmount
from last_order l
join dbo.FactResellerSales rs
	on rs.SalesOrderNumber = l.SalesOrderNumber
join dbo.DimReseller r
	on r.ResellerKey = l.ResellerKey
where l.rn = 1
group by l.ResellerKey,
	     r.ResellerName,
         l.SalesOrderNumber,
	     rs.OrderDate
order by 1, 2, 3;

/*
  знайти останню операцію по кожному продукту з FactProductInventory
*/
--3
select i.*
from (
	select  row_number() over(partition by productkey order by movementdate desc) as rn,
			ProductKey,
			MovementDate
	from dbo.FactProductInventory
	where UnitsIn <> 0 or UnitsOut <> 0) as l
join dbo.FactProductInventory i
	on i.ProductKey = l.ProductKey
	and i.MovementDate = l.MovementDate
where l.rn = 1
order by i.ProductKey;
/*
  Знайти кількість окремих замовлень згрупованих по країні, року замовлення, типу замовлення де Int - замовлення зробені ч/з інтернет 
  і Res - замовлення реселлера
  (враховуючи країну походження клієнта або країну походження реселера)
*/
--4
select c.* from (
select  g.EnglishCountryRegionName as Country,
		year(s.OrderDate) as "Year",
		'Int' as TypeOrder,
		count(distinct SalesOrderNumber) as OrdersCount
from dbo.FactInternetSales s
join dbo.DimCustomer c
	on c.CustomerKey = s.CustomerKey
join dbo.DimGeography g
	on g.GeographyKey = c.GeographyKey
group by g.EnglishCountryRegionName,
		 year(s.OrderDate)

union all

select  g.EnglishCountryRegionName as Country,
		year(s.OrderDate) as "Year",
		'Res' as TypeOrder,
		count(distinct SalesOrderNumber) as OrdersCount
from dbo.FactResellerSales s
join dbo.DimReseller c
	on c.ResellerKey = s.ResellerKey
join dbo.DimGeography g
	on g.GeographyKey = c.GeographyKey
group by g.EnglishCountryRegionName,
		 year(s.OrderDate) ) as c
order by c.Country, 
		 c."Year",
		 c.TypeOrder;

/*
  Знайти кількість всіх замовлень згрупованих по країні (враховуючи країну походження клієнта або країну походження реселера)
  Повернути дані де назви країни відповідають колонкам
  Включити країни з діменшина географія, в яких не було продажів
*/
--5
with cte as (
select  g.EnglishCountryRegionName as Country,
		'Int' as TypeOrder,
		count(distinct SalesOrderNumber) as OrdersCount
from dbo.FactInternetSales s
join dbo.DimCustomer c
	on c.CustomerKey = s.CustomerKey
join dbo.DimGeography g
	on g.GeographyKey = c.GeographyKey
group by g.EnglishCountryRegionName

union all

select  g.EnglishCountryRegionName as Country,
		'Res' as TypeOrder,
		count(distinct SalesOrderNumber) as OrdersCount
from dbo.FactResellerSales s
join dbo.DimReseller c
	on c.ResellerKey = s.ResellerKey
join dbo.DimGeography g
	on g.GeographyKey = c.GeographyKey
group by g.EnglishCountryRegionName
) 
select *
from cte
pivot( sum(OrdersCount) for [Country] in ([Australia], [Canada], [France], [Germany], [United Kingdom], [United States])) as pv;

/*
  Повернути всі дати від 01012000 до 31122025 не використовуючи таблиць
*/
--6
with Dates as (
	select [Date] = convert(date, '01/01/2012')
	union all
	select [Date] = dateadd(day, 1, [Date])
	from Dates
	where [Date] < '12/31/2025')
select format(d.[Date], 'dd/MM/yyyy') as "Date"
from Dates d
order by d.[Date] asc
option (maxrecursion 5200);
