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
select name from Facilities where membercost > 0

/* Q2: How many facilities do not charge a fee to members? */
select count(*) from Facilities where membercost = 0

/* Q3: How can you produce a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost?
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */
select facid,name as "facility name",membercost as "member cost" ,
monthlymaintenance as "monthly maintenance" from Facilities
where membercost > 0 and membercost < (monthlymaintenance * 0.2)

/* Q4: How can you retrieve the details of facilities with ID 1 and 5?
Write the query without using the OR operator. */
select * from Facilities where facid in (1,5)

/* Q5: How can you produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100? Return the name and monthly maintenance of the facilities
in question. */
select name, monthlymaintenance as "monthly maintenance" ,
case when monthlymaintenance > 100 then "expensive"
	 else "cheap" END as is_expensive
from Facilities

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Do not use the LIMIT clause for your solution. */
select firstname as "first name",surname as "last name" from Members
where joindate = (select max(joindate) from Members)

/* Q7: How can you produce a list of all members who have used a tennis court?
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */
select distinct fac.name as "name of the court",
 concat(mem.firstname,' ',mem.surname) as "name of the member"
 from Members mem
join Bookings book
on mem.memid = book.memid
join Facilities fac
on book.facid = fac.facid
where fac.name like 'Tennis court%'
order by mem.firstname,mem.surname

/* Q8: How can you produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30? Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */
select fac.name as "name of the court",
 concat(mem.firstname,' ',mem.surname) as "name of the member",
sum(case when mem.memid = 0 then book.slots * fac.guestcost
    else book.slots * fac.membercost end) as cost
from Members mem
join Bookings book
on mem.memid = book.memid
join Facilities fac
on book.facid = fac.facid
where date(book.starttime) = '2012-09-14'
group by mem.firstname,mem.surname
having cost > 30
order by cost desc

/* Q9: This time, produce the same result as in Q8, but using a subquery. */
select sub.name_fac as "name of the court",
 concat(mem.firstname,' ',mem.surname) as "name of the member",
sub.cost_tot as cost 
from
(select book.memid as mem_id, fac.name as name_fac, 
sum(case when book.memid = 0 then book.slots * fac.guestcost
    else book.slots * fac.membercost end) as cost_tot
from Bookings book
join Facilities fac
on fac.facid = book.facid
where date(book.starttime) = '2012-09-14'
group by book.memid
having cost_tot > 30) sub
join Members mem on
mem.memid = sub.mem_id
order by cost desc

/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */
select fac.name as "facility name",
sum(case when book.memid = 0 then book.slots * fac.guestcost
    else book.slots * fac.membercost end) as total_revenue
from Bookings book
join Facilities fac
on book.facid = fac.facid
group by fac.name
having total_revenue > 1000
order by total_revenue