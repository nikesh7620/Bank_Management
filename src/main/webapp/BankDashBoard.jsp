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
        response.sendRedirect(request.getContextPath() + "/Login.jsp");
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
        body { 
            background-color: #f8f9fa; 
            font-family: Arial, sans-serif; 
            margin:0; 
        }

        /* Sidebar styling */
        .sidebar { 
            height: 100vh; 
            width: 200px; 
            background-color: #000; /* Black sidebar */
            position: fixed; 
            top: 0; 
            left: 0; 
            padding-top: 60px; 
            overflow-x: hidden; 
            z-index: 999; 
            transition: 0.3s;
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
        .sidebar a:hover,
        .sidebar a.active {
             background-color: #0d6efd; /* Bootstrap blue */
             color: #fff;
        }

        /* Main content */
        .content { 
            max-width: 1200px; 
            margin-left: 200px; 
            padding: 20px; 
            transition: margin-left 0.3s;
        }

        /* Centered heading section without background */
        .heading-section {
            text-align: center;
            color: #000; /* Black text */
            padding: 20px 10px; /* Spacing around text */
            margin-bottom: 30px;
        }

        .heading-section h1 {
            font-size: 36px; /* Main header bigger */
            margin-bottom: 10px;
        }

        .heading-section h4 {
            font-size: 20px; /* Smaller than main header */
            margin: 0;
            font-weight: normal; /* Less bold */
        }

        /* Hamburger for mobile */
        .hamburger { 
            display: none; 
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

        @media (max-width: 768px) {
            .sidebar { 
                left: -200px; 
            }
            .sidebar.active { 
                left: 0; 
            }
            .content { 
                margin-left: 0; 
            }
            .content.shift { margin-left: 200px; }
            .hamburger { display: block; }
        }

        /* Table and layout styling */
        table { font-size: 14px; }
        .d-flex.justify-content-end.gap-2.mb-3 { flex-wrap: wrap; }
        .input-group { flex-wrap: wrap; }
    </style>
</head>

<body>

<!-- Sidebar -->
<i class="fas fa-bars hamburger" id="hamburgerBtn"></i>

<div class="sidebar" id="sidebar">
    <a href="LoadDashboardData"><i class="fas fa-home"></i>Dashboard</a>
    <a href="RegistrationForm.jsp"><i class="fas fa-user-plus"></i>Add New Client</a>
    <a href="DisplayClient.jsp"><i class="fas fa-users"></i>Display Client</a>
    <a href="Login.jsp"><i class="fas fa-sign-out-alt"></i>Logout</a>
</div>

<!-- Main Content -->
<div class="main content">

    <!-- Centered Heading -->
    <div class="heading-section">
        <h1>Saamsha Technologies</h1>
        <h4>Client Management System</h4>
    </div>
    
    <div class="d-flex justify-content-end gap-2 mb-3">
        <a href="<%= request.getContextPath() %>/RegistrationForm.jsp"
           class="btn btn-outline-primary px-4">
            <i class="fa fa-user-plus me-2"></i>Add New Client
        </a>

        <a href="<%= request.getContextPath() %>/DisplayClient.jsp"
           class="btn btn-outline-primary px-4">
            <i class="fa fa-users me-2"></i>Display Client
        </a>
    </div>
    
    <!-- Search -->
    <div class="mb-3" style="max-width: 400px;">
        <div class="input-group">
            <span class="input-group-text"><i class="fa fa-search"></i></span>
            <input type="text" id="searchInput" class="form-control"
                   placeholder="Search by account number" />
        </div>
    </div>

    <!-- Table -->
    <table id="accountsTable" class="table table-hover bg-white">
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
                        <span class="badge bg-danger">Inactive</span>
                    <%
                        }
                    %>
                </td>
            </tr>
        <%
                }
            } else {
        %>
            <tr class="text-center text-muted no-data">
                <td colspan="5">No client account activity available</td>
            </tr>
        <%
            }
        %>
        </tbody>
    </table>

    <!-- Pagination Controls -->
    <nav>
        <ul id="pagination" class="pagination justify-content-end"></ul>
    </nav>

</div>

<!-- Bootstrap JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

<script>
    // Hamburger toggle for mobile
    const hamburgerBtn = document.getElementById("hamburgerBtn");
    const sidebar = document.getElementById("sidebar");
    const contentDiv = document.querySelector('.content');

    hamburgerBtn.addEventListener("click", () => {
        sidebar.classList.toggle("active");
        contentDiv.classList.toggle("shift");
    });

    // Prevent back navigation issues
    window.addEventListener("pageshow", function (event) {
        if (event.persisted ||
            performance.getEntriesByType("navigation")[0].type === "back_forward") {
            window.location.reload();
        }
    });

    // Pagination and search
    const rowsPerPage = 5;
    let currentPage = 1;
    const table = document.getElementById("accountsTable");
    const tbody = table.querySelector("tbody");
    const allRows = Array.from(tbody.querySelectorAll("tr")).filter(r => !r.classList.contains("no-data"));
    const noDataRow = tbody.querySelector(".no-data");

    let filteredRows = [...allRows];

    function renderTablePage(page) {
        const pageCount = Math.ceil(filteredRows.length / rowsPerPage) || 1;

        currentPage = Math.min(Math.max(1, page), pageCount);

        allRows.forEach(row => row.style.display = "none");

        const startIndex = (currentPage - 1) * rowsPerPage;
        const endIndex = startIndex + rowsPerPage;

        for(let i = startIndex; i < endIndex && i < filteredRows.length; i++) {
            filteredRows[i].style.display = "";
        }

        if (filteredRows.length === 0) {
            if (noDataRow) noDataRow.style.display = "";
        } else {
            if (noDataRow) noDataRow.style.display = "none";
        }

        renderPagination(pageCount);
    }

    function renderPagination(pageCount) {
        const pagination = document.getElementById("pagination");
        pagination.innerHTML = "";

        const prevLi = document.createElement("li");
        prevLi.className = "page-item" + (currentPage === 1 ? " disabled" : "");
        const prevA = document.createElement("a");
        prevA.className = "page-link";
        prevA.href = "#";
        prevA.textContent = "Previous";
        prevA.onclick = e => { e.preventDefault(); if(currentPage > 1) renderTablePage(currentPage - 1); };
        prevLi.appendChild(prevA);
        pagination.appendChild(prevLi);

        for(let i = 1; i <= pageCount; i++) {
            const li = document.createElement("li");
            li.className = "page-item" + (i === currentPage ? " active" : "");
            const a = document.createElement("a");
            a.className = "page-link";
            a.href = "#";
            a.textContent = i;
            a.onclick = e => { e.preventDefault(); renderTablePage(i); };
            li.appendChild(a);
            pagination.appendChild(li);
        }

        const nextLi = document.createElement("li");
        nextLi.className = "page-item" + (currentPage === pageCount ? " disabled" : "");
        const nextA = document.createElement("a");
        nextA.className = "page-link";
        nextA.href = "#";
        nextA.textContent = "Next";
        nextA.onclick = e => { e.preventDefault(); if(currentPage < pageCount) renderTablePage(currentPage + 1); };
        nextLi.appendChild(nextA);
        pagination.appendChild(nextLi);
    }

    document.getElementById("searchInput").addEventListener("keyup", function() {
        const searchTerm = this.value.toLowerCase().trim();
        filteredRows = allRows.filter(row => {
            const accNo = row.cells[0].textContent.toLowerCase();
            return accNo.includes(searchTerm);
        });

        renderTablePage(1);
    });

    renderTablePage(currentPage);
</script>

</body>
</html>