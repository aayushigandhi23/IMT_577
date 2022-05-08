CREATE OR REPLACE FILE FORMAT CSV_SKIP_HEADER
TYPE = 'CSV'
field_delimiter = ','
FIELD_OPTIONALLY_ENCLOSED_BY = '"'
skip_header = 1;


select * from stage_customer

select * from stage_product

CREATE OR REPLACE TABLE DIM_LOCATION (
    DIM_LOCATION_ID NUMBER(20) IDENTITY(1,1) PRIMARY KEY,
    LOCATION_ADDRESS  VARCHAR(200),
    CITY VARCHAR(100),
    POSTAL_CODE VARCHAR(10),
    STATE_PROVINCE VARCHAR(100),
    COUNTRY VARCHAR(100)
)



INSERT INTO DIM_LOCATION
(
    DIM_LOCATION_ID,
    LOCATION_ADDRESS,
    CITY,
    POSTAL_CODE,
    STATE_PROVINCE,
    COUNTRY
)

VALUES
(
  -1,
  'UNKNOWN',
  'UNKNOWN',
  'UNKNOWN',
  'UNKNOWN',
  'UNKNOWN'
);


INSERT INTO DIM_LOCATION
(
    LOCATION_ADDRESS,
    CITY,
    POSTAL_CODE,
    STATE_PROVINCE,
    COUNTRY
)


SELECT ADDRESS,CITY,POSTALCODE,STATEPROVINCE, COUNTRY FROM STAGE_CUSTOMER 
UNION 
SELECT ADDRESS,CITY,POSTALCODE,STATEPROVINCE, COUNTRY FROM STAGE_RESELLER 
UNION
SELECT ADDRESS,CITY,POSTALCODE,STATEPROVINCE, COUNTRY FROM STAGE_STORE

CREATE OR REPLACE TABLE DIM_CHANNEL (
    DIM_CHANNEL_ID NUMBER(10) IDENTITY(1,1) PRIMARY KEY,
    SOURCE_CHANNEL_ID NUMBER(10),
    SOURCE_CHANNEL_CATEGORY_ID NUMBER(10),
    CHANNEL_NAME VARCHAR(100),
    CHANNEL_CATEGORY VARCHAR(100)
)

INSERT INTO DIM_CHANNEL(
    DIM_CHANNEL_ID ,
    SOURCE_CHANNEL_ID ,
    SOURCE_CHANNEL_CATEGORY_ID ,
    CHANNEL_NAME ,
    CHANNEL_CATEGORY)

VALUES(
-1,
-1,
-1,
'UNKNOWN',
'UNKNOWN'
)


INSERT INTO DIM_CHANNEL(
    SOURCE_CHANNEL_ID ,
    SOURCE_CHANNEL_CATEGORY_ID ,
    CHANNEL_NAME ,
    CHANNEL_CATEGORY)

SELECT C.CHANNELID,CC.CHANNELCATEGORYID,C.CHANNEL, CC.CHANNELCATEGORY FROM STAGE_CHANNEL C
JOIN STAGE_CHANNELCATEGORY CC ON C.CHANNELCATEGORYID = CC.CHANNELCATEGORYID


CREATE OR REPLACE TABLE DIM_PRODUCT(   
  DIM_PRODUCT_ID INT IDENTITY(1,1) PRIMARY KEY,    
  PRODUCT_ID INT,    
  PRODUCT_TYPE_ID INT,    
  PRODUCT_CATEGORY_ID INT,    
  PRODUCT_NAME VARCHAR(255),    
  PRODUCT_TYPE VARCHAR(255),    
  PRODUCT_CATEGORY VARCHAR(255),    
  PRODUCT_RETAIL_PRICE NUMBER(8,2),    
  PRODUCT_WHOLESALE_PRICE NUMBER(8,2),    
  PRODUCT_COST NUMBER(8,2),    
  PRODUCT_RETAIL_PROFIT NUMBER(8,2),    
  PRODUCT_WHOLESALE_UNIT_PROFIT NUMBER(8,2),    
  PRODUCT_RPROFIT_MARGIN_UNIT_PERCENT NUMBER (8,2),
  PRODUCT_WPROFIT_MARGIN_UNIT_PERCENT NUMBER(8,2))


