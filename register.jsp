
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>QueueLess - Student Registration</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background: #f1f5f9;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            margin: 0;
        }
        .container {
            background: white;
            width: 350px;
            padding: 30px;
            border-radius: 12px;
            box-shadow: 0 5px 20px rgba(0,0,0,0.1);
        }
        h2 {
            text-align: center;
            color: #1e3a8a;
        }
        label {
            display: block;
            margin-top: 15px;
            font-weight: bold;
        }
        input {
            width: 100%;
            padding: 10px;
            margin-top: 6px;
            border: 1px solid #cbd5e1;
            border-radius: 6px;
            box-sizing: border-box;
        }
        button {
            width: 100%;
            margin-top: 22px;
            padding: 11px;
            background: #2563eb;
            color: white;
            border: none;
            border-radius: 6px;
            cursor: pointer;
            font-size: 16px;
        }
        .message {
            color: #b91c1c;
            text-align: center;
            margin-top: 12px;
        }
        .login {
            text-align: center;
            margin-top: 18px;
        }
    </style>
</head>
<body>
<div class="container">
    <h2>Create Student Account</h2>

    <form action="RegisterServlet" method="post">
        <label for="name">Full Name</label>
        <input type="text" id="name" name="name" required>

        <label for="email">Email</label>
        <input type="email" id="email" name="email" required>

        <label for="password">Password</label>
        <input type="password" id="password" name="password"
               minlength="4" required>

        <button type="submit">Register</button>
    </form>

    <%
        String error = (String) request.getAttribute("errorMessage");
        if (error != null) {
    %>
        <div class="message"><%= error %></div>
    <%
        }
    %>

    <div class="login">
        Already registered? <a href="login.jsp">Login</a>
    </div>
</div>
</body>
</html>
