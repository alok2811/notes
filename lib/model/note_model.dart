class Note{

  int? id;
  String? title;
  DateTime? date;
  String? priority;
  int? status;
  String? description;

  Note({this.title, this.date, this.priority, this.status, this.description});

  Note.withId({this.id, this.title, this.date, this.priority, this.status, this.description});

  Map<String, dynamic> toMap(){
    final map = Map<String, dynamic>();

    if(id != null){
      map['id'] = id;
    }
    map['title'] = title;
    map['date'] = date!.toIso8601String();
    map['priority'] = priority;
    map['status'] = status;
    map['description'] = description;
    return map;
  }

  factory Note.fromMap(Map<String, dynamic> map){
    return Note.withId(
      id: map['id'],
      title:  map['title'],
      date: DateTime.parse(map['date']),
      priority: map['priority'],
      status: map['status'],
      description: map['description']
    );

  }

}