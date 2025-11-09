# 📚 CODE SNIPPETS REFERENCE

Copy-paste ready code untuk various use cases dengan Phase 4 files.

---

## 🎨 USING REQUEST CARD WIDGET

### **Basic Usage (Standard Mode)**
```dart
RequestCardWidget(
  request: request,
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RequestDetailScreen(requestId: request.id),
      ),
    );
  },
)
```

### **With Assignee Info**
```dart
RequestCardWidget(
  request: request,
  onTap: () => _handleTap(request),
  showAssignee: true,  // Show cleaner name + avatar
  showThumbnail: true,
)
```

### **Compact Mode (For Nested Lists)**
```dart
RequestCardWidget(
  request: request,
  onTap: () => _handleTap(request),
  compact: true,  // Single-line preview
  showThumbnail: false,
)
```

### **With Animation Index**
```dart
ListView.builder(
  itemCount: requests.length,
  itemBuilder: (context, index) {
    return RequestCardWidget(
      request: requests[index],
      onTap: () => _handleTap(requests[index]),
      animationIndex: index,  // Stagger animation
    );
  },
)
```

---

## 📄 NAVIGATING TO REQUEST DETAIL

### **Simple Navigation**
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => RequestDetailScreen(requestId: 'xxx'),
  ),
);
```

### **With Result Callback**
```dart
final result = await Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => RequestDetailScreen(requestId: request.id),
  ),
);

