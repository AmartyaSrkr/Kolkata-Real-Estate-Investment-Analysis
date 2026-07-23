drop table if exists kolkata_real_estate;

create table kolkata_real_estate (
	id integer primary key, 
	property_name text, 
	area_str text, 
	furnishing text, 
	transaction_type text, 
	status text, 
	price_str text
);

copy kolkata_real_estate (id, property_name, area_str, furnishing, transaction_type, status, price_str)
from 'D:/real_estate_properties.csv'
delimiter ','
csv header;

-- We need to alter table to make room for the clean data 
alter table kolkata_real_estate 
add column area_sqft numeric, 
add column price_inr numeric, 
add column property_type text, 
add column location text;

update kolkata_real_estate 
set
	-- 1. Clean Area: Remove "sqrt" and converting into numbers 
	area_sqft = cast(replace(area_str, ' sqft', '') as numeric),

	-- 2. Clean Price: Remove "₹", handle "Lac" and "Cr"
	price_inr = case
		when price_str like '%Lac' then 
			cast(replace(replace(price_str, '₹', ''), ' Lac', '') as numeric) * 100000
		when price_str like '%Cr' then 
			cast(replace(replace(price_str, '₹', ''), 'Cr', '') as numeric) * 10000000
        else null 
	end, 

	-- 3. Feature Engineering: Extract property type (everything before " for Sale")
	property_type = substring(property_name from '^(.*?)\s+for Sale'),

	-- 4. Feature Engineering: Extract location (everything after "in ")
	location = substring(property_name from 'in (.*)$');


-- Exploratory Data Analysis 
-- 1. Property Type Overview and Pricing Trend 
select 
	property_type,
	count(*) as total_properties, 
	round(avg(area_sqft), 0) as avg_area_sqft,
	round(avg(price_inr), 0) as avg_price_inr, 
	round(avg(price_inr / area_sqft), 0) as avg_price_per_sqft
from kolkata_real_estate 
where property_type is not null and area_sqft > 0 
group by property_type 
order by total_properties desc;

-- 2. top 10 most expensive locations 
select 
	location, 
	count(*) as property_count, 
	round(avg(price_inr), 0) as avg_total_price, 
	round(avg(price_inr / area_sqft), 0) as avg_price_per_sqft
from kolkata_real_estate 
where location is not null and area_sqft > 0 
group by location 
having count(*) >= 5
order by avg_price_per_sqft desc 
limit 10;

-- 3. Impact of Furnishing 
select 
	coalesce(furnishing, 'Not Specified') as furnishing_status,
	count(*) as listing_count, 
	round(avg(price_inr), 0) as avg_price, 
	round(avg(price_inr / area_sqft), 0) as avg_price_per_sqft
from kolkata_real_estate 
where area_sqft > 0 
group by furnishing_status 
order by avg_price_per_sqft desc; 

-- 4. Ranking Properties by Price per Location 
with RankedProperties as (
	select 
		property_name, 
		location,
		property_type, 
		price_inr,
		area_sqft,
		round(price_inr / area_sqft, 0) as price_per_sqft, 
		rank() over (partition by location order by price_inr desc) as price_rank
	from kolkata_real_estate 
	where location is not null and area_sqft > 0 
)
select 
	location, 
	price_rank, 
	property_name, 
	property_type, 
	price_inr, 
	price_per_sqft 
from RankedProperties 
where price_rank <= 3 
order by location, price_rank;


-- Price Segmentation 
-- BA: How is the Kolkata real estate market distributed across different budget tiers, are most homes budget-friendly or luxury?
select 
	case 
		when price_inr < 5000000 then '1. Budget (< 50 Lac)'
		when price_inr between 5000000 and 10000000 then '2. Mid-Range (50 Lac - 1 Cr)'
		when price_inr between 10000000 and 20000000 then '3. Premium (1 Cr - 2 Cr)'
		else '4. Luxury (>2 Cr)'
	end as price_tier,
	count(*) as total_properties, 
	round(avg(area_sqft), 0) as avg_area_sqft 
