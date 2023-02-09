/*

Cleaning Data in SQL Queries

*/

Select * 
from PorfolioProject.dbo.NashvilleHousing



------------------------------------------------------

--Standardize Date Format


Select SalesDateConverted, CONVERT(Date,Saledate)
from PorfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)


alter Table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)



---------------------------------------------
-- Populate Property Address Data


select *
from PorfolioProject.dbo.NashvilleHousing
--where PropertyAddress is null
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from PorfolioProject.dbo.NashvilleHousing a
join PorfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from PorfolioProject.dbo.NashvilleHousing a
join PorfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null



---breaking out Address into Inddividual columns (address, city , state)

select PropertyAddress
from PorfolioProject.dbo.NashvilleHousing
--where PropertyAddress is null
--order by ParcelID

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as Address
from PorfolioProject.dbo.NashvilleHousing

alter Table NashvilleHousing
Add PropertySplitAddress Nvarchar(255)

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

alter Table NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))

Select * 
from PorfolioProject.dbo.NashvilleHousing

Select OwnerAddress
from PorfolioProject.dbo.NashvilleHousing

Select
PARSENAME(replace(OwnerAddress, ',','.'),3),
PARSENAME(replace(OwnerAddress, ',','.'),2),
PARSENAME(replace(OwnerAddress, ',','.'),1)
from PorfolioProject.dbo.NashvilleHousing


alter Table NashvilleHousing
Add OwnerSplitAddress Nvarchar(255)

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(replace(OwnerAddress, ',','.'),3)

alter Table NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(replace(OwnerAddress, ',','.'),2)

alter Table NashvilleHousing
Add OwnerSplitState Nvarchar(255)

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(replace(OwnerAddress, ',','.'),1)


Select * 
from PorfolioProject.dbo.NashvilleHousing


---------------------------------------------------------------------------------------------------

---Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
from PorfolioProject.dbo.NashvilleHousing
group by SoldAsVacant
order by 2


Select SoldAsVacant,
Case when SoldAsVacant = 'Y' Then 'Yes'
	When SoldAsVacant =  'N' Then 'No'
	Else SoldAsVacant
	End
from PorfolioProject.dbo.NashvilleHousing

update NashvilleHousing
SET SoldAsVacant = Case when SoldAsVacant = 'Y' Then 'Yes'
	When SoldAsVacant =  'N' Then 'No'
	Else SoldAsVacant
	End





------------------------------------------------------------------------------------------------
----Remove Duplicates

WITH RowNumCTE AS(
Select *, 
	ROW_NUMBER() OVER (
	PARTItion by ParcelID,
	SalePrice,
	SaleDate,
	LegalReference
	ORDER BY 
			UniqueID) row_num
from PorfolioProject.dbo.NashvilleHousing
--order by ParcelID
)


Select *
from RowNumCTE
where row_num > 1
order by PropertyAddress



----------------------------------------------------------------------------------------------
--- Delete Unused Columns


Select * 
from PorfolioProject.dbo.NashvilleHousing

ALTER TABLE PorfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PorfolioProject.dbo.NashvilleHousing
DROP COLUMN SaleDate