CREATE TABLE graph_data (
    point1 TEXT,
    point2 TEXT,
    cost INT,
    PRIMARY KEY (point1, point2)
);

INSERT INTO graph_data VALUES
    ('a', 'd', 20),
    ('a', 'b', 10),
    ('a', 'c', 15),
    ('b', 'a', 10),
    ('b', 'd', 25),
    ('b', 'c', 35),
    ('c', 'a', 15),
    ('c', 'd', 30),
    ('c', 'b', 35),
    ('d', 'a', 20),
    ('d', 'b', 25),
    ('d', 'c', 30);

WITH RECURSIVE tours (tour, total_cost, remaining_nodes) AS (
    SELECT 'a'::TEXT, 0::INT, ARRAY['b', 'c', 'd']::TEXT[]
    UNION ALL
    SELECT tour || ',' || gd.point2, total_cost + gd.cost, array_remove(remaining_nodes, gd.point2)
    FROM tours
    JOIN graph_data gd ON split_part(tour, ',', length(tour) - length(replace(tour, ',', '')) + 1) = gd.point1
    WHERE NOT gd.point2 = ANY(string_to_array(tour, ','))
      AND gd.point2 = ANY(remaining_nodes)
),
final_tours AS (
    SELECT '{' || tour || ',a}' AS tour, total_cost + (SELECT cost FROM graph_data WHERE point1 = split_part(tour, ',', 1) AND point2 = split_part(tour, ',', length(tour) - length(replace(tour, ',', '')) + 1)) AS total_cost
    FROM tours
    WHERE remaining_nodes = '{}'
)
SELECT total_cost, tour
FROM final_tours
WHERE total_cost = (SELECT MIN(total_cost) FROM final_tours) OR total_cost = (SELECT MAX(total_cost) FROM final_tours)
ORDER BY total_cost, tour;