
use uniace_data

-- sorting out the students getting access to the website 
select 
	* 
from (select 
	`Email Name`, 
	`Email Domain`, 
	case
		when `Email Domain` like '%uni%' then "Studnet"
		when `Email Domain` like '%edu%' then "Student"
		else "Normal"
	end as "Email Classification",
	case 
		
	end as "University"
from uniace 
where `Email Name` is not null) as Source 
where `University` != "Normal"

#Cleaning up possible tables values
update uniace_data.uniace 
set `Email` = SUBSTRING(Email, 1, LOCATE('@', Email) - 1)

ALTER TABLE uniace_data.uniace 
CHANGE Email `Email Name` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci null

alter table uniace_data.uniace 
change `Email domain` `Email Domain` varchar(500) 

update uniace 
set `Email Domain` = "@outlook.com"
where `Email Domain` = "@outlook.com.vn"


use class6
#select the total students coming from the university
select distinct 
	`Email Name`, 
	`Email Domain`,
	`University`,
	max(`Access Time`) over (partition by `Email Name`) as "Max Access"
from (select 
	`Email Name`, 
	`Email Domain`, 
	`University`,
	row_number() over (partition by `Email Name`) as "Access Time"
from uniace) as Source

select 
	`IP Address`,
	row_number() over (partition by `IP Address`) as "Access Time"
from uniace 

#Retrieve emails existed both in templates open and list addition
select 
	`Email Name`
from uniace 
where `University` is not null 
and `Email Name` in 
(select 
	`Type`
from uniace 
where `Type` = "templates_open") 
and `Email Name` in 
(select 
	`Type`
from uniace
where `Type` = "list_addition")


#There's no users with emails returning after the first day
select 
	*
from (select 
	`Email Name`, 
	`Email Domain`, 
	`Date`,
	dense_rank() over (partition by `Email Name`, DATE(`Date`) order by `Date`) as "Total Access" 
from uniace 
where `Email Name` is not null) as Source 
where `Total Access` > 1

#Calculating the total interactions 
select distinct 
	Source2.`Email Name`,
	Source2.`Email Domain`,
	`Total Interactions`
from (select 
	`Email Name`, 
	count(distinct `Type`) as `Total Interactions`
from uniace 
group by `Email Name`) as Source1 
left join 
(select 
	`Email Name`,
	`Email Domain`,
	`Type`
from uniace 
where `Email Name` is not null 
order by `Email Name`) as Source2
on Source1.`Email Name` = Source2.`Email Name`
