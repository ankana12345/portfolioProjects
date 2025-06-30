select *
from portfolio_project.dbo.NashvilleHousing

-- standardize date format

select saledateconverted, convert(date, saledate) 
from portfolio_project.dbo.NashvilleHousing

update portfolio_project.dbo.NashvilleHousing
set saledate = convert(date, saledate)

alter table portfolio_project.dbo.NashvilleHousing
add saledateconverted date;

update portfolio_project.dbo.NashvilleHousing
set saledateconverted = convert(date, saledate)

--populate property address data

select *  
from portfolio_project.dbo.NashvilleHousing
--where PropertyAddress is null 
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
from portfolio_project.dbo.NashvilleHousing a
join portfolio_project.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

update a
set a.PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
from portfolio_project.dbo.NashvilleHousing a
join portfolio_project.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null;

--breaking out address into individual columns

select PropertyAddress  
from portfolio_project.dbo.NashvilleHousing
--where PropertyAddress is null 
--order by ParcelID

select 
substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as address, 
substring(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, len(PropertyAddress)) as address
from portfolio_project.dbo.NashvilleHousing

alter table portfolio_project.dbo.NashvilleHousing
add propertysplitaddress nvarchar(255)

update portfolio_project.dbo.NashvilleHousing
set propertysplitaddress = substring(PropertyAddress, 1, charindex(',', PropertyAddress)-1)

alter table portfolio_project.dbo.NashvilleHousing
add propertysplitcity nvarchar(255)

update portfolio_project.dbo.NashvilleHousing
set propertysplitcity = substring(PropertyAddress, charindex(',', PropertyAddress)+1, len(PropertyAddress))

select *
from portfolio_project.dbo.NashvilleHousing

select OwnerAddress
from portfolio_project.dbo.NashvilleHousing

--easier way to seperate address
select 
parsename (replace(OwnerAddress, ',', '.'),3),
parsename (replace(OwnerAddress, ',', '.'),2),
parsename (replace(OwnerAddress, ',', '.'),1)
from portfolio_project.dbo.NashvilleHousing

alter table portfolio_project.dbo.NashvilleHousing
add ownersplitaddress nvarchar(255)

update portfolio_project.dbo.NashvilleHousing
set ownersplitaddress = parsename (replace(OwnerAddress, ',', '.'),3)

alter table portfolio_project.dbo.NashvilleHousing
add ownersplitcity nvarchar(255)

update portfolio_project.dbo.NashvilleHousing
set ownersplitcity = parsename (replace(OwnerAddress, ',', '.'),2)

alter table portfolio_project.dbo.NashvilleHousing
add ownersplitstate nvarchar(255)

update portfolio_project.dbo.NashvilleHousing
set ownersplitstate = parsename (replace(OwnerAddress, ',', '.'),1)

select *
from portfolio_project.dbo.NashvilleHousing

select distinct(SoldAsVacant), count(SoldAsVacant)
from portfolio_project.dbo.NashvilleHousing
group by SoldAsVacant
order by 2

--changing all y to yes and all n to no

select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
when SoldAsVacant = 'n' then 'No'
else SoldAsVacant
end
from portfolio_project.dbo.NashvilleHousing

update portfolio_project.dbo.NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
when SoldAsVacant = 'n' then 'No'
else SoldAsVacant
end

--remove duplicates

with rownumCTE as (
select *,
row_number() over
(
partition by ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
order by 
UniqueID
) row_num
from portfolio_project.dbo.NashvilleHousing
--order by ParcelID
)
select *
from rownumCTE
where row_num > 1
--order by PropertyAddress


--delete unused columns

select *
from portfolio_project.dbo.NashvilleHousing

alter table portfolio_project.dbo.NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress

alter table portfolio_project.dbo.NashvilleHousing
drop column SaleDate

