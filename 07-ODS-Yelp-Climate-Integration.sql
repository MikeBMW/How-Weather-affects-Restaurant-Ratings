USE DATABASE RESTAURANT_WEATHER;


SELECT *
FROM RESTAURANT_WEATHER.ODS.PRECIPITATION p
LIMIT 1000;


SELECT
    cast(date_trunc('DAY', date) as date) as date,
    business_id,
    avg(stars) as avg_stars,
    count(*) as num_reviews
FROM RESTAURANT_WEATHER.ODS.YELP_REVIEWS
GROUP BY date, business_id
ORDER BY date, business_id;


//--------------------------------------
// INTEGRATION

SELECT r.date, r.business_id, b.name, (t.min+t.max)/2 as average_temperature, p.precipitation, r.avg_stars as average_stars, r.num_reviews as review_count
FROM
    (SELECT
        cast(date_trunc('DAY', date) as date) as date,
        business_id,
        avg(stars) as avg_stars,
        count(*) as num_reviews
    FROM RESTAURANT_WEATHER.ODS.YELP_REVIEWS
    GROUP BY date, business_id
    ORDER BY date, business_id) AS r
JOIN RESTAURANT_WEATHER.ODS.PRECIPITATION p ON r.date = p.date
JOIN RESTAURANT_WEATHER.ODS.TEMPERATURE t ON r.date = t.date
JOIN RESTAURANT_WEATHER.ODS.YELP_BUSINESSES b ON r.business_id = b.business_id
AND p.precipitation != 999 -- filter out bad precipitation values
ORDER BY r.date;




