import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/master/organization.dart';
import '../models/master/employee.dart';
import '../models/master/budget.dart';
import '../models/master/vendor.dart';
import '../models/master/asset_category.dart';
import '../models/master/master_data_models.dart'; // Legacy models for compatibility

// ... (Existing Repositories: Organization, Employee, Budget, Vendor, AssetCategory) ...

// 1. ORGANIZATION REPOSITORY
class OrganizationRepository {
  final SupabaseClient _client;
  OrganizationRepository(this._client);

  Stream<List<Organization>> getOrganizationsStream() {
    return _client
        .from('master_organizations')
        .stream(primaryKey: ['id'])
        .order('code')
        .map((data) => data.map((json) => Organization.fromJson(json)).toList());
  }

  Future<List<Organization>> getOrganizations() async {
    final data = await _client.from('master_organizations').select().order('code');
    return (data as List).map((e) => Organization.fromJson(e)).toList();
  }

  Future<Organization> createOrganization(Organization org) async {
    final json = org.toJson();
    if (org.id.isEmpty) json.remove('id'); 
    final data = await _client.from('master_organizations').insert(json).select().single();
    return Organization.fromJson(data);
  }

  Future<void> updateOrganization(Organization org) async {
    await _client.from('master_organizations').update(org.toJson()).eq('id', org.id);
  }

  Future<void> deleteOrganization(String id) async {
    await _client.from('master_organizations').delete().eq('id', id);
  }
}

// 2. EMPLOYEE REPOSITORY
class EmployeeRepository {
  final SupabaseClient _client;
  EmployeeRepository(this._client);

  Stream<List<Employee>> getEmployeesStream() {
    return _client
        .from('master_employees')
        .stream(primaryKey: ['id'])
        .order('full_name') 
        .map((data) => data.map((json) => Employee.fromJson(json)).toList());
  }

  Future<List<Employee>> getEmployees() async {
    final data = await _client.from('master_employees').select().order('full_name');
    return (data as List).map((e) => Employee.fromJson(e)).toList();
  }

  Future<Employee> createEmployee(Employee employee) async {
    final json = employee.toJson();
    if (employee.id.isEmpty) json.remove('id');
    
    final data = await _client.from('master_employees').insert(json).select().single();
    return Employee.fromJson(data);
  }

  Future<void> updateEmployee(Employee employee) async {
    await _client.from('master_employees').update(employee.toJson()).eq('id', employee.id);
  }

  Future<void> deleteEmployee(String id) async {
    await _client.from('master_employees').delete().eq('id', id);
  }
}

// 3. BUDGET REPOSITORY
class BudgetRepository {
  final SupabaseClient _client;
  BudgetRepository(this._client);

  Stream<List<Budget>> getBudgetsStream({int? fiscalYear}) {
    var query = _client.from('master_budgets').stream(primaryKey: ['id']);
    return query.order('id').map((data) {
      var list = data.map((json) => Budget.fromJson(json)).toList();
      if (fiscalYear != null) {
        list = list.where((b) => b.fiscalYear == fiscalYear).toList();
      }
      return list;
    });
  }

  Future<List<Budget>> getBudgetsByYear(int year) async {
     final data = await _client.from('master_budgets').select().eq('fiscal_year', year);
     return (data as List).map((e) => Budget.fromJson(e)).toList();
  }

  Future<Budget> createBudget(Budget budget) async {
    final json = budget.toJson();
    if (budget.id.isEmpty) json.remove('id');

    final data = await _client.from('master_budgets').insert(json).select().single();
    return Budget.fromJson(data);
  }

  Future<void> updateBudget(Budget budget) async {
    await _client.from('master_budgets').update(budget.toJson()).eq('id', budget.id);
  }

  Future<void> deleteBudget(String id) async {
    await _client.from('master_budgets').delete().eq('id', id);
  }
}

// 4. VENDOR REPOSITORY
class VendorRepository {
  final SupabaseClient _client;
  VendorRepository(this._client);

  Stream<List<Vendor>> getVendorsStream() {
    return _client
        .from('master_vendors')
        .stream(primaryKey: ['id'])
        .order('name')
        .map((data) => data.map((json) => Vendor.fromJson(json)).toList());
  }

  Future<List<Vendor>> getVendors() async {
    final data = await _client.from('master_vendors').select().order('name');
    return (data as List).map((e) => Vendor.fromJson(e)).toList();
  }

