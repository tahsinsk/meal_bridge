/// Configuration for the "Generate with AI" recipe feature (Google Gemini).
///
/// TODO(you): paste your own Gemini API key below — get one free at
/// https://aistudio.google.com/apikey.
///
/// SECURITY WARNING: this key is compiled directly into the app binary.
/// That's fine for personal use or handing the app to a few people you
/// trust, but it is NOT safe for a public App Store/Play Store release —
/// anyone can extract a hardcoded key from the binary and spend your quota
/// (or run up billing, if the key is ever attached to a paid project).
/// Before any public release, move this to either:
///   1. A backend proxy: the app calls your server, your server holds the
///      key and calls Gemini, or
///   2. A user-supplied key entered in Settings and stored locally, so each
///      user spends their own quota instead of yours.
class AiConfig {
  static const String geminiApiKey = 'YOUR_API_KEY_HERE';

  /// Tried first for every generation request.
  ///
  /// Was gemini-2.5-flash, but that (and gemini-2.5-flash-lite) returned
  /// HTTP 404 as of 2026-08 — Google retired both for new callers in favor
  /// of the 3.x line. Confirmed gemini-3.6-flash/gemini-3.5-flash-lite are
  /// live on this key's ListModels and both accept our exact
  /// responseSchema request before hardcoding them here.
  static const String model = 'gemini-3.6-flash';

  /// Used only if [model] fails (e.g. not available on this API key/tier).
  static const String fallbackModel = 'gemini-3.5-flash-lite';
}
