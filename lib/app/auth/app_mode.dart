enum AppMode {
  partner('partner'),
  scanner('scanner');

  const AppMode(this.appCode);
  final String appCode;

  static AppMode? tryParse(String? value) {
    for (final mode in values) {
      if (mode.appCode == value) return mode;
    }
    return null;
  }
}
