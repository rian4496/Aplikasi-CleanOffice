# Appwrite Chat Collections Setup Guide

Since Appwrite CLI v12.0.0 has changed the permissions system, it's easier to create collections via the Appwrite Console.

## Access Appwrite Console

1. Go to: https://sgp.cloud.appwrite.io/console
2. Select your project: **690dc074000d8971b247**
3. Go to **Databases** → Select database: **691868630007af45a94b**

---

## IMPORTANT NOTES

### Array Attributes Limitation
⚠️ **Array attributes CANNOT be set as Required in Appwrite Console**
- When creating array attributes (String[]), you must:
  - ✅ Check **"Array"** toggle
  - ❌ **DO NOT** check **"Required"** (leave it unchecked)
  - The app code handles validation, so this is safe

### Boolean Attributes Limitation
⚠️ **Boolean attributes CANNOT have default values if set as Required**
- For boolean attributes with default values:
  - ❌ **DO NOT** check **"Required"**
  - ✅ Set **"Default value"** to `false` or `true`
  - The app code ensures these fields are always populated

---

## Collection 1: Conversations

### Create Collection
- Click **"Create Collection"**
- **Collection ID**: `conversations`
- **Collection Name**: `Conversations`

### Permissions
After creating, go to **Settings** → **Permissions**:
- Click **"+ Add Role"**
- Select **"Any"** (authenticated users)
- Enable: **Read**, **Create**, **Update**

### Attributes
Click **"Attributes"** tab, then create each attribute:

1. **type** - String, Size: 20, ✅ Required
2. **name** - String, Size: 255, ❌ Not Required
3. **participantIds** - String, Size: 1000, ✅ Array, ❌ Not Required
4. **participantNames** - String, Size: 1000, ✅ Array, ❌ Not Required
5. **participantRoles** - String, Size: 500, ✅ Array, ❌ Not Required
6. **participantAvatars** - String, Size: 2000, ✅ Array, ❌ Not Required
7. **lastMessage** - String, Size: 500, ❌ Not Required
8. **lastMessageSenderId** - String, Size: 50, ❌ Not Required
9. **lastMessageAt** - DateTime, ❌ Not Required
10. **unreadCounts** - String, Size: 2000, ❌ Not Required (stores JSON)
11. **contextType** - String, Size: 20, ❌ Not Required
12. **contextId** - String, Size: 50, ❌ Not Required
13. **isArchived** - Boolean, ❌ Not Required, Default: `false`
14. **archivedBy** - String, Size: 500, ✅ Array, ❌ Not Required

### Indexes
Click **"Indexes"** tab, then create each index:

1. **idx_participants** - Type: Key, Attribute: participantIds, Order: ASC
2. **idx_archived** - Type: Key, Attribute: isArchived, Order: ASC
3. **idx_type** - Type: Key, Attribute: type, Order: ASC
4. **idx_context** - Type: Key, Attributes: contextType + contextId, Orders: ASC + ASC
5. **idx_last_message_at** - Type: Key, Attribute: lastMessageAt, Order: DESC

---

## Collection 2: Messages

### Create Collection
- **Collection ID**: `messages`
- **Collection Name**: `Messages`

### Permissions
- Select **"Any"** (authenticated users)
- Enable: **Read**, **Create**, **Update**, **Delete**

### Attributes

1. **conversationId** - String, Size: 50, ✅ Required
2. **senderId** - String, Size: 50, ✅ Required
3. **senderName** - String, Size: 255, ✅ Required
4. **senderRole** - String, Size: 50, ✅ Required
5. **senderAvatarUrl** - String, Size: 500, ❌ Not Required
6. **type** - String, Size: 20, ✅ Required
7. **content** - String, Size: 5000, ✅ Required
8. **mediaUrl** - URL, ❌ Not Required
9. **mediaFileName** - String, Size: 255, ❌ Not Required
10. **mediaFileSize** - Integer, ❌ Not Required
11. **reactions** - String, Size: 5000, ❌ Not Required (stores JSON)
12. **readBy** - String, Size: 2000, ✅ Array, ❌ Not Required
13. **replyToMessageId** - String, Size: 50, ❌ Not Required
14. **replyToText** - String, Size: 500, ❌ Not Required
15. **isEdited** - Boolean, ❌ Not Required, Default: `false`
16. **editedAt** - DateTime, ❌ Not Required
17. **isDeleted** - Boolean, ❌ Not Required, Default: `false`
18. **deletedAt** - DateTime, ❌ Not Required
19. **deletedBy** - String, Size: 50, ❌ Not Required
20. **createdAt** - DateTime, ✅ Required
21. **updatedAt** - DateTime, ✅ Required

