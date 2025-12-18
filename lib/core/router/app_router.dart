import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Screens
import '../../screens/auth/login_screen.dart';
import '../../screens/web_admin/dashboard/admin_dashboard.dart';
import '../../screens/web_admin/dashboard/activity_log_screen.dart';
// import '../../screens/web_admin/admin_dashboard_screen.dart';
import '../../screens/cleaner/cleaner_home_screen.dart';
import '../../screens/employee/employee_home_screen_enhanced.dart';

// Master Data Screens
import '../../screens/web_admin/master_data/master_pegawai_screen.dart';
import '../../screens/web_admin/master_data/master_organisasi_screen.dart';
import '../../screens/web_admin/master_data/master_anggaran_screen.dart';
import '../../screens/web_admin/master_data/master_aset_screen.dart';
import '../../screens/web_admin/master_data/master_vendor_screen.dart';

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

import '../../screens/web_admin/cleaner_management_screen.dart';
import '../../screens/web_admin/settings/admin_settings_screen.dart';
import '../../screens/web_admin/reports/report_center_screen.dart';
import '../../screens/web_admin/notifications/notification_center_screen.dart';
// import '../../screens/web_admin/user_management_screen.dart'; // Deprecated

// Layouts
import '../../widgets/web_admin/layout/admin_shell_layout.dart';

// Ticketing System
import '../../screens/shared/ticket_form_screen.dart';
import '../../screens/shared/inbox_screen.dart';
import '../../screens/kasubbag/kasubbag_approval_dashboard.dart';


final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _adminShellNavigatorKey = GlobalKey<NavigatorState>();

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    routes: [
      // Splash
      GoRoute(
        path: '/',
        builder: (context, state) => const LoginScreen(), 
      ),
      
      // Auth
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),

      // Admin Shell Route
      ShellRoute(
        navigatorKey: _adminShellNavigatorKey,
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
          
          // Settings
          GoRoute(
            path: '/admin/settings',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AdminSettingsScreen(),
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
          ),
          
          // Legacy User Management (Redirect to Settings)
          GoRoute(
            path: '/admin/users',
             redirect: (_, __) => '/admin/settings', // Users are now in Settings
             pageBuilder: (context, state) => const NoTransitionPage(
              child: AdminSettingsScreen(),
            ),
          ),
        ],
      ),

      // Cleaner Routes (Outside Admin Shell)
      GoRoute(
        path: '/cleaner/dashboard', // Changed from home to dashboard to match context
        builder: (context, state) => const CleanerHomeScreen(),
      ),

      // Employee Routes (Outside Admin Shell)
      GoRoute(
        path: '/employee/dashboard',
        builder: (context, state) => const EmployeeHomeScreenEnhanced(),
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
        builder: (context, state) => const InboxScreen(role: 'teknisi'),
      ),

      // Ticket Form (Universal)
      GoRoute(
        path: '/ticket/new',
        builder: (context, state) => TicketFormScreen(
          initialType: state.extra as TicketType?,
        ),
      ),
    ],
    // Role-based redirect logic
    redirect: (context, state) async {
      final session = Supabase.instance.client.auth.currentSession;
      final isLoggedIn = session != null;
      final isLoginRoute = state.matchedLocation == '/login' || state.matchedLocation == '/';

      // Not logged in -> go to login
      if (!isLoggedIn && !isLoginRoute) {
        return '/login';
      }

      // Logged in and on login page -> redirect based on role
      if (isLoggedIn && isLoginRoute) {
        try {
          final userId = session.user.id;
          final response = await Supabase.instance.client
              .from('user_roles')
              .select('role')
              .eq('user_id', userId)
              .maybeSingle();

          final role = response?['role'] as String? ?? 'employee';

          switch (role) {
            case 'admin': return '/admin/dashboard';
            case 'kasubbag': return '/kasubbag/dashboard';
            case 'teknisi': return '/teknisi/dashboard';
            case 'cleaner': return '/cleaner/dashboard';
            case 'employee': return '/employee/dashboard';
            default: return '/employee/dashboard';
          }
        } catch (e) {
          // Fallback to admin if role check fails (for existing admins)
          return '/admin/dashboard';
        }
      }

      return null; // No redirect
    },
  );
});
