# CSE 135: Online Database Analytics Applications Project

Project Overview: Create a shopping application using Java/JSP with a PostgreSQL database and Tomcat server, complete with error handling and data validation

	Project 1: Created an online shopping application with the ability to have buyers and sellers. Sellers are able to add items they want to sell and put each item up a category or create a new category. Buyers can only browse and purchase items sold by sellers, and sellers can also be buyers. Buyers can search by category and by product name. Once a user has added items to their cart, they can then checkout and supply payment info. 

	Project 2: Created a sales analytics page for sellers to view and understand purchasing habits of the customers. The user can view sales by customers or sales by U.S. states, and can also order the data by alphabetical or Top-k. Further they can limit what they see by specifying a specific category. Finally there is a similar products page that calculates the cosine similarity and displays the 100 product pairs that have the highest normalized cosine similarities.

	Project 3: Similar to the similar products page in Project 2 but offers a refresh button that uses AJAX to display new values for cells that have changed since the last refresh and color them red. The rows and columns order will only change when the Run button is pressed, which doesn't use AJAX but instead reruns the query to gather the new data. 

A complete description of the assignment can be found in project.pdf
