import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:async';
import 'dart:typed_data';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../riverpod/auth_providers.dart';

// Screens
import '../../screens/auth/login_screen.dart';
import '../../screens/web_admin/dashboard/admin_dashboard.dart';
import '../../screens/web_admin/settings/admin_settings_screen.dart';
import '../../screens/web_admin/settings/profile_screen.dart';
import '../../screens/web_admin/settings/admin_user_management_screen.dart';
import '../../screens/web_admin/notifications/notification_center_screen.dart';
import '../../screens/web_admin/dashboard/activity_log_screen.dart';
import '../../screens/cleaner/cleaner_home_screen.dart';
import '../../screens/employee/employee_home_screen_enhanced.dart';
import '../../screens/console/cleaner/web_cleaner_dashboard.dart';
import '../../screens/console/teknisi/web_teknisi_dashboard.dart';
import '../../screens/onboarding/welcome_screen.dart';
import '../../screens/cleaner/cleaner_schedule_screen.dart';
import '../../screens/cleaner/cleaner_task_screen.dart';
import '../../screens/cleaner/cleaner_task_detail_screen.dart';
import '../../screens/cleaner/cleaner_pending_screen.dart';
import '../../platforms/mobile/cleaner/my_tasks_screen.dart';
import '../../screens/cleaner/cleaner_login_screen.dart';
import '../../screens/teknisi/teknisi_home_screen.dart';
import '../../screens/teknisi/teknisi_inbox_screen.dart';
import '../../screens/teknisi/teknisi_task_detail_screen.dart';
import '../../screens/teknisi/teknisi_schedule_screen.dart';
import '../../screens/teknisi/teknisi_task_screen.dart';
import '../../screens/employee/web_employee_dashboard.dart';
import '../../screens/web_admin/analytics/ticket_analytics_screen.dart';

// Master Data Screens
import '../../screens/web_admin/master_data/master_pegawai_screen.dart';

import '../../screens/web_admin/master_data/master_organisasi_screen.dart';
import '../../screens/web_admin/master_data/master_anggaran_screen.dart';
import '../../screens/web_admin/master_data/master_aset_screen.dart';
import '../../screens/web_admin/master_data/master_vendor_screen.dart';
import '../../platforms/mobile/admin/quick_menu_screen.dart'; // Mobile Quick Menu (Unified)

// SIM-ASET Screens
import '../../screens/sim_aset/asset_list_screen.dart';
import '../../screens/sim_aset/asset_form_screen.dart';
import '../../screens/sim_aset/asset_detail_screen.dart';
import '../../models/asset.dart';
import '../../models/ticket.dart'; // Import for TicketType
// import '../../models/maintenance_log.dart'; // Import Asset model

// Procurement Screens
// Procurement Screens
import '../../screens/web_admin/transactions/procurement/procurement_list_screen.dart';
import '../../screens/web_admin/transactions/procurement/procurement_form_screen.dart';
import '../../screens/web_admin/transactions/procurement/procurement_detail_screen.dart';
import '../../screens/web_admin/transactions/procurement/procurement_archive_screen.dart';

import '../../screens/web_admin/transactions/helpdesk/helpdesk_screen.dart';
import '../../screens/web_admin/transactions/maintenance/maintenance_detail_screen.dart';
import '../../screens/web_admin/transactions/maintenance/maintenance_form_screen.dart';
// import '../../screens/web_admin/transactions/maintenance/maintenance_form_screen.dart'; // Duplicate
import '../../screens/inventory/inventory_list_screen.dart';
import '../../screens/inventory/inventory_add_edit_screen.dart';
import '../../screens/inventory/inventory_detail_screen.dart';
import '../../screens/inventory/inventory_request_list_screen.dart'; 
import '../../screens/inventory/inventory_request_form_screen.dart';
import '../../screens/inventory/inventory_request_history_screen.dart';
// Legacy imports removed (Disposal duplicate fix)
import '../../screens/web_admin/analytics_screen.dart'; // Import Analytics Screen
import '../../screens/sim_aset/loan_list_screen.dart';
import '../../screens/sim_aset/loan_form_screen.dart';
import '../../screens/sim_aset/loan_detail_screen.dart';
import '../../screens/sim_aset/booking_list_screen.dart';
import '../../screens/sim_aset/booking_form_screen.dart';
import '../../screens/web_admin/transactions/disposal/disposal_list_screen.dart';
import '../../screens/web_admin/transactions/disposal/disposal_form_screen.dart';
import '../../screens/web_admin/transactions/disposal/disposal_detail_screen.dart';
import '../../screens/web_admin/transactions/mutation/mutation_list_screen.dart';
import '../../screens/web_admin/transactions/mutation/mutation_form_screen.dart';
import '../../screens/web_admin/transactions/mutation/mutation_detail_screen.dart';

