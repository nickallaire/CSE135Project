<% response.setContentType("application/json") ; %>
<%@page contentType="text/html; charset=UTF-8"%>
<%@page import="org.json.*, java.lang.*"%>
<%@ page import="java.util.*" %>
<%@page import="java.sql.*" %>
<%
	class Cell {
		private String id;
		private String state_name;
		private String product_name;
		private int product_total;
		private int state_total;
		private int cell_total;
		
		public String getId() {
			return id;
		}
		
		public void setId(String id) {
			this.id = id;
		}
		
		public String getStateName() {
			return state_name;
		}
		
		public void setStateName(String state_name) {
			this.state_name = state_name;
		}
		
		public String getProductName() {
			return product_name;
		}
		
		public void setProductName(String product_name) {
			this.product_name = product_name;
		}
		
		public int getProductTotal() {
			return product_total;
		}
		
		public void setProductTotal(int product_total) {
			this.product_total = product_total;
		}
		
		public int getStateTotal() {
			return state_total;
		}
		
		public void setStateTotal(int state_total) {
			this.state_total = state_total;
		}
		
		public int getCellTotal() {
			return cell_total;
		}
		
		public void setCellTotal(int cell_total) {
			this.cell_total = cell_total;
		}
		
		Cell() {
		}
		
		public ArrayList<String> getTopKDiff() {
			
			Connection conn = null;
			ArrayList<String> tkd = new ArrayList<String>();
			int cat_count = Integer.parseInt(request.getParameter("cat_count"));
			String product_filter = request.getParameter("product_filter");
			
			try {
				// Registering Postgressql JDBC driver
				Class.forName("org.postgresql.Driver");
				// Open a connection to the database
				conn = DriverManager.getConnection(
					"jdbc:postgresql://localhost/Project2", 
					"postgres", "igelkott");
				
				Statement stmt = conn.createStatement();
				ResultSet newTopK = null;
				
				// All categories shown
				if (request.getParameter("product_filter").toString().equalsIgnoreCase("All Categories")) {
					newTopK = stmt.executeQuery(
							"(select tt.product_name " +
							"from temp_table tt) " +
								"except " +
							"(select p.product_name " +
							"from product p, products_in_cart pic, shopping_cart sc " +
							"where p.id=pic.product_id and sc.is_purchased=true and sc.id=pic.cart_id " +
							"group by p.product_name " +
							"order by sum(pic.quantity * pic.price) desc " +
							"limit 50)");
					
				// Specific category shown
				} else {
					newTopK = stmt.executeQuery(
							"(select tt.product_name " +
							"from temp_table tt, category c, product p " +
							"where c.category_name='" + product_filter + "' and tt.product_name=p.product_name and c.id=p.category_id) " +
								"except " +
							"(select p.product_name " +
							"from product p, products_in_cart pic, shopping_cart sc, category c " +
							"where p.id=pic.product_id and sc.is_purchased=true and sc.id=pic.cart_id and c.id=p.category_id and c.category_name='" + product_filter + "' " +
							"group by p.product_name " +
							"order by sum(pic.quantity * pic.price) desc " +
							"limit " + cat_count + ")");
				}
				
				
				
				while (newTopK.next()) {
					PreparedStatement stmt1 = conn.prepareStatement("select distinct product_sum " +
								"from temp_table " +
								"where product_name=?");
					stmt1.setString(1, newTopK.getString("product_name"));
					
					ResultSet price = stmt1.executeQuery();
					tkd.add(newTopK.getString("product_name"));
					if (price.next())
						tkd.add(price.getString("product_sum"));
					//System.out.println("DIFF: " + newTopK.getString("product_name"));
				}
				
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
			return tkd;
		}
		
		public ArrayList<String> newTopK() {
			
			Connection conn = null;
			ArrayList<String> ntk = new ArrayList<String>();
			
			int cat_count = Integer.parseInt(request.getParameter("cat_count"));
			String product_filter = request.getParameter("product_filter");
			
			try {
				// Registering Postgressql JDBC driver
				Class.forName("org.postgresql.Driver");
				// Open a connection to the database
				conn = DriverManager.getConnection(
					"jdbc:postgresql://localhost/Project2", 
					"postgres", "igelkott");
				
				Statement stmt = conn.createStatement();
				ResultSet newTopK = null;
			
				if (request.getParameter("product_filter").toString().equalsIgnoreCase("All Categories")) {
					newTopK = stmt.executeQuery("(select p.product_name " +
							"from product p, products_in_cart pic, shopping_cart sc " +
							"where p.id=pic.product_id and sc.is_purchased=true and sc.id=pic.cart_id " +
							"group by p.product_name " +
							"order by sum(pic.quantity * pic.price) desc " +
							"limit 50) " +
		
							"except " +
		
							"(select tt.product_name " +
							"from temp_table tt)");
				} else {
					newTopK = stmt.executeQuery("(select p.product_name " +
							"from product p, products_in_cart pic, shopping_cart sc, category c " +
							"where p.id=pic.product_id and sc.is_purchased=true and sc.id=pic.cart_id and c.id=p.category_id and c.category_name='" + product_filter + "' " +
							"group by p.product_name " +
							"order by sum(pic.quantity * pic.price) desc " +
							"limit " + cat_count + ") " +
		
							"except " +
		
							"(select tt.product_name " +
							"from temp_table tt)");
				}
				
				while (newTopK.next()) {
					PreparedStatement stmt1 = conn.prepareStatement("select sum(pic.quantity *pic.price) as product_sum " +
																	"from product p, shopping_cart sc, products_in_cart pic, person pe " +
																	"where p.product_name=? and p.id=pic.product_id and pic.cart_id=sc.id and sc.is_purchased=true and pe.id=sc.person_id");


					System.out.println("HERE: " + newTopK.getString("product_name"));
					stmt1.setString(1, newTopK.getString("product_name"));
				
					ResultSet price = stmt1.executeQuery();
					
					ntk.add(newTopK.getString("product_name"));
					if (price.next())
						ntk.add(price.getString("product_sum"));
				}
			
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
			return ntk;
		}
		
		public ArrayList<String> updateCells() {
			Connection conn = null;
			ArrayList<String> newCells = new ArrayList<String>();
			int cat_count = Integer.parseInt(request.getParameter("cat_count"));
			String product_filter = request.getParameter("product_filter");
			
			try {
				// Registering Postgressql JDBC driver
				Class.forName("org.postgresql.Driver");
				// Open a connection to the database
				conn = DriverManager.getConnection(
					"jdbc:postgresql://localhost/Project2", 
					"postgres", "igelkott");
				
				Statement stmt = conn.createStatement();
				ResultSet deltaCells = null;
				
				// All Categories shown
				if (request.getParameter("product_filter").toString().equalsIgnoreCase("All Categories")) {
					
					deltaCells = stmt.executeQuery("select tt.state_name, tt.product_name, sum (tt.cell_sum + (l.price * l.quantity)) as cell_total " +
							"from temp_table tt, log l, product p, person pe, state s " +
							"where tt.product_name=p.product_name and p.id=l.product_id and pe.id=l.person_id and pe.state_id=s.id and s.state_name=tt.state_name " +
							"group by tt.state_name, tt.product_name");
					
 			    // Specific Category shown
				}  else {
					
					deltaCells = stmt.executeQuery("select tt.state_name, tt.product_name, sum (tt.cell_sum + (l.price * l.quantity)) as cell_total " +
							"from temp_table tt, log l, product p, person pe, state s, category c " +
							"where tt.product_name=p.product_name and p.id=l.product_id and pe.id=l.person_id and pe.state_id=s.id and s.state_name=tt.state_name and c.id=p.category_id and c.category_name='" + product_filter + "' " +
							"group by tt.state_name, tt.product_name");
				}
				 
				while (deltaCells.next()) {
					PreparedStatement stmt1 = conn.prepareStatement("select sum(pic.quantity *pic.price) as product_sum " +
							"from product p, shopping_cart sc, products_in_cart pic, person pe " +
							"where p.product_name=? and p.id=pic.product_id and pic.cart_id=sc.id and sc.is_purchased=true and pe.id=sc.person_id");

					stmt1.setString(1, deltaCells.getString("product_name"));
					ResultSet price = stmt1.executeQuery();
					
					PreparedStatement stmt2 = null;
					
					if (request.getParameter("product_filter").toString().equalsIgnoreCase("All Categories")){
							stmt2 = conn.prepareStatement("select sum(pic.quantity *pic.price) as state_sum " +
							"from product p, shopping_cart sc, products_in_cart pic, person pe, state s " +
							"where s.state_name=? and pe.state_id=s.id and p.id=pic.product_id and pic.cart_id=sc.id and sc.is_purchased=true and pe.id=sc.person_id");
							
							stmt2.setString(1, deltaCells.getString("state_name"));
					} else {
						stmt2 = conn.prepareStatement("select sum(pic.quantity *pic.price) as state_sum " +
								"from product p, shopping_cart sc, products_in_cart pic, person pe, state s, category c " +
								"where s.state_name=? and pe.state_id=s.id and p.id=pic.product_id and pic.cart_id=sc.id and sc.is_purchased=true and pe.id=sc.person_id and p.category_id=c.id and c.category_name=?");
								
								stmt2.setString(1, deltaCells.getString("state_name"));
								stmt2.setString(2, request.getParameter("product_filter"));
					}
					
					ResultSet sPrice = stmt2.executeQuery();
					
					newCells.add(deltaCells.getString("state_name"));
					newCells.add(deltaCells.getString("product_name"));
					newCells.add(deltaCells.getString("cell_total"));
					if (price.next()) {
						newCells.add(price.getString("product_sum"));
					}
					if (sPrice.next()) {
						newCells.add(sPrice.getString("state_sum"));
					}
				}
				
				stmt.executeUpdate("DELETE FROM log");
				
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
			return newCells;
		}
	}

	ArrayList<Cell> cells = new ArrayList<Cell>();
	ArrayList<String> tkd = new ArrayList<String>();
	ArrayList<String> newCells = new ArrayList<String>();
	
		
	if (request.getParameter("action").toString().equalsIgnoreCase("cell")){
			Cell c1 = new Cell();
			newCells = c1.updateCells();
			
			for (int i = 0; i < newCells.size(); i += 5) {
				Cell c = new Cell();
				c.setId(newCells.get(i) + ":" + newCells.get(i + 1));
				c.setCellTotal(Integer.parseInt(newCells.get(i + 2)));
				c.setProductTotal(Integer.parseInt(newCells.get(i + 3)));
				c.setStateTotal(Integer.parseInt(newCells.get(i + 4)));
				cells.add(c);
			}
	} else {
		Cell c1 = new Cell();
		tkd = c1.getTopKDiff();

		for (int i = 0; i < tkd.size(); i+=2) {
			Cell c = new Cell();
			c.setId(tkd.get(i));
			c.setProductTotal(Integer.parseInt(tkd.get(i + 1)));
			cells.add(c);
		}
		
		if (tkd.size() > 0) {
			Cell temp = new Cell();
			temp.setId("SPLIT_HERE");
			cells.add(temp);
		}
		
		tkd = c1.newTopK();
		
		for (int i = 0; i < tkd.size(); i+=2) {
			Cell c = new Cell();
			c.setId(tkd.get(i));
			c.setProductTotal(Integer.parseInt(tkd.get(i + 1)));
			cells.add(c);
		}
	}
	
	JSONObject jObject = new JSONObject();
	try
	{
	    JSONArray jArray = new JSONArray();
	    for (Cell c : cells)
	    {
	         JSONObject cJSON = new JSONObject();
	         cJSON.put("id", c.getId());
	         cJSON.put("state_name", c.getStateName());
	         cJSON.put("product_name", c.getProductName());
	         cJSON.put("product_total", c.getProductTotal());
	         cJSON.put("state_total", c.getStateTotal());
	         cJSON.put("cell_total", c.getCellTotal());
	         jArray.put(cJSON);
	    }
	    jObject.put("CellList", jArray);
	} catch (Exception jse) {
	    jse.printStackTrace();
	}

	response.getWriter().println(jObject);
%>