
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

@WebServlet("/SkipTokenServlet")
public class SkipTokenServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null ||
                session.getAttribute("staffUsername") == null) {
            response.sendRedirect("staff-login.jsp");
            return;
        }

        Object idObject = session.getAttribute("tokenId");

        if (!(idObject instanceof Number)) {
            response.sendRedirect("staff-dashboard.jsp");
            return;
        }

        int tokenId = ((Number) idObject).intValue();

        String selectSql =
                "SELECT token_number, status FROM tokens "
              + "WHERE token_id = ? FOR UPDATE";

        String updateSql =
                "UPDATE tokens SET status = 'SKIPPED' "
              + "WHERE token_id = ? AND status = 'CALLED'";

        String historySql =
                "INSERT INTO token_history "
              + "(token_id, old_status, new_status) "
              + "VALUES (?, ?, 'SKIPPED')";

        try (Connection con = DBConnection.getConnection()) {

            con.setAutoCommit(false);

            try {
                String tokenNumber;
                String oldStatus;

                try (PreparedStatement ps =
                        con.prepareStatement(selectSql)) {

                    ps.setInt(1, tokenId);

                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.next()) {
                            con.rollback();
                            response.sendRedirect("staff-dashboard.jsp");
                            return;
                        }

                        tokenNumber = rs.getString("token_number");
                        oldStatus = rs.getString("status");
                    }
                }

                if (!"CALLED".equals(oldStatus)) {
                    con.rollback();
                    response.sendRedirect("staff-dashboard.jsp");
                    return;
                }

                try (PreparedStatement ps =
                        con.prepareStatement(updateSql)) {

                    ps.setInt(1, tokenId);

                    if (ps.executeUpdate() != 1) {
                        con.rollback();
                        response.sendRedirect("staff-dashboard.jsp");
                        return;
                    }
                }

                try (PreparedStatement ps =
                        con.prepareStatement(historySql)) {

                    ps.setInt(1, tokenId);
                    ps.setString(2, oldStatus);
                    ps.executeUpdate();
                }

                con.commit();

                session.setAttribute("tokenNumber", tokenNumber);
                session.setAttribute("tokenStatus", "SKIPPED");

                request.setAttribute("token", tokenNumber);
                request.setAttribute("status", "SKIPPED");

                request.getRequestDispatcher("staff-dashboard.jsp")
                       .forward(request, response);

            } catch (Exception e) {
                con.rollback();
                throw e;
            } finally {
                con.setAutoCommit(true);
            }

        } catch (Exception e) {
            throw new ServletException(
                    "Unable to skip the token in the database.", e);
        }
    }
}
