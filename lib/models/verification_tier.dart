enum VerificationTier {
  unverified,      // Just signed up, no verification
  emailVerified,   // Email verified
  phoneVerified,   // Phone verified
  idVerified,      // ID document verified
  trusted,         // Full trust score threshold reached
}

class VerificationStatus {
  final VerificationTier tier;
  final bool emailVerified;
  final bool phoneVerified;
  final bool idVerified;
  final double trustScore;
  
  const VerificationStatus({
    required this.tier,
    required this.emailVerified,
    required this.phoneVerified,
    required this.idVerified,
    required this.trustScore,
  });
  
  // Feature access permissions
  bool get canBrowse => true; // Everyone can browse
  bool get canViewCircles => emailVerified; // Need email verification
  bool get canJoinCircles => emailVerified && trustScore >= 30;
  bool get canCreateCircles => emailVerified && trustScore >= 40;
  bool get canCreateEvents => emailVerified && trustScore >= 50;
  bool get canSendMessages => emailVerified && trustScore >= 30;
  bool get canAccessPremium => phoneVerified || idVerified;
  bool get canHostLargeEvents => idVerified && trustScore >= 70;
  
  factory VerificationStatus.fromFirestore(Map<String, dynamic> data) {
    final emailVerified = data['emailVerified'] as bool? ?? false;
    final phoneVerified = data['phoneVerified'] as bool? ?? false;
    final idVerified = data['idVerified'] as bool? ?? false;
    final trustScore = (data['trustScore'] as num?)?.toDouble() ?? 50.0;
    
    // Determine tier
    VerificationTier tier;
    if (idVerified) {
      tier = VerificationTier.idVerified;
    } else if (phoneVerified) {
      tier = VerificationTier.phoneVerified;
    } else if (emailVerified) {
      tier = VerificationTier.emailVerified;
    } else {
      tier = VerificationTier.unverified;
    }
    
    if (trustScore >= 80 && idVerified) {
      tier = VerificationTier.trusted;
    }
    
    return VerificationStatus(
      tier: tier,
      emailVerified: emailVerified,
      phoneVerified: phoneVerified,
      idVerified: idVerified,
      trustScore: trustScore,
    );
  }
  
  Map<String, dynamic> toFirestore() {
    return {
      'emailVerified': emailVerified,
      'phoneVerified': phoneVerified,
      'idVerified': idVerified,
      'trustScore': trustScore,
    };
  }
  
  String getTierLabel() {
    switch (tier) {
      case VerificationTier.unverified:
        return 'Unverified';
      case VerificationTier.emailVerified:
        return 'Email Verified';
      case VerificationTier.phoneVerified:
        return 'Phone Verified';
      case VerificationTier.idVerified:
        return 'ID Verified';
      case VerificationTier.trusted:
        return 'Trusted Traveler';
    }
  }
  
  String getNextStep() {
    if (!emailVerified) return 'Verify your email to unlock features';
    if (!phoneVerified) return 'Verify phone for premium access';
    if (!idVerified) return 'Verify ID for full access';
    if (trustScore < 80) return 'Build trust score to become Trusted Traveler';
    return 'All verifications complete!';
  }
}
