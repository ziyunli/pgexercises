-- Count the number of facilities
-- Question
-- For our first foray into aggregates, we're going to stick to something simple. We want to know how many facilities exist - simply produce a total count.
SELECT count(*)
FROM cd.facilities;

-- Count the number of expensive facilities
-- Question
-- Produce a count of the number of facilities that have a cost to guests of 10 or more.
SELECT count(*)
FROM cd.facilities
WHERE guestcost >= 10;

-- Count the number of recommendations each member makes.
-- Question
-- Produce a count of the number of recommendations each member has made. Order by member ID.
SELECT *
FROM (SELECT recs.memid                                                                   AS recommendedby,
             (SELECT count(*) FROM cd.members mems WHERE mems.recommendedby = recs.memid) AS count
      FROM cd.members recs
      WHERE recs.memid > 0) AS results
WHERE results.count > 0;

-- GROUP BY batches the data together into groups, and run the aggregation function separately for each group.
SELECT recommendedby, count(*)
FROM cd.members
WHERE recommendedby IS NOT NULL
GROUP BY recommendedby
ORDER BY recommendedby;

-- List the total slots booked per facility
-- Question
-- Produce a list of the total number of slots booked per facility. For now, just produce an output table consisting of facility id and slots, sorted by facility id.
SELECT facid, sum(slots) AS "Total Slots"
FROM cd.bookings
GROUP BY facid
ORDER BY facid;

-- List the total slots booked per facility in a given month
-- Question
-- Produce a list of the total number of slots booked per facility in the month of September 2012. Produce an output table consisting of facility id and slots, sorted by the number of slots.
SELECT facid, sum(slots) AS "Total Slots'"
FROM cd.bookings
WHERE starttime BETWEEN '2012-09-01' AND '2012-10-01'
GROUP BY facid
ORDER BY sum(slots);

-- List the total slots booked per facility per month
-- Question
-- Produce a list of the total number of slots booked per facility per month in the year of 2012. Produce an output table consisting of facility id and slots, sorted by the id and month.
SELECT facid, date_part('month', starttime) AS month, sum(slots)
FROM cd.bookings
WHERE starttime BETWEEN '2012-01-01' AND '2013-01-01'
GROUP BY (facid, date_part('month', starttime))
ORDER BY (facid, date_part('month', starttime));

SELECT facid, extract(MONTH FROM starttime) AS month, sum(slots) AS "Total Slots"
FROM cd.bookings
WHERE starttime >= '2012-01-01'
  AND starttime < '2013-01-01'
GROUP BY facid, month
ORDER BY facid, month;

-- Find the count of members who have made at least one booking
-- Question
-- Find the total number of members who have made at least one booking.
SELECT count(DISTINCT memid)
FROM cd.bookings;

-- List facilities with more than 1000 slots booked
-- Question
-- Produce a list of facilities with more than 1000 slots booked. Produce an output table consisting of facility id and hours, sorted by facility id.
SELECT facid, total AS "Total Slots"
FROM (SELECT facid, sum(slots) AS total FROM cd.bookings GROUP BY facid) AS counts
WHERE total > 1000
ORDER BY facid;

-- WHERE is used to filter what data gets input into the aggregate function,
-- while HAVING is used to filter the data once it is output from the function.
SELECT facid, sum(slots) AS "Total Slots"
FROM cd.bookings
GROUP BY facid
HAVING sum(slots) > 1000
ORDER BY facid;

-- Find the total revenue of each facility
-- Question
-- Produce a list of facilities along with their total revenue. The output table should consist of facility name and revenue, sorted by revenue. Remember that there's a different cost for guests and members!
SELECT f.name, sum((CASE WHEN memid = 0 THEN f.guestcost ELSE f.membercost END) * slots) AS revenue
FROM cd.facilities f
         JOIN cd.bookings b ON b.facid = f.facid
GROUP BY f.facid
ORDER BY revenue;
