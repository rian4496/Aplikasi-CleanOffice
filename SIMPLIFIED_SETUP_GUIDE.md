# Simplified Setup Guide - Appwrite Console

⏱️ **Estimated time: 10-12 minutes** (Reduced from 20!)

## 🎯 What We Use

✅ **Appwrite System Fields** (automatic):
- `$id` - Document ID (replaces custom IDs like reportId, itemId, etc.)
- `$createdAt` - Creation timestamp
- `$updatedAt` - Update timestamp

⚠️ **Exception for `users` collection**:
- Keep `uid` field (sync with Appwrite Auth Account ID)
- Keep `joinDate` field (separate from $createdAt for business logic)

❌ **No need for**: reportId, itemId, etc. (use `$id` instead)

---

## 📦 COLLECTION 1: users

**Collection ID**: `users` | **Name**: `Users`

**Attributes** (13 fields):

| Key | Type | Size | Required | Default |
|-----|------|------|----------|---------|
| uid | String | 36 | ✅ | - |
| displayName | String | 255 | ✅ | - |
| email | Email | - | ✅ | - |
| photoURL | URL | - | ❌ | - |
| phoneNumber | String | 20 | ❌ | - |
| role | Enum | - | ✅ | employee |
| joinDate | DateTime | - | ✅ | - |
| departmentId | String | 36 | ❌ | - |
| staffId | String | 50 | ❌ | - |
| status | Enum | - | ✅ | active |
| location | String | 255 | ❌ | - |
| deletedAt | DateTime | - | ❌ | - |
| deletedBy | String | 36 | ❌ | - |

**Enum values**:
- `role`: admin, cleaner, employee
- `status`: active, inactive, deleted

**Indexes** (7 indexes):
- `uid_idx`: uid (type: unique, order: ASC)
- `idx_email`: email (type: unique, order: ASC)
- `role_idx`: role (type: key, order: ASC)
- `department_idx`: departmentId (type: key, order: ASC)
- `status_idx`: status (type: key, order: ASC)
- `status_joinDate_idx`: status, joinDate (type: key, orders: ASC, DESC) *composite*
- `role_joinDate_idx`: role, joinDate (type: key, orders: ASC, DESC) *composite*

**Permissions**: Any → Read, Create, Update

---

## 📦 COLLECTION 2: reports

**Collection ID**: `reports` | **Name**: `Reports`

**Attributes** (20 fields):

| Key | Type | Size | Required | Default |
|-----|------|------|----------|---------|
| userId | String | 36 | ✅ | - |
| userName | String | 255 | ✅ | - |
| userEmail | Email | - | ❌ | - |
| departmentId | String | 36 | ❌ | - |
| departmentName | String | 255 | ❌ | - |
| location | String | 255 | ✅ | - |
| title | String | 255 | ✅ | - |
| description | String | 5000 | ✅ | - |
| imageUrl | URL | - | ❌ | - |
| status | Enum | - | ❌ | pending |
| cleanerId | String | 36 | ❌ | - |
| cleanerName | String | 255 | ❌ | - |
| completionImageUrl | URL | - | ❌ | - |
| verifiedBy | String | 36 | ❌ | - |
| verifiedByName | String | 255 | ❌ | - |
| verificationNotes | String | 2000 | ❌ | - |
| isUrgent | Boolean | - | ❌ | false |
| date | DateTime | - | ✅ | - |
| assignedAt | DateTime | - | ❌ | - |
| startedAt | DateTime | - | ❌ | - |
| completedAt | DateTime | - | ❌ | - |
| verifiedAt | DateTime | - | ❌ | - |
| deletedAt | DateTime | - | ❌ | - |
| deletedBy | String | 36 | ❌ | - |

**Enum values**:
- `status`: pending, assigned, in_progress, completed, verified, rejected

**Indexes** (8 indexes):
- `user_idx`: userId (type: key, order: ASC)
- `cleaner_idx`: cleanerId (type: key, order: ASC)
- `status_idx`: status (type: key, order: ASC)
- `date_idx`: date (type: key, order: DESC)
- `department_idx`: departmentId (type: key, order: ASC)
- `status_date_idx`: status, date (type: key, orders: ASC, DESC) *composite*
- `cleaner_status_idx`: cleanerId, status (type: key, orders: ASC, ASC) *composite*
- `user_date_idx`: userId, date (type: key, orders: ASC, DESC) *composite*

**Permissions**: Any → Read, Create, Update

**Note**: Using soft delete pattern (Update with deletedAt field) instead of hard delete for audit trail.

---

## 📦 COLLECTION 3: inventory

**Collection ID**: `inventory` | **Name**: `Inventory`

