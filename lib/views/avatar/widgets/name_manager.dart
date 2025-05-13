import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/authentication_provider.dart';

class NameManager {
  final WidgetRef ref;
  String _shortName = 'Name not available';
  bool _showFullName = true;

  NameManager(this.ref) {
    _updateShortName();
  }

  bool get showFullName => _showFullName;
  String get shortName => _shortName;

  void setShowFullName(bool value) {
    _showFullName = value;
  }

  void setFirstLastInitial() {
    _showFullName = false;
    final authState = ref.read(authenticationProvider);
    final userInfo = authState.userInfo;
    final firstName = userInfo?['first_name'] as String?;
    final lastName = userInfo?['last_name'] as String?;
    if (firstName != null && lastName != null) {
      _shortName = "$firstName ${lastName[0]}.";
    }
  }

  void _updateShortName() {
    final authState = ref.read(authenticationProvider);
    final userInfo = authState.userInfo;
    final firstName = userInfo?['first_name'] as String?;
    final lastName = userInfo?['last_name'] as String?;

    if (firstName == null || lastName == null) {
      _shortName = 'Name not available';
      return;
    }
    
    final first = firstName.length >= 3 ? firstName.substring(0, 3) : firstName;
    final last = lastName.length >= 3 ? lastName.substring(0, 3) : lastName;
    _shortName = "$first$last";
  }

  String get fullName {
    final authState = ref.read(authenticationProvider);
    final userInfo = authState.userInfo;
    
    print('UserInfo: $userInfo');
    
    final firstName = userInfo?['first_name'] as String?;
    final lastName = userInfo?['last_name'] as String?;

    if (firstName == null || lastName == null) {
      print('Name is null - firstName: $firstName, lastName: $lastName');
      return 'Name not available';
    }
    return "$firstName $lastName";
  }

  String get displayName {
    if (_showFullName) {
      return fullName;
    } else {
      return _shortName;
    }
  }
} 