if (result == true) {
  // Request was updated, refresh list
  ref.invalidate(myRequestsProvider);
}
```

### **Named Route (If Implemented)**
```dart
Navigator.pushNamed(
  context,
  '/request_detail',
  arguments: requestId,
);
```

---

## 👤 EMPLOYEE SCREEN INTEGRATION

### **Add History Button to AppBar**
```dart
class EmployeeHomeScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Beranda'),
        actions: [
          // History button
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Riwayat Request',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RequestHistoryScreen(),
                ),
              );
            },
          ),
          
          // Optional: Create request button
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Buat Request',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateRequestScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: // ... your content
    );
  }
}
```

### **Add History Card in Body**
```dart
// Di dalam Column body
Card(
  child: ListTile(
    leading: const Icon(Icons.history, color: AppTheme.primary),
    title: const Text('Riwayat Request'),
    subtitle: const Text('Lihat semua request yang pernah dibuat'),
    trailing: const Icon(Icons.chevron_right),
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const RequestHistoryScreen(),
        ),
      );
    },
  ),
)
```

---

## 🧹 CLEANER SCREEN INTEGRATION

### **Full Cleaner Home with Available Requests**
```dart
class CleanerHomeScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Cleaner'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(pendingRequestsProvider);
          ref.invalidate(myAssignedRequestsProvider);
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stats cards (existing)
                _buildStatsCards(ref),
                
                const SizedBox(height: 24),
                
                // Available requests widget
                AvailableRequestsWidget(
                  onRequestAssigned: () {
                    // Refresh stats
                    ref.invalidate(myAssignedRequestsProvider);
                    ref.invalidate(pendingRequestsProvider);
                    
                    // Show feedback
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✅ Tugas berhasil diambil!'),
                        backgroundColor: AppTheme.success,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildStatsCards(WidgetRef ref) {
    final assignedAsync = ref.watch(myAssignedRequestsProvider);
    
    return assignedAsync.when(
      data: (requests) {
        final assigned = requests.where((r) => 
          r.status == RequestStatus.assigned).length;
        final inProgress = requests.where((r) => 
          r.status == RequestStatus.inProgress).length;
        final completed = requests.where((r) => 
          r.status == RequestStatus.completed).length;
        
        return Row(
          children: [
            Expanded(
              child: StatsCard(
                icon: Icons.assignment_outlined,
                label: 'Ditugaskan',
                value: assigned.toString(),
                color: AppTheme.secondary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatsCard(
                icon: Icons.hourglass_empty,
                label: 'Proses',
                value: inProgress.toString(),
                color: AppTheme.info,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatsCard(
                icon: Icons.check_circle,
                label: 'Selesai',
                value: completed.toString(),
                color: AppTheme.success,
              ),
            ),
          ],
        );
      },
      loading: () => const SizedBox(height: 100),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
```

---

## 👨‍💼 ADMIN SCREEN INTEGRATION

### **Full Admin Home with Request Management**
```dart
class AdminHomeScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(allRequestsProvider);
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Page title
                const Text(
                  'Dashboard',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Kelola semua request di sistem',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Request management widget
                RequestManagementWidget(
                  onRequestUpdated: () {
                    // Refresh provider
                    ref.invalidate(allRequestsProvider);
                    
                    // Optional: Show feedback
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✅ Request berhasil diupdate'),
                        backgroundColor: AppTheme.success,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

---

## 🔔 CUSTOM ACTION HANDLERS

### **Cancel Request with Reason**
```dart
Future<void> _handleCancelWithReason(Request request, BuildContext context, WidgetRef ref) async {
  final reasonController = TextEditingController();
  
  final result = await showDialog<Map<String, dynamic>>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Batalkan Request'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Alasan pembatalan:'),
          const SizedBox(height: 12),
          TextField(
            controller: reasonController,
            decoration: const InputDecoration(
              hintText: 'Contoh: Sudah tidak diperlukan',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, {
              'confirmed': true,
              'reason': reasonController.text,
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.error,
          ),
          child: const Text('Batalkan Request'),
        ),
      ],
    ),
  );
  
  if (result?['confirmed'] != true) return;
  
  try {
    await ref.read(requestActionsProvider).softDeleteRequest(request.id);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Request berhasil dibatalkan'),
        backgroundColor: AppTheme.success,
      ),
    );
    
    Navigator.pop(context, true); // Return to previous screen
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Gagal membatalkan: $e'),
        backgroundColor: AppTheme.error,
      ),
    );
  }
}
```

### **Complete Request with Notes**
```dart
Future<void> _handleCompleteWithNotes(Request request, BuildContext context, WidgetRef ref) async {
  final notesController = TextEditingController();
  File? completionImage;
  
  // Pick image first
  final imagePicker = ImagePicker();
  final pickedFile = await imagePicker.pickImage(
    source: ImageSource.camera,
    maxWidth: 1200,
    maxHeight: 1200,
    imageQuality: 85,
  );
  
  if (pickedFile == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Foto completion wajib diupload'),
        backgroundColor: AppTheme.warning,
      ),
    );
    return;
  }
  
  completionImage = File(pickedFile.path);
  
  // Show notes dialog
  final notes = await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Catatan Penyelesaian'),
      content: TextField(
        controller: notesController,
        decoration: const InputDecoration(
          hintText: 'Tambahkan catatan (optional)',
          border: OutlineInputBorder(),
        ),
        maxLines: 3,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, notesController.text),
          child: const Text('Selesai'),
        ),
      ],
    ),
  );
  
  if (notes == null) return;
  
  // Complete request
  try {
    await ref.read(requestActionsProvider).completeRequest(
      request.id,
      completionImage,
      notes: notes,
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Pekerjaan selesai!'),
        backgroundColor: AppTheme.success,
      ),
    );
    
    Navigator.pop(context, true);
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Gagal menyelesaikan: $e'),
        backgroundColor: AppTheme.error,
      ),
    );
  }
}
```

---

## 📊 CUSTOM STATISTICS DISPLAY

### **Summary Card for Employee**
```dart
Widget buildEmployeeStats(WidgetRef ref) {
  final requestsAsync = ref.watch(myRequestsProvider);
  
  return requestsAsync.when(
    data: (requests) {
      final pending = requests.where((r) => 
        r.status == RequestStatus.pending).length;
      final assigned = requests.where((r) => 
        r.status == RequestStatus.assigned).length;
      final inProgress = requests.where((r) => 
        r.status == RequestStatus.inProgress).length;
      final completed = requests.where((r) => 
        r.status == RequestStatus.completed).length;
      
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Request Saya',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem('Pending', pending, AppTheme.warning),
                  _buildStatItem('Proses', assigned + inProgress, AppTheme.info),
                  _buildStatItem('Selesai', completed, AppTheme.success),
                ],
              ),
            ],
          ),
        ),
      );
    },
    loading: () => const Card(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator()),
      ),
    ),
    error: (_, __) => const SizedBox.shrink(),
  );
}

Widget _buildStatItem(String label, int value, Color color) {
  return Column(
    children: [
      Text(
        value.toString(),
        style: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
        ),
      ),
    ],
  );
}
```

---

## 🔍 CUSTOM SEARCH IMPLEMENTATION

### **Search with Debounce**
```dart
class _RequestListState extends ConsumerStatefulWidget {
  Timer? _debounce;
  final _searchController = TextEditingController();
  
  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }
  
  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _searchQuery = query.toLowerCase();
      });
    });
  }
  
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Cari request...',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: _onSearchChanged,
        ),
        // ... list
      ],
    );
  }
}
```

---

## 🎨 CUSTOM EMPTY STATES

### **Empty with Action Button**
```dart
Widget buildCustomEmptyState() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.inbox_outlined,
          size: 80,
          color: Colors.grey[300],
        ),
        const SizedBox(height: 24),
        Text(
          'Belum ada request',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Request yang Anda buat akan muncul di sini',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[500],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CreateRequestScreen(),
              ),
            );
          },
          icon: const Icon(Icons.add),
          label: const Text('Buat Request Baru'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 16,
            ),
          ),
        ),
      ],
    ),
  );
}
```

---

## 🔄 REFRESH PATTERNS

### **Pull to Refresh with Multiple Providers**
```dart
Future<void> _handleRefresh() async {
  // Invalidate multiple providers
  ref.invalidate(myRequestsProvider);
  ref.invalidate(myAssignedRequestsProvider);
  ref.invalidate(pendingRequestsProvider);
  
  // Wait a bit for streams to update
  await Future.delayed(const Duration(milliseconds: 500));
}

// Usage
RefreshIndicator(
  onRefresh: _handleRefresh,
  child: ListView(...),
)
```

### **Manual Refresh Button**
```dart
IconButton(
  icon: const Icon(Icons.refresh),
  onPressed: () {
    ref.invalidate(myRequestsProvider);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Memuat ulang...'),
        duration: Duration(seconds: 1),
      ),
    );
  },
)
```

---

## 📱 RESPONSIVE LAYOUT

### **Adaptive Grid/List Based on Screen Width**
```dart
Widget buildResponsiveRequestList(List<Request> requests) {
  return LayoutBuilder(
    builder: (context, constraints) {
      // Tablet/Desktop: Grid
      if (constraints.maxWidth > 600) {
        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.5,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            return RequestCardWidget(
              request: requests[index],
              onTap: () => _handleTap(requests[index]),
              compact: true,
            );
          },
        );
      }
      
      // Mobile: List
      return ListView.builder(
        itemCount: requests.length,
        itemBuilder: (context, index) {
          return RequestCardWidget(
            request: requests[index],
            onTap: () => _handleTap(requests[index]),
          );
        },
      );
    },
  );
}
```

---

**More examples coming soon! Check inline documentation in each file for detailed usage. 🚀**
