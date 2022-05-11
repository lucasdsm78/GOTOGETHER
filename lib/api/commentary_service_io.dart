import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:go_together/helper/parse_helper.dart';
import 'package:go_together/models/signal.dart';
import 'package:go_together/helper/api.dart';

import '../models/commentary.dart';

class CommentaryServiceApi {
  final api = Api();

  Future<Commentary> add(Commentary commentary) async {
    print(commentary.toJson());
    final response = await api.client
        .post(Uri.parse(api.host + '/commentaries'),
      headers: api.mainHeader,
      body: commentary.toJson(),
    );
    if (response.statusCode == 201) {
      return Commentary.fromJson(jsonDecode(response.body)["success"]["last_insert"]);
    } else {
      throw Exception('Failed to create commentary.');
    }
  }

}