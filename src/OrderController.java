

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.sql.*;

/**
 * Servlet implementation class OrderController
 */
@WebServlet("/OrderController")
public class OrderController extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public OrderController() {
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
		Connection conn = null;

		int quantity = -1;

		try {
			// Registering Postgressql JDBC driver
			Class.forName("org.postgresql.Driver");
			// Open a conneection to the database
			conn = DriverManager.getConnection(
				"jdbc:postgresql://localhost/CSE135", 
				"postgres", "igelkott");
			
			String quantityString = request.getParameter("quantity");
			
			if (quantityString.length() > 0) {
				try {
					quantity = Integer.parseInt(quantityString);
				} catch (Exception e) {
					quantity = -1;
				}
			}
			
			if (quantity > 0) {
				PreparedStatement pstmt = conn.prepareStatement("insert into cart(sku, quantity, username) values(?, ?, ?);");
				pstmt.setString(1, request.getParameter("sku"));
				pstmt.setInt(2,  Integer.parseInt(request.getParameter("quantity")));
				pstmt.setString(3, request.getParameter("username"));
				pstmt.executeUpdate();
				
			} else {
				request.setAttribute("error", "Invalid quantity, please enter a different value");
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
	
		if (quantity > 0) {
			//request.getRequestDispatcher("./product_browsing.jsp").forward(request, response);
			response.sendRedirect(request.getContextPath() + "/product_browsing.jsp");
		} else {
			request.setAttribute("id", request.getParameter("id"));
			request.setAttribute("name", request.getParameter("name"));
			request.setAttribute("category", request.getParameter("category"));
			request.setAttribute("price", request.getParameter("price"));
			request.setAttribute("sku", request.getParameter("sku"));
			
			request.getRequestDispatcher("./product_order.jsp").forward(request, response);
			

		}
	}

}
