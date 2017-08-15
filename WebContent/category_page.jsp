<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Categories Page</title>
</head>
<body>
		<%
			if (session.getAttribute("username") == null) {				
		%>
			No user currently logged in. <p>
			<form action="login.jsp" name="invalid">
				<input type="submit" value="Go to Login Page"/>
			</form> 
			<form action="index.jsp" name="invalid">
				<input type="submit" value="Go to Signup Page"/>
			</form>
		<%		
			} else {
		%>
			Welcome, <%= session.getAttribute("username") %>! <p>
			
			<%
				if (request.getAttribute("error") != null) {
			%>
					<%= request.getAttribute("error") %><p>
			<%
				} else if (request.getAttribute("success") != null) {
			%>
					<%=request.getAttribute("success")%> <p>
			<%	
				}
			
				String role = session.getAttribute("role").toString();
				if (role.compareTo("customer") == 0) {
					
			%>
					<p>This page is available to owners only. </p>
			<%
				} else {
			%>
			<b>Links to other pages</b>
				<ul>
					<li><a href="category_page.jsp">Categories Page</a></li> 
					<li><a href="product_page.jsp">Products Page</a></li> 
					<li><a href="product_browsing.jsp">Product Browsing Page</a></li> 
					<li><a href="shopping_cart.jsp">Buy Shopping Cart</a></li> 
				
				</ul>		
			
				<b>Category Menu</b>
							
					<%-- Import the java.sql package --%>
					<%@ page import="java.sql.*" %>
					<%@ page import="java.util.ArrayList" %>
					
					<%-- Presentation Code --%>
					<table>
						<tr>
							<th>ID</th>
							<th>Name</th>
							<th>Description</th>
							<th>Owner</th>
						</tr>
						
						<%-- Insert Form Code --%>
						<tr>
							<FORM ACTION="Category" METHOD="POST">
								<INPUT TYPE="HIDDEN" NAME="action" VALUE="insert"/>
								<input type="hidden" name="username" value="<%= session.getAttribute("username")%>"/>
								<td>&nbsp;</td>
								<td><input value="" name="name" size="20"/></td>
								<td><input value="" name="description" size="40"/></td>
								<td><%= session.getAttribute("username") %></td>
								<td><input type="submit" value="Insert"/></td>
							</FORM>
						</tr>
						<%
							Class.forName("org.postgresql.Driver");
							Connection conn = DriverManager.getConnection(
								"jdbc:postgresql://localhost/CSE135", 
								"postgres", "igelkott");
							Statement stmt = conn.createStatement();
							
							// Use the statement to SELECT the categories
							// FROM the categories table.
							ResultSet rset = stmt.executeQuery("SELECT * FROM CATEGORY ORDER BY id;");
						%>
						<%-- Iterate over the ResultSet --%>
						<% while (rset.next()) { %>
							<tr>
								<%-- Update Form Code --%>
								<form action="Category" method="POST">
									<input type="hidden" name="action" value="update"/>
									<input type="hidden" name="id" value="<%=rset.getInt("id") %>"/>
									<input type="hidden" name="oldCategory" value="<%=rset.getString("name") %>"/>
									<td><%= rset.getInt("id") %></td>
									<td><input value="<%=rset.getString("name")%>" name="name" size="20"/></td>
									<td><input value="<%=rset.getString("description")%>" name="description" size="40"/></td>
									<td><%=rset.getString("owner")%></td>
									<%
										String tempUser = rset.getString("owner").toString();
										String user = session.getAttribute("username").toString();
										if (tempUser.equals(user)) {
									%>
											<td><input type="submit" value="Update"></td>
									<% 
										}
									%>
								</form>
								
								<%-- Delete Form Code --%>
								<form action="Category" method="POST">
									<input type="hidden" name="action" value="delete"/>
									<input type="hidden" value="<%=rset.getInt("id") %>" name="id"/>
									<input type="hidden" value="<%=rset.getString("name") %>" name="name"/>
									<input type="hidden" value="<%=rset.getString("description") %>" name="description"/>
									<%
										Statement check = conn.createStatement();
										String cat = rset.getString("name");
										
										int count = -1;
										ResultSet tset = check.executeQuery("select count(*) from product where category=\'" + cat + "\';");
										
										try {
											if (tset != null) {
												while (tset.next()) {
													count = tset.getInt(1);
												}
											}
											
											if (count == 0) {
												if (tempUser.equals(user)) {
									%>
													<td><input type="submit" value="Delete"/></td>
									<%
												}
											}
										} catch (Exception e) {
											System.out.println("Error: " + e.getMessage());
										}
									%>
								</form>
							</tr>
						<% } %>
						
					</table>
					
					<%-- Close Connection Code --%>
					<%
						// Close the ResultSet
						rset.close();
					
						// Close the Statement
						stmt.close();
						
						// Close the Connection
						conn.close();
					%>
			<%
				} 
			%>
			
		<%
		}
		%>		
</body>
</html>