/*
Two tables need to be created for loading the data , first one is OLYMPICS_HISTORY and second one is OLYMPICS_HISTORY_NOC_REGIONS.
1.  OLYMPICS_HISTORY table is loaded with data from the file athlete_events.csv which contains 271116 rows and 15 columns. Each row corresponds to an
    individual athlete competing in an individual Olympic event (athlete-events).
2.  OLYMPICS_HISTORY_NOC_REGIONS table contains NOCs (National Olympic Committees) information and the country it belongs to.
    Data from noc_regions.csv file is loaded into this table.
*/


DROP TABLE IF EXISTS OLYMPICS_HISTORY;
CREATE TABLE IF NOT EXISTS OLYMPICS_HISTORY
(
    id          INT,
    name        VARCHAR,
    sex         VARCHAR,
    age         VARCHAR,
    height      VARCHAR,
    weight      VARCHAR,
    team        VARCHAR,
    noc         VARCHAR,
    games       VARCHAR,
    year        INT,
    season      VARCHAR,
    city        VARCHAR,
    sport       VARCHAR,
    event       VARCHAR,
    medal       VARCHAR
);

DROP TABLE IF EXISTS OLYMPICS_HISTORY_NOC_REGIONS;
CREATE TABLE IF NOT EXISTS OLYMPICS_HISTORY_NOC_REGIONS
(
    noc         VARCHAR,
    region      VARCHAR,
    notes       VARCHAR
);

select * from OLYMPICS_HISTORY;
select * from OLYMPICS_HISTORY_NOC_REGIONS;
