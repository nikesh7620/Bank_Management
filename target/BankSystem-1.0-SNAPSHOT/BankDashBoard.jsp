<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*" %>
<%@ page session="true" %>

<%
    // Prevent caching so user cannot go back after logout
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    // Check user session
    if (session == null || session.getAttribute("user") == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    // Get accounts list from session
    List<Map<String, String>> accounts =
        (List<Map<String, String>>) session.getAttribute("accounts");
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
        body { background-color: #f8f9fa; }
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
        .sidebar a.active,
        .sidebar a:hover {
            background-color: #0d6efd;
            color: white;
        }
        .main {
            margin-left: 240px;
            padding: 30px;
            min-height: 100vh;
        }
    </style>
</head>

<body>

<!-- Sidebar -->
<div class="sidebar">
    <div class="sidebar-title">BACK OFFICE</div>

    <a href="#" class="active">
        <i class="fa fa-home me-2"></i>Dashboard
    </a>

    <a href="<%= request.getContextPath() %>/login.jsp">
        <i class="fa fa-sign-out-alt me-2"></i>Logout
    </a>
</div>

<!-- Main Content -->
<div class="main">

    <h3 class="mb-4">Client Account Activities</h3>

    <!-- Action Buttons -->
    <div class="d-flex justify-content-end gap-2 mb-3">
        <a href="<%= request.getContextPath() %>/RegisterationForm.jsp"
           class="btn btn-outline-primary px-4">
            <i class="fa fa-user-plus me-2"></i>Add New Client
        </a>

        <a href="<%= request.getContextPath() %>/DisplayClient.jsp"
           class="btn btn-success px-4">
            <i class="fa fa-users me-2"></i>Display Client
        </a>
    </div>

    <!-- Search -->
    <div class="mb-3" style="max-width: 400px;">
        <div class="input-group">
            <span class="input-group-text"><i class="fa fa-search"></i></span>
            <input type="text" class="form-control"
                   placeholder="Search by account number, name or status" />
        </div>
    </div>

    <!-- Table -->
    <table class="table table-hover bg-white">
        <thead class="table-light">
            <tr>
                <th>Account Number</th>
                <th>Client Name</th>
                <th>Account Type</th>
                <th>Account Creation Date</th>
                <th>Status</th>
            </tr>
        </thead>

        <tbody>
        <%
            if (accounts != null && !accounts.isEmpty()) {
                for (Map<String, String> acc : accounts) {
                    String status = acc.get("status");
        %>
            <tr>
                <td><%= acc.get("accNo") %></td>
                <td><%= acc.get("clientName") %></td>
                <td><%= acc.get("accType") %></td>
                <td><%= acc.get("createDate") %></td>
                <td>
                    <%
                        if ("A".equals(status)) {
                    %>
                        <span class="badge bg-success">Active</span>
                    <%
                        } else if ("I".equals(status)) {
                    %>
                        <span class="badge bg-secondary">Inactive</span>
                    <%
                        } else {
                    %>
                        <span class="badge bg-danger">Closed</span>
                    <%
                        }
                    %>
                </td>
            </tr>
        <%
                }
            } else {
        %>
            <tr class="text-center text-muted">
                <td colspan="5">No client account activity available</td>
            </tr>
        <%
            }
        %>
        </tbody>
    </table>

</div>

<!-- Bootstrap JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

<script>
    window.addEventListener("pageshow", function (event) {
        if (event.persisted ||
            performance.getEntriesByType("navigation")[0].type === "back_forward") {
            window.location.reload();
        }
    });
</script>

</body>
</html>
