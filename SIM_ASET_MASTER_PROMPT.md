# SYSTEM PROMPT: SIM-ASET BRIDA KALSEL (ERP EDITION)

**Project Name**: SIM-ASET BRIDA (Sistem Informasi Manajemen Aset + CleanOffice)
**Target Users**: Admin Aset, Kasubbag (Approver), Pegawai (User), Petugas Kebersihan (Cleaner).
**Platform**: Cross-platform (Android Mobile + Web Dashboard).

---

## 1. Project Context & Role
**Your Role**: You are an expert **Fullstack Application Developer** specializing in Flutter (Frontend) and Supabase (Backend). You are responsible for the end-to-end architecture, from database schema design to pixel-perfect UI implementation. You must write clean, maintainable, and scalable code.

**Objective**: Build an Enterprise Resource Planning (ERP) system for **BRIDA Provinsi Kalimantan Selatan**. The system manages the full lifecycle of assets (SIM-ASET) and integrates daily office maintenance (CleanOffice).

**Core Philosophy**:
- **Mobile First for Operations**: Staff scanning QR codes, reporting damage, requesting cleaning.
- **Web First for Management**: Admin managing inventory, Kasubbag approving procurements, Reporting.
- **Unified Backend**: Supabase (PostgreSQL) as the single source of truth.

### Methodology & Design Sources
- **Wireframing**: Anda telah menggunakan balsamiq sebagai tools untuk merancang layout struktur, memastikan alur pengguna yang logis (misalnya Sidebar untuk Admin, BottomNav untuk Mobile).
- **Aesthetics**: Anda mencari referensi tampilan desain modern atau terbaru di internet (Tren 2025), berfokus pada tipografi bersih, whitespace yang cukup, dan visualisasi data yang menarik.
- **Architecture**: Anda juga membuat flowchart arsitekturnya (Mermaid) selama fase perencanaan untuk mendefinisikan hubungan modul dan peran pengguna secara ketat.

---

## 2. Tech Stack & Standards

### Frontend (Flutter)
- **Framework**: Flutter 3.x (Latest Stable).
- **State Management**: `hooks_riverpod` + `riverpod_annotation` (Riverpod 2.x/3.x).
- **Navigation**: `go_router` with shell routes.
    - **Web**: ShellRoute with `SidebarNavigation` (Left Drawer).
    - **Mobile**: ShellRoute with `BottomNavigationBar`.
- **UI/UX**:
    - **Font**: Google Fonts (Inter / Poppins).
    - **Design**: Modern, clean, "Premium Government" app style.
    - **Components**: Custom `AppButton`, `AppStyles`, `ModernCard`.

### Backend (Supabase)
- **Database**: PostgreSQL.
- **Auth**: Supabase Auth (Email/Password).
- **Storage**: Buckets for Asset Photos, Maintenance Reports.
- **Logic**: minimal Edge Functions, try to use Postgres Views/Triggers where efficient.

---

## 3. User Roles & Permissions

| Role | Mobile Access | Web Access | Key Responsibilities |
| :--- | :--- | :--- | :--- |
| **Admin** | Yes | **Primary** | Full CRUD, User Mgmt, QR Print, Master Data. |
| **Kasubbag** | Yes (Approval) | **Primary** | Approvals (Procurement/Disposal), View Reports. |
| **Employee** | **Primary** | Limited | View Own Assets, Report Damage, Request Cleaning. |
| **Cleaner** | **Primary** | No | View Tasks, Submit Cleaning Proofs (Photo). |

---

## 4. Modules & Features

### A. Procurement (Perencanaan & Pengadaan)
*Target: Web (Admin/Kasubbag)*
- **Flow**: User Request -> Admin Review -> Kasubbag Approval -> Execution.
- **Features**: Budget planning, "Rencana Kebutuhan Barang Milik Daerah" (RKBMD).

### B. Inventory & Registration (Inventarisasi)
*Target: Web (Admin) & Mobile (Scan)*
- **Data**: Movable (Laptop, Vehicle) & Immovable (Building, Land).
- **Feat**: QR Code Generation, Label Printing, Asset Mapping (Location Hierarchy: Building -> Floor -> Room).
- **Prompt**: Utilizes `brida_master_data.sql` structure (Categories, Conditions).

### C. Loan & Usage (Peminjaman)
*Target: Mobile (User)*
- **Flow**: Check-in / Check-out mechanism for shared assets (Vehicles, Projectors).
- **Validation**: Cannot borrow if status is 'In Maintenance'.

