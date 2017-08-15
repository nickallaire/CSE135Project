

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.sql.*;

/**
 * Servlet implementation class ProductController
 */
@WebServlet("/ProductController")
public class ProductController extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public ProductController() {
        super();
        // TODO Auto-generated constructor stub
    }

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
		response.getWriter().append("Served at: ").append(request.getContextPath());
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
		//doGet(request, response);
		
		Connection conn = null;
		String currSearch = null;
		String currCat = null;
		try {
			// Registering Postgressql JDBC driver
			Class.forName("org.postgresql.Driver");
			// Open a conneection to the database
			conn = DriverManager.getConnection(
				"jdbc:postgresql://localhost/CSE135", 
				"postgres", "igelkott");
			
			// Search code
			String action = request.getParameter("action");
			if (action != null && action.equals("search")) {
				currCat = request.getParameter("link");
				currSearch = request.getParameter("search");
			}
			
			// Check if an insertion is requested
			action = request.getParameter("action");
			if (action != null && action.equals("insert")) {
				if (request.getParameter("search") != null)
						currSearch = request.getParameter("search");
				
				currCat = request.getParameter("link");
				
				String name = request.getParameter("name");
				String sku = request.getParameter("sku");
				String category = request.getParameter("category");
				String priceString = request.getParameter("price");
				int price = -1;
				if (priceString.length() > 0)
					try {
						price = Integer.parseInt(request.getParameter("price").toString());
					} catch (Exception e) {
						price = -1;
					}
				
				PreparedStatement check = conn.prepareStatement("select count(*) from product where sku='" + sku + "';");
				ResultSet set = check.executeQuery();
				System.out.println("INSERTING " + name + " " + sku + " " + category + " " + price);
				int count = -1;
				while (set.next())
					count = set.getInt(1);
				if (count == 0) {
					if (name.length() > 0 && sku.length() >0 && category.length() > 0 && price >= 0) {
						// Create the prepared statement to INSERT category values
						PreparedStatement pstmt = conn.prepareStatement(
								"INSERT INTO product (name, sku, category, price) VALUES (?, ?, ?, ?);");
						
						pstmt.setString(1, name);
						pstmt.setString(2, sku);
						pstmt.setString(3, category);
						pstmt.setInt(4, price);
						
						pstmt.executeUpdate();
						request.setAttribute("success", name + ", " + sku + ", " + category + ", " + price + " was successfully submitted");
					} else {
						request.setAttribute("error", "Invalid product data, please try again!");
					}
				} else {
					request.setAttribute("error", "SKU " + sku + " is already taken. Enter a different sku.");
				}
			}
			
			// Add check to make sure update is legal
			if (action != null && action.equals("update")) {
				if (request.getParameter("search") != null)
					currSearch = request.getParameter("search");
				currCat = request.getParameter("link");
				
				String name = request.getParameter("name");
				String sku = request.getParameter("sku");
				String category = request.getParameter("category");
				String priceString = request.getParameter("price");
				int price = -1;
				if (priceString.length() > 0)
					try {
						price = Integer.parseInt(request.getParameter("price").toString());
					} catch (Exception e) {
						price = -1;
					}
								
				try {
					if (name.length() > 0 && sku.length() >0 && category.length() > 0 && price >= 0) {
						
						PreparedStatement pstmt = conn.prepareStatement(
								"UPDATE product SET name=?, sku=?, category=?, price=? WHERE id=?;");
						
						pstmt.setString(1, name);
						pstmt.setString(2, sku);
						pstmt.setString(3, category);
						pstmt.setInt(4, price);
						pstmt.setInt(5, Integer.parseInt(request.getParameter("id")));
						pstmt.executeUpdate();
						
						PreparedStatement up = conn.prepareStatement("update confirmation set sku=? where sku=?;");
						up.setString(1, sku);
						up.setString(2, request.getParameter("oldSku"));
						up.executeUpdate();

						request.setAttribute("success", name + " was successfully updated!");
					} else {
						request.setAttribute("error", "Invalid product data, please try again!");
					}
				} catch (Exception e) {
					System.out.println(e.getMessage());
					request.setAttribute("error", "SKU " + sku + " is already taken. Enter a different value.");
				}			
			}
			
			if (action != null && action.equals("delete")) {
				if (request.getParameter("search") != null)
					currSearch = request.getParameter("search");
				
				String sku = request.getParameter("sku");
				
				currCat = request.getParameter("link");
				try {
//					PreparedStatement add = conn.prepareStatement("alter table cart add constraint cart_sku_fkey foreign key (sku)  references product(sku);");
//					add.executeUpdate();
					PreparedStatement drop = conn.prepareStatement("alter table cart drop constraint cart_sku_fkey;");
					drop.executeUpdate();
					PreparedStatement pstmt = conn.prepareStatement(
							"DELETE FROM product WHERE id=?");
					pstmt.setInt(1, Integer.parseInt(request.getParameter("id")));
					pstmt.executeUpdate();
					
					PreparedStatement up = conn.prepareStatement("delete from cart where sku=?;");
					System.out.println("SKU: " + sku);
					up.setString(1, sku);
					up.executeUpdate();
					
					request.setAttribute("success", request.getParameter("name") + " was successfully deleted!");
					PreparedStatement add = conn.prepareStatement("alter table cart add constraint cart_sku_fkey foreign key (sku)  references product(sku);");
					add.executeUpdate();
				} catch (Exception e) {
					System.out.println(e.getMessage());
				}
			}
			
			
		} catch (Exception e) {
			System.out.println(e.getMessage());
			throw new RuntimeException("There was a runtime problem!", e);
		} finally {
			try {
				if (conn != null)
					conn.close();
			} catch (SQLException e) {
				throw new RuntimeException("Cannot close the connection!", e);
			}
		}
		System.out.println("VALUES LEAVING: " + currCat + " " + currSearch);
		request.setAttribute("link", currCat);
		//request.setAttribute("search", currSearch);
		request.getRequestDispatcher("./product_page.jsp").forward(request, response);

	}

}
