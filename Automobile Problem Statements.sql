/*

-----------------------------------------------------------------------------------------------------------------------------------
													    Guidelines
-----------------------------------------------------------------------------------------------------------------------------------

The provided document is a guide for the project. Follow the instructions and take the necessary steps to finish
the project in the SQL file			

-----------------------------------------------------------------------------------------------------------------------------------
                                                         Queries                                            
-----------------------------------------------------------------------------------------------------------------------------------*/
  
/*-- QUESTIONS RELATED TO CUSTOMERS
     [Q1] What is the distribution of customers across states?
     
     Hint: For each state, count the number of customers.*/
	
	 #Ans 1	
		select 
			State, 
            count(*) as Customer_Count 
		from customer_t
		group by state
	  	order by state asc;

-- ---------------------------------------------------------------------------------------------------------------------------------

/*   [Q2] What is the average rating in each quarter?
--   Very Bad is 1, Bad is 2, Okay is 3, Good is 4, Very Good is 5.

Hint: Use a common table expression and in that CTE, assign numbers to the different customer ratings. 
      Now average the feedback for each quarter. */

	 #Ans 2	
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

/*   [Q3] Are customers getting more dissatisfied over time?

	Hint: Need the percentage of different types of customer feedback in each quarter. Use a common table expression and
		  determine the number of customer feedback in each category as well as the total number of customer feedback in each quarter.
		  Now use that common table expression to find out the percentage of different types of customer feedback in each quarter.
		  Eg: (total number of very good feedback/total customer feedback)* 100 gives you the percentage of very good feedback.*/
      
     #Ans 3
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

/*  [Q4] Which are the top 5 vehicle makers preferred by the customer.

    Hint: For each vehicle make what is the count of the customers.*/

	#Ans 4
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

/*  [Q5] What is the most preferred vehicle make in each state?

	Hint: Use the window function RANK() to rank based on the count of customers for each state and vehicle maker. 
	After ranking, take the vehicle maker whose rank is 1.*/

    #Ans 5
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

/*QUESTIONS RELATED TO REVENUE and ORDERS 

--  [Q6] What is the trend of number of orders by quarters?

    Hint: Count the number of orders for each quarter.*/

	#Ans 6
		select 
			quarter_number as Quarter_Number,
			count(quarter_number) as Order_Count
		from order_t
		group by quarter_number
		order by quarter_number;
        
-- ---------------------------------------------------------------------------------------------------------------------------------

/*   [Q7] What is the quarter over quarter % change in revenue?

	 Hint: Quarter over Quarter percentage change in revenue means what is the change in revenue from the subsequent quarter to the previous quarter in percentage.
		  To calculate you need to use the common table expression to find out the sum of revenue for each quarter.
		  Then use that CTE along with the LAG function to calculate the QoQ percentage change in revenue. */
      
	 #Ans 7
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

/*   [Q8] What is the trend of revenue and orders by quarters?

	 Hint: Find out the sum of revenue and count the number of orders for each quarter.*/

	 #Ans 8
		select 
			quarter_number as Quarter_Number,
			count(quarter_number) as Order_Count,
			sum(vehicle_price*quantity) as Revenue    
		from order_t
		group by Quarter_Number
		order by Quarter_Number;
        
-- ---------------------------------------------------------------------------------------------------------------------------------

/*  QUESTIONS RELATED TO SHIPPING 
     [Q9] What is the average discount offered for different types of credit cards?

	 Hint: Find out the average of discount for each credit card type.*/

	 #Ans 9
		select 
			c.credit_card_type as Credit_Card,
			round(avg(o.discount),2) as Avg_Discount
		from customer_t c
			inner join order_t o using (customer_id)
		group by Credit_Card
        order by Avg_Discount desc;

-- ---------------------------------------------------------------------------------------------------------------------------------

/*   [Q10] What is the average time taken to ship the placed orders for each quarters?
	 Hint: Use the dateiff function to find the difference between the ship date and the order date. */

     #Ans 10
		select 
			quarter_number as Quarter_number,
			round(avg(datediff(ship_date,order_date)),2) as Average_Shipping_Time
		from order_t
		group by quarter_number
		order by quarter_number;

-- --------------------------------------------------------Done----------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------------------------------------