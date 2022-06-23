use AdventureWorksDW2019;

/*
  ��������� �� ������ � dbo.DimCustomer
*/
select *
from dbo.DimCustomer;

/*
  ��������� ��'�, 2 ��'� �� ������� �볺���. � 2��� ���� ����� ���� 1� ����� � ������ ������.
   FirstName, MiddleName, LastName � dbo.DimCustomer
*/
select	FirstName,
		case	when MiddleName is not null 
				then concat(left(MiddleName, 1), '.') 
				else null 
		end as MiddleName,
		LastName
from dbo.DimCustomer;

/*
  ��������� ��'�, 2 ��'� �� ������� �볺���. � 2��� ���� ����� ���� 1� ����� � ������ ������.
  ��'������ �� �������� � ��������� FullName. ̳� �������� �� ���� �����.
   FirstName, MiddleName, LastName � dbo.DimCustomer
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
  ��������� ������� ���� ����� (Full Name) ��'������� FirstName, MiddleName, LastName. � MiddleName ����� ���� 1� ����� � ������ ������.
  ³�������� �� �������
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
  ��������� �� ������ � �������� ������� (dbo.FactProductInventory)
*/
select *
from dbo.FactProductInventory;

/*
  ���� �������� ���� (LastChanheDate) � dbo.FactProductInventory ��� �������� 606 (WHERE ProductKey = 606).
  �� ����� ������� MovementDate
*/
select max(MovementDate) as LastChangedDate
from dbo.FactProductInventory
where ProductKey = 606;

/*
  ������� ����� �������� ������� SalesTerritoryGroup � DimSalesTerritory
*/
select distinct SalesTerritoryGroup
from dbo.DimSalesTerritory;

/*
  �������� ����� 5 ������ �� ��� � FactCurrencyRate
*/
select top 5 *
from FactCurrencyRate
order by "Date" desc;

/*
  �������� ������ 5 ������ �� ��� � FactCurrencyRate
*/
select top 5 *
from FactCurrencyRate
order by "Date" asc;

/*
  ������ �����������(-�) �������(-�) �� ��� ������,
    ��������� ������� ProdcutKey �� UnitCost � FactProductInventory.
*/
select ProductKey, UnitCost
from dbo.FactProductInventory
where UnitCost = (	select max(UnitCost)
					from dbo.FactProductInventory );

/*
  ������ �����������(-�) �������(-�) �� ��� ������, ��������� �� ������� � FactProductInventory
*/
select *
from dbo.FactProductInventory
where UnitCost = (	select min(UnitCost)
					from dbo.FactProductInventory );

/*
  ������� �������� �����,
  ���������������� �������� ���� ����� ����������,
  ���������� ������� ����������� ������ �� ���� ������ ������������ SalesAmount � ����������� ������.
  ��������� 1�� ����� ������������ �� ����� ������ �� ��������.
  ���� ���������� ��������� - 0 �� ��� ���������
*/

-- ��� FactInternetSales
select (OrderQuantity *  UnitPrice - DiscountAmount - SalesAmount ) as DataCheck
from dbo.FactInternetSales
order by DataCheck desc;

-- ��� FactInternetSales
select (OrderQuantity * UnitPrice - DiscountAmount - SalesAmount ) as DataCheck, *
from dbo.FactInternetSales
order by DataCheck desc;

/*
  ���������� ������� ������ ���� �� ��� ����� �� �����.
  ��������� ��'�, �������, ������� ���� (YearsEmployed) � �������� 
*/
select  FirstName,
		LastName, 
		datediff(year, HireDate, getdate()) as YearsEmployed 
from dbo.DimEmployee
where "Status" = 'Current';

/*
  ��������� �� �� �� ��������� ������� ��������� ����� � ���-�����.
  � FactCallCenter, ��������� � ������� Date ��������� � ������: 12 Nov 21;
    � ����� ��������� ����� ���.
*/
select  datename(weekday, "Date"),
		format("Date", 'dd MMM yyyy'),
		Calls
from dbo.FactCallCenter
order by Calls desc;

/* 
  ��������� �� ��� ��� 3� �������, �� ��������� � ������� DimReseller,
  ���� ������� ���������� �� ���� ������� ����������, ���� ��������, � ����� ������� 15
*/
select *
from dbo.DimReseller
where FirstOrderYear is not null
order by FirstOrderYear, ResellerName
offset 30 rows fetch next 15 rows only;