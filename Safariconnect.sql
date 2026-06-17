create schema safari_connect;

SET search_path TO safari_connect;

create table staging_safari_connect(
booking_id text,
passenger_name text,
passenger_phone text,
passenger_gender text,
passenger_city text,
route_code text,
route_from text,
route_to text,
vehicle_plate text,
vehicle_type text,
driver_name text,
driver_rating text,
departure_date text,
departure_time text,
seat_class text,
seats_booked text,
fare_per_seat text,
total_fare text,
payment_method text,
booking_status text,
trip_rating text
);

select * from staging_safari_connect;

-- create duplicate table 
create table dirty_safari_connect
as select * from staging_safari_connect;

select * from dirty_safari_connect;

==== data cleaning ===

--1. Passenger_name \

select passenger_name from dirty_safari_connect;

--trimming and propercase
update dirty_safari_connect
set passenger_name = initcap(trim(passenger_name))
where passenger_name != initcap(trim(passenger_name));

--2.Passenger_phone
--2. Cleaning Phone Numbers
select passenger_phone from dirty_safari_data;
/*
 * Using regexp_replace
 * Syntax for regexp_replace is: regexp_replace(source, pattern, replacement_string, flag)
 * Syntax breakdown; 
 * 				source > the string where the search is being done i.e the column name in our case
				pattern > the sub-string to be replaced (what do you want to remove?)
				replacement string > What replaces the sub-string matching the pattern (What do you want to 					replace it with?)
				flag > controls the behavior of the matching operation; often i(case-insensitive matching) or g 				(global- lets the regexp run for all the contents of the column, and not stop after the first one).
The characters in regexp;
^ this indicates the start of a string; 
\ this is for ensuring the + is treated as a character and not an operator; 
[^0-9] means not inside, in our case it means we replace any character that does not match a character defined in the brackets, i.e whatever is not a digit. The positioning of the ^ determines the output;

code to remove +254 therefore becomes regexp_replace(passenger_phone, '^(\+254|254)', '0', 'g')

	If we had written this way ^[0-9] it would mean only for string that start with a number, replace just the  	start of the string with what you have specified, returns everything else regardless what comes 	after.Also 	for strings that don't start with numbers, they will remain unchanged.
	
	If we did [0-9] without the ^ it means whatever has a number anywhere, is what we want to remove, so it removes 	the numbers and leaves whatever else that isnt a number.
	
code to remove anything that is not a number then becomes: select regexp_replace(passenger_phone,'[^0-9]', '', 'g')
	
^[0-9]+$ means matching starts at the first character of the string(denoted by ^), 
	[0-9] the matching can be any number btn 0 and 9, 
	+ means to keep going after matching the start of the string, 
	$ means the end of the string, nothing can be after that. 
So in completion it means From start to end, the string must contain only digits.

where clause then becomes : where phone_number != ^[0-9]+$
*/
--full query merged to one then becomes; 
select regexp_replace(regexp_replace(passenger_phone, '^(\+254|254)', '0'),'[^0-9]', '', 'g') as cleaned_data
from dirty_safari_data
where passenger_phone != '^[0-9]+$';
*/

-- to replace the +254 with 0 

UPDATE dirty_safari_connect
SET passenger_phone = '0' || RIGHT(passenger_phone, 9) 
WHERE passenger_phone LIKE '+254%';

-- to remove the - and any other characters 

UPDATE dirty_safari_connect
SET passenger_phone = REGEXP_REPLACE(passenger_phone, '[^0-9]', '', 'g') --- the source(column), pattern(what to replace), replacement string and flag
WHERE passenger_phone !~ '^[0-9]+$';

-- empty phone numbers COALESCE to null

select coalesce(nullif(passenger_phone, ''),'null') as passenger_phone
from dirty_safari_connect;

update dirty_safari_connect 
set passenger_phone = coalesce(nullif(passenger_phone, ''),'null')
where passenger_phone = '';

select passenger_phone,  
coalesce(nullif(passenger_phone,'null'),'unknown') as phone_new
from v_clean_trips vct
where passenger_phone = 'null';


update v_clean_trips vct  
set passenger_phone = coalesce(nullif(passenger_phone,'null'),'unknown') 
where passenger_phone = 'null';

select passenger_phone
from v_clean_trips vct;

--passenger_gender
select passenger_id,
set passenger_gender = trim(passenger_gender) as gender

