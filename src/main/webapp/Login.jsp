<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%
response.setHeader("Cache-Control","no-cache, no-store, must-revalidate");
response.setHeader("Pragma","no-cache");
response.setDateHeader("Expires", 0);

/* Handle logout safely */
if ("true".equals(request.getParameter("logout"))) {
    if (session != null) {
        session.invalidate();
    }
    session = request.getSession(true); // create NEW session
}
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Login</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">

    <style>
        body {
            min-height: 100vh;
            background: linear-gradient(135deg, #e9e6ff, #f5f7ff);
            display: flex;
            align-items: center;
            justify-content: center;
            font-family: 'Segoe UI', sans-serif;
        }
        .login-card {
            max-width: 380px;
            width: 100%;
            background: #fff;
            padding: 30px;
            border-radius: 16px;
            box-shadow: 0 10px 30px rgba(0,0,0,.15);
        }
        .login-title {
            text-align: center;
            font-weight: 700;
            color: #1e40af;
            margin-bottom: 25px;
        }
        .form-control {
            height: 34px;
            font-size: .85rem;
        }
        .btn-login {
            width: 90px;
            background: #1d4ed8;
            color: white;
        }
    </style>
</head>

<body>

<div class="login-card">
    <h4 class="login-title">Saamsha Technologies</h4>

    <form method="post" action="ValidateCredentials">

        <div class="mb-3">
            <label class="form-label">User ID</label>
            <input type="text" name="userId" class="form-control" required maxlength="5">
        </div>

        <div class="mb-3">
            <label class="form-label">Password</label>
            <input type="password" name="password" class="form-control" required maxlength="8">
        </div>

        <div class="text-center mt-4">
            <button type="submit" class="btn btn-login">Login</button>
        </div>

        <%
        String loginError = (String) session.getAttribute("loginError");
        if (loginError != null) {
        %>
            <div class="alert alert-danger text-center mt-3">
                <%= loginError %>
            </div>
        <%
            session.removeAttribute("loginError");
        }
        %>

    </form>
</div>

</body>
</html>
