/* Welcome to the SQL mini project. For this project, you will use
Springboard' online SQL platform, which you can log into through the
following link:

https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

Note that, if you need to, you can also download these tables locally.

In the mini project, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */



/* Q1: Some of the facilities charge a fee to members, but some do not.
Please list the names of the facilities that do. */

SELECT * 
	FROM  `Facilities` /*grab all columns and rows from the facilities table of the database*/  
	WHERE  `membercost` > 0 /* return rows in which the member cost is greater than */


/* Q2: How many facilities do not charge a fee to members? */

/*count the member cost column of the facilities table if member cost is equal to zero*/

SELECT COUNT(  `membercost` )
	FROM  `Facilities` 
	WHERE  `membercost` = 0


/* Q3: How can you produce a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost?
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

SELECT facid, /*return the facility id, name, membercost and monthly maintenance columns from the facilities table*/
       name, 
       membercost, 
       monthlymaintenance, 
       (membercost / monthlymaintenance) *100 AS cost_maint_pct /*divide member cost by monthly maintainance, multiply by a 100 and return as a new column*/
	FROM Facilities
	WHERE membercost > 0
	AND membercost / monthlymaintenance < 20 /*return rows in which member cost greater than zero and cost/maintance percent is below 20*/


/* Q4: How can you retrieve the details of facilities with ID 1 and 5?
Write the query without using the OR operator. */

SELECT * 
	FROM Facilities
	WHERE facid
	IN ('1',  '5') /*select all rows whose id 'matches' 1 or 5*/


/* Q5: How can you produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100? Return the name and monthly maintenance of the facilities
in question. */

SELECT name, 
       monthlymaintenance, /*select name and monthly maintanace fields of fthe facilities table*/
	   CASE WHEN monthlymaintenance > 100 /*if monthly maintenance cost is >100 'label' as expensive and <100 cheap, results are return on a new column*/
	   THEN  'expensive'
 	   ELSE  'cheap'
	   END AS cheap_or_expensive
FROM `Facilities` 


/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Do not use the LIMIT clause for your solution. */

SELECT joindate, 
	   firstname,
	   surname /*select joindate, first name and surname from the members table*/
	FROM Members
	WHERE joindate = (SELECT MAX( joindate ) FROM Members ) /*return rows in which the join data is the max joindate of the members table*/ 


/* Q7: How can you produce a list of all members who have used a tennis court?
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

/*Step1. Return name of facility column from facilities table and 
concatenate first name and last name of members table and return the column*/

/*Step2. Inner join bookings and facilities table using the facility id.*/

/*Step3. Inner join members and bookings table using the member id.*/

/*Step4. Return rows in which memvber id does not equal 0 and 
name match similar 'TENNIS COURT%' values*/

/*Step5. Group by name and member name, sort ascending by member name*/


SELECT Facilities.name AS name, CONCAT(Members.firstname,  ' ', Members.surname ) AS member_name
	FROM Bookings
	JOIN Facilities ON Bookings.facid = Facilities.facid
	JOIN Members ON Bookings.memid = Members.memid
	WHERE Bookings.memid !=0 
	AND Facilities.name LIKE  'TENNIS COURT%'
GROUP BY name, member_name
ORDER BY member_name

/* Q8: How can you produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30? Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

SELECT f.name, surname AS member, f.guestcost * b.slots AS cost
FROM country_club.Bookings b
JOIN country_club.Facilities f ON b.facid = f.facid
JOIN country_club.Members m ON m.memid = b.memid
WHERE LEFT( starttime, 10 ) =  '2012-09-14'
AND m.memid =0

UNION 

SELECT f.name, CONCAT( m.firstname,  ' ', m.surname ) AS member, SUM( f.membercost * b.slots ) AS cost
FROM country_club.Bookings b
JOIN country_club.Facilities f ON b.facid = f.facid
JOIN country_club.Members m ON m.memid = b.memid
WHERE LEFT( starttime, 10 ) =  '2012-09-14'
AND m.memid !=0
GROUP BY m.memid
HAVING cost >30
ORDER BY cost DESC 
LIMIT 0 , 30


/* Q9: This time, produce the same result as in Q8, but using a subquery. */

SELECT g.name, surname AS member, g.cost
FROM country_club.Members m

JOIN (

SELECT b.memid, f.name, slots * guestcost AS cost
FROM country_club.Bookings b
JOIN country_club.Facilities f ON b.facid = f.facid
WHERE LEFT( starttime, 10 ) =  '2012-09-14'
AND memid =0
)g ON m.memid = g.memid
WHERE cost >30

UNION 

SELECT mem.name, CONCAT( m.firstname,  ' ', m.surname ) AS member, mem.cost
FROM country_club.Members m
JOIN (

SELECT b.memid, f.name, SUM( f.membercost * b.slots ) AS cost
FROM country_club.Bookings b
JOIN country_club.Facilities f ON b.facid = f.facid
JOIN country_club.Members m ON m.memid = b.memid
WHERE LEFT( starttime, 10 ) =  '2012-09-14'
AND m.memid !=0
GROUP BY m.memid
)mem ON m.memid = mem.memid
WHERE cost >30
ORDER BY cost DESC 
LIMIT 0 , 30


/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

/*Step1. Return name of facility column from facilities table*/

/*Step 2. If member id = 0 (this means is a guest) multiply slots column by guest cost column, else 
multiply slots column by member cost column, then sum the resulting products 
and return as column total_revenue

/*Step3. Inner join bookings and facilities table using the facility id.*/

/*Step4. Inner join members and bookings table using the member id.*/

/*Step4. Group by facility name, return rows with total revenue below 1,000 and 
ort revenue in descending order*/


SELECT Facilities.name, 
SUM(
CASE WHEN Bookings.memid =0
THEN Facilities.guestcost * Bookings.slots
ELSE Facilities.membercost * Bookings.slots
END ) AS total_revenue
FROM Facilities
JOIN Bookings ON Facilities.facid = Bookings.facid
GROUP BY name 
HAVING total_revenue <1000
ORDER BY total_revenue DESC