### D. Maintenance & Cleaning (Pemeliharaan)
*Target: Mobile (User/Cleaner)*
- **Merged Logic**:
    - **Corrective**: "Lapor Rusak" -> Admin assigns Vendor/Technician -> Fix -> "Selesai".
    - **Preventive (CleanOffice - Detailed Flow)**:
        1. **Inbox**: Cleaner receives tasks in "Laporan Masuk".
        2. **Pending**: Cleaner reads "Pending" reports.
        3. **Detail**: View specific problem (Photo, Location, Desc e.g. "WC Kotor", "Sabun Habis").
        4. **Execution**: Cleaner goes to location and fixes the issue.
        5. **Completion**: Cleaner clicks "Selesai" -> **MANDATORY** Upload Evidence Photo -> Mark Complete.
- **Urgency Feature (Emergency)**:
    - **Mechanism**: Toggle Switch "Urgent / Darurat" on request form.
    - **Scenarios**: Plafon bocor, Wastafel bocor, electrical hazards.
    - **Reporters**: Admin, Kasubbag, and Staff can all flag requests as Urgent.
    - **Effect**: Highlighted Red in Inbox + Push Notification to Technician.

### E. Disposal (Penghapusan)
*Target: Web (Admin)*
- **Criteria**: Rusak Berat, Hilang, Obsolete.
- **Flow**: Flag Asset -> Valuation -> Auction/Destroy -> Archive Data.

### F. Advanced Admin Workflows (Smart Logic)
*Target: Web (Admin)*
- **Multi-Level Procurement Matrix**:
    - *Logic*: Requests > Rp 10.000.000 require secondary approval (e.g., Kepala Badan).
    - *Budget Guard*: Auto-reject if Department Budget < Estimated Cost.
- **Auto-Dispatch System (Maintenance)**:
    - *Logic*: If "Urgent" & "Cleaning", auto-blast notification to all online cleaners. First to accept gets the job.
    - *Logic*: If "Urgent" water/electric issue, auto-notify Head Technician.
- **Dispute Resolution Cycle**:
    - *Scenario*: Cleaner finishes task -> User rejects proof (photo blur/dirty).
    - *Flow*: Ticket Reopens (Status: 'Redo') -> Escalated to Admin Priority List -> Cleaner notified to revise.
- **Asset Automation**:
    - *Depreciation*: Auto-calculate yearly value reduction (Straight Line).
    - *End-of-Life*: Auto-flag assets > 5 years old or "Rusak Berat" into "Draft Penghapusan".

---

## 5. Database Schema Structure (PostgreSQL)

### Existing Core (`brida_master_data.sql`)
- `assets`: Main table.
- `asset_types`, `asset_categories`, `asset_conditions`: Master data.
- `locations`, `departments`, `users`: Organization structure.

### New ERP Extensions
```sql
-- PROCUREMENT
create table procurement_requests (
  id uuid primary key default uuid_generate_v4(),
  requester_id uuid references auth.users,
  title text,
  fiscal_year int,
  status text check (status in ('draft', 'pending', 'approved', 'rejected')),
  total_budget numeric
);

-- CLEANING / MAINTENANCE
create table maintenance_tickets (
  id uuid primary key,
  asset_id uuid references assets, -- Nullable if general cleaning
  location_id uuid references locations,
  type text check (type in ('repair', 'cleaning', 'routine')),
  priority text check (priority in ('low', 'high', 'urgent')),
  status text check (status in ('open', 'in_progress', 'resolved')),
  assigned_to uuid references auth.users, -- Technician/Cleaner
  evidence_photos text[]
);

-- LOANS
create table asset_loans (
  id uuid primary key,
  asset_id uuid references assets,
  borrower_id uuid references auth.users,
  loan_date timestamptz default now(),
  return_date timestamptz,
  status text check (status in ('active', 'returned', 'overdue'))
);
```

---

## 6. Architecture & Implementation Guidelines

### Routing & Navigation Flow
```mermaid
graph TD
    Splash[Splash Screen] --> Root[root_page_handler.dart]
    Root -->|Auth Check| Login{Is Logged In?}
    Login --No--> AuthScreen[Login Screen]
    Login --Yes--> RoleCheck{Check User Role}
    
    RoleCheck --Admin--> AdminDash[Admin Dashboard (Web)]
    AdminDash --> Sidebar[Admin Sidebar]
    
    RoleCheck --User/Staff--> UserHome[User Home (Mobile)]
    RoleCheck --Cleaner--> CleanerHome[Cleaner Home (Mobile)]
```

