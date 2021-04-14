SELECT fl.flight_id,
       ap1.city depature_city,
       ap2.city arrival_city,
       fl.actual_departure depature_date,
       (EXTRACT(HOUR FROM (fl.scheduled_arrival - fl.scheduled_departure)) +
        EXTRACT(MINUTE FROM (fl.scheduled_arrival - fl.scheduled_departure)) / 60) AS flight_time,
       ac.model aircraft_model,
       s.count_seats aircraft_seats,
       tf.count_ticket ticket_sold,
       tf.ticket_prices ticket_amount
FROM dst_project.flights fl
JOIN dst_project.aircrafts ac ON fl.aircraft_code = ac.aircraft_code
JOIN dst_project.airports ap1 ON fl.departure_airport = ap1.airport_code
JOIN dst_project.airports ap2 ON fl.arrival_airport = ap2.airport_code
LEFT JOIN
    (SELECT flight_id,
            sum(amount) ticket_prices,
            count(tf.ticket_no) count_ticket
     FROM dst_project.ticket_flights tf
     GROUP BY 1) tf ON fl.flight_id = tf.flight_id
LEFT JOIN
    (SELECT ac.model,
            count(s.seat_no) count_seats
     FROM dst_project.aircrafts ac
     JOIN dst_project.seats s ON ac.aircraft_code = s.aircraft_code
     GROUP BY 1) s ON ac.model = s.model
WHERE fl.departure_airport = 'AAQ'
    AND (date_trunc('month', fl.scheduled_departure) in ('2017-01-01',
                                                         '2017-02-01',
                                                         '2017-12-01'))
    AND fl.status not in ('Cancelled')
ORDER BY 4,
         3;