import 'package:opennutritracker/core/utils/hive_db_provider.dart';
import 'package:logging/logging.dart';
import 'package:opennutritracker/core/data/dbo/user_dbo.dart';

class UserDataSource {
  final String _userKey;
  final log = Logger('UserDataSource');
  final HiveDBProvider _hive;

  UserDataSource(this._hive, this._userKey);

  Future<void> saveUserData(UserDBO userDBO) async {
    log.fine('Updating user in db');
    await _hive.userBox.put(_userKey, userDBO);
  }

  Future<bool> hasUserData() async => _hive.userBox.containsKey(_userKey);

  Future<UserDBO> getUserData() async {
    return _hive.userBox.get(_userKey)!;
  }
}
