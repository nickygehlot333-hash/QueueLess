
package controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        String email = request.getParameter("email");
        String password = request.getParameter("password");

        String sql = "SELECT user_id, name, email, role "
                   + "FROM users "
                   + "WHERE email = ? AND password = ? "
                   + "AND role = 'STUDENT'";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, email);
            ps.setString(2, password);

            try (ResultSet rs = ps.executeQuery()) {

                if (rs.next()) {
                    HttpSession session = request.getSession();

                    session.setAttribute("studentEmail",
                            rs.getString("email"));
                    session.setAttribute("studentName",
                            rs.getString("name"));
                    session.setAttribute("studentId",
                            rs.getInt("user_id"));

                    response.sendRedirect("student-dashboard.jsp");

                } else {
                    response.sendRedirect(
                            "login.jsp?error=invalid");
                }
            }

        } catch (Exception e) {
            throw new ServletException(
                    "Student login failed due to a database error.", e);
        }
    }
}
