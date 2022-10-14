
select *
from nashville_rs


-- standardize date format

select SaleDate, CONVERT(Date, SaleDate) as sale_date
from nashville_rs

update nashville_rs
set SaleDate = CONVERT(Date, SaleDate)

-- fill empty property address 

select *
from nashville_rs
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) as filling
from nashville_rs as a
join nashville_rs as b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from nashville_rs as a
join nashville_rs as b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-- split out Property_address into address, city & state

select substring(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address,
substring(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) as City
from nashville_rs

ALTER TABLE nashville_rs
Add PropertySplitAddress Nvarchar(255);

Update nashville_rs
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE nashville_rs
Add PropertySplitCity Nvarchar(255);

Update nashville_rs
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

select*
from nashville_rs


-- same process above with owner address
select 
PARSENAME (Replace(OwnerAddress,',','.'),3) as address, 
PARSENAME (Replace(OwnerAddress,',','.'),2) as city,
PARSENAME (Replace(OwnerAddress,',','.'),1) as state
from nashville_rs

ALTER TABLE nashville_rs
Add ownerSplitAddress Nvarchar(255);

Update nashville_rs
SET  ownerSplitAddress = PARSENAME (Replace(OwnerAddress,',','.'),3)


ALTER TABLE nashville_rs
Add ownerSplitCity Nvarchar(255);

Update nashville_rs
SET ownerSplitCity = PARSENAME (Replace(OwnerAddress,',','.'),2)

ALTER TABLE nashville_rs
Add ownerSplitstate Nvarchar(255);

Update nashville_rs
SET ownerSplitstate = PARSENAME (Replace(OwnerAddress,',','.'),1)

select*
from nashville_rs


-- replace 'Y' & 'N' for "Yes" & "No" in "Sold as vacant" field

select distinct (soldasvacant), count(soldasvacant) as counting
from nashville_rs
group by SoldAsVacant
order by 2

select soldasvacant, 
case when SoldAsVacant = 'Y' then 'Yes'
when SoldAsVacant = 'N' then 'No'
else soldasvacant
end
from nashville_rs

update nashville_rs
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
when SoldAsVacant = 'N' then 'No'
else soldasvacant
end

--remove duplicates

with row_num_cte as(
select*, 
ROW_NUMBER() over (partition by parcelid,propertyaddress,saleprice,saledate,legalreference order by uniqueid) row_num
from nashville_rs
)
delete
from row_num_cte
where row_num > 1 

-- deleting unused columns

alter table nashville_rs
drop column owneraddress, taxdistrict, propertyaddress
alter table nashville_rs
drop column saledate

select*
from nashville_rs