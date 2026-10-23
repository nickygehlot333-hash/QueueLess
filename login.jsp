<!DOCTYPE html>
<html>
<head>
    <title>QueueLess - Login</title>
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
            text-align: center;
            font-size: 24px;
            font-weight: bold;
        }

        .login-container {
            width: 350px;
            margin: 80px auto;
            background: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
        }

        h2 {
            text-align: center;
            color: #1f2937;
        }

        label {
            display: block;
            margin-top: 15px;
            margin-bottom: 5px;
        }

        input {
            width: 100%;
            padding: 10px;
            box-sizing: border-box;
            border: 1px solid #ccc;
            border-radius: 5px;
        }

        button {
            width: 100%;
            padding: 12px;
            margin-top: 25px;
            background: #2563eb;
            color: white;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-size: 16px;
        }

        button:hover {
            background: #1d4ed8;
        }

        .register {
            text-align: center;
            margin-top: 20px;
        }

        .register a {
            color: #2563eb;
            text-decoration: none;
        }
    </style>
</head>

<body>

    <div class="navbar">
        QueueLess
    </div>

    <div class="login-container">

        <h2>Student Login</h2>

        <form action="LoginServlet" method="post">

            <label>Email</label>
            <input type="email" name="email" required>

            <label>Password</label>
            <input type="password" name="password" required>

            <button type="submit">Login</button>

        </form>

        <div class="register">
            Don't have an account?
            <a href="register.jsp">Register</a>
        </div>

    </div>

</body>
</html>