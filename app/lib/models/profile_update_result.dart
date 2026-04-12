/// Outcome of saving profile changes from [AuthService.updateProfile].
class ProfileUpdateResult {
  final String? error;

  /// Shown on success (e.g. email verification sent). Only when [error] is null.
  final String? userMessage;

  const ProfileUpdateResult({this.error, this.userMessage});

  bool get isSuccess => error == null;

  factory ProfileUpdateResult.ok({String? userMessage}) =>
      ProfileUpdateResult(error: null, userMessage: userMessage);

  factory ProfileUpdateResult.failure(String message) =>
      ProfileUpdateResult(error: message, userMessage: null);
}
