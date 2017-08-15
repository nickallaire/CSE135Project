<%@page import="org.json.*"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.ArrayList" %>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>New Sales Analytics Page</title>


</head>
<body>
<label id="log"></label>

	<h3>New Sales Analytics Table</h3>
	<p id="newTopK" align="center"></p>
	
	<%-- Product Category Filter Dropdown --%>
	<% 
		String product_filter;
		int cat_count = 0;
		
		// Set product_filter value
		if (request.getParameter("product_filter") != null)
			product_filter = request.getParameter("product_filter");
		else
			product_filter = "All Categories";
		
		// Create database connection
		Connection conn = null;

		try {
			// Registering Postgressql JDBC driver
			Class.forName("org.postgresql.Driver");
			// Open a connection to the database
			conn = DriverManager.getConnection(
				"jdbc:postgresql://localhost/Project2", 
				"postgres", "igelkott");
			
			// Fills category drop box
			Statement stmt = conn.createStatement();
	%>
			<!-- Run Query button form -->
			<form action="sale_analytics_page_2.jsp" method="get">
				
				Product Category Filter:
				
				<select name="product_filter">
					<%
						if (product_filter.toString().equals("All Categories")) {
					%>
							<option selected="selected" value="All Categories">All Categories</option>
					<%
						} else {
					%>
							<option value="All Categories">All Categories</option>
					<%
						}
						
						// Insert all categories into dropdown menu
						ResultSet rset = stmt.executeQuery("select category_name from category order by category_name asc;");
						while (rset.next()) {
							if (product_filter.toString().equals(rset.getString("category_name"))) {
					%>
								<option selected="selected" value="<%=rset.getString("category_name") %>"><%= rset.getString("category_name") %></option>		
					<%
							} else {
					%>
								<option value="<%=rset.getString("category_name") %>"><%= rset.getString("category_name") %></option>
					<%
							} // else
						} // while loop
					%>
				
				</select> <p>
				
				<input type="submit" value="Run Query"/> <p>
			</form>
			
			<button onclick="refresh();" value="Show"> Refresh </button>
			<button onClick="refresh();" value="Show" style="position: fixed; right: 0;">Refresh</button> <p>
				
			<table id="mytable" border=10 frame=box rules=all>
			<tbody id="tablebody">
		<%
			String query = "";
			
			
			// Empty temp_table
			PreparedStatement deleteTemp = conn.prepareStatement("delete from temp_table");
			deleteTemp.executeUpdate();
			
			if (product_filter.equals("All Categories")) {
				
				// Table query with All Categories
	 			query = "with overall_table as " +
								"(select pc.product_id,c.state_id,sum(pc.price*pc.quantity) as amount " + 
		 							"from products_in_cart pc " +  
		 							"inner join shopping_cart sc on (sc.id = pc.cart_id and sc.is_purchased = true) " + 
		 							"inner join product p on (pc.product_id = p.id) " +
		 							"inner join person c on (sc.person_id = c.id) " + 
		 							"group by pc.product_id,c.state_id " + 
		 						"), " +
		 						"top_state as " +
		 						"(select state_id, sum(amount) as dollar from ( " +
		 							"select state_id, amount from overall_table " +
		 							"UNION ALL " + 
		 							"select id as state_id, 0.0 as amount from state " +
		 							") as state_union " +
		 						"group by state_id order by dollar desc limit 56 " + 
		 						"), " +
		 						"top_n_state as " + 
		 						"(select row_number() over(order by dollar desc) as state_order, state_id, dollar from top_state " +
		 						"), " +
		 						"top_prod as " +
		 						"(select product_id, sum(amount) as dollar from ( " + 
		 							"select product_id, amount from overall_table " +
		 							"UNION ALL " +
		 							"select id as product_id, 0.0 as amount from product " +
		 							") as product_union " +
		 						"group by product_id order by dollar desc limit 50" +
		 						"), " +
		 						"top_n_prod as " +
		 						"(select row_number() over(order by dollar desc) as product_order, product_id, dollar from top_prod " +
		 						") " + 
		 						"select ts.state_id, s.state_name, tp.product_id, pr.product_name, COALESCE(ot.amount, 0.0) as cell_sum, ts.dollar as state_sum, tp.dollar as product_sum " +
		 							"from top_n_prod tp CROSS JOIN top_n_state ts " +
		 							"LEFT OUTER JOIN overall_table ot " +
		 							"ON ( tp.product_id = ot.product_id and ts.state_id = ot.state_id) " +
		 							"inner join state s ON ts.state_id = s.id " + 
		 							"inner join product pr ON tp.product_id = pr.id " + 
		 							"order by ts.state_order, tp.product_order";
			} else {
				
				// Get number of products in specific category
				PreparedStatement pstmt = conn.prepareStatement("select count(*) " +
						"from product, category " +
						"where category.id=product.category_id and category.category_name=?");
				pstmt.setString(1, product_filter);
				ResultSet count = pstmt.executeQuery();
				if (count.next()) {
					cat_count = count.getInt(1);
				}
				
				// Table query with specific category
				query = "with overall_table as " +
						"(select pc.product_id,c.state_id,sum(pc.price*pc.quantity) as amount " + 
 							"from products_in_cart pc " +  
 							"inner join shopping_cart sc on (sc.id = pc.cart_id and sc.is_purchased = true) " + 
 							"inner join product p on (pc.product_id = p.id) " +
 							"inner join category cat on (cat.category_name='" + product_filter + "' and cat.id=p.category_id) " +
 							"inner join person c on (sc.person_id = c.id) " + 
 							"group by pc.product_id,c.state_id " + 
 						"), " +
 						"top_state as " +
 						"(select state_id, sum(amount) as dollar from ( " +
 							"select state_id, amount from overall_table " +
 							"UNION ALL " + 
 							"select id as state_id, 0.0 as amount from state " +
 							") as state_union " +
 						"group by state_id order by dollar desc limit 56 " + 
 						"), " +
 						"top_n_state as " + 
 						"(select row_number() over(order by dollar desc) as state_order, state_id, dollar from top_state " +
 						"), " +
 						"top_prod as " +
 						"(select product_id, sum(amount) as dollar from ( " + 
 							"select product_id, amount from overall_table " +
 							"UNION ALL " +
 							"select id as product_id, 0.0 as amount from product " +
 							") as product_union " +
 						"group by product_id order by dollar desc limit " + cat_count + " " +
 						"), " +
 						"top_n_prod as " +
 						"(select row_number() over(order by dollar desc) as product_order, product_id, dollar from top_prod " +
 						") " + 
 						"select ts.state_id, s.state_name, tp.product_id, pr.product_name, COALESCE(ot.amount, 0.0) as cell_sum, ts.dollar as state_sum, tp.dollar as product_sum " +
 							"from top_n_prod tp CROSS JOIN top_n_state ts " +
 							"LEFT OUTER JOIN overall_table ot " +
 							"ON ( tp.product_id = ot.product_id and ts.state_id = ot.state_id) " +
 							"inner join state s ON ts.state_id = s.id " + 
 							"inner join product pr ON tp.product_id = pr.id " + 
 							"order by ts.state_order, tp.product_order";
			}
			
			// Current table Statement
			Statement topK_state = conn.createStatement(ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_READ_ONLY);
			
			// Current table ResultSet
			ResultSet tset = topK_state.executeQuery(query);
			
			// Insert current table into temp_table for precomputation
			PreparedStatement insertTemp = conn.prepareStatement("INSERT INTO temp_table(state_name, product_name, cell_sum, product_sum, state_sum) VALUES (?, ?, ?, ?, ?)");
			while (tset.next()) {
				insertTemp.setString(1,tset.getString("state_name"));
				insertTemp.setString(2,tset.getString("product_name"));
				insertTemp.setInt(3,Integer.parseInt(tset.getString("cell_sum")));
				insertTemp.setInt(4,Integer.parseInt(tset.getString("product_sum")));
				insertTemp.setInt(5,Integer.parseInt(tset.getString("state_sum")));
				insertTemp.executeUpdate();
			}
			
			tset.beforeFirst();
		%>
			<tr>				
				<th align="center">State</th>
		<%
			int loop = 50;
		
			// Set loop count to specific category count
			if (!(product_filter.equals("All Categories")))
				loop = cat_count;
			
			// Display table header
			for (int i = 0; i < loop; i++) {
				if (tset.next()) {
		%>	
					<th id="<%= tset.getString("product_name") %>" align="center"><%=  tset.getString("product_name")%><br><%= "($" + tset.getString("product_sum") + ")" %></th> 
		<%
				}
			}
		%>
			</tr>			
		<%
			tset.beforeFirst();
			for (int i = 0; i < 56; i++) {
				
				// Display state_name and first product_name cell_sum
				if (tset.next()) {
		%>
				<tr>
					<td align="center" id="<%= tset.getString("state_name") %>"><%= tset.getString("state_name") %> <br> <%= "($" + tset.getString("state_sum") + ")" %></td>
					<td id="<%= tset.getString("state_name") + ":" + tset.getString("product_name") %>" align="center"><%= "$" + tset.getString("cell_sum") %>
		<%
				} // if 
				
				// Display rest of product_name cell_sum's
				for (int j = 0; j < loop - 1; j++) {
					if (tset.next()) {
		%>
						<td id="<%= tset.getString("state_name") + ":" + tset.getString("product_name") %>" align="center"><%= "$" + tset.getString("cell_sum") %></td>
		<%
					} // if 
				} // for inner
		%>
				</tr>
		<%
			} // for outer
		%>
			</tbody>
			</table><p>
		
			<button onClick="refresh()" value="Show"> Refresh </button>
	
	<%
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
	%>
<script>
	
	function refresh() {
		changeProductColor();
		
	}
	
	function changeCellColor(){
		document.getElementById("log").innerHTML = "inside changeCellColor";
		var xmlHttp = new XMLHttpRequest();
		var url="refresh.jsp";
		url = url + "?action=cell&product_filter=<%= product_filter %>&cat_count=<%= cat_count %>";
		
		var stateChanged = function () {
			document.getElementById("log").innerHTML = "inside statechanged";
			
			if (xmlHttp.readyState == 4) {
				console.log(xmlHttp.responseText);
				var jsonStr = xmlHttp.responseText;
				var result = JSON.parse(jsonStr);
				console.log(result);
				showDeltaCells(result);
			}
		}
		
		xmlHttp.onreadystatechange = stateChanged;
		xmlHttp.open("GET", url, true);
		xmlHttp.send(null);
	}
	
	function changeProductColor(){
		//document.getElementById("log").innerHTML = "inside changeCellColor";
		var xmlHttp = new XMLHttpRequest();
		var url="refresh.jsp";
		url = url + "?action=product&product_filter=<%= product_filter %>&cat_count=<%= cat_count %>";
		
		var stateChanged = function () {
			//document.getElementById("log").innerHTML = "inside statechanged";
			
			if (xmlHttp.readyState == 4) {
				console.log(xmlHttp.responseText);
				var jsonStr = xmlHttp.responseText;
				var result = JSON.parse(jsonStr);
				console.log(result);
				showDeltaProducts(result);
			}
		}
		
		xmlHttp.onreadystatechange = stateChanged;
		xmlHttp.open("GET", url, true);
		xmlHttp.send(null);
	}
	
	function showDeltaCells(obj) {
		var i;
		var j;
		var row;
		var col;
		var array;
	    var row="";
	    var arr = obj.CellList;
	    var length = Object.keys(arr).length;
	    console.log("Length: " + length);
	    
	    for(i = 0; i < length; i++) {
	    	array = arr[i].id.toString().split(":");
	    	console.log("Array: " + array[0] + " : " + array[1]);
	    	var x = document.getElementById(arr[i].id);
	    	var y = document.getElementById(array[0]);
	    	var z = document.getElementById(array[1]);
	    	
	    	x.innerHTML = ""+ "$" + arr[i].cell_total +"";
	    	y.innerHTML = "" + array[0] + "<br>($" + arr[i].state_total + ")" + "";
	    	z.innerHTML = "" + array[1] + "<br>($" + arr[i].product_total + ")" + "";
	    	
	    	x.style.backgroundColor = "red"
	    	y.style.backgroundColor = "red"
	    	z.style.backgroundColor = "red"
		}
	    
	}	
	
	function showDeltaProducts(obj) {
		var i;
		var j;
	    var row="";
	    var arr = obj.CellList;
	    
	    var length = Object.keys(arr).length;
	    console.log("Length: " + length);
	    
	    var header = document.getElementById("mytable").getElementsByTagName("th");
	    for(i = 0; i < header.length; i++) {
	    	header[i].style.backgroundColor = "white";
	    }
	    
	    var cell = document.getElementById("mytable").getElementsByTagName("td");
	    console.log("TABLE LENGTH: " + cell.length);
	    for(i = 0; i < cell.length; i++) {
		    cell[i].style.backgroundColor = "white";
	    }
	    
	    console.log("ARR LEN: " + arr.length);
	    for(i = 0; i < length; i++) {
	    	if (arr[i].id === "SPLIT_HERE") {
	    		var y = document.getElementById("newTopK");
	    		var begin = "<label>Top K has changed, new values are: <br>" ;
	    		var middle = "";
	    		
	    		for (j = i + 1; j < length; j++) {
	    			middle = middle + arr[j].id + ": $" + arr[j].product_total + "<br>";
	    		}
	    		
	    		var end = "</label>";
	    		y.innerHTML = begin + middle + end;
	    		break;
	    	}
	    	// HERE
	    	var k;
	    	var header = document.getElementById("mytable").getElementsByTagName("th");
	    	for (k = 1; k < header.length; k++) {
		    	console.log("H: " + header[k].id);

	    	}
	    	var len = header.length + 1;
	    	console.log("HEADER LENGTH: " + (len - 1));
	    	for (k = 1; k < len; k++) {
	    		if (header[k].id == arr[i].id) {
	    			break;
	    		}
	    	}
	    	console.log("HEADER POS: " + k);
	    	
	    	var x = document.getElementById(arr[i].id);
	    	x.innerHTML = ""+ arr[i].id + "<br>" + "($" + arr[i].product_total +")";
	    	x.style.backgroundColor = "purple"
	    	
	    	for (var z = 1; z < 57; z++) {
	    		var c = document.getElementById("mytable").rows[z].cells[k];
	    		c.style.backgroundColor = "purple";
	    	}
	    	

		    	
	    }
    	changeCellColor();
	}
</script>
</body>
</html>