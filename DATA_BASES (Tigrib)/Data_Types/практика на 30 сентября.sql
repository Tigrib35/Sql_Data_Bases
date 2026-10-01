IF DB_ID('BookStoreDB') IS NOT NULL
    DROP DATABASE BookStoreDB;
GO

CREATE DATABASE BookStoreDB;
GO

USE BookStoreDB;
GO

ALTER DATABASE BookStoreDB ADD FILEGROUP FG_Catalog;
ALTER DATABASE BookStoreDB ADD FILEGROUP FG_History;
GO

ALTER DATABASE BookStoreDB
ADD FILE (
    NAME = CatalogData,
    FILENAME = 'C:\MSSQL\Data\CatalogData.ndf',
    SIZE = 8MB,
    FILEGROWTH = 4MB
) TO FILEGROUP FG_Catalog;

ALTER DATABASE BookStoreDB
ADD FILE (
    NAME = HistoryData,
    FILENAME = 'C:\MSSQL\Data\HistoryData.ndf',
    SIZE = 8MB,
    FILEGROWTH = 4MB
) TO FILEGROUP FG_History;
GO

CREATE TABLE dbo.Writers
(
    WriterId      INT IDENTITY(1000, 5) NOT NULL,
    Surname       VARCHAR(60)  NOT NULL,
    GivenName     VARCHAR(60)  NOT NULL,
    BornOn        DATE         NULL,
    Citizenship   VARCHAR(80)  NULL,

    CONSTRAINT PK_Writers PRIMARY KEY (WriterId)
) ON FG_History;
GO

CREATE TABLE dbo.PublishingHouses
(
    HouseId       INT IDENTITY(1,1) NOT NULL,
    HouseName     VARCHAR(180) NOT NULL,
    Town          VARCHAR(80)  NULL,
    SiteUrl       VARCHAR(200) NULL,

    CONSTRAINT PK_PublishingHouses PRIMARY KEY (HouseId),
    CONSTRAINT UQ_HouseName UNIQUE (HouseName)
) ON FG_History;
GO

CREATE TABLE dbo.Categories
(
    CategoryId    SMALLINT IDENTITY(1,1) NOT NULL,
    CategoryName  VARCHAR(80) NOT NULL,

    CONSTRAINT PK_Categories PRIMARY KEY (CategoryId),
    CONSTRAINT UQ_CategoryName UNIQUE (CategoryName)
) ON FG_History;
GO

CREATE TABLE dbo.Editions
(
    EditionId     INT IDENTITY(1,1) NOT NULL,
    HouseId       INT           NOT NULL,
    EditionTitle  VARCHAR(250)  NOT NULL,
    IsbnCode      CHAR(17)      NOT NULL,
    Cost          MONEY         NOT NULL CONSTRAINT DF_Editions_Cost DEFAULT (0),
    Pages         SMALLINT      NULL,
    YearPrinted   SMALLINT      NOT NULL,

    CONSTRAINT PK_Editions PRIMARY KEY (EditionId),
    CONSTRAINT UQ_Editions_Isbn UNIQUE (IsbnCode),
    CONSTRAINT FK_Editions_House
        FOREIGN KEY (HouseId) REFERENCES dbo.PublishingHouses(HouseId),
    CONSTRAINT CK_Editions_Cost CHECK (Cost >= 0),
    CONSTRAINT CK_Editions_Year CHECK (YearPrinted BETWEEN 1400 AND 2100)
) ON FG_Catalog;
GO

CREATE TABLE dbo.EditionWriters
(
    EditionId     INT NOT NULL,
    WriterId      INT NOT NULL,

    CONSTRAINT PK_EditionWriters PRIMARY KEY (EditionId, WriterId),
    CONSTRAINT FK_EW_Edition FOREIGN KEY (EditionId) REFERENCES dbo.Editions(EditionId),
    CONSTRAINT FK_EW_Writer  FOREIGN KEY (WriterId)  REFERENCES dbo.Writers(WriterId)
) ON FG_Catalog;
GO

