# Product Specification: CleanOffice Application

## 1. Project Overview
**CleanOffice** is a comprehensive facility management and SIM-ASET ERP application built with Flutter (Web & Mobile). It manages cleaning services, asset procurement, maintenance, disposal, and employee service requests.

## 2. Technical Stack
- **Framework**: Flutter (Dart)
- **Backend / Database**: Supabase (PostgreSQL, Auth, Realtime)
- **State Management**: Riverpod (Hooks Riverpod + Flutter Riverpod)
- **Routing**: GoRouter (Role-based navigation)
- **UI System**: Material Design 3 (Custom AppTheme)
- **Platforms**: Mobile (Android/iOS) and Web (Admin Dashboard)

## 3. Core Features & Capabilities

### 3.1 Authentication & User Management
- **Login**: Email/password authentication via Supabase Auth.
- **Role Management**: 
    - **Admin**: Full access to dashboard, reports, assets, personnel.
    - **Employee**: Can submit requests and view status.
    - **Cleaner**: Receives tasks, updates status, and uploads completion proofs.
- **Account Verification**: Admin flow to verify new staff accounts.

### 3.2 Report & Request Management
- **Cleaning Reports**: Cleaners submit reports with before/after photos.
- **Service Requests**: Employees request cleaning services for specific locations.
- **Workflow**: `Pending` -> `Assigned` -> `In Progress` -> `Completed` -> `Verified` (Admin).
- **Validation**: Admin verifies completed reports (Accept/Reject with notes).

### 3.3 Asset & Inventory Management (SIM-ASET)
- **Inventory Tracking**: Manage cleaning supplies and equipment stock.
- **Transactions**: 
    - **Procurement**: Purchase requests and approval workflow.
    - **Maintenance**: Asset repair and service logging.
    - **Disposal**: Asset written-off/disposal workflow.
- **QR Scanning**: (Placeholder/Planned) for quick asset lookup.

### 3.4 Admin Dashboard & Analytics
- **Unified Dashboard**: 
    - Real-time statistics (Active cleaners, pending reports, urgent tasks).
    - Charts (Weekly performance, asset status distribution).
- **Exporting**: Generate PDF/Excel reports for management review.
- **Monitoring**: Live activity feed of system events.

### 3.5 Personnel Management
- **Cleaner Profiles**: Track performance, ratings, and task history.
- **Employee Profiles**: Manage access and department information.

## 4. Testing Requirements (TestSprite)

### 4.1 Critical User Flows to Test
1. **Login Flow**:
   - Valid credentials (login success).
   - Invalid credentials (error handling).
   - Session persistence check.

2. **Transaction E2E (Employee -> Cleaner -> Admin)**:
   - Employee submits a request.
   - Cleaner receives and accepts request.
   - Cleaner completes request (upload photo).
   - Admin verifies and approves the report.

3. **Asset Management**:
   - CRUD operations on Inventory.
   - Submitting a Procurement Request.

### 4.2 Test Data Strategy
- Use Supabase local instance or staging project.
- Seed data: 1 Admin, 1 Cleaner, 1 Employee user.
- Seed master data: 5 Assets, 3 Organizations.

### 4.3 UI/UX Verification
- **Responsiveness**: Check layout on Mobile vs Web Desktop.
- **Empty States**: Verify "No Data" widgets appear correctly.
- **Loading States**: Verify skeletons/spinners during async operations.

## 5. File Structure Reference
(See `testsprite_tests/tmp/code_summary.json` for detailed file mapping)
