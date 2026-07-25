/// Centralized discovery configuration constants.
///
/// Move any service discovery/lookup URLs here so they can be reused across
/// the codebase instead of being repeated inline.
///
/// NOTE: Adjust this value for your environment (dev/stage/prod) or wire it
/// up to environment-specific configuration management.
const String kDiscoveryUrl = 'http://127.0.0.1:8080/api/bootstrap';
