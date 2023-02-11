---Data cleaning of a database of Nashville data housing

---Look at the data
SELECT *
FROM HousingData.dbo.HousingData


---Some rows of the PropertyAddress are null but same ParcelId have the same property address so we can use parcel id column to populate null rows
SELECT *, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM HousingData.dbo.HousingData as a join HousingData.dbo.HousingData as b on a.ParcelID=b.ParcelID and a.UniqueID<>b.UniqueID
where a.PropertyAddress is null


UPDATE a
SET PropertyAddress=ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM HousingData.dbo.HousingData as a join HousingData.dbo.HousingData as b on a.ParcelID=b.ParcelID and a.UniqueID<>b.UniqueID
where a.PropertyAddress is null

---Transform SalesDate type from datetime to date

ALTER TABLE HousingData.dbo.HousingData
add SaleDateConv Date;

Update HousingData.dbo.HousingData
set SaleDateConv=convert(date,SaleDate)


---Divide Property Address column in address and city

---Method 1
select PropertyAddress,SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) AS Address, SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as City
FROM HousingData.dbo.HousingData

---METHOD 2
Select PARSENAME(REPLACE(PropertyAddress,',','.'),2), PARSENAME(REPLACE(PropertyAddress,',','.'),1)
FROM HousingData.dbo.HousingData

Alter table HousingData.dbo.HousingData
add Property_Address NVARCHAR(255)

UPDATE HousingData.dbo.HousingData
SET Property_Address=SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

Alter table HousingData.dbo.HousingData
add City_Address NVARCHAR(255)

UPDATE HousingData.dbo.HousingData
SET City_Address=SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))

select *
from HousingData.dbo.HousingData


---Divide Owner Address column in address and city
Select PARSENAME(REPLACE(OwnerAddress,',','.'),3),PARSENAME(REPLACE(OwnerAddress,',','.'),2), PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM HousingData.dbo.HousingData

Alter table HousingData.dbo.HousingData
add Owner_Address NVARCHAR(255)

UPDATE HousingData.dbo.HousingData
SET Owner_Address=PARSENAME(REPLACE(OwnerAddress,',','.'),3)


Alter table HousingData.dbo.HousingData
add Owner_City NVARCHAR(255)

UPDATE HousingData.dbo.HousingData
SET Owner_City=PARSENAME(REPLACE(OwnerAddress,',','.'),2)

Alter table HousingData.dbo.HousingData
add Owner_State NVARCHAR(255)

UPDATE HousingData.dbo.HousingData
SET Owner_State=PARSENAME(REPLACE(OwnerAddress,',','.'),1)


---Clean SoldAsVacant column

---Method 1 (Just Y and N)
Alter table HousingData.dbo.HousingData
add SoldAsVacantCleaned CHAR(1)

UPDATE HousingData.dbo.HousingData
SET SoldAsVacantCleaned=SUBSTRING(SoldAsVacant,1 , LEN(1))

---Method 2 (Just Yes and No)
Update HousingData.dbo.HousingData
SET SoldAsVacant= case when SoldAsVacant='Y' Then 'Yes'
	when SoldAsVacant='N' Then 'No'
	else SoldAsVacant
	end

---Remove duplicates column

with RowNumb as (select *,
ROW_NUMBER() 
OVER (PARTITION BY ParcelID, LandUse, PropertyAddress, SaleDate, SalePrice, LegalReference, SoldAsVacant
ORDER BY UniqueID) Row_Numb
from HousingData.dbo.HousingData
)
delete 
from RowNumb
where Row_Numb>1

---Delete old columns
select * 
FROM HousingData.dbo.HousingData


ALTER TABLE  HousingData.dbo.HousingData
DROP COLUMN SaleDate, OwnerName, PropertyAddress, SoldAsVacant

