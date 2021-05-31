USE [Proyek]

--1
SELECT SoftwareName,'Rp. '+CAST(sum(SoftwarePrice*qty) as varchar) AS Income
FROM TrHeaderSales ths JOIN TrDetailSales tds ON
ths.SalesID=tds.SalesID JOIN MsSoftware ms ON
tds.SoftwareID=ms.SoftwareID JOIN MsSoftwareType mst ON
mst.SoftwareTypeID=ms.SoftwareTypeID
WHERE SoftwareTypeName IN ('Browser','Web Development') AND SoftwareStock>10
Group By SoftwareName,SoftwarePrice

--2
SELECT md.DistributorCompany, [Total Software Bought] = SUM(tdp.qty)
FROM MsDistributor md JOIN TrHeaderPurchase thp ON 
md.DistributorID = thp.DistributorID JOIN TrDetailPurchase tdp ON
thp.PurchaseID = tdp.purchaseID
WHERE md.DistributorName LIKE 'A%' AND DATEPART(DAY, thp.TransactionDatePurchase) > 10
GROUP BY TransactionDatePurchase, DistributorCompany

--3 
SELECT 'Rp' + CAST(AVG(ms.SoftwarePrice * QTY) AS varchar) AS [AverageRevenuePerDay], 
ths.TransactionDateSales, CAST(count (distinct(mss.staffgender)) AS VARCHAR) + ' Person' AS [MaleStaff]
from TrHeaderSales ths JOIN TrDetailSales tds ON
ths.SalesID=tds.SalesID JOIN MsSoftware ms ON
tds.SoftwareID=ms.SoftwareID JOIN MsStaff mss ON
mss.StaffID=ths.StaffID
WHERE year(TransactionDateSales) = 2018
Group by ths.TransactionDateSales

--4
SELECT [Gender] = LEFT(mst.staffgender,1), [Total Transactions] = CAST(COUNT(ths.SalesId) AS VARCHAR)  + ' transaction(s)', [Total Sold] = CAST(SUM(tds.qty) AS VARCHAR) + ' item(s)'
FROM MsStaff mst JOIN TrHeaderSales ths ON 
mst.StaffID = ths.StaffID JOIN TrDetailSales tds ON
ths.SalesID = tds.SalesID JOIN MsSoftware ms ON
tds.SoftwareID = ms.SoftwareID
WHERE mst.StaffGender LIKE 'Male' 
GROUP BY mst.StaffGender, tds.qty, ms.SoftwarePrice
HAVING (ms.SoftwarePrice * tds.qty) > 100000
SELECT [Gender] = LEFT(mst.staffgender,1), [Total Transactions] = CAST(COUNT(ths.SalesId) AS VARCHAR)  + ' transaction(s)', [Total Sold] = CAST(SUM(tds.qty) AS VARCHAR) + ' item(s)'
FROM MsStaff mst JOIN TrHeaderSales ths ON 
mst.StaffID = ths.StaffID JOIN TrDetailSales tds ON
ths.SalesID = tds.SalesID JOIN MsSoftware ms ON
tds.SoftwareID = ms.SoftwareID
WHERE mst.StaffGender LIKE 'Female' 
GROUP BY mst.StaffGender, tds.qty, ms.SoftwarePrice
HAVING (ms.SoftwarePrice * tds.qty) > 200000

--5
SELECT tdp.SoftwareId,SoftwareName,'Rp. '+CAST(SoftwarePrice AS varchar) AS [SoftwarePrice]
FROM MsSoftware ms,TrDetailPurchase AS tdp,TrHeaderPurchase AS thp,
(	SELECT [Average]=avg(SoftwarePrice)
	FROM MsSoftware
) as average
WHERE Softwareprice<average AND tdp.SoftwareID=ms.SoftwareID 
AND tdp.PurchaseID=thp.PurchaseID AND StaffID in ('SF003','SF004','SF009')
ORDER BY ms.SoftwarePrice desc

