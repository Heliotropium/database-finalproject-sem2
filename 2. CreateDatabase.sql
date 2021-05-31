create database Proyek

USE [Proyek]

create table MsStaff
(
	StaffID char(5) primary key not null,
	StaffName varchar(45),
	StaffGender varchar(6),
	StaffPhone varchar(14),
	StaffDOB date,
	StaffEmail varchar(50),
	StaffAddress varchar(50),
	constraint stafflen check( len(StaffID) = 5 ),
	constraint staffid check( StaffID like 'SF[0-9][0-9][0-9]' ),	
	constraint staffphone check( len(StaffPhone) = 13),
	constraint staffdob check(datediff(year,StaffDOB,getdate())>17),
	constraint staffgender check( StaffGender in ('Male', 'Female')),
	constraint staffaddress check( StaffAddress like '[0-9][0-9][0-9] street')
)

create table MsCustomer
(
	CustomerID char(5) primary key not null,
	CustomerName varchar(45),
	CustomerGender varchar(6),
	CustomerPhone varchar(14),
	CustomerAddress varchar(50),
	constraint customername check( len(CustomerName) >5 ),
	constraint customerid check( CustomerID like 'CX[0-9][0-9][0-9]' ),	
	constraint customergender check( CustomerGender in ('Male', 'Female')),
	constraint customerphone check( len(CustomerPhone) = 13),
	constraint customeraddress check( CustomerAddress like '[0-9][0-9][0-9] street')
)

create table MsSoftwareType
(
	SoftwareTypeID char(5) primary key,
	SoftwareTypeName varchar(40),
	constraint softwaretypeid check( SoftwareTypeID like 'TP[0-9][0-9][0-9]' ),	
	constraint softwaretype check( SoftwareTypeName in ('Multimedia Design', 'Database Management',
	'Browser','Web Development','Integrated Development Environment','Mobile Application','Game Development',
	'Text Editor','Business Analytics','Others'))
)


create table MsSoftware
(
	SoftwareID char(5) primary key not null,
	SoftwareName varchar(45),
	SoftwareVersion varchar(20),
	SoftwareReleaseDate date,
	SoftwarePrice int,
	SoftwareStock int,
	SoftwareTypeID char(5) not null,
	constraint softwareid check( SoftwareID like 'SW[0-9][0-9][0-9]' ),	
	constraint softwareprice check ( Softwareprice BETWEEN 20000 and 3000000 ),
	constraint softwareVersion check (SoftwareVersion LIKE '[0-9].[0-9]'),
	Foreign key(SoftwareTypeID) references MsSoftwareType on update cascade on delete cascade
)

create table TrHeaderSales
(
	SalesID char(6) primary key not null,
	TransactionDateSales datetime not null,
	StaffID char(5) not null,
	CustomerID char(5) not null,
	constraint salesid check ( SalesID like 'SL[0-9][0-9][0-9]'),   
	Foreign key(CustomerID) references MsCustomer on update cascade on delete cascade,
	Foreign key(StaffID) references MsStaff on update cascade on delete cascade,
)


create table TrDetailSales
(
	SalesID char(6) not null,
	SoftwareID char(5) not null,
	qty INT not null,
	primary key(SalesID,SoftwareID),
	Foreign key(SalesID) references TrHeaderSales on update cascade on delete cascade,
	Foreign key(SoftwareID) references MsSoftware on update cascade on delete cascade
	)


create table MsDistributor
(
	DistributorID char(5) primary key,
	DistributorName varchar(45),
	DistributorCompany varchar (45),
	constraint distriId check( DistributorID like 'DT[0-9][0-9][0-9]' ),
	constraint distributorname check ( DistributorName like '% %' )
)


create table TrHeaderPurchase
(
	PurchaseID char(6) primary key not null,
	TransactionDatePurchase datetime not null,
	StaffID char(5) not null,
	DistributorID char(5) not null,
	constraint purchaseid check ( PurchaseID like 'PR[0-9][0-9][0-9]'),   
	Foreign key(DistributorID) references MsDistributor on update cascade on delete cascade,
	Foreign key(StaffID) references MsStaff on update cascade on delete cascade,
)

create table TrDetailPurchase
(
	PurchaseID char(6) not null,
	SoftwareID char(5) not null,	
	qty INT not null,
	primary key (PurchaseID,SoftwareID),
	Foreign key(SoftwareID) references MsSoftware on update cascade on delete cascade,
	Foreign key(PurchaseID) references TrHeaderPurchase on update cascade on delete cascade
)