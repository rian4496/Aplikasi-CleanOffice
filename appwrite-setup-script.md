# Appwrite Setup Script via MCP

## Prerequisites
- Appwrite Cloud Account: https://cloud.appwrite.io
- Project ID: `690dc074000d8971b247`
- Endpoint: `https://sgp.cloud.appwrite.io/v1`
- API Key dengan permission: `databases.write`, `collections.write`, `attributes.write`, `buckets.write`

---

## 🎯 Instructions for Claude Desktop with MCP

**Paste this entire guide into Claude Desktop conversation and ask:**

> "Please create the Appwrite database schema for CleanOffice project using the MCP tools. Here are the requirements:"

---

## Database Configuration

**Database ID**: `cleanoffice_db`
**Database Name**: `CleanOffice Database`

---

## Collections to Create

### 1. Users Collection

**Collection ID**: `users`
**Collection Name**: `Users`

**Attributes:**
```
1. userId (string, size: 36, required: true)
2. email (string, size: 255, required: true)
3. name (string, size: 255, required: true)
4. role (string, size: 50, required: true) - enum: employee, cleaner, admin
5. departmentId (string, size: 36, required: false)
6. departmentName (string, size: 255, required: false)
7. phoneNumber (string, size: 20, required: false)
8. profileImageUrl (string, size: 2000, required: false)
9. isActive (boolean, required: true, default: true)
10. createdAt (datetime, required: true)
11. updatedAt (datetime, required: false)
12. location (string, size: 255, required: false)
```

**Indexes:**
- `email_idx` on `email` (type: key, unique)
- `role_idx` on `role` (type: key)
- `department_idx` on `departmentId` (type: key)

**Permissions:**
- Read: `users` (any authenticated user)
- Create: `users`
- Update: `users`
- Delete: `admins` (team role)

---

### 2. Reports Collection

**Collection ID**: `reports`
**Collection Name**: `Reports`

**Attributes:**
```
1. reportId (string, size: 36, required: true)
2. userId (string, size: 36, required: true)
3. userName (string, size: 255, required: true)
4. departmentId (string, size: 36, required: false)
5. departmentName (string, size: 255, required: false)
6. location (string, size: 255, required: true)
7. title (string, size: 255, required: true)
8. description (string, size: 5000, required: true)
9. imageUrl (string, size: 2000, required: false)
10. status (string, size: 50, required: true) - enum: pending, assigned, in_progress, completed, verified, rejected
11. priority (string, size: 50, required: false)
12. cleanerId (string, size: 36, required: false)
13. cleanerName (string, size: 255, required: false)
14. completionImageUrl (string, size: 2000, required: false)
15. verifiedBy (string, size: 36, required: false)
16. verifiedByName (string, size: 255, required: false)
17. verificationNotes (string, size: 2000, required: false)
18. isUrgent (boolean, required: false, default: false)
19. date (datetime, required: true)
20. assignedAt (datetime, required: false)
21. startedAt (datetime, required: false)
22. completedAt (datetime, required: false)
23. verifiedAt (datetime, required: false)
24. deletedAt (datetime, required: false)
25. deletedBy (string, size: 36, required: false)
26. userEmail (string, size: 255, required: false)
```

**Indexes:**
- `user_idx` on `userId` (type: key)
- `cleaner_idx` on `cleanerId` (type: key)
- `status_idx` on `status` (type: key)
- `date_idx` on `date` (type: key, order: desc)
- `department_idx` on `departmentId` (type: key)
- `deleted_idx` on `deletedAt` (type: key)

**Permissions:**
- Read: `users`
- Create: `users`
- Update: `users`
- Delete: `admins`

---

### 3. Inventory Collection

**Collection ID**: `inventory`
**Collection Name**: `Inventory`

**Attributes:**
```
1. itemId (string, size: 36, required: true)
2. name (string, size: 255, required: true)
3. category (string, size: 100, required: true)
4. quantity (integer, required: true, min: 0)
5. unit (string, size: 50, required: true)
6. minStock (integer, required: true, min: 0)
7. location (string, size: 255, required: false)
8. imageUrl (string, size: 2000, required: false)
9. description (string, size: 2000, required: false)
10. lastRestocked (datetime, required: false)
11. createdAt (datetime, required: true)
12. updatedAt (datetime, required: false)
13. deletedAt (datetime, required: false)
```

**Indexes:**
- `category_idx` on `category` (type: key)
- `quantity_idx` on `quantity` (type: key)
- `deleted_idx` on `deletedAt` (type: key)

**Permissions:**
- Read: `users`
- Create: `users`
- Update: `users`
- Delete: `admins`

---

### 4. Requests Collection

**Collection ID**: `requests`
**Collection Name**: `Requests`

**Attributes:**
```
1. requestId (string, size: 36, required: true)
2. itemId (string, size: 36, required: true)
3. itemName (string, size: 255, required: true)
4. requestedBy (string, size: 36, required: true)
5. requestedByName (string, size: 255, required: true)
6. quantity (integer, required: true, min: 1)
7. reason (string, size: 2000, required: true)
8. status (string, size: 50, required: true) - enum: pending, approved, rejected, fulfilled
9. approvedBy (string, size: 36, required: false)
10. approvedByName (string, size: 255, required: false)
11. approvalNotes (string, size: 2000, required: false)
12. requestDate (datetime, required: true)
13. approvedAt (datetime, required: false)
14. fulfilledAt (datetime, required: false)
```

