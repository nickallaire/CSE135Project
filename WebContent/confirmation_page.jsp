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
		Purchased Shopping Cart: <p>
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
		<p><a href="product_browsing.jsp" onclick="<% stmt.executeUpdate("delete from cart where username='" + session.getAttribute("username") + "';"); %>">Go back to browse</a>
	<%
		}
	%>
</body>
</html>