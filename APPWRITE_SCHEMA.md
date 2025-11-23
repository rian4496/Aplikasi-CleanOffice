# Appwrite Database Schema

## Database Setup Guide

This document contains the complete database schema for migrating from Firebase to Appwrite.

### Step 1: Create Database

1. Go to Appwrite Console: https://cloud.appwrite.io
2. Navigate to **Databases**
3. Click **Create Database**
4. Database ID: `cleanoffice_db`
5. Name: `CleanOffice Database`

---

## Collections

### 1. Users Collection

**Collection ID**: `users`

**Attributes**:
```
- userId (string, 36, required) - Unique user ID
- email (string, 255, required) - User email
- name (string, 255, required) - Full name
- role (enum, required) - Values: employee, cleaner, admin
- departmentId (string, 36, optional) - Department ID
- departmentName (string, 255, optional) - Department name
- phoneNumber (string, 20, optional) - Phone number
- profileImageUrl (string, 2000, optional) - Profile photo URL
- isActive (boolean, required, default: true) - Account status
- createdAt (datetime, required) - Account creation time
- updatedAt (datetime, optional) - Last update time
```

**Indexes**:
- `email_idx` on `email` (unique)
- `role_idx` on `role`
- `department_idx` on `departmentId`

**Permissions**:
- Read: `users`
- Create: `users`
- Update: `users`
- Delete: `admins`

---

### 2. Reports Collection

**Collection ID**: `reports`

**Attributes**:
```
- reportId (string, 36, required) - Report ID (auto-generated)
- userId (string, 36, required) - Employee who created report
- userName (string, 255, required) - Employee name
- departmentId (string, 36, optional) - Department ID
- departmentName (string, 255, optional) - Department name
- location (string, 255, required) - Cleaning location
- description (string, 5000, required) - Problem description
- imageUrl (string, 2000, optional) - Problem photo URL
- status (enum, required) - Values: pending, assigned, in_progress, completed, verified, rejected
- priority (enum, optional) - Values: low, medium, high, urgent
- cleanerId (string, 36, optional) - Assigned cleaner ID
- cleanerName (string, 255, optional) - Assigned cleaner name
- completionImageUrl (string, 2000, optional) - Completion proof photo
- verifiedBy (string, 36, optional) - Admin who verified
- verifiedByName (string, 255, optional) - Admin name
- verificationNotes (string, 2000, optional) - Verification notes
- date (datetime, required) - Report creation date
- assignedAt (datetime, optional) - Assignment timestamp
- startedAt (datetime, optional) - Work start timestamp
- completedAt (datetime, optional) - Completion timestamp
- verifiedAt (datetime, optional) - Verification timestamp
- deletedAt (datetime, optional) - Soft delete timestamp
- deletedBy (string, 36, optional) - User who deleted
```

**Indexes**:
- `user_idx` on `userId`
- `cleaner_idx` on `cleanerId`
- `status_idx` on `status`
- `date_idx` on `date` (DESC)
- `department_idx` on `departmentId`
- `deleted_idx` on `deletedAt`

**Permissions**:
- Read: `users`
- Create: `users`
- Update: `users`
- Delete: `admins`

---

### 3. Inventory Collection

**Collection ID**: `inventory`

**Attributes**:
```
- itemId (string, 36, required) - Item ID
- name (string, 255, required) - Item name
- category (string, 100, required) - Category
- quantity (integer, required) - Current stock
- unit (string, 50, required) - Unit (pcs, box, liter, etc)
- minStock (integer, required) - Minimum stock threshold
- location (string, 255, optional) - Storage location
- imageUrl (string, 2000, optional) - Item photo
- description (string, 2000, optional) - Item description
- lastRestocked (datetime, optional) - Last restock date
- createdAt (datetime, required) - Creation time
- updatedAt (datetime, optional) - Last update time
- deletedAt (datetime, optional) - Soft delete
```

**Indexes**:
- `category_idx` on `category`
- `quantity_idx` on `quantity`
- `deleted_idx` on `deletedAt`

**Permissions**:
- Read: `users`
- Create: `users`
- Update: `users`
- Delete: `admins`

---

### 4. Requests Collection

**Collection ID**: `requests`

**Attributes**:
```
- requestId (string, 36, required) - Request ID
- itemId (string, 36, required) - Inventory item ID
- itemName (string, 255, required) - Item name
- requestedBy (string, 36, required) - User ID who requested
- requestedByName (string, 255, required) - User name
- quantity (integer, required) - Requested quantity
- reason (string, 2000, required) - Request reason
- status (enum, required) - Values: pending, approved, rejected, fulfilled
- approvedBy (string, 36, optional) - Admin who approved
- approvedByName (string, 255, optional) - Admin name
- approvalNotes (string, 2000, optional) - Approval notes
- requestDate (datetime, required) - Request date
- approvedAt (datetime, optional) - Approval timestamp
- fulfilledAt (datetime, optional) - Fulfillment timestamp
```

