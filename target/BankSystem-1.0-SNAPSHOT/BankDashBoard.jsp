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
        .pagination {
            justify-content: end;
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
    
    <div class="d-flex justify-content-end gap-2 mb-3">
        <a href="<%= request.getContextPath() %>/RegisterationForm.jsp"
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
        <ul id="pagination" class="pagination"></ul>
    </nav>

</div>

<!-- Bootstrap JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

<script>
    // Prevent back navigation issues
    window.addEventListener("pageshow", function (event) {
        if (event.persisted ||
            performance.getEntriesByType("navigation")[0].type === "back_forward") {
            window.location.reload();
        }
    });

    const rowsPerPage = 5;
    let currentPage = 1;
    const table = document.getElementById("accountsTable");
    const tbody = table.querySelector("tbody");
    const allRows = Array.from(tbody.querySelectorAll("tr")).filter(r => !r.classList.contains("no-data"));
    const noDataRow = tbody.querySelector(".no-data");

    // Rows after filtering by search term
    let filteredRows = [...allRows];

    function renderTablePage(page) {
        const pageCount = Math.ceil(filteredRows.length / rowsPerPage) || 1;

        currentPage = Math.min(Math.max(1, page), pageCount);

        // Hide all rows first
        allRows.forEach(row => row.style.display = "none");

        // Show the rows for the current page from filteredRows
        const startIndex = (currentPage - 1) * rowsPerPage;
        const endIndex = startIndex + rowsPerPage;

        for(let i = startIndex; i < endIndex && i < filteredRows.length; i++) {
            filteredRows[i].style.display = "";
        }

        // Show no-data row if no results
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

        // Previous Button
        const prevLi = document.createElement("li");
        prevLi.className = "page-item" + (currentPage === 1 ? " disabled" : "");
        const prevA = document.createElement("a");
        prevA.className = "page-link";
        prevA.href = "#";
        prevA.textContent = "Previous";
        prevA.onclick = e => { e.preventDefault(); if(currentPage > 1) renderTablePage(currentPage - 1); };
        prevLi.appendChild(prevA);
        pagination.appendChild(prevLi);

        // Page Numbers
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

        // Next Button
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

    // Search by Account Number
    document.getElementById("searchInput").addEventListener("keyup", function() {
        const searchTerm = this.value.toLowerCase().trim();
        filteredRows = allRows.filter(row => {
            const accNo = row.cells[0].textContent.toLowerCase();
            return accNo.includes(searchTerm);
        });

        renderTablePage(1);  // reset to page 1 after filtering
    });

    // Initial render
    renderTablePage(currentPage);
</script>

</body>
</html>
