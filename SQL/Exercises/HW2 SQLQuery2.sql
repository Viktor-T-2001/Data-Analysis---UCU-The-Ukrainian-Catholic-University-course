/*
  Витягнути SalesOrderNumber, SalesOrderLineNumber, ResellerKey, ProductKey, OrderQuantity, SalesAmount для продажів (ResellerSaler) 
  2011 року  Посортувати від новіших до старших замовлень. Результат має завжди повертатися однаковим.
*/
--1
select  SalesOrderNumber, 
		SalesOrderLineNumber, 
		ResellerKey, 
		ProductKey, 
		OrderQuantity, 
		SalesAmount
from dbo.FactResellerSales
where year(OrderDate) = 2011
order by OrderDate desc;

/*
  Витягнути SalesOrderNumber, SalesOrderLineNumber, ResellerKey, ProductKey, OrderQuantity, SalesAmount для продажів (ResellerSaler) 
  здійснених в грудні 2012
  Посортувати від новіших до старших замовлень. Результат має завжди повертатися однаковим.
*/
--2
select  SalesOrderNumber, 
		SalesOrderLineNumber, 
		ResellerKey, 
		ProductKey, 
		OrderQuantity, 
		SalesAmount
from dbo.FactResellerSales
where	year(OrderDate) = 2012
		and month(OrderDate) = 12
order by OrderDate desc, 
		 SalesOrderNumber desc, 
		 SalesOrderLineNumber asc;

/*
  Отримати SalesOrderNumber, SalesOrderLineNumber, ResellerKey, ProductName, OrderQuantity, SalesAmount для продажів (ResellerSaler) 
  здійснених в жовтні 2013.
  Де ProductName це англійська назва продукту.
  Посортувати від новіших до старших замовлень. Результат має завжди повертатися однаковим.
*/
--3
select  s.SalesOrderNumber, 
		s.SalesOrderLineNumber, 
		s.ResellerKey, 
		p.EnglishProductName as ProductName, 
		s.OrderQuantity, 
		s.SalesAmount,
		s.OrderDate
from dbo.FactResellerSales s
join dbo.DimProduct p
	on p.ProductKey = s.ProductKey
where	year(s.OrderDate) = 2013
		and month(s.OrderDate) = 10
order by s.OrderDate desc, 
		 s.SalesOrderNumber desc, 
		 s.SalesOrderLineNumber asc;

/*
  Повернути SalesOrderNumber, SalesOrderLineNumber, ResellerName, ProductName, OrderQuantity, SalesAmount для продажів (ResellerSaler) 
  здійснених в жовтні 2013.
  Де ProductName це англійська назва продукту.
  Посортувати від новіших до старших замовлень. Результат має завжди повертатися однаковим.
*/
--4
select  s.SalesOrderNumber, 
		s.SalesOrderLineNumber, 
		r.ResellerName as ResellerName, 
		p.EnglishProductName as ProductName, 
		s.OrderQuantity, 
		s.SalesAmount,
		s.OrderDate
from dbo.FactResellerSales s
join dbo.DimProduct p
	on p.ProductKey = s.ProductKey
join dbo.DimReseller r
	on r.ResellerKey = s.ResellerKey
where	year(s.OrderDate) = 2013
		and month(s.OrderDate) = 10
order by s.OrderDate desc, 
		 s.SalesOrderNumber desc, 
		 s.SalesOrderLineNumber asc;

/*
  Отримати EmployeeKey, FullName (Ім'я, прізвище), ParentEmployeeKey для робітників для яких SalesTerritoryKey дорівнює 1
*/
--5
select  EmployeeKey, 
		FirstName + ' ' + LastName as FullName, 
		ParentEmployeeKey
from dbo.DimEmployee
where SalesTerritoryKey = 1;

/*
  Отримати EmployeeKey, FullName (Ім'я, прізвище), ParentEmployeeKey для робітників які здійснюють операції на території 
  Північно-західного регіону США
*/
--6
select  e.EmployeeKey, 
		e.FirstName + ' ' + e.LastName as FullName, 
		e.ParentEmployeeKey
from dbo.DimEmployee e
join dbo.DimSalesTerritory s
	on e.SalesTerritoryKey = s.SalesTerritoryKey
	and s.SalesTerritoryRegion = 'Northwest'
	and s.SalesTerritoryCountry = 'United States';

/*
  Отримати EmployeeKey, FullName (Ім'я, прізвище), ParentEmployeeKey, ManagerFullName  (Ім'я, прізвище), для робітників які 
  здійснюють операції на території Північно-західного регіону США
*/
--7
select  e.EmployeeKey, 
		e.FirstName + ' ' + e.LastName as FullName, 
		e.ParentEmployeeKey,
		e2.FirstName + ' ' + e2.LastName as ManagerFullName
