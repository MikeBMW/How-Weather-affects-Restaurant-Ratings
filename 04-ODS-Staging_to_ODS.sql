USE DATABASE RESTAURANT_WEATHER;

USE SCHEMA ODS;

// -------------------------------
// PRECIPITATION

// CLEANING
SELECT * 
FROM staging.NYC_PRECIPITATION
WHERE precipitation = 'T';

UPDATE staging.NYC_PRECIPITATION
SET precipitation = '999'
WHERE precipitation = 'T';

CREATE OR REPLACE TABLE precipitation (
    date date,
    precipitation float,
    precipitation_normal float
);

// LOAD
INSERT INTO precipitation SELECT * FROM staging.NYC_PRECIPITATION;

SELECT *
FROM RESTAURANT_WEATHER.ODS.PRECIPITATION
LIMIT 1000;


// -------------------------------
// TEMPERATURE

SELECT *
FROM RESTAURANT_WEATHER.STAGING.NYC_TEMPERATURE
LIMIT 1000;

CREATE OR REPLACE TABLE temperature (
    date date,
    min float,
    max float,
    normal_min float,
    normal_max float
);

insert into temperature select * from RESTAURANT_WEATHER.STAGING.NYC_TEMPERATURE;

SELECT *
FROM RESTAURANT_WEATHER.ODS.temperature
LIMIT 1000;




// -------------------------------
// BUSINESS
SELECT *
FROM RESTAURANT_WEATHER.STAGING.YELP_BUSINESSES
LIMIT 100;

