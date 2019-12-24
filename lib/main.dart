import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Air Note',
      theme: ThemeData(
        // This is the theme of your application.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Air Note'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  CollectionReference get notes => Firestore.instance.collection('notes');
  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: _buildBody(context),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await _addNoteDialog(context);
        },
        tooltip: 'Add note',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Widget _buildBody(BuildContext context) {
    return StreamBuilder<QuerySnapshot> (
      stream: notes.snapshots(),
      builder: (context, snapshot) {
        if(!snapshot.hasData) return LinearProgressIndicator();
        
        return _buildList(context, snapshot.data.documents);
      },
    );
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
    return ListView(
      children: snapshot.map((data) => _buildListItem(context, data)).toList(),
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    final record = Record.fromSnapshot(data);
    return Padding(
      key: ValueKey(record.body),
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: Card(
        elevation: 1.0,
        child: ListTile(
          title: Text(record.body),
        ),
      ),
    );
  }

  Future<String> _addNoteDialog(BuildContext context) async {
    String noteText = '';
    return showDialog<String>(context: context,
    barrierDismissible: false,
      builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Add Note"),
        content: new Row(
          children: <Widget>[
            new Expanded(child: new TextField(
              autofocus: true,
              decoration: new InputDecoration(
                  labelText: 'Note', hintText: 'enter text'),
              onChanged: (value) {
                noteText = value;
              },
            ))
          ],
        ),
        actions: <Widget>[
          FlatButton(
            child: const Text('BACK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          FlatButton(
            child: Text("SAVE"),
            onPressed: () {
              notes.add(<String, dynamic> {
                'body': noteText,
                'id': "1" //nothing serious
              });
              Navigator.of(context).pop();
            },
          )
        ],
      );
      }
    );
  }


}

class Record {
  final String body;
  final String id;
  final DocumentReference reference;

  Record.fromMap(Map<String, dynamic> map, {this.reference})
    :assert(map['body'] != null),
    assert(map['id'] != null),
    body = map['body'],
    id = map['id'];

  Record.fromSnapshot(DocumentSnapshot snapshot)
    :this.fromMap(snapshot.data, reference: snapshot.reference);


  @override
  String toString() => "Data: $body - $id";
}
