/*  
	Cleansing data
  
  */
 
 select * from [dbo].[Nashville housing]
-----------------------------------------------------------------------------------------------------------------------------
--Standardize Date format
 update [dbo].[Nashville housing]
 set SaleDate = cast(SaleDate as date)

 Alter table [dbo].[Nashville housing]
  add SaleDateConvereted date;
   
 update [dbo].[Nashville housing]
 set SaleDateConvereted = convert(date,SaleDate)
 
 Select SaleDate,SaleDateConvereted
 from [dbo].[Nashville housing]

------------------------------------------------------------------------------------------------------------------------------
--Populate property address data
 select *
 from [dbo].[Nashville housing]
 --where PropertyAddress is null 
 order by ParcelID

 select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress
 from [dbo].[Nashville housing] a
 join [dbo].[Nashville housing] b
 on a.ParcelID = b.ParcelID
 and a.UniqueID<>b.UniqueID 
 where a.PropertyAddress is null

 update a
 set a.PropertyAddress = isnull(a.PropertyAddress,b.PropertyAddress)
 from [dbo].[Nashville housing] a
 join [dbo].[Nashville housing] b
 on a.ParcelID = b.ParcelID
 and a.UniqueID<>b.UniqueID 
 where a.PropertyAddress is null

 ----------------------------------------------------------------------------------------------------------------------------
 --Breaking the address into individual colulmns(Address,city,state)

 select PropertyAddress
 from [dbo].[Nashville housing]
 
 Select substring(PropertyAddress,1,charindex(',',PropertyAddress)-1) as Address,
 substring(PropertyAddress,charindex(',',PropertyAddress)+1,len(PropertyAddress)) as city
 from [dbo].[Nashville housing]

 Alter table [dbo].[Nashville housing]
  add PropertySplitAddress nvarchar(255);
   
 update [dbo].[Nashville housing]
 set PropertySplitAddress = substring(PropertyAddress,1,charindex(',',PropertyAddress)-1)

 Alter table [dbo].[Nashville housing]
 add PropertySplitCity nvarchar(255);

 update [dbo].[Nashville housing]
 set PropertySplitCity =substring(PropertyAddress,charindex(',',PropertyAddress)+1,len(PropertyAddress))

 Select OwnerAddress
 from [dbo].[Nashville housing]

 select 
 PARSENAME(replace(OwnerAddress,',','.'),3),
 PARSENAME(replace(OwnerAddress,',','.'),2),
 PARSENAME(replace(OwnerAddress,',','.'),1)
 from [dbo].[Nashville housing]

 Alter table [dbo].[Nashville housing]
  add OwnerSplitAddress nvarchar(255);
   
 update [dbo].[Nashville housing]
 set OwnerSplitAddress = PARSENAME(replace(OwnerAddress,',','.'),3)

 Alter table [dbo].[Nashville housing]
 add OwnerSplitcity nvarchar(255);
  
 update [dbo].[Nashville housing]
 set OwnerSplitcity = PARSENAME(replace(OwnerAddress,',','.'),2)

 Alter table [dbo].[Nashville housing]
 add OwnerSplitState nvarchar(255);
 
 update [dbo].[Nashville housing]
 set OwnerSplitState = PARSENAME(replace(OwnerAddress,',','.'),1)

 select * from 
 [dbo].[Nashville housing]

------------------------------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "sold as vacant" field
 
 select distinct SoldAsVacant, count('SoldAsVacant')
 from  [dbo].[Nashville housing]
 group by SoldAsVacant
 order by 2

 select SoldAsVacant
 , case when SoldAsVacant = 'Y' Then 'Yes'
        when SoldAsVacant = 'N' Then 'NO'
	else SoldAsVacant
   end
 from [dbo].[Nashville housing]

 update [dbo].[Nashville housing]
 set SoldAsVacant = case when SoldAsVacant = 'Y' Then 'Yes'
        when SoldAsVacant = 'N' Then 'NO'
	else SoldAsVacant
   end

----------------------------------------------------------------------------------------------------------------------------------------------

--Remove Duplicates
 with Row_numCTE as
 (
 select * ,
  ROW_NUMBER() over ( partition by ParcelID, 
					PropertyAddress, 
					SalePrice, 
					SaleDate,
					LegalReference 
					order by UniqueID)row_num
  from [dbo].[Nashville housing]
 -- order by ParcelID
 )
Delete from Row_numCTE
 where row_num >1
-- order by PropertyAddress

-------------------------------------------------------------------------------------------------------------------------------------------------------

--Delete Unused columns

 select * 
 from [dbo].[Nashville housing]

 alter table [dbo].[Nashville housing] 
 drop column PropertyAddress,OwnerAddress,TaxDistrict

  alter table [dbo].[Nashville housing] 
 drop column SaleDate