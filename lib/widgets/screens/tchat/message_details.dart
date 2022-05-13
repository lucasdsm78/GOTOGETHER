import 'dart:developer';


import 'package:flutter/material.dart';
import 'package:go_together/models/messages.dart';
import 'package:go_together/usecase/message.dart';

class MessageDetailsScreen extends StatefulWidget {
  const MessageDetailsScreen({Key? key, required this.id}) : super(key: key);
  final int id;
  static const tag = "message_details";


  @override
  _MessageDetailsScreenState createState() => _MessageDetailsScreenState();
}

class _MessageDetailsScreenState extends State<MessageDetailsScreen> {
  final MessageUseCase messageUseCase = MessageUseCase();
  late Future<List<Message>> futureActivity;

  @override
  void initState() {
    super.initState();
    futureActivity = messageUseCase.getById(widget.id);
    /*getSessionValue("user").then((res){
      setState(() {
        currentUser = res;
      });
    });*/
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails du message'),
      ),
      body: Center(
        child: FutureBuilder<List<Message>>(
          future: futureActivity,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              //return Text(snapshot.data!.description);
              log(snapshot.data!.toString());
              print(snapshot.data!.toString());
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                //mainAxisSize: MainAxisSize.min,
                children: <Widget>[


                  const SizedBox(height: 30),
                ],
              );
            } else if (snapshot.hasError) {
              return Text('${snapshot.error}  ');
            }
            return const Center(
                child: CircularProgressIndicator()
            );
          },
        ),
      ),
    );
  }
}