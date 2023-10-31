--create a join table Absentisum with compensation
select * from Absenteeism_at_work a
left join [work].[dbo].[compensation] b
on a.ID=b.Id
--now connect with reasons
left join Reasons r on
a.Reason_for_absence=r.Number;

--find the healthiest emp for bonus Ques1
select * from Absenteeism_at_work
where Social_drinker=0 and Social_smoker=0
and Body_mass_index < 25 --as per googlw <25 is healthy
and Absenteeism_time_in_hours < (select AVG(Absenteeism_time_in_hours) from Absenteeism_at_work);

--compensation rate increase for non-smokers budget $983,221(received from hr)  so .68 increase per hr., 1414 incre per year per employee 8*5*52*.68
-- hrs calculation 8*5*52*686 emp i.e 1,426,880
select COUNT(*) as nonsmokers

--optimize query
select a.ID,
r.Reason,Month_of_absence, Body_mass_index,
Case when Body_mass_index < 18.5 then 'underweight'
	when Body_mass_index between 18.5 and 25 then 'Healthy'
	when Body_mass_index between 25 and 30  then 'Overrweight'
	when Body_mass_index > 30 then 'obese'
	else 'unknown' end as BMI_category,
--lets reate some new columns categorical like season ans BMI
Case when  Month_of_Absence in (12,1,2) then 'Winter'
	when  Month_of_Absence in (3,4,5) then 'Spring'
	when  Month_of_Absence in (6,7,8) then 'Summer'
	when  Month_of_Absence in (9,10,11) then 'Fall'
	Else 'Unknown' end as Season_name,
Month_of_absence,
Day_of_the_week,
Transportation_expense,
Education,
Social_drinker,
Social_smoker,
pet,
Disciplinary_failure,
age,
Work_load_Average_day,
Absenteeism_time_in_hours
from Absenteeism_at_work a
left join [work].[dbo].[compensation] b
on a.ID=b.Id
--now connect with reasons
left join Reasons r on
a.Reason_for_absence=r.Number;

