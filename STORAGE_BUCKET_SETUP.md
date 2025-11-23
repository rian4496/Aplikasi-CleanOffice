# Storage Bucket Setup - Single Bucket Solution

## ⚠️ Free Tier Limit

Appwrite Cloud Free tier only allows **1 storage bucket**.

## ✅ Solution: Use Folder Structure

We use **1 bucket** with folder organization:
- `reports/` - Report images
- `profiles/` - Profile pictures
- `inventory/` - Inventory images

---

## 🗂️ Create Storage Bucket

### Step 1: Go to Storage
1. Open [Appwrite Console](https://cloud.appwrite.io/console/project-690dc074000d8971b247)
2. Click **Storage** in left sidebar

### Step 2: Create Bucket
1. Click **"Create bucket"**
2. Fill in:
   - **Bucket ID**: `cleanoffice_storage`
   - **Name**: `CleanOffice Storage`

### Step 3: Configure Settings
- **Max file size**: `5242880` bytes (5MB)
- **Allowed file extensions**: `jpg`, `jpeg`, `png`, `webp`
- **Compression**: ✅ gzip
- **Encryption**: ✅ Enabled
- **Antivirus**: ✅ Enabled (if available)

### Step 4: Set Permissions
Click **"Settings"** tab:
1. Click **"Add role"**
2. Select **"Any"** (all authenticated users)
3. Check: ✅ **Read**, ✅ **Create**
4. Click **Update**

### Step 5: Verify
- Bucket `cleanoffice_storage` should appear in Storage list
- Permissions show "Any" with Read & Create access

---

## 📂 How Folder Structure Works

Files will be automatically organized by folder prefix in filename:

**Examples:**
```
reports/user123_1234567890.jpg
profiles/user456_0987654321.jpg
inventory/inv_1122334455.jpg
```

The app will handle this automatically - you don't need to create folders manually!

---

## ✅ Done!

After creating this bucket, tell me: **"Bucket sudah dibuat"**

Then we can continue with the integration!
