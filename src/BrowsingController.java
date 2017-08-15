

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Servlet implementation class BrowsingController
 */
@WebServlet("/BrowsingController")
public class BrowsingController extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public BrowsingController() {
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
		
//		try {
//			
//			// Registering Postgressql JDBC driver
//			Class.forName("org.postgresql.Driver");
//			
//			// Open a conneection to the database
//			conn = DriverManager.getConnection(
//				"jdbc:postgresql://localhost/CSE135", 
//				"postgres", "igelkott");
			
			// Search code
			String action = request.getParameter("action");
			if (action != null && action.equals("search")) {
				currCat = request.getParameter("link");
				currSearch = request.getParameter("search");
			}
			
//		} catch (Exception e) {
//			System.out.println(e.getMessage());
//			throw new RuntimeException("There was a runtime problem!", e);
//		} finally {
//			try {
//				if (conn != null)
//					conn.close();
//			} catch (SQLException e) {
//				throw new RuntimeException("Cannot close the connection!", e);
//			}
//		}
		//System.out.println("VALUES LEAVING: " + currCat + " " + currSearch);
		request.setAttribute("link", currCat);
		request.setAttribute("search", currSearch);
		request.getRequestDispatcher("./product_browsing.jsp").forward(request, response);
	}

}
