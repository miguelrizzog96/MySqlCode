##### TEAMS WITH THEIR PAYROLL OVER THE YEARS AND THE WIN COST as a function of the wins and payroll of the team
USE lahmansbaseballdb;
SELECT s.yearID,t.name,t.W,ROUND(SUM(s.salary),2)AS Payroll, ROUND(SUM(s.salary)/t.W ,2)AS W_cost
FROM salaries s
JOIN teams t
ON t.ID = s.team_ID
WHERE t.yearID>1999 
GROUP BY t.yearID,t.name
ORDER BY t.W DESC,W_cost ASC   
Limit 1000;
 
 #### TOP 10 VENEZUELANS WITH THE MOST HOME RUNS ON THE HISTORY OF MLB
SELECT SUM(b.HR)AS Home_runs,p.nameFirst,p.nameLast,p.debut, p.birthCountry,p.finalGame
FROM batting b
JOIN people p
ON b.playerID=p.playerID
WHERE YEAR(p.debut) >1980 AND p.birthCountry='Venezuela'
GROUP BY p.nameFirst,p.nameLast
ORDER BY Home_runs DESC
LIMIT 10;
###############################################################
### TOP 3 TEAMS WITH MOST WINS SEASON BY SEASON
###############################################################
SELECT ranks.name,yearID,W,L,team_rank
FROM
	(SELECT 
		name, 
		yearID,
		W,
        L,
		ROW_NUMBER() OVER (PARTITION BY yearID ORDER BY W desc) AS team_rank 
    FROM teams) ranks 
WHERE team_rank <= 3 AND yearID>='2000';
################################################################################
#Team's Ballparks
################################################################################
SELECT parkname,parkalias,teamkey,city,state,hm.attendance,tf.franchName FROM parks p
JOIN homegames hm 
ON p.ID=hm.park_ID
JOIN teams t
ON t.ID= hm.team_ID
JOIN teamsfranchises tf
ON t.franchID=tf.franchID
WHERE yearkey>2010
GROUP BY franchName
ORDER BY attendance DESC;
##############################################################################
#Teams withs most world series wins
###############################################################################
SELECT  franchname, COUNT(t.WSWin) AS ws_won  FROM teams t
JOIN teamsfranchises f
ON f.franchID=t.franchID
where t.WSWin ='Y'
GROUP BY franchname
ORDER BY ws_won DESC;
#################################################################################
# count of world series per league (National, American)
###############################################################################
SELECT  lgID, COUNT(t.WSWin) AS ws_won  FROM teams t
JOIN teamsfranchises f
ON f.franchID=t.franchID
where t.WSWin ='Y'
GROUP BY lgID
ORDER BY ws_won DESC;
##################################################################################
#Nº of active players per country
##################################################################################
SELECT yearID,birthCountry, SUM(p_active) AS n_active_players  FROM (SELECT DISTINCT
	t1.nameFirst,
    t1.nameLast,
    t1.debut_date,
    t1.finalgame_date,
    t2.yearID,
    t1.birthCountry,
    CASE WHEN t2.yearID BETWEEN YEAR(t1.debut_date) AND YEAR(t1.finalgame_date)THEN 1
    ELSE 0
    END AS p_active
FROM 
	people t1
CROSS JOIN 
	teams t2
) t
WHERE p_active=1
GROUP BY yearID,birthCountry,p_active
ORDER BY yearID,n_active_players DESC;

#####################################################################################
#lowest seeded teams to win world series
#####################################################################################
SELECT * FROM teams
WHERE WSWin ='Y'
ORDER BY L DESC,lgID DESC;

#####################################################################################
#teams with more wins than the Colorado Rockies on 2001 season
#####################################################################################
SELECT name, W
FROM teams 
WHERE W >(SELECT W FROM teams WHERE name='Colorado Rockies' AND yearID=2001)AND yearID=2001;
#########
#Players with more home runs than andres Galarraga
SELECT nameFirst,nameLast,debut,birthCountry,SUM(HR) AS home_runs FROM people p
JOIN batting b ON p.playerID=b.playerID
GROUP BY nameFirst, nameLast
HAVING home_runs>(SELECT SUM(HR)FROM people p JOIN batting b ON p.playerID=b.playerID
WHERE nameFirst='Andres' AND nameLast= 'Galarraga'
GROUP BY nameFirst, nameLast);

###################################################################
#SELECT TEAMS THAT ARE ON THE SAME DIVISION AS the yankees or CUBS
#####################################################################
SELECT franchName ,d.division FROM teamsfranchises f
JOIN teams t 
ON t.franchID=f.franchID 
JOIN divisions d
ON d.ID=t.div_ID
WHERE d.active='Y' AND f.active='Y' AND t.yearID=2019
AND d.division IN (SELECT d.division FROM teamsfranchises f
JOIN teams t 
ON t.franchID=f.franchID 
JOIN divisions d
ON d.ID=t.div_ID
WHERE yearID=2019 AND (franchName ='New York Yankees' OR franchName='Chicago Cubs'))
;


##### all posible matchups
SELECT t1.franchName,'VS',t2.franchName FROM teamsfranchises t1
CROSS JOIN teamsfranchises t2 
WHERE t1.active='Y' AND t2.active='Y'
AND t1.franchName <> t2.franchName
ORDER BY t1.franchName,t2.franchName;



SELECT distinct birthYear, CASE 
WHEN birthYear LIKE '191%' THEN '1910s'
                 WHEN 
                 birthYear LIKE '192%' THEN '1920s'
                 WHEN birthYear LIKE '193%' THEN '1930s'
                 WHEN birthYear LIKE '194%' THEN '1940s'
                 WHEN birthYear LIKE '195%' THEN '1950s'
                 WHEN birthYear LIKE '196%' THEN '1960s'
                 WHEN birthYear LIKE '197%' THEN '1970s'
                 WHEN birthYear LIKE '198%' THEN '1980s'
                 WHEN birthYear LIKE '199%' THEN '1990s' END as f FROM people
ORDER BY birthYear DESC;


SELECT 
	yearID,
    lgID,
    name,
    W,
    AVG(W) OVER(PARTITION BY lgID)as league_avg,
    W-AVG(W) OVER(PARTITION BY lgID) as Diff
FROM 
	teams 
WHERE 
	yearID>1999
ORDER BY 
	Diff DESC,yearID;

SELECT yearID,name,W,L, W/(W+L) AS WinPercentage
FROM teams
WHERE yearID>1970
ORDER BY WinPercentage DESC;
; 

SELECT ROUND(AVG(s.salary)), ROUND(AVG(ERA),2), concat(nameFirst,' ', nameLast) AS Full_Name FROM pitching pi
JOIN people pe ON pe.playerID =pi.playerID 
JOIN salaries s ON pe.playerID=s.playerID
WHERE s.yearID >2010 AND G >50
GROUP BY Full_name;

SELECT * FROM people
WHERE YEAR(debut)=2000;

SELECT * FROM BATTING
WHERE yearID BETWEEN 2014 AND 2015
;

SELECT AVG(sa.salary),bat.*,bat.H/bat.AB AS BA,
(H + BB + HBP)/(AB + BB + HBP + SF) AS OBP
 FROM 
salaries sa 
JOIN batting bat ON
sa.playerID=bat.playerID
WHERE sa.yearID BETWEEN 2014 AND 2015
AND bat.yearID BETWEEN 2014 AND 2015
AND bat.AB>25
GROUP BY playerID, yearID;

