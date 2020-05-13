-- Retrieve the start times of members' bookings
SELECT b.starttime
FROM cd.bookings b
         JOIN cd.members m ON b.memid = m.memid
WHERE m.surname = 'Farrell'
  AND m.firstname = 'David';

-- Work out the start times of bookings for tennis courts
SELECT bks.starttime AS START, facs."name" AS name
FROM cd.bookings bks
         JOIN cd.facilities facs ON bks.facid = facs.facid
WHERE DATE(bks.starttime) = '2012-09-21'
  AND facs.name LIKE 'Tennis Court%'
ORDER BY bks.starttime;

-- Produce a list of all members who have recommended another member
SELECT firstname, surname
FROM cd.members
WHERE memid IN (SELECT DISTINCT referer.memid
                FROM cd.members referer
                         JOIN cd.members referee ON referee.recommendedby = referer.memid)
ORDER BY surname, firstname;

SELECT DISTINCT recs.firstname AS firstname, recs.surname AS surname
FROM cd.members mems
         INNER JOIN cd.members recs ON recs.memid = mems.recommendedby
ORDER BY surname, firstname;

-- Produce a list of all members, along with their recommender
SELECT referee.firstname memfname, referee.surname memsname, referer.firstname recfname, referer.surname refsname
FROM cd.members AS referee
         LEFT JOIN cd.members AS referer ON referee.recommendedby = referer.memid
ORDER BY referee.surname, referee.firstname;

-- Produce a list of all members who have used a tennis court
SELECT DISTINCT mems.firstname || ' ' || mems.surname AS member, facs.name AS facility
FROM cd.members mems
         JOIN cd.bookings bks ON mems.memid = bks.memid
         JOIN cd.facilities facs ON bks.facid = facs.facid
WHERE facs."name" LIKE 'Tennis Court%'
ORDER BY member;

-- Produce a list of costly bookings
SELECT mems.firstname || ' ' || mems.surname                                                         AS member,
       facs.name                                                                                     AS facility,
       CASE WHEN mems.memid = 0 THEN facs.guestcost * bks.slots ELSE facs.membercost * bks.slots END AS COST
FROM cd.members mems
         INNER JOIN cd.bookings bks ON mems.memid = bks.memid
         INNER JOIN cd.facilities facs ON bks.facid = facs.facid
WHERE DATE(bks.starttime) = '2012-09-14'
  AND ((mems.memid = 0 AND bks.slots * facs.guestcost > 30) OR (mems.memid != 0 AND bks.slots * facs.membercost > 30))
ORDER BY COST DESC;


-- Produce a list of all members, along with their recommender, using no joins.
SELECT DISTINCT mems.firstname || ' ' || mems.surname AS member,
                (SELECT recs.firstname || ' ' || recs.surname AS recommender
                 FROM cd.members recs
                 WHERE recs.memid = mems.recommendedby)
FROM cd.members mems
ORDER BY member;

-- Produce a list of costly bookings, using a subquery
SELECT member, facility, cost
FROM (SELECT mems.firstname || ' ' || mems.surname                                                         AS member,
             facs.name                                                                                     AS facility,
             CASE WHEN mems.memid = 0 THEN bks.slots * facs.guestcost ELSE bks.slots * facs.membercost END AS COST
      FROM cd.members mems
               INNER JOIN cd.bookings bks ON mems.memid = bks.memid
               INNER JOIN cd.facilities facs ON bks.facid = facs.facid
      WHERE DATE(bks.starttime) = '2012-09-14') AS bookings
WHERE cost > 30
ORDER BY cost DESC;