import '../../screens/web_admin/cleaner_management_screen.dart';
import '../../screens/web_admin/settings/admin_settings_screen.dart';
import '../../screens/web_admin/reports/report_center_screen.dart';
import '../../screens/web_admin/reports/stock_movement_report_screen.dart';
import '../../screens/web_admin/reports/report_preview_screen.dart';
import '../../screens/web_admin/notifications/notification_center_screen.dart';
// import '../../screens/web_admin/user_management_screen.dart'; // Deprecated

// Layouts
import '../../widgets/web_admin/layout/admin_shell_layout.dart';

// Ticketing System
import '../../screens/shared/ticket_form_screen.dart';
import '../../screens/shared/inbox_screen.dart';
import '../../screens/kasubbag/kasubbag_approval_dashboard.dart';


final _rootNavigatorKey = GlobalKey<NavigatorState>();
// final _adminShellNavigatorKey removed to prevent Duplicate Key errors

/// Converts a Stream to a Listenable for GoRouter refreshListenable
class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

// ==================== ROLE-BASED ROUTE PROTECTION ====================

/// Get home route for each role
/// Uses kIsWeb to determine if user should go to Web Console or Mobile App routes
String _getHomeRouteForRole(String? role) {
  // Web users all get Console routes (Admin Shell Layout)
  if (kIsWeb) {
    switch (role) {
      case 'admin':
        return '/admin/dashboard';
      case 'kasubbag_umpeg':
        return '/admin/dashboard'; // Same as Admin (Full Access)
      case 'teknisi':
      case 'teknisi_aset':
        return '/console/teknisi/dashboard'; // Web Teknisi Dashboard (Mobile Layout)
      case 'cleaner':
        return '/console/cleaner/dashboard'; // Web Cleaner Dashboard
      case 'employee':
        return '/admin/dashboard'; // Web Employee now uses Admin Console
      default:
        return '/login';
    }
  }
  
  // Mobile App users get dedicated mobile routes
  switch (role) {
    case 'admin':
      return '/admin/dashboard'; // Admin still uses web-like layout
    case 'kasubbag_umpeg':
      return '/admin/dashboard';
    case 'teknisi':
      return '/teknisi/dashboard'; // Mobile Teknisi View
    case 'cleaner':
      return '/cleaner/dashboard'; // Mobile Cleaner (existing)
    case 'employee':
      return '/employee/dashboard'; // Mobile Employee (existing)
    default:
      return '/login';
  }
}

