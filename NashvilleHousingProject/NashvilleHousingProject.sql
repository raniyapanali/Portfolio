--Cleaning dataset project

select *
from portfolio..NashvilleHousing

--standardize date format

select SaleDate, convert(date, SaleDate)
from portfolio..NashvilleHousing

alter table portfolio..NashvilleHousing
add SaleDateConverted date;

UPDATE portfolio..NashvilleHousing
set SaleDateConverted = convert(date, SaleDate)

--Populate Propertyaddress data

select a.PropertyAddress, b.PropertyAddress, a.ParcelID, b.ParcelID, isnull(a.PropertyAddress, b.PropertyAddress)
from portfolio..NashvilleHousing a
JOIN portfolio..NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
from portfolio..NashvilleHousing a
JOIN portfolio..NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress IS NULL

--Breaking down PropertyAddress into individual columns(Address, City)

select SUBSTRING(PropertyAddress, 1, charindex(',', PropertyAddress)-1) as Address,
 SUBSTRING(PropertyAddress, charindex(',', PropertyAddress)+1, LEN(PropertyAddress)) AS City
from portfolio..NashvilleHousing

ALTER TABLE portfolio..NashvilleHousing
add PropertySplitAddress Nvarchar(255) ;

UPDATE portfolio..NashvilleHousing
set 
PropertySplitAddress = SUBSTRING(PropertyAddress, 1, charindex(',', PropertyAddress)-1)

ALTER TABLE portfolio..NashvilleHousing
add PropertySplitCity Nvarchar(255) ;

UPDATE portfolio..NashvilleHousing
set
PropertySplitCity = SUBSTRING(PropertyAddress, charindex(',', PropertyAddress)+1, LEN(PropertyAddress))

ALTER TABLE portfolio..NashvilleHousing
drop column City ;


ALTER TABLE portfolio..NashvilleHousing
drop column Address ;

select *
from portfolio..NashvilleHousing

--Breaking down OwnerAddress into Address, city and state

SELECT PARSENAME(REPLACE(OwnerAddress,',', '.'), 3) AS OwnerSplitAddress
from portfolio..NashvilleHousing

SELECT PARSENAME(REPLACE(OwnerAddress,',', '.'), 2) AS OwnerSplitCity
from portfolio..NashvilleHousing

SELECT PARSENAME(REPLACE(OwnerAddress,',', '.'), 1) AS OwnerSplitState
from portfolio..NashvilleHousing

ALTER TABLE portfolio..NashvilleHousing
add OwnerSplitAddress nvarchar(255)

update NashvilleHousing
set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',', '.'), 3) 
from portfolio..NashvilleHousing

alter table portfolio..NashvilleHousing
add OwnerSplitCity nvarchar(255)

update NashvilleHousing
set OwnerSplitCity = PARSENAME(replace(OwnerAddress, ',', '.'),2)
from portfolio..NashvilleHousing

ALTER TABLE portfolio..NashvilleHousing
add OwnerSplitState nvarchar(255) 

Update NashvilleHousing
set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
from portfolio..NashvilleHousing
 
ALTER TABLE portfolio..NashvilleHousing
DROP COLUMN OwnerCity

select *
from portfolio..NashvilleHousing

--Change 0 or 1 in SoldAsVacant to Yes or No

select SoldAsVacant
from portfolio..NashvilleHousing 
 
alter table portfolio..NashvilleHousing
alter column SoldAsVacant char(3)

select SoldAsVacant,
  case when SoldAsVacant = '0' then 'No'
       when SoldAsVacant = '1' then 'Yes'
       else SoldAsVacant
  end
from portfolio..NashvilleHousing

update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = '0' then 'No'
                        when SoldAsVacant = '1' then 'Yes'
                        else SoldAsVacant
                        end
from portfolio..NashvilleHousing

update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'N' then 'No'
                        when SoldAsVacant = 'Y' then 'Yes'
                        else SoldAsVacant
                        end
from portfolio..NashvilleHousing

select *
from portfolio..NashvilleHousing

SELECT DISTINCT SoldAsVacant, count(SoldAsVacant)
from portfolio..NashvilleHousing
group by SoldAsVacant

--Remove duplicates

with RowNumCTE 
AS (
select *, ROW_NUMBER()
  over(PARTITION BY ParcelID, LandUse, PropertyAddress, SaleDate, SalePrice, LegalReference
  order by UniqueID) AS RowNum
from portfolio..NashvilleHousing)

SELECT * 
FROM RowNumCTE
where RowNum > 1

--Delete unused columns
  
alter table portfolio..NashvilleHousing
drop column PropertyAddress, SaleDate,  OwnerAddress, TaxDistrict

select *
from portfolio..NashvilleHousing