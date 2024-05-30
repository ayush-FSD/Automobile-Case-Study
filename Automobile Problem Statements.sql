/*-- CUSTOMERS QUERIES:-
     The distribution of customers across states.
*/
	
		
		select 
			State, 
            count(*) as Customer_Count 
		from customer_t
		group by state
	  	order by state asc;

-- ---------------------------------------------------------------------------------------------------------------------------------

/*   The average rating in each quarter rated as following:-
--   Very Bad is 1, Bad is 2, Okay is 3, Good is 4, Very Good is 5.
 */

		
		with CTE1
			as (select quarter_number,
				round(avg(case 
						when customer_feedback = 'Very Bad' 
							then 1
						when customer_feedback = 'Bad' 
							then 2
						when customer_feedback = 'Very Okay' 
							then 3
						when customer_feedback = 'Good' 
							then 4
						when customer_feedback = 'Very Good' 
							then 5
						end),2) as Avg_Ratings
				from order_t
				group by quarter_number)
		select 
			Quarter_Number, 
            Avg_Ratings
		from CTE1
		group by quarter_number
		order by quarter_number;

-- ---------------------------------------------------------------------------------------------------------------------------------

/*   Are customers getting more dissatisfied over time or not.

*/
      
   
		with CTE1
			as (select 
					quarter_number, 
                    count(customer_feedback) as Total_Feedback
				from order_t
				group by quarter_number
				order by quarter_number
				),
			 CTE2 
		    as (select 
					customer_feedback,
                    count(customer_feedback) as Feedback_Count, 
                    quarter_number
				from order_t
				group by customer_feedback, quarter_number
				order by quarter_number
				)
		select 
			CTE1.quarter_number as Quarter_Number,
			CTE2.customer_feedback as Feedback,
			CTE2.Feedback_Count,
			round((CTE2.Feedback_Count/CTE1.Total_Feedback)*100,0) as Feedback_Percentage
		from CTE1
		inner join CTE2
			where CTE1.quarter_number = CTE2.quarter_number
		order by Quarter_Number;
	
-- ---------------------------------------------------------------------------------------------------------------------------------

/*  The top 5 vehicle makers preferred by the customer.

 */

	
		select 
			p.vehicle_maker as Vehicle_Make,
			count(o.customer_id) as Total_Customer_Count
		from order_t o
        	inner join product_t p
				on p.product_id=o.product_id
		group by Vehicle_Make
		order by Total_Customer_Count desc
        limit 10;
		
-- ---------------------------------------------------------------------------------------------------------------------------------

/*  The most preferred vehicle make in each state.
*/

 
		select 
			State,
			Vehicle_Maker,
			Customer_Count
		from 
			(select 
				c.state as State,
				p.vehicle_maker as Vehicle_Maker,
				count(c.customer_id) as Customer_Count,
				rank() 
					over(partition by state order by count(c.customer_id) desc) as Ranks
			 from customer_t c
				inner join order_t o
					on o.customer_id = c.customer_id
				inner join product_t p
					on o.product_id = p.product_id
			 group by c.state,p.vehicle_maker
			 ) as Table1
		where Ranks = 1;

-- ---------------------------------------------------------------------------------------------------------------------------------

/* QUERY RELATED TO REVENUE and ORDERS 

--  The trend of number of orders by quarters.
*/

	
		select 
			quarter_number as Quarter_Number,
			count(quarter_number) as Order_Count
		from order_t
		group by quarter_number
		order by quarter_number;
        
-- ---------------------------------------------------------------------------------------------------------------------------------

/*   The quarter over quarter % change in revenue.
*/
      
	
		with CTE as
			(
			select 
				quarter_number as Quarter_Number,
				sum(vehicle_price*quantity) as Quarter_Revenue,
				lag(sum(vehicle_price*quantity)) OVER(order by quarter_number) as Previous_Quarter_revenue
			from order_t
			group by quarter_number
			)
		select 
			Quarter_Number,
			Quarter_Revenue,    
			round(((Quarter_Revenue-Previous_Quarter_Revenue)/Previous_Quarter_Revenue)*100,2) as QoQ
		from CTE;

-- ---------------------------------------------------------------------------------------------------------------------------------

/*   The trend of revenue and orders by quarters.
*/

	
		select 
			quarter_number as Quarter_Number,
			count(quarter_number) as Order_Count,
			sum(vehicle_price*quantity) as Revenue    
		from order_t
		group by Quarter_Number
		order by Quarter_Number;
        
-- ---------------------------------------------------------------------------------------------------------------------------------

/*  QUERY RELATED TO SHIPPING 
     The average discount offered for different types of credit cards?
*/

	 
		select 
			c.credit_card_type as Credit_Card,
			round(avg(o.discount),2) as Avg_Discount
		from customer_t c
			inner join order_t o using (customer_id)
		group by Credit_Card
        order by Avg_Discount desc;

-- ---------------------------------------------------------------------------------------------------------------------------------

/*   The average time taken to ship the placed orders for each quarters?
*/

     
		select 
			quarter_number as Quarter_number,
			round(avg(datediff(ship_date,order_date)),2) as Average_Shipping_Time
		from order_t
		group by quarter_number
		order by quarter_number;

-- --------------------------------------------------------Done----------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------------------------------------