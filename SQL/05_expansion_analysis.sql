SELECT 
    t.ticket_type_name,
    ROUND(AVG(v.spend_cents_clean / NULLIF(v.party_size, 0)) / 100.0, 2) AS avg_spend_per_person_dollars
FROM fact_visits v
JOIN dim_ticket t 
    ON v.ticket_type_id = t.ticket_type_id
GROUP BY t.ticket_type_name
ORDER BY avg_spend_per_person_dollars DESC;

/*
I added a new analysis to better understand guest value by calculating average spend 
per person across different ticket types. Instead of just looking at total spend, 
I adjusted for party size to get a more accurate view of individual spending behavior. 
The results showed that Day Pass guests spend the most per person on average, 
followed by VIP, with Family Pack guests spending significantly less per person. 
This suggests that while group-based tickets may drive higher overall attendance, 
individual spend tends to be lower, which could impact how pricing or promotions 
are structured depending on the goal.
*/

/* Now I'm going to improve the repeat guest segmentation */
WITH visit_counts AS (
    SELECT 
        guest_id,
        COUNT(*) AS total_visits
    FROM fact_visits
    GROUP BY guest_id
)

SELECT 
    guest_id,
    total_visits,
    CASE 
        WHEN total_visits = 1 THEN 'one_time'
        WHEN total_visits BETWEEN 2 AND 3 THEN 'occasional'
        ELSE 'frequent'
    END AS guest_segment
FROM visit_counts;




WITH visit_counts AS (
    SELECT 
        guest_id,
        COUNT(*) AS total_visits
    FROM fact_visits
    GROUP BY guest_id
),
guest_segments AS (
    SELECT 
        guest_id,
        CASE 
            WHEN total_visits = 1 THEN 'one_time'
            WHEN total_visits BETWEEN 2 AND 3 THEN 'occasional'
            ELSE 'frequent'
        END AS segment
    FROM visit_counts
)

SELECT 
    gs.segment,
    ROUND(AVG(v.spend_cents_clean / NULLIF(v.party_size, 0)) / 100.0, 2) AS avg_spend_per_person
FROM fact_visits v
JOIN guest_segments gs 
    ON v.guest_id = gs.guest_id
GROUP BY gs.segment
ORDER BY avg_spend_per_person DESC;