select departure_date from staging_safari_connect ;
select to_char(case
            -- dd-mm-yy
when departure_date like '__-__-__' then to_date(departure_date, 'dd-mm-yy')
            -- yyyy-mm-dd
when departure_date like '____-__-__' then to_date(departure_date, 'yyyy-mm-dd')
            -- dd/mm/yyyy
 when departure_date like '__/__/____'
 then to_date(departure_date, 'dd/mm/yyyy')
            -- dd-mm-yyyy (e.g. 18-01-2024)
            when departure_date like '__-__-____'
                 and split_part(departure_date, '-', 2)::int <= 12
                then to_date(departure_date, 'dd-mm-yyyy')
            -- mm-dd-yyyy (e.g. 01-18-2024)
            when departure_date like '__-__-____'
                 and split_part(departure_date, '-', 1)::int <= 12
                then to_date(departure_date, 'mm-dd-yyyy')
            else null
        end,
        'dd-mm-yyyy'
    ) as formatted_date
from staging_safari_connect;
----
---- 
update staging_safari_connect
set departure_date =
to_char(
        case
            -- dd-mm-yy
            when departure_date like '__-__-__'
                then to_date(departure_date, 'dd-mm-yy')
            -- yyyy-mm-dd
            when departure_date like '____-__-__'
                then to_date(departure_date, 'yyyy-mm-dd')
            -- dd/mm/yyyy
            when departure_date like '__/__/____'
                then to_date(departure_date, 'dd/mm/yyyy')
            -- dd-mm-yyyy (e.g. 18-01-2024)
            when departure_date like '__-__-____'
                 and split_part(departure_date, '-', 2)::int <= 12
                then to_date(departure_date, 'dd-mm-yyyy')
            -- mm-dd-yyyy (e.g. 01-18-2024)
            when departure_date like '__-__-____'
                 and split_part(departure_date, '-', 1)::int <= 12
                then to_date(departure_date, 'mm-dd-yyyy')
            else null
        end,
        'dd-mm-yyyy'
    );


alter table staging_safari_connect 
alter column departure_date type date using to_date(departure_date, 'dd-mm-yyyy');

select * from staging_safari_connect;

set ser


--- passenger city
--- Removing white spaces
select 
    passenger_city as original_city,
    initcap(trim(passenger_city)) as predicted_clean_city
from dirty_safari_connect
where passenger_city != initcap(trim(passenger_city));

update dirty_safari_connect
set passenger_city = initcap(trim(passenger_city))
where passenger_city != initcap(trim(passenger_city));


--- fill in the blanks 
update dirty_safari_connect 
set passenger_city = 'Unknown'
where passenger_city = '';

--- Gender 
select 
passenger_gender as gender_original,
initcap(trim(passenger_gender)) as new_gender
from dirty_safari_connect
where passenger_gender != initcap(trim(passenger_gender));

update dirty_safari_connect 
set passenger_gender = initcap(trim(passenger_gender))
where passenger_gender != initcap(trim(passenger_gender));

-- to standardize
select passenger_gender,
case 
	when passenger_gender = 'Male' then 'M'
	when passenger_gender = 'Female' then 'F'
	when passenger_gender in ('M','F') then passenger_gender
	else 'unknown'
end as cleaned_gender
from dirty_safari_connect;


update dirty_safari_connect
set passenger_gender = case 
    when passenger_gender = 'Male' then 'M'
    when passenger_gender = 'Female' then 'F'
    when passenger_gender in ('M', 'F') then passenger_gender
    else 'unknown'
end
where passenger_gender in ('Male', 'Female');

---6. Payment method
select payment_method, initcap(trim(payment_method))
from dirty_safari_connect
where payment_method != initcap(trim(payment_method));

update dirty_safari_connect 
set payment_method = initcap(trim(payment_method))
where payment_method != initcap(trim(payment_method));

-- to standardize

select payment_method,
case 
	when payment_method = 'M-Pesa' then 'M-pesa'
	when payment_method = 'Mpesa' then 'M-pesa'
	when payment_method in ('M-pesa','Card','Cash') then payment_method
	else 'unknown'
end as cleaned_payment_method
from dirty_safari_connect;


update dirty_safari_connect
set payment_method = case 
	when payment_method = 'M-Pesa' then 'M-pesa'
	when payment_method = 'Mpesa' then 'M-pesa'
	when payment_method in ('M-pesa','Card','Cash') then payment_method
	else 'unknown'
end
where payment_method in ('M-Pesa','Mpesa');

select payment_method, count(payment_method) from dirty_safari_connect
group by payment_method;


