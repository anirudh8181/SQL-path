-- Question 1: How would you categorize customers as either "Northeast" or "Other" if the states New York and New Hampshire are the primary focus?

-- Question 2: Based on the phone column, how can we distinguish between international contacts (starting with '00') and local ones?

-- Question 3: If a customer joined before 2022, they are "Legacy"; otherwise, they are "New." How is this written using the join_date?

-- Question 4: For the stores, label those in the 'North' or 'South' regions as "Vertical Axis" and all others as "Central/Misc."

-- Question 5: How would you flag customers using 'example.net' as "Internal Test" vs "External" in the dim_customer table?

-- Question 6: Using the unit_price, classify products over 500.00 as "High-End" and those below as "Standard."

-- Question 7: How do you label 'Clothing' and 'Electronics' as "Technical/Wearable" and everything else as "General Inventory"?

-- Question 8: If the brand is 'BrandA' or 'BrandB', it is "Premium Brand"; otherwise, it is "Third Party." Use the dim_product table.

-- Question 9: In the fact_sales table, identify transactions where quantity_sold is greater than 5 as "Bulk Order."

-- Question 10: How would you flag a sale as "Deep Discount" if the discount is greater than 40.00?

-- Question 11: Categorize sales based on total_amount: over 5000 is "Enterprise," 1000-5000 is "Mid-Market," and under 1000 is "Consumer."

-- Question 12: Create a column that shows 'Yes' if a discount was applied and 'No' if it was 0.

-- Question 13: Using dim_date, label sales in 'October', 'November', and 'December' as "Q4 Peak" and others as "Off-Peak."

-- Question 14: If a sale occurs on a weekend (is_weekend = 1), label it "Premium Window," otherwise "Standard Window."

-- Question 15: Group the quarters so that Quarters 1 and 2 are "First Half" and 3 and 4 are "Second Half."