from dbo.DimEmployee e
join dbo.DimSalesTerritory s
	on e.SalesTerritoryKey = s.SalesTerritoryKey
	and s.SalesTerritoryRegion = 'Northwest'
	and s.SalesTerritoryCountry = 'United States'
join dbo.DimEmployee e2
	on e2.EmployeeKey = e.ParentEmployeeKey;

/*
  Витягнути CurrencyAlternateKey,  CurrencyName,  EndOfDayRate,  DateKey  з факту вартості валют для валют 'GBP', 'EUR', 'UAH'
*/
--8
select  dc.CurrencyAlternateKey,  
		dc.CurrencyName,  
		fc.EndOfDayRate,  
		fc.DateKey
from dbo.FactCurrencyRate fc
join dbo.DimCurrency dc
	on dc.CurrencyKey = fc.CurrencyKey
where dc.CurrencyAlternateKey in ('GBP', 'EUR', 'UAH');

/*
  Витягнути CurrencyAlternateKey,  CurrencyName,  EndOfDayRate,  Date та форматовану дату (FormattedDate) у форматі схожому 
  по патерну "Monday, 1 Jan 00" з факту вартості валют для валют 'GBP', 'EUR', 'UAH' починаючи з 2013 року.
  Посортувати за датою, типом валюти
*/
--9
select  dc.CurrencyAlternateKey,  
		dc.CurrencyName,  
		fc.EndOfDayRate,  
		fc."Date",
		format(fc."Date", 'dddd, dd MMM yy') as FormattedDate
from dbo.FactCurrencyRate fc
join dbo.DimCurrency dc
	on dc.CurrencyKey = fc.CurrencyKey
where  dc.CurrencyAlternateKey in ('GBP', 'EUR', 'UAH')
	   and year(fc."Date") >= 2013;

/*
  Повернути назву категорії, підкатегорії, продукту (CategoryName, SubcategoryName, ProductName - значення англійською)  і 
  альтренативний ключ продукту з категорії компоненти (Components) і з субкатегорій, що починаються на 'H' (h not n).
*/
--10
select  c.EnglishProductCategoryName as CategoryName,
		sc.EnglishProductSubcategoryName as SubcategoryName,
		p.EnglishProductName as PoductName,
		p.ProductAlternateKey
from dbo.DimProduct p
join dbo.DimProductSubcategory sc
	on p.ProductSubcategoryKey = sc.ProductSubcategoryKey
join dbo.DimProductCategory c
	on c.ProductCategoryKey = sc.ProductCategoryKey
where   c.EnglishProductCategoryName = 'Components'
		and upper(left(sc.EnglishProductSubcategoryName, 1)) = 'H';

/*
  Повернути інформацію по продажах і назву категорії, підкатегорії, продукту (CategoryName, SubcategoryName, ProductName - значення англійською)  
  і альтренативний ключ продукту з категорії компоненти (Components) і з субкатегорій, що починаються на 'H' або 'C' (h not n / C not s).
  SalesOrderNumber, SalesOrderLineNumber, OrderQuantity, SalesAmount,  SaleAmountPerUnit,  UnitPrice,  DealerPrice. 
  Інформація про продажі з FactResellerSales
*/
--11
select  c.EnglishProductCategoryName as CategoryName,
		sc.EnglishProductSubcategoryName as SubcategoryName,
		p.EnglishProductName as PoductName,
		p.ProductAlternateKey,
		rc.SalesOrderNumber,
		rc.OrderQuantity, 
		rc.SalesAmount,  
		rc.SalesAmount / rc.OrderQuantity as SaleAmountPerUnit,  
		rc.UnitPrice,  
		rc.UnitPrice * (1 - rc.UnitPriceDiscountPct) as DealerPrice
from dbo.DimProduct p
join dbo.DimProductSubcategory sc
	on p.ProductSubcategoryKey = sc.ProductSubcategoryKey
join dbo.DimProductCategory c
	on c.ProductCategoryKey = sc.ProductCategoryKey
left join dbo.FactResellerSales as rc
	on rc.ProductKey = p.ProductKey
where   c.EnglishProductCategoryName = 'Components'
		and ( upper(left(sc.EnglishProductSubcategoryName, 1)) = 'H'
		   or upper(left(sc.EnglishProductSubcategoryName, 1)) = 'C');

/*
  Повернути назву категорії, підкатегорії, продукту (CategoryName, SubcategoryName, ProductName - значення англійською)  і 
  альтренативний ключ продукту з категорії компоненти (Components) і з субкатегорій, що починаються на 'H' (h not n).
  Для яких немає продажів у FactResellerSales.
*/
--12
select  c.EnglishProductCategoryName as CategoryName,
		sc.EnglishProductSubcategoryName as SubcategoryName,
		p.EnglishProductName as PoductName,
		p.ProductAlternateKey,
		rc.SalesOrderNumber,
		rc.OrderQuantity, 
		rc.SalesAmount,  
		rc.SalesAmount / rc.OrderQuantity as SaleAmountPerUnit,  
		rc.UnitPrice,  
		rc.UnitPrice * (1 - rc.UnitPriceDiscountPct) as DealerPrice
