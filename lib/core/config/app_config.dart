/// Points at the FastAPI payment backend, reached through the ngrok tunnel.
///
/// ⚠️ IMPORTANT — read this before every demo:
/// ngrok's free tier gives a NEW URL every time it's restarted. Before
/// demoing the payment flow, copy the current "Forwarding" URL from your
/// ngrok terminal and paste it below, replacing the whole string. Then do
/// a full app restart (stop + run again) — a hot reload alone will NOT
/// reliably pick up a `const` value change.
class AppConfig {
  AppConfig._();

  static const String backendBaseUrl = 'https://selector-tightrope-shrine.ngrok-free.dev';
}
