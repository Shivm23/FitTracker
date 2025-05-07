import 'package:hive_flutter/hive_flutter.dart';
import 'package:opennutritracker/core/data/data_source/user_weight_dbo.dart';

class UserWeightDataSource {
  final Box<UserWeightDbo> _userWeightBox;

  UserWeightDataSource(this._userWeightBox);

  String _normaliseDateToKey(DateTime date) {
    /* Normalizes the given date to midnight for use as a unique daily key*/
    return DateTime(date.year, date.month, date.day).toString();
  }

  Future<void> addUserWeight(UserWeightDbo userWeightDbo) async {
    /* Use the date at midnight as the key to ensure one entry per day */
    await _userWeightBox.put(
        _normaliseDateToKey(userWeightDbo.date), userWeightDbo);
  }

  Future<void> deleteUserWeightByDate(DateTime dateTime) async {
    await _userWeightBox.delete(_normaliseDateToKey(dateTime));
  }

  Future<UserWeightDbo?> getUserWeightByDate(DateTime dateTime) async {
    return _userWeightBox.get(_normaliseDateToKey(dateTime));
  }

  Future<UserWeightDbo?> getLastSavedUserWeight(DateTime date) async {
    for (int i = _userWeightBox.length - 1; i >= 0; i--) {
      final dbo = _userWeightBox.getAt(i);
      if (dbo != null && !dbo.date.isAfter(date)) {
        return dbo;
      }
    }
    return null;
  }
}