**Attributes** (10 fields):

| Key | Type | Size | Required | Default |
|-----|------|------|----------|---------|
| name | String | 255 | ✅ | - |
| category | String | 100 | ✅ | - |
| quantity | Integer | - | ❌ (min: 0) | 0 |
| unit | String | 50 | ✅ | - |
| minStock | Integer | - | ❌ (min: 0) | 0 |
| location | String | 255 | ❌ | - |
| imageUrl | URL | - | ❌ | - |
| description | String | 2000 | ❌ | - |
| lastRestocked | DateTime | - | ❌ | - |
| deletedAt | DateTime | - | ❌ | - |

**Indexes** (4 indexes):
- `category_idx`: category (type: key, order: ASC)
- `idx_quantity`: quantity (type: key, order: ASC)
- `idx_category_quantity`: category, quantity (type: key, orders: ASC, ASC) *composite*
- `idx_quantity_minStock`: quantity, minStock (type: key, orders: ASC, ASC) *composite*

**Permissions**: Any → Read, Create, Update

---

## 📦 COLLECTION 4: stock_requests

**Collection ID**: `stock_requests` | **Name**: `Stock Requests`

**Purpose**: Request barang inventori (contoh: "sabun habis", "butuh marker 5 buah")

**Workflow**: Employee request → Admin approve/reject/cancelled by employee → Admin fulfill

**Cancel Rules**: Employee can cancel only when status = pending

**Attributes** (13 fields):

| Key | Type | Size | Required | Default |
|-----|------|------|----------|---------|
| itemId | String | 36 | ✅ | - |
| itemName | String | 255 | ✅ | - |
| requestedBy | String | 36 | ✅ | - |
| requestedByName | String | 255 | ✅ | - |
| quantity | Integer | - | ❌ (min: 1) | 1 |
| reason | String | 2000 | ✅ | - |
| status | Enum | - | ❌ | pending |
| approvedBy | String | 36 | ❌ | - |
| approvedByName | String | 255 | ❌ | - |
| approvalNotes | String | 2000 | ❌ | - |
| requestDate | DateTime | - | ✅ | - |
| approvedAt | DateTime | - | ❌ | - |
| fulfilledAt | DateTime | - | ❌ | - |

**Enum values**:
- `status`: pending, approved, rejected, fulfilled, cancelled

**Indexes** (7 indexes):
- `idx_item`: itemId (type: key, order: ASC)
- `idx_user`: requestedBy (type: key, order: ASC)
- `idx_status`: status (type: key, order: ASC)
- `idx_date`: requestDate (type: key, order: DESC)
- `idx_status_date`: status, requestDate (type: key, orders: ASC, DESC) *composite*
- `idx_user_status`: requestedBy, status (type: key, orders: ASC, ASC) *composite*
- `idx_item_status`: itemId, status (type: key, orders: ASC, ASC) *composite*

**Permissions**: Any → Read, Create, Update

---

## 📦 COLLECTION 5: notifications

**Collection ID**: `notifications` | **Name**: `Notifications`

**Attributes** (6 fields):

| Key | Type | Size | Required | Default |
|-----|------|------|----------|---------|
| userId | String | 36 | ✅ | - |
| title | String | 255 | ✅ | - |
| body | String | 2000 | ✅ | - |
| type | String | 50 | ✅ | - |
| data | String | 5000 | ❌ | - |
| isRead | Boolean | - | ❌ | false |

**Indexes** (5 indexes):
- `idx_user`: userId (type: key, order: ASC)
- `idx_type`: type (type: key, order: ASC)
- `idx_read`: isRead (type: key, order: ASC)
- `idx_user_read`: userId, isRead (type: key, orders: ASC, ASC) *composite*
- `idx_user_type`: userId, type (type: key, orders: ASC, ASC) *composite*

**Permissions**: Any → Read, Create, Update

---

## 📦 COLLECTION 6: departments

**Collection ID**: `departments` | **Name**: `Departments`

**Attributes** (5 fields):

| Key | Type | Size | Required | Default |
|-----|------|------|----------|---------|
| name | String | 255 | ✅ | - |
| description | String | 2000 | ❌ | - |
| headId | String | 36 | ❌ | - |
| headName | String | 255 | ❌ | - |
| isActive | Boolean | - | ❌ | true |

**Indexes** (2 indexes):
- `idx_name`: name (type: unique, order: ASC)
- `idx_active`: isActive (type: key, order: ASC)

**Permissions**: Any → Read, Create, Update

---

## 📦 COLLECTION 7: stock_history

**Collection ID**: `stock_history` | **Name**: `Stock History`

**Attributes** (9 fields):

