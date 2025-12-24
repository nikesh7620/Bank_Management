<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="true" %>

<%
    // Security & session check
    if (session == null || session.getAttribute("user") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Disable caching (optional but recommended)
    response.addHeader("Pragma", "no-cache");
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.addHeader("Cache-Control", "pre-check=0, post-check=0");
    response.setDateHeader("Expires", 0);
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Display Client Details</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" rel="stylesheet">

    <style>
        body {
            background-color: #f8f9fa;
            font-family: Arial, sans-serif;
            margin:0;
        }

        .sidebar {
            height: 100vh;
            width: 200px;
            background-color: #6c757d;
            position: fixed;
            top: 0;
            left: -200px;
            padding-top: 60px;
            transition: 0.3s;
            overflow-x: hidden;
            z-index: 999;
        }

        .sidebar a {
            color: white;
            display: flex;
            align-items: center;
            padding: 10px 20px;
            text-decoration: none;
            font-size: 14px;
            margin: 5px 0;
            border-radius: 4px;
        }

        .sidebar a i { margin-right: 10px; }
        .sidebar a:hover { background-color: #5a6268; }
        .sidebar.active { left: 0; }

        .hamburger {
            position: fixed;
            top: 15px;
            left: 15px;
            font-size: 24px;
            color: #fff;
            background-color: #0d6efd;
            padding: 5px 10px;
            border-radius: 5px;
            cursor: pointer;
            z-index: 1001;
        }

        .content {
            max-width: 900px;
            margin: 0 auto;
            padding: 20px;
            transition: 0.3s;
        }

        .content.shift { margin-left: 200px; }

        .form-label {
            font-weight:600;
            font-size:13px;
        }

        input.form-control {
            font-size: 13px;
            padding:8px;
            width:100%;
            box-sizing:border-box;
        }

        input.form-control:readonly {
            background-color:#eaf2fb;
        }

        #clientError {
            color:#e53935;
            font-size:12px;
            margin-top:3px;
        }

        .btn-primary {
            background-color: #1a73e8;
            border-color: #1a73e8;
        }

        .btn-primary:hover {
            background-color: #155ab6;
            border-color: #155ab6;
        }

        .btn-secondary {
            background-color: #6c757d;
            border-color: #6c757d;
        }

        .btn-secondary:hover {
            background-color: #5a6268;
            border-color: #5a6268;
        }

        .form-row {
            display: flex;
            gap: 15px;
            margin-bottom: 10px;
            flex-wrap: wrap;
        }

        .form-row > div {
            flex: 1;
        }

        /* 🔹 SAME WIDTH AS FULL NAME */
        .half-width {
            flex: 0 0 calc(50% - 7.5px);
        }

        @media (max-width: 768px) {
            .form-row {
                flex-direction: column;
            }
            .half-width {
                flex: 1;
            }
        }
    </style>
</head>

<body>

<i class="fas fa-bars hamburger" id="hamburgerBtn"></i>

<div class="sidebar" id="sidebar">
    <a href="BankDashBoard.jsp"><i class="fas fa-home"></i><span>Dashboard</span></a>
    <a href="RegisterationForm.jsp"><i class="fas fa-user-plus"></i><span>Add New Client</span></a>
    <a href="DisplayClient.jsp"><i class="fas fa-users"></i><span>Display Client</span></a>
    <a href="login.jsp"><i class="fas fa-sign-out-alt"></i><span>Logout</span></a>
</div>

<div class="content">
    <h1 class="text-center text-primary">Saamsha Technologies</h1>
    <h2 class="text-center text-secondary">Client Management System</h2>
    <h3 class="text-center text-secondary">Display Client Details</h3>

    <form id="clientForm" action="<%=request.getContextPath()%>/getClientDetails" method="post">
        <input type="hidden" name="redirectPage" value="DisplayClient.jsp">

        <!-- Account Number -->
        <div class="form-row">
            <div class="half-width">
                <label class="form-label">Account Number</label>
                <input type="text" class="form-control" name="accountNumber" maxlength="6"
                       pattern="[A-Za-z0-9]{1,6}" required
                       value="<%= session.getAttribute("accountNumber") != null ? session.getAttribute("accountNumber") : "" %>"
                       oninput="this.value=this.value.toUpperCase()">
                <div id="clientError">
                    <%= session.getAttribute("clientError") != null ? session.getAttribute("clientError") : "" %>
                </div>
            </div>

            <!-- EMPTY COLUMN TO MATCH FULL NAME WIDTH -->
            <div></div>
        </div>

        <!-- Full Name & DOB -->
        <div class="form-row">
            <div>
                <label class="form-label">Full Name</label>
                <input type="text" class="form-control" readonly maxlength="30"
                       value="<%= session.getAttribute("fullName") != null ? session.getAttribute("fullName") : "" %>">
            </div>
            <div>
                <label class="form-label">Date of Birth</label>
                <input type="date" class="form-control" readonly
                       value="<%= session.getAttribute("dob") != null ? session.getAttribute("dob") : "" %>">
            </div>
        </div>

        <!-- Phone & Email -->
        <div class="form-row">
            <div>
                <label class="form-label">Phone Number</label>
                <input type="text" class="form-control" readonly maxlength="15"
                       value="<%= session.getAttribute("phone") != null ? session.getAttribute("phone") : "" %>">
            </div>
            <div>
                <label class="form-label">Email</label>
                <input type="email" class="form-control" readonly maxlength="40"
                       value="<%= session.getAttribute("email") != null ? session.getAttribute("email") : "" %>">
            </div>
        </div>

        <!-- Gender -->
        <div class="form-row">
            <div class="half-width">
                <label class="form-label">Gender</label>
                <input type="text" class="form-control" readonly maxlength="12"
                       value="<%= "M".equals(session.getAttribute("gender")) ? "Male"
                           : ("F".equals(session.getAttribute("gender")) ? "Female"
                           : ("T".equals(session.getAttribute("gender")) ? "Transgender" : "")) %>">
            </div>

            <!-- EMPTY COLUMN TO MATCH FULL NAME WIDTH -->
            <div></div>
        </div>

        <!-- Address -->
        <div class="form-row">
            <div><label class="form-label">Address Line 1</label>
                <input type="text" class="form-control" readonly
                       value="<%= session.getAttribute("addressLine1") != null ? session.getAttribute("addressLine1") : "" %>">
            </div>
        </div>

        <div class="form-row">
            <div><label class="form-label">Address Line 2</label>
                <input type="text" class="form-control" readonly
                       value="<%= session.getAttribute("addressLine2") != null ? session.getAttribute("addressLine2") : "" %>">
            </div>
        </div>

        <div class="form-row">
            <div><label class="form-label">Address Line 3</label>
                <input type="text" class="form-control" readonly
                       value="<%= session.getAttribute("addressLine3") != null ? session.getAttribute("addressLine3") : "" %>">
            </div>
            <div><label class="form-label">Pincode</label>
                <input type="text" class="form-control" readonly maxlength="6"
                       value="<%= session.getAttribute("pincode") != null ? session.getAttribute("pincode") : "" %>">
            </div>
        </div>

        <div class="form-row">
            <div><label class="form-label">City</label>
                <input type="text" class="form-control" readonly
                       value="<%= session.getAttribute("city") != null ? session.getAttribute("city") : "" %>">
            </div>
            <div><label class="form-label">State</label>
                <input type="text" class="form-control" readonly
                       value="<%= session.getAttribute("state") != null ? session.getAttribute("state") : "" %>">
            </div>
            <div><label class="form-label">Country</label>
                <input type="text" class="form-control" readonly
                       value="<%= session.getAttribute("country") != null ? session.getAttribute("country") : "" %>">
            </div>
        </div>

        <!-- Account / Currency -->
        <div class="form-row">
            <div><label class="form-label">Preferred Account Type</label>
                <input type="text" class="form-control" readonly
                       value="<%= session.getAttribute("accountType") != null ? session.getAttribute("accountType") : "" %>">
            </div>
            <div><label class="form-label">Preferred Currency</label>
                <input type="text" class="form-control" readonly
                       value="<%= session.getAttribute("currency") != null ? session.getAttribute("currency") : "" %>">
            </div>
        </div>

        <!-- ID -->
        <div class="form-row">
            <div><label class="form-label">ID Type</label>
                <input type="text" class="form-control" readonly
                       value="<%= session.getAttribute("idType") != null ? session.getAttribute("idType") : "" %>">
            </div>
            <div><label class="form-label">ID Number</label>
                <input type="text" class="form-control" readonly
                       value="<%= session.getAttribute("idNumber") != null ? session.getAttribute("idNumber") : "" %>">
            </div>
        </div>

        <div class="text-center mt-3">
            <button type="submit" class="btn btn-primary btn-sm">Fetch Client Details</button>
            <button type="button" class="btn btn-secondary btn-sm" id="clearBtn">Clear</button>
        </div>

        <%
            session.removeAttribute("accountNumber");
            session.removeAttribute("clientError");
            session.removeAttribute("fullName");
            session.removeAttribute("dob");
            session.removeAttribute("phone");
            session.removeAttribute("email");
            session.removeAttribute("gender");
            session.removeAttribute("addressLine1");
            session.removeAttribute("addressLine2");
            session.removeAttribute("addressLine3");
            session.removeAttribute("pincode");
            session.removeAttribute("city");
            session.removeAttribute("state");
            session.removeAttribute("country");
            session.removeAttribute("accountType");
            session.removeAttribute("currency");
            session.removeAttribute("idType");
            session.removeAttribute("idNumber");
        %>
    </form>
</div>

<script>
    const hamburgerBtn = document.getElementById("hamburgerBtn");
    const sidebar = document.getElementById("sidebar");
    const content = document.querySelector('.content');

    hamburgerBtn.addEventListener("click", () => {
        sidebar.classList.toggle("active");
        content.classList.toggle("shift");
    });

    const accountNumberInput = document.querySelector('[name="accountNumber"]');
    const readonlyInputs = document.querySelectorAll('input[readonly]');
    const clientErrorDiv = document.getElementById("clientError");

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