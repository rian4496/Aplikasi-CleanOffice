# Appwrite MCP Prompts for CleanOffice Setup

## Pre-requisites
- Appwrite MCP server configured in Claude Code
- Project ID: `690dc074000d8971b247`
- Endpoint: `https://sgp.cloud.appwrite.io/v1`

---

## Prompt 1: Create Database

```
Create a new database in my Appwrite project with ID "cleanoffice_db" and name "CleanOffice Database"
```

---

## Prompt 2: List Databases (Verify)

```
List all databases in my Appwrite project
```

---

## Prompt 3: Create Collections

### Users Collection
```
Create a new collection in database "cleanoffice_db" with:
- Collection ID: "users"
- Collection Name: "Users"

Add these attributes:
- userId (string, size 36, required)
- email (string, size 255, required)
- name (string, size 255, required)
- role (string, size 50, required)
- departmentId (string, size 36, optional)
- departmentName (string, size 255, optional)
- phoneNumber (string, size 20, optional)
- profileImageUrl (string, size 2000, optional)
- isActive (boolean, required, default true)
- createdAt (datetime, required)
- updatedAt (datetime, optional)
- location (string, size 255, optional)

Create these indexes:
- Index "email_idx" on "email" attribute (unique)
- Index "role_idx" on "role" attribute
- Index "department_idx" on "departmentId" attribute
```

### Reports Collection
```
Create a new collection in database "cleanoffice_db" with:
- Collection ID: "reports"
- Collection Name: "Reports"

Add these attributes:
- reportId (string, size 36, required)
- userId (string, size 36, required)
- userName (string, size 255, required)
- userEmail (string, size 255, optional)
- departmentId (string, size 36, optional)
- departmentName (string, size 255, optional)
- location (string, size 255, required)
- title (string, size 255, required)
- description (string, size 5000, required)
- imageUrl (string, size 2000, optional)
- status (string, size 50, required)
- priority (string, size 50, optional)
- cleanerId (string, size 36, optional)
- cleanerName (string, size 255, optional)
- completionImageUrl (string, size 2000, optional)
- verifiedBy (string, size 36, optional)
- verifiedByName (string, size 255, optional)
- verificationNotes (string, size 2000, optional)
- isUrgent (boolean, optional, default false)
- date (datetime, required)
- assignedAt (datetime, optional)
- startedAt (datetime, optional)
- completedAt (datetime, optional)
- verifiedAt (datetime, optional)
- deletedAt (datetime, optional)
- deletedBy (string, size 36, optional)

Create these indexes:
- Index "user_idx" on "userId" attribute
- Index "cleaner_idx" on "cleanerId" attribute
- Index "status_idx" on "status" attribute
- Index "date_idx" on "date" attribute (descending order)
- Index "department_idx" on "departmentId" attribute
- Index "deleted_idx" on "deletedAt" attribute
```

### Inventory Collection
```
Create a new collection in database "cleanoffice_db" with:
- Collection ID: "inventory"
- Collection Name: "Inventory"

Add these attributes:
- itemId (string, size 36, required)
- name (string, size 255, required)
- category (string, size 100, required)
- quantity (integer, required)
- unit (string, size 50, required)
- minStock (integer, required)
- location (string, size 255, optional)
- imageUrl (string, size 2000, optional)
- description (string, size 2000, optional)
- lastRestocked (datetime, optional)
- createdAt (datetime, required)
- updatedAt (datetime, optional)
- deletedAt (datetime, optional)

Create these indexes:
- Index "category_idx" on "category" attribute
- Index "quantity_idx" on "quantity" attribute
- Index "deleted_idx" on "deletedAt" attribute
```

### Requests Collection
```
Create a new collection in database "cleanoffice_db" with:
- Collection ID: "requests"
- Collection Name: "Requests"

Add these attributes:
- requestId (string, size 36, required)
- itemId (string, size 36, required)
- itemName (string, size 255, required)
- requestedBy (string, size 36, required)
- requestedByName (string, size 255, required)
- quantity (integer, required)
- reason (string, size 2000, required)
- status (string, size 50, required)
- approvedBy (string, size 36, optional)
- approvedByName (string, size 255, optional)
- approvalNotes (string, size 2000, optional)
- requestDate (datetime, required)
- approvedAt (datetime, optional)
- fulfilledAt (datetime, optional)

Create these indexes:
- Index "item_idx" on "itemId" attribute
- Index "user_idx" on "requestedBy" attribute
- Index "status_idx" on "status" attribute
- Index "date_idx" on "requestDate" attribute (descending order)
```

