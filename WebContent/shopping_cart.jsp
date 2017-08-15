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
			if (request.getAttribute("error") != null) {
		%>
				<%=request.getAttribute("error") %> <p>
			
		<%
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
				int totalPrice = 0;
				Class.forName("org.postgresql.Driver");
				Connection conn = DriverManager.getConnection(
					"jdbc:postgresql://localhost/CSE135", 
					"postgres", "igelkott");
				Statement stmt = conn.createStatement();
			
				// Use the statement to SELECT the categories
				// FROM the categories table.
				String username = session.getAttribute("username").toString();
				ResultSet rset = stmt.executeQuery("SELECT p.id, p.name, p.sku, p.category, p.price, c.quantity, c.id FROM Product p, Cart c where c.sku=p.sku and c.username='" + username +"' order by p.category;");
				String cart_id = "";
				System.out.println("cart: " + cart_id);
				int numInCart = 0;
				while (rset.next()) {
					cart_id = rset.getString("id");
					totalPrice += Integer.parseInt(rset.getString("price")) * Integer.parseInt(rset.getString("quantity"));
					numInCart++;
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
		Total price of shopping cart: $<%= totalPrice %><p>
		
		<%
			if (numInCart > 0) {
		%>
				Credit card: 
				<form action="Confirmation" method="post">
					<input type="text" name="credit_card" value=""/>
					<input type="hidden" name="username" value="<%=session.getAttribute("username") %>"/>
					
					<input type="submit" name="Purchase"/>
				</form>
		<%
			}
		%>
		
		<%
		}
		%>
	
</body>
</html>