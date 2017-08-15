<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Similar Products</title>
</head>
<body>
	<h3>Similar Product Pairs</h3>
	<table border=10 frame=box rules=all>
			
			<tbody>
				<tr>
					<td>Product 1</td>
					<td>Product 2</td>
					<td>Cosine Similarity</td>
				</tr>
				<tr>
				<%@page import="ucsd.shoppingApp.*, java.util.*, java.sql.*"%>
				<% 
				try{
					Class.forName("org.postgresql.Driver");
				Connection con = DriverManager.getConnection("jdbc:postgresql://localhost/Project2",
			                    "postgres", "igelkott");	
				
				String getPairs= "SELECT DISTINCT p.id, p.product_name, p2.id, p2.product_name, " 
						+ " (SUM( (pic.price * pic.quantity) * (pic2.price * pic2.quantity)) / (totals1.total + totals2.total)) as cs "
						+ "FROM product p, products_in_cart pic, shopping_cart sc, product p2, products_in_cart pic2, shopping_cart sc2, " 
						+ " (SELECT p.id AS totalsid, p.product_name, SUM(pic.price * pic.quantity)AS total " + 
						        "FROM product p,products_in_cart pic " +
						        "WHERE pic.product_id = p.id GROUP by totalsid) as totals1, " +
						"(SELECT p.id AS totalsid, p.product_name, SUM(pic.price * pic.quantity)AS total " +
						        "FROM product p,products_in_cart pic " +
						        "WHERE pic.product_id = p.id GROUP BY totalsid) as totals2 " +
						"WHERE pic.product_id = p.id AND sc.id = pic.cart_id AND sc.is_purchased = true AND " +
							   "pic2.product_id = p2.id AND sc2.id = pic2.cart_id AND sc2.is_purchased = true " +
						       "AND pic.product_id != pic2.product_id AND p2.product_name > p.product_name " +
						       "AND p.id = totals1.totalsid AND p2.id = totals2.totalsid AND sc.person_id = sc2.person_id " +
						"GROUP BY p.id, p2.id, totals1.total, totals2.total " +
						"ORDER BY cs DESC LIMIT 100;";
				ResultSet rs = null;
				PreparedStatement psmt = con.prepareStatement(getPairs);	
				rs = psmt.executeQuery();
				
				while (rs.next())
				{
				%> <tr>
					<td><%= rs.getString(2) %></td>
					<td><%= rs.getString(4) %></td>
					<td><%= rs.getFloat(5) %> </td>
					</tr>
					
				<% 
				}
				}
				
				catch (Exception e)
				{
					e.printStackTrace();
					System.exit(0);	
				}%>
			
				</tr>
			</tbody>
		</table>
</body>	
</html>