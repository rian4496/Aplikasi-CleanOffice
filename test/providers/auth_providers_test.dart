import 'package:aplikasi_cleanoffice/core/error/exceptions.dart';
import 'package:aplikasi_cleanoffice/providers/riverpod/auth_providers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Jalankan `dart run build_runner build` untuk membuat file mock
import 'auth_providers_test.mocks.dart' as mocks;

// Anotasi untuk memberitahu mockito kelas mana yang harus di-mock
@GenerateMocks([FirebaseAuth, User, UserCredential])
void main() {
  // Deklarasikan variabel mock yang akan kita gunakan di semua tes
  late mocks.MockFirebaseAuth mockAuth;
  late mocks.MockUser mockUser;
  late ProviderContainer container;
  late List<AsyncValue<void>> states;

  // setUp dijalankan sebelum setiap tes
  setUp(() {
    // Inisialisasi mock object
    mockAuth = mocks.MockFirebaseAuth();
    mockUser = mocks.MockUser();
    states = [];

    // Buat ProviderContainer dan override provider asli dengan mock kita
    container = ProviderContainer(
      overrides: [
        firebaseAuthProvider.overrideWithValue(mockAuth),
      ],
    );

    // Tambahkan listener untuk merekam setiap perubahan state pada notifier
    container.listen<AsyncValue<void>>(
      authActionsProvider,
      (previous, next) {
        states.add(next);
      },
      fireImmediately: true,
    );
  });

  // tearDown dijalankan setelah setiap tes untuk membersihkan
  tearDown(() {
    container.dispose();
  });

  group('AuthActionsNotifier - changePassword', () {
    const currentPassword = 'oldPassword123';
    const newPassword = 'newPassword456';
    const email = 'test@example.com';

    // Tes untuk skenario sukses
    test(
        'should emit [loading, data] on successful password change',
        () async {
      // ARRANGE (Persiapan)
      // 1. Atur perilaku mock: jika `currentUser` dipanggil, kembalikan `mockUser`
      when(mockAuth.currentUser).thenReturn(mockUser);
      // 2. Atur perilaku mock: jika `email` dipanggil pada `mockUser`, kembalikan email
      when(mockUser.email).thenReturn(email);
      when(mockUser.uid).thenReturn('some-uid');
      // 3. Atur perilaku mock: jika `reauthenticateWithCredential` dipanggil, selesaikan Future (berhasil)
      // Metode ini mengembalikan Future<UserCredential>, jadi kita kembalikan mock UserCredential.
      when(mockUser.reauthenticateWithCredential(any))
          .thenAnswer((_) async => mocks.MockUserCredential());
      // 4. Atur perilaku mock: jika `updatePassword` dipanggil, selesaikan Future (berhasil)
      // Metode ini mengembalikan Future<void>, jadi kita gunakan async {}
      when(mockUser.updatePassword(any)).thenAnswer((_) async {});

      // ACT (Tindakan)
      // Panggil metode yang ingin kita uji
      await container.read(authActionsProvider.notifier).changePassword(
            currentPassword: currentPassword,
            newPassword: newPassword,
          );

      // ASSERT (Verifikasi)
      // 1. Verifikasi bahwa state berubah sesuai urutan yang diharapkan:
      //    - State awal (data)
      //    - State loading
      //    - State akhir (data lagi, menandakan sukses)
      expect(states, [
        const AsyncData<void>(null),
        const AsyncLoading<void>(),
        const AsyncData<void>(null),
      ]);

      // 2. Verifikasi bahwa metode re-autentikasi dipanggil tepat 1 kali.
      verify(mockUser.reauthenticateWithCredential(any)).called(1);
      // 3. Verifikasi bahwa metode update password dipanggil tepat 1 kali.
      verify(mockUser.updatePassword(newPassword)).called(1);
    });

    // Tes untuk skenario gagal (kata sandi salah)
    test(
        'should emit [loading, error] when re-authentication fails',
        () async {
      // ARRANGE (Persiapan)
      // 1. Buat exception palsu yang akan dilempar
      final exception =
          FirebaseAuthException(code: 'wrong-password', message: 'Wrong password');
      // 2. Atur perilaku mock: `currentUser` dan `email` seperti sebelumnya
      when(mockAuth.currentUser).thenReturn(mockUser);
      when(mockUser.email).thenReturn(email);
      when(mockUser.uid).thenReturn('some-uid');
      // 3. Atur perilaku mock: jika `reauthenticateWithCredential` dipanggil, LEMPAR exception
      when(mockUser.reauthenticateWithCredential(any)).thenThrow(exception);
      
      // ACT (Tindakan)
      // Panggil metode yang ingin kita uji. Kita gunakan `expectLater` karena metode ini akan melempar error.
      await expectLater(
        container.read(authActionsProvider.notifier).changePassword(
              currentPassword: currentPassword,
              newPassword: newPassword,
            ),
        // Verifikasi bahwa metode tersebut melempar exception yang sama
        throwsA(isA<AuthException>()),
      );

      // ASSERT (Verifikasi)
      // 1. Verifikasi urutan state: data -> loading -> error
      expect(states.length, 3);
      expect(states[0], isA<AsyncData>());
      expect(states[1], isA<AsyncLoading>());
      expect(states[2], isA<AsyncError>());

      // 2. Verifikasi bahwa state error berisi exception yang benar
      final errorState = states.last as AsyncError;
      expect(errorState.error, isA<AuthException>());

      // 3. Verifikasi bahwa metode `updatePassword` TIDAK PERNAH dipanggil, karena re-autentikasi gagal.
      verifyNever(mockUser.updatePassword(any));
    });
  });
}