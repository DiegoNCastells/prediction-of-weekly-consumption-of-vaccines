select v.name as vacc
        ,p.name as prac
        ,vaccinsPerMonth.week
        ,vaccinsPerMonth.year
        ,vaccinsPerMonth.totalWeek 
from(
    select  vaccinations.vaccine_id
     		,vaccinations.practice_id
            ,date_part('month',vaccinations.given_at) as week
            ,date_part('year',vaccinations.given_at) as year
            --,date_part('month',vaccinations.given_at) as month
            ,count(*) as totalWeek
    from vaccinations
    inner join practices on practices.id=vaccinations.practice_id and {{practica}}
    inner join inventories inv on inv.id=vaccinations.inventory_id
    where vaccinations.historic=false
        and practices.is_billable=true
        and inv.vfc=false
        and vaccinations.historic=false
    	and extract ( year from (vaccinations.given_at) ) > extract ( year from ( current_date-interval'4 year' ) )
    group by vaccinations.vaccine_id
       		 ,vaccinations.practice_id
                ,date_part('month',vaccinations.given_at) 
                ,date_part('year',vaccinations.given_at)
    order by vaccinations.vaccine_id
       			,vaccinations.practice_id
                ,date_part('month',vaccinations.given_at)  
                ,totalWeek asc
)vaccinsPerMonth 
inner join vaccines v on vaccinsPerMonth.vaccine_id = v.id
inner join practices p on vaccinsPerMonth.practice_id = p.id
order by  v.name desc