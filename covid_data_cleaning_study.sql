
				-- STANDARDIZE DATE FORMAT -- 

-- just date, no time
select CONVERT(date,SaleDate) from homesales  


-- first create new null column and then update that
ALTER TABLE homesales
Add SaleDateConverted Date;
Update homesales
SET SaleDateConverted = CONVERT(Date,SaleDate)



				-- POPULATE PROPERTY ADDRESS DATA --

-- how many empty cells are there ?
select count(*) PropertyAddress from homesales
where  PropertyAddress is null


-- fill these with who has same parcelID
select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress from homesales a
join homesales b on a.ParcelID = b.ParcelID and a.[UniqueID ] != b.[UniqueID ]
where a.PropertyAddress is null


select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from homesales a
join homesales b on a.ParcelID = b.ParcelID and a.[UniqueID ] != b.[UniqueID ]
where a.PropertyAddress is null


update a set a.PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from homesales a
join homesales b on a.ParcelID = b.ParcelID and a.[UniqueID ] != b.[UniqueID ]
where a.PropertyAddress is null


select count(*) PropertyAddress from homesales
where  PropertyAddress is null



		-- BREAKING OUT ADDRESS INTO INDIVIDUAL COLUMNS (ADDRESS, CITY, STATE) --

select PropertyAddress from homesales


select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS Suburb
from homesales




alter table homesales add adress varchar(255)
update homesales set adress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

alter table homesales add suburb varchar(255)
update homesales set suburb  = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


-- 2. way 

select 
PARSENAME(REPLACE(PropertyAddress, ',', '.'), 2),
PARSENAME(REPLACE(PropertyAddress, ',', '.'), 1)
from homesales


alter table homesales add adress2 varchar(255)
update homesales set adress2 = PARSENAME(REPLACE(PropertyAddress, ',', '.'), 2)

alter table homesales add suburb2 varchar(255)
update homesales set suburb2  = PARSENAME(REPLACE(PropertyAddress, ',', '.'), 1)



select OwnerAddress from homesales


Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From homesales


ALTER TABLE homesales Add OwnerSplitAddress Nvarchar(255)
Update homesales
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE homesales Add OwnerSplitCity Nvarchar(255)
Update homesales 
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE homesales Add OwnerSplitState Nvarchar(255)
Update homesales
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)




		-- CHANGE Y AND N TO YES AND NO IN "SOLD AS VACANT" FIELD --

SELECT SoldAsVacant FROM homesales

SELECT 
CASE
	WHEN SoldAsVacant = 'Y' then 'YES'
	WHEN SoldAsVacant = 'N' THEN 'NO'
	ELSE SoldAsVacant
END
FROM homesales

UPDATE homesales SET SoldAsVacant = CASE
	WHEN SoldAsVacant = 'Y' then 'YES'
	WHEN SoldAsVacant = 'N' THEN 'NO'
	ELSE SoldAsVacant
END



			-- REMOVE DUPLICATES--


Select *,ROW_NUMBER() OVER (
PARTITION BY ParcelID,PropertyAddress,SalePrice,SaleDate,LegalReference
ORDER BY
UniqueID
) row_num
From homesales
order by row_num desc

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

From homesales
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

-- OR

select * FROM 
(Select *,ROW_NUMBER() OVER (
PARTITION BY ParcelID,PropertyAddress,SalePrice,SaleDate,LegalReference
ORDER BY
UniqueID
) row_num
From homesales)T
WHERE row_num > 1


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

From homesales
--order by ParcelID
)
DELETE
From RowNumCTE
Where row_num > 1




				-- DELETE UNUSED COLUMNS--

ALTER TABLE homesales DROP COLUMN adress2, suburb2

