import 'package:go_together/models/commentary.dart';
import '../api/commentary_service_io.dart';

class CommentaryUseCase {
  CommentaryServiceApi api = CommentaryServiceApi();

  Future<Commentary?> add(Commentary commentary) async {
    return api.add(commentary).then((value) => value);
  }
}
