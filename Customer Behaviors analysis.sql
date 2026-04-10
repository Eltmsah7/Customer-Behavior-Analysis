-- Q1: what is the total revenue genrated by male Vs female Customers 
select gender , sum(purchase_amount) as [ Total revenue]
from raw_customer_data
group by gender	

-- Q2: which customer use the discount but still spent more than the average purchase amount ?
select customer_id ,purchase_amount 
from raw_customer_data
where discount_applied ='Yes' and
	purchase_amount >= (select AVG(purchase_amount) from raw_customer_data)

-- Q3: Top 5 products with the highest average review rating?

select top 5 item_purchased , round(Avg(review_rating) , 2) as AVG_Rating
from raw_customer_data
group by item_purchased
order by AVG_Rating desc

-- Q4: Compare average Purchase Amounts between Standard and Express Shipping

select shipping_type , round(avg(purchase_amount) ,2) as AVG_Purchase
from raw_customer_data
where shipping_type in ('Standard' ,'Express')
group by shipping_type
order by AVG_Purchase desc 

-- Q5: Do subscribed customers spend more? (Average spend & Total revenue)
select subscription_status , 
COUNT(customer_id) as 'Total Customers ',
ROUND(AVG(purchase_amount) , 2) as 'AVG Spend' ,
Sum(purchase_amount)  as 'Total Revenue'
from raw_customer_data
group by subscription_status
order by [Total Revenue] , [AVG Spend] desc

-- Q6: Which 5 products have the highest percentage of purchases with discounts applied?

select top 5 item_purchased ,
round(sum(case when discount_applied = 'Yes' then 1 else 0 end)* 100 / count(*),2)  as Discount_persentage
from raw_customer_data 
group by item_purchased
order by Discount_persentage desc 

-- Q7: Segment customers into New, Returning, and Loyal based on previous purchases.

select 
case 
    when previous_purchases <=3 then 'New'
    when previous_purchases between 4 and 15 then 'Retuining'
    else 'Loyal'
end as customer_segment ,
count(customer_id) AS Total_customer 
from raw_customer_data
group by case 
    when previous_purchases <=3 then 'New'
    when previous_purchases between 4 and 15 then 'Retuining'
    else 'Loyal'
end



-- another way
with Customer_type as (
select customer_id , previous_purchases ,
case 
    when previous_purchases <= 3 then 'New'
    when previous_purchases between 4 and 15 then 'Returned'
    else 'Loyal'
end as [Customer_Segmentation]
from raw_customer_data
)
select 
Customer_Segmentation ,
COUNT(Customer_Segmentation) as [number of customer]
from Customer_type 
group by Customer_Segmentation


-- Q8: Top 3 most purchased products within each category?

with item_counts as (
    select category ,
    item_purchased ,
    count(customer_id) AS  Total_orders ,
    ROW_NUMBER() over(PARTITION by category order by count(customer_id) desc) as item_rank
    from raw_customer_data
    group by category , item_purchased
)
select
    item_rank,
    category ,
    item_purchased,
    Total_orders 
from item_counts
where item_rank <=3

-- Q9: Are repeat buyers (more than 5 previous purchases) also likely to subscribe?

select subscription_status ,
count(customer_id) as Customer_count
from raw_customer_data
where previous_purchases > 5
group by subscription_status

-- Q10: What is the revenue contribution of each age group?
select age_group , sum(purchase_amount) as [Total Purchase amount]
from raw_customer_data
group by age_group
order by [Total Purchase amount] desc
