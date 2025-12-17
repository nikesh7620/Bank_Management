<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page session="true" %>

<%
    // Prevent caching so user cannot go back after logout
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate"); // HTTP 1.1
    response.setHeader("Pragma", "no-cache"); // HTTP 1.0
    response.setDateHeader("Expires", 0); // Proxies

    // Check user session
    if (session == null || session.getAttribute("user") == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <title>Bank Management System - Dashboard</title>
    <meta name="viewport" content="width=device-width, initial-scale=1" />

    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" rel="stylesheet" />

    <style>
        body {
            background-color: #f8f9fa;
        }
        .sidebar {
            position: fixed;
            width: 220px;
            height: 100vh;
            background-color: #212529;
            padding: 20px;
            color: white;
        }
        .sidebar-title {
            font-weight: bold;
            font-size: 20px;
            margin-bottom: 30px;
            letter-spacing: 1.2px;
        }
        .sidebar a {
            color: #adb5bd;
            text-decoration: none;
            display: block;
            padding: 10px 12px;
            border-radius: 5px;
            margin-bottom: 8px;
            font-weight: 500;
        }
        .sidebar a.active, .sidebar a:hover {
            background-color: #0d6efd;
            color: white;
        }
        .main {
            margin-left: 240px;
            padding: 30px;
            min-height: 100vh;
        }
        .search-container .form-control {
            max-width: 400px;
        }
    </style>
</head>
<body>

<!-- Sidebar -->
<div class="sidebar">
    <div class="sidebar-title">BACK OFFICE</div>
    <a href="#" class="active"><i class="fa fa-tachometer-alt me-2"></i>Dashboard</a>
    <a href="<%= request.getContextPath() %>/login.jsp?logout=true"><i class="fa fa-sign-out-alt me-2"></i>Logout</a>
</div>

<!-- Main content -->
<div class="main">
    <h3 class="mb-4">Client Activities</h3>

    <!-- Top buttons -->
    <div class="d-flex justify-content-end gap-2 mb-3">
        <a href="<%= request.getContextPath() %>/RegisterationForm.jsp" class="btn btn-outline-primary px-4">
            <i class="fa fa-user-plus me-2"></i> ADD NEW CLIENT
        </a>
        <a href="<%= request.getContextPath() %>/DisplayClient.jsp" class="btn btn-success px-4">
            <i class="fa fa-users me-2"></i> DISPLAY CLIENT
        </a>
    </div>

    <!-- Search bar -->
    <div class="search-container mb-3">
        <div class="input-group" style="max-width: 400px;">
            <span class="input-group-text"><i class="fa fa-search"></i></span>
            <input type="text" class="form-control" placeholder="Search for client, name, ID, activity or status" />
        </div>
    </div>

    <!-- Client Activities Table -->
    <table class="table table-hover bg-white">
        <thead class="table-light">
            <tr>
                <th>Client</th>
                <th>Activity</th>
                <th>Date</th>
                <th>Status</th>
            </tr>
        </thead>
        <tbody>
            <!-- Example row -->
            <tr class="text-center text-muted">
                <td colspan="4">No client activity available</td>
            </tr>
        </tbody>
    </table>
</div>

<!-- Bootstrap JS Bundle -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

<script>
    // Reload page on back/forward navigation to prevent stale content
    window.addEventListener("pageshow", function(event) {
        if (event.persisted || performance.getEntriesByType("navigation")[0].type === "back_forward") {
            window.location.reload();
        }
    });
</script>

</body>
</html>
