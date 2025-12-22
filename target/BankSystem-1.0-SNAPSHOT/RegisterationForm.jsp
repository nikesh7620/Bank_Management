<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page session="true" %>
<%@ page import="java.util.*" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <title>Bank Management System</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <!-- Bootstrap & Font Awesome -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" />
    <!-- Custom CSS -->
    <link rel="stylesheet" href="RegisterationForm.css" />

    <style>
        body { background-color: #f8f9fa; font-family: Arial, sans-serif; }

        /* Sidebar */
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

        /* Hamburger */
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

        /* Content */
        .content { margin-left: 0; transition: 0.3s; }
        .content.shift { margin-left: 200px; }

        /* Form */
        .form-container {
            margin-top: 60px;
            max-width: 900px;
            margin-left: auto;
            margin-right: auto;
            padding: 20px;
            background: #fff;
            border-radius: 5px;
            box-shadow: 0 0 10px rgba(0,0,0,0.1);
        }
        .form-title { font-size: 22px; font-weight: 600; margin-bottom: 20px; text-align: center; }
    </style>
</head>

<body>

<%-- Clear form-related session attributes at page load --%>
<%
    String[] fieldsToClear = {
        "Name","dob","countryCode","Mobnbr","email","gender","address1","address2","address3",
        "pincode","city","state","country","accType","currency","otherCurrency","idType","idNumber"
    };
    for (String field : fieldsToClear) {
        session.removeAttribute(field);
    }
%>

<!-- Hamburger -->
<i class="fas fa-bars hamburger" id="hamburgerBtn"></i>

<!-- Sidebar -->
<div class="sidebar" id="sidebar">   
    <a href="<%=request.getContextPath()%>/BankDashBoard.jsp"><i class="fas fa-home"></i> Dashboard</a>
    <a href="<%=request.getContextPath()%>/RegisterationForm.jsp"><i class="fas fa-user-plus"></i> Add New Client</a>
    <a href="<%=request.getContextPath()%>/DisplayClient.jsp"><i class="fas fa-users"></i> Display Client</a>
    <a href="<%=request.getContextPath()%>/login.jsp"><i class="fas fa-sign-out-alt"></i> Logout</a>
</div>

<div class="content" id="mainContent">
    <div class="form-container">
        <div class="form-title">Account Registration Form</div>

        <form action="RegisterForm" method="post"> 
            <input type="hidden" name="redirectPage" value="RegisterationForm.jsp"/>
            <input type="hidden" name="pgmname" value="add"/>

            <!-- Name & DOB -->
            <div class="row mb-3">
                <div class="col-md-6">
                    <label>Full Name *</label>
                    <input type="text" class="form-control input-light" name="Name" autocomplete="off" minlength="1" maxlength="30" required
                        value="<%= session.getAttribute("Name") != null ? session.getAttribute("Name") : "" %>">
                </div>
                <div class="col-md-6">
                    <label>Date of Birth *</label>
                    <input type="date" class="form-control input-light" name="dob" autocomplete="off" required
                           value="<%= session.getAttribute("dob") != null ? session.getAttribute("dob") : "" %>">
                </div>
            </div>

            <!-- Phone & Email -->
            <div class="row mb-3">
                <div class="col-md-6">
                    <label>Phone Number *</label>
                    <div class="input-group">
                        <select class="form-select input-light" name="countryCode" style="max-width: 55px;" required>
                            <option value="+91" <%= "+91".equals(session.getAttribute("countryCode")) ? "selected" : "" %>>+91</option>
                            <option value="+1" <%= "+1".equals(session.getAttribute("countryCode")) ? "selected" : "" %>>+1</option>
                            <option value="+44" <%= "+44".equals(session.getAttribute("countryCode")) ? "selected" : "" %>>+44</option>
                            <option value="+61" <%= "+61".equals(session.getAttribute("countryCode")) ? "selected" : "" %>>+61</option>
                            <option value="+81" <%= "+81".equals(session.getAttribute("countryCode")) ? "selected" : "" %>>+81</option>
                            <option value="+971" <%= "+971".equals(session.getAttribute("countryCode")) ? "selected" : "" %>>+971</option>
                            <option value="+65" <%= "+65".equals(session.getAttribute("countryCode")) ? "selected" : "" %>>+65</option>
                        </select>
                        <input type="text" class="form-control input-light" name="Mobnbr" autocomplete="off" minlength="10" maxlength="10" required
                               value="<%= session.getAttribute("Mobnbr") != null ? session.getAttribute("Mobnbr") : "" %>">
                    </div>
                </div>
                <div class="col-md-6">
                    <label>Email *</label>
                    <input type="email" class="form-control input-light" name="email" autocomplete="off" minlength="5" maxlength="40" required
                           value="<%= session.getAttribute("email") != null ? session.getAttribute("email") : "" %>">
                </div>
            </div>

            <!-- Gender -->
            <div class="mb-3">
                <label>Gender *</label><br>
                <input type="radio" name="gender" value="M" required <%= "M".equals(session.getAttribute("gender")) ? "checked" : "" %>> Male
                <input type="radio" name="gender" value="F" class="ms-3" <%= "F".equals(session.getAttribute("gender")) ? "checked" : "" %>> Female
                <input type="radio" name="gender" value="T" class="ms-3" <%= "T".equals(session.getAttribute("gender")) ? "checked" : "" %>> Transgender
            </div>

            <!-- Address -->
            <div class="mb-3">
                <label>Address Line 1 *</label>
                <input type="text" class="form-control input-light" name="address1" autocomplete="off" minlength="1" maxlength="30" required
                       value="<%= session.getAttribute("address1") != null ? session.getAttribute("address1") : "" %>">
            </div>
            <div class="mb-3">
                <label>Address Line 2</label>
                <input type="text" class="form-control input-light" name="address2" autocomplete="off" minlength="0" maxlength="30"
                       value="<%= session.getAttribute("address2") != null ? session.getAttribute("address2") : "" %>">
            </div>
            <div class="row mb-3">
                <div class="col-md-4">
                    <label>Address Line 3</label>
                    <input type="text" class="form-control input-light" name="address3" autocomplete="off" minlength="0" maxlength="30"
                        value="<%= session.getAttribute("address3") != null ? session.getAttribute("address3") : "" %>">
                </div>
                <div class="col-md-4">
                    <label>Pincode *</label>
                    <input type="text" class="form-control input-light" name="pincode" autocomplete="off" minlength="6" maxlength="6" required
                           value="<%= session.getAttribute("pincode") != null ? session.getAttribute("pincode") : "" %>">
                </div>
                <div class="col-md-4">
                    <label>City *</label>
                    <input type="text" class="form-control input-light" name="city" autocomplete="off" minlength="1" maxlength="30" required
                           value="<%= session.getAttribute("city") != null ? session.getAttribute("city") : "" %>">
                </div>
            </div>

            <!-- State & Country -->
            <div class="row mb-3">
                <div class="col-md-6">
                    <label>State *</label>
                    <input type="text" class="form-control input-light" name="state" autocomplete="off" minlength="1" maxlength="30" required
                           value="<%= session.getAttribute("state") != null ? session.getAttribute("state") : "" %>">
                </div>
                <div class="col-md-6">
                    <label>Country *</label>
                    <input type="text" class="form-control input-light" name="country" autocomplete="off" minlength="1" maxlength="30" required
                           value="<%= session.getAttribute("country") != null ? session.getAttribute("country") : "" %>">
                </div>
            </div>

            <!-- Account Type & Currency -->
            <div class="row mb-3">
                <div class="col-md-6">
                    <label>Preferred Account Type *</label><br>
                    <input type="radio" name="accType" value="Savings" required <%= "Savings".equals(session.getAttribute("accType")) ? "checked" : "" %>> Savings
                    <input type="radio" name="accType" value="Current" class="ms-3" <%= "Current".equals(session.getAttribute("accType")) ? "checked" : "" %>> Current    
                </div>
                <div class="col-md-6">
                    <label>Preferred Currency *</label><br>
                    <input type="radio" name="currency" value="USD" required onclick="toggleOtherCurrency()" <%= "USD".equals(session.getAttribute("currency")) ? "checked" : "" %>> USD
                    <input type="radio" name="currency" value="INR" class="ms-3" onclick="toggleOtherCurrency()" <%= "INR".equals(session.getAttribute("currency")) ? "checked" : "" %>> INR
                    <input type="radio" name="currency" value="OTH" class="ms-3" onclick="toggleOtherCurrency()" <%= "OTH".equals(session.getAttribute("currency")) ? "checked" : "" %>> Other:
                    <input type="text" class="input-light ms-2" id="otherCurrencyInput" style="width: 120px; border: 1px solid #ccc;"
                           name="otherCurrency" minlength="3" maxlength="3"
                           value="<%= session.getAttribute("otherCurrency") != null ? session.getAttribute("otherCurrency") : "" %>">
                </div>
            </div>

            <!-- ID Details -->
            <div class="row mb-3">
                <div class="col-md-6">
                    <label>ID Type *</label>
                    <select class="form-control input-light" name="idType" required>
                        <option value="" disabled selected>Select ID Type</option>
                        <option value="Passport" <%= "Passport".equals(session.getAttribute("idType")) ? "selected" : "" %>>Passport</option>
                        <option value="Aadhaar Card" <%= "Aadhaar Card".equals(session.getAttribute("idType")) ? "selected" : "" %>>Aadhaar Card</option>
                        <option value="PAN Card" <%= "PAN Card".equals(session.getAttribute("idType")) ? "selected" : "" %>>PAN Card</option>
                        <option value="Driving License" <%= "Driving License".equals(session.getAttribute("idType")) ? "selected" : "" %>>Driving License</option>
                    </select>
                </div>
                <div class="col-md-6">
                    <label>ID Number *</label>
                    <input type="text" class="form-control input-light" name="idNumber" autocomplete="off" minlength="1" maxlength="20" required
                           value="<%= session.getAttribute("idNumber") != null ? session.getAttribute("idNumber") : "" %>">
                </div>
            </div>

            <!-- Submit -->
            <div class="text-center mb-3">
                <button type="submit" class="btn btn-primary px-5">Submit Application</button>
            </div>

            <%-- Response Modal --%>
            <%
                String responseMessage = (String) session.getAttribute("responseMessage");
                boolean showModal = responseMessage != null && !responseMessage.trim().isEmpty();
            %>
            <% if (showModal) { %>
                <div class="modal fade show" id="responseModal" tabindex="-1" aria-modal="true" role="dialog" style="display: block;">
                    <div class="modal-dialog modal-dialog-centered">
                        <div class="modal-content text-center">
                            <div class="modal-header bg-primary text-white">
                                <h5 class="modal-title w-100">Response Status</h5>
                                <button type="button" class="btn-close btn-close-white" onclick="hideModal()" aria-label="Close"></button>
                            </div>
                            <div class="modal-body"><p><%= responseMessage %></p></div>
                            <div class="modal-footer justify-content-center">
                                <button type="button" class="btn btn-primary" onclick="hideModal()">Close</button>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="modal-backdrop fade show"></div>
                <% session.removeAttribute("responseMessage"); %>
            <% } %>

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

    // Modal hide
    function hideModal() {
        const modal = document.getElementById('responseModal');
        modal.style.display = 'none';
        const backdrop = document.querySelector('.modal-backdrop');
        if (backdrop) backdrop.style.display = 'none';
    }

    // Enable Other currency input using readonly
    function toggleOtherCurrency() {
        const otherCurrencyInput = document.getElementById("otherCurrencyInput");
        const selectedCurrency = document.querySelector('input[name="currency"]:checked').value;

        if (selectedCurrency === "OTH") {
            otherCurrencyInput.readOnly = false;    // Editable
            otherCurrencyInput.required = true;     // Required
        } else {
            otherCurrencyInput.readOnly = true;     // Not editable
            otherCurrencyInput.required = false;    // Not required
            otherCurrencyInput.value = "";          // Clear value
        }
    }

         // Call on page load to set initial state
         window.onload = toggleOtherCurrency;
    
    function showValidationModal(message) {
        const modalHtml = `
            <div class="modal fade show" id="validationModal" tabindex="-1" style="display:block;">
                <div class="modal-dialog modal-dialog-centered">
                    <div class="modal-content text-center">
                        <div class="modal-header bg-danger text-white">
                            <h5 class="modal-title w-100">Validation Error</h5>
                            <button type="button" class="btn-close btn-close-white" onclick="closeValidationModal()"></button>
                        </div>
                        <div class="modal-body"><p>${message}</p></div>
                        <div class="modal-footer justify-content-center">
                            <button class="btn btn-danger" onclick="closeValidationModal()">Close</button>
                        </div>
                    </div>
                </div>
            </div>
            <div class="modal-backdrop fade show"></div>
        `;
        document.body.insertAdjacentHTML("beforeend", modalHtml);
    }

    function closeValidationModal() {
        document.getElementById("validationModal").remove();
        document.querySelector(".modal-backdrop").remove();
    }
</script>

</body>
</html>