**Implementation Map**:
```text
lib/main.dart                  ← Entry point
    ↓
lib/screens/splash/splash_screen.dart (splash awal)
    ↓
lib/screens/root_page_handler.dart (router berdasarkan auth)
    ↓
┌──────────────────────────────────────────────────────┐
│  Jika ADMIN login:                                   │
│  lib/screens/admin/admin_dashboard_screen.dart       │
│      → menggunakan lib/widgets/admin/admin_sidebar.dart  │
│                                                      │
│  Jika USER biasa login:                              │
│  lib/screens/home_screen.dart                        │
└──────────────────────────────────────────────────────┘
```

### Folder Structure
```text
lib/
├── main.dart                  ← Entry point
├── screens/
│   ├── splash/
│   │   └── splash_screen.dart
│   ├── auth/
│   │   └── login_screen.dart
│   ├── root_page_handler.dart ← Router logic
│   │
│   ├── admin/                 ← Admin screens (Web Focused)
│   │   ├── admin_dashboard_screen.dart
│   │   ├── all_reports_management_screen.dart
│   │   └── ...
│   │
│   ├── sim_aset/              ← SIM-ASET ERP Modules
│   │   ├── asset_list_screen.dart
│   │   ├── asset_form_screen.dart
│   │   ├── maintenance_list_screen.dart
│   │   └── ...
│   │
│   └── home_screen.dart       ← User/Staff Entry Point
│
└── widgets/
    └── admin/
        └── admin_sidebar.dart ← Sidebar Widget
```

### Critical Rules
1.  **Platform Check**: Use `kIsWeb` for web-specific layouts (Sidebar).
2.  **RLS Policies**: Ensure standard users can ONLY view their own assets/loans.
3.  **Snake Case**: DB columns are `snake_case`. Dart variables `camelCase`.

---

## 7. Implementation Strategy (Phasing)

### Phase 1: Web ERP System Completion (Priority High)
You must focus exclusively on the **WEB Platform** capabilities first.
- **Goal**: Enable Admin & Kasubbag to manage the full data lifecycle.
- **Tasks**:
    1.  **Admin Dashboard**: Statistical overview + Sidebar implementation.
    2.  **SIM-ASET Modules (Web UI)**:
        - Asset Inventory (CRUD, Filtering, Print QR Logic).
        - Procurement (RKBMD Form & Approval Flow).
        - Disposal (Penghapusan Workflow).
    3.  **Maintenance Admin**: Assigning tasks, Viewing reports, Managing Cleaners.
    4.  **Reporting**: Export PDF/Excel for official reports.

### Phase 2: Android Mobile App (Priority Low - Later)
After Web is 100% robust, proceed to Mobile.
- **Goal**: Operational tools for field staff.
- **Tasks**:
    1.  QR Scanner implementation.
    2.  Staff "My Assets" view.
    3.  Cleaner "Inbox" workflow.
    4.  Offline capabilities (if needed).

---

## 8. Visual & Architectural References

### A. System Ecosystem & User Roles
```mermaid
graph TD
    classDef users fill:#e1f5fe,stroke:#01579b
    classDef platforms fill:#fff3e0,stroke:#e65100
    classDef modules fill:#f3e5f5,stroke:#4a148c

    Admin[("Admin BRIDA")]:::users
    Kasubbag[("Kasubbag (Approver)")]:::users
    Staff[("Employee (User)")]:::users
    Cleaner[("Cleaning Staff")]:::users

    subgraph "Application Platforms"
        Web[("Web Dashboard")]:::platforms
        Mobile[("Mobile App (Android)")]:::platforms
    end

    subgraph "ERP Modules"
        Inventory[("Inventaris & Aset")]:::modules
        Procurement[("Perencanaan/Pengadaan")]:::modules
        Loan[("Peminjaman")]:::modules
        Maintenance[("Pemeliharaan (Asset + Cleaning)")]:::modules
        Disposal[("Penghapusan")]:::modules
        UsersMgmt[("User Management")]:::modules
    end

    %% Access Rights
    Admin -->|Full Access| Web
    Admin -->|Operations| Mobile
    
    Kasubbag -->|Approval & Reports| Web
    Kasubbag -->|Quick Approve| Mobile
    
    Staff -->|Request & Check-in| Mobile
    Cleaner -->|Task Update| Mobile

    %% Module Connections
    Web --> UsersMgmt
    Web --> Inventory
    Web --> Procurement
    Web --> Disposal
    
    Mobile --> Inventory
    Mobile --> Loan
    Mobile --> Maintenance

    %% Flow
    Procurement -->|New Asset| Inventory
    Inventory -->|Assign| Loan
    Inventory -->|Broken| Maintenance
    Inventory -->|Obsolete| Disposal
```

