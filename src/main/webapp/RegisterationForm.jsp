<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page session="true" %>
<%@ page import="java.util.*" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <title>Bank Management System</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" />
    <link rel="stylesheet" href="RegisterationForm.css" />
  
    <style>
        body { background-color: #f8f9fa; font-family: Arial, sans-serif; }
        .sidebar { height: 100vh; width: 200px; background-color: #6c757d; position: fixed; top: 0; left: -200px; padding-top: 60px; transition: 0.3s; overflow-x: hidden; z-index: 999; }
        .sidebar a { color: white; display: flex; align-items: center; padding: 10px 20px; text-decoration: none; font-size: 14px; margin: 5px 0; border-radius: 4px; }
        .sidebar a i { margin-right: 10px; }
        .sidebar a:hover { background-color: #5a6268; }
        .sidebar.active { left: 0; }
        .hamburger { position: fixed; top: 15px; left: 15px; font-size: 24px; color: #fff; background-color: #0d6efd; padding: 5px 10px; border-radius: 5px; cursor: pointer; z-index: 1001; }
        .content { margin-left: 0; transition: 0.3s; }
        .content.shift { margin-left: 200px; }
        .form-container { margin-top: 60px; max-width: 900px; margin-left: auto; margin-right: auto; padding: 20px; background: #fff; border-radius: 5px; box-shadow: 0 0 10px rgba(0,0,0,0.1); }
        .form-title { font-size: 22px; font-weight: 600; margin-bottom: 20px; text-align: center; }
        .field-error { color: #dc3545; font-size: 12px; margin-top: 3px; }
        .required-star { color: #dc3545; font-weight: bold; }
        #otherCurrencyInput[readonly] { background-color: #e9ecef; }
    </style>
</head>

<body>
<%
    // --- 1. Robustly handle new client and responseCode ---
    Boolean isNewClient = "true".equals(request.getParameter("newClient"));
    String responseCode = (String) session.getAttribute("responseCode");

    if (isNewClient) {
        // Clear session fields whenever Add New Client is clicked
        String[] fieldsToClear = {
            "Name","dob","countryCode","Mobnbr","email","gender","address1","address2","address3",
            "pincode","city","state","country","accType","currency","otherCurrency","idType","idNumber"
        };
        for (String field : fieldsToClear) {
            session.removeAttribute(field);
        }
        session.removeAttribute("responseCode");
    } else {
        // Keep previous responseCode trimmed
        if (responseCode != null) responseCode = responseCode.trim();
    }
%>

<!-- Hamburger -->
<i class="fas fa-bars hamburger" id="hamburgerBtn"></i>

<!-- Sidebar -->
<div class="sidebar" id="sidebar">
    <a href="<%=request.getContextPath()%>/BankDashBoard.jsp"><i class="fas fa-home"></i> Dashboard</a>
    <!-- Pass newClient=true to trigger clearing -->
    <a href="<%=request.getContextPath()%>/RegisterationForm.jsp?newClient=true"><i class="fas fa-user-plus"></i> Add New Client</a>
    <a href="<%=request.getContextPath()%>/DisplayClient.jsp"><i class="fas fa-users"></i> Display Client</a>
    <a href="<%=request.getContextPath()%>/login.jsp"><i class="fas fa-sign-out-alt"></i> Logout</a>
</div>

<div class="content" id="mainContent">
    <div class="form-container">
        <div class="form-title">Account Registration Form</div>

        <form action="RegisterForm" method="post" novalidate>
            <input type="hidden" name="redirectPage" value="RegisterationForm.jsp"/>
            <input type="hidden" name="pgmname" value="add"/>

                        <!-- Name & DOB -->
            <div class="row mb-3">
                <div class="col-md-6">
                    <label>Full Name <span class="required-star">*</span></label>
                    <input type="text" class="form-control input-light" name="Name" autocomplete="off" minlength="1" maxlength="30" 
                        value="<%= session.getAttribute("Name") != null ? session.getAttribute("Name") : "" %>" required>                    
                    <div class="field-error" id="nameError"></div>
                </div>
                <div class="col-md-6">
                    <label>Date of Birth <span class="required-star">*</span></label>
                    <input type="date" class="form-control input-light" name="dob" autocomplete="off" 
                        value="<%= session.getAttribute("dob") != null ? session.getAttribute("dob") : "" %>" required>                    
                    <div class="field-error" id="dobError"></div>
                </div>
            </div>

            <!-- Phone & Email -->
            <div class="row mb-3">
                <div class="col-md-6">
                    <label>Phone Number <span class="required-star">*</span></label>
                    <div class="input-group">
                        <select class="form-select input-light" name="countryCode" style="max-width: 55px;" required>
                            <option value="+91">+91</option>
                            <option value="+1">+1</option>
                            <option value="+44">+44</option>
                            <option value="+61">+61</option>
                            <option value="+81">+81</option>
                            <option value="+971">+971</option>
                            <option value="+65">+65</option>
                        </select>
                        <input type="text" class="form-control input-light" name="Mobnbr" autocomplete="off" minlength="10" maxlength="10"
                            value="<%= session.getAttribute("Mobnbr") != null ? session.getAttribute("Mobnbr") : "" %>" required>                                           
                    </div>
                    <div class="field-error" id="phoneError"></div>
                </div>
                <div class="col-md-6">
                    <label>Email <span class="required-star">*</span></label>
                    <input type="email" class="form-control input-light" name="email" autocomplete="off" minlength="5" maxlength="40"
                        value="<%= session.getAttribute("email") != null ? session.getAttribute("email") : "" %>" required>                    
                    <div class="field-error" id="emailError"></div>
                </div>
            </div>

            <!-- Gender -->
            <div class="mb-3">
                <label>Gender <span class="required-star">*</span></label><br>
                <input type="radio" name="gender" value="M" <%= "M".equals(session.getAttribute("gender")) ? "checked" : "" %> required> Male
                <input type="radio" name="gender" value="F" class="ms-3" <%= "F".equals(session.getAttribute("gender")) ? "checked" : "" %>> Female
                <input type="radio" name="gender" value="T" class="ms-3" <%= "T".equals(session.getAttribute("gender")) ? "checked" : "" %>> Transgender
                <div class="field-error" id="genderError"></div>
            </div>            

            <!-- Address -->
            <div class="mb-3">
                <label>Address Line 1 <span class="required-star">*</span></label>
                <input type="text" class="form-control input-light" name="address1" autocomplete="off" minlength="1" maxlength="30"
                    value="<%= session.getAttribute("address1") != null ? session.getAttribute("address1") : "" %>" required>                
                <div class="field-error" id="address1Error"></div>
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
                    <label>Pincode <span class="required-star">*</span></label>
                    <input type="text" class="form-control input-light" name="pincode" autocomplete="off" minlength="6" maxlength="6"
                        value="<%= session.getAttribute("pincode") != null ? session.getAttribute("pincode") : "" %>" required>                    
                    <div class="field-error" id="pincodeError"></div>
                </div>
                <div class="col-md-4">
                    <label>City <span class="required-star">*</span></label>
                    <input type="text" class="form-control input-light" name="city" autocomplete="off" minlength="1" maxlength="30"
                        value="<%= session.getAttribute("city") != null ? session.getAttribute("city") : "" %>" required>                    
                    <div class="field-error" id="cityError"></div>
                </div>
            </div>

            <!-- State & Country -->
            <div class="row mb-3">
                <div class="col-md-6">
                    <label>State <span class="required-star">*</span></label>
                    <input type="text" class="form-control input-light" name="state" autocomplete="off" minlength="1" maxlength="30"
                        value="<%= session.getAttribute("state") != null ? session.getAttribute("state") : "" %>" required>                    
                    <div class="field-error" id="stateError"></div>
                </div>
                <div class="col-md-6">
                    <label>Country <span class="required-star">*</span></label>
                    <input type="text" class="form-control input-light" name="country" autocomplete="off" minlength="1" maxlength="30"
                        value="<%= session.getAttribute("country") != null ? session.getAttribute("country") : "" %>" required>                    
                    <div class="field-error" id="countryError"></div>
                </div>
            </div>

            <!-- Account Type & Currency -->
            <div class="row mb-3">
                <div class="col-md-6">
                    <label>Preferred Account Type <span class="required-star">*</span></label><br>
                    <input type="radio" name="accType" value="Savings" <%= "Savings".equals(session.getAttribute("accType")) ? "checked" : "" %> required> Savings
                    <input type="radio" name="accType" value="Current" class="ms-3" <%= "Current".equals(session.getAttribute("accType")) ? "checked" : "" %>> Current    
                    <div class="field-error" id="accTypeError"></div>
                </div>
                <div class="col-md-6">
                    <label>Preferred Currency <span class="required-star">*</span></label><br>
                    <input type="radio" name="currency" value="USD" onclick="toggleOtherCurrency()" <%= "USD".equals(session.getAttribute("currency")) ? "checked" : "" %> required> USD
                    <input type="radio" name="currency" value="INR" class="ms-3" onclick="toggleOtherCurrency()" <%= "INR".equals(session.getAttribute("currency")) ? "checked" : "" %>> INR
                    <input type="radio" name="currency" value="OTH" class="ms-3" onclick="toggleOtherCurrency()" <%= "OTH".equals(session.getAttribute("currency")) ? "checked" : "" %>> Other:
                    <input type="text" class="input-light ms-2" id="otherCurrencyInput" style="width: 120px; border: 1px solid #ccc;" name="otherCurrency" minlength="3" maxlength="3" 
                        value="<%= session.getAttribute("otherCurrency") != null ? session.getAttribute("otherCurrency") : "" %>" readonly>
                    <div class="field-error" id="currencyError"></div>
                    <div class="field-error" id="otherCurrencyError"></div>
                </div>
            </div>            

            <!-- ID Type & Number -->
            <div class="row mb-3">
                <div class="col-md-6">
                    <label>ID Type <span class="required-star">*</span></label>
                    <select class="form-control input-light" name="idType" required>
                        <option value="" disabled selected>Select ID Type</option>
                        <option value="Passport" <%= "Passport".equals(session.getAttribute("idType")) ? "selected" : "" %>>Passport</option>
                        <option value="Aadhaar Card" <%= "Aadhaar Card".equals(session.getAttribute("idType")) ? "selected" : "" %>>Aadhaar Card</option>
                        <option value="PAN Card" <%= "PAN Card".equals(session.getAttribute("idType")) ? "selected" : "" %>>PAN Card</option>
                        <option value="Driving License" <%= "Driving License".equals(session.getAttribute("idType")) ? "selected" : "" %>>Driving License</option>
                    </select>
                    <div class="field-error" id="idTypeError"></div>
                </div>
                <div class="col-md-6">
                    <label>ID Number <span class="required-star">*</span></label>
                    <input type="text" class="form-control input-light" name="idNumber" autocomplete="off" minlength="1" maxlength="20"
                        value="<%= session.getAttribute("idNumber") != null ? session.getAttribute("idNumber") : "" %>" required>
                    <div class="field-error" id="idNumberError"></div>
                </div>
            </div>

            <!-- Submit -->
            <div class="text-center mb-3">
                <button type="submit" class="btn btn-primary px-5">Submit Application</button>
            </div>
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

    // Toggle "Other Currency" input
    function toggleOtherCurrency() {
        const otherCurrencyInput = document.getElementById("otherCurrencyInput");
        const selected = document.querySelector('input[name="currency"]:checked');
        if (selected && selected.value === "OTH") {
            otherCurrencyInput.readOnly = false;
            otherCurrencyInput.required = true;
            otherCurrencyInput.focus();
        } else {
            otherCurrencyInput.readOnly = true;
            otherCurrencyInput.required = false;
            otherCurrencyInput.value = "";
        }
    }

    // Sequential inline validation
    const form = document.querySelector("form");
    form.addEventListener("submit", function(e) {
        document.querySelectorAll(".field-error").forEach(el => el.textContent = "");

        function showError(field, errorId, message) {
            document.getElementById(errorId).textContent = message;
            if (field) field.focus();
            e.preventDefault();
        }

        const fields = [
            { selector: "[name='Name']", errorId: "nameError", message: "Please enter full name" },
            { selector: "[name='dob']", errorId: "dobError", message: "Please select date of birth" },
            { selector: "[name='Mobnbr']", errorId: "phoneError", message: "Please enter phone number" },
            { selector: "[name='email']", errorId: "emailError", message: "Please enter email" },
            { selector: "input[name='gender']:checked", errorId: "genderError", message: "Please select gender" },
            { selector: "[name='address1']", errorId: "address1Error", message: "Please enter address" },
            { selector: "[name='pincode']", errorId: "pincodeError", message: "Please enter pincode" },
            { selector: "[name='city']", errorId: "cityError", message: "Please enter city" },
            { selector: "[name='state']", errorId: "stateError", message: "Please enter state" },
            { selector: "[name='country']", errorId: "countryError", message: "Please enter country" },
            { selector: "input[name='accType']:checked", errorId: "accTypeError", message: "Please select account type" },
            { selector: "input[name='currency']:checked", errorId: "currencyError", message: "Please select currency" },
            { selector: "[name='otherCurrency']", errorId: "otherCurrencyError", message: "Please enter currency code", condition: () => {
                const c = document.querySelector("input[name='currency']:checked");
                return c && c.value === "OTH" && document.querySelector("[name='otherCurrency']").value.trim() === "";
            }},
            { selector: "[name='idType']", errorId: "idTypeError", message: "Please select ID type" },
            { selector: "[name='idNumber']", errorId: "idNumberError", message: "Please enter ID number" }
        ];

        for (let f of fields) {
            let el = document.querySelector(f.selector);
            let invalid = f.condition ? f.condition() : !el || el.value.trim() === "";
            if (invalid) {
                showError(el, f.errorId, f.message);
                return; // stop at first error
            }
        }
    });

    // Clear error and move focus to next field
    const clearAndFocusNext = (currentSelector, nextSelector, errorId) => {
        const current = document.querySelector(currentSelector);
        const next = document.querySelector(nextSelector);
        current.addEventListener("change", () => {
            document.getElementById(errorId).textContent = "";
            if(next) next.focus();
        });
    }

    // Enhanced DOB → Phone inline validation
    const dobField = document.querySelector("[name='dob']");
    const phoneField = document.querySelector("[name='Mobnbr']");
    const phoneError = document.getElementById("phoneError");

    dobField.addEventListener("change", () => {
        document.getElementById("dobError").textContent = "";
        phoneField.focus();
        if (phoneField.value.trim() === "") {
            phoneError.textContent = "Please enter phone number";
        } else {
            phoneError.textContent = "";
        }
    });

    phoneField.addEventListener("input", () => {
        if (phoneField.value.trim() !== "") phoneError.textContent = "";
    });

    // Clear ID Type → ID Number inline validation
    const idTypeField = document.querySelector("[name='idType']");
    const idNumberField = document.querySelector("[name='idNumber']");
    const idNumberError = document.getElementById("idNumberError");

    idTypeField.addEventListener("change", () => {
        document.getElementById("idTypeError").textContent = "";
        idNumberField.focus();
        if (idNumberField.value.trim() === "") {
            idNumberError.textContent = "Please enter ID number";
        } else {
            idNumberError.textContent = "";
        }
    });

    idNumberField.addEventListener("input", () => {
        if (idNumberField.value.trim() !== "") idNumberError.textContent = "";
    });

    // Hide modal function
    function hideModal() {
        const modal = document.getElementById("responseModal");
        if (modal) {
            modal.classList.remove("show");
            modal.style.display = "none";
            const backdrop = document.querySelector(".modal-backdrop");
            if (backdrop) backdrop.remove();
        }
    }
</script>

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

</body>
</html>