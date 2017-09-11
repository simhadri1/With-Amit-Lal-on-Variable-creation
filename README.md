# Variable Creation from Transactional Data for Supervised Learning.
With-Amit-Lal-on-Variable-creation 


Authors: 
Satish Kumar Simhadri - Director Data Science - Rang Technologies Inc
Amit Lal – Senior SAS Programmer, Novartis 

Abstract: 
In supervised learning, creating independent and dependent variables is one of the basic steps before starting modeling work. Data scientists translate business question at hand, into a data mining problem to solve.  It is well known fact that the data comes from multiple forms. We combine multiple data sets to come up with a data sets for modeling. Based on how the data is available, we can divide it in to two. One: single record for customer. Example (Demographic data). Two: multiple records for customer (Transactional data). We convert the transactional data into to single record per customer and joined with demographic data to come up with set of independent variables. Transactional data has time component to it. We aggregate and create the independent variables from this data. There is some literature that talks about creating single record per customer. However, it has limited scope and more academic. This paper focuses on how how the real transactional data sets looks like, when you directly take it from database. How to convert that to create data sets for modeling. Finally provides SAS code that is easily be applied to any transactional data to come up with independent variables. 
Contents of document: ( yet to be written in detail) 
Performance window: 
Observation window: 
Picture for Performance window and observation window.
The independent variables are generated from observation window and dependent variable I created from performance window. 
Scope: 
-	We currently focus on creating independent variables for fixed observation window from transactional data set. 
-	Brief discussion on transactional data from banking industry. Then converting it to independent variables. 
-	Code in appendix to perform this activity. ( Macrotised to make it applicable for any industry ) 
Data Used as example: Bank transactional data is used as example to demonstrate. 
Application: This is directly useful across all industries, where we use transactional data to create independent variables. For Example: 
-	Point of Sale (POS) data in retail for each SKU.
-	Claims data in healthcare or general insurance.
-	Viewership data in media industry.
-	Bank Transactional data of customer’s usage of bank accounts or credit card.


- A sample data set and codes are provided. 
