--
-- Insert some data into a table
--     Question
--
--     The club is adding a new facility - a spa. We need to add it into the facilities table. Use the following values:
--
--     facid: 9, Name: 'Spa', membercost: 20, guestcost: 30, initialoutlay: 100000, monthlymaintenance: 800.
--
INSERT INTO cd.facilities (facid, name, membercost, guestcost, initialoutlay, monthlymaintenance)
VALUES (9, 'Spa', 20, 30, 100000, 800);

-- Insert multiple rows of data into a table
--     Question
--
--     In the previous exercise, you learned how to add a facility. Now you're going to add multiple facilities in one command. Use the following values:
--
--     facid: 9, Name: 'Spa', membercost: 20, guestcost: 30, initialoutlay: 100000, monthlymaintenance: 800.
--     facid: 10, Name: 'Squash Court 2', membercost: 3.5, guestcost: 17.5, initialoutlay: 5000, monthlymaintenance: 80.
--
INSERT INTO cd.facilities (facid, name, membercost, guestcost, initialoutlay, monthlymaintenance)
VALUES (9, 'Spa', 20, 30, 100000, 800),
       (10, 'Squash Court 2', 3.5, 17.5, 5000, 80);

-- While you'll most commonly see VALUES when inserting data, Postgres allows you to use VALUES wherever you might use a SELECT.
-- Similarly, it's possible to use SELECT wherever you see a VALUES. This means that you can INSERT the results of a SELECT.


-- Insert calculated data into a table
--     Question
--
--     Let's try adding the spa to the facilities table again. This time, though, we want to automatically generate the value for the next facid, rather than specifying it as a constant. Use the following values for everything else:
--
--     Name: 'Spa', membercost: 20, guestcost: 30, initialoutlay: 100000, monthlymaintenance: 800.
INSERT INTO cd.facilities (facid, name, membercost, guestcost, initialoutlay, monthlymaintenance)
SELECT (SELECT max(facid) FROM cd.facilities) + 1, 'Spa', 20, 30, 100000, 800;

-- Update some existing data
--     Question
--     We made a mistake when entering the data for the second tennis court. The initial outlay was 10000 rather than 8000: you need to alter the data to fix the error.
UPDATE cd.facilities
SET initialoutlay = 10000
WHERE facid = 1;
-- The WHERE clause is extremely important.

-- Update multiple rows and columns at the same time
--     Question
--     We want to increase the price of the tennis courts for both members and guests. Update the costs to be 6 for members, and 30 for guests.
UPDATE cd.facilities
SET guestcost =30,
    membercost=6
WHERE name LIKE 'Tennis Court%';

-- Update a row based on the contents of another row
--     Question
--     We want to alter the price of the second tennis court so that it costs 10% more than the first one. Try to do this without using constant values for the prices, so that we can reuse the statement if we want to.
UPDATE cd.facilities facs
SET membercost = (SELECT membercost * 1.1 FROM cd.facilities WHERE facid = 0),
    guestcost  = (SELECT guestcost * 1.1 FROM cd.facilities WHERE facid = 0)
WHERE facs.facid = 1;

-- Non-standard extension UPDATE...FROM
UPDATE cd.facilities facs
SET membercost = facs2.membercost * 1.1,
    guestcost  = facs2.guestcost * 1.1
FROM (SELECT * FROM cd.facilities WHERE facid = 0) facs2
WHERE facs.facid = 1;

-- Delete all bookings
--     Question
--     As part of a clearout of our database, we want to delete all bookings from the cd.bookings table. How can we accomplish this?
DELETE
FROM cd.bookings;

-- It's not perfectly safe in all circumstances https://www.postgresql.org/docs/current/mvcc-caveats.html
TRUNCATE cd.bookings;

-- Delete a member from the cd.members table
--     Question
--     We want to remove member 37, who has never made a booking, from our database. How can we achieve that?
DELETE
FROM cd.members
WHERE memid = 37;

-- Substituting in member id 0 instead. This member has made many bookings,
-- and you'll find that the delete fails with an error about a foreign key constraint violation.
-- https://www.postgresql.org/docs/current/ddl-constraints.html


-- Delete based on a subquery
--     Question
--     In our previous exercises, we deleted a specific member who had never made a booking. How can we make that more general, to delete all members who have never made a booking?
DELETE
FROM cd.members
WHERE memid NOT IN (SELECT memid FROM cd.bookings);

-- Or using correlated subquery
DELETE
FROM cd.members mems
WHERE NOT exists(SELECT 1 FROM cd.bookings WHERE memid = mems.memid);
