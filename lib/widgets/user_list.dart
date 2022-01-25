import 'package:flutter/material.dart';
import 'package:go_together/models/user.dart';
import 'package:go_together/usecase/user.dart';
import 'package:go_together/widgets/components/list_view.dart';

class UserList extends StatefulWidget {
  const UserList({Key? key}) : super(key: key);

  @override
  _UserListState createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  final UserUseCase userUseCase = UserUseCase();
  final _biggerFont = const TextStyle(fontSize: 18.0);
  final _saved = <User>{};
  late Future<List<User>> futureUsers;

  @override
  void initState() {
    super.initState();
    futureUsers = userUseCase.getAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('User list'),
          actions: [
            IconButton(
              icon: const Icon(Icons.list),
              onPressed: _pushSaved,
              tooltip: 'See more',
            ),
          ],
        ),
        body: FutureBuilder<List<User>>(
          future: futureUsers,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<User> data = snapshot.data!;
              return ListViewSeparated(data: data, buildListItem: _buildRow);
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }
            return const Center(
              child: CircularProgressIndicator()
            );
          },
        ),
      );
  }

  void _pushSaved() {
    Navigator.of(context).push(
      // Add lines from here...
      MaterialPageRoute<void>(
        builder: (context) {
          final tiles = _saved.map(
                (user) {
              return ListTile(
                title: Text(
                  user.username,
                  style: _biggerFont,
                ),
              );
            },
          );
          final divided = tiles.isNotEmpty
              ? ListTile.divideTiles(
            context: context,
            tiles: tiles,
          ).toList()
              : <Widget>[];

          return Scaffold(
            appBar: AppBar(
              title: const Text('Saved Suggestions'),
            ),
            body: ListView(children: divided),
          );
        },
      ), // ...to here.
    );
  }

  Widget _buildRow(User user) {
    final alreadySaved = _saved.contains(user);
    return ListTile(
      title: Text(
        user.username,
        style: _biggerFont,
      ),
      trailing: Icon(   // NEW from here...
        alreadySaved ? Icons.favorite : Icons.favorite_border,
        color: alreadySaved ? Colors.red : null,
        semanticLabel: alreadySaved ? 'Remove friend' : 'Add friend',
      ),                // ... to here.
      onTap: () {
        setState(() {
          if (alreadySaved) {
            _saved.remove(user);
          } else {
            _saved.add(user);
          }
        });
      },
    );
  }
}