/// Check if role can access a given route
bool _canRoleAccessRoute(String? role, String path) {
  if (role == null) return false;
  
  // Admin can access everything
  if (role == 'admin') return true;
  
  // Define route access per role
  final routeAccess = <String, List<String>>{
    'kasubbag_umpeg': [
      '/admin/dashboard',
      '/admin/quick-menu', // Allow Quick Menu access
      '/admin/activities',
      '/admin/assets',
      '/admin/procurement',
      '/admin/helpdesk',
      '/admin/inventory',
      '/admin/cleaners',
      '/admin/disposal',
      '/admin/analytics',
      '/admin/loans',
      '/admin/bookings',
      '/admin/maintenance',
      '/admin/reports',
      '/admin/notifications',
      '/admin/ticket',
      '/admin/inbox',
      '/admin/master', // Full access to Master Data
      '/admin/settings', // Full access to Settings
      '/admin/profile', // Profile access
      '/admin/users', // User Management
      '/kasubbag',
    ],
    'teknisi': [
      '/admin/dashboard',
      '/admin/helpdesk',
      '/admin/maintenance',
      '/admin/ticket',
      '/admin/inbox',
      '/admin/profile',
      '/teknisi', // Mobile teknisi routes
      '/teknisi/schedule',
      '/teknisi/my-tasks',
      '/teknisi/task',
    ],
    'cleaner': [
      '/cleaner',
      '/console/cleaner', // Web Console access
      '/admin/ticket',
      '/admin/inbox',
      '/admin/helpdesk', // Can see helpdesk for their tasks
      '/admin/profile', // Profile access
      '/admin/notifications', // Notification Center
      '/cleaner/schedule', // Mobile Schedule Screen
      '/cleaner/my-tasks', // Mobile My Tasks Screen
      '/cleaner/task', // Task detail (prefix match)
    ],
    'employee': [
      '/admin/dashboard',
      '/admin/quick-menu', // Added for Quick Menu access
      '/admin/activities',
      '/admin/assets',
      '/admin/procurement',
      '/admin/helpdesk',
      '/admin/inventory',
      '/admin/disposal',
      '/admin/analytics',
      '/admin/loans',
      '/admin/bookings',
      '/admin/maintenance',
      '/admin/reports',
      '/admin/notifications',
      '/admin/ticket',
      '/admin/inbox',
      '/admin/master', // Full Master Data Access
      '/admin/settings',
      '/admin/profile', // Profile access
      '/console/employee',
      '/employee',
    ],
  };
  
  final allowedRoutes = routeAccess[role] ?? [];
  
  // Check if path starts with any of the allowed routes
  for (final route in allowedRoutes) {
    if (path.startsWith(route)) return true;
  }
  
  return false;
}