  Future<Vendor> createVendor(Vendor vendor) async {
    final json = vendor.toJson();
    if (vendor.id.isEmpty) json.remove('id');

    final data = await _client.from('master_vendors').insert(json).select().single();
    return Vendor.fromJson(data);
  }

  Future<void> updateVendor(Vendor vendor) async {
    await _client.from('master_vendors').update(vendor.toJson()).eq('id', vendor.id);
  }

  Future<void> deleteVendor(String id) async {
    await _client.from('master_vendors').delete().eq('id', id);
  }
}

// 5. ASSET CATEGORY REPOSITORY
class AssetCategoryRepository {
  final SupabaseClient _client;
  AssetCategoryRepository(this._client);

  Stream<List<AssetCategory>> getCategoriesStream() {
    return _client
        .from('master_asset_categories')
        .stream(primaryKey: ['id'])
        .order('code')
        .map((data) => data.map((json) => AssetCategory.fromJson(json)).toList());
  }

  Future<List<AssetCategory>> getCategories() async {
    final data = await _client.from('master_asset_categories').select().order('code');
    return (data as List).map((e) => AssetCategory.fromJson(e)).toList();
  }

  Future<AssetCategory> createCategory(AssetCategory category) async {
    final json = category.toJson();
    if (category.id.isEmpty) json.remove('id');

    final data = await _client.from('master_asset_categories').insert(json).select().single();
    return AssetCategory.fromJson(data);
  }

  Future<void> updateCategory(AssetCategory category) async {
    await _client.from('master_asset_categories').update(category.toJson()).eq('id', category.id);
  }

  Future<void> deleteCategory(String id) async {
    await _client.from('master_asset_categories').delete().eq('id', id);
  }
}

// 6. ASSET REPOSITORY (Legacy/Search)
class AssetRepository {
  final SupabaseClient _client;
  AssetRepository(this._client);

  // Using 'assets' table but mapping to MasterAset simplified model
  Future<List<MasterAset>> searchAssets(String query) async {
    final queryBuilder = _client.from('assets')
      .select('id, qr_code, name, category, condition, location_id, image_url'); 

    // Apply search filter if query is not empty
    final data = query.isEmpty
      ? await queryBuilder.order('name').limit(50)
      : await queryBuilder.ilike('name', '%$query%').limit(20);

    // Map database fields to MasterAset model
    return (data as List).map((e) => MasterAset.fromJson({
      'id': e['id'],
      'asset_code': e['qr_code'],
      'name': e['name'],
      'category': e['category'], 
      'condition_id': e['condition'],
      'location_id': e['location_id'],
      'image_url': e['image_url'],
    })).toList();
  }

  /// Fetch assets for KIB Reporting
  Future<List<MasterAset>> getAssetsForReport({
    required DateTime startDate,
    required DateTime endDate,
    String? category, // 'A', 'B', 'C', or 'all'
  }) async {
    var query = _client.from('assets')
      .select('id, qr_code, name, category, condition, location_id, image_url, created_at') // Added created_at
      .gte('created_at', startDate.toIso8601String())
      .lte('created_at', endDate.toIso8601String());

    // Apply Category Filter logic (KIB A, B, etc.)
    if (category != null && category != 'all') {
      // Logic KIB mapping
      if (category == 'A') { // Tanah
        query = query.ilike('category', '%tanah%');
      } else if (category == 'B') { // Peralatan (bukan tanah, gedung, jalan)
        // Use 'or' with NOT conditions using filter approach
        query = query.filter('category', 'not.ilike', '%tanah%')
                     .filter('category', 'not.ilike', '%gedung%')
                     .filter('category', 'not.ilike', '%bangunan%')
                     .filter('category', 'not.ilike', '%jalan%')
                     .filter('category', 'not.ilike', '%irigasi%');
      } else if (category == 'C') { // Gedung
        query = query.or('category.ilike.%gedung%,category.ilike.%bangunan%');
      }
      // Add more as needed
    }

    final data = await query.order('created_at');

    return (data as List).map((e) => MasterAset.fromJson({
      'id': e['id'],
      'asset_code': e['qr_code'],
      'name': e['name'],
      'category': e['category'], 
      'condition_id': e['condition'],
      'location_id': e['location_id'],
      'image_url': e['image_url'],
    })).toList();
  }
}


