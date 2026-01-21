import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../repositories/master_data_repositories.dart';
import '../../models/master/organization.dart';
import '../../models/master/employee.dart';
import '../../models/master/budget.dart';
import '../../models/master/vendor.dart';
import '../../models/master/asset_category.dart';

// --- REPOSITORIES ---
final organizationRepositoryProvider = Provider<OrganizationRepository>((ref) {
  return OrganizationRepository(Supabase.instance.client);
});
final employeeRepositoryProvider = Provider<EmployeeRepository>((ref) {
  return EmployeeRepository(Supabase.instance.client);
});
final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  return BudgetRepository(Supabase.instance.client);
});
final vendorRepositoryProvider = Provider<VendorRepository>((ref) {
  return VendorRepository(Supabase.instance.client);
});
final assetCategoryRepositoryProvider = Provider<AssetCategoryRepository>((ref) {
  return AssetCategoryRepository(Supabase.instance.client);
});

// --- FUTURES (ONE-TIME FETCH LISTS) ---
// Changed from StreamProvider to FutureProvider to avoid Realtime errors 
// since Replication is not enabled for these tables.

final organizationsProvider = FutureProvider<List<Organization>>((ref) {
  return ref.watch(organizationRepositoryProvider).getOrganizations();
});

final employeesProvider = FutureProvider<List<Employee>>((ref) {
  return ref.watch(employeeRepositoryProvider).getEmployees();
});

// For budgets, we might want to filter by year, but for now allow all.
final budgetsProvider = FutureProvider<List<Budget>>((ref) {
  return ref.watch(budgetRepositoryProvider).getBudgetsByYear(DateTime.now().year);
});

final vendorsProvider = FutureProvider<List<Vendor>>((ref) {
  return ref.watch(vendorRepositoryProvider).getVendors();
});

// NOTE: assetCategoriesProvider is defined in dropdown_providers.dart
// Use that one for dropdowns/lists. The controller below is kept for CRUD operations.

// --- CONTROLLERS (CRUD ACTIONS) ---

// 1. Organization Controller
class OrganizationController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> create(Organization org) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref.read(organizationRepositoryProvider).createOrganization(org));
  }
  
  Future<void> updateOrganization(Organization org) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref.read(organizationRepositoryProvider).updateOrganization(org));
  }

  Future<void> delete(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref.read(organizationRepositoryProvider).deleteOrganization(id));
  }
}
final organizationControllerProvider = AsyncNotifierProvider<OrganizationController, void>(OrganizationController.new);

// 2. Employee Controller
class EmployeeController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> create(Employee emp) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref.read(employeeRepositoryProvider).createEmployee(emp));
  }
  
  Future<void> updateEmployee(Employee emp) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref.read(employeeRepositoryProvider).updateEmployee(emp));
  }

  Future<void> delete(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref.read(employeeRepositoryProvider).deleteEmployee(id));
  }
}
final employeeControllerProvider = AsyncNotifierProvider<EmployeeController, void>(EmployeeController.new);

// 3. Budget Controller
class BudgetController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> create(Budget budget) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref.read(budgetRepositoryProvider).createBudget(budget));
  }
  
  Future<void> updateBudget(Budget budget) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref.read(budgetRepositoryProvider).updateBudget(budget));
  }

  Future<void> delete(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref.read(budgetRepositoryProvider).deleteBudget(id));
  }
}
final budgetControllerProvider = AsyncNotifierProvider<BudgetController, void>(BudgetController.new);

// 4. Vendor Controller
class VendorController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> create(Vendor vendor) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref.read(vendorRepositoryProvider).createVendor(vendor));
  }
  
  Future<void> updateVendor(Vendor vendor) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref.read(vendorRepositoryProvider).updateVendor(vendor));
  }

  Future<void> delete(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref.read(vendorRepositoryProvider).deleteVendor(id));
  }
}
final vendorControllerProvider = AsyncNotifierProvider<VendorController, void>(VendorController.new);

// 5. Asset Category Controller
class AssetCategoryController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> create(AssetCategory category) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref.read(assetCategoryRepositoryProvider).createCategory(category));
  }
  
  Future<void> updateCategory(AssetCategory category) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref.read(assetCategoryRepositoryProvider).updateCategory(category));
  }

  Future<void> delete(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref.read(assetCategoryRepositoryProvider).deleteCategory(id));
  }
}
final assetCategoryControllerProvider = AsyncNotifierProvider<AssetCategoryController, void>(AssetCategoryController.new);
