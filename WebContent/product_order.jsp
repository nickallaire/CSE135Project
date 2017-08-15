<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Insert title here</title>
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
		<p>
		
		<%
			String name = "";
			String sku ="";
			String id = "";
			String category = "";
			String price = "";
			
			if (request.getAttribute("error") != null) {
				name = request.getAttribute("name").toString();
				sku = request.getAttribute("sku").toString();
				id = request.getAttribute("id").toString();
				category = request.getAttribute("category").toString();
				price = request.getAttribute("price").toString();
		%>
				<%= request.getAttribute("error") %> <p>
		<%
			} else {
				name = request.getParameter("name");
				sku = request.getParameter("sku");
				id = request.getParameter("id");
				category = request.getParameter("category");
				price = request.getParameter("price");
			}
		%>
		
		Current Shopping Cart: <p>
		<table>
			<tr>
				<th>&nbsp;</th>
				<th>ID</th>
				<th>Name</th>
				<th>SKU</th>
				<th>Category</th>
				<th>Price</th>
				<th>Amount</th>
			</tr>
		
			<%@ page import="java.sql.*" %>
			<%
				Class.forName("org.postgresql.Driver");
				Connection conn = DriverManager.getConnection(
					"jdbc:postgresql://localhost/CSE135", 
					"postgres", "igelkott");
				Statement stmt = conn.createStatement();
			
				// Use the statement to SELECT the categories
				// FROM the categories table.
				String username = session.getAttribute("username").toString();
				ResultSet rset = stmt.executeQuery("SELECT p.id, p.name, p.sku, p.category, p.price, c.quantity FROM Product p, Cart c where c.sku=p.sku and c.username='" + username + "' order by p.category;");
				while (rset.next()) {
			%>
					<tr>
						<td>&nbsp;</td>
						<td><%=rset.getString("id") %></td>
						<td><%=rset.getString("name") %></td>
						<td><%=rset.getString("sku") %></td>
						<td><%=rset.getString("category") %></td>
						<td><%=rset.getString("price") %></td>
						<td><%=rset.getString("quantity") %></td>
					</tr>
			<%
				}
			%>
		
		</table> <p> <p>
		
		
		Product Selected:
		<%
			PreparedStatement pstmt = conn.prepareStatement("select count(*) from product where sku=?;");
			pstmt.setString(1, request.getParameter("sku"));
			rset = pstmt.executeQuery();
			int count = -1;
			while (rset.next()) {
				count = rset.getInt(1);
			}
			if (count > 0) {
		%> 
				<table>
					<tr>
						<th>&nbsp;</th>
						<th>ID</th>
						<th>Name</th>
						<th>SKU</th>
						<th>Category</th>
						<th>Price</th>
						<th>Amount</th>
					</tr>
					
					<tr>
						<td>&nbsp;</td>
						<td><%=id %></td>
						<td><%=name %></td>
						<td><%=sku %></td>
						<td><%=category %></td>
						<td><%=price %></td>
						<form action="Order" method="post"/>
							<input type="hidden" name="sku" value="<%=request.getParameter("sku") %>"/>
							<input type="hidden" name="username" value="<%=session.getAttribute("username") %>"/>
							<input type="hidden" name="id" value="<%=request.getParameter("id") %>"/>
							<input type="hidden" name="name" value="<%=request.getParameter("name") %>"/>
							<input type="hidden" name="sku" value="<%=request.getParameter("sku") %>"/>
							<input type="hidden" name="category" value="<%=request.getParameter("category") %>"/>
							<input type="hidden" name="price" value="<%=request.getParameter("price") %>"/>
							
							<td><input type="text" name="quantity" value="1" /></td>
							<td><input type="submit" value="Add to cart"/></td>
						</form>
					</tr>
				</table>
		<%
			} else {
				
		%>
			<p>Something went wrong, product might've been deleted. Please go back.
		<%
			}
		%>
		
		<%
		}
		%>
</body>
</html>