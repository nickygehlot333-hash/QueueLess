
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

@WebServlet("/RegisterServlet")
public class RegisterServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String password = request.getParameter("password");

        if (name == null || email == null || password == null
                || name.trim().isEmpty()
                || email.trim().isEmpty()
                || password.length() < 4) {

            request.setAttribute("errorMessage",
                    "Please enter valid details. Password must have "
                    + "at least 4 characters.");

            request.getRequestDispatcher("register.jsp")
                    .forward(request, response);
            return;
        }

        name = name.trim();
        email = email.trim();

        try (Connection con = DBConnection.getConnection()) {

            // Check whether the email is already registered.
            String checkSql =
                    "SELECT user_id FROM users WHERE email = ?";

            try (PreparedStatement checkPs =
                    con.prepareStatement(checkSql)) {

                checkPs.setString(1, email);

                try (ResultSet rs = checkPs.executeQuery()) {
                    if (rs.next()) {
                        request.setAttribute("errorMessage",
                                "This email is already registered.");

                        request.getRequestDispatcher("register.jsp")
                                .forward(request, response);
                        return;
                    }
                }
            }

            // Register the new account as a student.
            String insertSql =
                    "INSERT INTO users (name, email, password, role) "
                    + "VALUES (?, ?, ?, 'STUDENT')";

            try (PreparedStatement insertPs =
                    con.prepareStatement(insertSql)) {

                insertPs.setString(1, name);
                insertPs.setString(2, email);
                insertPs.setString(3, password);

                int result = insertPs.executeUpdate();

                if (result == 1) {
                    response.sendRedirect("login.jsp?registered=success");
                } else {
                    request.setAttribute("errorMessage",
                            "Registration failed. Please try again.");

                    request.getRequestDispatcher("register.jsp")
                            .forward(request, response);
                }
            }

        } catch (Exception e) {
            throw new ServletException(
                    "Student registration failed due to a database error.",
                    e);
        }
    }
}
