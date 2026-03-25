class AuthLoginRequest {
  final String email;
  final String senha;

  AuthLoginRequest({required this.email, required this.senha});

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'email': email, 'senha': senha};
  }

  factory AuthLoginRequest.fromJson(Map<String, dynamic> map) {
    return AuthLoginRequest(
      email: map['email'] as String,
      senha: map['senha'] as String,
    );
  }
}
