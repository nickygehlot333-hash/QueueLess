
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String studentEmail = (String) session.getAttribute("studentEmail");

    if (studentEmail == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String studentName = studentEmail.substring(0, studentEmail.indexOf("@"));
    studentName = studentName.replace(".", " ");
    studentName = studentName.replace("_", " ");

    if (studentName.length() > 0) {
        studentName = studentName.substring(0, 1).toUpperCase()
                     + studentName.substring(1);
    }

    String tokenNumber = (String) session.getAttribute("tokenNumber");
    String department = (String) session.getAttribute("department");
    String tokenStatus = (String) session.getAttribute("tokenStatus");

    if (tokenStatus == null && tokenNumber != null) {
        tokenStatus = "WAITING";
    }

    if (tokenNumber == null) {
        tokenNumber = "No token generated";
        tokenStatus = "N/A";
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Profile - QueueLess</title>

    <style>
        * {
            box-sizing: border-box;
        }

        body {
            margin: 0;
            font-family: Arial, sans-serif;
            background: #f1f5f9;
            color: #1e293b;
        }

        .header {
            background: #1d4ed8;
            color: white;
            padding: 22px;
            text-align: center;
        }

        .header h1 {
            margin: 0;
            font-size: 27px;
        }

        .header p {
            margin: 7px 0 0;
            color: #dbeafe;
        }

        .container {
            max-width: 650px;
            margin: 35px auto;
            padding: 0 18px;
        }

        .profile-card {
            background: white;
            padding: 30px;
            border-radius: 15px;
            box-shadow: 0 5px 20px rgba(0, 0, 0, 0.07);
        }

        .avatar {
            width: 85px;
            height: 85px;
            margin: 0 auto 15px;
            border-radius: 50%;
            background: #dbeafe;
            color: #1d4ed8;
            display: flex;
            justify-content: center;
            align-items: center;
            font-size: 35px;
            font-weight: bold;
        }

        .student-name {
            text-align: center;
            margin: 0 0 5px;
            font-size: 24px;
        }

        .student-role {
            text-align: center;
            color: #64748b;
            margin: 0 0 25px;
        }

        .section-title {
            font-size: 18px;
            margin: 25px 0 15px;
            border-bottom: 1px solid #e2e8f0;
            padding-bottom: 10px;
        }

        .detail {
            margin-bottom: 17px;
        }

        .detail-label {
            display: block;
            font-size: 13px;
            color: #64748b;
            margin-bottom: 5px;
        }

        .detail-value {
            font-size: 15px;
            font-weight: bold;
            overflow-wrap: anywhere;
        }

        .status {
            display: inline-block;
            background: #fef3c7;
            color: #92400e;
            padding: 6px 12px;
            border-radius: 20px;
            font-size: 13px;
        }

        .actions {
            display: flex;
            flex-wrap: wrap;
            gap: 12px;
            margin-top: 28px;
        }

        .btn {
            flex: 1;
            min-width: 150px;
            text-align: center;
            padding: 12px;
            border-radius: 8px;
            text-decoration: none;
            font-weight: bold;
        }

        .primary {
            background: #1d4ed8;
            color: white;
        }

        .secondary {
            background: #e2e8f0;
            color: #1e293b;
        }

        .footer {
            text-align: center;
            color: #64748b;
            font-size: 12px;
            margin-top: 20px;
        }

        @media (max-width: 480px) {
            .profile-card {
                padding: 22px;
            }
        }
    </style>
</head>

<body>

    <div class="header">
        <h1>QueueLess</h1>
        <p>Student Profile</p>
    </div>

    <div class="container">
        <div class="profile-card">

            <div class="avatar">
                <%= studentName.substring(0, 1).toUpperCase() %>
            </div>

            <h2 class="student-name"><%= studentName %></h2>
            <p class="student-role">Student Account</p>

            <h3 class="section-title">Personal Information</h3>

            <div class="detail">
                <span class="detail-label">Student Name</span>
                <span class="detail-value"><%= studentName %></span>
            </div>

            <div class="detail">
                <span class="detail-label">Email Address</span>
                <span class="detail-value"><%= studentEmail %></span>
            </div>

            <h3 class="section-title">Current Token Information</h3>

            <div class="detail">
                <span class="detail-label">Token Number</span>
                <span class="detail-value"><%= tokenNumber %></span>
            </div>

            <div class="detail">
                <span class="detail-label">Department</span>
                <span class="detail-value">
                    <%
                        if ("AC".equals(department)) {
                            out.print("Accounts");
                        } else if ("EX".equals(department)) {
                            out.print("Examination Cell");
                        } else if ("AD".equals(department)) {
                            out.print("Administration");
                        } else if ("SC".equals(department)) {
                            out.print("Scholarship");
                        } else if ("CE".equals(department)) {
                            out.print("Certificate Section");
                        } else if ("HO".equals(department)) {
                            out.print("Hostel Office");
                        } else {
                            out.print("Not selected");
                        }
                    %>
                </span>
            </div>

            <div class="detail">
                <span class="detail-label">Token Status</span>
                <span class="status"><%= tokenStatus %></span>
            </div>

            <div class="actions">
                <a href="student-dashboard.jsp" class="btn primary">
                    Back to Dashboard
                </a>

                <a href="token-history.jsp" class="btn secondary">
                    View Token History
                </a>
            </div>

            <div class="footer">
                QueueLess — Your time matters.
            </div>

        </div>
    </div>

</body>
</html>
