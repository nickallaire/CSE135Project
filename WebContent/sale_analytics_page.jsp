<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Sale Analytics</title>
</head>
<body>
	<%
		String cust_state;
		String order;
		String product_filter;
		
		if (request.getParameter("cust_state") != null)
			cust_state = request.getParameter("cust_state");
		else
			cust_state = "customer";
		
		if (request.getParameter("order") != null)
			order = request.getParameter("order");
		else
			order = "alphabetical";
		
		if (request.getParameter("product_filter") != null)
			cust_state = request.getParameter("product_filter");
		else
			cust_state = "All Categories";
		
		
	%>
	<form action="sale_analytics_page.jsp" method="get">
		Rows: 
		<select name="cust_state">
			<option value="customer">Customer</option>
			<option value="state">State</option>
		</select> <p>
		
		Order:
		<select name="order">
			<option value="alphabetical">Alphabetical</option>
			<option value="top-k">Top-k</option>
		</select> <p>
		
		Product Category Filter:
		<%@ page import="java.sql.*" %>
		<select name="product_filter">
			<option value="All Categories">All Categories</option>
			<%
				Connection conn = null;
				try {
					// Registering Postgressql JDBC driver
					Class.forName("org.postgresql.Driver");
					// Open a connection to the database
					conn = DriverManager.getConnection(
						"jdbc:postgresql://localhost/CSE135", 
						"postgres", "igelkott");
					
					Statement stmt = conn.createStatement();
					ResultSet rset = stmt.executeQuery("select name from category order by name asc;");
					while (rset.next()) {
			%>
			<option value="<%=rset.getString("name") %>"><%= rset.getString("name") %></option>
			
			<%
					} // while loop
			%>
		
		</select> <p>
		
		<input type="submit" value="Run Query"/> <p>
	</form> 
	
	<table border=10 frame=box rules=all>
		<tr>
			<th>Customers</th>
			<%
				ResultSet tset;
				if (order.equals("alphabetical"))
					tset = stmt.executeQuery("select name from product order by name asc limit 20");
				else
					tset = stmt.executeQuery("select name from product order by name asc limit 20");
				
				while (tset.next()) {
			%>
			<th><%= tset.getString("name") %></th>
			<%
				} // while
			%>
		</tr>
		
		<%
			ResultSet xSet = stmt.executeQuery("select sum(p.price) from product p");
		%>
	</table> <p>
	
	<form action="" method="">
		<input type="submit" value="Next 20"/>
		<input type="submit" value="Next 20 Products"/>
	</form>
	
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