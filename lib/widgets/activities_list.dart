import 'package:flutter/material.dart';
import 'package:go_together/api/objects/activity.dart';
import 'package:go_together/api/requests.dart';

class ActivityList extends StatefulWidget {
  const ActivityList({Key? key}) : super(key: key);

  @override
  _ActivityListState createState() => _ActivityListState();
}

class _ActivityListState extends State<ActivityList> {
  final _biggerFont = const TextStyle(fontSize: 18.0);
  final _saved = <Activity>{};
  late Future<List<Activity>> futureActivities;

  @override
  void initState() {
    super.initState();
    futureActivities = fetchActivities();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity list'),
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: _pushSaved,
            tooltip: 'See more',
          ),
        ],
      ),
      body: FutureBuilder<List<Activity>>(
        future: futureActivities,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Activity> data = snapshot.data!;
            return _buildActivities(data);
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }
          return CircularProgressIndicator();
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
                (activity) {
              return ListTile(
                title: Text(
                  activity.description,
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

  Widget _buildActivities(data) {
    return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: data.length * 2,
        itemBuilder: /*1*/ (context, i) {
          if (i.isOdd) return const Divider(); /*2*/

          final index = i ~/ 2; /*3*/
          return _buildRow(data[index]);
        });
    /*
    Center(
          child: FutureBuilder<Activity>(
            future: futureActivities,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Text(snapshot.data!.Activityname);
              } else if (snapshot.hasError) {
                return Text('${snapshot.error}');
              }

              // By default, show a loading spinner.
              return const CircularProgressIndicator();
            },
          ),
        ),
    * */
  }

  Widget _buildRow(Activity activity) {
    final alreadySaved = _saved.contains(activity);
    return ListTile(
      title: Text(
        activity.description + " - " + activity.hostName,
        style: _biggerFont,
      ),
      subtitle: Text(activity.address),
      trailing: Icon(   // NEW from here...
        alreadySaved ? Icons.favorite : Icons.favorite_border,
        color: alreadySaved ? Colors.red : null,
        semanticLabel: alreadySaved ? 'Remove friend' : 'Add friend',
      ),                // ... to here.
      onTap: () {
        setState(() {
          if (alreadySaved) {
            _saved.remove(activity);
          } else {
            _saved.add(activity);
          }
        });
      },
    );
  }
}
