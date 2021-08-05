USE DATABASE restaurant_weather;

// --------------------------------------------
// PRECIPITATION

create or replace file format my_csv_format
  type = csv
  field_delimiter = ','
  skip_header = 1
  null_if = ('NULL', 'null')
  empty_field_as_null = true
  compression = gzip;

show file formats;

// stage local cloud storage
create or replace stage precipitation file_format=my_csv_format;

// Run in snowsql local client
//put file:///Users/ericlok/Documents/workspace/Data-Architect-Data-Warehouse-Weather/USW00094728-NY_CITY_CENTRAL_PARK-precipitation-inch.csv @precipitation auto_compress=true;

list @precipitation;

select
metadata$filename,
metadata$file_row_number,
parse_json(t.$1), t.$1 from @precipitation
(file_format => my_csv_format) t;

// TEST
SELECT to_date($1, 'YYYYMMDD'), $2, $3
FROM @precipitation (file_format => 'my_csv_format');

create or replace table NYC_PRECIPITATION (
  date date,
  precipitation float,
  precipitation_normal float
);

copy into NYC_PRECIPITATION from (
  select to_date($1, 'YYYYMMDD'), $2, $3
  from @precipitation (file_format => 'my_csv_format')
);

SELECT *
FROM RESTAURANT_WEATHER.STAGING.NYC_PRECIPITATION
LIMIT 1000;

// --------------------------------------------
// TEMPERATURE

// stage local cloud storage
create or replace stage temperature file_format=my_csv_format;

//put file:///Users/ericlok/Documents/workspace/Data-Architect-Data-Warehouse-Weather/USW00094728-temperature-degreeF.csv @temperature auto_compress=true;

list @temperature;

// TEST
SELECT to_date($1, 'YYYYMMDD'), $2, $3, $4, $5
FROM @temperature (file_format => 'my_csv_format');

create or replace table NYC_TEMPERATURE (
  date date,
  min_value float,
  max_value float,
  normal_min float,
  normal_max float
);

copy into NYC_TEMPERATURE from (
  select to_date($1, 'YYYYMMDD'), $2, $3, $4, $5
  from @temperature (file_format => 'my_csv_format')
);

SELECT *
FROM RESTAURANT_WEATHER.STAGING.NYC_TEMPERATURE
LIMIT 1000;




// --------------------------------------------
// COVID

use schema staging;

show file formats;

create or replace file format myjsonformat type='JSON' strip_outer_array=true;

// stage local cloud storage
create or replace stage json_stage file_format=myjsonformat;

// create table
create table yelp_academic_dataset_covid_features (usersjson variant);

// snowsql
//put file:///Users/ericlok/Documents/workspace/Data-Architect-Data-Warehouse-Weather/covid_19_dataset_2020_06_10/yelp_academic_dataset_covid_features.json @json_stage auto_compress=true;

copy into YELP_COVID 
from @json_stage/yelp_academic_dataset_covid_features.json.gz 
file_format = (format_name = myjsonformat) on_error = 'skip_file';

select *
from "RESTAURANT_WEATHER"."STAGING"."YELP_COVID";

// --------------------------------------------

list @json_stage;

select *
from @json_stage
LIMIT 100;

// --------------------------------------------
// BUSINESS

// create table
create table yelp_businesses (usersjson variant);

// snowsql
//put file:///Users/ericlok/Documents/workspace/Data-Architect-Data-Warehouse-Weather/yelp_dataset/yelp_academic_dataset_business.json @json_stage auto_compress=true;

copy into YELP_BUSINESSES 
from @json_stage/yelp_academic_dataset_business.json.gz 
file_format = (format_name = myjsonformat) on_error = 'skip_file';

select *
from "RESTAURANT_WEATHER"."STAGING"."YELP_BUSINESSES";

// --------------------------------------------
// CHECKIN

// create table
create table YELP_CHECKINS (usersjson variant);
create table YELP_TIPS (usersjson variant);
create table YELP_USERS (usersjson variant);
create table YELP_REVIEWS (usersjson variant);

// snowsql
//put file:///Users/ericlok/Documents/workspace/Data-Architect-Data-Warehouse-Weather/yelp_dataset/yelp_academic_dataset_checkin.json @json_stage auto_compress=true;
//put file:///Users/ericlok/Documents/workspace/Data-Architect-Data-Warehouse-Weather/yelp_dataset/yelp_academic_dataset_tip.json @json_stage auto_compress=true;
//put file:///Users/ericlok/Documents/workspace/Data-Architect-Data-Warehouse-Weather/yelp_dataset/yelp_academic_dataset_user.json @json_stage auto_compress=true;
//put file:///Users/ericlok/Documents/workspace/Data-Architect-Data-Warehouse-Weather/yelp_dataset/yelp_academic_dataset_review.json @json_stage auto_compress=true;

copy into YELP_CHECKINS
from @json_stage/yelp_academic_dataset_checkin.json.gz 
file_format = (format_name = myjsonformat) on_error = 'skip_file';

copy into YELP_TIPS
from @json_stage/yelp_academic_dataset_tip.json.gz 
file_format = (format_name = myjsonformat) on_error = 'skip_file';

copy into YELP_USERS
from @json_stage/yelp_academic_dataset_user.json.gz 
file_format = (format_name = myjsonformat) on_error = 'skip_file';

copy into YELP_REVIEWS
from @json_stage/yelp_academic_dataset_review.json.gz 
file_format = (format_name = myjsonformat) on_error = 'skip_file';

SELECT *
FROM "RESTAURANT_WEATHER"."STAGING"."YELP_CHECKINS";
SELECT *
FROM "RESTAURANT_WEATHER"."STAGING"."YELP_TIPS";
SELECT *
FROM "RESTAURANT_WEATHER"."STAGING"."YELP_USERS";
SELECT *
FROM "RESTAURANT_WEATHER"."STAGING"."YELP_REVIEWS"
LIMIT 100;



