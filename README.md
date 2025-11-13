# The Office – SQL Analytics Project

This project uses SQL to explore one of my favourite sitcoms, *The Office*.  
Starting from two raw CSVs (episodes + IMDb data), I:

- Design and create database tables
- Clean and standardize key fields
- Build views and use window functions / CTEs
- Answer analytical questions about episodes, writers, seasons, and directors

> **Tech stack:** PostgreSQL (or compatible SQL), window functions, CTEs, views

---

## Project Overview

The goal of this project is to **showcase practical SQL skills** using a fun, real dataset:

- **Data modeling & ingestion** – creating tables and loading CSVs into a relational schema  
- **Data cleaning** – handling numeric precision, fixing inconsistent text fields  
- **Analytical querying** – aggregates, window functions, CTEs, string functions, and views  
- **Storytelling** – answering concrete questions about *The Office* and its episodes

I focus on questions like:

- How many episodes are there overall and per season?  
- Which writers contributed the most to the show?  
- How do episode ratings compare to their season’s average?  
- Which seasons are the highest-rated?  
- Which directors tend to get the best ratings and viewership?

---

## Data Sources

The project uses two CSV files:

- `the_office_imdb.csv`  
  - Season and episode number  
  - Title  
  - Original air date  
  - IMDb rating  
  - Total votes  
  - Description

- `the_office_episodes.csv`  
  - Season  
  - Episode number in season and overall  
  - Title  
  - Directed by / written by  
  - Original air date  
  - Production code  
  - U.S. viewers (in millions)

These are loaded into two tables: `the_office_imdb` and `the_office_episodes`. :contentReference[oaicite:1]{index=1}  

---

## Schema & Data Loading

The database layer starts with explicit table definitions:

- `the_office_imdb`  
  - `season`, `episode_number`, `title`, `original_air_date`, `imdb_rating`, `total_votes`, `description`
- `the_office_episodes`  
  - `season`, `episode_num_in_season`, `episode_num_overall`, `title`, `directed_by`, `written_by`, `original_air_date`, `prod_code`, `us_viewers`

Example DDL (simplified):

```sql
CREATE TABLE IF NOT EXISTS the_office_imdb (
    season SMALLINT,
    episode_number SMALLINT,
    title VARCHAR(100),
    original_air_date DATE,
    imdb_rating NUMERIC,
    total_votes INT,
    description VARCHAR(500)
);

CREATE TABLE IF NOT EXISTS the_office_episodes (
    season SMALLINT,
    episode_num_in_season SMALLINT,
    episode_num_overall SMALLINT, 
    title VARCHAR(50), 
    directed_by VARCHAR(50),
    written_by VARCHAR(100),
    original_air_date DATE,
    prod_code INT,
    us_viewers NUMERIC
);
