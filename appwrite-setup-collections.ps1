# Appwrite CLI commands to create chat collections
# Run this after answering 'N' to the pull prompt

Write-Host "Creating conversations collection..." -ForegroundColor Cyan
appwrite databases create-collection `
  --database-id "691868630007af45a94b" `
  --collection-id "conversations" `
  --name "Conversations" `
  --permissions 'read("role:admin")' 'read("role:cleaner")' 'create("role:admin")' 'update("role:admin")' 'update("role:cleaner")' 'delete("role:admin")'

# Conversations attributes
Write-Host "Adding conversations attributes..." -ForegroundColor Yellow
appwrite databases create-string-attribute --database-id "691868630007af45a94b" --collection-id "conversations" --key "type" --size 20 --required true
appwrite databases create-string-attribute --database-id "691868630007af45a94b" --collection-id "conversations" --key "name" --size 255 --required false
appwrite databases create-string-attribute --database-id "691868630007af45a94b" --collection-id "conversations" --key "participantIds" --size 1000 --required true --array true
appwrite databases create-string-attribute --database-id "691868630007af45a94b" --collection-id "conversations" --key "participantNames" --size 1000 --required true --array true
appwrite databases create-string-attribute --database-id "691868630007af45a94b" --collection-id "conversations" --key "participantRoles" --size 500 --required true --array true
appwrite databases create-string-attribute --database-id "691868630007af45a94b" --collection-id "conversations" --key "participantAvatars" --size 2000 --required false --array true
appwrite databases create-string-attribute --database-id "691868630007af45a94b" --collection-id "conversations" --key "lastMessage" --size 500 --required false
appwrite databases create-string-attribute --database-id "691868630007af45a94b" --collection-id "conversations" --key "lastMessageSenderId" --size 50 --required false
appwrite databases create-datetime-attribute --database-id "691868630007af45a94b" --collection-id "conversations" --key "lastMessageAt" --required false
appwrite databases create-string-attribute --database-id "691868630007af45a94b" --collection-id "conversations" --key "unreadCounts" --size 2000 --required false
appwrite databases create-string-attribute --database-id "691868630007af45a94b" --collection-id "conversations" --key "contextType" --size 20 --required false
appwrite databases create-string-attribute --database-id "691868630007af45a94b" --collection-id "conversations" --key "contextId" --size 50 --required false
appwrite databases create-boolean-attribute --database-id "691868630007af45a94b" --collection-id "conversations" --key "isArchived" --required true --default false
appwrite databases create-string-attribute --database-id "691868630007af45a94b" --collection-id "conversations" --key "archivedBy" --size 500 --required false --array true

# Conversations indexes
Write-Host "Creating conversations indexes..." -ForegroundColor Yellow
appwrite databases create-index --database-id "691868630007af45a94b" --collection-id "conversations" --key "idx_participants" --type "key" --attributes "participantIds" --orders "ASC"
appwrite databases create-index --database-id "691868630007af45a94b" --collection-id "conversations" --key "idx_archived" --type "key" --attributes "isArchived" --orders "ASC"
appwrite databases create-index --database-id "691868630007af45a94b" --collection-id "conversations" --key "idx_type" --type "key" --attributes "type" --orders "ASC"
appwrite databases create-index --database-id "691868630007af45a94b" --collection-id "conversations" --key "idx_context" --type "key" --attributes "contextType" "contextId" --orders "ASC" "ASC"
appwrite databases create-index --database-id "691868630007af45a94b" --collection-id "conversations" --key "idx_last_message_at" --type "key" --attributes "lastMessageAt" --orders "DESC"

Write-Host ""
Write-Host "Creating messages collection..." -ForegroundColor Cyan
appwrite databases create-collection `
  --database-id "691868630007af45a94b" `
  --collection-id "messages" `
  --name "Messages" `
  --permissions 'read("role:admin")' 'read("role:cleaner")' 'create("role:admin")' 'create("role:cleaner")' 'update("role:admin")' 'update("role:cleaner")' 'delete("role:admin")' 'delete("role:cleaner")'

