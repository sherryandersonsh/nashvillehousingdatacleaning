/* Cleaning Data Using SQL Queries*/

DROP TABLE nashvillehousing;


CREATE TABLE nashvillehousing
(
    UniqueID        INT,
    ParcelID        VARCHAR(50),
    LandUse         VARCHAR(50),
    PropertyAddress VARCHAR(200),
    SaleDate        DATE,
    SalePrice       VARCHAR(10),
    LegalReference  VARCHAR(50),
    SoldAsVacant    VARCHAR(10),
    OwnerName       VARCHAR(100),
    OwnerAddress    VARCHAR(200),
    Acreage         VARCHAR(200),
    TaxDistrict     VARCHAR(50),
    LandValue       INT,
    BuildingValue   INT,
    TotalValue      INT,
    YearBuilt       INT,
    Bedrooms        INT,
    FullBath        INT,
    HalfBath        INT
);

--Imports the data from the .csv file into the table
COPY nashvillehousing (
                       UniqueID, ParcelID, LandUse, PropertyAddress, SaleDate, SalePrice, LegalReference, SoldAsVacant,
                       OwnerName, OwnerAddress, Acreage, TaxDistrict, LandValue, BuildingValue, TotalValue, YearBuilt,
                       Bedrooms, FullBath, HalfBath
    )
    FROM '/Users/dataportfolioprojects/NashvilleHousingDataforDataCleaning.csv'
    DELIMITER ','
    CSV HEADER;

Select *
from nashvillehousing;

/* Populate PROPERTYADDRESS
Every property address has a Parcel ID. Will use the parcel id to populate the empty fields under the property address
column */

-- Join table to itself to compare the property and parcel id address columns.
-- The coalesce check if a.PropertyAdress is null, if its null it populates it with b.PropertyAddress.
-- This line a.uniqueid <> b.uniqueid is used to avoid duplicating records
select a.ParcelID,
       a.PropertyAddress,
       b.ParcelID,
       b.PropertyAddress,
       coalesce(a.PropertyAddress, b.PropertyAddress)
from nashvillehousing a
         join nashvillehousing b
              on a.parcelid = b.parcelid
                  and a.uniqueid <> b.uniqueid
where a.propertyaddress is null;

-- Updates the propertu address empty fields based on the parcel ids
Update nashvillehousing
SET PropertyAddress = coalesce(a.PropertyAddress, b.PropertyAddress)
from nashvillehousing a
         join nashvillehousing b
              on a.parcelid = b.parcelid
                  and a.uniqueid <> b.uniqueid
where a.propertyaddress is null

-- Breaking out addresses into columns(Address, City, State)

select PropertyAddress
from nashvillehousing;

-- Extracts the text before the comma and after the comma
SELECT SUBSTRING(PropertyAddress, 1, strpos(propertyaddress, ',') - 1) as Address,
       SUBSTRING(PropertyAddress, strpos(propertyaddress, ',') + 1, length(PropertyAddress)) as City
from nashvillehousing;

-- Update the table by adding the address and city in two new columns
ALTER TABLE nashvillehousing
ADD PropertySplitAddress varchar(255);

UPDATE nashvillehousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, strpos(propertyaddress, ',') - 1);

ALTER TABLE nashvillehousing
ADD PropertySplitCity varchar(255);

UPDATE nashvillehousing
SET PropertySplitCity  = SUBSTRING(PropertyAddress, strpos(propertyaddress, ',') + 1, length(PropertyAddress));

-- Update the table by parsing the owner address in three new columns
select split_part(OwnerAddress,',',1),
       split_part(OwnerAddress,',',2),
       split_part(OwnerAddress,',',3)
from nashvillehousing;

ALTER TABLE nashvillehousing
ADD OwnerSplitAddress varchar(255);

UPDATE nashvillehousing
SET OwnerSplitAddress  = split_part(OwnerAddress,',',1);

ALTER TABLE nashvillehousing
ADD OwnerSplitCity varchar(255);

UPDATE nashvillehousing
SET OwnerSplitCity  = split_part(OwnerAddress,',',2);

ALTER TABLE nashvillehousing
ADD OwnerSplitState varchar(255);

UPDATE nashvillehousing
SET OwnerSplitState  = split_part(OwnerAddress,',',3);

select *
from nashvillehousing