CREATE TABLE dbo.EditionCategories
(
    EditionId     INT      NOT NULL,
    CategoryId    SMALLINT NOT NULL,

    CONSTRAINT PK_EditionCategories PRIMARY KEY (EditionId, CategoryId),
    CONSTRAINT FK_EC_Edition  FOREIGN KEY (EditionId)  REFERENCES dbo.Editions(EditionId),
    CONSTRAINT FK_EC_Category FOREIGN KEY (CategoryId) REFERENCES dbo.Categories(CategoryId)
) ON FG_Catalog;
GO

CREATE TABLE dbo.Customers
(
    CustomerId    INT IDENTITY(1,1) NOT NULL,
    ContactName   VARCHAR(150) NOT NULL,
    ContactEmail  VARCHAR(120) NOT NULL,
    JoinedAt      DATETIME     NOT NULL CONSTRAINT DF_Customers_Joined DEFAULT (GETDATE()),

    CONSTRAINT PK_Customers PRIMARY KEY (CustomerId),
    CONSTRAINT UQ_Customers_Email UNIQUE (ContactEmail),
    CONSTRAINT CK_Customers_Email CHECK (ContactEmail LIKE '%@%.%')
) ON FG_Catalog;
GO

CREATE TABLE dbo.Purchases
(
    PurchaseId    INT IDENTITY(1,1) NOT NULL,
    CustomerId    INT           NOT NULL,
    EditionId     INT           NOT NULL,
    PurchasedAt   DATETIME      NOT NULL CONSTRAINT DF_Purchases_Date DEFAULT (GETDATE()),
    ItemsCount    TINYINT       NOT NULL CONSTRAINT DF_Purchases_Items DEFAULT (1),
    Amount        MONEY         NOT NULL,

    CONSTRAINT PK_Purchases PRIMARY KEY (PurchaseId),
    CONSTRAINT FK_Purchases_Customer FOREIGN KEY (CustomerId) REFERENCES dbo.Customers(CustomerId),
    CONSTRAINT FK_Purchases_Edition  FOREIGN KEY (EditionId)  REFERENCES dbo.Editions(EditionId),
    CONSTRAINT CK_Purchases_Items CHECK (ItemsCount BETWEEN 1 AND 100),
    CONSTRAINT CK_Purchases_Amount CHECK (Amount >= 0)
) ON FG_Catalog;
GO

CREATE INDEX IX_Editions_Title
    ON dbo.Editions (EditionTitle);
GO

CREATE INDEX IX_Editions_Premium
    ON dbo.Editions (Cost)
    WHERE Cost > 2000;
GO

CREATE INDEX IX_Purchases_ByCustomer
    ON dbo.Purchases (CustomerId, PurchasedAt DESC);
GO

CREATE COLUMNSTORE INDEX IX_Purchases_Analytics
    ON dbo.Purchases (EditionId, CustomerId, Amount, PurchasedAt);
GO

INSERT INTO dbo.Writers (Surname, GivenName, BornOn, Citizenship)
VALUES ('Булгаков', 'Михаил', '1891-05-15', 'Россия');

INSERT INTO dbo.PublishingHouses (HouseName, Town, SiteUrl)
VALUES ('АСТ', 'Москва', 'https://ast.ru');

INSERT INTO dbo.Categories (CategoryName)
VALUES ('Мистика');

INSERT INTO dbo.Editions (HouseId, EditionTitle, IsbnCode, Cost, Pages, YearPrinted)
VALUES (1, 'Мастер и Маргарита', '978-5-17-118999-9', 1750.00, 480, 1967);

INSERT INTO dbo.EditionWriters (EditionId, WriterId) VALUES (1, 1000);
INSERT INTO dbo.EditionCategories (EditionId, CategoryId) VALUES (1, 1);

INSERT INTO dbo.Customers (ContactName, ContactEmail)
VALUES ('Пётр Сидоров', 'petr.sidorov@example.com');

INSERT INTO dbo.Purchases (CustomerId, EditionId, ItemsCount, Amount)
VALUES (1, 1, 2, 3500.00);
GO

SELECT e.EditionTitle, e.Cost, w.Surname
FROM dbo.Editions e
JOIN dbo.EditionWriters ew ON ew.EditionId = e.EditionId
JOIN dbo.Writers w         ON w.WriterId  = ew.WriterId;

SELECT c.ContactName, p.Amount, p.PurchasedAt
FROM dbo.Purchases p
JOIN dbo.Customers c ON c.CustomerId = p.CustomerId;
GO