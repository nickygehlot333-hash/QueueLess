
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

@WebServlet("/StaffLoginServlet")
public class StaffLoginServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        String email = request.getParameter("username");
        String password = request.getParameter("password");

        String sql = "SELECT user_id, name, email "
                   + "FROM users "
                   + "WHERE email = ? AND password = ? "
                   + "AND role = 'STAFF'";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, email);
            ps.setString(2, password);

            try (ResultSet rs = ps.executeQuery()) {

                if (rs.next()) {
                    HttpSession session = request.getSession();

                    session.setAttribute("staffUsername",
                            rs.getString("name"));
                    session.setAttribute("staffEmail",
                            rs.getString("email"));
                    session.setAttribute("staffId",
                            rs.getInt("user_id"));

                    response.sendRedirect("staff-dashboard.jsp");

                } else {
                    response.sendRedirect(
                            "staff-login.jsp?error=invalid");
                }
            }

        } catch (Exception e) {
            throw new ServletException(
                    "Staff login failed due to a database error.", e);
        }
    }
}
