import 'package:flutter/material.dart';
import 'package:go_together/models/activity.dart';
import 'package:go_together/api/requests.dart';
import 'package:go_together/widgets/activity.dart';
import 'package:http/http.dart' as http;

class ActivityList extends StatefulWidget {
  const ActivityList({Key? key}) : super(key: key);

  @override
  _ActivityListState createState() => _ActivityListState();
}

class _ActivityListState extends State<ActivityList> {
  final _biggerFont = const TextStyle(fontSize: 18.0);
  final _saved = <Activity>{};
  late Future<List<Activity>> futureActivities;
  int userId = 1;

  @override
  void initState() {
    super.initState();
    futureActivities = fetchActivities(http.Client());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity list'),
        /*actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: _pushSaved,
            tooltip: 'See more',
          ),
        ],*/
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
          return const Center(
              child: CircularProgressIndicator()
          );
        },
      ),
    );
  }

  /*
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
  */
  void _pushDetails(int activityId) {
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
          //return ActivityDetailsScreen(activityId: activityId);
          return  ActivityDetailsScreen(activityId: activityId);//ListView(children: divided)

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
  }

  Widget _buildRow(Activity activity) {
    final alreadySaved = _saved.contains(activity);
    final hasJoin = activity.currentParticipants.contains(userId.toString());
    return ListTile(
      title: Text(
        activity.description + " - " + activity.hostName,
        style: _biggerFont,
      ),
      subtitle: Text(activity.address),
      trailing: Icon(   // NEW from here...
        hasJoin ? Icons.favorite : Icons.favorite_border,
        color: hasJoin ? Colors.red : null,
        semanticLabel: hasJoin ? 'i have join' : 'i have not join',
      ),                // ... to here.
      onTap: () {
        setState(() {
          /*if (alreadySaved) {
            _saved.remove(activity);
          } else {
            _saved.add(activity);
          }*/
          // !snapshot.data!.currentParticipants.contains(userId.toString())
          _pushDetails(activity.id);
        });
      },
    );
  }
}
