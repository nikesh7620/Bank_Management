<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="true" %>
<%
    // Security & session check
    if (session == null || session.getAttribute("user") == null) {
        response.sendRedirect("Login.jsp");
        return;
    }

    // Disable caching
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Display Client Details</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <!-- Bootstrap & Font Awesome -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" rel="stylesheet">
    <link rel="stylesheet" href="RegistrationForm.css" />
</head>
<body>

<!-- Hamburger -->
<i class="fas fa-bars hamburger" id="hamburgerBtn"></i>

<!-- Sidebar -->
<div class="sidebar" id="sidebar">
    <a href="LoadDashboardData"><i class="fas fa-home"></i>Dashboard</a>
    <a href="RegistrationForm.jsp"><i class="fas fa-user-plus"></i>Add New Client</a>
    <a href="DisplayClient.jsp"><i class="fas fa-users"></i>Display Client</a>
    <a href="Login.jsp"><i class="fas fa-sign-out-alt"></i>Logout</a>
</div>

<!-- Main Content -->
<div class="content" id="mainContent">
    <div class="form-container">
        <div class="text-center mb-4">
            <h1 style="font-size:32px; font-weight:600; margin-bottom:5px;">Saamsha Technologies</h1>
            <h4 style="font-size:20px; font-weight:400; margin-bottom:10px;">Client Management System</h4>
            <h5 style="font-size:18px; font-weight:500;">Display Client Details</h5>
        </div>

        <form id="clientForm" action="<%=request.getContextPath()%>/GetClientDetails" method="post">
            <input type="hidden" name="redirectPage" value="DisplayClient.jsp">

            <!-- 1st Line: Account Number and Status -->
<div class="row mb-3">
    <div class="col-md-6">
        <label>Account Number <span class="required-star">*</span></label>
        <input type="text" class="form-control input-light" name="accountNumber" id="accountNumber" maxlength="6"
               pattern="[A-Za-z0-9]{1,6}"
               value="<%= session.getAttribute("accountNumber") != null ? session.getAttribute("accountNumber") : "" %>"
               oninput="this.value=this.value.toUpperCase()">
        <div class="field-error" id="clientError">
            <%= session.getAttribute("clientError") != null ? session.getAttribute("clientError") : "" %>
        </div>
    </div>
    <div class="col-md-6">
        <label>Status</label>
        <input type="text" class="form-control input-light" readonly
               value="<%= session.getAttribute("status") != null ? session.getAttribute("status") : "" %>">
    </div>
