import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../repositories/master_data_repositories.dart';
import '../models/master/master_data_models.dart';

// Import New Models for Mapping
import '../models/master/employee.dart';
import '../models/master/organization.dart';
import '../models/master/budget.dart';
import '../models/master/vendor.dart';

// --- Dependencies ---
final supabaseClientProvider = Provider((ref) => Supabase.instance.client);

// --- Repositories ---
final employeeRepositoryProvider = Provider((ref) => EmployeeRepository(ref.watch(supabaseClientProvider)));
final organizationRepositoryProvider = Provider((ref) => OrganizationRepository(ref.watch(supabaseClientProvider)));
final budgetRepositoryProvider = Provider((ref) => BudgetRepository(ref.watch(supabaseClientProvider)));
final vendorRepositoryProvider = Provider((ref) => VendorRepository(ref.watch(supabaseClientProvider)));
final assetRepositoryProvider = Provider((ref) => AssetRepository(ref.watch(supabaseClientProvider)));

// --- Data Providers (Read Only / AsyncValue) ---

// 1. Employee List (Adapter: Employee -> MasterPegawai)
final employeeListProvider = FutureProvider<List<MasterPegawai>>((ref) async {
  final employees = await ref.watch(employeeRepositoryProvider).getEmployees();
  return employees.map((e) => MasterPegawai(
    id: e.id,
    nip: e.nip,
    namaLengkap: e.fullName,
    email: e.email,
    noHp: e.phone,
    jabatan: e.position,
    status: e.status,
    unitKerjaId: e.organizationId,
    // Add other fields if needed, or default
  )).toList();
});

// 2. Organization Hierarchy (Adapter: Organization -> MasterOrganisasi)
final organizationListProvider = FutureProvider<List<MasterOrganisasi>>((ref) async {
  final orgs = await ref.watch(organizationRepositoryProvider).getOrganizations();
  return orgs.map((o) => MasterOrganisasi(
    id: o.id,
    code: o.code,
    name: o.name,
    parentId: o.parentId,
    description: null, // New Organization model lacks description
  )).toList();
});

// 3. Budgets (Default Year 2025)
final budgetListProviderFamily = FutureProvider.family<List<MasterAnggaran>, int>((ref, year) async {
  final budgets = await ref.watch(budgetRepositoryProvider).getBudgetsByYear(year);
  return budgets.map((b) => MasterAnggaran(
    id: b.id,
    uraian: b.sourceName,
    kodeRekening: b.id.substring(0, min(8, b.id.length)), // Dummy or use actual if present.
    tahunAnggaran: b.fiscalYear,
    paguAwal: b.totalAmount,
    paguTerpakai: b.totalAmount - b.remainingAmount,
  )).toList();
});

int min(int a, int b) => a < b ? a : b;

// Simple budgetListProvider for current year (used in dashboard)
final budgetListProvider = FutureProvider<List<MasterAnggaran>>((ref) async {
  final currentYear = DateTime.now().year;
  final budgets = await ref.watch(budgetRepositoryProvider).getBudgetsByYear(currentYear);
   return budgets.map((b) => MasterAnggaran(
    id: b.id,
    uraian: b.sourceName,
    kodeRekening: b.id, // Fallback
    tahunAnggaran: b.fiscalYear,
    paguAwal: b.totalAmount,
    paguTerpakai: b.totalAmount - b.remainingAmount,
  )).toList();
});

// 4. Vendors (Adapter: Vendor -> MasterVendor)
final vendorListProvider = FutureProvider<List<MasterVendor>>((ref) async {
  final vendors = await ref.watch(vendorRepositoryProvider).getVendors();
  return vendors.map((v) => MasterVendor(
    id: v.id,
    namaPerusahaan: v.name,
    npwp: v.taxId,
    kontakPerson: v.contactPerson,
    status: v.status == 'active' ? 'verified' : 'unverified', // Mapping logic
  )).toList();
});

// 5. Assets (Searchable) - Uses AssetRepository which returns MasterAset directly.
// 5. Assets (Searchable) - Uses AssetRepository which returns MasterAset directly.
final recentAssetsProvider = FutureProvider<List<MasterAset>>((ref) async {
  return ref.watch(assetRepositoryProvider).searchAssets(''); 
});

// Alias for compatibility with admin_dashboard_provider
final assetListProvider = recentAssetsProvider;
