class AuthRefreshToken {
  final String refreshToken;

  AuthRefreshToken({required this.refreshToken});

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'refreshToken': refreshToken};
  }

  factory AuthRefreshToken.fromJson(Map<String, dynamic> map) {
    return AuthRefreshToken(refreshToken: map['refreshToken'] as String);
  }
}
