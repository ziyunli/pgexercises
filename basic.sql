-- Retrieve everything from a table 
SELECT *
FROM cd.facilities;

-- Retrieve specific columns from a table
SELECT name, membercost
FROM cd.facilities;

-- Control which rows are retrieved 
SELECT *
FROM cd.facilities
WHERE membercost > 0;

-- Control which rows are retrieved - part 2
SELECT facid, name, membercost, monthlymaintenance
FROM cd.facilities
WHERE membercost > 0
  AND membercost * 50.0 < monthlymaintenance;

-- Basic string searches 
SELECT *
FROM cd.facilities
WHERE name LIKE '%Tennis%';

-- Matching against multiple possible values 
-- The argument it takes is not just a list of values - it's actually a table with a single column.
SELECT *
FROM cd.facilities
WHERE facid IN (1, 5);

-- Classify results into buckets
SELECT name, (CASE WHEN monthlymaintenance > 100 THEN 'expensive' ELSE 'cheap' END) AS cost
FROM cd.facilities;

-- Working with dates
SELECT memid, surname, firstname, joindate
FROM cd.members
WHERE joindate > '2012-09-01';

-- Removing duplicates and ordering results

SELECT DISTINCT surname
FROM cd.members
ORDER BY surname
LIMIT 10;

-- Combining results from multiple queries
SELECT "name" AS surname
FROM cd.facilities
UNION
SELECT surname
FROM cd.members;

-- Simple aggregation 
-- You'd like to get the signup date of your last member. How can you retrieve this information? 
SELECT MAX(joindate) AS lastest
FROM cd.members;

-- You'd like to get the first and last name of the last member(s) who signed up - not just the date.
SELECT firstname, surname, joindate
FROM cd.members
WHERE joindate = (SELECT max(joindate) FROM cd.members);
