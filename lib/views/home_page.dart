import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notes/database/database_helper.dart';
import 'package:notes/model/note_model.dart';
import 'package:notes/views/add_notes.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {


  late Future<List<Note>> _noteList;

  final DateFormat _dateFormatter = DateFormat('MMM dd, yyyy');

  final _databaseHelper = DatabaseHelper.instance;

  _updateNoteList(){
    _noteList = _databaseHelper.getNoteList();
  }

  @override
  void initState() {
    super.initState();
    _updateNoteList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notepad++'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => AddNotes()));
        },
        child: Icon(Icons.add),
      ),
      body: FutureBuilder(
        future: _noteList,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {

          if(!snapshot.hasData){
            return Center(child: CircularProgressIndicator());
          }

          final int completeNoteCount = snapshot.data!.where((Note note) => note.status ==1).length;

          return ListView.builder(
              itemCount: snapshot.data!.length +1,
              itemBuilder: (context, index) {
                return index == 0 ? Container(
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('My Notes', style: TextStyle(fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Theme
                              .of(context)
                              .primaryColor),),
                      SizedBox(height: 10,),
                      Text('$completeNoteCount of  ${snapshot.data.length}', style: TextStyle(fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Theme
                              .of(context)
                              .primaryColor),),
                    ],
                  ),
                ) :
                _buildNote(snapshot.data![index-1]);
              });
        }
      ),
    );
  }

  Widget _buildNote(Note note){

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        children: [
          ListTile(
            title: Text(note.title!, style: TextStyle(
              fontSize: 18,
              decoration: note.status == 0 ? TextDecoration.none :TextDecoration.lineThrough
            ),),
            subtitle: Text('${_dateFormatter.format(note.date!)} - ${note.priority}', style: TextStyle(fontSize: 15,
                decoration: note.status == 0 ? TextDecoration.none :TextDecoration.lineThrough
            ),),
            trailing: Checkbox(
              value: note.status == 1 ? true : false,
              activeColor: Theme
                  .of(context)
                  .primaryColor,
              onChanged: (value) {
                note.status = value! ? 1: 0;
                _databaseHelper.update(note);
                setState(() {
                  _updateNoteList();
                });
              },),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AddNotes(note: note, updateNoteList: _updateNoteList(),))),
          ),
          Divider(),
        ],
      ),);

  }

}
