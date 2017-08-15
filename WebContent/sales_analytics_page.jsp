<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Sale Analytics</title>
</head>
<body>
	<h3>Sales Analytics Table</h3>
	<%
		boolean hidden;
		boolean bHidden = false;
		boolean b1Hidden = false;
		int cust_state_inc;
		int product_inc;
		String cust_state;
		String order;
		String product_filter;
			
		if (request.getParameter("cust_state_pressed") != null || request.getParameter("product_pressed") != null)
			hidden = true;
		else
			hidden = false;
		
		if(request.getParameter("cust_state_inc") != null)
			if (request.getParameter("cust_state_pressed") != null)
				cust_state_inc = Integer.parseInt(request.getParameter("cust_state_inc")) + 20;
			else 
				cust_state_inc = Integer.parseInt(request.getParameter("cust_state_inc"));
		else
			cust_state_inc = 0;
		
		if (request.getParameter("product_inc") != null)
			if (request.getParameter("product_pressed") != null)
				product_inc = Integer.parseInt(request.getParameter("product_inc")) + 10;
			else
				product_inc = Integer.parseInt(request.getParameter("product_inc"));
		else
			product_inc = 0;
		
		
		System.out.println("product_inc: " + product_inc);
		
		if (request.getParameter("cust_state") != null)
			cust_state = request.getParameter("cust_state");
		else
			cust_state = "customer";
		
		if (request.getParameter("order") != null)
			order = request.getParameter("order");
		else
			order = "alphabetical";
		
		if (request.getParameter("product_filter") != null)
			product_filter = request.getParameter("product_filter");
		else
			product_filter = "All Categories";

		
		Connection conn = null;

		try {
			// Registering Postgressql JDBC driver
			Class.forName("org.postgresql.Driver");
			// Open a connection to the database
			conn = DriverManager.getConnection(
				"jdbc:postgresql://localhost/Project2", 
				"postgres", "igelkott");
			
			// Fills category drop box
			Statement stmt = conn.createStatement();
			Statement stmt1 = conn.createStatement();
			
			int pCount = 0;
			int csCount = 0;
			int cCount = 0;
			int sCount = 0;
			
			Statement csSize = conn.createStatement();
			Statement pSize = conn.createStatement();
			Statement cSize = conn.createStatement();
			if (!(product_filter.equals("All Categories"))) {
				PreparedStatement sSize = conn.prepareStatement("select count(*) as count from product p, category c where c.category_name=? and c.id=p.category_id");
				sSize.setString(1, product_filter);
				ResultSet sSet = sSize.executeQuery();
				while (sSet.next())
					sCount = sSet.getInt("count");
			}
			
			ResultSet csSet = csSize.executeQuery("select count(*) as count from person");
			ResultSet pSet = pSize.executeQuery("select count(*) as count from product");
			ResultSet cSet = cSize.executeQuery("select count(distinct p.state_id) as count from person p");
			
			while (csSet.next())
				csCount = csSet.getInt("count");
			
			while (pSet.next())
				pCount = pSet.getInt("count");
			
			while (cSet.next())
				cCount = cSet.getInt("count");
			
			System.out.println("PRODUCT SIZE: " + pCount);
			System.out.println("STATE SIZE: " + cCount);
			System.out.println("CUSTOMER SIZE: " + csCount);
			if (!hidden) {
		
	%>
	<form action="sales_analytics_page.jsp" method="get">
	
	
		<%-- Rows (customers/states) Dropdown --%>
	
	
		Rows: 
		<select name="cust_state">
			<%
				if (cust_state.toString().equals("state")) {
			%>
					<option selected="selected" value="state">State</option>
					<option value="customer">Customer</option>
			<%
				} else {	
			%>
					<option selected="selected" value="customer">Customer</option>
					<option value="state">State</option>	
			<%
				}
			%>
			
		</select> <p>
		
		
		<%-- Order (alphabetical/top-k Dropdown --%>
		
		
		Order:
		<select name="order">
			<%
				if (order.toString().equals("top-k")) {
			%>
					<option selected="selected" value="top-k">Top-k</option>
					<option value="alphabetical">Alphabetical</option>
			<%
				} else {
						
			%>
					<option selected="selected" value="alphabetical">Alphabetical</option>
					<option value="top-k">Top-k</option>	
			<%
				}
			%>
			
		</select> <p>
		
		
		<%-- Product Category Filter Dropdown --%>
		
		
		Product Category Filter:
		<%@ page import="java.sql.*" %>
		<%@ page import="java.util.ArrayList" %>
		<select name="product_filter">
			<%
				if (product_filter.toString().equals("All Categories")) {
			%>
					<option selected="selected" value="All Categories">All Categories</option>
			<%
				} else {
			%>
					<option value="All Categories">All Categories</option>
			<%
				}
			
					
					ResultSet rset = stmt.executeQuery("select category_name from category order by category_name asc;");
					while (rset.next()) {
						if (product_filter.toString().equals(rset.getString("category_name"))) {
			%>
							<option selected="selected" value="<%=rset.getString("category_name") %>"><%= rset.getString("category_name") %></option>		
			<%
						} else {
			%>
							<option value="<%=rset.getString("category_name") %>"><%= rset.getString("category_name") %></option>
			<%
						}
					} // while loop
			%>
		
		</select> <p>
		
		<input type="submit" value="Run Query"/> <p><p>
	</form> 
	
	<%
			}
	%>
	
	
	
	<%-- Table code --%>
	
	
	<table border=10 frame=box rules=all>
		<tr>
			<th>Customers</th>
			
			<%-- Creates the table header of product names --%>
			<%
				ArrayList<String> productHeader = new ArrayList<String>();
				ResultSet tset;
				if (order.equals("alphabetical")) {
					
					if (product_filter.toString().equals("All Categories")) { // alphabetical all categories of PRODUCTS
						
						if (cust_state.equals("customer")) { // alphabetical, all categories, customer
						
							PreparedStatement pstmt3 = conn.prepareStatement("select product_name, sum(pic.quantity * pic.price) as total " + 
													 "from product, shopping_cart sc, products_in_cart pic " + 
													 "where sc.id=pic.cart_id and pic.product_id=product.id " + 
													 "group by product_name " + 
												     "order by product_name asc " +
												     "limit 10 offset ?");
						
							pstmt3.setInt(1, product_inc);
							tset = pstmt3.executeQuery();
							
							System.out.println("1 ran");
							
						} else { // alphabetical, all categories, state
							
							tset = stmt.executeQuery("select product_name, sum(pic.quantity * pic.price) as total " + 
									 "from product, shopping_cart sc, products_in_cart pic, state s, person p " + 
									 "where sc.id=pic.cart_id and pic.product_id=product.id and p.state_id=s.id " + 
									 "group by product_name " + 
								     "order by product_name asc " +
								     "limit 10 offset " + product_inc);						}
						
					} else { // alphabetical and specific category of PRODUCTS selected
						
						if (cust_state.equals("customer")) { // alphabetical, specific category, customer
							
							PreparedStatement pstmt1 = conn.prepareStatement("select product_name, sum(pic.quantity * pic.price) as total " + 
																			 "from product, category c, shopping_cart sc, products_in_cart pic, person p " + 
																			 "where c.category_name=? and product.category_id=c.id and sc.id=pic.cart_id and pic.product_id=product.id and sc.is_purchased = true and sc.person_id=p.id " + 
																			 "group by product_name " + 
																			 "order by product_name asc " + 
																			 "limit 10 offset ?");
							pstmt1.setString(1, product_filter);
							pstmt1.setInt(2, product_inc);
							tset = pstmt1.executeQuery();
							System.out.println("2 ran");
							
						} else { // alphabetical, specific category, state
							
							PreparedStatement pstmt1 = conn.prepareStatement("select product_name, sum(pic.quantity * pic.price) as total " + 
									 "from product, category c, shopping_cart sc, products_in_cart pic, state s, person p " + 
									 "where c.category_name=? and category_id=c.id and sc.id=pic.cart_id and pic.product_id=product.id and s.id=p.state_id " + 
									 "group by product_name " + 
									 "order by product_name asc " + 
									 "limit 10 offset ?");
							
						pstmt1.setString(1, product_filter);
						pstmt1.setInt(2, product_inc);

							tset = pstmt1.executeQuery();
						}
						
					}
				} else { // Top-k ordering
					
					if (product_filter.toString().equals("All Categories")) { // Top-k and all categories of PRODUCTS
						
						if (cust_state.equals("customer")) { // top-k, all categories, customer
							
							PreparedStatement pstmt3 = conn.prepareStatement("select product_name, sum(pic.quantity * pic.price) as total " + 
													 "from product p, shopping_cart sc, products_in_cart pic " + 
													 "where sc.id=pic.cart_id and pic.product_id=p.id and sc.is_purchased=? " + 
													 "group by p.product_name " + 
													 "order by sum(pic.price * pic.quantity) desc " + 
													 "limit 10 offset ?");
						
							pstmt3.setBoolean(1, true);
							pstmt3.setInt(2, product_inc);
							tset = pstmt3.executeQuery();
							System.out.println("3 ran");
							
						} else { // top-k, all categories, state
							
							PreparedStatement pstmt3 = conn.prepareStatement("select product_name, sum(pic.quantity * pic.price) as total " + 
									 "from product p, shopping_cart sc, products_in_cart pic, state s, person pe " + 
									 "where sc.id=pic.cart_id and pic.product_id=p.id and sc.is_purchased=? and s.id=pe.state_id " + 
									 "group by p.product_name " + 
									 "order by sum(pic.price * pic.quantity) desc " + 
									 "limit 10 offset ?");
							pstmt3.setBoolean(1,true);
							pstmt3.setInt(2, product_inc);
							tset = pstmt3.executeQuery();
							
						}
					
					} else { // Top-k and specific categories of PRODUCTS selected
						
						if (cust_state.equals("customer")) { // top-k specific category, customer
							
							PreparedStatement pstmt3 = conn.prepareStatement("select product_name, sum(pic.quantity * pic.price) as total " +
																			 "from product p, shopping_cart sc, products_in_cart pic, category c " +
																			 "where sc.id=pic.cart_id and pic.product_id=p.id and sc.is_purchased=? and c.id=p.category_id and c.category_name=? " + 
																			 "group by p.product_name " + 
																			 "order by sum(pic.price * pic.quantity) desc " + 
																			 "limit 10 offset ?");
							pstmt3.setBoolean(1, true);
							pstmt3.setString(2, product_filter);
							pstmt3.setInt(3, product_inc);
							tset = pstmt3.executeQuery();
							System.out.println("4 ran");
							
						} else { // top-k, specific category, state
							
							PreparedStatement pstmt3 = conn.prepareStatement("select product_name, sum(pic.quantity * pic.price) as total " +
									 "from product p, shopping_cart sc, products_in_cart pic, category c, person pe, state s " +
									 "where sc.id=pic.cart_id and pic.product_id=p.id and sc.is_purchased=? and c.id=p.category_id and c.category_name=? and s.id=pe.state_id " + 
									 "group by p.product_name " + 
									 "order by sum(pic.price * pic.quantity) desc " + 
									 "limit 10 offset ?");
							
							pstmt3.setBoolean(1, true);
							pstmt3.setString(2, product_filter);
							pstmt3.setInt(3, product_inc);

							tset = pstmt3.executeQuery();
							
						}
						
					}

				}
				while (tset.next()) {
					productHeader.add(tset.getString("product_name"));
			%>
					<th><%= tset.getString("product_name") %> <br> <%="($" + tset.getString("total") + ")" %></th>
			<%
				} // while
			%>
		</tr>
		
		<%-- Populate table with price values of product per customer --%>
		<tr>
		<%
			ResultSet nameSet;
			String topK1 = "";
			String topK2 = "";
			
			if (cust_state.equals("customer")) { // customer selected
				
				if (order.equals("alphabetical")) { // query for customer and alphabetical selected
					
					if (product_filter.equals("All Categories")) { // customer, alphabetical, all categories
						
						topK1 = "select p.person_name, p.id, sum(pic.quantity * pic.price) as total " +
								"from person p, product pr, shopping_cart sc, products_in_cart pic " +
								"where sc.id=pic.cart_id and pic.product_id=pr.id and sc.is_purchased=true and p.id=sc.person_id " +
								"group by p.person_name, p.id " +
								"order by p.person_name asc";
							
						topK2 = "select pe.person_name, pe.id, 0 as total " +
								"from person pe " +
								"where pe.person_name not in " + 
									"(select p.person_name " +
									"from person p, shopping_cart sc, products_in_cart pic " +
									"where p.id=sc.person_id and pic.cart_id=sc.id and sc.is_purchased=true " +
									"group by p.person_name, p.id " + 
									"order by p.person_name asc)";
							
						nameSet = stmt1.executeQuery("select * from ((" + topK1 + ") union (" + topK2 + ")) as hey order by person_name asc limit 20 offset " + cust_state_inc);
					
					} else { // customer, alphabetical, specific category
						
						topK1 = "select p.person_name, p.id, sum(pic.quantity * pic.price) as total " +
								"from person p, product pr, shopping_cart sc, products_in_cart pic, category c " +
								"where sc.id=pic.cart_id and pic.product_id=pr.id and sc.is_purchased=true and p.id=sc.person_id and c.category_name='" + product_filter + "' and c.id=pr.category_id " +
								"group by p.person_name, p.id " +
								"order by p.person_name asc";
							
						topK2 = "select pe.person_name, pe.id, 0 as total " +
								"from person pe " +
								"where pe.person_name not in " + 
									"(select p.person_name " +
									"from person p, shopping_cart sc, products_in_cart pic " +
									"where p.id=sc.person_id and pic.cart_id=sc.id and sc.is_purchased=true " +
									"group by p.person_name, p.id " + 
									"order by p.person_name asc)";
							
						nameSet = stmt1.executeQuery("select * from ((" + topK1 + ") union (" + topK2 + ")) as hey order by person_name asc limit 20 offset " + cust_state_inc);
						
					}
						
				} else { // query for customer and top-k selected
					
					if (product_filter.equals("All Categories")) { // customer, top-k, all categories
						
						topK1 = "select p.person_name, p.id, sum(pic.price * pic.quantity) as total " +
								"from person p, shopping_cart sc, products_in_cart pic " +
								"where p.id=sc.person_id and pic.cart_id=sc.id and sc.is_purchased=true " +
								"group by p.person_name, p.id " + 
								"order by sum(pic.price * pic.quantity) desc";
							
						topK2 = "select pe.person_name, pe.id, 0 as total " + 
								"from person pe " + 
								"where pe.person_name not in " + 
									"(select p.person_name " +
									"from person p, shopping_cart sc, products_in_cart pic " + 
									"where p.id=sc.person_id and pic.cart_id=sc.id and sc.is_purchased=true " + 
									"group by p.person_name, p.id " + 
									"order by sum(pic.price * pic.quantity) desc)";
							
						nameSet = stmt1.executeQuery("select * from ((" + topK1 + ") union (" + topK2 + ")) as hey order by total desc limit 20 offset " + cust_state_inc);
					
					} else { // customer, top-k, specific category
						
						topK1 = "select p.person_name, p.id, sum(pic.price * pic.quantity) as total " +
								"from person p, shopping_cart sc, products_in_cart pic, category c, product pr " +
								"where p.id=sc.person_id and pic.cart_id=sc.id and pic.product_id=pr.id and sc.is_purchased=true and c.category_name='" + product_filter + "' and c.id=pr.category_id " +
								"group by p.person_name, p.id " + 
								"order by sum(pic.price * pic.quantity) desc";
							
						topK2 = "select pe.person_name, pe.id, 0 as total " + 
								"from person pe " + 
								"where pe.person_name not in " + 
									"(select p.person_name " +
									"from person p, shopping_cart sc, products_in_cart pic " + 
									"where p.id=sc.person_id and pic.cart_id=sc.id and sc.is_purchased=true " + 
									"group by p.person_name, p.id " + 
									"order by sum(pic.price * pic.quantity) desc)";
							
						nameSet = stmt1.executeQuery("select * from ((" + topK1 + ") union (" + topK2 + ")) as hey order by total desc limit 20 offset " + cust_state_inc);
						
					}
				}
			} else { // state selected
				
				if (order.equals("alphabetical")) { // query for state and alphabetical selected
					
					if (product_filter.equals("All Categories")) { // state, alphabetical, all categories
						
						topK1 = "select distinct s.state_code, sum(pic.quantity * pic.price) as total " + 
								"from person p, state s, shopping_cart sc, products_in_cart pic " + 
								"where p.state_id=s.id and p.id=sc.person_id and pic.cart_id=sc.id and sc.is_purchased=true " + 
								"group by s.state_code " + 
								"order by s.state_code asc";
							
						topK2 = "select distinct st.state_code, 0 as total " + 
								"from state st, person pe " + 
								"where st.id=pe.state_id and st.state_code not in " + 
									"(select s.state_code " + 
									"from state s, person p, shopping_cart sc, products_in_cart pic " + 
									"where p.state_id=s.id and p.id=sc.person_id and pic.cart_id=sc.id and sc.is_purchased=true " + 
									"group by s.state_code " + 
									"order by s.state_code asc)";
						nameSet = stmt1.executeQuery("select * from ((" + topK1 + ") union (" + topK2 + ")) as hey order by state_code asc limit 20 offset " + cust_state_inc);
					
					} else { // state, alphabetical, specific category
						
						topK1 = "select distinct s.state_code, sum(pic.quantity * pic.price) as total " + 
								"from person p, state s, shopping_cart sc, products_in_cart pic, category c, product pr " + 
								"where p.state_id=s.id and p.id=sc.person_id and pic.cart_id=sc.id and sc.is_purchased=true and pr.id=pic.product_id and c.id=pr.category_id and c.category_name='" + product_filter + "' " + 
								"group by s.state_code " + 
								"order by s.state_code asc";
							
						topK2 = "select distinct st.state_code, 0 as total " + 
								"from state st, person pe " + 
								"where st.id=pe.state_id and st.state_code not in " + 
									"(select s.state_code " + 
									"from state s, person p, shopping_cart sc, products_in_cart pic " + 
									"where p.state_id=s.id and p.id=sc.person_id and pic.cart_id=sc.id and sc.is_purchased=true " + 
									"group by s.state_code " + 
									"order by s.state_code asc)";
						nameSet = stmt1.executeQuery("select * from ((" + topK1 + ") union (" + topK2 + ")) as hey order by state_code asc limit 20 offset " + cust_state_inc);
					}

				} else { // query for state and top-k selected
					
					if (product_filter.equals("All Categories")) { // state, top-k, all categories
					
						topK1 = "select s.state_code, sum(pic.price * pic.quantity) as total " + 
								"from person p, state s, shopping_cart sc, products_in_cart pic " + 
								"where p.id=sc.person_id and pic.cart_id=sc.id and sc.is_purchased=true and s.id=p.state_id " + 
								"group by s.state_code " + 
								"order by sum(pic.price * pic.quantity) desc";
							
						topK2 = "select st.state_code, 0 as total " + 
								"from state st, person pe " + 
								"where st.id=pe.state_id and st.state_code not in " + 
									"(select s.state_code " +
									"from person p, state s, shopping_cart sc, products_in_cart pic " + 
									"where p.id=sc.person_id and pic.cart_id=sc.id and sc.is_purchased=true and s.id=p.state_id " + 
									"group by s.state_code " + 
									"order by sum(pic.price * pic.quantity) desc)";
							
						nameSet = stmt1.executeQuery("select * from ((" + topK1 + ") union (" + topK2 + ")) as hey order by total desc limit 20 offset " + cust_state_inc);
					
					} else { // state, top-k, specific category
						
						topK1 = "select s.state_code, sum(pic.price * pic.quantity) as total " + 
								"from person p, state s, shopping_cart sc, products_in_cart pic, category c, product pr " + 
								"where p.id=sc.person_id and pic.cart_id=sc.id and sc.is_purchased=true and s.id=p.state_id and pr.id=pic.product_id and c.id=pr.category_id and c.category_name='" + product_filter + "' " +  
								"group by s.state_code " + 
								"order by sum(pic.price * pic.quantity) desc";
							
						topK2 = "select st.state_code, 0 as total " + 
								"from state st, person pe " + 
								"where st.id=pe.state_id and st.state_code not in " + 
									"(select s.state_code " +
									"from person p, state s, shopping_cart sc, products_in_cart pic " + 
									"where p.id=sc.person_id and pic.cart_id=sc.id and sc.is_purchased=true and s.id=p.state_id " + 
									"group by s.state_code " + 
									"order by sum(pic.price * pic.quantity) desc)";
							
						nameSet = stmt1.executeQuery("select * from ((" + topK1 + ") union (" + topK2 + ")) as hey order by total desc limit 20 offset " + cust_state_inc);
						
					}
				}
			}
			while (nameSet.next()) {
				if (cust_state.equals("customer")) {
		%>
					<td><%= nameSet.getString("person_name") %> <br> <%="($" + nameSet.getString("total") + ")" %></td>		
		<%
				} else {
		%>
					<td><%= nameSet.getString("state_code") %> <br> <%="($" + nameSet.getString("total") + ")" %></td>
		<%
				}
		
				String sql1 = "";
				String sql2 = "";
				if (product_filter.equals("All Categories")) { // Show all categories
					
					if (cust_state.equals("customer")) { // show all categories and customers THIS QUERY
						
						if (order.equals("alphabetical")) { // alphabetical, all categories, customers
							
							sql1 = "select p.product_name as name, sum(pic.price * pic.quantity) as price " + 
									"from product p, shopping_cart sc, products_in_cart pic, person pe " + 
									"where sc.is_purchased=? and sc.person_id=pe.id and sc.id=pic.cart_id and pic.product_id=p.id and pe.id=? " + 
									"group by pic.product_id, p.product_name"; // limit 10 offset " + product_inc;
								
							sql2 = "select p.product_name as name, 0 as price " + 
									"from product p " + 
									"where p.product_name not in " + 
										"(select pr.product_name " + 
										"from product pr, shopping_cart sc, products_in_cart pic, person pe " + 
										"where sc.is_purchased=? and sc.person_id=pe.id and sc.id=pic.cart_id and pic.product_id=pr.id and pe.id=?)";// limit 10 offset " + product_inc + ")";
						
						} else { // top-k, all categories, customers THIS QUERY 1:46
							
							sql1 = "select p.product_name as name, sum(pic.price * pic.quantity) as price " + 
									"from product p, shopping_cart sc, products_in_cart pic, person pe " + 
									"where sc.is_purchased=? and sc.person_id=pe.id and sc.id=pic.cart_id and pic.product_id=p.id and pe.id=? " + 
									"group by pic.product_id, p.product_name " + 
									"order by sum(pic.price * pic.quantity) desc"; // limit 10 offset " + product_inc;
								
							sql2 = "select p.product_name as name, 0 as price " + 
									"from product p " + 
									"where p.product_name not in " + 
										"(select pr.product_name " + 
										"from product pr, shopping_cart sc, products_in_cart pic, person pe " + 
										"where sc.is_purchased=? and sc.person_id=pe.id and sc.id=pic.cart_id and pic.product_id=pr.id and pe.id=?)";// limit 10 offset " + product_inc + ")";
							
						System.out.println("YO!");
						}
					
					} else { // show all categories and states
						sql1 = "select p.product_name as name, sum(pic.price * pic.quantity) as price " + 
								"from product p, shopping_cart sc, products_in_cart pic, person pe, state s " + 
								"where sc.is_purchased=? and sc.person_id=pe.id and sc.id=pic.cart_id and pic.product_id=p.id and pe.state_id=s.id and s.state_code=? " + 
								"group by s.state_code, p.product_name";
							
						sql2 = "select p.product_name as name, 0 as price " + 
								"from product p where p.product_name not in " + 
									"(select pr.product_name " + 
									"from product pr, shopping_cart sc, products_in_cart pic, person pe, state s " + 
									"where sc.is_purchased=? and sc.person_id=pe.id and sc.id=pic.cart_id and pic.product_id=pr.id and pe.state_id=s.id and s.state_code=?)";
						
					}
				} else { // specific category is selected
					
					if (cust_state.equals("customer")) { // specific category and customers
						
						sql1 = "select p.product_name as name, sum(pic.price * pic.quantity) as price " + 
								"from category c, product p, shopping_cart sc, products_in_cart pic, person pe " + 
								"where sc.is_purchased=? and sc.person_id=pe.id and sc.id=pic.cart_id and pic.product_id=p.id and pe.id=? and c.category_name=? and c.id=p.category_id " + 
								"group by pic.product_id, p.product_name";
								
						sql2 = "select p.product_name as name, 0 as price " + 
								"from category c, product p " + 
								"where c.category_name=? and c.id=p.category_id and p.product_name not in " + 
									"(select pr.product_name " + 
									"from product pr, shopping_cart sc, products_in_cart pic, person pe " + 
									"where sc.is_purchased=? and sc.person_id=pe.id and sc.id=pic.cart_id and pic.product_id=pr.id and pe.id=? and c.category_name=?)";
				
					} else { // specific category and states
						sql1 = "select p.product_name as name, sum(pic.price * pic.quantity) as price " + 
								"from category c, product p, shopping_cart sc, products_in_cart pic, person pe, state s " + 
								"where sc.is_purchased=? and sc.person_id=pe.id and sc.id=pic.cart_id and pic.product_id=p.id and pe.state_id=s.id and s.state_code=? and c.category_name=? and c.id=p.category_id " + 
								"group by pic.product_id, p.product_name";
								
						sql2 = "select p.product_name as name, 0 as price " + 
								"from category c, product p " + 
								"where c.category_name=? and c.id=p.category_id and p.product_name not in " + 
									"(select pr.product_name " + 
									"from product pr, shopping_cart sc, products_in_cart pic, person pe, state s " + 
									"where sc.is_purchased=? and sc.person_id=pe.id and sc.id=pic.cart_id and pic.product_id=pr.id and pe.state_id=s.id and s.state_code=? and c.category_name=?)";	
					}
				}
				
				PreparedStatement pstmt2;
				
				if (order.equals("alphabetical")) {
					pstmt2 = conn.prepareStatement("select * from ((" + sql1 + ") UNION (" + sql2 + ")) as query order by name limit ? offset " + product_inc);
				} else
					pstmt2 = conn.prepareStatement("select * from ((" + sql1 + ") UNION (" + sql2 + ")) as query order by price desc limit ? offset " + product_inc);

				if (!(product_filter.equals("All Categories"))) { // All Categories
					
					pstmt2.setBoolean(1, true);
					
					if (cust_state.equals("customer")) {	// Customer, All Categories
						
						pstmt2.setInt(2, Integer.parseInt(nameSet.getString("id")));
						pstmt2.setInt(6,Integer.parseInt(nameSet.getString("id")));
						
					} else {	// State, All Categories
						
						pstmt2.setString(2, nameSet.getString("state_code"));
						pstmt2.setString(6, nameSet.getString("state_code"));
						
					} 
					
					pstmt2.setString(3, product_filter); // catgory name
					pstmt2.setString(4, product_filter); // catgory name
					pstmt2.setBoolean(5, true); // catgory name
					pstmt2.setString(7, product_filter);
					pstmt2.setInt(8, productHeader.size());
					
				} else { // Specific category
					
					pstmt2.setBoolean(1, true);
					
					if (cust_state.equals("customer")) { // Customer, specific category
						
						pstmt2.setInt(2, Integer.parseInt(nameSet.getString("id")));
						pstmt2.setInt(4,Integer.parseInt(nameSet.getString("id")));
						
					} else { // State, specific category
						
						pstmt2.setString(2, nameSet.getString("state_code"));
						pstmt2.setString(4, nameSet.getString("state_code"));
						
					} 
					
					pstmt2.setBoolean(3, true);
					pstmt2.setInt(5, productHeader.size());
				}
				ResultSet xSet = pstmt2.executeQuery();
				int i = 0;
				while (xSet.next()) {
					if (order.equals("alphabetical")){
		%>
						<td><%= xSet.getString("price") %></td>
		<%	
					} else { // top-k
						ResultSet zSet = null;
					
						if(cust_state.equals("customer")) { // top-k, customer
							
							if (product_filter.equals("All Categories")) { // top-k, customer, all categories
								
								PreparedStatement temp = conn.prepareStatement(
								"select p.product_name as name, sum(pic.quantity * pic.price) as price " + 
								"from product p, products_in_cart pic, shopping_cart sc, person pe " +
								"where p.product_name=? and sc.is_purchased=? and sc.person_id=pe.id and sc.id=pic.cart_id and pic.product_id=p.id and pe.id=? " +
								"group by p.product_name, pic.product_id " +
								"order by name");
								
								temp.setString(1, xSet.getString("name"));
								temp.setBoolean(2, true);
								temp.setInt(3, Integer.parseInt(nameSet.getString("id")));
				
								zSet = temp.executeQuery();
								
								System.out.println("productHeader: " + productHeader.get(i));
								
							} else { // top-k, customer, specific category
								PreparedStatement temp = conn.prepareStatement(
										"select p.product_name as name, sum(pic.quantity * pic.price) as price " + 
										"from product p, products_in_cart pic, shopping_cart sc, person pe, category c " +
										"where p.product_name=? and sc.is_purchased=? and sc.person_id=pe.id and sc.id=pic.cart_id and pic.product_id=p.id and pe.id=? and c.category_name=? and c.id=p.category_id " +
										"group by p.product_name, pic.product_id " +
										"order by name");
										
										temp.setString(1, xSet.getString("name"));
										temp.setBoolean(2, true);
										temp.setInt(3, Integer.parseInt(nameSet.getString("id")));
										temp.setString(4, product_filter);
						
										zSet = temp.executeQuery();
										
										System.out.println("productHeader: " + productHeader.get(i));
							}
						
						} else { // top-k, states
							
							if (product_filter.equals("All Categories")) { // top-k, states, all categories
								
								PreparedStatement temp = conn.prepareStatement(
										"select p.product_name as name, sum(pic.quantity * pic.price) as price " + 
										"from product p, products_in_cart pic, shopping_cart sc, person pe, state s " +
										"where p.product_name=? and sc.is_purchased=? and sc.person_id=pe.id and sc.id=pic.cart_id and pic.product_id=p.id and s.state_code=? and s.id=pe.state_id " +
										"group by p.product_name, pic.product_id " +
										"order by name");
										
										temp.setString(1, xSet.getString("name"));
										temp.setBoolean(2, true);
										temp.setString(3, nameSet.getString("state_code"));
						
										zSet = temp.executeQuery();
										
										System.out.println("productHeader: " + productHeader.get(i));
								
							} else { // top-k, states, specific category
								
								PreparedStatement temp = conn.prepareStatement(
										"select p.product_name as name, sum(pic.quantity * pic.price) as price " + 
										"from product p, products_in_cart pic, shopping_cart sc, person pe, state s, category c " +
										"where p.product_name=? and sc.is_purchased=? and sc.person_id=pe.id and sc.id=pic.cart_id and pic.product_id=p.id and s.state_code=? and s.id=pe.state_id and c.id=p.category_id and c.category_name=?" +
										"group by p.product_name, pic.product_id " +
										"order by name");
										
										temp.setString(1, xSet.getString("name"));
										temp.setBoolean(2, true);
										temp.setString(3, nameSet.getString("state_code"));
										temp.setString(4, product_filter);
						
										zSet = temp.executeQuery();
										
										System.out.println("productHeader: " + productHeader.get(i));
								
							}
						}
						int j = 0;
						boolean found = false;
						while (zSet.next()) {
							for (j = 0; j < productHeader.size(); j++) {
								System.out.println("HEADER: " + zSet.getString("name"));
								if (zSet.getString("name").equals(productHeader.get(j).toString())) {
								%>
									<td><%= zSet.getInt("price") %></td>
								<%
									found = true;
									break;
								} 
							}
							if (j == productHeader.size()) {
								%>
									<td>0</td>
								<%
							}
							
						} if (j < productHeader.size() && !found) {
							%>
								<td>0</td>
							<%
						}
						i++;
						if (i == productHeader.size())
							break;
						
						
					}
				}
				
		%>
				</tr>
		<%
			}
		%>
		
	</table> <p>
	
	<%
		if ((cust_state_inc + 20) >= csCount && cust_state.equals("customer"))
			bHidden = true;
	
		if ((cust_state_inc + 20) >= cCount && cust_state.equals("state"))
			bHidden = true; 
	
		if (!bHidden) {
	%>
	<form action="sales_analytics_page.jsp" method="get">
		<%
			if (cust_state.toString().equals("customer")) {
		%>
				<input type="submit" value="Next 20 customers"/>
		<%
			} else {
		%>
				<input type="submit" value="Next 20 states"/>
		<%
			}
		
		%>
		<input type="hidden" name="cust_state_inc" value="<%= cust_state_inc %>"/>
		<input type="hidden" name="product_inc" value="<%=product_inc%>"/>
		<input type="hidden" name="cust_state_pressed" value=true/>
		<input type="hidden" name="cust_state" value="<%=cust_state %>"/>
		<input type="hidden" name="order" value="<%= order %>"/>
		<input type="hidden" name="product_filter" value="<%= product_filter %>"/>
	</form>
	
	<%
			}
		if ((product_inc + 10) < pCount && product_filter.equals("All Categories"))
			b1Hidden = true;
		
		if ((product_inc + 10) < sCount && !(product_filter.equals("All Categories")))
		
		if (!b1Hidden) {
	%>
	
	<form action="sales_analytics_page.jsp" method="get">
		<input type="submit" value="Next 10 Products"/>
		<input type="hidden" name="product_inc" value="<%=product_inc%>"/>
		<input type="hidden" name="cust_state_inc" value="<%= cust_state_inc %>"/>
		<input type="hidden" name="product_pressed" value=true/>
		<input type="hidden" name="cust_state" value="<%=cust_state %>"/>
		<input type="hidden" name="order" value="<%= order %>"/>
		<input type="hidden" name="product_filter" value="<%= product_filter %>"/>
	</form>
	
	<%
		}
	%>
	
		<%
			} catch (Exception e) {
				throw new RuntimeException("There was a runtime problem!", e);
			
		 	} finally {
				try {
					if (conn != null)
						conn.close();
				} catch (SQLException e) {
					throw new RuntimeException("Cannot close the connection!", e);
				}
			}
		%>
</body>
</html>