### Notifications Collection
```
Create a new collection in database "cleanoffice_db" with:
- Collection ID: "notifications"
- Collection Name: "Notifications"

Add these attributes:
- notificationId (string, size 36, required)
- userId (string, size 36, required)
- title (string, size 255, required)
- body (string, size 2000, required)
- type (string, size 50, required)
- data (string, size 5000, optional)
- isRead (boolean, required, default false)
- createdAt (datetime, required)

Create these indexes:
- Index "user_idx" on "userId" attribute
- Index "type_idx" on "type" attribute
- Index "read_idx" on "isRead" attribute
- Index "date_idx" on "createdAt" attribute (descending order)
```

### Departments Collection
```
Create a new collection in database "cleanoffice_db" with:
- Collection ID: "departments"
- Collection Name: "Departments"

Add these attributes:
- departmentId (string, size 36, required)
- name (string, size 255, required)
- description (string, size 2000, optional)
- headId (string, size 36, optional)
- headName (string, size 255, optional)
- isActive (boolean, required, default true)
- createdAt (datetime, required)

Create these indexes:
- Index "name_idx" on "name" attribute (unique)
- Index "active_idx" on "isActive" attribute
```

### Stock History Collection
```
Create a new collection in database "cleanoffice_db" with:
- Collection ID: "stock_history"
- Collection Name: "Stock History"

Add these attributes:
- historyId (string, size 36, required)
- itemId (string, size 36, required)
- itemName (string, size 255, required)
- action (string, size 50, required)
- quantityChange (integer, required)
- quantityBefore (integer, required)
- quantityAfter (integer, required)
- userId (string, size 36, required)
- userName (string, size 255, required)
- notes (string, size 2000, optional)
- createdAt (datetime, required)

Create these indexes:
- Index "item_idx" on "itemId" attribute
- Index "action_idx" on "action" attribute
- Index "date_idx" on "createdAt" attribute (descending order)
```

---

## Prompt 4: Show Collections (Verify)

```
Show me the collections in my database "cleanoffice_db"
```

---

## Prompt 5: Create Storage Buckets

### Reports Bucket
```
Create a storage bucket in my Appwrite project with:
- Bucket ID: "reports"
- Bucket Name: "Reports Images"
- Max file size: 5242880 bytes (5MB)
- Allowed file extensions: jpg, jpeg, png, webp
- Compression: gzip
- Encryption: enabled
- Antivirus: enabled

Set permissions to allow authenticated users to read and create files
```

### Profiles Bucket
```
Create a storage bucket in my Appwrite project with:
- Bucket ID: "profiles"
- Bucket Name: "Profile Pictures"
- Max file size: 2097152 bytes (2MB)
- Allowed file extensions: jpg, jpeg, png, webp
- Compression: gzip
- Encryption: enabled
- Antivirus: enabled

Set permissions to allow authenticated users to read and create files
```

### Inventory Bucket
```
Create a storage bucket in my Appwrite project with:
- Bucket ID: "inventory"
- Bucket Name: "Inventory Images"
- Max file size: 5242880 bytes (5MB)
- Allowed file extensions: jpg, jpeg, png, webp
- Compression: gzip
- Encryption: enabled
- Antivirus: enabled

Set permissions to allow authenticated users to read and create files
```

---

## Prompt 6: List Buckets (Verify)

```
List all storage buckets in my Appwrite project
```

---

## Verification Steps

After running all prompts, verify:

1. Database "cleanoffice_db" exists
2. 7 collections created (users, reports, inventory, requests, notifications, departments, stock_history)
3. All attributes created correctly
4. All indexes created
5. 3 storage buckets created (reports, profiles, inventory)

You can verify in Appwrite Console: https://cloud.appwrite.io/console/project-690dc074000d8971b247

---

## Tips

- Run prompts **one by one** and wait for each to complete
- If you get an error, check the error message and adjust
- MCP might ask for confirmation for destructive operations
- You can list/show resources at any time to check progress
