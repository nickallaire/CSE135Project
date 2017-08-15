<HTML>
	<HEAD>
		<TITLE>Login Page</TITLE>
	</HEAD>
	<BODY>
		Welcome to the page that allows a returning user to login!
		<p>
		<form method="post" action="Login">
			Login with text box below: <p>
			User name: 
			<INPUT TYPE="TEXT" NAME="name"/> <p>
			
			<INPUT TYPE="SUBMIT" VALUE="Login"/>
		</FORM>
		<form action="index.jsp" name="invalid">
				<input type="submit" value="Go to Signup Page"/>
			</form>
		
		<%
			boolean failure = false;
			String username = null;
			if (request.getAttribute("failure") != null) {
				failure = (boolean) request.getAttribute("failure");
			}
			
			if (request.getAttribute("username") != null) {
				username = request.getAttribute("username").toString();
			}
			
			if (failure) {
		%>
				The user name <%= username %> does not exist. Please enter a valid login!
		<%
			}
		%>
	</BODY>
</HTML>