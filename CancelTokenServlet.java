
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

@WebServlet("/CancelTokenServlet")
public class CancelTokenServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        // Check whether the student is logged in
        if (session == null ||
                session.getAttribute("studentEmail") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        Object idObject = session.getAttribute("tokenId");

        if (!(idObject instanceof Number)) {
            response.sendRedirect("student-dashboard.jsp");
            return;
        }

        int tokenId = ((Number) idObject).intValue();

        Object studentIdObject = session.getAttribute("studentId");

        if (!(studentIdObject instanceof Number)) {
            response.sendRedirect("login.jsp");
            return;
        }

        int studentId = ((Number) studentIdObject).intValue();

        String selectSql =
                "SELECT token_number, status FROM tokens "
              + "WHERE token_id = ? AND student_id = ? FOR UPDATE";

        String updateSql =
                "UPDATE tokens SET status = 'CANCELLED' "
              + "WHERE token_id = ? AND student_id = ? "
              + "AND status = 'WAITING'";

        String historySql =
                "INSERT INTO token_history "
              + "(token_id, old_status, new_status) "
              + "VALUES (?, ?, 'CANCELLED')";

        try (Connection con = DBConnection.getConnection()) {

            con.setAutoCommit(false);

            try {
                String tokenNumber;
                String oldStatus;

                // Find this student's token and lock its database row
                try (PreparedStatement ps =
                        con.prepareStatement(selectSql)) {

                    ps.setInt(1, tokenId);
                    ps.setInt(2, studentId);

                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.next()) {
                            con.rollback();
                            response.sendRedirect(
                                    "student-dashboard.jsp");
                            return;
                        }

                        tokenNumber = rs.getString("token_number");
                        oldStatus = rs.getString("status");
                    }
                }

               // Only WAITING tokens can be cancelled
if (!"WAITING".equals(oldStatus)) {
    con.rollback();

    session.setAttribute(
        "cancelMessage",
        "This token cannot be cancelled because its status is "
        + oldStatus + "."
    );

    response.sendRedirect("token.jsp");
    return;
}

                // Update the token in MySQL
                try (PreparedStatement ps =
                        con.prepareStatement(updateSql)) {

                    ps.setInt(1, tokenId);
                    ps.setInt(2, studentId);

                    if (ps.executeUpdate() != 1) {
                        con.rollback();
                        response.sendRedirect("token.jsp");
                        return;
                    }
                }

                // Record the status change in token_history
                try (PreparedStatement ps =
                        con.prepareStatement(historySql)) {

                    ps.setInt(1, tokenId);
                    ps.setString(2, oldStatus);
                    ps.executeUpdate();
                }

                // Save both database changes together
                con.commit();

                // Update the student's current session
                session.setAttribute("tokenNumber", tokenNumber);
                session.setAttribute("tokenStatus", "CANCELLED");

                response.sendRedirect("token.jsp");

            } catch (Exception e) {
                con.rollback();
                throw e;
            } finally {
                con.setAutoCommit(true);
            }

        } catch (Exception e) {
            throw new ServletException(
                    "Unable to cancel the token in the database.", e);
        }
    }
}
