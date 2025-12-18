// Stub for non-web platforms

void downloadFile(List<int> bytes, String fileName) {
  // No-op on non-web platforms
  // File saving should be handled differently (e.g., using path_provider)
  throw UnsupportedError('downloadFile is only supported on web');
}
