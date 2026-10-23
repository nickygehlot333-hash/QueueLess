<%
    if (session.getAttribute("studentEmail") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String studentEmail = (String) session.getAttribute("studentEmail");
    String tokenNumber = (String) session.getAttribute("tokenNumber");
    String department = (String) session.getAttribute("department");
    String tokenStatus = (String) session.getAttribute("tokenStatus");

    if (tokenStatus == null && tokenNumber != null) {
        tokenStatus = "WAITING";
    }

    String departmentName = department;

    if ("EX".equals(department)) {
        departmentName = "Examination Cell";
    } else if ("AC".equals(department)) {
        departmentName = "Accounts";
    } else if ("AD".equals(department)) {
        departmentName = "Administration";
    } else if ("SC".equals(department)) {
        departmentName = "Scholarship Section";
    } else if ("CE".equals(department)) {
        departmentName = "Certificate Section";
    } else if ("HO".equals(department)) {
        departmentName = "Hostel Office";
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>QueueLess - Student Dashboard</title>
    <meta charset="UTF-8">

    <style>
        body {
            margin: 0;
            font-family: Arial, sans-serif;
            background: #f4f6f8;
        }

        .navbar {
            background: #1f2937;
            color: white;
            padding: 20px;
            font-size: 24px;
            font-weight: bold;
        }

        .container {
            padding: 40px;
        }

        h1 {
            color: #1f2937;
        }

        .cards {
            display: flex;
            gap: 20px;
            flex-wrap: wrap;
            margin-top: 30px;
        }

        .card {
            background: white;
            width: 220px;
            padding: 25px;
            border-radius: 10px;
            box-shadow: 0 4px 10px rgba(0,0,0,0.1);
        }

        .card h3 {
            margin-top: 0;
        }

        .status-card {
            background: white;
            padding: 25px;
            border-radius: 10px;
            box-shadow: 0 4px 10px rgba(0,0,0,0.1);
            margin-top: 25px;
            max-width: 650px;
        }

        .token-number {
            font-size: 30px;
            font-weight: bold;
            color: #2563eb;
        }

        .status {
            font-weight: bold;
            color: #2563eb;
        }

        .btn {
            display: inline-block;
            margin-top: 10px;
            padding: 10px 18px;
            background: #2563eb;
            color: white;
            text-decoration: none;
            border-radius: 5px;
        }
    </style>
</head>

<body>

    <div class="navbar">
        QueueLess - Student Dashboard

        <a href="LogoutServlet"
           style="float:right; color:white; text-decoration:none;">
            Logout
        </a>
    </div>

    <div class="container">

        <h1>Welcome, <%= studentEmail %>!</h1>

        <p>Manage your digital queue from here.</p>

        <!-- Current Token Status -->
        <div class="status-card">
            <h2>My Current Token</h2>

            <% if (tokenNumber != null) { %>

                <div class="token-number"><%= tokenNumber %></div>

                <p>
                    <b>Department:</b>
                    <%= departmentName == null ? department : departmentName %>
                </p>

                <p>
                    <b>Status:</b>
                    <span class="status">
                        <%= tokenStatus == null ? "WAITING" : tokenStatus %>
                    </span>
                </p>

                <a href="token.jsp" class="btn">View Token Details</a>

            <% } else { %>

                <p>You have not taken a token yet.</p>
                <a href="take-token.jsp" class="btn">Take Your First Token</a>

            <% } %>
        </div>

        <div class="cards">

            <div class="card">
                <h3>Take Token</h3>
                <p>Join a queue for a college service.</p>
                <a href="take-token.jsp" class="btn">Take Token</a>
            </div>

            <div class="card">
                <h3>My Current Token</h3>
                <p>Check your current queue status.</p>
                <a href="token.jsp" class="btn">View Token</a>
            </div>

            
            <div class="card">
                <h3>Token History</h3>
                <p>View your previous tokens.</p>
                <a href="token-history.jsp" class="btn">View History</a>
            </div>

            
            <div class="card">
                <h3>Profile</h3>
                <p>View and manage your profile.</p>
                <a href="student-profile.jsp" class="btn">My Profile</a>
            </div>


        </div>

    </div>

</body>
</html>
