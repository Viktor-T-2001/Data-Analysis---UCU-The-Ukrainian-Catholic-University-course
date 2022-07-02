use AdventureWorksDW2019;

/*
  Повернути продукти які продавалися через інтернет, але не продавалися reseller'ам
*/
--1

select  distinct 
		s.ProductKey, 
		p.EnglishProductName
from dbo.FactInternetSales s
join dbo.DimProduct p
	on p.ProductKey = s.ProductKey
left join (
	select ProductKey
	from dbo.FactResellerSales
	) as a
	on a.ProductKey = s.ProductKey
where a.ProductKey is null;

/*
  Повернути деталі про продукти які не продавалися через інтернет і не продавалися reseller'ам
  а також кількість цих продуктів на складі з FactProductInventory (останній запис)
*/
--2

select  p.ProductKey, 
		p.EnglishProductName,
		i.UnitsBalance
from dbo.DimProduct p
left join (
		select  row_number() over(  partition by ProductKey 
									order by DateKey desc ) as rn,
				ProductKey, 
				UnitsBalance 
		from dbo.FactProductInventory
		) as i
	on i.ProductKey = p.ProductKey
	and i.rn = 1
where p.ProductKey not in (
	select ProductKey 
	from dbo.FactInternetSales
	union
	select ProductKey
	from dbo.FactResellerSales)
order by p.ProductKey;

/*
  для кожного продукту повернути загальну кількість проданих одиниць
*/
--3

select  p.ProductKey, 
		p.EnglishProductName,
		isnull(sum(s.QuantitySales), 0) as QuantitySales
from dbo.DimProduct p
left join (
select  ProductKey, 
		sum(OrderQuantity) as QuantitySales
from dbo.FactInternetSales
group by ProductKey

union all

select  ProductKey,
		sum(OrderQuantity) as QuantitySales
from dbo.FactResellerSales
group by ProductKey
) as s
	on s.ProductKey = p.ProductKey
group by p.ProductKey, 
		 p.EnglishProductName
order by QuantitySales desc;

/*
   за кожень день травня 2014 року знайти сумарну кількість дзвінків (calls) прийнятих в колцентрі кількість інтернет продажів, кількість продажів реселерам, 
*/
--4

with Dates_May as (
	select [Date] = convert(date, '05/01/2014')
	union all
	select [Date] = dateadd(day, 1, [Date])
	from Dates_May
	where [Date] < '05/31/2014'
)

select d.[Date],
	   isnull(c.Calls, 0) as Calls,
	   isnull(si.SalesAmount, 0) as InternetSalesAmount,
	   isnull(sr.SalesAmount, 0) as ReselelrSalesAmount
from Dates_May d

left join (
	select  [Date], 
			sum(Calls) as Calls
	from dbo.FactCallCenter
	where   year([Date]) = 2014
			and month([Date]) = 5
	group by [Date]
	) as c
	on d.[Date] = convert(date, c.[Date])

left join (
	select  OrderDate, 
			sum(SalesAmount) as SalesAmount
	from dbo.FactInternetSales
	where   year(OrderDate) = 2014
			and month(OrderDate) = 5
	group by OrderDate
	) as si
	on d.[Date] = convert(date, si.OrderDate)

left join (
	select  OrderDate, 
			sum(SalesAmount) as SalesAmount
	from dbo.FactResellerSales
	where   year(OrderDate) = 2014
			and month(OrderDate) = 5
	group by OrderDate
	) as sr
	on d.[Date] = convert(date, sr.OrderDate)

order by d.[Date] asc
option (maxrecursion 31);

/*
  Знайти всі дати, в які не проводилися опрацювання продажів для Reseller'ів
  Повернути лише дати між першою і останньою операцією в історії
*/
--5

begin 

declare @Date_start date = (select min(OrderDate) from dbo.FactResellerSales);
declare @Date_end date = (select max(OrderDate) from dbo.FactResellerSales);

with Dates as (
	select [Date] = convert(date, @Date_start)
	union all
	select [Date] = dateadd(day, 1, [Date])
	from Dates
	where [Date] < @Date_end
)

select d.[Date]
from Dates d
where d.[Date] not in ( select distinct convert(date, OrderDate)
						from dbo.FactResellerSales)
order by d.[Date] asc
option (maxrecursion 1500);

end;

/*
  Для всіх днів 1-3 фіскального кварталу 2012 року поверну:
  Quarter: формату 'Q1 2012'  
  Date: dd/MM/yyyy
  InternetSales: кількість замовлень
  ResellerSales: кількість замовлень
*/
--6

with Dates as (
	select [Date] = convert(date, '01/01/2012')
	union all
	select [Date] = dateadd(day, 1, [Date])
	from Dates
	where [Date] < '09/30/2012'
)