--7.Booking_Status 
select distinct booking_status from dirty_safari_connect;

select booking_status,initcap(trim(booking_status))
from dirty_safari_connect
where booking_status != initcap(trim(booking_status));


update dirty_safari_connect  
set booking_status = initcap(trim(booking_status))
where booking_status != initcap(trim(booking_status)); 

--8. total_fare

select total_fare from dirty_safari_connect;

select total_fare, regexp_replace(total_fare, '[^0-9]','','g')
from dirty_safari_connect;

update dirty_safari_connect
set total_fare = regexp_replace(total_fare, '[^0-9]','','g')
where total_fare !~ '^[0-9]+$';

--9. fare per seat 

select fare_per_seat from dirty_safari_connect dsc;

select fare_per_seat, regexp_replace(fare_per_seat, '[^0-9]','','g')
from dirty_safari_connect;


update dirty_safari_connect
set fare_per_seat = regexp_replace(fare_per_seat, '[^0-9]','','g')
where fare_per_seat !~ '^[0-9]+$';

-- 10. seat class

select distinct seat_class from dirty_safari_connect dsc;

select distinct seat_class,
case
	when initcap(trim(seat_class)) = 'Bus' then 'Business Class'
	when initcap(trim(seat_class)) = 'Business' then 'Business Class'
	when initcap(trim(seat_class)) = 'Economy' then 'Economy Class'
	when initcap(trim(seat_class)) = 'Eco' then 'Economy Class'	
	else initcap(trim(seat_class))
end
from dirty_safari_connect;


update dirty_safari_connect
set seat_class = 
case 
	when initcap(trim(seat_class)) = 'Bus' then 'Business Class'
	when initcap(trim(seat_class)) = 'Business' then 'Business Class'
	when initcap(trim(seat_class)) = 'Economy' then 'Economy Class'
	when initcap(trim(seat_class)) = 'Eco' then 'Economy Class'	
	else initcap(trim(seat_class))
end;


-- 11. Driver names 

select distinct driver_name from dirty_safari_connect dsc;

select driver_name, initcap(trim(driver_name))
from dirty_safari_connect;


update dirty_safari_connect dsc 
set driver_name = initcap(trim(driver_name))
where driver_name != initcap(trim(driver_name));


---12. trip rating 


select  trip_rating from dirty_safari_connect dsc;

select trip_rating, nullif(trip_rating, '') 
from dirty_safari_connect dsc;

update dirty_safari_connect dsc 
set trip_rating = nullif(trip_rating, '')
where trip_rating = '';


---12. trip rating 
-- invalid 0, 6, 7 

select  trip_rating from dirty_safari_connect dsc;

select trip_rating, nullif(trip_rating, '') 
from dirty_safari_connect dsc;

update dirty_safari_connect dsc 
set trip_rating = nullif(trip_rating, '')
where trip_rating = '';


select trip_rating, nullif(trip_rating, '0') 
from dirty_safari_connect dsc;


update dirty_safari_connect dsc 
set trip_rating = nullif(trip_rating, '0')
where trip_rating = '0';

select trip_rating, nullif(trip_rating, '6') 
from dirty_safari_connect dsc;


update dirty_safari_connect dsc 
set trip_rating = nullif(trip_rating, '6')
where trip_rating = '6';


select trip_rating, nullif(trip_rating, '7') 
from dirty_safari_connect dsc;


update dirty_safari_connect dsc 
set trip_rating = nullif(trip_rating, '7')
where trip_rating = '7';

-- 13. vehicle type
select distinct vehicle_type from dirty_safari_connect;

select distinct vehicle_type, initcap(trim(vehicle_type)) as clean_vehicles
from dirty_safari_connect;

update dirty_safari_connect
set vehicle_type = initcap(trim(vehicle_type))
where vehicle_type != initcap(trim(vehicle_type));

--14. Updating the - seats_booked
update dirty_safari_connect dsc 
set seats_booked = null
where seats_booked = '-1';

--15. Removing Duplicates 

-- to confirm duplicates

select booking_id, count(booking_id) 
from dirty_safari_connect dsc
group by booking_id;

-- to delete duplicates

delete from dirty_safari_connect 
where ctid in ( select ctid from (select ctid,row_number() over (partition by booking_id order by booking_id) as duplicate
from dirty_safari_connect) dsc
where dsc.duplicate > 1);

select * from dirty_safari_connect
where ctid not in (
 select min(ctid)
 from dirty_safari_connect
 group by booking_id);
