<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Insert title here</title>
</head>
<BODY>
		<%
			session.setAttribute("username", null);
			session.setAttribute("role", null);
			session.setAttribute("age", null);
			session.setAttribute("state", null);
		%>
		
		Welcome to the page that allows a new user to sign up!
		<p>
		<form name="signup" action="SignUp" method="post">
			Sign up for an account below: <p>
			User name: 
			<INPUT TYPE="TEXT" NAME="name"/> <p>
			Role: 
			<SELECT NAME="role">
				<OPTION value="customer">customer</OPTION>
				<OPTION value="owner">owner</OPTION>
			</SELECT> <p>
			Age: 
			<INPUT TYPE="TEXT" NAME="age"/> <p>
			US State: 
			<SELECT NAME="state">
				<OPTION value="Alabama">AL</OPTION>
				<OPTION value="Alaska">AK</OPTION>
				<OPTION value="Arizona">AZ</OPTION>
				<OPTION value="Arkansas">AR</OPTION>
				<OPTION value="California">CA</OPTION>
				<OPTION value="Colorado">CO</OPTION>
				<OPTION value="Connecticut">CT</OPTION>
				<OPTION value="Delaware">DE</OPTION>
				<OPTION value="District of Columbia">DC</OPTION>
				<OPTION value="Florida">FL</OPTION>
				<OPTION value="Georgia">GA</OPTION>
				<OPTION value="Hawaii">HI</OPTION>
				<OPTION value="Idaho">ID</OPTION>
				<OPTION value="Illinois">IL</OPTION>
				<OPTION value="Indiana">IN</OPTION>
				<OPTION value="Iowa">IA</OPTION>
				<OPTION value="Kansas">KS</OPTION>
				<OPTION value="Kentucky">KY</OPTION>
				<OPTION value="Louisiana">LA</OPTION>
				<OPTION value="Maine">ME</OPTION>
				<OPTION value="Maryland">MD</OPTION>
				<OPTION value="Massachusetts">MA</OPTION>
				<OPTION value="Michigan">MI</OPTION>
				<OPTION value="Minnesota">MN</OPTION>
				<OPTION value="Mississippi">MS</OPTION>
				<OPTION value="Missouri">MO</OPTION>
				<OPTION value="Montana">MT</OPTION>
				<OPTION value="Nebraska">NE</OPTION>
				<OPTION value="Nevada">NV</OPTION>
				<OPTION value="New Hampshire">NH</OPTION>
				<OPTION value="New Jersey">NJ</OPTION>
				<OPTION value="New Mexico">NM</OPTION>
				<OPTION value="New York">NY</OPTION>
				<OPTION value="North Carolina">NC</OPTION>
				<OPTION value="North Dakota">ND</OPTION>
				<OPTION value="Ohio">OH</OPTION>
				<OPTION value="Oklahoma">OK</OPTION>
				<OPTION value="Oregon">OR</OPTION>
				<OPTION value="Pennsylvania">PA</OPTION>
				<OPTION value="Rhode Island">RI</OPTION>
				<OPTION value="South Carolina">SC</OPTION>
				<OPTION value="South Dakota">SD</OPTION>
				<OPTION value="Tennessee">TN</OPTION>
				<OPTION value="Texas">TX</OPTION>
				<OPTION value="Utah">UT</OPTION>
				<OPTION value="Vermont">VT</OPTION>
				<OPTION value="Virginia">VA</OPTION>
				<OPTION value="Washington">WA</OPTION>
				<OPTION value="West Virginia">WV</OPTION>
				<OPTION value="Wisconsin">WI</OPTION>
				<OPTION value="Wyoming">WY</OPTION>
			</SELECT> <p>
			<INPUT TYPE="SUBMIT" VALUE="Sign up"/> <p>
			<INPUT TYPE="BUTTON" VALUE="Go to Login" onclick="window.location='login.jsp'" >
		</FORM>
	</BODY>
</html>