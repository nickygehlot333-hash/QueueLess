<%
    if (session.getAttribute("studentEmail") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>QueueLess - Take Token</title>
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

        .navbar a {
            float: right;
            color: white;
            text-decoration: none;
            font-size: 16px;
            margin-top: 4px;
        }

        .container {
            width: 500px;
            margin: 60px auto;
            background: white;
            padding: 35px;
            border-radius: 10px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
        }

        h1 {
            text-align: center;
            color: #1f2937;
        }

        label {
            display: block;
            margin-top: 25px;
            margin-bottom: 8px;
            font-weight: bold;
        }

        select {
            width: 100%;
            padding: 12px;
            font-size: 16px;
        }

        button {
            width: 100%;
            margin-top: 25px;
            padding: 12px;
            background: #2563eb;
            color: white;
            border: none;
            border-radius: 5px;
            font-size: 16px;
            cursor: pointer;
        }

        button:hover {
            background: #1d4ed8;
        }
    </style>
</head>

<body>

<div class="navbar">
    QueueLess

    <a href="LogoutServlet">Logout</a>
</div>

<div class="container">

    <h1>Take a Token</h1>

    <form action="TakeTokenServlet" method="post">

        <label>Select Department</label>

        <select name="department" required>

            <option value="">-- Select Department --</option>

            <option value="AC">Accounts</option>

            <option value="EX">Examination Cell</option>

            <option value="AD">Administration</option>

            <option value="SC">Scholarship Section</option>

            <option value="CE">Certificate Section</option>

            <option value="HO">Hostel Office</option>

        </select>

        <button type="submit">
            Get My Token
        </button>

    </form>

</div>

</body>
</html>