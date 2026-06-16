-- =====================================================================
-- CONDITIONAL LOGIC - 50 DATA ENGINEER INTERVIEW QUESTIONS
-- Schema: Real_Sales (star schema) -- see Insert_script.sql for full DDL/data
-- Topics: CASE WHEN, nested CASE, simple CASE, IF, IFNULL, COALESCE, NULLIF,
--         conditional aggregation, business-rule mapping, category derivation,
--         status standardization, data-quality rules.
-- =====================================================================

USE Real_Sales;

-- ---- CASE / IF basics ----------------------------------------------
-- C1.  [B] Tag each product Budget(<200)/Standard(200-599.99)/Premium(>=600).
-- C2.  [B] Standardize gender: 'M'->Male, 'F'->Female, anything else->'Unknown'.
-- C3.  [B] Convert dim_date.is_weekend (1/0) into 'Weekend'/'Weekday' using IF().
-- C4.  [B] Map dim_date.quarter (1-4) to 'Q1 Jan-Mar' .. 'Q4 Oct-Dec' (simple CASE).
-- C5.  [B] Flag each sale HAS_DISCOUNT when discount>0 else NO_DISCOUNT.
-- C6.  [B] Flag high-value orders: total_amount>=3000 -> 'High' else 'Normal' (IF).
-- C7.  [B] Map brand: BrandA/BrandB->'Premium', else 'Standard' (simple CASE).
-- C8.  [B] Bucket quantity_sold: 1->'Single', 2-10->'Small', >10->'Bulk'.
-- C9.  [B] Label month number (dim_date.month) into season Winter/Spring/Summer/Fall.
-- C10. [B] Customer last-name initial bucket: A-M -> 'Group1', N-Z -> 'Group2'.

-- ---- NULL handling: IFNULL / COALESCE / NULLIF ---------------------
-- C11. [B] Defensive: guarantee numeric discount (IFNULL ->0) and net_unit_price.
-- C12. [I] NULLIF to compute discount as % of unit_price safe against zero price.
-- C13. [I] COALESCE a display location: first non-null of city, state, country.
-- C14. [I] Treat discount=0 as "no discount": NULLIF(discount,0) then label.
-- C15. [I] COALESCE chain to pick a contact label: phone, else email, else 'NO CONTACT'
--          (defensive pattern; data is fully populated here).

-- ---- Nested CASE / multi-condition rules ---------------------------
-- C16. [I] Tenure tier (nested): New/Growing/Loyal/Veteran + Gold/Silver VIP band.
-- C17. [I] Tiered shipping cost from total_amount: <500->50, 500-1500->25, else free.
-- C18. [A] Risk level (nested): combine over-discount and high amount into Low/Med/High.
-- C19. [A] Loyalty points: tiered rate on total_amount returning a NUMERIC value.
-- C20. [I] Discount band from discount_pct (nested + NULLIF): None/Low/Med/High.

-- ---- Category / status derivation ----------------------------------
-- C21. [I] Email provider segment from domain (simple CASE): Net/Org/Com/Other.
-- C22. [I] Product life stage from launch_date vs today: New/Established/Mature/Legacy.
-- C23. [I] Region super-group: North/East->'NE-Zone', South/West->'SW-Zone', else 'Central'.
-- C24. [I] Country known-list standardization: in a known set -> keep, else 'OTHER'.
-- C25. [I] Revenue bucket per sale: Micro/Small/Medium/Large; count + sum per bucket.
-- C26. [A] Customer value segment by lifetime revenue: Platinum/Gold/Silver/Bronze/None.
-- C27. [A] Lifecycle status (RFM-lite recency): Active/At-Risk/Dormant/Churned/Never.
-- C28. [A] Order-count tier per customer: Bronze(<3)/Silver(3-9)/Gold(10+).
-- C29. [I] Price-vs-category positioning: flag products priced above their category avg.
-- C30. [A] Product margin band: Healthy(<5%)/Watch(5-15%)/Eroded(>15%); incl. No-Sales.

-- ---- Conditional aggregation (manual pivots / cross-tabs) ----------
-- C31. [I] Pivot revenue per region into category columns (electronics/clothing/books).
-- C32. [I] Count weekend vs weekday sales per region (SUM(CASE...)).
-- C33. [I] Revenue split by gender per product category.
-- C34. [I] Per store: total revenue + revenue from discounted lines only.
-- C35. [A] Cross-tab: sales count by region (rows) x quarter (columns).
-- C36. [I] Total discount given on Electronics only (conditional SUM).
-- C37. [A] Per category: % of revenue coming from 'Bulk' (qty>10) orders.
-- C38. [A] Customer cohort matrix: count of New vs Returning order lines per month.

-- ---- Data-quality rules --------------------------------------------
-- C39. [I] Row DQ flag: discount>unit_price->OVER_DISCOUNT, total<=0->BAD_AMOUNT, else OK.
-- C40. [I] Invalid-record flag: quantity_sold<=0 OR unit_price<=0 OR discount<0.
-- C41. [A] dim_customer completeness scorecard (well-formed email/phone/join_date).
-- C42. [I] Email structural validity flag using CASE + LIKE '%@%.%'.
-- C43. [I] Phone validity class: VALID_10 / CHECK_INTL(11-15) / INVALID.
-- C44. [A] Future-dated join_date flag (join_date>CURDATE()) - data quality.
-- C45. [A] total_amount reconciliation: MATCH/ROUNDING/MISMATCH vs qty*(price-discount).
-- C46. [A] Referential check: fact rows whose product_key has unit_price mismatch w/ dim.

-- ---- Composite / production-style ----------------------------------
-- C47. [A] Build one composite status string per customer: tier|activity|risk (CONCAT of CASEs).
-- C48. [A] Per sale: derive a profitability_flag using nested CASE on net margin.
-- C49. [A] Price-band bucketing of products into 100-wide bands labeled with CASE.
-- C50. [A] Single "customer_360" SELECT: tier + lifecycle + value band + dq_flag together.
