enum CardRole {
  token,
  meldPart,
  meldResult,
  comboPiece,
}

extension CardRoleEx on CardRole {
  String get code {
    switch (this) {
      case CardRole.token:
        return 'token';
      case CardRole.meldPart:
        return 'meld_part';
      case CardRole.meldResult:
        return 'meld_result';
      case CardRole.comboPiece:
        return 'combo_piece';
    }
  }
}

CardRole? parseCardRole(dynamic object,) {
  switch ('$object'.toLowerCase()) {
    case 'token': return CardRole.token;
    case 'meld_part': return CardRole.meldPart;
    case 'meld_result': return CardRole.meldResult;
    case 'combo_piece': return CardRole.comboPiece;
    default: return null;
  }
}