-- select all

select *
from Housing

-- standarize date

select SaleDateConverted,CONVERT(date,SaleDate)
from Housing

update Housing
set SaleDate = CONVERT(date,SaleDate)

alter table housing
add SaleDateConverted date

update Housing
set SaleDateConverted = CONVERT(date,SaleDate)

-- Populate property address data

select *
from Housing
where PropertyAddress is null
order by UniqueID 

-- Joining itself to populate address
-- Matching ParcedId with different UniqueId
select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from Housing a
join Housing b
	on a.ParcelID = b.ParcelID
	and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null

-- Upadating using alias
update a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from Housing a
join Housing b
	on a.ParcelID = b.ParcelID
	and a.UniqueID <> b.UniqueID

-- Breaking the address to addres, city columns

select PropertyAddress
from Housing
order by UniqueID 

-- Substring to delimitated by the comma and split in two columns aswell.
select
SUBSTRING(PropertyAddress, 1,CHARINDEX(',',PropertyAddress) - 1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) + 1, LEN(PropertyAddress)) as City
from Housing

alter table housing
add PropertySplitAddress nvarchar(50)

update Housing
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1,CHARINDEX(',',PropertyAddress) - 1)

alter table housing
add PropertySplitCity nvarchar(50)

update Housing
set PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) + 1, LEN(PropertyAddress))

select *
from Housing

-- Same with owner's address
-- Using parsename to retrive a specific part of the address.
select
PARSENAME(replace(owneraddress,',','.'),3) as OwnerAddress,
PARSENAME(replace(owneraddress,',','.'),2) as OwnerCity,
PARSENAME(replace(owneraddress,',','.'),1) as OwnerState
from Housing

alter table housing
add OwnerSplitAddress nvarchar(50)

update Housing
set OwnerSplitAddress = PARSENAME(replace(owneraddress,',','.'),3)

alter table housing
add OwnerSplitCity nvarchar(50)

update Housing
set OwnerSplitCity = PARSENAME(replace(owneraddress,',','.'),2)

alter table housing
add OwnerSplitState nvarchar(50)

update Housing
set OwnerSplitState = PARSENAME(replace(owneraddress,',','.'),1)

select *
from Housing

-- Change y and n to yes and no in soldasvacant.

select distinct(SoldAsVacant), COUNT(SoldAsVacant)
from Housing
group by SoldAsVacant

select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end
from Housing

update Housing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end
from Housing

-- Remove duplicates
-- Checking duplicated values on those columns
WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From Housing
--order by ParcelID
)
Select *
From RowNumCTE
where row_num > 1
order by propertyaddress

-- Delete unused columns

Select *
From Housing

ALTER TABLE Housing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

