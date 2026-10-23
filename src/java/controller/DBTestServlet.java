
package controller;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.SQLException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/DBTestServlet")
public class DBTestServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/html;charset=UTF-8");

        try (PrintWriter out = response.getWriter()) {

            try (Connection con = DBConnection.getConnection()) {
                out.println("<h2>Database connection successful!</h2>");
                out.println("<p>QueueLess is connected to MySQL.</p>");

            } catch (SQLException e) {
                out.println("<h2>Database connection failed.</h2>");
                out.println("<p>" + e.getMessage() + "</p>");
                e.printStackTrace();
            }
        }
    }
}
