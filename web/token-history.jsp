
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.sql.SQLException" %>
<%@ page import="controller.DBConnection" %>

<%
    if (session.getAttribute("studentEmail") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    Object studentIdObject = session.getAttribute("studentId");

    if (!(studentIdObject instanceof Number)) {
        response.sendRedirect("login.jsp");
        return;
    }

    int studentId = ((Number) studentIdObject).intValue();

    String sql =
        "SELECT t.token_number, d.department_name, t.status, t.created_at "
      + "FROM tokens t "
      + "JOIN departments d ON t.department_id = d.department_id "
      + "WHERE t.student_id = ? "
      + "ORDER BY t.created_at DESC, t.token_id DESC";

    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    boolean hasError = false;
    boolean found = false;
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Token History - QueueLess</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background: #f1f5f9;
            margin: 0;
            padding: 30px;
        }
        .container {
            max-width: 1000px;
            margin: 30px auto;
            background: white;
            padding: 25px;
            border-radius: 12px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.08);
            overflow-x: auto;
        }
        h1 { color: #1e3a8a; }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }
        th, td {
            padding: 12px;
            border-bottom: 1px solid #ddd;
            text-align: left;
        }
        th { background: #1e3a8a; color: white; }
        .empty, .error {
            padding: 15px;
            border-radius: 8px;
        }
        .empty { background: #eff6ff; }
        .error { background: #fee2e2; color: #991b1b; }
        .status { font-weight: bold; }
        .btn {
            display: inline-block;
            margin-top: 20px;
            padding: 10px 16px;
            background: #2563eb;
            color: white;
            text-decoration: none;
            border-radius: 6px;
        }
    </style>
</head>
<body>
<div class="container">
    <h1>My Token History</h1>
    <p>View your tokens, departments, statuses and creation times.</p>

    <%
        try {
            con = DBConnection.getConnection();
            ps = con.prepareStatement(sql);
            ps.setInt(1, studentId);
            rs = ps.executeQuery();

            while (rs.next()) {
                found = true;

                String tokenNumber = rs.getString("token_number");
                String department = rs.getString("department_name");
                String status = rs.getString("status");
                String createdAt = rs.getString("created_at");

                if (!found) {
    %>
                    <p class="empty">No token history found.</p>
    <%
                }
    %>
    <%
                if (found && rs.isFirst()) {
    %>
    <table>
        <tr>
            <th>Token Number</th>
            <th>Department</th>
            <th>Status</th>
            <th>Created At</th>
        </tr>
    <%
                }
    %>
        <tr>
            <td><%= tokenNumber %></td>
            <td><%= department %></td>
            <td class="status"><%= status %></td>
            <td><%= createdAt %></td>
        </tr>
    <%
            }

            if (found) {
    %>
    </table>
    <%
            } else {
    %>
    <p class="empty">No token history found. Generate a token to get started.</p>
    <%
            }

        } catch (Exception e) {
            hasError = true;
            application.log("Unable to load QueueLess token history.", e);
    %>
    <p class="error">Unable to load token history. Please try again later.</p>
    <%
        } finally {
            try { if (rs != null) rs.close(); } catch (SQLException e) { }
            try { if (ps != null) ps.close(); } catch (SQLException e) { }
            try { if (con != null) con.close(); } catch (SQLException e) { }
        }
    %>

    <a href="student-dashboard.jsp" class="btn">Back to Dashboard</a>
</div>
</body>
</html>
