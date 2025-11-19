This project analyzes subscription churn using weekly retention cohorts. I use data from the turing_data_analytics.subscriptions table in BigQuery to group users by the week they started their subscription and track how many remain active over the next 6 weeks.

The analysis is done with SQL (BigQuery) to calculate retention from week 0 to week 6, and the results are exported to Google Sheets to build a retention heatmap. 

The goal is to help the Product Manager see early churn signals faster than with monthly reports, understand where retention drops the most and provide actionable recommendations to improve user retention and reduce churn.

The dataset: https://console.cloud.google.com/bigquery?ws=!1m5!1m4!4m3!1stc-da-1!2sturing_data_analytics!3ssubscriptions&pli=1

The overview sheet: https://docs.google.com/spreadsheets/d/1OFf9tgDITyM5Sf7QpRduKiv5BPWPlUYE4L2O-ilFbvE/edit?gid=658609489#gid=658609489