--6
SELECT Substring(StaffName, 1, (CHARINDEX(' ', StaffName + ' ')-1)) AS [StaffFirstName], 
StaffPhone, 
CONVERT(varchar,TransactionDateSales,107)AS[TransactionDate]
FROM MsStaff ms, TrDetailSales tds, TrHeaderSales ths,
(	SELECT [Average] = avg(qty)
	FROM TrDetailSales
) AS average
WHERE tds.SalesID = ths.SalesID AND ms.StaffID = ths.StaffID
AND qty<average AND year(TransactionDateSales) < 2019
Group by StaffName, StaffPhone, TransactionDateSales

--7
SELECT tdp.PurchaseID AS [PurchaseTransactionId],'Mx. '+substring(DistributorName,CHARINDEX(' ',DistributorName)+1,len(distributorname))AS[Distributor Last Name],
DistributorCompany,CONVERT(varchar,TransactionDatePurchase,107)AS[TransactionDate]
FROM MsDistributor md,TrHeaderPurchase thp,TrDetailPurchase tdp,MsSoftware ms,
(	SELECT [Average]=avg(SoftwarePrice)
	FROM MsSoftware
) as average,
(
	SELECT[Maximum]=max(softwareprice)
	FROM MsSoftware
) as maximum
WHERE md.DistributorID=thp.DistributorID AND thp.PurchaseID=tdp.PurchaseID
AND tdp.SoftwareID=ms.SoftwareID
AND DATEPART(Year,TransactionDatePurchase) between 2017 AND 2018
AND SoftwarePrice>average AND SoftwarePrice<maximum
Group by tdp.PurchaseID,DistributorName,DistributorCompany,TransactionDatePurchase

--8
SELECT md.DistributorName, [TransactionDate] = thp.TransactionDatePurchase, [Total Transactions] = CAST(COUNT(thp.PurchaseID) AS VARCHAR)  + ' transaction(s)' 
FROM MsDistributor md JOIN TrHeaderPurchase thp ON 
md.DistributorID = thp.DistributorID JOIN TrHeaderSales ths ON
thp.StaffID = ths.StaffID JOIN TrDetailSales tds ON
ths.SalesID = tds.SalesID JOIN MsSoftware ms ON 
tds.SoftwareID = ms.SoftwareID,
( SELECT  [Average] = AVG(CAST(SoftwareVersion AS numeric)) 
FROM MsSoftware) as average
WHERE ms.SoftwareVersion > average.[Average] AND md.DistributorID LIKE 'DT001' OR md.DistributorID LIKE 'DT005' OR md.DistributorID LIKE 'DT006'
GROUP BY md.DistributorName, thp.TransactionDatePurchase

--9
CREATE VIEW [StaffSalesReport] AS
SELECT StaffName,StaffGender,CAST(count(Distinct ths.SalesID)AS varchar)+' Transactions' AS[TransactionCount],
'Rp. '+CAST(sum(softwareprice*qty)AS varchar) AS [Total Sales Income]
FROM MsStaff ms,TrDetailSales tds, TrHeaderSales ths,MsSoftware mso
WHERE ms.StaffID=ths.StaffID AND ths.SalesID=tds.SalesID AND
mso.SoftwareID=tds.SoftwareID
AND StaffName LIKE ('% % %')
GROUP BY StaffName,StaffGender
HAVING sum(softwareprice*qty)>100000

--10
CREATE VIEW [Recurring Members] AS
SELECT CustomerName, count(distinct ths.SalesID) AS [Total Transaction],
'Rp. '+CAST(SUM(softwareprice*qty)AS varchar) AS [Total Spent]
FROM MsCustomer mc, MsSoftware ms, TrHeaderSales ths, TrDetailSales tds
WHERE mc.CustomerID=ths.CustomerID AND ths.SalesID=tds.SalesID AND
tds.SoftwareID=ms.SoftwareID AND SoftwarePrice>50000
Group By CustomerName
HAVING count(distinct ths.SalesID)>2