CREATE OR REPLACE TABLE YELP_BUSINESSES (
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

INSERT INTO YELP_BUSINESSES 
SELECT 
    PARSE_JSON(USERSJSON):business_id,
    PARSE_JSON(USERSJSON):name,
    PARSE_JSON(USERSJSON):address,
    PARSE_JSON(USERSJSON):city,
    PARSE_JSON(USERSJSON):state,
    PARSE_JSON(USERSJSON):postal_code,
    PARSE_JSON(USERSJSON):latitude,
    PARSE_JSON(USERSJSON):longitude,
    PARSE_JSON(USERSJSON):stars,
    PARSE_JSON(USERSJSON):review_count,
    PARSE_JSON(USERSJSON):is_open,
    PARSE_JSON(USERSJSON):attributes,
    PARSE_JSON(USERSJSON):categories,
    PARSE_JSON(USERSJSON):hours
FROM RESTAURANT_WEATHER.STAGING.YELP_BUSINESSES;

SELECT *
FROM RESTAURANT_WEATHER.ODS.YELP_BUSINESSES
LIMIT 1000;


// ----------------------------
// CHECKINS
SELECT *
FROM RESTAURANT_WEATHER.STAGING.YELP_CHECKINS;

CREATE OR REPLACE TABLE YELP_CHECKINS (
    business_id string,
    date string,
    constraint fk_business_id foreign key (business_id) references YELP_BUSINESSES(business_id) 
);

INSERT INTO YELP_CHECKINS
SELECT 
    PARSE_JSON(USERSJSON):business_id,
    PARSE_JSON(USERSJSON):date
FROM RESTAURANT_WEATHER.STAGING.YELP_CHECKINS;

SELECT * 
FROM RESTAURANT_WEATHER.ODS.YELP_CHECKINS
LIMIT 1000;


// ----------------------------
// USERS
SELECT *
FROM RESTAURANT_WEATHER.STAGING.YELP_USERS;

CREATE OR REPLACE TABLE YELP_USERS (
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

INSERT INTO YELP_USERS
SELECT 
    PARSE_JSON(USERSJSON):user_id,
    PARSE_JSON(USERSJSON):name,
    PARSE_JSON(USERSJSON):review_count,
    PARSE_JSON(USERSJSON):yelping_since,
    PARSE_JSON(USERSJSON):useful,
    PARSE_JSON(USERSJSON):funny,
    PARSE_JSON(USERSJSON):cool,
    PARSE_JSON(USERSJSON):elite,
    PARSE_JSON(USERSJSON):friends,
    PARSE_JSON(USERSJSON):fans,
    PARSE_JSON(USERSJSON):average_stars,
    PARSE_JSON(USERSJSON):compliment_hot,
    PARSE_JSON(USERSJSON):compliment_more,
    PARSE_JSON(USERSJSON):compliment_profile,
    PARSE_JSON(USERSJSON):compliment_cute,
    PARSE_JSON(USERSJSON):compliment_list,
    PARSE_JSON(USERSJSON):compliment_note,
    PARSE_JSON(USERSJSON):compliment_plain,
    PARSE_JSON(USERSJSON):compliment_cool,
    PARSE_JSON(USERSJSON):compliment_funny,
    PARSE_JSON(USERSJSON):compliment_writer,
    PARSE_JSON(USERSJSON):compliment_photos
FROM RESTAURANT_WEATHER.STAGING.YELP_USERS;

SELECT * 
FROM RESTAURANT_WEATHER.ODS.YELP_USERS
LIMIT 100;


// ----------------------------
// REVIEWS
SELECT *
FROM RESTAURANT_WEATHER.STAGING.YELP_REVIEWS
LIMIT 100;

CREATE OR REPLACE TABLE YELP_REVIEWS (
    review_id string,
    user_id string,
    business_id string,
    stars float,
    useful number,
    funny number,
    cool number,
    text string, 
    date timestamp_ntz,
    constraint pk_review_id primary key (review_id), 
    constraint fk_user_id foreign key (user_id) references YELP_USERS(user_id),
    constraint fk_business_id foreign key (business_id) references YELP_BUSINESSES(business_id)
);

INSERT INTO YELP_REVIEWS
SELECT
    PARSE_JSON(USERSJSON):review_id,
    PARSE_JSON(USERSJSON):user_id,
    PARSE_JSON(USERSJSON):business_id,
    PARSE_JSON(USERSJSON):stars,
    PARSE_JSON(USERSJSON):useful,
    PARSE_JSON(USERSJSON):funny,
    PARSE_JSON(USERSJSON):cool,
    PARSE_JSON(USERSJSON):text, 
    PARSE_JSON(USERSJSON):date
FROM RESTAURANT_WEATHER.STAGING.YELP_REVIEWS;

SELECT * 
FROM RESTAURANT_WEATHER.ODS.YELP_REVIEWS
LIMIT 1000;


// ----------------------------
// TIPS
SELECT *
FROM RESTAURANT_WEATHER.STAGING.YELP_TIPS
LIMIT 100;

CREATE OR REPLACE TABLE YELP_TIPS (
    user_id string,
    business_id string,
    text string,
    date timestamp_ntz,
    compliment_count number,
    constraint fk_user_id foreign key (user_id) references YELP_USERS(user_id),
    constraint fk_business_id foreign key (business_id) references YELP_BUSINESSES(business_id)
);

INSERT INTO YELP_TIPS
SELECT
    PARSE_JSON(USERSJSON):user_id,
    PARSE_JSON(USERSJSON):business_id,
    PARSE_JSON(USERSJSON):text,
    PARSE_JSON(USERSJSON):date,
    PARSE_JSON(USERSJSON):compliment_count
FROM RESTAURANT_WEATHER.STAGING.YELP_TIPS;

SELECT * 
FROM RESTAURANT_WEATHER.ODS.YELP_TIPS
LIMIT 100;

// ----------------------------
// COVID
SELECT *
FROM RESTAURANT_WEATHER.STAGING.YELP_COVID
LIMIT 5;

create or replace table YELP_COVID (
   business_id string,
   highlights string,
   "delivery_or_takeout" boolean,
   "Grubhub_enabled" boolean,
   "Call_To_Action_enabled" boolean,
   "Request_a_Quote_Enabled" boolean,
   "Covid_Banner" string,
   "Temporary_Closed_Until" string,
   "Virtual_Services_Offered" string,
   foreign key (business_id) references YELP_BUSINESSES(business_id)
);

INSERT INTO YELP_COVID
SELECT
    PARSE_JSON(USERSJSON):business_id,
    PARSE_JSON(USERSJSON):highlights,
    PARSE_JSON(USERSJSON):"delivery or takeout",
    PARSE_JSON(USERSJSON):"Grubhub enabled",
    PARSE_JSON(USERSJSON):"Call To Action enabled",
    PARSE_JSON(USERSJSON):"Request a Quote Enabled",
    PARSE_JSON(USERSJSON):"Covid Banner",
    PARSE_JSON(USERSJSON):"Temporary Closed Until",
    PARSE_JSON(USERSJSON):"Virtual Services Offered"
FROM RESTAURANT_WEATHER.STAGING.YELP_COVID;

SELECT * 
FROM RESTAURANT_WEATHER.ODS.YELP_COVID
LIMIT 100;

