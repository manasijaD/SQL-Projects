Select * 
From PortfolioProject.dbo.HousingData

--Standardized Date 

Select SaleDateNew, CONVERT(DATE,SaleDate)
From PortfolioProject.dbo.HousingData

alter table HousingData
add SaleDateNew date;
Update HousingData
Set SaleDateNew = CONVERT(DATE,SaleDate)

--Populate Property Addres Data 
Select *
From PortfolioProject.dbo.HousingData
--where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.HousingData a 
join PortfolioProject.dbo.HousingData b 
on a.ParcelID = b.ParcelID
AND a.[UniqueID ] < > b.[UniqueID]
Where a.PropertyAddress is null

Update a 
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.HousingData a
JOIN PortfolioProject.dbo.HousingData b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

--Breaking out address into Individual Columns(Address,City,Sate) 


SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address
From PortfolioProject.dbo.HousingData

ALTER TABLE PortfolioProject.dbo.HousingData
Add PropertySplitAddress Nvarchar(255);

Update PortfolioProject.dbo.HousingData
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE PortfolioProject.dbo.HousingData
Add PropertySplitCity Nvarchar(255);

Update PortfolioProject.dbo.HousingData
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

Select *
From PortfolioProject.dbo.HousingData

ALTER TABLE PortfolioProject.dbo.HousingData
Add OwnerSplitAddress Nvarchar(255);

Update PortfolioProject.dbo.HousingData
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE PortfolioProject.dbo.HousingData
Add OwnerSplitCity Nvarchar(255);

Update PortfolioProject.dbo.HousingData
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE PortfolioProject.dbo.HousingData
Add OwnerSplitState Nvarchar(255);

Update PortfolioProject.dbo.HousingData
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)



Select *
From PortfolioProject.dbo.HousingData

-- -- Change Y and N to Yes and No in "Sold as Vacant" field
Select SoldAsVacant, count(SoldAsVacant)
From PortfolioProject.dbo.HousingData
group by SoldAsVacant
order by count(SoldAsVacant) desc

Select SoldAsVacant, 
Case when SoldAsVacant = 'N' then 'No'
         when SoldAsVacant = 'Y' then 'Yes'
		 else SoldAsVacant 
		 End
From PortfolioProject.dbo.HousingData
--where SoldAsVacant = 'N'

Update PortfolioProject.dbo.HousingData
SET SoldAsVacant = Case when SoldAsVacant = 'N' then 'No'
         when SoldAsVacant = 'Y' then 'Yes'
		 else SoldAsVacant 
		 End
-- Remove Duplicates 
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

From PortfolioProject.dbo.HousingData
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress



Select *
From PortfolioProject.dbo.HousingData

-- Delete Unused Columns
Select *
From PortfolioProject.dbo.HousingData



ALTER TABLE PortfolioProject.dbo.HousingData

DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate










