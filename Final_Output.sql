/*
Data Analysis Project on Olympics History data.
lets find out some important insights about Olympics games by answering these 20 questions.

Note : This is a historical dataset on the modern Olympic Games, 
including all the Games from Athens 1896 to Rio 2016. data about olympics post 2016 is not included.
*/



/*
Q1. How many Olympics games have been held so far? List down all Olympics games held so far and 
	where they were held.
*/

select count(distinct games) as total_games_held
from olympics_history;

select distinct games, city
from olympics_history 
order by games;


/*
Q2. which athlete from India won the most medals in Olympics (till 2016).
*/

	with temp as
			(select name, sport, count(*) as total_medals from olympics_history 
			where team = 'India' and medal <> 'NA'
			group by name, sport
			order by total_medals desc),
	t2 as 
			(select * ,
			dense_rank() over(order by total_medals desc) as rnk
			from temp)
select name, sport, total_medals
from t2
where rnk = 1;


/*
Q3. Mention the total no of nations who participated in each Olympics game?
*/

	with countries_table as
		(select oh.games, nr.region
		from olympics_history oh 
		join olympics_history_noc_regions nr on oh.noc = nr.noc
		group by games, region)
select games, count(*) as countries_participated
from countries_table
group by games;



/*
Q4. Which year saw the highest and lowest no of countries participating in Olympics?
*/
	with countries as
		(select oh.year, nr.region
		from olympics_history oh 
		join olympics_history_noc_regions nr on oh.noc = nr.noc
		group by oh.year,nr.region)
(select concat('highest_count_year - ',year) as year, count(region) as total_countries
from countries
group by year
order by total_countries desc
limit 1)
union 
(select concat('lowest_count_year - ',year) as year, count(region) as total_countries
from countries
group by year
order by total_countries
limit 1);


/*
Q5. Which nation has participated in all of the Olympics games?
*/
	with countries as
			(select oh.games, nr.region
			from olympics_history oh 
			join olympics_history_noc_regions nr on oh.noc = nr.noc
			group by oh.games,nr.region),
	total_games(total_games) as
			(select count(distinct games) as total_games from olympics_history),
	regions as 
			(select region, count(games)as games_participated from countries group by region)
select * from regions r , total_games tg 
where r.games_participated = tg.total_games;


/*
Q6. Identify the sport which was played in all summer Olympics
*/

	with games_sport_table as
		(select games, season,sport 
		from olympics_history
		 where season = 'Summer'
		group by games,season, sport
		order by games),
	total_games(total_games) as
		(select count(distinct games) as total_games from olympics_history where season = 'Summer'),
	sport_played as 
		(select sport, count(games) as games_included from games_sport_table
		group by sport)
select * from sport_played sp, total_games tg 
where sp.games_included = tg.total_games;



/*
Q7. Which Sports were just played only once in the Olympics
*/

	with games_sport_table as
			(select distinct games, sport from olympics_history order by games),
		sport_gamesCount_table as 
			(select sport, count(*) as no_of_games from games_sport_table group by sport)
select sport_gamesCount_table.* , games_sport_table.games 
from sport_gamesCount_table join games_sport_table
on sport_gamesCount_table.sport = games_sport_table.sport
where no_of_games = 1
order by games_sport_table.sport;


/*
Q8. Fetch the total no of sports played in each Olympics games.
*/
	with games_table as
		(select games, sport
		 from olympics_history
		 group by games, sport)
select games, count(*) as total_sports
from games_table 
group by games 
order by total_sports desc;
		

/*
Q9. Fetch details of the oldest athletes to win a gold medal.
*/

	with t1 as
		(select name,team,
		CASE 
		WHEN age = 'NA' THEN '0' ELSE age
		END as age, 
		games, sport, medal
		from olympics_history where medal = 'Gold'),
	t2 as 
		(select t1.*,
		dense_rank() over(order by age desc) as rnk
		from t1)
select * from t2 where rnk = 1 


/*
Q10. Find the Ratio of male and female athletes participated in all Olympics games
*/

	with male_count(male) as
		(select count(*) as male from olympics_history where sex = 'M'),
	female_count(female) as
		(select count(*) as female from olympics_history where sex = 'F')
select m.male, f.female , concat('1 : ' , round((m.male::decimal / f.female::decimal),2) )as ratio
from male_count m,female_count f;



/*
Q11. Fetch the top 5 athletes who have won the most gold medals
*/

	with athlete_medal_count as
		(select name, team, sport, COUNT(*) as total_gold_medals from olympics_history
		where medal = 'Gold'
		group by name, team,sport
		order by total_gold_medals desc),
	top_5 as 
		(select *,
		 dense_rank() over(order by total_gold_medals desc) as athlete_rank from athlete_medal_count)
select name, team,sport, total_gold_medals from top_5
where athlete_rank <= 5;

/*
Q12. Fetch the top 5 athletes who have won the most medals (gold/silver/bronze)
*/
	with medal_table as
		(select id, name,team, sport, count(medal) as total_medals from olympics_history 
			 where medal <> 'NA' 
			 group by id, name, team,sport
			 order by total_medals desc),
	rank_table as	
		(select * , 
		 dense_rank() over(order by total_medals desc) as rnk
		 from medal_table)
select name,team, sport, total_medals from rank_table where rnk <= 5;


/*
Q13. Fetch the top 5 most successful countries in Olympics. Success is defined by no 
of medals won.
*/

	with medals_table as
			(select nr.region as country, count(*) as total_medals 
			from olympics_history oh 
				join olympics_history_noc_regions nr using (noc)
			where medal <> 'NA'
			group by nr.region
			order by total_medals desc),
		rank_table as
			(select *,
			dense_rank() over(order by total_medals desc) as rnk
			from medals_table)
select country, total_medals 
from rank_table where rnk <= 5;


/*
Q14. List down total gold, silver and bronze medals won by each country
*/	
	with medal_table as
		(select nr.region as country , oh.medal from olympics_history oh
			join olympics_history_noc_regions nr using (noc)
		where medal <> 'NA'),
		t2 as
		(select country, medal , count(*) as medals from medal_table group by country, medal
		order by country)
select country, medal, medals,
sum(medals) over(partition by country)as total_medals
from t2
order by total_medals desc


-- optinal approach - for converting row level data to column level

select country
    	, coalesce(Gold, 0) as gold
    	, coalesce(Silver, 0) as silver
    	, coalesce(Bronze, 0) as bronze
	from crosstab('select nr.region as country , oh.medal, count(*) as total_medals
					from olympics_history oh
					join olympics_history_noc_regions nr using (noc)
					where medal <> ''NA''
					group by country, medal
					order by country, medal',
				 'values (''Bronze''), (''Gold''), (''Silver'')')
			as result(country varchar, Bronze bigint , Gold bigint , Silver bigint)
order by Gold desc, Silver desc , Bronze desc;



/*
Q15. List down total gold, silver and bronze medals won by each country 
corresponding to each Olympics games.
*/

SELECT substring(games,1,position(' - ' in games) - 1) as games
			, substring(games,position(' - ' in games) + 3) as country
			, coalesce(gold, 0) as gold
			, coalesce(silver, 0) as silver
			, coalesce(bronze, 0) as bronze
    FROM CROSSTAB('SELECT concat(games, '' - '', nr.region) as games
			, medal , count(1) as total_medals
			FROM olympics_history oh
			JOIN olympics_history_noc_regions nr ON nr.noc = oh.noc
			where medal <> ''NA''
			GROUP BY games,nr.region,medal
			order BY games,medal',
            'values (''Bronze''), (''Gold''), (''Silver'')')
    AS FINAL_RESULT(games text, bronze bigint, gold bigint, silver bigint);


/*
Q16. Identify which country won the most gold, most silver and most bronze medals in 
each Olympics games.
*/

 WITH temp as
    	(SELECT substring(games, 1, position(' - ' in games) - 1) as games
    	 	, substring(games, position(' - ' in games) + 3) as country
            , coalesce(gold, 0) as gold
            , coalesce(silver, 0) as silver
            , coalesce(bronze, 0) as bronze
    	FROM CROSSTAB('SELECT concat(games, '' - '', nr.region) as games
			,medal , count(1) as total_medals
			  FROM olympics_history oh
			  JOIN olympics_history_noc_regions nr ON nr.noc = oh.noc
			  where medal <> ''NA''
			  GROUP BY games,nr.region,medal
			  order BY games,medal',
		  'values (''Bronze''), (''Gold''), (''Silver'')')
    AS FINAL_RESULT(games text, bronze bigint, gold bigint, silver bigint))
select distinct games
	, concat(first_value(country) over(partition by games order by gold desc)
			, ' - '
			, first_value(gold) over(partition by games order by gold desc)) as Max_Gold
	, concat(first_value(country) over(partition by games order by silver desc)
			, ' - '
			, first_value(silver) over(partition by games order by silver desc)) as Max_Silver
	, concat(first_value(country) over(partition by games order by bronze desc)
			, ' - '
			, first_value(bronze) over(partition by games order by bronze desc)) as Max_Bronze
    from temp
    order by games;

/*
Q17. Identify which country won the most gold, most silver, most bronze medals and 
the most medals in each Olympics games.
*/

    with temp as
    	(SELECT substring(games, 1, position(' - ' in games) - 1) as games
    		, substring(games, position(' - ' in games) + 3) as country
    		, coalesce(gold, 0) as gold
    		, coalesce(silver, 0) as silver
    		, coalesce(bronze, 0) as bronze
    	FROM CROSSTAB('SELECT concat(games, '' - '', nr.region) as games
			  ,medal , count(1) as total_medals
			  FROM olympics_history oh
			  JOIN olympics_history_noc_regions nr ON nr.noc = oh.noc
			  where medal <> ''NA''
			  GROUP BY games,nr.region,medal
			  order BY games,medal',
		      'values (''Bronze''), (''Gold''), (''Silver'')')
    		AS FINAL_RESULT(games text, bronze bigint, gold bigint, silver bigint)),
    tot_medals as
				(SELECT games, nr.region as country, count(1) as total_medals
				FROM olympics_history oh
				JOIN olympics_history_noc_regions nr ON nr.noc = oh.noc
				where medal <> 'NA'
				GROUP BY games,nr.region order BY 1, 2)
select distinct t.games
	, concat(first_value(t.country) over(partition by t.games order by gold desc)
			, ' - '
			, first_value(t.gold) over(partition by t.games order by gold desc)) as Max_Gold
	, concat(first_value(t.country) over(partition by t.games order by silver desc)
			, ' - '
			, first_value(t.silver) over(partition by t.games order by silver desc)) as Max_Silver
	, concat(first_value(t.country) over(partition by t.games order by bronze desc)
			, ' - '
			, first_value(t.bronze) over(partition by t.games order by bronze desc)) as Max_Bronze
	, concat(first_value(tm.country) over (partition by tm.games order by total_medals desc nulls last)
			, ' - '
			, first_value(tm.total_medals) over(partition by tm.games order by total_medals desc nulls last))
			as Max_Medals
from temp t
join tot_medals tm on tm.games = t.games and tm.country = t.country
order by games;



/*
Q18. Which countries have never won gold medal but have won silver/bronze medals?
*/

	with t1 as
		(select country,
		coalesce(gold, 0) as gold,
		coalesce(silver, 0) as silver,
		coalesce(bronze, 0) as bronze
		from crosstab('select nr.region as country , medal, count(*) as medals_count
						from olympics_history oh join
						olympics_history_noc_regions nr on oh.noc = nr.noc
						where medal <> ''NA'' 
						group by nr.region , medal 
						order by nr.region , medal ',
					  'values (''Bronze''), (''Gold''), (''Silver'')')
		as result (country varchar ,bronze bigint, gold bigint ,silver bigint))
select * from t1 where gold = 0
order by silver desc ,bronze desc;



/*
Q19. In which Sport/event, India has won highest medals
*/

	with t1 as
			(select sport, count(*) as medals from
			(select games, sport, event, medal
			from olympics_history
			where team = 'India' and medal <> 'NA'
			group by games, sport, event, medal
			order by games, event) temp
			group by sport
			order by medals desc),
	t2 as
			(select *,
			dense_rank() over(order by medals desc) as rnk
			from t1)
select sport, medals from t2 where rnk = 1;



/*
Q20. Break down all Olympics games where India won medal for Hockey and how 
many medals in each Olympics games
*/

select  nr.region , sport, oh.games, count(*) as total_medals
from olympics_history oh join 
olympics_history_noc_regions nr on oh.noc = nr.noc
where nr.region = 'India' and oh.sport = 'Hockey' and medal <> 'NA'
group by  oh.games, nr.region , sport
order  by total_medals desc;