-----
-----
delete from dirty_safari_connect
where ctid not in (
select min(ctid)
from dirty_safari_connect
group by booking_id);



alter table dirty_safari_connect 
add constraint pk_booking_id primary key (booking_id); -- or

/*
--USING clause tells PostgreSQL how to convert the existing data in that column into the new data type.
-- Without it, PostgreSQL tries to do the conversion automatically.
-- Sometimes it cannot safely guarantee the conversion, especially when:
changing between very different data types
applying stricter limits
formatting dates/numbers
cleaning values during conversion

-- So USING gives explicit instructions, it is like saying ''Take the current values in guest_nationality and cast them into VARCHAR(20).”
-- The :: is PostgreSQL shorthand for type casting.  If the column was already text-like (for example TEXT → VARCHAR(20)), PostgreSQL often does not require USING, because PostgreSQL already knows how to convert TEXT to VARCHAR.
*/--

alter table dirty_safari_connect 
add primary key (booking_id);


alter table dirty_safari_connect 
alter column passenger_name type varchar(100) using passenger_name::varchar(100);

alter table dirty_safari_connect 
alter column passenger_phone type varchar(10) using passenger_phone::varchar(10);

alter table dirty_safari_connect 
alter column passenger_gender type varchar(1) using passenger_gender::varchar(1);

alter table dirty_safari_connect 
alter column passenger_city type varchar(50) using passenger_city::varchar(50);

alter table dirty_safari_connect 
alter column route_code type varchar(10) using route_code::varchar(10);

alter table dirty_safari_connect 
alter column route_from type varchar(50) using route_from::varchar(50);

alter table dirty_safari_connect 
alter column route_to type varchar(50) using route_to::varchar(50);

alter table dirty_safari_connect 
alter column vehicle_plate type varchar(10) using vehicle_plate::varchar(10);

alter table dirty_safari_connect 
alter column vehicle_type type varchar(20) using vehicle_type::varchar(20);

alter table dirty_safari_connect 
alter column driver_name type varchar(100) using driver_name::varchar(100);

alter table dirty_safari_connect 
alter column driver_rating type decimal using driver_rating::decimal;

alter table dirty_safari_connect 
alter column departure_date type date using to_date(departure_date, 'dd-mm-yyyy');

alter table dirty_safari_connect 
alter column departure_time type time using departure_time::time;

alter table dirty_safari_connect 
alter column seat_class type varchar(50) using seat_class::varchar(50);

alter table dirty_safari_connect 
alter column seats_booked type int using seats_booked::int;

alter table dirty_safari_connect 
alter column fare_per_seat type numeric using fare_per_seat::numeric;

alter table dirty_safari_connect 
alter column total_fare type numeric using total_fare::numeric;

alter table dirty_safari_connect 
alter column payment_method type varchar(10) using payment_method::varchar(10);

alter table dirty_safari_connect 
alter column booking_status type varchar(20) using booking_status::varchar(20);
alter table dirty_safari_connect 
alter column trip_rating type int using trip_rating::int;


---creating the last version of the clean table
create table v_clean_trips as 
select * from dirty_safari_connect; 

set search_path to safari_connect;

alter table v_clean_trips 
add primary key (booking_id);


select * from dirty_safari_connect;

update dirty_safari_connect dsc
set departure_date = ssc.departure_date
from staging_safari_connect ssc
where dsc.booking_id = ssc.booking_id;


select * from dirty_safari_connect dsc ;

update v_clean_trips vct
set departure_date = dsc.departure_date
from  dirty_safari_connect dsc
where vct.booking_id = dsc.booking_id;





select * from v_clean_trips;


==== ANALSIS ====
1.Route Analysis - Which routes earn the most? Which are most popular?

-- 1A. 1A - Revenue and bookings by route
-- Show: route_code, route_from, route_to, total_bookings, total_seats, total_revenue, avg_fare, avg_trip_rating. Order by total_revenue descending.

-- Revenue by route_code
select route_code, route_from, route_to, count(booking_id) as total_bookings,
sum(seats_booked) as total_seats, sum(total_fare) as Revenue_by_route_code, 
round(avg(total_fare),2) as avg_fare, round(avg(trip_rating),2) as avg_trip_rating
from v_clean_trips vct 
group by route_code, route_from, route_to
order by revenue_by_route_code desc;