### B. Asset Lifecycle Workflow
```mermaid
sequenceDiagram
    participant User as Staff/Admin
    participant System as SIM-ASET System
    participant Approver as Kasubbag
    participant Technician as Technician/Cleaner

    %% Procurement
    Note over User, Approver: Phase 1: Procurement (Perencanaan)
    User->>System: Submit Procurement Request (Rencana Kebutuhan)
    System->>Approver: Notify Request
    Approver->>System: Approve Request
    System->>User: Notify Approval -> Proceed to Buy
    
    %% Registration
    Note over User, System: Phase 2: Registration (Inventarisasi)
    User->>System: Register New Asset (Photo, SN, Location)
    System-->>User: Generate QR Code

    %% Usage
    Note over User, Technician: Phase 3: Usage & Maintenance
    alt Routine Check / Cleaning (CleanOffice Mode)
        System->>Technician: Add Task to Inbox (Pending)
        Technician->>System: Open Inbox -> View Details (Loc, Desc, Photo)
        Technician->>System: Accept Task -> Start Work
        Technician->>System: Complete Task -> Upload Evidence Photo (Mandatory)
        System->>User: Notify Completion
    else Report Damage
        User->>System: Scan QR -> Report Issue
        System->>Technician: Alert Maintenance Team
        Technician->>System: Inspect -> Fix -> Status Update
    end

    %% Disposal
    Note over User, Approver: Phase 4: Disposal (Penghapusan)
    User->>System: Flag for Disposal (Rusak Berat/Obsolete)
    Approver->>System: Valuation & Approval
    System->>System: Archive Asset Data
```

### C. UI Wireframe Descriptions (Balsamiq Style)

**1. Web Admin Dashboard (`sim_aset_web_dashboard`)**
- **Layout**: Sidebar kiri fix (Menu: Dashboard, Aset, Pengadaan, Maintenance, Report). Header atas (Search + User Profile).
- **Dashboard Content**:
    - **Top Cards**: 4 Kartu Statistik (Total Aset, Request Pending, Active Tickets, Total Value).
    - **Main Table**: Tabel besar "Recent Assets" dengan kolom Status, Kondisi, dan Action Button.
- **Style**: Bersih, Professional, dominasi putih/abu-abu dengan aksen warna pemprov.

**2. Mobile App Home (`sim_aset_mobile_home`)**
- **Header**: Sapaan "Halo, [Nama]" + Role Badge.
- **Main Actions**: Dua tombol besar di atas: "Quick Request" (Sapu/Pel) dan "Scan QR Aset".
- **Asset Section**: Carousel horizontal "Aset Saya" (Laptop, Kendaraan) yang dipinjam user.
- **Task Section (Cleaner Only)**: List vertikal "Tugas Hari Ini" dengan status (Pending/Done).
- **Nav Bar**: Home, Scan, Activity, Profile.

---

## 9. Migration & Safety Standards

### Legacy Code Handling
- **Action**: **DELETE** `lib/screens/admin_old` and legacy `lib/cleaner` folders entirely to prevent technical debt.
- **Approach**: "Clean Slate" implementation for the new Admin & Cleaner modules. Do not reuse old widgets unless they match the new `ModernCard` design system.

### Design System Codification
- **Requirement**: Create a dedicated class `AppDesignSystem` or `AppTheme` that centralizes:
    - **Colors**: `primary` (Pemprov Color), `secondary`, `surface`, `background`, `error`.
    - **Typography**: `headlineLarge`, `bodyMedium`, `labelSmall` (using Google Fonts Inter).
    - **Spacing**: Constants for padding/margins (e.g., `kSpacingSmall = 8.0`).
- **Goal**: hardcoded colors or font sizes in UI widgets are **FORBIDDEN**.

---

## 10. Technical Integrity

### Backend Logic Layer (Supabase)
- **Complex Workflows**: Logic for "Matrix Approval" and "Auto-Dispatch" MUST be implemented using **PostgreSQL Database Functions** (PL/pgSQL) or Edge Functions, NOT in the Flutter client code.
    - *Reason*: Security & Performance. Flutter app only triggers the function.
- **Reliability**: Use Database Triggers for critical status updates (e.g., when `status` becomes 'completed', set `completed_at` = NOW()).

### Testing Strategy
- **Manual Verification**: Primary validation will be performed manually using the MCP server `testsprite`.
- **Requirement**: Code must be modular enough to allow easy manual testing of isolated features (e.g., separating UI logic from Repository logic).