</div>

            <!-- 2nd Line: Full Name and DOB -->
            <div class="row mb-3">
                <div class="col-md-6">
                    <label>Full Name</label>
                    <input type="text" class="form-control input-light" readonly maxlength="30"
                           value="<%= session.getAttribute("fullName") != null ? session.getAttribute("fullName") : "" %>">
                </div>
                <div class="col-md-6">
                    <label>Date of Birth</label>
                    <input type="date" class="form-control input-light" readonly
                           value="<%= session.getAttribute("dob") != null ? session.getAttribute("dob") : "" %>">
                </div>
            </div>

            <!-- 3rd Line: Phone and Email -->
            <div class="row mb-3">
                <div class="col-md-6">
                    <label>Phone Number</label>
                    <input type="text" class="form-control input-light" readonly maxlength="15"
                           value="<%= session.getAttribute("phone") != null ? session.getAttribute("phone") : "" %>">
                </div>
                <div class="col-md-6">
                    <label>Email</label>
                    <input type="email" class="form-control input-light" readonly maxlength="40"
                           value="<%= session.getAttribute("email") != null ? session.getAttribute("email") : "" %>">
                </div>
            </div>

            <!-- 4th Line: Gender -->
            <div class="row mb-3">
                <div class="col-12">
                    <label>Gender</label>
                    <input type="text" class="form-control input-light" readonly
                           value="<%= "M".equals(session.getAttribute("gender")) ? "Male" :
                                   ("F".equals(session.getAttribute("gender")) ? "Female" :
                                   ("T".equals(session.getAttribute("gender")) ? "Transgender" : "")) %>">
                </div>
            </div>

            <!-- 5th Line: Address Line 1 -->
            <div class="row mb-3">
                <div class="col-12">
                    <label>Address Line 1</label>
                    <input type="text" class="form-control input-light" readonly
                           value="<%= session.getAttribute("addressLine1") != null ? session.getAttribute("addressLine1") : "" %>">
                </div>
            </div>

            <!-- 6th Line: Address Line 2 -->
            <div class="row mb-3">
                <div class="col-12">
                    <label>Address Line 2</label>
                    <input type="text" class="form-control input-light" readonly
                           value="<%= session.getAttribute("addressLine2") != null ? session.getAttribute("addressLine2") : "" %>">
                </div>
            </div>

            <!-- 7th Line: Address Line 3, Pincode and City -->
            <div class="row mb-3">
                <div class="col-md-4">
                    <label>Address Line 3</label>
                    <input type="text" class="form-control input-light" readonly
                           value="<%= session.getAttribute("addressLine3") != null ? session.getAttribute("addressLine3") : "" %>">
                </div>
                <div class="col-md-4">
                    <label>Pincode</label>
                    <input type="text" class="form-control input-light" readonly maxlength="6"
                           value="<%= session.getAttribute("pincode") != null ? session.getAttribute("pincode") : "" %>">
                </div>
                <div class="col-md-4">
                    <label>City</label>
                    <input type="text" class="form-control input-light" readonly
                           value="<%= session.getAttribute("city") != null ? session.getAttribute("city") : "" %>">
                </div>
            </div>

            <!-- 8th Line: State and Country -->
            <div class="row mb-3">
                <div class="col-md-6">
                    <label>State</label>
                    <input type="text" class="form-control input-light" readonly
                           value="<%= session.getAttribute("state") != null ? session.getAttribute("state") : "" %>">
                </div>
                <div class="col-md-6">
                    <label>Country</label>
                    <input type="text" class="form-control input-light" readonly
                           value="<%= session.getAttribute("country") != null ? session.getAttribute("country") : "" %>">
                </div>
            </div>

            <!-- 9th Line: Account Type and Currency -->
            <div class="row mb-3">
                <div class="col-md-6">
                    <label>Preferred Account Type</label>
                    <input type="text" class="form-control input-light" readonly
                           value="<%= session.getAttribute("accountType") != null ? session.getAttribute("accountType") : "" %>">
                </div>
                <div class="col-md-6">
                    <label>Preferred Currency</label>
                    <input type="text" class="form-control input-light" readonly
                           value="<%= session.getAttribute("currency") != null ? session.getAttribute("currency") : "" %>">
                </div>
            </div>

            <!-- 10th Line: ID Type and ID Number -->
            <div class="row mb-3">
                <div class="col-md-6">
                    <label>ID Type</label>
                    <input type="text" class="form-control input-light" readonly
                           value="<%= session.getAttribute("idType") != null ? session.getAttribute("idType") : "" %>">
                </div>
                <div class="col-md-6">
                    <label>ID Number</label>
                    <input type="text" class="form-control input-light" readonly
                           value="<%= session.getAttribute("idNumber") != null ? session.getAttribute("idNumber") : "" %>">
                </div>
            </div>

            <!-- Buttons -->
            <div class="text-center mt-3">
                <button type="submit" class="btn btn-primary btn-sm">Fetch Client Details</button>
                <button type="button" class="btn btn-secondary btn-sm" id="clearBtn">Clear</button>
            </div>

            <%
                // Clear session attributes after showing
                String[] attrs = { "accountNumber","clientError","fullName","dob","phone","email","gender",
                                   "addressLine1","addressLine2","addressLine3","pincode","city","state",
                                   "country","accountType","currency","idType","idNumber","status"};
                for(String a : attrs) session.removeAttribute(a);
            %>
        </form>
    </div>
</div>

<script>
    // Sidebar toggle
    const hamburgerBtn = document.getElementById("hamburgerBtn");
    const sidebar = document.getElementById("sidebar");
    const mainContent = document.getElementById("mainContent");

    hamburgerBtn.addEventListener("click", () => {
        sidebar.classList.toggle("active");
        mainContent.classList.toggle("shift");
    });

    // Form validation & clear button
    const form = document.getElementById("clientForm");
    const accountNumber = document.getElementById("accountNumber");
    const clientError = document.getElementById("clientError");
    const readonlyInputs = document.querySelectorAll('input[readonly]');
    const clearBtn = document.getElementById("clearBtn");

    form.addEventListener("submit", function(e) {
        if(accountNumber.value.trim() === "") {
            e.preventDefault();
            clientError.textContent = "Please enter the account number";
            accountNumber.focus();
        }
    });

    accountNumber.addEventListener("input", () => {
        clientError.textContent = "";
        readonlyInputs.forEach(i => i.value = "");
    });

    clearBtn.addEventListener("click", () => {
        accountNumber.value = "";
        clientError.textContent = "";
        readonlyInputs.forEach(i => i.value = "");
    });
</script>

</body>
</html>
