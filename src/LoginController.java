

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.sql.*;

/**
 * Servlet implementation class LoginController
 */
@WebServlet("/LoginController")
public class LoginController extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public LoginController() {
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
		String username = "";
		String role = "";
		String age = "";
		String state = "";
		username = request.getParameter("name");
		boolean okay = true;
		boolean match = false;
		
		if (username.length() == 0)
			okay = false;
		
		if (okay) {
			Connection conn = null;
			try { 
				// Registering Postgresql JDBC driver
				Class.forName("org.postgresql.Driver");
				// Open a conneection to the database
				conn = DriverManager.getConnection(
					"jdbc:postgresql://localhost/CSE135", 
					"postgres", "igelkott");
				
				// Create the statement
				//Statement stmt = conn.createStatement();
				PreparedStatement pstmt = conn.prepareStatement(
						"SELECT * FROM ACCOUNT WHERE username=?;");
				//System.out.println("USER is: " + username);
				pstmt.setString(1, username);
				
				ResultSet rset = pstmt.executeQuery();
				
				String tempName = "Nope";
				while (rset.next()) {
					tempName = rset.getString("username");
					
					//System.out.println("TEMP = " + tempName);
					if (username.compareTo(tempName) == 0) {
						//System.out.println("GOT HERE");
						match = true;
						role = rset.getString("role");
						age = rset.getString("age");
						state = rset.getString("state");
					} else {
						match = false;
					}
				
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
		}
		
		if (match) {
			//System.out.println("AYY");
			request.setAttribute("username", username);
			request.setAttribute("role", role);
			request.setAttribute("age", age);
			request.setAttribute("state", state);
			request.setAttribute("login", "yes");
			request.getRequestDispatcher("./home.jsp").forward(request, response);

		} else {
			request.setAttribute("username", username);
			request.setAttribute("failure", true);
			request.getRequestDispatcher("./login.jsp").forward(request, response);
		}
	}

}