-- 1B - Revenue per seat by route (efficiency metric)
-- Which route earns the most per seat sold? Show route, total_revenue, total_seats, and revenue_per_seat = total_revenue / total_seats.

select route_code,route_from, route_to, sum(seats_booked) as total_seats, sum(total_fare) as total_revenue, round(sum(total_fare)/sum(seats_booked),2) as revenue_per_seat
from v_clean_trips vct 
group by route_code,route_from, route_to
order by revenue_per_seat desc;
-- RTOO1: KES 1,248

-- 1C - Route ranking with window function
-- Rank all routes by total revenue using RANK(). Also show each route's percentage of total company revenue

select route_code, route_from, route_to, sum(total_fare), rank() over (order by sum(total_fare) desc) as revenue_rank 
from v_clean_trips vct
group by route_code, route_from, route_to;

--- using the CTE to get the % revenue by route
with route_revenue as (
select route_code, route_from, route_to,
sum(total_fare) as revenue_by_route,
rank() over (order by sum(total_fare) desc) as revenue_rank
from v_clean_trips vct
group by route_code, route_from, route_to)
select *,round((revenue_by_route * 100.0) / sum(revenue_by_route) over(), 2) as revenue_percentage
from route_revenue;

-- 1D - Vehicle type performance
Compare Bus vs Matatu vs Minibus - total bookings, revenue, avg rating. 
Which vehicle type is most profitable?

select vehicle_type, count(booking_id) as booking_by_vehicle_type, 
sum(total_fare) as revenue_by_type,round(avg(trip_rating),2) as rating
from v_clean_trips vct 
group by vehicle_type
order by revenue_by_type desc;
-- The bus has the highest revenue and bookings 101,930
-- The minibus was rated the highest

- Question 2 -  Driver Performance
--Business need: HR wants to know who to promote, who needs training, and whether driver rating affects passenger satisfaction.
--2A - Driver summary
--Show: driver_name, total_trips, total_seats_carried, total_revenue, avg_trip_rating, driver_rating. Order by total_revenue descending.

--- using concate to create trip ids 
select driver_name, count(distinct concat(departure_date, '_', departure_time, '_', route_code)) as total_trips,
sum(seats_booked) as total_seats_carried, sum(total_fare) as total_revenue, round(avg(trip_rating),2) as avg_trip_rating, 
avg(driver_rating) as avg_driver_rating
from v_clean_trips  
group by driver_name 
order by total_revenue desc;

---- using the vehicle types
select driver_name, count(concat(vehicle_type, '_', route_code)) as total_trips, sum(seats_booked) total_seats ,
sum(total_fare) as total_revenue, round(avg(trip_rating),2) as avg_trip_rating, avg(driver_rating) as avg_driver_rating
from v_clean_trips  
group by driver_name 
order by total_revenue desc;
-- Kelvin Omondi had the highest revenue, trips and seats booked
-- Moses Kipchoge had the highest everage rating which states that he is the most preffered driver among the 8

2B - Driver ranking - overall + by vehicle type
Using a CTE for driver totals, rank drivers overall by revenue AND within their vehicle type using PARTITION BY vehicle_type.

with driver_totals as
(select driver_name, vehicle_type, sum(total_fare) as total_revenue
from v_clean_trips vct 
group by driver_name, vehicle_type)
select *, rank() over (partition by vehicle_type order by total_revenue desc)
from driver_totals;


--2C. Does driver rating predict passenger satisfaction?
--Group drivers into high-rated (≥ 4.5) and standard (< 4.5). Compare average passenger trip_rating for each group. 
--Does a higher driver rating lead to happier passengers?


-- generalized
with passenger_satisfaction as
(select driver_name, avg(driver_rating) as avg_driver_rating, avg(trip_rating) as avg_trip_rating,
case
when avg(driver_rating) >= 4.5 then 'high_rated'
else 'standard'
end as rating_groupings
from v_clean_trips
group by driver_name)
select rating_groupings, round(avg(avg_trip_rating), 2) as final_passenger_satisfaction
from passenger_satisfaction
group by rating_groupings;


-- breakdown

select driver_name, round(avg(driver_rating), 2) as avg_driver_rating, round(avg(trip_rating), 2) as avg_passenger_satisfaction,round(avg(trip_rating) - avg(driver_rating), 2) as rating_gap, count(*) as total_trips,
case
	when avg(driver_rating) >= 4.5 then 'high_rated'
	else 'standard'
end as rating_groupings 
from v_clean_trips
group by driver_name
order by avg_driver_rating desc;