| Key | Type | Size | Required |
|-----|------|------|----------|
| itemId | String | 36 | ✅ |
| itemName | String | 255 | ✅ |
| action | String | 50 | ✅ |
| quantityChange | Integer | - | ✅ |
| quantityBefore | Integer | - | ✅ |
| quantityAfter | Integer | - | ✅ |
| userId | String | 36 | ✅ |
| userName | String | 255 | ✅ |
| notes | String | 2000 | ❌ |

**Indexes** (4 indexes):
- `idx_item`: itemId (type: key, order: ASC)
- `idx_action`: action (type: key, order: ASC)
- `idx_item_action`: itemId, action (type: key, orders: ASC, ASC) *composite*
- `idx_user`: userId (type: key, order: ASC)

**Permissions**: Any → Read, Create, Update

---

## 📦 COLLECTION 8: service_requests

**Collection ID**: `service_requests` | **Name**: `Service Requests`

**Purpose**: Request layanan personal (contoh: "angkat galon", "bersihkan mobil saya")

**Workflow**: Employee request → Cleaner self-assign/assigned → Cleaner work → Complete

**Attributes** (18 fields):

| Key | Type | Size | Required | Default |
|-----|------|------|----------|---------|
| location | String | 255 | ✅ | - |
| description | String | 5000 | ✅ | - |
| isUrgent | Boolean | - | ❌ | false |
| preferredDateTime | DateTime | - | ❌ | - |
| requestedBy | String | 36 | ✅ | - |
| requestedByName | String | 255 | ✅ | - |
| requestedByRole | String | 20 | ✅ | - |
| assignedTo | String | 36 | ❌ | - |
| assignedToName | String | 255 | ❌ | - |
| assignedAt | DateTime | - | ❌ | - |
| assignedBy | String | 20 | ❌ | - |
| status | Enum | - | ❌ | pending |
| imageUrl | URL | - | ❌ | - |
| completionImageUrl | URL | - | ❌ | - |
| completionNotes | String | 2000 | ❌ | - |
| startedAt | DateTime | - | ❌ | - |
| completedAt | DateTime | - | ❌ | - |
| deletedAt | DateTime | - | ❌ | - |
| deletedBy | String | 36 | ❌ | - |

**Enum values**:
- `status`: pending, assigned, in_progress, completed, cancelled

**Indexes** (7 indexes):
- `idx_requester`: requestedBy (type: key, order: ASC)
- `idx_cleaner`: assignedTo (type: key, order: ASC)
- `idx_status`: status (type: key, order: ASC)
- `idx_urgent`: isUrgent (type: key, order: DESC)
- `idx_status_created`: status, $createdAt (type: key, orders: ASC, DESC) *composite*
- `idx_cleaner_status`: assignedTo, status (type: key, orders: ASC, ASC) *composite*
- `idx_requester_status`: requestedBy, status (type: key, orders: ASC, ASC) *composite*

**Permissions**: Any → Read, Create, Update

**Note**: Private visibility - only requester, assigned cleaner, and admin can see each request.

---

## 🗂️ STORAGE BUCKET

**Bucket ID**: `cleanoffice_storage` | **Name**: `CleanOffice Storage`

1. Go to **Storage** → **Create bucket**
2. Settings:
   - Max file size: `5242880` (5MB)
   - Extensions: `jpg,jpeg,png,webp`
   - Compression: ✅ gzip
   - Encryption: ✅ Enabled
3. Permissions: Any → Read, Create

---

## ✅ Verification

- [ ] 8 collections created
- [ ] All attributes added (match with existing models!)
- [ ] All indexes created
- [ ] 1 storage bucket created
- [ ] Permissions set

**Total attributes**: ~104 fields across 8 collections
**Total indexes**: ~44 indexes (includes composite indexes for query optimization)

**Breakdown**:
- users: 13 fields, 7 indexes (2 composite)
- reports: 20 fields, 8 indexes (3 composite)
- inventory: 10 fields, 4 indexes (2 composite)
- stock_requests: 13 fields, 7 indexes (3 composite)
- notifications: 6 fields, 5 indexes (2 composite)
- departments: 5 fields, 2 indexes
- stock_history: 9 fields, 4 indexes (1 composite)
- service_requests: 18 fields, 7 indexes (3 composite)

**Notes**:
- Using Appwrite's proper data types (Email, URL, Enum) for better validation!
- Composite indexes optimize common query patterns (filter + sort, filter + filter)
- **stock_requests** = Request barang inventori (sabun habis, butuh marker)
- **service_requests** = Request layanan personal (angkat galon, bersihkan mobil)

After done, tell me: **"Setup selesai"**