INSERT INTO DIM_PRODUCT
(
  DIM_PRODUCT_ID,    
  PRODUCT_ID,    
  PRODUCT_TYPE_ID ,    
  PRODUCT_CATEGORY_ID ,    
  PRODUCT_NAME,    
  PRODUCT_TYPE ,    
  PRODUCT_CATEGORY ,    
  PRODUCT_RETAIL_PRICE,    
  PRODUCT_WHOLESALE_PRICE ,    
  PRODUCT_COST ,    
  PRODUCT_RETAIL_PROFIT ,    
  PRODUCT_WHOLESALE_UNIT_PROFIT ,    
  PRODUCT_RPROFIT_MARGIN_UNIT_PERCENT,
  PRODUCT_WPROFIT_MARGIN_UNIT_PERCENT
)

VALUES
(
-1,
-1,
-1,
-1,
'UNKNOWN',
'UNKNOWN',
'UNKNOWN',
-1,
-1,
-1,
-1,
-1,
-1,
-1)

INSERT INTO DIM_PRODUCT(
    PRODUCT_ID,
    PRODUCT_TYPE_ID,
    PRODUCT_CATEGORY_ID,
    PRODUCT_NAME,
    PRODUCT_TYPE,
    PRODUCT_CATEGORY,
    PRODUCT_RETAIL_PRICE,
    PRODUCT_WHOLESALE_PRICE,
    PRODUCT_COST,
    PRODUCT_RETAIL_PROFIT,
    PRODUCT_WHOLESALE_UNIT_PROFIT,    
    PRODUCT_RPROFIT_MARGIN_UNIT_PERCENT,
    PRODUCT_WPROFIT_MARGIN_UNIT_PERCENT
)

SELECT P.PRODUCTID, PT.PRODUCTTYPEID, PC.PRODUCTCATEGORYID, P.PRODUCT,
PT.PRODUCTTYPE, PC.PRODUCTCATEGORY, P.PRICE, P.WHOLESALEPRICE, P.COST, (P.PRICE - P.COST), (P.WHOLESALEPRICE - P.COST), (P.PRICE - P.COST)*100/P.PRICE, (P.WHOLESALEPRICE - P.COST)*100/P.PRICE
FROM STAGE_PRODUCT AS P
INNER JOIN STAGE_PRODUCTTYPE AS PT ON P.PRODUCTTYPEID = PT.PRODUCTTYPEID
INNER JOIN STAGE_PRODUCTCATEGORY AS PC ON PT.PRODUCTCATEGORYID = PC.PRODUCTCATEGORYID


CREATE OR REPLACE TABLE DIM_CUSTOMER(
    DIM_CUSTOMER_ID NUMBER(10) IDENTITY(1,1) PRIMARY KEY,
    DIM_LOCATION_ID NUMBER(20) FOREIGN KEY REFERENCES DIM_LOCATION(DIM_LOCATION_ID),
    CUSTOMER_ID VARCHAR(255),
    FULL_NAME VARCHAR(100),
    FIRST_NAME VARCHAR(50),
    LAST_NAME VARCHAR(50),
    GENDER VARCHAR(50),
    EMAIL_ID VARCHAR(255),
    PHONE_NUMBER VARCHAR(20)
)



INSERT INTO DIM_CUSTOMER(
    DIM_CUSTOMER_ID,
    DIM_LOCATION_ID,
    CUSTOMER_ID,
    FULL_NAME,
    FIRST_NAME,
    LAST_NAME,
    GENDER,
    EMAIL_ID ,
    PHONE_NUMBER
)

VALUES(
  -1,
  -1,
  'UNKNOWN',
  'UNKNOWN',
  'UNKNOWN',
  'UNKNOWN',
  'UNKNOWN',
  'UNKNOWN',
  'UNKNOWN'
)


INSERT INTO DIM_CUSTOMER(
    CUSTOMER_ID,
    FULL_NAME,
    FIRST_NAME,
    LAST_NAME,
    GENDER,
    EMAIL_ID ,
    PHONE_NUMBER
)

SELECT C.CUSTOMERID, CONCAT(C.FIRSTNAME,' ',C.LASTNAME), C.FIRSTNAME, C.LASTNAME, C.GENDER, C.EMAILADDRESS, C.PHONENUMBER FROM STAGE_CUSTOMER C

