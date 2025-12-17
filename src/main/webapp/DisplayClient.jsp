<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page session="true" %>

<%
    // Session validation
    if (session == null || session.getAttribute("user") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Get client details from request attributes (empty on first visit)
    String accountNumber = request.getAttribute("accountNumber") != null ? (String)request.getAttribute("accountNumber") : "";
    String fullName = request.getAttribute("fullName") != null ? (String)request.getAttribute("fullName") : "";
    String dob = request.getAttribute("dob") != null ? (String)request.getAttribute("dob") : "";
    String phone = request.getAttribute("phone") != null ? (String)request.getAttribute("phone") : "";
    String email = request.getAttribute("email") != null ? (String)request.getAttribute("email") : "";
    String gender = request.getAttribute("gender") != null ? (String)request.getAttribute("gender") : "";
    String addressLine1 = request.getAttribute("addressLine1") != null ? (String)request.getAttribute("addressLine1") : "";
    String addressLine2 = request.getAttribute("addressLine2") != null ? (String)request.getAttribute("addressLine2") : "";
    String addressLine3 = request.getAttribute("addressLine3") != null ? (String)request.getAttribute("addressLine3") : "";
    String city = request.getAttribute("city") != null ? (String)request.getAttribute("city") : "";
    String state = request.getAttribute("state") != null ? (String)request.getAttribute("state") : "";
    String country = request.getAttribute("country") != null ? (String)request.getAttribute("country") : "";
    String pincode = request.getAttribute("pincode") != null ? (String)request.getAttribute("pincode") : "";
    String accountType = request.getAttribute("accountType") != null ? (String)request.getAttribute("accountType") : "";
    String currency = request.getAttribute("currency") != null ? (String)request.getAttribute("currency") : "";
    String idType = request.getAttribute("idType") != null ? (String)request.getAttribute("idType") : "";
    String idNumber = request.getAttribute("idNumber") != null ? (String)request.getAttribute("idNumber") : "";
    String clientError = request.getAttribute("clientError") != null ? (String)request.getAttribute("clientError") : "";
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Display Client Details</title>
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

    <style>
        body { background-color: #f8f9fa; margin: 0; font-family: Arial, sans-serif; }

        /* Sidebar */
        .sidebar {
            height: 100vh;
            width: 0; /* initially hidden */
            background-color: #343a40;
            position: fixed;
            top: 0;
            left: 0;
            padding-top: 60px;
            overflow-x: hidden;
            transition: width 0.3s;
            z-index: 99;
        }
        .sidebar a {
            color: white;
            display: flex;
            align-items: center;
            padding: 10px 20px;
            text-decoration: none;
            font-size: 14px;
            opacity: 0;
            transition: opacity 0.3s;
        }
        .sidebar a i { margin-right: 10px; }
        .sidebar.expanded { width: 200px; }
        .sidebar.expanded a { opacity: 1; }

        /* Hamburger button always on top */
        .hamburger {
            position: fixed;
            top: 15px;
            left: 15px;
            font-size: 28px;
            cursor: pointer;
            z-index: 100; /* higher than sidebar */
            color: #343a40;
            background-color: #f8f9fa;
            padding: 5px 10px;
            border-radius: 4px;
        }

        /* Content */
        .content {
            margin-left: 0;
            padding: 20px;
            transition: margin-left 0.3s;
        }
        .sidebar.expanded ~ .content { margin-left: 200px; }

        /* Headings and form styling */
        .main-heading { text-align: center; color: blue; font-size: 22px; margin-bottom: 10px; }
        .sub-heading { text-align: center; color: blue; font-size: 16px; margin-bottom: 15px; }
        .form-label { font-weight: 600; font-size: 13px; }
        input.form-control { font-size: 13px; padding: 4px 6px; }
        #clientError { color: red; font-size: 12px; margin-top: 3px; }
    </style>
</head>
<body>

<!-- Hamburger -->
<i class="fas fa-bars hamburger" id="hamburgerBtn"></i>

<!-- Sidebar -->
<div class="sidebar" id="sidebar">
    <a href="BankDashBoard.jsp"><i class="fas fa-tachometer-alt"></i><span>Dashboard</span></a>
    <a href="RegisterationForm.jsp"><i class="fas fa-user-plus"></i><span>Add New Client</span></a>
    <a href="DisplayClient.jsp"><i class="fas fa-users"></i><span>Display Client</span></a>
    <a href="login.jsp"><i class="fas fa-sign-out-alt"></i><span>Logout</span></a>
</div>

<!-- Main content -->
<div class="content">
    <h1 class="main-heading">Saamsha Technologies</h1>
    <h2 class="sub-heading">Client Management System</h2>
    <h3 class="sub-heading">Display Client Details</h3>

    <form id="clientForm" action="<%=request.getContextPath()%>/getClientDetails" method="post">
        <input type="hidden" name="redirectPage" value="DisplayClient.jsp">
        <div class="row g-2">
            <!-- Account Number -->
            <div class="col-md-4 col-12 mb-2">
                <label class="form-label">Account Number</label>
                <input type="text" id="accountNumber" name="accountNumber"
                       class="form-control" required minlength="1" maxlength="6"
                       pattern="[A-Za-z0-9]{1,6}"
                       title="Account Number must be 1 to 6 alphanumeric characters"
                       oninput="this.value=this.value.toUpperCase()"
                       value="<%= accountNumber %>">
                <div id="clientError"><%= clientError %></div>
            </div>

            <!-- Client Details -->
            <div class="col-md-6 col-12 mb-2"><label class="form-label">Full Name</label>
                <input class="form-control" readonly value="<%= fullName %>"></div>
            <div class="col-md-6 col-12 mb-2"><label class="form-label">Date of Birth</label>
                <input class="form-control" readonly value="<%= dob %>"></div>
            <div class="col-md-6 col-12 mb-2"><label class="form-label">Phone Number</label>
                <input class="form-control" readonly value="<%= phone %>"></div>
            <div class="col-md-6 col-12 mb-2"><label class="form-label">Email</label>
                <input class="form-control" readonly value="<%= email %>"></div>
            <div class="col-md-6 col-12 mb-2"><label class="form-label">Gender</label>
                <input class="form-control" readonly value="<%= gender %>"></div>
            <div class="col-md-6 col-12 mb-2"><label class="form-label">Address Line 1</label>
                <input class="form-control" readonly value="<%= addressLine1 %>"></div>
            <div class="col-md-6 col-12 mb-2"><label class="form-label">Address Line 2</label>
                <input class="form-control" readonly value="<%= addressLine2 %>"></div>
            <div class="col-md-6 col-12 mb-2"><label class="form-label">Address Line 3</label>
                <input class="form-control" readonly value="<%= addressLine3 %>"></div>
            <div class="col-md-4 col-12 mb-2"><label class="form-label">Pincode</label>
                <input class="form-control" readonly value="<%= pincode %>"></div>
            <div class="col-md-4 col-12 mb-2"><label class="form-label">City</label>
                <input class="form-control" readonly value="<%= city %>"></div>
            <div class="col-md-4 col-12 mb-2"><label class="form-label">State</label>
                <input class="form-control" readonly value="<%= state %>"></div>
            <div class="col-md-6 col-12 mb-2"><label class="form-label">Country</label>
                <input class="form-control" readonly value="<%= country %>"></div>
            <div class="col-md-6 col-12 mb-2"><label class="form-label">Account Type</label>
                <input class="form-control" readonly value="<%= accountType %>"></div>
            <div class="col-md-6 col-12 mb-2"><label class="form-label">Currency</label>
                <input class="form-control" readonly value="<%= currency %>"></div>
            <div class="col-md-6 col-12 mb-2"><label class="form-label">ID Type</label>
                <input class="form-control" readonly value="<%= idType %>"></div>
            <div class="col-md-12 col-12 mb-2"><label class="form-label">ID Number</label>
                <input class="form-control" readonly value="<%= idNumber %>"></div>
        </div>

        <div class="mt-3 text-center">
            <button type="submit" class="btn btn-primary btn-sm">Fetch Client Details</button>
            <button type="button" class="btn btn-secondary btn-sm" id="clearBtn">Clear</button>
        </div>
    </form>
</div>

<script>
    // Sidebar toggle
    const hamburger = document.getElementById("hamburgerBtn");
    const sidebar = document.getElementById("sidebar");
    hamburger.addEventListener("click", () => {
        sidebar.classList.toggle("expanded");
    });

    // Clear client fields
    const accountNumberInput = document.getElementById("accountNumber");
    const clientErrorDiv = document.getElementById("clientError");
    const readonlyInputs = document.querySelectorAll("input[readonly]");

    accountNumberInput.addEventListener("input", () => {
        clientErrorDiv.textContent = "";
        readonlyInputs.forEach(i => i.value = "");
    });

    document.getElementById("clearBtn").addEventListener("click", () => {
        accountNumberInput.value = "";
        clientErrorDiv.textContent = "";
        readonlyInputs.forEach(i => i.value = "");
    });
</script>
</body>
</html>
