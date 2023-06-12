
create view orderitems as select * from production.orderitems; 
create view orders as select * from production.orders; 
create view orderstatuses as select * from production.orderstatuses; 
create view orderstatuslog as select * from production.orderstatuslog; 
create view products as select * from production.products; 
create view users as select * from production.users; 

 

create table analysis.dm_rfm_segments ( 
id int4 NOT NULL, 
recency int4 NOT NULL, 
frequency int4 NOT NULL, 
monetary_value int4 NOT NULL, 
CONSTRAINT dm_rfm_segments_pkey PRIMARY KEY (id),  
CONSTRAINT recency_check CHECK (6 > recency and recency > 0), 
CONSTRAINT frequency_check CHECK (5 >= frequency and frequency >= 1), 
CONSTRAINT monetary_check CHECK (5 >= monetary_value and monetary_value>= 1) 
); 


insert into analysis.dm_rfm_segments 
SELECT u.id AS user_id 
      ,ntile(5) over (order by max(order_ts) nulls first) as recency 
      ,ntile(5) over (order by count(o.order_id) nulls first) as frequency  
      ,ntile(5) over (order by sum(payment) nulls first) AS monetary_value 
FROM analysis.users u 
LEFT JOIN analysis.orders o ON o.user_id = u.id   
                           AND o.order_ts >= '2021-01-01'  
                           AND o.status = 4 
GROUP BY 1



--Доработка представления по причине обновления структуры данных
create or replace view orders as 
select po.order_id, po.order_ts, po.user_id, po.bonus_payment, po.payment, po.cost, po.bonus_grant, t2.status_id 
from production.orders po 
join  (select t1.order_id, t1.status_id from
        (select o.order_id, o.status_id, o.dttm, rank() over (partition by o.order_id order by o.dttm desc) as rn 
        from production.orderstatuslog o) t1 where rn = 1 ) t2 
on po.order_id = t2.order_id;