-3A - Monthly revenue with month-over-month change (CTE + LAG)

-- date, total_fare
with month_over_month as 
(select  date_trunc('month', departure_date) as month, sum(total_fare) as current_revenue, lag(sum(total_fare)) over (order by date_trunc('month', departure_date)) as previous_month_revenue
from v_clean_trips
group by month)
select *, (current_revenue - previous_month_revenue) as month_over_month_change, round((current_revenue - previous_month_revenue) * 100/previous_month_revenue,2) as percentage_change
from month_over_month;


-- 3B - Running total of revenue
-- Fixed: Added year to the window function order by block
select to_char(departure_date, 'month') as c_month, sum(total_fare) as c_revenue, sum(sum(total_fare)) over (order by extract(year from departure_date) asc, extract(month from departure_date) asc ) as running_totals, extract(year from departure_date) as c_year
from v_clean_trips
group by extract(year from departure_date), extract(month from departure_date), to_char(departure_date, 'month')
order by c_year asc, extract(month from departure_date) asc;


--- or these two 
select to_char(departure_date, 'month') as month, sum(total_fare) as monthly_revenue, sum(sum(total_fare)) over (order by date_trunc('month', departure_date)) as running_total
from v_clean_trips
group by date_trunc('month', departure_date), to_char(departure_date, 'month')
order by date_trunc('month', departure_date);



select date_trunc('month', departure_date), sum(total_fare), sum(sum(total_fare)) over (order by date_trunc('month', departure_date )) 
from v_clean_trips
group by date_trunc('month', departure_date);

-- 3C - Best and worst 3 months

---Using a CTE for monthly revenue, show the top 3 months and the bottom 3 months by revenue. Use RANK().

with revenue_rank as
(select date_trunc('month', departure_date) as month, sum(total_fare) as monthly_revenue, rank() over (order by sum(total_fare) desc) as top_rank, rank() over (order by sum(total_fare) asc) as bottom_rank
from v_clean_trips
group by date_trunc('month', departure_date))
select  * from revenue_rank 
where top_rank <= 3 or bottom_rank <= 3;


-- 3D - Revenue by route per month (pivot)
--Show one row per month with separate columns for the top 3 routes (RT001, RT002, RT003) using CASE WHEN + SUM.

--- Getting the top 3 routes by revenue
select route_code, route_from, route_to, sum(total_fare), rank() over (order by sum(total_fare) desc) as revenue_rank 
from v_clean_trips vct
group by route_code, route_from, route_to;


-- - Revenue by route per month (pivot)
select   to_char(date_trunc('month', departure_date), 'month') as month,  --# this part scans the months and assigns the monthname
sum (case when route_code = 'RT001' then total_fare else 0 end) as "route1_revenue", --# the case when statement sums the total_fares associated to the 'Route001' and assigns 0 to any other route
sum (case when route_code = 'RT004' then total_fare else 0 end) as "route4_revenue",
sum ( case when route_code = 'RT002'then total_fare else 0 end) as "route2_revenue"
  from v_clean_trips
group by date_trunc('month', departure_date)   # creates the months 
order by date_trunc('month', departure_date);

-- 4A - Top passenger cities
-- Show: passenger_city, total_bookings, total_seats, total_revenue, avg_fare. Order by total_bookings descending. Only include cities with 3+ bookings.

select * from
(select passenger_city, count(booking_id) as total_bookings, sum(seats_booked) as total_seats, sum(total_fare) as total_revenue, round(avg(total_fare),2) as avg_fare
from v_clean_trips
group by passenger_city
order by total_bookings desc) booking_summary
where total_bookings >= 3;

-- 4B - Gender split and seat class preference
-- Show bookings and revenue broken down by passenger_gender and seat_class. Use a CASE WHEN pivot to show Economy and Business as separate columns.


select passenger_gender,seat_class, count(booking_id) as total_bookings, 
	sum(case when seat_class = 'Economy Class' then total_fare else 0 end) as "Economy_Revenue",
	sum(case when seat_class = 'Business Class' then total_fare else 0 end) as "Business_Revenue"
from v_clean_trips vct 
group by passenger_gender,seat_class
order by passenger_gender;

-- 4C - Satisfaction breakdown (CTE)
-- Using a CTE, count how many trips fall into each satisfaction category (Satisfied / Neutral / Unsatisfied / No Rating). Show count and percentage of total completed trips