from dbo.DimProduct p
join dbo.DimProductSubcategory sc
	on p.ProductSubcategoryKey = sc.ProductSubcategoryKey
join dbo.DimProductCategory c
	on c.ProductCategoryKey = sc.ProductCategoryKey
left join dbo.FactResellerSales as rc
	on rc.ProductKey = p.ProductKey
where   c.EnglishProductCategoryName = 'Components'
		and upper(left(sc.EnglishProductSubcategoryName, 1)) = 'H' 
		and rc.ProductKey is null;

/*
  Повернути інформацію по продажах і назву категорії, підкатегорії, продукту (CategoryName, SubcategoryName, ProductName - значення англійською)  
  і альтренативний ключ продукту і з субкатегорій, що містять ключеве слово bike
  SalesOrderNumber, SalesOrderLineNumber, OrderQuantity, SalesAmount,  SaleAmountPerUnit,  UnitPrice,  DealerPrice. 
  Інформація про продажі з FactInternetSales.
  Посортувати по CategoryName, SubcategoryName, ProductName. Сортування має бути недвозначним.
*/
--13
select  c.EnglishProductCategoryName as CategoryName,
		sc.EnglishProductSubcategoryName as SubcategoryName,
		p.EnglishProductName as PoductName,
		p.ProductAlternateKey,
		rc.SalesOrderNumber,
		rc.OrderQuantity, 
		rc.SalesAmount,  
		rc.SalesAmount / rc.OrderQuantity as SaleAmountPerUnit,  
		rc.UnitPrice,  
		rc.UnitPrice * (1 - rc.UnitPriceDiscountPct) as DealerPrice
from dbo.DimProduct p
join dbo.DimProductSubcategory sc
	on p.ProductSubcategoryKey = sc.ProductSubcategoryKey
join dbo.DimProductCategory c
	on c.ProductCategoryKey = sc.ProductCategoryKey
left join dbo.FactResellerSales as rc
	on rc.ProductKey = p.ProductKey
where lower(sc.EnglishProductSubcategoryName) like '%bike%'
order by c.EnglishProductCategoryName asc, 
		 sc.EnglishProductSubcategoryName asc, 
		 p.EnglishProductName asc;

/*
  Інформацію про сьогоднішніх клієнтів іменинників для розсилки імейлів. Потрібно повернути Title,  FirstName,  MiddleName,  LastName,  
  NameStyle,  Gender,  EmailAddress та вік.
*/
--14
select  Title,  
		FirstName,  
		MiddleName,  
		LastName,  
		NameStyle,  
		Gender,  
		EmailAddress,
		datediff(year, BirthDate, getdate()) as Age,
		BirthDate
from dbo.DimCustomer
where month(BirthDate) = month(getdate())
	  and day(BirthDate) = day(getdate());

/*
  Інформацію про сьогоднішніх клієнтів іменинників для розсилки імейлів. Потрібно повернути Title,  FirstName,  MiddleName,  
  LastName,  NameStyle,  Gender,  EmailAddress, вік та бонусну знижку BDDiscount%, яка залежить від віку клієнта.
  Для всіх, кому 25 чи менше отримують 30% знижки, кому до 40 або включно - 35%, кому менше 61 - отримують 40% знижки, 
  кому до 70 або 70 - 45%, кому більше - 50%. Остання колонка має бути інт.
  *** примітка: запит має повертати результат для того дня коли виконується
*/
--15
select  Title,  
		FirstName,  
		MiddleName,  
		LastName,  
		NameStyle,  
		Gender,  
		EmailAddress,
		datediff(year, BirthDate, getdate()) as Age,
		BirthDate,
		case when datediff(year, BirthDate, getdate()) <= 25 then 30
			 when datediff(year, BirthDate, getdate()) <= 40 then 35
			 when datediff(year, BirthDate, getdate()) < 61  then 40
			 when datediff(year, BirthDate, getdate()) <= 70 then 45
			 else 50
		end as "BDDiscount%"
from dbo.DimCustomer
where month(BirthDate) = month(getdate())
	  and day(BirthDate) = day(getdate());

/*
  Повернути всіх робочих для яких в EmergencyContactName вказаний клієнт магазину
  
*/
select  e.EmployeeKey,
		e.FirstName,
		e.LastName,
		e.Title
from dbo.DimEmployee e
join dbo.DimCustomer c
	on e.EmergencyContactName = (c.FirstName + ' ' + c.LastName);