**Indexes**:
- `item_idx` on `itemId`
- `user_idx` on `requestedBy`
- `status_idx` on `status`
- `date_idx` on `requestDate` (DESC)

**Permissions**:
- Read: `users`
- Create: `users`
- Update: `users`
- Delete: `admins`

---

### 5. Notifications Collection

**Collection ID**: `notifications`

**Attributes**:
```
- notificationId (string, 36, required) - Notification ID
- userId (string, 36, required) - Target user ID
- title (string, 255, required) - Notification title
- body (string, 2000, required) - Notification message
- type (enum, required) - Values: report, inventory, request, system
- data (string, 5000, optional) - JSON data payload
- isRead (boolean, required, default: false) - Read status
- createdAt (datetime, required) - Creation time
```

**Indexes**:
- `user_idx` on `userId`
- `type_idx` on `type`
- `read_idx` on `isRead`
- `date_idx` on `createdAt` (DESC)

**Permissions**:
- Read: Own documents only
- Create: `users`
- Update: Own documents only
- Delete: Own documents only

---

### 6. Departments Collection

**Collection ID**: `departments`

**Attributes**:
```
- departmentId (string, 36, required) - Department ID
- name (string, 255, required) - Department name
- description (string, 2000, optional) - Description
- headId (string, 36, optional) - Department head user ID
- headName (string, 255, optional) - Department head name
- isActive (boolean, required, default: true) - Active status
- createdAt (datetime, required) - Creation time
```

**Indexes**:
- `name_idx` on `name` (unique)
- `active_idx` on `isActive`

**Permissions**:
- Read: `users`
- Create: `admins`
- Update: `admins`
- Delete: `admins`

---

### 7. Stock History Collection

**Collection ID**: `stock_history`

**Attributes**:
```
- historyId (string, 36, required) - History ID
- itemId (string, 36, required) - Inventory item ID
- itemName (string, 255, required) - Item name
- action (enum, required) - Values: restock, usage, adjustment
- quantityChange (integer, required) - Quantity delta (+/-)
- quantityBefore (integer, required) - Stock before change
- quantityAfter (integer, required) - Stock after change
- userId (string, 36, required) - User who made change
- userName (string, 255, required) - User name
- notes (string, 2000, optional) - Change notes
- createdAt (datetime, required) - Change timestamp
```

**Indexes**:
- `item_idx` on `itemId`
- `action_idx` on `action`
- `date_idx` on `createdAt` (DESC)

**Permissions**:
- Read: `users`
- Create: `users`
- Update: None (immutable)
- Delete: `admins`

---

## Storage Buckets

### 1. Reports Bucket

**Bucket ID**: `reports`
- Max file size: 5MB
- Allowed file types: image/jpeg, image/png, image/webp
- Permissions:
  - Read: `users`
  - Create: `users`
  - Update: Own files only
  - Delete: Own files + `admins`

### 2. Profiles Bucket

**Bucket ID**: `profiles`
- Max file size: 2MB
- Allowed file types: image/jpeg, image/png, image/webp
- Permissions:
  - Read: `users`
  - Create: `users`
  - Update: Own files only
  - Delete: Own files only

### 3. Inventory Bucket

**Bucket ID**: `inventory`
- Max file size: 5MB
- Allowed file types: image/jpeg, image/png, image/webp
- Permissions:
  - Read: `users`
  - Create: `users`
  - Update: `admins`
  - Delete: `admins`

---

## Setup Checklist

- [ ] Create database `cleanoffice_db`
- [ ] Create collection `users` with attributes and indexes
- [ ] Create collection `reports` with attributes and indexes
- [ ] Create collection `inventory` with attributes and indexes
- [ ] Create collection `requests` with attributes and indexes
- [ ] Create collection `notifications` with attributes and indexes
- [ ] Create collection `departments` with attributes and indexes
- [ ] Create collection `stock_history` with attributes and indexes
- [ ] Create bucket `reports`
- [ ] Create bucket `profiles`
- [ ] Create bucket `inventory`
- [ ] Set proper permissions for all collections and buckets

---

## Notes

1. **User Roles**: Use Appwrite's built-in role system:
   - `users` = All authenticated users
   - `admins` = Team with admin role (create this in Appwrite Console)

2. **Soft Delete**: Items with `deletedAt` field are soft deleted (not permanently removed)

3. **Realtime**: All collections support realtime subscriptions

4. **Data Migration**: After setup, you can export Firebase data and import to Appwrite using custom scripts