-- cte
with completed_trips as
(select count(booking_id) as total_bookings,
    case
        when trip_rating >= 4 then 'satisfied'
        when trip_rating = 3 then 'neutral'
        when trip_rating < 3 then 'unsatisfied'
        else 'no rating'
    end as satisfaction_category
from v_clean_trips
where booking_status = 'Completed'  ---- this filters the whole query to look only at completed trips
group by satisfaction_category 
order by total_bookings desc)
select satisfaction_category, total_bookings,
round(total_bookings * 100.0 / sum(total_bookings) over(), 2) as percentage_of_total----the percentage out of all completed bookings
from completed_trips;


--- using a subquery
select 
case
	when trip_rating >= 4 then 'satisfied'
	when trip_rating = 3 then 'neutral'
	when trip_rating < 3 then 'unsatisfied'
else 'no rating' end as satisfaction_category,
count(booking_id) as total_bookings,
round(count(booking_id) * 100.0 / sum(count(booking_id)) over(), 2) as percentage_of_total--calculates the percentage out of all completed bookings
from v_clean_trips
where booking_status = 'Completed'  ----- this filters the whole query to look only at completed trips
group by 
    satisfaction_category 
order by total_bookings desc;


select booking_status, trip_rating from v_clean_trips vct where vct.booking_status = 'No Show';

---4D - Passenger quartiles by spend (NTILE)
-- Using a CTE for total spend per passenger, divide passengers into 4 quartiles using NTILE(4). Show: passenger_name, total_spent, quartile. Label quartile 4 as 'Top Spender'.

with quartile_spend as
(select passenger_name, sum(total_fare) as total_spend, ntile(4) over (order by sum(total_fare) asc) as quartiles_by_spend
from v_clean_trips
group by passenger_name)
select * ,
case 
	when quartiles_by_spend = 4 then 'Top Spender'
	else quartiles_by_spend::text 
end as quartile_category
from quartile_spend;

-- Question 5 - Cancellations & Lost Revenue

-- 5A - Overall status breakdown
select booking_status,count(booking_id) as total_bookings, sum(total_fare) as revenue_by_bookings
from v_clean_trips
group by booking_status;

---by day breakdown 
SELECT
    to_char(date_trunc('month', departure_date), 'FMMonth') AS month,
    to_char(departure_date, 'FMDay') AS day_of_week,
    extract(isodow from departure_date) AS day_num,
	COUNT(CASE WHEN booking_status = 'Completed' THEN 1 END) AS completed,
    COUNT(CASE WHEN booking_status = 'Cancelled' THEN 1 END) AS cancelled,
    COUNT(CASE WHEN booking_status = 'No Show' THEN 1 END) AS no_show
FROM v_clean_trips
GROUP BY
    date_trunc('month', departure_date),
    to_char(departure_date, 'FMMonth'),
    to_char(departure_date, 'FMDay'),
    extract(isodow from departure_date)
ORDER BY
    date_trunc('month', departure_date),
    day_num;


--- 5B - Cancellation rate by route
Show: route_code, route, total_bookings, completed, cancelled, no_show, cancellation_rate_pct.

with bookings_distribution as
(select route_code,route_from, route_to, booking_status,count(booking_id) as total_bookings 
from v_clean_trips
where booking_status = 'Cancelled'
group by booking_status,route_code,route_from, route_to
order by route_code)
select *,round(total_bookings *100/ sum(total_bookings) over(),2) as cancellation_rate  from bookings_distribution;


-- 5C - Revenue lost from cancellations and no-shows

select booking_status, sum(total_fare), count(booking_status)
from v_clean_trips vct
where booking_status in ('Cancelled', 'No Show')
group by booking_status;

-- Question 6 - Operational Patterns
-- 
Business need: Operations wants to schedule more vehicles during peak times and fewer during quiet times.

-- 6A - Revenue by day of week

--- isodow: the global standard for numbering days of week the first day is monday,
--  dow: starts from sunday--USA standard

select to_char(departure_date,'Day') AS day_of_week, sum(total_fare)as total_revenue
from v_clean_trips vct
group by day_of_week, extract(isodow from departure_date)
order by extract(isodow from departure_date);

-- another way
select to_char(departure_date, 'fmday') as day_of_week,--- guides postgres to not have spaces in the output
    sum(total_fare) as total_revenue
from v_clean_trips
group by to_char(departure_date, 'fmday'), extract(isodow from departure_date)
order by extract(isodow from departure_date);


-- 6B - Busiest departure times
-- Group by departure_time. Show which time slots carry the most passengers and generate the most revenue.