final goRouterProvider = Provider<GoRouter>((ref) {
  // Watch auth state for reactivity
  final authState = ref.watch(authStateProvider);
  final userRole = ref.watch(currentUserRoleProvider);
  
  // Create refresh listenable from auth stream
  final refreshListenable = GoRouterRefreshStream(
    Supabase.instance.client.auth.onAuthStateChange.map((event) => event.session).distinct(),
  );
  
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    refreshListenable: refreshListenable,
    redirect: (context, state) {
      final path = state.uri.path;
      final isLoggedIn = authState.value != null;
      final isLoginRoute = path == '/' || path == '/login';
      
      // Not logged in and trying to access protected route
      if (!isLoggedIn && !isLoginRoute) {
        return '/login';
      }
      
      // Logged in and on login page - redirect to home
      if (isLoggedIn && isLoginRoute) {
        return _getHomeRouteForRole(userRole);
      }
      
      // Check role-based access for admin routes
      if (isLoggedIn && path.startsWith('/admin')) {
        if (!_canRoleAccessRoute(userRole, path)) {
          // Redirect to role's home page
          return _getHomeRouteForRole(userRole);
        }
      }
      
      // Check role-specific routes
      if (isLoggedIn && path.startsWith('/cleaner') && userRole != 'cleaner' && userRole != 'admin') {
        return _getHomeRouteForRole(userRole);
      }
      if (isLoggedIn && path.startsWith('/employee') && userRole != 'employee' && userRole != 'admin') {
        return _getHomeRouteForRole(userRole);
      }
      if (isLoggedIn && path.startsWith('/kasubbag') && userRole != 'kasubbag_umpeg' && userRole != 'admin') {
        return _getHomeRouteForRole(userRole);
      }
      
      return null; // No redirect needed
    },
    routes: [
      // Splash / Welcome (Mobile: WelcomeScreen, Web: LoginScreen)
      // Splash / Welcome (Mobile: WelcomeScreen, Web: LoginScreen)
      GoRoute(
        path: '/',
        builder: (context, state) {
           return LayoutBuilder(
             builder: (context, constraints) {
               // Mobile Web (< 900px) or Native App -> WelcomeScreen
               // Desktop Web (>= 900px) -> LoginScreen
               if (constraints.maxWidth < 900) {
                 return const WelcomeScreen();
               }
               return const LoginScreen();
             },
           );
        }, 
      ),
      
      // Auth (Mobile: CleanerLoginScreen, Web: LoginScreen)
      GoRoute(
        path: '/login',
        builder: (context, state) {
           return LayoutBuilder(
             builder: (context, constraints) {
               // Mobile Web (< 900px) -> CleanerLoginScreen
               // Desktop Web (>= 900px) -> LoginScreen
               if (constraints.maxWidth < 900) {
                 return const CleanerLoginScreen();
               }
               return const LoginScreen();
             },
           );
        },
      ),

      // Admin Shell Route
      ShellRoute(
        // navigatorKey: _adminShellNavigatorKey, // Removed to fix key collision
        builder: (context, state, child) {
          return AdminShellLayout(child: child);
        },
        routes: [
          GoRoute(
            path: '/admin/dashboard',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AdminDashboardScreen(),
            ),
          ),
          GoRoute(
            path: '/admin/activities',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ActivityLogScreen(),
            ),
          ),
          GoRoute(
            path: '/admin/quick-menu',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: QuickMenuScreen(),
            ),
          ),
          
          // --- MASTER DATA ROUTES ---
          GoRoute(
            path: '/admin/master/pegawai',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: MasterPegawaiScreen(),
            ),
          ),
          GoRoute(
            path: '/admin/master/organisasi',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: MasterOrganisasiScreen(),
            ),
          ),
          GoRoute(
            path: '/admin/master/anggaran',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: MasterAnggaranScreen(),
            ),
          ),
          GoRoute(
            path: '/admin/master/aset',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: MasterAsetScreen(),
            ),
          ),
          GoRoute(
            path: '/admin/master/vendor',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: MasterVendorScreen(),
            ),
          ),

          // Legacy / Specific Asset Routes (Keeping for now if needed, or deprecate)
          GoRoute(
            path: '/admin/assets',
            // Redirect generic list to Master Menu if no type specified
            redirect: (context, state) {
              if (state.uri.queryParameters['type'] == null) {
                return '/admin/master/aset';
              }
              return null;
            },
            pageBuilder: (context, state) {
              // Get assetType from query params for folder-based navigation
              final assetType = state.uri.queryParameters['type'];
              return NoTransitionPage(
                child: AssetListScreen(assetType: assetType),
              );
            },
            routes: [
               GoRoute(
                path: 'new',
                builder: (context, state) {
                  // Pass assetType from parent route's query params
                  final parentUri = state.uri;
                  final assetType = parentUri.queryParameters['type'];
                  return AssetFormScreen(assetType: assetType);
                },
              ),
              GoRoute(
                path: 'edit/:id',
                builder: (context, state) {
                  final asset = state.extra as Asset?;
                  final assetType = state.uri.queryParameters['type'];
                  return AssetFormScreen(asset: asset, assetType: assetType);
                },
              ),
              GoRoute(
                path: 'detail/:id',
                builder: (context, state) {
                   final asset = state.extra as Asset?;
                   if (asset == null) {
                     return const Scaffold(body: Center(child: Text("Asset not found"))); 
                   }
                   final assetType = state.uri.queryParameters['type'];
                   return AssetDetailScreen(asset: asset, assetType: assetType);
                },
              ),
              // Mutation Routes
              GoRoute(
                path: 'mutation',
                builder: (context, state) => const MutationListScreen(),
                routes: [
                  GoRoute(
                    path: 'create',
                    builder: (context, state) => const MutationFormScreen(),
                  ),
                  GoRoute(
                    path: ':id',
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return MutationDetailScreen(mutationId: id);
                    },
                  ),
                ],
              ),
            ],
          ),
          
          // Procurement
          GoRoute(
            path: '/admin/procurement',
             pageBuilder: (context, state) => const NoTransitionPage(
              child: ProcurementListScreen(),
            ),
            routes: [
              GoRoute(
                path: 'new',
                builder: (context, state) => const ProcurementFormScreen(),
              ),
              GoRoute(
                path: 'archive',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: ProcurementArchiveScreen(),
                ),
              ),
              GoRoute(
                 path: 'detail/:id',
                 builder: (context, state) {
                   final id = state.pathParameters['id'];
                   if (id == null) return const Scaffold(body: Center(child: Text("Error: No ID")));
                   return ProcurementDetailScreen(id: id);
                 }
              ),
            ],
          ),

          // Disposal
          GoRoute(
            path: '/admin/disposal',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: DisposalListScreen(),
            ),
            routes: [
              GoRoute(
                path: 'new',
                builder: (context, state) => const DisposalFormScreen(),
              ),
              GoRoute(
                path: 'detail/:id',
                builder: (context, state) {
                  final id = state.pathParameters['id'] ?? '';
                  return DisposalDetailScreen(id: id);
                },
              ),
            ],
          ),

          // Loans (Peminjaman)
          GoRoute(
            path: '/admin/loans',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: LoanListScreen(),
            ),
            routes: [
              GoRoute(
                path: 'new',
                builder: (context, state) => const LoanFormScreen(),
              ),
              GoRoute(
                path: 'detail/:id',
                builder: (context, state) {
                  final id = state.pathParameters['id'] ?? '';
                  return LoanDetailScreen(id: id);
                },
              ),
            ],
          ),

          // Cleaners
          GoRoute(
            path: '/admin/cleaners',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: CleanerManagementScreen(),
            ),
          ),
          
          // Analytics
          GoRoute(
            path: '/admin/analytics',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AnalyticsReportScreen(),
            ),
          ),

          // Inventory (Consumables)
          GoRoute(
            path: '/admin/inventory',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: InventoryListScreen(),
            ),
            routes: [
                  GoRoute(
                    path: 'requests', // /admin/inventory/requests
                    builder: (context, state) => const InventoryRequestListScreen(),
                  ),
                  GoRoute(
                    path: 'new', // /admin/inventory/new
                    builder: (context, state) => const InventoryAddEditScreen(),
                  ),
              GoRoute(
                path: 'edit/:id',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  // Fetch logic or pass simple id
                  return InventoryAddEditScreen(itemId: id);
                },
              ),
              GoRoute(
                path: 'detail/:id',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return InventoryDetailScreen(itemId: id);
                },
              ),
            ],
          ),

          // Helpdesk (Refactored Maintenance)
          GoRoute(
            path: '/admin/helpdesk',
            pageBuilder: (context, state) {
              return const NoTransitionPage(
                child: HelpdeskScreen(initialType: null), // Command Center
              );
            },
            routes: [
              GoRoute(
                path: 'kerusakan',
                pageBuilder: (context, state) => CustomTransitionPage(
                  key: state.pageKey,
                  transitionDuration: const Duration(milliseconds: 800),
                  reverseTransitionDuration: const Duration(milliseconds: 800),
                  child: const HelpdeskScreen(initialType: 'kerusakan'),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    const begin = Offset(1.0, 0.0);
                    const end = Offset.zero;
                    const curve = Curves.easeInOut;
                    var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                    return SlideTransition(position: animation.drive(tween), child: child);
                  },
                ),
              ),
              GoRoute(
                path: 'kebersihan',
                pageBuilder: (context, state) => CustomTransitionPage(
                  key: state.pageKey,
                  transitionDuration: const Duration(milliseconds: 800),
                  reverseTransitionDuration: const Duration(milliseconds: 800),
                  child: const HelpdeskScreen(initialType: 'kebersihan'),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    const begin = Offset(1.0, 0.0);
                    const end = Offset.zero;
                    const curve = Curves.easeInOut;
                    var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                    return SlideTransition(position: animation.drive(tween), child: child);
                  },
                ),
              ),
              GoRoute(
                path: 'stok',
                pageBuilder: (context, state) => CustomTransitionPage(
                  key: state.pageKey,
                  transitionDuration: const Duration(milliseconds: 800),
                  reverseTransitionDuration: const Duration(milliseconds: 800),
                  child: const HelpdeskScreen(initialType: 'stock_request'),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    const begin = Offset(1.0, 0.0);
                    const end = Offset.zero;
                    const curve = Curves.easeInOut;
                    var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                    return SlideTransition(position: animation.drive(tween), child: child);
                  },
                ),
              ),
              // Subroutes for Maintenance forms
               GoRoute(
                path: 'new',
                builder: (context, state) => const MaintenanceRequestForm(),
              ),
              GoRoute(
                path: 'edit/:id',
                builder: (context, state) {
                    final id = state.pathParameters['id'];
                    return MaintenanceRequestForm(id: id);
                },
              ),
              GoRoute(
                path: 'detail/:id',
                builder: (context, state) {
                   final id = state.pathParameters['id'];
                   if (id == null) return const Scaffold(body: Center(child: Text("Error: No ID")));
                   return MaintenanceDetailScreen(id: id);
                 }
              ),
            ],
          ),

          // Ticket Form (Admin Context)
          GoRoute(
            path: '/admin/ticket/new',
            pageBuilder: (context, state) => NoTransitionPage(
              child: TicketFormScreen(
                initialType: state.extra as TicketType?,
              ),
            ),
          ),

          // Loans (Peminjaman)
          GoRoute(
            path: '/admin/loans',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: LoanListScreen(),
            ),
            routes: [
                GoRoute(
                  path: 'new',
                  builder: (context, state) => const LoanFormScreen(),
                ),
                GoRoute(
                  path: 'detail/:id',
                  builder: (context, state) {
                    final id = state.pathParameters['id']!;
                    return LoanDetailScreen(id: id);
                  },
                ),
            ]
          ),
          
          // Bookings (Internal)
          GoRoute(
            path: '/admin/bookings',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: BookingListScreen(),
            ),
            routes: [
              GoRoute(
                path: 'new',
                builder: (context, state) => const BookingFormScreen(),
              ),
            ],
          ),

          // Disposal (Penghapusan)
          GoRoute(
            path: '/admin/disposal',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: DisposalListScreen(),
            ),
            routes: [
              GoRoute(
                path: 'new',
                builder: (context, state) => const DisposalFormScreen(),
              ),
            ],
          ),

          // Mutation (Mutasi Aset)
          GoRoute(
            path: '/admin/transactions/mutation',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: MutationListScreen(),
            ),
            routes: [
              GoRoute(
                path: 'create',
                builder: (context, state) => const MutationFormScreen(),
              ),
              GoRoute(
                path: ':id',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return MutationDetailScreen(mutationId: id);
                },
              ),
            ],
          ),
          
          // Settings (General Only)
          GoRoute(
            path: '/admin/settings',
            pageBuilder: (context, state) => const NoTransitionPage(
               child: AdminSettingsScreen(),
            ),
          ),
          
          // Profile (Dedicated)
          GoRoute(
            path: '/admin/profile',
            pageBuilder: (context, state) => const NoTransitionPage(
               child: ProfileScreen(),
            ),
          ),

          // Notification Center
          GoRoute(
            path: '/admin/notifications',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: NotificationCenterScreen(),
            ),
          ),

          // Reports (Catalog)
          GoRoute(
            path: '/admin/reports',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ReportCenterScreen(),
            ),
            routes: [
              GoRoute(
                path: 'preview',
                parentNavigatorKey: _rootNavigatorKey, // Hide Shell/Menu
                builder: (context, state) {
                  final extra = state.extra as Map<String, dynamic>?;
                   return ReportPreviewScreen(
                      title: extra?['title'] as String? ?? 'Preview',
                      pdfBytes: extra?['pdfBytes'] as Uint8List? ?? Uint8List(0),
                   );
                },
              ),
            ],
          ),
          GoRoute(
            path: '/admin/reports/stock-movement',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: StockMovementReportScreen(),
            ),
          ),
          
          // Ticket Analytics
          GoRoute(
            path: '/admin/analytics/tickets',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: TicketAnalyticsScreen(),
            ),
          ),
          
          // User Management (Dedicated Screen)
          GoRoute(
            path: '/admin/users',
             pageBuilder: (context, state) => const NoTransitionPage(
              child: AdminUserManagementScreen(),
            ),
          ),
          


          // ==================== CONSOLE ROUTES (WEB PORTAL FOR ALL ROLES) ====================
          // These routes are INSIDE the ShellRoute, so they get the Admin Sidebar + Header

          // Console: Cleaner Dashboard (Web View)
          GoRoute(
            path: '/console/cleaner/dashboard',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: WebCleanerDashboard(), // Desktop-optimized Cleaner Dashboard
            ),
          ),
          GoRoute(
            path: '/console/cleaner/schedule',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: CleanerScheduleScreen(),
            ),
          ),
          GoRoute(
            path: '/console/cleaner/profile',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ProfileScreen(),
            ),
          ),
          GoRoute(
            path: '/console/cleaner/settings',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AdminSettingsScreen(),
            ),
          ),
          GoRoute(
            path: '/console/cleaner/pending',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: CleanerPendingScreen(),
            ),
          ),
          GoRoute(
            path: '/console/cleaner/my-tasks',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: CleanerTaskScreen(),
            ),
          ),
           GoRoute(
            path: '/console/cleaner/create_request',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: InventoryRequestFormScreen(),
            ),
          ),
          GoRoute(
            path: '/console/cleaner/notifications',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: NotificationCenterScreen(fallbackRoute: '/console/cleaner/dashboard'),
            ),
          ),

          // Console: Teknisi Dashboard (Web View)
          GoRoute(
            path: '/console/teknisi/dashboard',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: WebTeknisiDashboard(), 
            ),
          ),
          GoRoute(
            path: '/console/teknisi/notifications',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: NotificationCenterScreen(fallbackRoute: '/console/teknisi/dashboard'),
            ),
          ),

          // Console: Employee Dashboard (Web View)
          GoRoute(
            path: '/console/employee/dashboard',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: WebEmployeeDashboard(), 
            ),
          ),
        ],
      ),

      // Cleaner Routes (Outside Admin Shell)
      GoRoute(
        path: '/cleaner/dashboard', // Changed from home to dashboard to match context
        builder: (context, state) => const CleanerHomeScreen(),
      ),
      GoRoute(
        path: '/cleaner/schedule',
        builder: (context, state) => const CleanerScheduleScreen(),
      ),
      GoRoute(
        path: '/cleaner/my-tasks',
        builder: (context, state) => const CleanerTaskScreen(),
      ),
      GoRoute(
        path: '/cleaner/task/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return CleanerTaskDetailScreen(ticketId: id);
        },
      ),

      // Employee Routes (Outside Admin Shell)
      GoRoute(
        path: '/employee/dashboard',
        builder: (context, state) => const EmployeeHomeScreenEnhanced(),
      ),
      GoRoute(
        path: '/employee/quick-menu',
        builder: (context, state) => const QuickMenuScreen(), // Unified, role-aware
      ),
      GoRoute(
        path: '/create_request',
        builder: (context, state) => const InventoryRequestFormScreen(),
      ),
      GoRoute(
        path: '/request_history',
        builder: (context, state) => const InventoryRequestHistoryScreen(),
      ),

      // Kasubbag Routes (Outside Admin Shell for now - will have own shell later)
      GoRoute(
        path: '/kasubbag/dashboard',
        builder: (context, state) => const KasubbagApprovalDashboard(),
      ),

      // Teknisi Routes (Outside Admin Shell)
      GoRoute(
        path: '/teknisi/dashboard',
        builder: (context, state) => const TeknisiHomeScreen(),
      ),
      GoRoute(
        path: '/teknisi/inbox',
        builder: (context, state) => const TeknisiInboxScreen(),
      ),
      GoRoute(
        path: '/teknisi/schedule',
        builder: (context, state) => const TeknisiScheduleScreen(),
      ),
      GoRoute(
        path: '/teknisi/task/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return TeknisiTaskDetailScreen(ticketId: id);
        },
      ),
      GoRoute(
        path: '/teknisi/my-tasks',
        builder: (context, state) => const TeknisiTaskScreen(),
      ),

      // Ticket Form (Universal)
      GoRoute(
        path: '/ticket/new',
        builder: (context, state) => TicketFormScreen(
          initialType: state.extra as TicketType?,
        ),
      ),
    ],
  );
});
