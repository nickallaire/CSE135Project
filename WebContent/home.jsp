<HTML>
	<HEAD>
		<TITLE>Home Page</TITLE>
	</HEAD>
	<BODY>
		<%
			String username = "";
			String role = "";
			String age = "";
			String state = "";
			
			if (request.getAttribute("login") != null) {
				username = request.getAttribute("username").toString();
				role = request.getAttribute("role").toString();
				age = request.getAttribute("age").toString();
				state = request.getAttribute("state").toString();
				session.setAttribute("username", username);
				session.setAttribute("role", role);
				session.setAttribute("age", age);
				session.setAttribute("state", state);
			}
				
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
			Welcome, <%= request.getAttribute("username").toString() %>! <p>
			
			<%
				
			%>
			
			<b>Different Options</b>
			
			<%
				if (role.compareTo("owner") == 0) {
					
			%>
					<ul>
						<li><a href="category_page.jsp">Categories Page</a></li> 
						<li><a href="product_page.jsp">Products Page</a></li> 
						<li><a href="product_browsing.jsp">Product Browsing Page</a></li> 
						<li><a href="shopping_cart.jsp">Buy Shopping Cart</a></li> 
					</ul>	
			<%
				} else {
			%>
			
					<ul>
						<li><a href="product_browsing.jsp">Product Browsing Page</a></li> 
						<li><a href="shopping_cart.jsp">Buy Shopping Cart</a></li> 
					</ul>
			
			<%
				}
			%>
		<%
			}
		%>
			
			
	</BODY>
</HTML>