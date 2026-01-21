import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/agency_profile.dart';
import 'settings_providers.dart';

// AsyncNotifier: Loads from DB, Updates to DB
class AgencyProfileNotifier extends AsyncNotifier<AgencyProfile> {
  @override
  Future<AgencyProfile> build() async {
    final repo = ref.read(agencyRepositoryProvider);
    // Try fetch from DB, if null return default Empty
    final fromDb = await repo.getAgencyProfile();
    return fromDb ?? AgencyProfile.empty();
  }

  Future<void> updateProfile(AgencyProfile newProfile) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(agencyRepositoryProvider);
      return await repo.upsertAgencyProfile(newProfile);
    });
  }
  
  // Update Signers only (helper)
  Future<void> updateSigners(List<AgencySigner> signers) async {
    final current = state.value;
    if (current == null) return;
    
    final newProfile = AgencyProfile(
      id: current.id,
      name: current.name,
      shortName: current.shortName,
      address: current.address,
      phone: current.phone,
      email: current.email,
      website: current.website,
      logoUrl: current.logoUrl,
      city: current.city,
      signers: signers,
    );
     
    await updateProfile(newProfile);
  }
}

final agencyProfileProvider = AsyncNotifierProvider<AgencyProfileNotifier, AgencyProfile>(() {
  return AgencyProfileNotifier();
});