# Messages attributes
Write-Host "Adding messages attributes..." -ForegroundColor Yellow
appwrite databases create-string-attribute --database-id "691868630007af45a94b" --collection-id "messages" --key "conversationId" --size 50 --required true
appwrite databases create-string-attribute --database-id "691868630007af45a94b" --collection-id "messages" --key "senderId" --size 50 --required true
appwrite databases create-string-attribute --database-id "691868630007af45a94b" --collection-id "messages" --key "senderName" --size 255 --required true
appwrite databases create-string-attribute --database-id "691868630007af45a94b" --collection-id "messages" --key "senderRole" --size 50 --required true
appwrite databases create-string-attribute --database-id "691868630007af45a94b" --collection-id "messages" --key "senderAvatarUrl" --size 500 --required false
appwrite databases create-string-attribute --database-id "691868630007af45a94b" --collection-id "messages" --key "type" --size 20 --required true
appwrite databases create-string-attribute --database-id "691868630007af45a94b" --collection-id "messages" --key "content" --size 5000 --required true
appwrite databases create-url-attribute --database-id "691868630007af45a94b" --collection-id "messages" --key "mediaUrl" --required false
appwrite databases create-string-attribute --database-id "691868630007af45a94b" --collection-id "messages" --key "mediaFileName" --size 255 --required false
appwrite databases create-integer-attribute --database-id "691868630007af45a94b" --collection-id "messages" --key "mediaFileSize" --required false
appwrite databases create-string-attribute --database-id "691868630007af45a94b" --collection-id "messages" --key "reactions" --size 5000 --required false
appwrite databases create-string-attribute --database-id "691868630007af45a94b" --collection-id "messages" --key "readBy" --size 2000 --required true --array true
appwrite databases create-string-attribute --database-id "691868630007af45a94b" --collection-id "messages" --key "replyToMessageId" --size 50 --required false
appwrite databases create-string-attribute --database-id "691868630007af45a94b" --collection-id "messages" --key "replyToText" --size 500 --required false
appwrite databases create-boolean-attribute --database-id "691868630007af45a94b" --collection-id "messages" --key "isEdited" --required true --default false
appwrite databases create-datetime-attribute --database-id "691868630007af45a94b" --collection-id "messages" --key "editedAt" --required false
appwrite databases create-boolean-attribute --database-id "691868630007af45a94b" --collection-id "messages" --key "isDeleted" --required true --default false
appwrite databases create-datetime-attribute --database-id "691868630007af45a94b" --collection-id "messages" --key "deletedAt" --required false
appwrite databases create-string-attribute --database-id "691868630007af45a94b" --collection-id "messages" --key "deletedBy" --size 50 --required false
appwrite databases create-datetime-attribute --database-id "691868630007af45a94b" --collection-id "messages" --key "createdAt" --required true
appwrite databases create-datetime-attribute --database-id "691868630007af45a94b" --collection-id "messages" --key "updatedAt" --required true

# Messages indexes
Write-Host "Creating messages indexes..." -ForegroundColor Yellow
appwrite databases create-index --database-id "691868630007af45a94b" --collection-id "messages" --key "idx_conversation" --type "key" --attributes "conversationId" --orders "ASC"
appwrite databases create-index --database-id "691868630007af45a94b" --collection-id "messages" --key "idx_sender" --type "key" --attributes "senderId" --orders "ASC"
appwrite databases create-index --database-id "691868630007af45a94b" --collection-id "messages" --key "idx_created_at" --type "key" --attributes "createdAt" --orders "DESC"
appwrite databases create-index --database-id "691868630007af45a94b" --collection-id "messages" --key "idx_conversation_created" --type "key" --attributes "conversationId" "createdAt" --orders "ASC" "DESC"
appwrite databases create-index --database-id "691868630007af45a94b" --collection-id "messages" --key "idx_conversation_active" --type "key" --attributes "conversationId" "isDeleted" --orders "ASC" "ASC"
appwrite databases create-index --database-id "691868630007af45a94b" --collection-id "messages" --key "idx_reply_to" --type "key" --attributes "replyToMessageId" --orders "ASC"

