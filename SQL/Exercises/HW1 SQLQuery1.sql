use AdventureWorksDW2019;

/*
  Повернути всі записи з dbo.DimCustomer
*/
select *
from dbo.DimCustomer;

/*
  Витягнути Ім'я, 2 ім'я та прізвище клієнтів. З 2ого імені взяти лише 1у літеру і додати крапку.
   FirstName, MiddleName, LastName з dbo.DimCustomer
*/
select	FirstName,
		case	when MiddleName is not null 
				then concat(left(MiddleName, 1), '.') 
				else null 
		end as MiddleName,
		LastName
from dbo.DimCustomer;

/*
  Витягнути Ім'я, 2 ім'я та прізвище клієнтів. З 2ого імені взяти лише 1у літеру і додати крапку.
  Об'єднати ці атрибути і повернути FullName. Між атрибути має бути пробіл.
   FirstName, MiddleName, LastName з dbo.DimCustomer
*/
select	FirstName,
		case	when MiddleName is not null 
				then concat(left(MiddleName, 1), '.') 
				else null 
		end as MiddleName,
		LastName,
		concat(FirstName, ' ', MiddleName, ' ', LastName) as FullName
from dbo.DimCustomer;
				
/*
  Витягнути унікальні повні імена (Full Name) об'єднавши FirstName, MiddleName, LastName. З MiddleName взяти лише 1у літеру і додати крапку.
  Відсортува по алфавіту
*/
with cte as (
select	distinct
		FirstName,
		case	when MiddleName is not null 
				then concat(left(MiddleName, 1), '.') 
				else null 
		end as MiddleName,
		LastName
from dbo.DimCustomer
)
select concat(FirstName, ' ', MiddleName, ' ', LastName) as FullName
from cte
order by FullName;

/*
  Витягнути всі записи з інтернет продажів (dbo.FactProductInventory)
*/
select *
from dbo.FactProductInventory;

/*
  Дата останньої зміни (LastChanheDate) в dbo.FactProductInventory для продукта 606 (WHERE ProductKey = 606).
  На основі колонки MovementDate
*/
select max(MovementDate) as LastChangedDate
from dbo.FactProductInventory
where ProductKey = 606;

/*
  Унікальні групи територій продажів SalesTerritoryGroup з DimSalesTerritory
*/
select distinct SalesTerritoryGroup
from dbo.DimSalesTerritory;

/*
  Отримати перші 5 записів по даті з FactCurrencyRate
*/
select top 5 *
from FactCurrencyRate
order by "Date" desc;

/*
  Отримати останні 5 записів по даті з FactCurrencyRate
*/
select top 5 *
from FactCurrencyRate
order by "Date" asc;

/*
  Знайти найдорожчий(-і) продукт(-и) за всю історію,
    повернути колонки ProdcutKey та UnitCost з FactProductInventory.
*/
select ProductKey, UnitCost
from dbo.FactProductInventory
where UnitCost = (	select max(UnitCost)
					from dbo.FactProductInventory );

/*
  Знайти найдешевщий(-і) продукт(-и) за всю історію, повернути всі колонки з FactProductInventory
*/
select *
from dbo.FactProductInventory
where UnitCost = (	select min(UnitCost)
					from dbo.FactProductInventory );

/*
  Зробити перевірку даних,
  прокалькулювавши загальну суму лінійки замовлення,
  помноживши кількість замовленого товару на ціну товару відмінусувавши SalesAmount з урахуванням знижки.
  Повернути 1ий рядок посортований по цьому виразу по спаданню.
  Якщо повернутий результат - 0 то все правильно
*/

-- для FactInternetSales
select (OrderQuantity *  UnitPrice - DiscountAmount - SalesAmount ) as DataCheck
from dbo.FactInternetSales
order by DataCheck desc;

-- для FactInternetSales
select (OrderQuantity * UnitPrice - DiscountAmount - SalesAmount ) as DataCheck, *
from dbo.FactInternetSales
order by DataCheck desc;

/*
  Вирахувати кількість повних років від час найму до зараз.
  Повернути Ім'я, прізвище, кількість років (YearsEmployed) з таблички 
*/
select  FirstName,
		LastName, 
		datediff(year, HireDate, getdate()) as YearsEmployed 
from dbo.DimEmployee
where "Status" = 'Current';

/*
  Повернути всі дні із найбльшою кількістю прийнятих скарг у кол-центр.
  З FactCallCenter, результат з колонки Date повернути у форматі: 12 Nov 21;
    а також повернути назву дня.
*/
select  datename(weekday, "Date"),
		format("Date", 'dd MMM yyyy'),
		Calls
from dbo.FactCallCenter
order by Calls desc;

/* 
  Витягнути всі дані для 3ї сторінки, які приходять з сутності DimReseller,
  якщо вибране сортування по року першого замовлення, назві реселера, а розмір сторінки 15
*/
select *
from dbo.DimReseller
where FirstOrderYear is not null
order by FirstOrderYear, ResellerName
offset 30 rows fetch next 15 rows only;