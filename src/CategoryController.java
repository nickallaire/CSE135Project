

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.sql.*;

/**
 * Servlet implementation class CategoryController
 */
@WebServlet("/CategoryController")
public class CategoryController extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public CategoryController() {
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
		
		// Variable declarations and initializations
		Connection conn = null;
		try {
			// Registering Postgressql JDBC driver
			Class.forName("org.postgresql.Driver");
			// Open a connection to the database
			conn = DriverManager.getConnection(
				"jdbc:postgresql://localhost/CSE135", 
				"postgres", "igelkott");
			
			// Check if an insertion is requested
			String name = request.getParameter("name");
			String description = request.getParameter("description");
			
			String action = request.getParameter("action");
			if (name.length() > 0 && description.length() > 0) {
				try{
					if (action != null && action.equals("insert")) {
						// Create the prepared statement to INSERT category values
						PreparedStatement pstmt = conn.prepareStatement(
								"INSERT INTO category (name, description, owner) VALUES (?, ?, ?);");
						
						pstmt.setString(1, request.getParameter("name"));
						pstmt.setString(2, request.getParameter("description"));
						pstmt.setString(3, request.getParameter("username"));
						
						pstmt.executeUpdate();
						
						request.setAttribute("success", "Successfully inserted " + name);
					}
				} catch (Exception e) {
					request.setAttribute("error", "Error, category name already exists");
				}
			} else {
				request.setAttribute("error", "Error inserting new category. Please try again");
			}
			
			// Add check to make sure update is legal
			name = request.getParameter("name");
			description = request.getParameter("description");
			
			if (name.length() > 0 && description.length() > 0) {
				try {
					if (action != null && action.equals("update")) {
						//PreparedStatement add = conn.prepareStatement("alter table product add constraint product_category_fkey foreign key (category)  references category(name);");
						//add.executeUpdate();
						PreparedStatement drop = conn.prepareStatement("alter table product drop constraint product_category_fkey;");
						drop.executeUpdate();
						PreparedStatement pstmt = conn.prepareStatement(
								"UPDATE category SET name = ?, description = ? WHERE id = ?;");
						
						System.out.println("NAME: " + name + " DESCRIPTION: " + description + " ID: " + Integer.parseInt(request.getParameter("id")));
					
						pstmt.setString(1, request.getParameter("name"));
						pstmt.setString(2, request.getParameter("description"));
						pstmt.setInt(3, Integer.parseInt(request.getParameter("id")));
						pstmt.executeUpdate();
						
						PreparedStatement up = conn.prepareStatement("update product set category=? where category=?");
						up.setString(1, name);
						up.setString(2, request.getParameter("oldCategory"));
						up.executeUpdate();
						
						request.setAttribute("success", "Successfully updated " + name);
						
						PreparedStatement add = conn.prepareStatement("alter table product add constraint product_category_fkey foreign key (category)  references category(name);");
						add.executeUpdate();
						
					}
				} catch (Exception e) {
					System.out.println(e.getMessage());
					request.setAttribute("error", "Error, category name already exists");
				}
			} else {
				request.setAttribute("error", "Error updating the category. Please try again");
			}
			
			if (action != null && action.equals("delete")) {
				
				PreparedStatement pstmt = conn.prepareStatement(
						"DELETE FROM category WHERE id = ?");
				pstmt.setInt(1, Integer.parseInt(request.getParameter("id")));
				pstmt.executeUpdate();
				
				request.setAttribute("success", "Successfully deleted " + name);
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
		
		request.getRequestDispatcher("./category_page.jsp").forward(request, response);

	}

}