**Indexes:**
- `item_idx` on `itemId` (type: key)
- `user_idx` on `requestedBy` (type: key)
- `status_idx` on `status` (type: key)
- `date_idx` on `requestDate` (type: key, order: desc)

**Permissions:**
- Read: `users`
- Create: `users`
- Update: `users`
- Delete: `admins`

---

### 5. Notifications Collection

**Collection ID**: `notifications`
**Collection Name**: `Notifications`

**Attributes:**
```
1. notificationId (string, size: 36, required: true)
2. userId (string, size: 36, required: true)
3. title (string, size: 255, required: true)
4. body (string, size: 2000, required: true)
5. type (string, size: 50, required: true) - enum: report, inventory, request, system
6. data (string, size: 5000, required: false) - JSON payload
7. isRead (boolean, required: true, default: false)
8. createdAt (datetime, required: true)
```

**Indexes:**
- `user_idx` on `userId` (type: key)
- `type_idx` on `type` (type: key)
- `read_idx` on `isRead` (type: key)
- `date_idx` on `createdAt` (type: key, order: desc)

**Permissions:**
- Read: Document-level (only owner)
- Create: `users`
- Update: Document-level (only owner)
- Delete: Document-level (only owner)

---

### 6. Departments Collection

**Collection ID**: `departments`
**Collection Name**: `Departments`

**Attributes:**
```
1. departmentId (string, size: 36, required: true)
2. name (string, size: 255, required: true)
3. description (string, size: 2000, required: false)
4. headId (string, size: 36, required: false)
5. headName (string, size: 255, required: false)
6. isActive (boolean, required: true, default: true)
7. createdAt (datetime, required: true)
```

**Indexes:**
- `name_idx` on `name` (type: key, unique)
- `active_idx` on `isActive` (type: key)

**Permissions:**
- Read: `users`
- Create: `admins`
- Update: `admins`
- Delete: `admins`

---

### 7. Stock History Collection

**Collection ID**: `stock_history`
**Collection Name**: `Stock History`

**Attributes:**
```
1. historyId (string, size: 36, required: true)
2. itemId (string, size: 36, required: true)
3. itemName (string, size: 255, required: true)
4. action (string, size: 50, required: true) - enum: restock, usage, adjustment
5. quantityChange (integer, required: true)
6. quantityBefore (integer, required: true)
7. quantityAfter (integer, required: true)
8. userId (string, size: 36, required: true)
9. userName (string, size: 255, required: true)
10. notes (string, size: 2000, required: false)
11. createdAt (datetime, required: true)
```

**Indexes:**
- `item_idx` on `itemId` (type: key)
- `action_idx` on `action` (type: key)
- `date_idx` on `createdAt` (type: key, order: desc)

**Permissions:**
- Read: `users`
- Create: `users`
- Update: None (immutable)
- Delete: `admins`

---

## Storage Buckets to Create

### 1. Reports Bucket
- **Bucket ID**: `reports`
- **Bucket Name**: `Reports Images`
- **Max file size**: 5MB (5242880 bytes)
- **Allowed extensions**: `jpg`, `jpeg`, `png`, `webp`
- **Compression**: `gzip`
- **Encryption**: true
- **Antivirus**: true (if available)

**Permissions:**
- Read: `users`
- Create: `users`
- Update: Document-level (only owner)
- Delete: `admins`

### 2. Profiles Bucket
- **Bucket ID**: `profiles`
- **Bucket Name**: `Profile Pictures`
- **Max file size**: 2MB (2097152 bytes)
- **Allowed extensions**: `jpg`, `jpeg`, `png`, `webp`
- **Compression**: `gzip`
- **Encryption**: true
- **Antivirus**: true

**Permissions:**
- Read: `users`
- Create: `users`
- Update: Document-level (only owner)
- Delete: Document-level (only owner)

### 3. Inventory Bucket
- **Bucket ID**: `inventory`
- **Bucket Name**: `Inventory Images`
- **Max file size**: 5MB (5242880 bytes)
- **Allowed extensions**: `jpg`, `jpeg`, `png`, `webp`
- **Compression**: `gzip`
- **Encryption**: true
- **Antivirus**: true

**Permissions:**
- Read: `users`
- Create: `users`
- Update: `admins`
- Delete: `admins`

---

## Verification Checklist

After setup, verify:
- [ ] Database `cleanoffice_db` exists
- [ ] 7 collections created with correct attributes
- [ ] All indexes created
- [ ] 3 storage buckets created
- [ ] Permissions set correctly
- [ ] Test creating a document in `users` collection
- [ ] Test uploading a file to `reports` bucket

---

## Notes

1. **Permission format in Appwrite**:
   - `users` = role:all (all authenticated users)
   - `admins` = team:admins (create this team in Appwrite Console)

2. **Datetime format**: ISO 8601 string (e.g., `2024-01-20T10:30:00.000Z`)

3. **Document IDs**: Use Appwrite's `ID.unique()` for auto-generation

4. **Enum validation**: Appwrite doesn't have native enum support, so validation happens at app level

---

## After Setup Complete

Return to VSCode and tell me: **"Setup selesai"**

Then I will:
1. Update main.dart to initialize Appwrite
2. Update Riverpod providers
3. Create migration helpers
4. Test the integration
