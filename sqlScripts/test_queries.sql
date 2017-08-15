// Create temp_table
create table temp_table(
    id serial primary key,
    state_name text not null,
    product_name text not null,
    cell_sum integer not null,
    product_sum integer not null,
    state_sum integer not null);

// Create log
create table log(
    id serial primary key,
    person_id integer not null,
	product_id integer not null,
	price integer not null,
	quantity integer not null);

// Find top 52 products
select p.product_name, sum(pic.quantity * pic.price) as cell_sum
from product p, products_in_cart pic, shopping_cart sc
where p.id=pic.product_id and sc.is_purchased=true and sc.id=pic.cart_id
group by p.product_name
order by sum(pic.quantity * pic.price) desc
limit 52


// Find kicked out value 
(select tt.product_name
from temp_table tt)

except

(select p.product_name
from product p, products_in_cart pic, shopping_cart sc
where p.id=pic.product_id and sc.is_purchased=true and sc.id=pic.cart_id
group by p.product_name
order by sum(pic.quantity * pic.price) desc
limit 50)



// Find new value
(select p.product_name
from product p, products_in_cart pic, shopping_cart sc
where p.id=pic.product_id and sc.is_purchased=true and sc.id=pic.cart_id
group by p.product_name
order by sum(pic.quantity * pic.price) desc
limit 50)

except

(select tt.product_name
from temp_table tt)



// Create temp_table
with overall_table as 
(select pc.product_id,c.state_id,sum(pc.price*pc.quantity) as amount  
 	from products_in_cart pc  
 	inner join shopping_cart sc on (sc.id = pc.cart_id and sc.is_purchased = true)
 	inner join product p on (pc.product_id = p.id) -- add category filter if any
 	inner join person c on (sc.person_id = c.id)
 	group by pc.product_id,c.state_id
),
top_state as
(select state_id, sum(amount) as dollar from (
	select state_id, amount from overall_table
	UNION ALL
	select id as state_id, 0.0 as amount from state
	) as state_union
 group by state_id order by dollar desc limit 50
),
top_n_state as 
(select row_number() over(order by dollar desc) as state_order, state_id, dollar from top_state
),
top_prod as 
(select product_id, sum(amount) as dollar from (
	select product_id, amount from overall_table
	UNION ALL
	select id as product_id, 0.0 as amount from product
	) as product_union
group by product_id order by dollar desc limit 50
),
top_n_prod as 
(select row_number() over(order by dollar desc) as product_order, product_id, dollar from top_prod
)
select ts.state_id, s.state_name, tp.product_id, pr.product_name, COALESCE(ot.amount, 0.0) as cell_sum, ts.dollar as state_sum, tp.dollar as product_sum
	from top_n_prod tp CROSS JOIN top_n_state ts 
	LEFT OUTER JOIN overall_table ot 
	ON ( tp.product_id = ot.product_id and ts.state_id = ot.state_id)
	inner join state s ON ts.state_id = s.id
	inner join product pr ON tp.product_id = pr.id
	order by ts.state_order, tp.product_order


