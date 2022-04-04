
import 'dart:io';

import 'package:go_together/helper/enum/gender.dart';
import 'package:go_together/helper/extensions/date_extension.dart';
import 'package:go_together/models/user.dart';

class Mock {
  static User userGwen = User(
    id:1,
    username:"gwenael95",
    mail:"gwenael.mw@gmail.com",
    role:"ADMIN",
    gender: Gender.male,
    birthday: parseStringToDateTime(DateTime.now().getDbDateTime()),
    availability: Availability(monday: false, wednesday: false),
    friendsList: [4,2,3,11,24,25,15]
  );

  static User user2 = User(
    id:2,
    username:"gwenael2",
    mail:"gwenael.mw@orange.fr",
    role:"USER",
    gender: Gender.male,
    birthday: parseStringToDateTime(DateTime.now().getDbDateTime()),
    availability: Availability(sunday: false),

  );
}