select 'Q' + convert(char(1), datepart(quarter, d.[Date])) + 
	   ' ' + convert(char(4), format(d.[Date], 'yyyy')) as Quarter,
	   format(d.[Date], 'dd/MM/yyyy'),
	   isnull(si.OrdersQuant, 0) as InternetSales,
	   isnull(sr.OrdersQuant, 0) as ResellerSales
from Dates d

left join (
	select  OrderDate, 
			count(*) as OrdersQuant
	from dbo.FactInternetSales
	where   year(OrderDate) = 2012
			and month(OrderDate) between 1 and 9
	group by OrderDate
	) as si
	on d.[Date] = convert(date, si.OrderDate)

left join (
	select  OrderDate, 
			count(*) as OrdersQuant
	from dbo.FactResellerSales
	where   year(OrderDate) = 2012
			and month(OrderDate) between 1 and 9
	group by OrderDate
	) as sr
	on d.[Date] = convert(date, sr.OrderDate)

order by d.[Date] asc
option (maxrecursion 300);

/*
  Знайти середню кількість опрацьованих інтернет замовлень в місяць (за календарними днями) за всю історії існування мережі.
*/
--7

select  s."Month",
		avg(s.NumOfOrders) as AvgNumOfOrders
from (
select  year(OrderDate) as "Year",
		month(OrderDate) as "Month",
		count(*) as NumOfOrders
from dbo.FactInternetSales
group by year(OrderDate),
		 month(OrderDate) 
) as s
group by s."Month"
order by s."Month" asc;

/*
  Повернути назву категорії, назву субкатегорії (іспанською), категорію продажів - кількість товарів проданих через інтернет магазин - 
  якщо <1000 - 'I', >=1000 < 3000 -  'II', більше - 'ІІІ', інші - 'NA' 
*/
--8

select  cat1.SpanishProductCategoryName,
		cat2.SpanishProductSubcategoryName,
		case when sum(SalesQuant) < 1000 then 'I'
			 when sum(SalesQuant) < 3000 then 'II'
			 when sum(SalesQuant) >= 3000 then 'III'
			 else 'NA'
		end as InternetSalesCategory
from dbo.DimProduct p
left join (
	select  ProductKey,	
			sum(OrderQuantity) as SalesQuant
	from dbo.FactInternetSales
	group by ProductKey
	) as a
	on a.ProductKey = p.ProductKey
join dbo.DimProductSubcategory cat2
	on p.ProductSubcategoryKey = cat2.ProductSubcategoryKey
join dbo.DimProductCategory cat1
	on cat1.ProductCategoryKey = cat2.ProductCategoryKey
group by cat1.SpanishProductCategoryName,
		 cat2.SpanishProductSubcategoryName;

/*
  Продукти які продавалися (інтернет і перекупам) у 2012 році, але не продавалися у 2013
*/
--9

with sales_2013 as (

	select  ProductKey 
	from dbo.FactInternetSales
	where year(OrderDate) = 2013

	union 

	select  ProductKey 
	from dbo.FactResellerSales
	where year(OrderDate) = 2013
),
sales_2012_not_2013 as (

select ProductKey 
from dbo.FactInternetSales
where ProductKey not in (select ProductKey
						from sales_2013)
	  and year(OrderDate) = 2012

union

select ProductKey 
from dbo.FactResellerSales
where ProductKey not in (select ProductKey
						from sales_2013)
	  and year(OrderDate) = 2012
)
select s.ProductKey,
	   p.EnglishProductName
from sales_2012_not_2013 s
join dbo.DimProduct p
	on p.ProductKey = s.ProductKey
order by s.ProductKey;

/*
  Знайти менеджерів підопічні яких зробили більше 50 індивідуальних продажів на рік
*/
--10

select m.ParentEmployeeKey,
	   mm.LastName,	
	   mm.FirstName,
	   mm.Title,
	   sum(case when s.EmployeeKey is not null 
	       then 1 else 0 end) as NumOfOrders
from (	
	select  distinct 
			m.ParentEmployeeKey,
			e.EmployeeKey	
	from dbo.DimEmployee m
	join dbo.DimEmployee e
		on e.ParentEmployeeKey = m.ParentEmployeeKey 
	) as m
join dbo.FactResellerSales s
	on s.EmployeeKey = m.EmployeeKey
	and year(s.OrderDate) = 2012
join dbo.DimEmployee mm
	on mm.EmployeeKey = m.ParentEmployeeKey
group by m.ParentEmployeeKey,
		 mm.LastName,	
	     mm.FirstName,
	     mm.Title
having sum(case when s.EmployeeKey is not null 
		   then 1 else 0 end) > 50;
