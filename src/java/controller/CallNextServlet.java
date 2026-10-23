
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

@WebServlet("/CallNextServlet")
public class CallNextServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        // Protect the servlet: staff must be logged in
        if (session == null
                || session.getAttribute("staffUsername") == null) {
            response.sendRedirect("staff-login.jsp");
            return;
        }

        // Read the selected department from the dashboard
        String departmentCode =
                request.getParameter("departmentCode");

        if (departmentCode == null
                || departmentCode.trim().isEmpty()) {
            departmentCode = "ALL";
        }

        departmentCode = departmentCode.trim().toUpperCase();

        // Accept only valid department codes or ALL
        if (!"ALL".equals(departmentCode)
                && !"AC".equals(departmentCode)
                && !"EX".equals(departmentCode)
                && !"AD".equals(departmentCode)
                && !"SC".equals(departmentCode)
                && !"CE".equals(departmentCode)
                && !"HO".equals(departmentCode)) {

            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Invalid department selection."
            );
            return;
        }

        // Remember the selected filter
        session.setAttribute(
                "selectedDepartmentCode", departmentCode);

        String selectSql =
                "SELECT t.token_id, t.token_number, "
              + "d.department_code, d.department_name "
              + "FROM tokens t "
              + "JOIN departments d "
              + "ON t.department_id = d.department_id "
              + "WHERE t.status = 'WAITING' ";

        if (!"ALL".equals(departmentCode)) {
            selectSql += "AND d.department_code = ? ";
        }

        selectSql +=
                "ORDER BY t.created_at ASC, t.token_id ASC "
              + "LIMIT 1 FOR UPDATE";

        String updateSql =
                "UPDATE tokens SET status = 'CALLED' "
              + "WHERE token_id = ? AND status = 'WAITING'";

        String historySql =
                "INSERT INTO token_history "
              + "(token_id, old_status, new_status) "
              + "VALUES (?, 'WAITING', 'CALLED')";

        try (Connection con = DBConnection.getConnection()) {

            con.setAutoCommit(false);

            try {
                int tokenId;
                String tokenNumber;
                String selectedDepartmentCode;
                String departmentName;

                /*
                 * Serialize Call Next requests.
                 * Every CallNextServlet transaction locks the
                 * department rows before checking active tokens.
                 */
                String lockSql =
                        "SELECT department_id FROM departments "
                      + "ORDER BY department_id FOR UPDATE";

                try (PreparedStatement ps =
                        con.prepareStatement(lockSql);
                     ResultSet rs = ps.executeQuery()) {

                    while (rs.next()) {
                        rs.getInt("department_id");
                    }
                }

                /*
                 * SAFETY CHECK:
                 * Do not call another token while any token
                 * is already CALLED or SERVING.
                 */
                String activeSql =
                        "SELECT token_number, status FROM tokens "
                      + "WHERE status IN ('CALLED', 'SERVING') "
                      + "ORDER BY token_id ASC LIMIT 1 FOR UPDATE";

                try (PreparedStatement ps =
                        con.prepareStatement(activeSql);
                     ResultSet rs = ps.executeQuery()) {

                    if (rs.next()) {
                        String activeToken =
                                rs.getString("token_number");
                        String activeStatus =
                                rs.getString("status");

                        con.commit();

                        session.setAttribute(
                                "callNextMessage",
                                "Token " + activeToken + " is already "
                                + activeStatus + ". Complete or skip it "
                                + "before calling another token."
                        );

                        response.sendRedirect(
                                "staff-dashboard.jsp");
                        return;
                    }
                }

                // Find the oldest waiting token in the chosen queue
                try (PreparedStatement ps =
                        con.prepareStatement(selectSql)) {

                    if (!"ALL".equals(departmentCode)) {
                        ps.setString(1, departmentCode);
                    }

                    try (ResultSet rs = ps.executeQuery()) {

                        if (!rs.next()) {
                            con.commit();

                            session.setAttribute(
                                    "callNextMessage",
                                    "No waiting tokens in "
                                    + ("ALL".equals(departmentCode)
                                       ? "the queue."
                                       : "the selected department.")
                            );

                            response.sendRedirect(
                                    "staff-dashboard.jsp");
                            return;
                        }

                        tokenId = rs.getInt("token_id");
                        tokenNumber =
                                rs.getString("token_number");
                        selectedDepartmentCode =
                                rs.getString("department_code");
                        departmentName =
                                rs.getString("department_name");
                    }
                }

                // Change WAITING to CALLED
                try (PreparedStatement ps =
                        con.prepareStatement(updateSql)) {

                    ps.setInt(1, tokenId);

                    if (ps.executeUpdate() != 1) {
                        con.rollback();

                        session.setAttribute(
                                "callNextMessage",
                                "The token could not be called. "
                                + "Please try again."
                        );

                        response.sendRedirect(
                                "staff-dashboard.jsp");
                        return;
                    }
                }

                // Record the status change in token history
                try (PreparedStatement ps =
                        con.prepareStatement(historySql)) {

                    ps.setInt(1, tokenId);
                    ps.executeUpdate();
                }

                con.commit();

                // Store the selected token in the staff session
                session.setAttribute("tokenId", tokenId);
                session.setAttribute("tokenNumber", tokenNumber);
                session.setAttribute("department", departmentName);
                session.setAttribute("tokenStatus", "CALLED");

                session.removeAttribute("callNextMessage");

                request.setAttribute("token", tokenNumber);
                request.setAttribute("status", "CALLED");

                System.out.println(
                        "Called token: " + tokenNumber
                        + ", department: " + selectedDepartmentCode
                );

                request.getRequestDispatcher(
                        "staff-dashboard.jsp")
                        .forward(request, response);

            } catch (Exception e) {
                con.rollback();
                throw e;
            } finally {
                con.setAutoCommit(true);
            }

        } catch (Exception e) {
            throw new ServletException(
                    "Unable to call the next token from the database.",
                    e
            );
        }
    }
}
