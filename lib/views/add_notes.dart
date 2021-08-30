import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:notes/database/database_helper.dart';
import 'package:notes/model/note_model.dart';
import 'package:notes/views/home_page.dart';

class AddNotes extends StatefulWidget {
  final Note? note;
  final Function? updateNoteList;

  AddNotes({this.note, this.updateNoteList});

  @override
  _AddNotesState createState() => _AddNotesState();
}

class _AddNotesState extends State<AddNotes> {

  var titleController = TextEditingController();
  var dateController = TextEditingController();
  var descriptionController = TextEditingController();


  DateTime selectedDate = DateTime.now();
  final dateFormatter = DateFormat('MMM dd, yyyy');
  final priorities = ['Low', 'Medium', 'High'];
  String priority = 'Low';

  void _handleDatePicker() async {

    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2100));
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
      });
    dateController.text = dateFormatter.format(selectedDate);
  }

  void _saveData() async {
    if (widget.note == null) {
      String _title = titleController.text.toString();
      String _description = descriptionController.text.toString();
      String _priority = priority.toString();
      Note note = Note(title: _title,
          date: selectedDate,
          priority: _priority,
          status: 0,
          description: _description);
      await DatabaseHelper.instance.insert(note);

      Navigator.pushAndRemoveUntil(
          context, MaterialPageRoute(builder: (context) => HomePage()), (
          route) => false);
    }else{
      Note note = Note(
          title: titleController.text.toString(),
          date: selectedDate,
          priority: priority,
          status: widget.note!.status,
          description: descriptionController.text.toString(),
      );
      note.id = widget.note!.id;

      final result = await DatabaseHelper.instance.update(note);
      print(result);

      Navigator.pushAndRemoveUntil(
          context, MaterialPageRoute(builder: (context) => HomePage()), (
          route) => false);

    }

    widget.updateNoteList!();
  }

  @override
  void initState() {
    super.initState();
    if(widget.note != null){
      titleController = TextEditingController(text: widget.note!.title);
      dateController = TextEditingController(text: dateFormatter.format(widget.note!.date!));
      descriptionController = TextEditingController(text: widget.note!.description);
      priority = widget.note!.priority!;
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Notes'),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Add Notes', style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),),
                SizedBox(height: 20,),
                TextField(
                  controller: titleController,
                  style: TextStyle(fontSize: 18),
                  decoration: new InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)
                      ),
                      contentPadding: EdgeInsets.all(15.0),
                    labelText: 'Title',
                    labelStyle: TextStyle(fontSize: 18),
                ),
            ),
                SizedBox(height: 20,),

                TextField(
                  controller: dateController,
                  style: TextStyle(fontSize: 18),
                  autocorrect: false,
                  readOnly: true,
                  onTap: _handleDatePicker,
                  decoration: new InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)
                    ),
                    contentPadding: EdgeInsets.all(15.0),
                    labelText: 'Date',
                    labelStyle: TextStyle(fontSize: 18),
                  ),
                ),
                SizedBox(height: 20,),

                DropdownButtonFormField(
                  isExpanded: true,
                  decoration: new InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)
                    ),
                    contentPadding: EdgeInsets.all(15.0),
                    labelText: 'Priority',
                    labelStyle: TextStyle(fontSize: 18),
                  ),
                  items: priorities.map((String value) {
                    return DropdownMenuItem<String>(
                        value: value,
                        child: new Text(value),
                      );
                    }).toList(),
                    style: TextStyle(fontSize: 18,color: Colors.black),
                    value: priority,
                    onChanged: (value) {
                      setState(() {
                        priority = value.toString();
                      });
                    },

                ),
                SizedBox(height: 20,),

                TextField(
                  controller: descriptionController,
                  style: TextStyle(fontSize: 18),
                  autocorrect: false,
                  maxLength: 1000,
                  maxLines: 5,
                  decoration: new InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)
                    ),
                    contentPadding: EdgeInsets.all(15.0),
                    labelText: 'Description',
                    labelStyle: TextStyle(fontSize: 18),
                  ),
                ),
                SizedBox(height: 20,),

                SizedBox(width: double.infinity,
                child: ElevatedButton(
                  onPressed: (){
                    _validation();
                  },
                  child: Text(widget.note != null? 'Update':'Save'),
                ),),

                SizedBox(height: 10,),
                SizedBox(width: double.infinity,
                  child: widget.note != null ? ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.red,
                    ),// foreground
                    onPressed: (){
                      _deleteNote();
                    },
                    child: Text('Delete'),
                  ) : null,)


              ],
            ),

          ),
        ),
      ),
    );
  }

  void _validation(){
    if(titleController.text.isEmpty){
      Fluttertoast.showToast(msg: 'Please fill Title...');
    }else if(dateController.text.isEmpty){
      Fluttertoast.showToast(msg: 'Please select Date...');
    }else if(descriptionController.text.isEmpty){
      Fluttertoast.showToast(msg: 'Please fill Description...');
    }else{
      _saveData();
    }
  }

  void _deleteNote() async {
   await DatabaseHelper.instance.delete(widget.note!.id!);
    Navigator.pushAndRemoveUntil(
        context, MaterialPageRoute(builder: (context) => HomePage()), (
        route) => false);
  }

}
