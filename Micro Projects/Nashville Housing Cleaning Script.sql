/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [UniqueID ]
      ,[ParcelID]
      ,[LandUse]
      ,[PropertyAddress]
      ,[SaleDate]
      ,[SalePrice]
      ,[LegalReference]
      ,[SoldAsVacant]
      ,[OwnerName]
      ,[OwnerAddress]
      ,[Acreage]
      ,[TaxDistrict]
      ,[LandValue]
      ,[BuildingValue]
      ,[TotalValue]
      ,[YearBuilt]
      ,[Bedrooms]
      ,[FullBath]
      ,[HalfBath]
  FROM [Portfolio Project].[dbo].[NashvilleHousing]


  -- Standardize date format 
  Select CONVERT(DATE,SUBSTRING(CONVERT(VARCHAR, SaleDate),1,11)) AS a1,CONVERT(Date, SaleDate) As b1
  FROM [Portfolio Project]..NashvilleHousing
 
 Alter Table NashvilleHousing
 ADD SaleDateConverted Date;

  Update NashvilleHousing
  SET SaleDateConverted = CONVERT(DATE,SaleDate)

 Select SaleDate, SaleDateConverted
  FROM [Portfolio Project]..NashvilleHousing

  --Populate Property Adress data
  Select *
  From [Portfolio Project]..NashvilleHousing
  --Where PropertyAddress IS NULL
  order by ParcelID
  -- NOTE: parcel ID and Address are equivalent, ie if an adress has address x, it will always have id y. 

  Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
  From [Portfolio Project]..NashvilleHousing as a
  JOIN [Portfolio Project]..NashvilleHousing as b
  ON a.ParcelID = b.ParcelID
  AND a.[UniqueID ] <> b.[UniqueID ]
  where a.PropertyAddress IS NULL

  Update a
  SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
  From [Portfolio Project]..NashvilleHousing as a
  JOIN [Portfolio Project]..NashvilleHousing as b
  ON a.ParcelID = b.ParcelID
  AND a.[UniqueID ] <> b.[UniqueID ]
  where a.PropertyAddress IS NULL

 -- Breaking out the adress into individual Columns (Adress, city and state)

 Select PropertyAddress
 FROM [Portfolio Project]..NashvilleHousing



  Select  
  Substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
  Substring(PropertyAddress, CHARINDEX(',', PropertyAddress)+1,LEN(PropertyAddress)) as City
 FROM [Portfolio Project]..NashvilleHousing

 Alter Table NashvilleHousing
 ADD PropertySplitAddress Nvarchar(255);

 Update NashvilleHousing
 SET PropertySplitAddress = Substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

 Alter Table NashvilleHousing
 ADD PropertySplitCity Nvarchar(255);

  Update NashvilleHousing
 SET PropertySplitCity = Substring(PropertyAddress, CHARINDEX(',', PropertyAddress)+1,LEN(PropertyAddress))

 Select PropertySplitAddress, PropertySplitCity
 FROM NashvilleHousing


  Alter Table NashvilleHousing
 ADD OwnerSplitAddress Nvarchar(255);

 
  Alter Table NashvilleHousing
 ADD OwnerSplitCity Nvarchar(255);

 
  Alter Table NashvilleHousing
 ADD OwnerSplitState Nvarchar(255);
 
 Update NashvilleHousing
 SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'), 3)

  Update NashvilleHousing
 SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'), 2)

  Update NashvilleHousing
 SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'), 1)

Select *
From NashvilleHousing


-- Change Y and N to yes and No in Sold as Vacant Field

Select DISTINCT(SoldAsVacant), Count(SoldAsVacant)
From NashvilleHousing
Group BY SoldAsVacant
order by 2

Update NashvilleHousing
SET SoldAsVacant = CASE
WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'Yes' THEN 'Yes'
ELSE SoldAsVacant
END;

--Remove Duplicates
WITH RowNumCTE AS(
Select *, 
ROW_NUMBER() OVER (PARTITION BY parcelID, 
PropertyAddress, 
SalePrice, 
SaleDate, 
LegalReference 
ORDER BY UniqueID) row_num
From NashvilleHousing
--order by ParcelID
)
DELETE
FROM RowNumCTE
WHERE row_num > 1
order by PropertyAddress

-- DELETE Unused Columns 

Select *
From NashvilleHousing

Alter Table NashvilleHousing
DROP COLUMN SaleDate, PropertyAddress, OwnerAddress