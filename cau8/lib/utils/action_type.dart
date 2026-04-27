enum ActionType { create, update, delete, read }

extension ActionTypeExt on ActionType {
  String get label {
    switch (this) {
      case ActionType.create: return 'CREATE';
      case ActionType.update: return 'UPDATE';
      case ActionType.delete: return 'DELETE';
      case ActionType.read:   return 'READ';
    }
  }

  String get emoji {
    switch (this) {
      case ActionType.create: return '➕';
      case ActionType.update: return '✏️';
      case ActionType.delete: return '🗑️';
      case ActionType.read:   return '👁️';
    }
  }
}