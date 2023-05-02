select * 
from [portfolio project]..[nashville housing]


--standardize date format
--the following query shows the redundant date in sales date and get only needed data
select SaleDate, CONVERT(date,saledate)
from [portfolio project]..[nashville housing]

update [nashville housing]
set SaleDate=CONVERT(date,saledate)

alter table [nashville housing]
add sale_date2 date

update [nashville housing]
set sale_date2 =CONVERT(date,saledate)

select sale_date2
from [portfolio project]..[nashville housing]


--popularize the property data
--the following data shows the null values in property address and using parcel id as reference populates the null values

select PropertyAddress
from [portfolio project]..[nashville housing]
where PropertyAddress is null

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
from [portfolio project]..[nashville housing] A
join [portfolio project]..[nashville housing] B
	on a.ParcelID = b.parcelID
	and a.[UniqueID ] <> b.[UniqueID ] 
where a.PropertyAddress is null

update A
set PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
from [portfolio project]..[nashville housing] A
join [portfolio project]..[nashville housing] B
	on a.ParcelID = b.parcelID
	and a.[UniqueID ] <> b.[UniqueID ] 

-- checking tables of property
select PropertyAddress
from [portfolio project]..[nashville housing]
where PropertyAddress is null

--breaking down address into  individual columns(address,city)

select propertyaddress
from [portfolio project]..[nashville housing]

SELECT 
PARSENAME(REPLACE(PROPERTYADDRESS,',','.'),2),
PARSENAME(REPLACE(PROPERTYADDRESS,',','.'),1)
from [portfolio project]..[nashville housing]

alter table [nashville housing]
add PROPERTYADDRESS_main NVARCHAR(255)

update [nashville housing]
set PROPERTYADDRESS_main   =PARSENAME(REPLACE(PROPERTYADDRESS,',','.'),2)

alter table [nashville housing]
add PROPERTYADDRESS_CITY NVARCHAR(255)

update [nashville housing]
set PROPERTYADDRESS_CITY  =PARSENAME(REPLACE(PROPERTYADDRESS,',','.'),1)

--breaking down owner address into  individual columns(address,city,States)
SELECT 
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
from [portfolio project]..[nashville housing]

alter table [nashville housing]
add OwnerAddress_NAME NVARCHAR(255)

update [nashville housing]
set OwnerAddress_NAME  =PARSENAME(REPLACE(OwnerAddress,',','.'),3)

alter table [nashville housing]
add  OwnerAddress_CITY NVARCHAR(255)

update [nashville housing]
set  OwnerAddress_CITY  =PARSENAME(REPLACE(PROPERTYADDRESS,',','.'),2)

alter table [nashville housing]
add  OwnerAddress_STATE NVARCHAR(255)

update [nashville housing]
set  OwnerAddress_STATE  =PARSENAME(REPLACE(OwnerAddress,',','.'),1)

--making the soldas vacant column contain yes/no only


select distinct SoldAsVacant ,count (soldasvacant) as count
from [portfolio project]..[nashville housing]
group by SoldAsVacant
order by 2


select SoldAsVacant,
	case when SoldAsVacant = 'y' then 'yes'
		 when SoldAsVacant = 'n' then 'no'
		 else SoldAsVacant
		 end
from [portfolio project]..[nashville housing]

update [nashville housing]
set SoldAsVacant=	case when SoldAsVacant = 'y' then 'yes'
					when SoldAsVacant = 'n' then 'no'
					else SoldAsVacant
					end

--removing duplicates


with row_numcte as(
select *,
	ROW_NUMBER() over(
		partition by parcelid,
					 propertyaddress,
					 saledate,
					 saleprice,
					 legalreference
					 order by
					 uniqueid) as row_num



from [portfolio project]..[nashville housing]
)
select *
from row_numcte
where row_num > 1


--deleting unused columns

alter table [portfolio project]..[nashville housing]
drop column saledate,propertyaddress_name

select * 
from [portfolio project]..[nashville housing]