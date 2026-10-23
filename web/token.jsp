
<%@ page import="controller.DBConnection" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.sql.SQLException" %>
<%@ page import="java.sql.Timestamp" %>

<%
    if (session.getAttribute("studentEmail") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String studentEmail =
        (String) session.getAttribute("studentEmail");

    Integer tokenId = null;
    Object idObject = session.getAttribute("tokenId");

    if (idObject instanceof Number) {
        tokenId = Integer.valueOf(((Number) idObject).intValue());
    }

    String tokenNumber = null;
    String tokenStatus = null;
    String department = null;
    String departmentName = null;
    Timestamp tokenCreatedAt = null;
    int departmentId = -1;
    int peopleAhead = 0;
    String activeToken = "No token currently called";

    String cancelMessage =
        (String) session.getAttribute("cancelMessage");
    session.removeAttribute("cancelMessage");

    // Read the duplicate-token warning.
    String tokenCreationMessage =
        (String) session.getAttribute("tokenCreationMessage");
    session.removeAttribute("tokenCreationMessage");

    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    try {
        con = DBConnection.getConnection();

        // Find the student's latest token if session ID is missing.
        if (tokenId == null) {
            ps = con.prepareStatement(
                "SELECT t.token_id FROM tokens t " +
                "JOIN users u ON t.student_id = u.user_id " +
                "WHERE u.email = ? " +
                "ORDER BY t.created_at DESC, t.token_id DESC LIMIT 1"
            );
            ps.setString(1, studentEmail);
            rs = ps.executeQuery();

            if (rs.next()) {
                tokenId = Integer.valueOf(rs.getInt("token_id"));
                session.setAttribute("tokenId", tokenId);
            }

            rs.close();
            ps.close();
            rs = null;
            ps = null;
        }

        // Read the current token from MySQL.
        if (tokenId != null) {
            ps = con.prepareStatement(
                "SELECT t.token_number, t.status, t.department_id, " +
                "t.created_at, d.department_code, d.department_name " +
                "FROM tokens t " +
                "JOIN departments d ON t.department_id = d.department_id " +
                "JOIN users u ON t.student_id = u.user_id " +
                "WHERE t.token_id = ? AND u.email = ?"
            );
            ps.setInt(1, tokenId.intValue());
            ps.setString(2, studentEmail);
            rs = ps.executeQuery();

            if (rs.next()) {
                tokenNumber = rs.getString("token_number");
                tokenStatus = rs.getString("status");
                departmentId = rs.getInt("department_id");
                department = rs.getString("department_code");
                departmentName = rs.getString("department_name");
                tokenCreatedAt = rs.getTimestamp("created_at");

                session.setAttribute("tokenNumber", tokenNumber);
                session.setAttribute("tokenStatus", tokenStatus);
                session.setAttribute("department", department);
            }

            rs.close();
            ps.close();
            rs = null;
            ps = null;
        }

        // Count earlier waiting tokens in this department.
        if (tokenNumber != null
                && "WAITING".equals(tokenStatus)
                && tokenCreatedAt != null) {

            ps = con.prepareStatement(
                "SELECT COUNT(*) FROM tokens " +
                "WHERE department_id = ? AND status = 'WAITING' " +
                "AND (created_at < ? OR " +
                "(created_at = ? AND token_id < ?))"
            );
            ps.setInt(1, departmentId);
            ps.setTimestamp(2, tokenCreatedAt);
            ps.setTimestamp(3, tokenCreatedAt);
            ps.setInt(4, tokenId.intValue());
            rs = ps.executeQuery();

            if (rs.next()) {
                peopleAhead = rs.getInt(1);
            }

            rs.close();
            ps.close();
            rs = null;
            ps = null;
        }

        // Find the active token in the same department.
        if (departmentId != -1) {
            ps = con.prepareStatement(
                "SELECT token_number FROM tokens " +
                "WHERE department_id = ? " +
                "AND status IN ('CALLED', 'SERVING') " +
                "ORDER BY created_at ASC, token_id ASC LIMIT 1"
            );
            ps.setInt(1, departmentId);
            rs = ps.executeQuery();

            if (rs.next()) {
                activeToken = rs.getString("token_number");
            }

            rs.close();
            ps.close();
            rs = null;
            ps = null;
        }

    } catch (Exception e) {
        application.log("Unable to load live queue information.", e);
    } finally {
        try {
            if (rs != null) rs.close();
        } catch (SQLException e) { }

        try {
            if (ps != null) ps.close();
        } catch (SQLException e) { }

        try {
            if (con != null) con.close();
        } catch (SQLException e) { }
    }

    if (tokenNumber == null) {
        response.sendRedirect("student-dashboard.jsp");
        return;
    }

    if (tokenStatus == null) {
        tokenStatus = "UNKNOWN";
    }

    String statusColor = "#f59e0b";

    if ("CALLED".equals(tokenStatus)) {
        statusColor = "#2563eb";
    } else if ("SERVING".equals(tokenStatus)) {
        statusColor = "#7c3aed";
    } else if ("COMPLETED".equals(tokenStatus)) {
        statusColor = "#16a34a";
    } else if ("SKIPPED".equals(tokenStatus)) {
        statusColor = "#dc2626";
    } else if ("CANCELLED".equals(tokenStatus)) {
        statusColor = "#64748b";
    }

    boolean shouldRefresh =
        "WAITING".equals(tokenStatus)
        || "CALLED".equals(tokenStatus)
        || "SERVING".equals(tokenStatus);
%>

<!DOCTYPE html>
<html>
<head>
    <title>My Token - QueueLess</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <% if (shouldRefresh) { %>
    <meta http-equiv="refresh" content="10">
    <% } %>

    <style>
        * { box-sizing: border-box; }

        body {
            font-family: Arial, sans-serif;
            background: #f4f6f8;
            text-align: center;
            padding: 40px 15px;
            margin: 0;
            color: #1e293b;
        }

        .box {
            background: white;
            width: 480px;
            max-width: 100%;
            margin: auto;
            padding: 30px;
            border-radius: 14px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
        }

        h1 { color: #1d4ed8; font-size: 27px; }

        .token {
            font-size: 42px;
            font-weight: bold;
            color: #2563eb;
            margin: 20px 0;
            overflow-wrap: anywhere;
        }

        .info { font-size: 16px; margin: 16px 0; }

        .status {
            display: inline-block;
            color: white;
            background: <%= statusColor %>;
            padding: 7px 14px;
            border-radius: 20px;
            font-size: 14px;
            font-weight: bold;
        }

        .queue-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 12px;
            margin-top: 25px;
        }

        .queue-card {
            background: #eff6ff;
            border: 1px solid #dbeafe;
            border-radius: 10px;
            padding: 17px 10px;
            overflow-wrap: anywhere;
        }

        .queue-label {
            color: #64748b;
            font-size: 13px;
            margin-bottom: 10px;
        }

        .queue-value {
            color: #1d4ed8;
            font-size: 23px;
            font-weight: bold;
        }

        .message {
            padding: 12px;
            margin-bottom: 18px;
            border-radius: 8px;
            background: #fee2e2;
            color: #b91c1c;
            font-weight: bold;
            font-size: 14px;
            line-height: 1.5;
            overflow-wrap: anywhere;
        }

        .btn {
            display: inline-block;
            padding: 12px 22px;
            background: #2563eb;
            color: white;
            text-decoration: none;
            border-radius: 6px;
            margin-top: 18px;
            font-size: 14px;
        }

        .cancel-btn {
            background: #dc2626;
            color: white;
            padding: 11px 18px;
            border: none;
            border-radius: 6px;
            cursor: pointer;
            font-weight: bold;
            font-size: 14px;
        }

        .note {
            color: #64748b;
            font-size: 13px;
            margin-top: 12px;
            line-height: 1.5;
        }

        .refresh-note {
            color: #64748b;
            font-size: 12px;
            margin-top: 20px;
        }

        @media (max-width: 380px) {
            .queue-grid { grid-template-columns: 1fr; }
            .box { padding: 22px 16px; }
        }
    </style>
</head>

<body>
<div class="box">

    <% if (tokenCreationMessage != null) { %>
        <div class="message"><%= tokenCreationMessage %></div>
    <% } %>

    <% if (cancelMessage != null) { %>
        <div class="message"><%= cancelMessage %></div>
    <% } %>

    <h1>My Queue Status</h1>
    <div class="token"><%= tokenNumber %></div>

    <div class="info">
        <b>Department:</b> <%= departmentName %>
    </div>

    <div class="info">
        <b>Status:</b>
        <span class="status"><%= tokenStatus %></span>
    </div>

    <% if ("WAITING".equals(tokenStatus)) { %>
        <div class="queue-grid">
            <div class="queue-card">
                <div class="queue-label">People ahead</div>
                <div class="queue-value"><%= peopleAhead %></div>
            </div>
            <div class="queue-card">
                <div class="queue-label">Currently called</div>
                <div class="queue-value" style="font-size:19px;">
                    <%= activeToken %>
                </div>
            </div>
        </div>

        <% if (peopleAhead == 0) { %>
            <p class="note">You are next in the waiting queue!</p>
        <% } else { %>
            <p class="note">Please wait. Your position updates automatically.</p>
        <% } %>

        <form action="CancelTokenServlet" method="post">
            <button type="submit" class="cancel-btn">Cancel Token</button>
        </form>
        <p class="note">You can cancel your token while it is waiting.</p>

    <% } else if ("CALLED".equals(tokenStatus)) { %>
        <div class="queue-grid">
            <div class="queue-card">
                <div class="queue-label">Your token</div>
                <div class="queue-value"><%= tokenNumber %></div>
            </div>
            <div class="queue-card">
                <div class="queue-label">Currently called</div>
                <div class="queue-value" style="font-size:19px;">
                    <%= activeToken %>
                </div>
            </div>
        </div>
        <p class="note">Your token has been called. Please proceed to the counter.</p>

    <% } else if ("SERVING".equals(tokenStatus)) { %>
        <p class="note">Your token is currently being served.</p>

    <% } else if ("COMPLETED".equals(tokenStatus)) { %>
        <p class="note">This token has been completed.</p>

    <% } else if ("SKIPPED".equals(tokenStatus)) { %>
        <p class="note">This token has been skipped.</p>

    <% } else if ("CANCELLED".equals(tokenStatus)) { %>
        <p class="note">This token has been cancelled.</p>
    <% } %>

    <% if (shouldRefresh) { %>
        <p class="refresh-note">
            Queue status refreshes automatically every 10 seconds.
        </p>
    <% } %>

    <a href="student-dashboard.jsp" class="btn">Back to Dashboard</a>

</div>
</body>
</html>
