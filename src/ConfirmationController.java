

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.sql.*;


/**
 * Servlet implementation class ConfirmationController
 */
@WebServlet("/ConfirmationController")
public class ConfirmationController extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public ConfirmationController() {
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

		boolean okay = true;
		try {
			// Registering Postgressql JDBC driver
			Class.forName("org.postgresql.Driver");
			
			// Open a conneection to the database
			conn = DriverManager.getConnection(
				"jdbc:postgresql://localhost/CSE135", 
				"postgres", "igelkott");
			
			Statement stmt = conn.createStatement();
			String username = request.getParameter("username");
			String creditCard = request.getParameter("credit_card");

			if (creditCard.length() > 0) {
				ResultSet rset = stmt.executeQuery("select * from cart c, product p where c.username='" + username + "' and p.sku=c.sku;");
				while (rset.next()) {
					PreparedStatement pstmt = conn.prepareStatement("insert into confirmation(username, sku, quantity, price, date) values (?, ?, ?, ?, ?);");
					pstmt.setString(1, username);
					pstmt.setString(2, rset.getString("sku"));
					pstmt.setInt(3, Integer.parseInt(rset.getString("quantity")));
					pstmt.setInt(4, Integer.parseInt(rset.getString("price")));
					pstmt.setString(5, new java.util.Date().toString());
					pstmt.executeUpdate();
				
				}
			} else {
				okay = false;
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

		if (okay)
			request.getRequestDispatcher("./confirmation_page.jsp").forward(request, response);
		else {
			request.setAttribute("error", "Please enter a valid credit card.");
			request.getRequestDispatcher("./shopping_cart.jsp").forward(request, response);
		}
	}

}
