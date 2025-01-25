WITH Time_Differences AS (
    SELECT
        g.grubhub_slug,
        CONCAT(g.open_time, ' - ', g.close_time) AS grubhub_business_hours,
        u.uber_eats_slug,
        CONCAT(u.open_time, ' - ', u.close_time) AS uber_eats_business_hours,
        TIME_TO_SEC(TIMEDIFF(g.open_time, u.open_time)) / 60 AS open_diff_minutes,
        TIME_TO_SEC(TIMEDIFF(g.close_time, u.close_time)) / 60 AS close_diff_minutes
    FROM
        Grubhub_Hours g
    JOIN
        UberEats_Hours u
    ON
        g.restaurant_id = u.restaurant_id
        AND g.day_of_week = u.day_of_week
),
Mismatch_Categories AS (
    SELECT
        grubhub_slug,
        grubhub_business_hours,
        uber_eats_slug,
        uber_eats_business_hours,
        open_diff_minutes,
        close_diff_minutes,
        -- Define mismatch categories
        CASE
            WHEN open_diff_minutes BETWEEN 0 AND 5 AND close_diff_minutes BETWEEN 0 AND 5 THEN 'In Range'
            WHEN (open_diff_minutes > 5 OR open_diff_minutes < -5) OR (close_diff_minutes > 5 OR close_diff_minutes < -5) THEN 'Out of Range'
            ELSE 'Out of Range with 5 mins difference between GH and UE'
        END AS is_out_of_range
    FROM
        Time_Differences
)
-- Final query 
SELECT
    grubhub_slug AS "Grubhub slug",
    grubhub_business_hours AS "Virtual Restaurant Business Hours",
    uber_eats_slug AS "Uber Eats slug",
    uber_eats_business_hours AS "Uber Eats Business Hours",
    is_out_of_range AS "is_out_range"
FROM
    Mismatch_Categories;
