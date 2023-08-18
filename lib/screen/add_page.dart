import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
class AddTodoPage extends StatefulWidget {
  final Map? todo;
  const AddTodoPage({super.key, this.todo});

  @override
  State<AddTodoPage> createState() => _AddTodoPageState();
}

class _AddTodoPageState extends State<AddTodoPage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  bool isEdit = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final todo = widget.todo;
    if (todo != null){
      isEdit = true;
      final title = todo['title'];
      final description = todo['description'];
      titleController.text = title;
      descriptionController.text = description;
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            isEdit? 'Edit Todo' : 'Add Todo'
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          TextField(
            controller: titleController,
            decoration: InputDecoration(
              hintText: 'Title'
            ),
          ),
          TextField(
            controller: descriptionController,
            keyboardType: TextInputType.multiline,
            decoration: InputDecoration(
              hintText: 'Description'
            ),
            minLines: 5,
            maxLines: 8,
          ),
          SizedBox(height: 20,),
          ElevatedButton(
              onPressed: isEdit? updateData : submitData,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                    isEdit? 'Update' : 'Submit'
                ),
              ),
          ),
        ],
      ),
    );
  }


  Future<void> updateData() async {
    final todo = widget.todo;
    if (todo == null){
      print("you can not call update without todo data");
      return;
    }
    final id = todo['_id'];
    final isCompleted = todo['is_completed'];
    final title = titleController.text;
    final desctription = descriptionController.text;
    final body =
    {
      "title": title,
      "description": desctription,
      "is_completed": isCompleted,
    };
    final url = 'https://api.nstack.in/v1/todos/$id';
    final uri = Uri.parse(url);
    final response = await http.put(
        uri,
        body: jsonEncode(body),
        headers: {
          'Content-Type': 'application/json'
        }
    );
    if (response.statusCode == 200 ){
      showSuccessMessage('Updation Success');
    }else{
      showErrorMessage('Updation failed');
    }
  }

    Future<void> submitData() async{
    final title = titleController.text;
    final desctription = descriptionController.text;
    final body =
    {
      "title": title,
      "description": desctription,
      "is_completed": false,
    };
    final url = 'https://api.nstack.in/v1/todos';
    final uri = Uri.parse(url);
    final response = await http.post(
        uri,
        body: jsonEncode(body),
        headers: {
          'Content-Type': 'application/json'
        }
    );
    if (response.statusCode == 201 ){
      titleController.text = '';
      descriptionController.text = '';
      showSuccessMessage('Creation Success');
    }else{
      showErrorMessage('Creation failed');
    }
  }

  void showSuccessMessage(String message){
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
  void showErrorMessage(String message){
    final snackBar = SnackBar(
        content: Text(
            message,
            style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}


