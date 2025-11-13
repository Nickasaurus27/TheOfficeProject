# The Office – SQL Data Exploration

This project uses SQL to explore data from one of my favourite sitcoms, *The Office*.  
Using episode-level metadata and IMDb ratings, I answer questions like:

- How many episodes and seasons are there, and how are they distributed?
- Which writers and directors contributed the most, and how did their episodes perform?
- Which seasons were highest rated, and which episodes over- or under-performed their season?

---

## 📂 Project Overview

**Goal:** Showcase practical SQL skills (joins, window functions, text manipulation, CTEs, views, CASE logic) through a fun exploratory analysis of *The Office*.

**Key skills demonstrated:**

- Data cleaning and schema design  
- Aggregations and grouping  
- String manipulation to handle multi-writer episodes  
- Window functions to compare episodes to season averages  
- CTEs and views to organize reusable logic  
- Simple classification logic (bucketing directors by performance)

---

## 🧾 Data

The project uses two tables:

1. `the_office_episodes`  
   - `season` (SMALLINT)  
   - `episode_num_in_season` (SMALLINT)  
   - `episode_num_overall` (SMALLINT)  
   - `title` (VARCHAR)  
   - `directed_by` (VARCHAR)  
   - `written_by` (VARCHAR)  
   - `original_air_date` (DATE)  
   - `prod_code` (INT)  
   - `us_viewers` (NUMERIC → converted to BIGINT)

2. `the_office_imdb`  
   - `season` (SMALLINT)  
   - `episode_number` (SMALLINT)  
   - `title` (VARCHAR)  
   - `original_air_date` (DATE)  
   - `imdb_rating` (NUMERIC)  
   - `total_votes` (INT)  
   - `description` (VARCHAR)

> Note: as part of cleaning, `us_viewers` values are rounded and cast from `NUMERIC` to `BIGINT` for easier analysis.

1. **Clone the repo**

   ```bash
   git clone https://github.com/<your-username>/the-office-sql-project.git
   cd the-office-sql-project
