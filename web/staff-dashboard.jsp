
<%@ page import="controller.DBConnection" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.sql.SQLException" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.LinkedHashMap" %>

<%
    // Protect the staff dashboard
    if (session.getAttribute("staffUsername") == null) {
        response.sendRedirect("staff-login.jsp");
        return;
    }

    // Remember the selected department filter
    String selectedDepartmentCode =
        (String) session.getAttribute("selectedDepartmentCode");

    if (selectedDepartmentCode == null) {
        selectedDepartmentCode = "ALL";
    }

    // Message returned by CallNextServlet
    String callNextMessage =
        (String) session.getAttribute("callNextMessage");

    session.removeAttribute("callNextMessage");

    // Current active token information
    String token = "No Active Token";
    String status = "NO ACTIVE TOKEN";
    String department = "Department Not Selected";
    boolean hasActiveToken = false;

    Connection currentCon = null;
    PreparedStatement currentPs = null;
    ResultSet currentRs = null;

    try {
        currentCon = DBConnection.getConnection();

        currentPs = currentCon.prepareStatement(
            "SELECT t.token_id, t.token_number, t.status, " +
            "d.department_name " +
            "FROM tokens t " +
            "JOIN departments d ON t.department_id = d.department_id " +
            "WHERE t.status IN ('CALLED', 'SERVING') " +
            "ORDER BY t.created_at DESC, t.token_id DESC LIMIT 1"
        );

        currentRs = currentPs.executeQuery();

        if (currentRs.next()) {
            int currentTokenId = currentRs.getInt("token_id");

            token = currentRs.getString("token_number");
            status = currentRs.getString("status");
            department = currentRs.getString("department_name");
            hasActiveToken = true;

            session.setAttribute("tokenId", currentTokenId);
            session.setAttribute("tokenNumber", token);
            session.setAttribute("tokenStatus", status);
            session.setAttribute("department", department);

        } else {
            session.removeAttribute("tokenId");
            session.removeAttribute("tokenNumber");
            session.removeAttribute("tokenStatus");
            session.removeAttribute("department");
        }

    } catch (Exception e) {
        application.log("Unable to load current token.", e);
    } finally {
        try {
            if (currentRs != null) currentRs.close();
        } catch (SQLException e) { }

        try {
            if (currentPs != null) currentPs.close();
        } catch (SQLException e) { }

        try {
            if (currentCon != null) currentCon.close();
        } catch (SQLException e) { }
    }

    // Overall queue information
    int waitingCount = 0;
    String nextToken = "None";

    Connection queueCon = null;
    PreparedStatement queuePs = null;
    ResultSet queueRs = null;

    try {
        queueCon = DBConnection.getConnection();

        queuePs = queueCon.prepareStatement(
            "SELECT COUNT(*) FROM tokens WHERE status = 'WAITING'"
        );

        queueRs = queuePs.executeQuery();

        if (queueRs.next()) {
            waitingCount = queueRs.getInt(1);
        }

        queueRs.close();
        queueRs = null;

        queuePs.close();
        queuePs = null;

        queuePs = queueCon.prepareStatement(
            "SELECT token_number FROM tokens " +
            "WHERE status = 'WAITING' " +
            "ORDER BY created_at ASC, token_id ASC LIMIT 1"
        );

        queueRs = queuePs.executeQuery();

        if (queueRs.next()) {
            nextToken = queueRs.getString("token_number");
        }

    } catch (Exception e) {
        application.log("Unable to load queue information.", e);
    } finally {
        try {
            if (queueRs != null) queueRs.close();
        } catch (SQLException e) { }

        try {
            if (queuePs != null) queuePs.close();
        } catch (SQLException e) { }

        try {
            if (queueCon != null) queueCon.close();
        } catch (SQLException e) { }
    }

    // Department-wise waiting token counts
    Map<String, Integer> departmentQueues =
        new LinkedHashMap<String, Integer>();

    Connection deptCon = null;
    PreparedStatement deptPs = null;
    ResultSet deptRs = null;

    try {
        deptCon = DBConnection.getConnection();

        deptPs = deptCon.prepareStatement(
            "SELECT d.department_name, COUNT(t.token_id) AS waiting_count " +
            "FROM departments d " +
            "LEFT JOIN tokens t ON d.department_id = t.department_id " +
            "AND t.status = 'WAITING' " +
            "GROUP BY d.department_id, d.department_name " +
            "ORDER BY d.department_name"
        );

        deptRs = deptPs.executeQuery();

        while (deptRs.next()) {
            departmentQueues.put(
                deptRs.getString("department_name"),
                deptRs.getInt("waiting_count")
            );
        }

    } catch (Exception e) {
        application.log(
            "Unable to load department-wise queue information.", e
        );
    } finally {
        try {
            if (deptRs != null) deptRs.close();
        } catch (SQLException e) { }

        try {
            if (deptPs != null) deptPs.close();
        } catch (SQLException e) { }

        try {
            if (deptCon != null) deptCon.close();
        } catch (SQLException e) { }
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>Staff Dashboard - QueueLess</title>
    <meta charset="UTF-8">
    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <style>
        * {
            box-sizing: border-box;
        }

        body {
            font-family: Arial, sans-serif;
            background: #f1f5f9;
            margin: 0;
            padding: 25px 15px;
            color: #1e293b;
        }

        .dashboard-container {
            max-width: 900px;
            margin: 0 auto;
        }

        .page-header {
            text-align: center;
            margin-bottom: 25px;
        }

        .page-header h1 {
            color: #1d4ed8;
            margin-bottom: 8px;
        }

        .page-header p {
            color: #64748b;
            margin-top: 0;
        }

        .token-card,
        .queue-info,
        .department-section,
        .filter-card {
            background: white;
            border-radius: 16px;
            padding: 25px;
            margin-bottom: 22px;
            box-shadow: 0 5px 20px rgba(0, 0, 0, 0.06);
        }

        .token-card {
            text-align: center;
            border-top: 5px solid #2563eb;
        }

        .department-name {
            color: #475569;
            margin-top: 0;
        }

        .current-label {
            color: #64748b;
            margin-top: 25px;
        }

        .token-number {
            font-size: 38px;
            font-weight: bold;
            color: #1d4ed8;
            margin: 15px 0;
            overflow-wrap: anywhere;
        }

        .status {
            display: inline-block;
            padding: 8px 16px;
            border-radius: 20px;
            font-weight: bold;
            font-size: 13px;
            background: #e2e8f0;
            color: #334155;
        }

        .status-called {
            background: #dbeafe;
            color: #1d4ed8;
        }

        .status-serving {
            background: #fef3c7;
            color: #92400e;
        }

        .status-none {
            background: #f1f5f9;
            color: #64748b;
        }

        .queue-info h2,
        .department-section h2,
        .filter-card h2 {
            color: #1d4ed8;
            margin-top: 0;
        }

        .filter-card p {
            color: #64748b;
            line-height: 1.5;
        }

        .department-select {
            width: 100%;
            padding: 12px;
            margin: 8px 0 15px;
            border: 1px solid #cbd5e1;
            border-radius: 8px;
            background: white;
            color: #1e293b;
            font-size: 15px;
        }

        button,
        .logout-btn {
            display: inline-block;
            border: none;
            border-radius: 8px;
            padding: 12px 18px;
            margin: 5px;
            font-size: 14px;
            font-weight: bold;
            text-decoration: none;
            cursor: pointer;
        }

        button:hover,
        .logout-btn:hover {
            opacity: 0.85;
        }

        button:disabled {
            opacity: 0.45;
            cursor: not-allowed;
        }

        .call-btn {
            background: #2563eb;
            color: white;
        }

        .complete-btn {
            background: #16a34a;
            color: white;
        }

        .skip-btn {
            background: #dc2626;
            color: white;
        }

        .logout-btn {
            background: #e2e8f0;
            color: #334155;
        }

        .queue-row {
            display: flex;
            justify-content: space-between;
            gap: 15px;
            padding: 14px 0;
            border-bottom: 1px solid #e2e8f0;
        }

        .queue-row:last-child {
            border-bottom: none;
        }

        .queue-value {
            font-weight: bold;
            overflow-wrap: anywhere;
            text-align: right;
        }

        .department-grid {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 16px;
            margin-top: 20px;
        }

        .department-card {
            background: #f8fafc;
            border: 1px solid #e2e8f0;
            border-left: 4px solid #2563eb;
            border-radius: 12px;
            padding: 18px;
        }

        .department-card h3 {
            font-size: 16px;
            margin: 0 0 12px;
            color: #334155;
        }

        .department-count {
            font-size: 30px;
            font-weight: bold;
            color: #1d4ed8;
            margin: 0 0 6px;
        }

        .department-caption,
        .empty-queue {
            font-size: 13px;
            color: #64748b;
            margin: 0;
        }

        .message {
            background: #eff6ff;
            color: #1d4ed8;
            border: 1px solid #bfdbfe;
            border-radius: 8px;
            padding: 12px 15px;
            margin-bottom: 20px;
            line-height: 1.5;
        }

        .action-buttons {
            margin-top: 25px;
        }

        .logout-area {
            text-align: center;
            margin-top: 25px;
        }

        @media (max-width: 480px) {
            .token-card,
            .queue-info,
            .department-section,
            .filter-card {
                padding: 20px 15px;
            }

            .token-number {
                font-size: 30px;
            }

            .department-grid {
                grid-template-columns: 1fr;
            }

            button {
                margin: 5px 2px;
                padding: 11px 12px;
            }
        }
    </style>
</head>

<body>

<div class="dashboard-container">

    <div class="page-header">
        <h1>QueueLess</h1>
        <p>Staff Dashboard</p>
    </div>

    <% if (callNextMessage != null) { %>
        <div class="message">
            <%= callNextMessage %>
        </div>
    <% } %>

    <!-- Department selection -->
    <div class="filter-card">
        <h2>Call Next Token</h2>

        <p>
            Choose a department to call its oldest waiting token,
            or select All Departments to use the college-wide queue.
        </p>

        <form action="CallNextServlet" method="post">

            <label for="departmentCode">
                <strong>Select Department</strong>
            </label>

            <select id="departmentCode"
                    name="departmentCode"
                    class="department-select">

                <option value="ALL"
                    <%= "ALL".equals(selectedDepartmentCode)
                        ? "selected" : "" %>>
                    All Departments
                </option>

                <option value="AC"
                    <%= "AC".equals(selectedDepartmentCode)
                        ? "selected" : "" %>>
                    Accounts
                </option>

                <option value="EX"
                    <%= "EX".equals(selectedDepartmentCode)
                        ? "selected" : "" %>>
                    Examination Cell
                </option>

                <option value="AD"
                    <%= "AD".equals(selectedDepartmentCode)
                        ? "selected" : "" %>>
                    Administration
                </option>

                <option value="SC"
                    <%= "SC".equals(selectedDepartmentCode)
                        ? "selected" : "" %>>
                    Scholarship Section
                </option>

                <option value="CE"
                    <%= "CE".equals(selectedDepartmentCode)
                        ? "selected" : "" %>>
                    Certificate Section
                </option>

                <option value="HO"
                    <%= "HO".equals(selectedDepartmentCode)
                        ? "selected" : "" %>>
                    Hostel Office
                </option>

            </select>

            <button type="submit"
                    class="call-btn"
                    <%= hasActiveToken ? "disabled" : "" %>>
                Call Next
            </button>

            <% if (hasActiveToken) { %>
                <p class="empty-queue">
                    Complete or skip the active token before
                    calling another token.
                </p>
            <% } %>

        </form>
    </div>

    <!-- Current active token -->
    <div class="token-card">

        <h2 class="department-name"><%= department %></h2>

        <p class="current-label">Active Token</p>

        <div class="token-number"><%= token %></div>

        <p>
            <strong>Status:</strong>
            <span class="status <%
                if ("CALLED".equals(status)) {
                    out.print("status-called");
                } else if ("SERVING".equals(status)) {
                    out.print("status-serving");
                } else {
                    out.print("status-none");
                }
            %>"><%= status %></span>
        </p>

        <div class="action-buttons">

            <form action="CompleteTokenServlet" method="post"
                  style="display:inline;">
                <button type="submit"
                        class="complete-btn"
                    <%= hasActiveToken ? "" : "disabled" %>>
                    Complete
                </button>
            </form>

            <form action="SkipTokenServlet" method="post"
                  style="display:inline;">
                <button type="submit"
                        class="skip-btn"
                    <%= hasActiveToken ? "" : "disabled" %>>
                    Skip
                </button>
            </form>

        </div>
    </div>

    <!-- Overall queue information -->
    <div class="queue-info">

        <h2>Queue Information</h2>

        <div class="queue-row">
            <span>Total Waiting Tokens</span>
            <span class="queue-value"><%= waitingCount %></span>
        </div>

        <div class="queue-row">
            <span>Next Token Across All Departments</span>
            <span class="queue-value"><%= nextToken %></span>
        </div>

    </div>

    <!-- Department-wise waiting counts -->
    <div class="department-section">

        <h2>Department-wise Queue</h2>

        <p class="empty-queue">
            Counts include only tokens with WAITING status.
        </p>

        <% if (departmentQueues.isEmpty()) { %>

            <p class="empty-queue">
                Department queue information is unavailable.
                Please check the database connection.
            </p>

        <% } else { %>

            <div class="department-grid">

                <% for (Map.Entry<String, Integer> entry
                        : departmentQueues.entrySet()) { %>

                    <div class="department-card">
                        <h3><%= entry.getKey() %></h3>

                        <p class="department-count">
                            <%= entry.getValue() %>
                        </p>

                        <p class="department-caption">
                            Waiting
                            <%= entry.getValue() == 1
                                ? "token" : "tokens" %>
                        </p>
                    </div>

                <% } %>

            </div>

        <% } %>

    </div>

    <!-- Logout -->
    <div class="logout-area">
        <a href="StaffLogoutServlet" class="logout-btn">
            Logout
        </a>
    </div>

</div>

</body>
</html>