select departure_time,sum(seats_booked) as total_seats, sum(total_fare) as total_revenue
from v_clean_trips
group by departure_time
order by departure_time;


-- breakdown by seat class

select seat_class,departure_time,sum(seats_booked) as total_seats, sum(total_fare) as total_revenue
from v_clean_trips
group by departure_time,seat_class
order by departure_time;


-- 6C- Seat utilisation by vehicle type
-- Compare how full each vehicle type typically runs. Show: vehicle_type, avg_seats_booked, and a label 
-- 'High Load' if avg > 3, 'Medium Load' if 2-3, 'Low Load' if below 2.


select vehicle_type, round(avg(seats_booked),2) as avg_seats,
case 
	when avg(seats_booked) > 3 then 'High Load'
	when avg(seats_booked) between 2 and 3 then 'Medium Load'
	else 'Low Load'
end
from v_clean_trips
group by vehicle_type;


======== VIEWS ========

-- View 1: Route performance
--CREATE OR REPLACE VIEW v_route_performance AS
-- paste your 1A query here

CREATE OR REPLACE VIEW v_route_performance AS
select route_code, route_from, route_to, count(booking_id) as total_bookings,sum(seats_booked) as total_seats, sum(total_fare) as Revenue_by_route_code, round(avg(total_fare),2) as avg_fare, round(avg(trip_rating),2) as avg_trip_rating
from v_clean_trips vct 
group by route_code, route_from, route_to
order by revenue_by_route_code desc;



-- View 2: Driver performance
--CREATE OR REPLACE VIEW v_driver_performance AS
-- paste your 2A query here

CREATE OR REPLACE VIEW v_driver_performance AS
select driver_name, count(distinct concat(departure_date, '_', departure_time, '_', route_code)) as total_trips, sum(seats_booked) as total_seats_carried, sum(total_fare) as total_revenue, round(avg(trip_rating),2) as avg_trip_rating, avg(driver_rating) as avg_driver_rating
from v_clean_trips  
group by driver_name 
order by total_revenue desc;




-- View 3: Monthly revenue trend
--CREATE OR REPLACE VIEW v_monthly_revenue AS
-- paste your 3A query (the CTE) here

CREATE OR REPLACE VIEW v_monthly_revenue AS
with month_over_month as 
(select  date_trunc('month', departure_date) as month, sum(total_fare) as current_revenue, lag(sum(total_fare)) over (order by date_trunc('month', departure_date)) as previous_month_revenue
from v_clean_trips
group by month)
select *, (current_revenue - previous_month_revenue) as month_over_month_change, round((current_revenue - previous_month_revenue) * 100/previous_month_revenue,2) as percentage_change
from month_over_month;



-- View 4: Cancellation analysis
-- CREATE OR REPLACE VIEW v_cancellation_analysis AS
-- paste your 5B query here

CREATE OR REPLACE VIEW v_cancellation_analysis AS
with bookings_distribution as
(select route_code, route_to, route_from, booking_status,count(booking_id) as total_bookings 
from v_clean_trips
where booking_status = 'Cancelled'
group by booking_status,route_code,route_to, route_from
order by route_code)
select *,round(total_bookings *100/ sum(total_bookings) over(),2) as cancellation_rate  from bookings_distribution;

-- View 5: Passenger city insights
--CREATE OR REPLACE VIEW v_passenger_insights AS
-- paste your 4A query here

CREATE OR REPLACE VIEW v_passenger_insights AS
select * from
(select passenger_city, count(booking_id) as total_bookings, sum(seats_booked) as total_seats, sum(total_fare) as total_revenue, round(avg(total_fare),2) as avg_fare
from v_clean_trips
group by passenger_city
order by total_bookings desc) booking_summary
where total_bookings >= 3;

====== INDEXING ======

-- booking_id, passenger_phone, route_code, driver_name,departure_time,vehicle_type,seat_class

create index idx_passenger_phone on v_clean_trips(passenger_phone);

create index idx_route_code on v_clean_trips(route_code) ;

create index idx_driver_name on v_clean_trips(driver_name);

create index idx_departure_time on v_clean_trips(departure_time);

create index idx_vehicle_type on v_clean_trips(vehicle_type);

create index idx_seat_class on v_clean_trips(seat_class);

create index idx_passenger_gender on v_clean_trips(passenger_gender);

select * from pg_indexes where  tablename = 'v_clean_trips';

select * from v_clean_trips vct;
