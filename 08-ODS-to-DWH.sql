USE DATABASE RESTAURANT_WEATHER;

create schema DWH;

USE SCHEMA DWH;

// PRECIPITATION
CREATE OR REPLACE TABLE DIM_PRECIPITATION (
    date date,
    precipitation float,
    precipitation_normal float
);

// LOAD
INSERT INTO DWH.DIM_PRECIPITATION SELECT * FROM ODS.precipitation;

// SAMPLE DATA
SELECT *
FROM DWH.DIM_PRECIPITATION
LIMIT 1000;

// -------------------------------
// TEMPERATURE

SELECT *
FROM ODS.TEMPERATURE
LIMIT 1000;

CREATE OR REPLACE TABLE DIM_TEMPERATURE (
    date date,
    min float,
    max float,
    normal_min float,
    normal_max float
);

insert into DWH.DIM_TEMPERATURE select * from ODS.TEMPERATURE;

SELECT *
FROM DWH.DIM_TEMPERATURE
LIMIT 1000;


// -------------------------------
// BUSINESS
SELECT *
FROM ODS.YELP_BUSINESSES
LIMIT 100;

CREATE OR REPLACE TABLE DIM_BUSINESSES (
    business_id string,
    name string,
    address string,
    city string,
    state string,
    postal_code string,
    latitude float,
    longitude float,
    stars float,
    review_count number,
    is_open number,
    attributes variant,
    categories string,
    hours variant,
    constraint pk_business_id primary key (business_id)
);

INSERT INTO DIM_BUSINESSES 
SELECT 
    *
FROM ODS.YELP_BUSINESSES;

SELECT *
FROM DWH.DIM_BUSINESSES
LIMIT 1000;


// ----------------------------
// USERS
SELECT *
FROM ODS.YELP_USERS
LIMIT 100;

CREATE OR REPLACE TABLE DIM_USERS (
    user_id string,
    name string,
    review_count string,
    yelping_since timestamp,
    useful number,
    funny number,
    cool number,
    elite string,
    friends variant,
    fans number,
    average_stars float,
    compliment_hot number,
    compliment_more number,
    compliment_profile number,
    compliment_cute number,
    compliment_list number,
    compliment_note number,
    compliment_plain number,
    compliment_cool number,
    compliment_funny number,
    compliment_writer number,
    compliment_photos number,
    constraint pk_user_id primary key (user_id)
);

INSERT INTO DIM_USERS
SELECT *
FROM ODS.YELP_USERS;

SELECT * 
FROM DWH.DIM_USERS
LIMIT 100;

// ----------------------------
// REVIEWS

SELECT *
FROM ODS.YELP_REVIEWS
LIMIT 100;

CREATE OR REPLACE TABLE DIM_REVIEWS (
    review_id string,
    user_id string,
    business_id string,
    stars float,
    useful number,
    funny number,
    cool number,
    text string, 
    date timestamp_ntz,
    constraint pk_review_id primary key (review_id)
);

INSERT INTO DIM_REVIEWS
SELECT
    *
FROM ODS.YELP_REVIEWS;

SELECT * 
FROM DWH.DIM_REVIEWS
LIMIT 1000;

//---------------------------------------
// FACT TABLE

create or replace table FACT_CLIMATE_REVIEW (
  date date,
  review_id string,
  business_id string,
  user_id string,
  min_temperature float,
  max_temperature float,
  precipitation float,
  stars float,
  primary key (date, review_id, business_id)
);


INSERT INTO FACT_CLIMATE_REVIEW
SELECT r.date, r.review_id, r.business_id, r.user_id, t.min, t.max, p.precipitation, r.stars
FROM DWH.DIM_REVIEWS r
JOIN DWH.DIM_USERS u ON u.user_id = r.user_id
JOIN DWH.DIM_PRECIPITATION p ON cast(date_trunc('DAY', r.date) as date) = p.date
JOIN DWH.DIM_TEMPERATURE t ON cast(date_trunc('DAY', r.date) as date) = t.date
JOIN DWH.DIM_BUSINESSES b ON r.business_id = b.business_id
AND p.precipitation != 999; -- filter out bad precipitation values


// SAMPLE DATA
SELECT * 
FROM DWH.FACT_CLIMATE_REVIEW
LIMIT 1000;