Write-Host ""
Write-Host "Creating typing_indicators collection..." -ForegroundColor Cyan
appwrite databases create-collection `
  --database-id "691868630007af45a94b" `
  --collection-id "typing_indicators" `
  --name "Typing Indicators" `
  --permissions 'read("role:admin")' 'read("role:cleaner")' 'create("role:admin")' 'create("role:cleaner")' 'update("role:admin")' 'update("role:cleaner")' 'delete("role:admin")' 'delete("role:cleaner")'

# Typing indicators attributes
Write-Host "Adding typing_indicators attributes..." -ForegroundColor Yellow
appwrite databases create-string-attribute --database-id "691868630007af45a94b" --collection-id "typing_indicators" --key "conversationId" --size 50 --required true
appwrite databases create-string-attribute --database-id "691868630007af45a94b" --collection-id "typing_indicators" --key "userId" --size 50 --required true
appwrite databases create-string-attribute --database-id "691868630007af45a94b" --collection-id "typing_indicators" --key "userName" --size 255 --required true
appwrite databases create-boolean-attribute --database-id "691868630007af45a94b" --collection-id "typing_indicators" --key "isTyping" --required true --default false
appwrite databases create-datetime-attribute --database-id "691868630007af45a94b" --collection-id "typing_indicators" --key "lastTypingAt" --required true

# Typing indicators indexes
Write-Host "Creating typing_indicators indexes..." -ForegroundColor Yellow
appwrite databases create-index --database-id "691868630007af45a94b" --collection-id "typing_indicators" --key "idx_conversation" --type "key" --attributes "conversationId" --orders "ASC"
appwrite databases create-index --database-id "691868630007af45a94b" --collection-id "typing_indicators" --key "idx_user" --type "key" --attributes "userId" --orders "ASC"
appwrite databases create-index --database-id "691868630007af45a94b" --collection-id "typing_indicators" --key "idx_active_typing" --type "key" --attributes "conversationId" "isTyping" --orders "ASC" "ASC"

Write-Host ""
Write-Host "Creating user_presence collection..." -ForegroundColor Cyan
appwrite databases create-collection `
  --database-id "691868630007af45a94b" `
  --collection-id "user_presence" `
  --name "User Presence" `
  --permissions 'read("role:admin")' 'read("role:cleaner")' 'create("role:admin")' 'create("role:cleaner")' 'update("role:admin")' 'update("role:cleaner")' 'delete("role:admin")' 'delete("role:cleaner")'

# User presence attributes
Write-Host "Adding user_presence attributes..." -ForegroundColor Yellow
appwrite databases create-string-attribute --database-id "691868630007af45a94b" --collection-id "user_presence" --key "userId" --size 50 --required true
appwrite databases create-boolean-attribute --database-id "691868630007af45a94b" --collection-id "user_presence" --key "isOnline" --required true --default false
appwrite databases create-datetime-attribute --database-id "691868630007af45a94b" --collection-id "user_presence" --key "lastSeenAt" --required true
appwrite databases create-datetime-attribute --database-id "691868630007af45a94b" --collection-id "user_presence" --key "updatedAt" --required true

# User presence indexes
Write-Host "Creating user_presence indexes..." -ForegroundColor Yellow
appwrite databases create-index --database-id "691868630007af45a94b" --collection-id "user_presence" --key "idx_user" --type "key" --attributes "userId" --orders "ASC"
appwrite databases create-index --database-id "691868630007af45a94b" --collection-id "user_presence" --key "idx_online" --type "key" --attributes "isOnline" --orders "ASC"
appwrite databases create-index --database-id "691868630007af45a94b" --collection-id "user_presence" --key "idx_last_seen" --type "key" --attributes "lastSeenAt" --orders "DESC"

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "All collections created successfully!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Verify collections in Appwrite Console" -ForegroundColor White
Write-Host "2. Test the chat functionality in the app" -ForegroundColor White
Write-Host "3. Proceed with Phase 3 UI implementation" -ForegroundColor White
Write-Host ""
Read-Host "Press Enter to continue"
