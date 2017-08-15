<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Product Page</title>
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
				<%-- Import the java.sql package --%>
					<%@ page import="java.sql.*" %>
					<%@ page import="java.util.ArrayList" %>
					
					<%-- Open Connection Code --%>
					<%
						// Variable declarations and initializations
						ArrayList<String> categories = new ArrayList<String>();
					
						String currCat = "All Categories";
						if (request.getParameter("link") != null) {
							currCat = request.getParameter("link");
						}
						System.out.println("currCat: " + currCat);
						
						String currSearch = "";
						if (request.getParameter("search") != null) {
							currSearch = request.getParameter("search");
						}
						System.out.println("currSearch: " + currSearch);
	
						
					%>
					
					<%-- Statement Code --%>
					<%
						Class.forName("org.postgresql.Driver");
						Connection conn = DriverManager.getConnection(
							"jdbc:postgresql://localhost/CSE135", 
							"postgres", "igelkott");
						Statement stmt = conn.createStatement();
				
						// Use the statement to SELECT the categories
						// FROM the categories table.
						ResultSet rset = stmt.executeQuery("SELECT * FROM CATEGORY ORDER BY name;");
						ResultSet tset;
					%>
				
					<%-- Display categories links --%>
					<b>Product Menu</b>
					<ul>
						<%
							if (currSearch == null) {	
						%>
								<li><a href="product_page.jsp?link=All Categories">All Categories</a></li>
						<%
							} else {
						%>
								<li><a href="product_page.jsp?link=All Categories&search=<%=currSearch%>">All Categories</a></li>
						<%
							}
							while (rset.next()) {
								String cat = rset.getString("name").toString();
						
								if (currSearch == null) {
						%>
									<li><a href="product_page.jsp?link=<%=cat%>"><%= cat %></a></li>
						<%
								} else {
						%>
									<li><a href="product_page.jsp?link=<%=cat%>&search=<%=currSearch%>"><%= cat %></a></li>
						<%
								}
							}
						%>
						
						</ul>
						
						<%-- Search Form Code --%>
						<form action="Product" method="POST">
							<input type="hidden" name="action" value="search"/>
							<input type="hidden" name="link" value="<%=currCat %>"/>
							Enter product: 
							<%
								if (currSearch == null) {
							%>
									<input type="text" name="search" value=""/>
							<%
								} else {
							%>
									<input type="text" name="search" value="<%=currSearch%>"/>
							<%
								}
							%>
							<input type="submit" value="Search"/>
						</form> <p>
						
						<%-- Display Table --%>
						<table>
							<tr>
								<th>ID</th>
								<th>Name</th>
								<th>SKU</th>
								<th>Category</th>
								<th>List Price</th>
							</tr>
							
							<%-- Insert Form Code --%>
							<tr>
								<FORM ACTION="Product" METHOD="POST">
									<INPUT TYPE="HIDDEN" NAME="action" VALUE="insert"/>
									<input type="hidden" name="link" value="<%=currCat%>"/>
									<input type="hidden" name="search" value="<%=currSearch %>"/>
									<td>&nbsp;</td>
									<td><input value="" name="name" size="20"/></td>
									<td><input value="" name="sku" size="20"/></td>
									<td>
										<select name="category">
											<%  rset = stmt.executeQuery("SELECT * FROM CATEGORY ORDER BY name;");
												while (rset.next()) { 
													String cat = rset.getString("name").toString();
													categories.add(cat);
											%>
													<option value="<%= cat %>"><%= cat %></option>
											<% } %>
										</select>
									</td>
									<td><input value="" name="price" size="20"/></td>
									<td><input type="submit" value="Insert"/></td>
								</FORM>
							</tr>
							
							<%-- Iterate over the ResultSet --%>
							<% 
								String value = request.getParameter("link");
								rset = stmt.executeQuery("select * from product order by id;");
								if (value != null && !(value.equals("All Categories"))) {
									//System.out.println("GOT HERE");
									if (currSearch == null) {
										rset = stmt.executeQuery("select * from product where category='" + value + "' order by id;");
									} else {
										rset = stmt.executeQuery("select * from product where category='" + value + "' and name like '%" + currSearch + "%' order by id;");
									}
								} else {
									value = "All Categories";
									if (currSearch != null) {
										rset = stmt.executeQuery("select * from product where name like '%" + currSearch +"%' order by id;");
									}
								}
								System.out.println("VALUE: " + value);
								
								while (rset.next()) { 
							%>
								<tr>
									<%-- Update Form Code --%>
									<%
										String oldSku = rset.getString("sku");
									%>
									<form action="Product" method="POST">
										<input type="hidden" name="action" value="update"/>
										<input type="hidden" name="id" value="<%=rset.getInt("id") %>"/>
										<input type="hidden" name="link" value="<%=currCat %>"/>
										<input type="hidden" name="search" value="<%=currSearch %>"/>
										<input type="hidden" name="oldSku" value="<%=oldSku %>"/>
										<td><%= rset.getInt("id") %></td>
										<td><input value="<%=rset.getString("name")%>" name="name" size="20"/></td>
										<td><input value="<%=rset.getString("sku")%>" name="sku" size="20"/></td>
										<td>
											<select name="category">
											<%
												//if (value != null ) {
											%>
													<option value="<%=rset.getString("category") %>" selected="selected"><%=rset.getString("category") %></option>
											<%  
												//}
												for(int i = 0; i < categories.size(); i++) { 
													String cat = categories.get(i);
													if (!(cat.equals(rset.getString("category")))) {
											%>
														<option value="<%= cat %>"><%= cat %></option>
												<% } %>
											<% } %>
											</select>
										</td>									
										<td><input value="<%=rset.getString("price")%>" name="price" size="20"/></td>
										
										<%
											//String tempUser = "nick"; //rset.getString("owner").toString();
											//String user = session.getAttribute("username").toString();
											//if (tempUser.equals(user)) {
										%>
												<td><input type="submit" value="Update"></td>
										<% 
											//}
										%>
									</form>
									
									<%-- Delete Form Code --%>
									<form action="Product" method="post">
										<input type="hidden" name="action" value="delete"/>
										<input type="hidden" value="<%=rset.getInt("id") %>" name="id"/>
										<input type="hidden" name="link" value="<%=currCat %>"/>
										<input type="hidden" name="search" value="<%=currSearch %>"/>
										<input type="hidden" name="name" value="<%=rset.getString("name") %>"/>
										<input type="hidden" name="sku" value="<%=rset.getString("sku") %>"/>
										<%										
											//if (tempUser.equals(user)) {
										%>
												<td><input type="submit" value="Delete"/></td>
										<%
											//}
										%>
									</form>
								</tr>
							<% } %>
									
						</table>
						
						
						<%-- Close Connection Code --%>
						<%
							// Close the ResultSet
							rset.close();
							//tset.close();
						
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