from kolkata_real_estate 
where price_inr is not null 
group by price_tier 
order by price_tier; 


-- Indetification of "Oversized" properties 
-- BA: Which specific properties offer significantly more space than the average for their property type?
with AverageSizes as (
	select 
		property_type, 
		avg(area_sqft) as avg_type_area 
	from kolkata_real_estate 
	where area_sqft > 0 
	group by property_type 
)
select 
	k.property_name, 
	k.location, 
	k.property_type, 
	k.area_sqft as actual_area, 
	round(a.avg_type_area, 0) as average_area_for_type, 
	k.price_inr 
from kolkata_real_estate k 
join AverageSizes a on k.property_type = a.property_type 
where k.area_sqft > (a.avg_type_area * 1.30) -- 30% larger than average
order by k.property_type, k.area_sqft desc;


-- Market Quartiles 
-- BA: If we divide the market into four equal tiers based on price, what is the starting and ending price for each tier?
with Quartiles as (
	select 
		property_name, 
		price_inr, 
		area_sqft, 
		ntile(4) over (order by price_inr asc) as price_quartile 
	from kolkata_real_estate 
	where price_inr is not null 
)
select 
	concat('Q', price_quartile) as quartile, 
	count(*) as listings_in_quartile, 
	min(price_inr) as minimum_price,
	max(price_inr) as maximum_price, 
	round(avg(area_sqft), 0) as avg_area 
from Quartiles 
group by price_quartile
order by price_quartile;


/* Purpose: Identifies high-value real estate investment opportunities by:
         1. Isolating the top 20% most premium neighborhoods (by price/sqft).
         2. Finding properties within those areas that are larger than the 
            neighborhood average area.
         3. Ensuring those properties are priced below the neighborhood 
            average price per square foot (identifying a discount).
*/
with LocationStats as (
	select 
		location, 
		count(*) as total_listings, 
		avg(price_inr / area_sqft) as loc_avg_price_per_sqft, 
		avg(area_sqft) as loc_avg_area, 
		percent_rank() over (order by avg(price_inr / area_sqft) desc) as location_percentile
	from kolkata_real_estate 
	where location is not null and area_sqft > 0 
	group by location 
	having count(*) >= 5
),
PremiumLocations as (
	select * 
	from LocationStats 
	where location_percentile <= 0.20
)

select 
	k.property_name, 
	k.location, 
	k.property_type, 
	k.price_inr, 
	k.area_sqft,
	round(k.price_inr / k.area_sqft, 0) as property_price_per_sqft, 
	round(p.loc_avg_price_per_sqft, 0) as neighborhood_avg_price_per_sqft,
	round(p.loc_avg_area, 0) as neighborhood_avg_area, 
	round(p.loc_avg_price_per_sqft - (k.price_inr / k.area_sqft), 0) as sqft_discount_amount
from kolkata_real_estate k 
join PremiumLocations p on k.location = p.location 
where 
	(k.price_inr / k.area_sqft) < p.loc_avg_price_per_sqft 
	and k.area_sqft > p.loc_avg_area 
order by 
	p.loc_avg_price_per_sqft desc, 
	sqft_discount_amount desc;
	

-- Executive Location Pivot Matrix 
select 
	location, 
	count(*) as total_listings, 
	round(avg(price_inr / area_sqft), 0) as avg_price_per_sqft, 

	-- Using the FITLER clause to pivot data into columns 
	count(*) filter(where property_type = '2 BHK Apartment') as total_2_bhk,
	count(*) filter(where property_type = '3 BHK Apartment') as total_3_bhk,
	count(*) filter(where property_type in ('Shop', 'Office Space', 'Showroom')) as total_commercial_spaces

from kolkata_real_estate 
where location is not null and area_sqft > 0 
group by location 
having count(*) > 10 
order by total_listings desc, avg_price_per_sqft desc;













