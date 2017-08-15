

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.sql.*;

/**
 * Servlet implementation class SignUpController
 */
@WebServlet("/SignUpController")
public class SignUpController extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public SignUpController() {
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
		String name = request.getParameter("name");
		String role = request.getParameter("role");
		String ageString = request.getParameter("age");
		int age = -1;
		if (ageString.length() > 0) {
			try{
				age = Integer.parseInt(request.getParameter("age").toString());
			} catch (Exception e) {
				age = -1;
			}
		}
		String state = request.getParameter("state");
		boolean okay = true;
		boolean badName = false;
		boolean badRole = false;
		boolean badAge = false;
		boolean badState = false;
		boolean taken = false;
		
		if (name.length() == 0) {
			okay = false;
			badName = true;
		} else if (role.length() == 0) {
			okay = false;
			badRole = true;
		} else if (age <= 0) {
			okay = false;
			badAge = true;
		} else if (state.length() == 0) {
			okay = false;
			badState = true;
		}
		
		if (okay) {
			Connection conn = null;
			try { 
				// REgistering Postgresql JDBC driver
				Class.forName("org.postgresql.Driver");
				// Open a connection to the database
				conn = DriverManager.getConnection(
					"jdbc:postgresql://localhost/CSE135", 
					"postgres", "igelkott");
		
				// Create the statement
				PreparedStatement pstmt1 = conn.prepareStatement("SELECT * FROM ACCOUNT A WHERE A.username=?;");
				pstmt1.setString(1, name);
				ResultSet rset = pstmt1.executeQuery();
		
				while (rset.next()) {
					String tempName = rset.getString("username");
					
					if (tempName.compareTo(name) == 0) {
						taken = true;
						okay = false;	
					}
				}
				
				if (!taken) {
					PreparedStatement pstmt = conn.prepareStatement(
							"INSERT INTO ACCOUNT(USERNAME, ROLE, AGE, STATE) VALUES(?, ?, ?, ?);");
					
					// Use the statement to INSERT new account
					pstmt.setString(1, name);
					pstmt.setString(2, role);
					pstmt.setInt(3, age);
					pstmt.setString(4, state);
					
					pstmt.executeUpdate();
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
		String message = "";
		String errorCode = "";
		if (okay) {
			message = "You have successfully signed up!";
		} else {
			message = "There was an error signing up!";
			if (taken) 
				errorCode = "Username already taken!";
			else if (badName)
				errorCode = "Must enter a username!";
			else if (badRole)
				errorCode = "Must enter a role!";
			else if (badAge)
				errorCode = "Must enter an age!";
			else if (badState)
				errorCode = "Must enter a state!";
		}
		
		request.setAttribute("message", message);
		request.setAttribute("errorCode", errorCode);
		request.getRequestDispatcher("./signup_result.jsp").forward(request, response);
	}

}
