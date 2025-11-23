# Manual Setup Guide - Appwrite Console

⏱️ **Estimated time: 15-20 minutes**

## 🎯 Quick Setup Checklist

Database `cleanoffice_db` sudah dibuat ✅

Now create:
- [ ] 7 Collections
- [ ] 3 Storage Buckets

---

## 📦 COLLECTION 1: users

1. Go to: [Appwrite Console](https://cloud.appwrite.io/console/project-690dc074000d8971b247/databases/database-cleanoffice_db)
2. Click **"Create Collection"**
3. Collection ID: `users` | Name: `Users` → Click **Create**
4. Click **"Attributes"** tab → Add attributes:

| Key | Type | Size | Required | Default |
|-----|------|------|----------|---------|
| userId | String | 36 | ✅ | - |
| email | String | 255 | ✅ | - |
| name | String | 255 | ✅ | - |
| role | String | 50 | ✅ | - |
| departmentId | String | 36 | ❌ | - |
| departmentName | String | 255 | ❌ | - |
| phoneNumber | String | 20 | ❌ | - |
| profileImageUrl | String | 2000 | ❌ | - |
| isActive | Boolean | - | ✅ | true |
| createdAt | DateTime | - | ✅ | - |
| updatedAt | DateTime | - | ❌ | - |
| location | String | 255 | ❌ | - |

5. Click **"Indexes"** tab → Add indexes:
   - `email_idx`: email (Unique, ASC)
   - `role_idx`: role (Key, ASC)
   - `department_idx`: departmentId (Key, ASC)

6. Click **"Settings"** tab → Set permissions:
   - Add permission: **Any** → Read, Create, Update
   - Click **Update**

---

## 📦 COLLECTION 2: reports

Collection ID: `reports` | Name: `Reports`

**Attributes:**

| Key | Type | Size | Required |
|-----|------|------|----------|
| reportId | String | 36 | ✅ |
| userId | String | 36 | ✅ |
| userName | String | 255 | ✅ |
| userEmail | String | 255 | ❌ |
| departmentId | String | 36 | ❌ |
| departmentName | String | 255 | ❌ |
| location | String | 255 | ✅ |
| title | String | 255 | ✅ |
| description | String | 5000 | ✅ |
| imageUrl | String | 2000 | ❌ |
| status | String | 50 | ✅ |
| priority | String | 50 | ❌ |
| cleanerId | String | 36 | ❌ |
| cleanerName | String | 255 | ❌ |
| completionImageUrl | String | 2000 | ❌ |
| verifiedBy | String | 36 | ❌ |
| verifiedByName | String | 255 | ❌ |
| verificationNotes | String | 2000 | ❌ |
| isUrgent | Boolean | - | ❌ (default: false) |
| date | DateTime | - | ✅ |
| assignedAt | DateTime | - | ❌ |
| startedAt | DateTime | - | ❌ |
| completedAt | DateTime | - | ❌ |
| verifiedAt | DateTime | - | ❌ |
| deletedAt | DateTime | - | ❌ |
| deletedBy | String | 36 | ❌ |

**Indexes:**
- `user_idx`: userId
- `cleaner_idx`: cleanerId
- `status_idx`: status
- `date_idx`: date (DESC)
- `department_idx`: departmentId
- `deleted_idx`: deletedAt

**Permissions:** Any → Read, Create, Update

---

## 📦 COLLECTION 3: inventory

Collection ID: `inventory` | Name: `Inventory`

**Attributes:**

| Key | Type | Size | Required |
|-----|------|------|----------|
| itemId | String | 36 | ✅ |
| name | String | 255 | ✅ |
| category | String | 100 | ✅ |
| quantity | Integer | - | ✅ (min: 0) |
| unit | String | 50 | ✅ |
| minStock | Integer | - | ✅ (min: 0) |
| location | String | 255 | ❌ |
| imageUrl | String | 2000 | ❌ |
| description | String | 2000 | ❌ |
| lastRestocked | DateTime | - | ❌ |
| createdAt | DateTime | - | ✅ |
| updatedAt | DateTime | - | ❌ |
| deletedAt | DateTime | - | ❌ |

**Indexes:**
- `category_idx`: category
- `quantity_idx`: quantity
- `deleted_idx`: deletedAt

**Permissions:** Any → Read, Create, Update

---

## 📦 COLLECTION 4: requests

Collection ID: `requests` | Name: `Requests`

**Attributes:**

| Key | Type | Size | Required |
|-----|------|------|----------|
| requestId | String | 36 | ✅ |
| itemId | String | 36 | ✅ |
| itemName | String | 255 | ✅ |
| requestedBy | String | 36 | ✅ |
| requestedByName | String | 255 | ✅ |
| quantity | Integer | - | ✅ (min: 1) |
| reason | String | 2000 | ✅ |
| status | String | 50 | ✅ |
| approvedBy | String | 36 | ❌ |
| approvedByName | String | 255 | ❌ |
| approvalNotes | String | 2000 | ❌ |
| requestDate | DateTime | - | ✅ |
| approvedAt | DateTime | - | ❌ |
| fulfilledAt | DateTime | - | ❌ |

**Indexes:**
- `item_idx`: itemId
- `user_idx`: requestedBy
- `status_idx`: status
- `date_idx`: requestDate (DESC)

**Permissions:** Any → Read, Create, Update

---

## 📦 COLLECTION 5: notifications

Collection ID: `notifications` | Name: `Notifications`

**Attributes:**

| Key | Type | Size | Required |
|-----|------|------|----------|
| notificationId | String | 36 | ✅ |
| userId | String | 36 | ✅ |
| title | String | 255 | ✅ |
| body | String | 2000 | ✅ |
| type | String | 50 | ✅ |
| data | String | 5000 | ❌ |
| isRead | Boolean | - | ✅ (default: false) |
| createdAt | DateTime | - | ✅ |

**Indexes:**
- `user_idx`: userId
- `type_idx`: type
- `read_idx`: isRead
- `date_idx`: createdAt (DESC)

**Permissions:** Any → Read, Create, Update

---

## 📦 COLLECTION 6: departments

Collection ID: `departments` | Name: `Departments`

**Attributes:**

| Key | Type | Size | Required |
|-----|------|------|----------|
| departmentId | String | 36 | ✅ |
| name | String | 255 | ✅ |
| description | String | 2000 | ❌ |
| headId | String | 36 | ❌ |
| headName | String | 255 | ❌ |
| isActive | Boolean | - | ✅ (default: true) |
| createdAt | DateTime | - | ✅ |

**Indexes:**
- `name_idx`: name (Unique)
- `active_idx`: isActive

**Permissions:** Any → Read, Create, Update

---

## 📦 COLLECTION 7: stock_history

Collection ID: `stock_history` | Name: `Stock History`

**Attributes:**

| Key | Type | Size | Required |
|-----|------|------|----------|
| historyId | String | 36 | ✅ |
| itemId | String | 36 | ✅ |
| itemName | String | 255 | ✅ |
| action | String | 50 | ✅ |
| quantityChange | Integer | - | ✅ |
| quantityBefore | Integer | - | ✅ |
| quantityAfter | Integer | - | ✅ |
| userId | String | 36 | ✅ |
| userName | String | 255 | ✅ |
| notes | String | 2000 | ❌ |
| createdAt | DateTime | - | ✅ |

**Indexes:**
- `item_idx`: itemId
- `action_idx`: action
- `date_idx`: createdAt (DESC)

**Permissions:** Any → Read, Create, Update

---

## 🗂️ STORAGE BUCKETS

Go to: **Storage** in left sidebar

### BUCKET 1: reports
1. Click **"Create bucket"**
2. Bucket ID: `reports` | Name: `Reports Images`
3. Max file size: `5242880` (5MB)
4. Allowed extensions: `jpg,jpeg,png,webp`
5. Compression: ✅ gzip
6. Encryption: ✅ Enabled
7. Permissions: Any → Read, Create
8. Click **Create**

### BUCKET 2: profiles
- Bucket ID: `profiles` | Name: `Profile Pictures`
- Max file size: `2097152` (2MB)
- Allowed extensions: `jpg,jpeg,png,webp`
- Compression, Encryption: ✅ Enabled
- Permissions: Any → Read, Create

### BUCKET 3: inventory
- Bucket ID: `inventory` | Name: `Inventory Images`
- Max file size: `5242880` (5MB)
- Allowed extensions: `jpg,jpeg,png,webp`
- Compression, Encryption: ✅ Enabled
- Permissions: Any → Read, Create

---

## ✅ Verification

After setup, verify:
1. Database has 7 collections ✅
2. Each collection has all attributes ✅
3. All indexes created ✅
4. Storage has 3 buckets ✅
5. Permissions set to "Any" for read/create ✅

**When done, tell me: "Setup selesai"**

---

## 💡 Tips

- **Copas attributes**: Copy table ke Excel, paste 1-by-1ke Appwrite
- **Shortcut**: Use Tab key to navigate between fields
- **Save time**: Create all attributes first, then indexes, then permissions
- **Error?**: Screenshot and send to me

**Butuh waktu ~15 menit kalau fokus!** 🚀