### Indexes

1. **idx_conversation** - Type: Key, Attribute: conversationId, Order: ASC
2. **idx_sender** - Type: Key, Attribute: senderId, Order: ASC
3. **idx_created_at** - Type: Key, Attribute: createdAt, Order: DESC
4. **idx_conversation_created** - Type: Key, Attributes: conversationId + createdAt, Orders: ASC + DESC
5. **idx_conversation_active** - Type: Key, Attributes: conversationId + isDeleted, Orders: ASC + ASC
6. **idx_reply_to** - Type: Key, Attribute: replyToMessageId, Order: ASC

---

## Collection 3: Typing Indicators

### Create Collection
- **Collection ID**: `typing_indicators`
- **Collection Name**: `Typing Indicators`

### Permissions
- Select **"Any"** (authenticated users)
- Enable: **Read**, **Create**, **Update**, **Delete**

### Attributes

1. **conversationId** - String, Size: 50, ✅ Required
2. **userId** - String, Size: 50, ✅ Required
3. **userName** - String, Size: 255, ✅ Required
4. **isTyping** - Boolean, ❌ Not Required, Default: `false`
5. **lastTypingAt** - DateTime, ✅ Required

### Indexes

1. **idx_conversation** - Type: Key, Attribute: conversationId, Order: ASC
2. **idx_user** - Type: Key, Attribute: userId, Order: ASC
3. **idx_active_typing** - Type: Key, Attributes: conversationId + isTyping, Orders: ASC + ASC

---

## Collection 4: User Presence

### Create Collection
- **Collection ID**: `user_presence`
- **Collection Name**: `User Presence`

### Permissions
- Select **"Any"** (authenticated users)
- Enable: **Read**, **Create**, **Update**

### Attributes

1. **userId** - String, Size: 50, ✅ Required
2. **isOnline** - Boolean, ❌ Not Required, Default: `false`
3. **lastSeenAt** - DateTime, ✅ Required
4. **updatedAt** - DateTime, ✅ Required

### Indexes

1. **idx_user** - Type: Key, Attribute: userId, Order: ASC
2. **idx_online** - Type: Key, Attribute: isOnline, Order: ASC
3. **idx_last_seen** - Type: Key, Attribute: lastSeenAt, Order: DESC

---

## After Setup

Once all 4 collections are created:

1. Verify in Appwrite Console that all collections, attributes, and indexes are created
2. Test the chat functionality in the Flutter app
3. Proceed with Phase 3 UI implementation (typing indicator, online status, reactions, edit/delete)

---

## Quick Reference

### Summary of Appwrite Console Limitations:
1. ⚠️ **Array attributes cannot be Required** - Always uncheck "Required" for arrays
2. ⚠️ **Boolean with default cannot be Required** - Uncheck "Required" to set default value
3. ✅ **String/DateTime/Integer/URL** - Can be Required without issues

### Attribute Type Guidelines:
- **String**: Regular text fields
- **String[]**: Array fields (uncheck Required, check Array toggle)
- **Boolean**: True/false fields (uncheck Required if you want default value)
- **DateTime**: Date and time fields (use DateTime type, not String)
- **Integer**: Numeric fields (for file sizes, counts, etc.)
- **URL**: For web URLs (validates URL format)

### Permissions Guidelines:
- Using **"Any"** allows all authenticated users
- This is suitable for the chat system where admins and cleaners need access
- You can refine permissions later if needed