UPDATE DIM_CUSTOMER AS DCU
SET DCU.DIM_LOCATION_ID = X.DIM_LOCATION_ID
FROM
(SELECT DL.DIM_LOCATION_ID, DCU.CUSTOMER_ID FROM DIM_LOCATION AS DL
INNER JOIN STAGE_CUSTOMER AS SCU ON DL.LOCATION_ADDRESS = SCU.ADDRESS AND DL.CITY = SCU.CITY AND DL.COUNTRY = SCU.COUNTRY
INNER JOIN DIM_CUSTOMER AS DCU ON SCU.CUSTOMERID = DCU.CUSTOMER_ID) X
WHERE DCU.CUSTOMER_ID = X.CUSTOMER_ID
AND DCU.DIM_LOCATION_ID IS NULL



CREATE OR REPLACE TABLE DIM_STORE(
    DIM_STORE_ID INT IDENTITY(1,1)PRIMARY KEY,
    DIM_LOCATION_ID NUMBER(20) FOREIGN KEY REFERENCES DIM_LOCATION(DIM_LOCATION_ID),
    STORE_ID NUMBER(10),
    STORE_NUMBER INT,
    STORE_MANAGER VARCHAR(255)
)

INSERT INTO DIM_STORE(
    DIM_STORE_ID ,
    DIM_LOCATION_ID,
    STORE_ID,
    STORE_NUMBER,
    STORE_MANAGER
)

VALUES(
-1,
-1,
-1,
-1,
'UNKNOWN'
)
 
INSERT INTO DIM_STORE(
    STORE_ID,
    STORE_NUMBER,
    STORE_MANAGER
)
SELECT STOREID, STORENUMBER, STOREMANAGER FROM STAGE_STORE

UPDATE DIM_STORE AS DST
SET DST.DIM_LOCATION_ID = Y.DIM_LOCATION_ID
FROM
(SELECT DL.DIM_LOCATION_ID, DST.STORE_ID FROM DIM_LOCATION AS DL
INNER JOIN STAGE_STORE AS SS ON DL.LOCATION_ADDRESS = SS.ADDRESS AND DL.CITY = SS.CITY AND DL.COUNTRY = SS.COUNTRY
INNER JOIN DIM_STORE AS DST ON SS.STOREID = DST.STORE_ID) Y
WHERE DST.STORE_ID = Y.STORE_ID
AND DST.DIM_LOCATION_ID IS NULL

SELECT * FROM DIM_STORE


CREATE OR REPLACE TABLE DIM_RESELLER(
    DIM_RESELLER_ID INT IDENTITY(1,1) PRIMARY KEY,
    DIM_LOCATION_ID NUMBER(20) FOREIGN KEY REFERENCES DIM_LOCATION(DIM_LOCATION_ID),
    RESELLER_ID VARCHAR(255),
    RESELLER_NAME VARCHAR(255),
    RESELLER_CONTACT VARCHAR(255),
    PHONE_NUMBER VARCHAR(20),
    EMAIL VARCHAR(255)
)

INSERT INTO DIM_RESELLER (
    DIM_RESELLER_ID,
    DIM_LOCATION_ID,
    RESELLER_ID,
    RESELLER_NAME,
    RESELLER_CONTACT,
    PHONE_NUMBER,
    EMAIL
)

VALUES(
-1,
-1,
'UNKNOWN',
'UNKNOWN',
'UNKNOWN',
'UNKNOWN',
'UNKNOWN'
)

INSERT INTO DIM_RESELLER(
    RESELLER_ID,
    RESELLER_NAME,
    RESELLER_CONTACT,
    PHONE_NUMBER,
    EMAIL
)
SELECT RESELLERID, RESELLERNAME, CONTACT, PHONENUMBER, EMAILADDRESS FROM STAGE_RESELLER

UPDATE DIM_RESELLER AS DR
SET DR.DIM_LOCATION_ID = Z.DIM_LOCATION_ID
FROM
(
  SELECT DL.DIM_LOCATION_ID, DR.RESELLER_ID FROM DIM_LOCATION AS DL
  INNER JOIN STAGE_RESELLER AS SR ON DL.LOCATION_ADDRESS = SR.ADDRESS AND DL.CITY = SR.CITY AND DL.COUNTRY = SR.COUNTRY
  INNER JOIN DIM_RESELLER AS DR ON SR.RESELLERID = DR.RESELLER_ID
) Z
WHERE DR.RESELLER_ID = Z.RESELLER_ID
AND DR.DIM_LOCATION_ID IS NULL

SELECT * FROM DIM_RESELLER




