class AuthUser {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String name;
  final String? phone;
  final String? avatarUrl;
  final bool mfaEnabled;
  final String kycStatus;
  final bool isEmailVerified;
  final DateTime createdAt;

  const AuthUser({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.name,
    this.phone,
    this.avatarUrl,
    this.mfaEnabled = false,
    this.kycStatus = 'unverified',
    this.isEmailVerified = false,
    required this.createdAt,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    final fullName = json['name']?.toString() ?? '';
    final parts = fullName.split(' ');
    return AuthUser(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? (parts.isNotEmpty ? parts.first : ''),
      lastName: json['lastName']?.toString() ?? (parts.length > 1 ? parts.sublist(1).join(' ') : ''),
      name: fullName,
      phone: json['phone']?.toString(),
      avatarUrl: json['avatar']?.toString() ?? json['avatarUrl']?.toString(),
      mfaEnabled: json['mfaEnabled'] as bool? ?? false,
      kycStatus: json['kycStatus']?.toString() ?? 'unverified',
      isEmailVerified: json['isEmailVerified'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'avatar': avatarUrl,
      'mfaEnabled': mfaEnabled,
      'kycStatus': kycStatus,
      'isEmailVerified': isEmailVerified,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  AuthUser copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? name,
    String? phone,
    String? avatarUrl,
    bool? mfaEnabled,
    String? kycStatus,
    bool? isEmailVerified,
    DateTime? createdAt,
  }) {
    return AuthUser(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      mfaEnabled: mfaEnabled ?? this.mfaEnabled,
      kycStatus: kycStatus ?? this.kycStatus,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class LoginRequest {
  final String email;
  final String password;

  const LoginRequest({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}

class RegisterRequest {
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String? phone;

  const RegisterRequest({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    this.phone,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
    };
  }
}

class AuthTokens {
  final String accessToken;
  final String refreshToken;

  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
  });

  factory AuthTokens.fromJson(Map<String, dynamic> json) {
    return AuthTokens(
      accessToken: json['accessToken']?.toString() ?? '',
      refreshToken: json['refreshToken']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
    };
  }
}

/// Result of a login attempt.
/// Either a full [AuthResponse] (tokens + user) or an [MfaChallenge].
sealed class LoginResult {
  const LoginResult();
}

class AuthResponse extends LoginResult {
  final AuthTokens tokens;
  final AuthUser user;

  const AuthResponse({
    required this.tokens,
    required this.user,
  });

  /// Handles both:
  /// - `{ "tokens": {...}, "user": {...} }` (mobile convention)
  /// - `{ "accessToken": "...", "refreshToken": "...", "user": {...} }` (backend)
  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final tokensJson = json['tokens'] as Map<String, dynamic>?;
    return AuthResponse(
      tokens: tokensJson != null
          ? AuthTokens.fromJson(tokensJson)
          : AuthTokens(
              accessToken: json['accessToken']?.toString() ?? '',
              refreshToken: json['refreshToken']?.toString() ?? '',
            ),
      user: AuthUser.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tokens': tokens.toJson(),
      'user': user.toJson(),
    };
  }
}

class MfaChallenge extends LoginResult {
  final String mfaToken;

  const MfaChallenge({required this.mfaToken});

  factory MfaChallenge.fromJson(Map<String, dynamic> json) {
    return MfaChallenge(
      mfaToken: json['mfaToken']?.toString() ?? '',
    );
  }
}
