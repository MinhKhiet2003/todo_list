import 'package:flutter/material.dart';
import 'package:rest_api/services/todo_service.dart';
import '../utils/snackbar_helper.dart';
import 'add_page.dart';

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  bool isLoading = true;
  List items = [];
  @override
  void initState() {
    super.initState();
    fetchTodo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todo List'),
        centerTitle: true,
      ),
          body: Visibility(
            visible: isLoading,
            child: Center(
             child:   CircularProgressIndicator()
            ),
            replacement: RefreshIndicator(
              onRefresh: fetchTodo,
              child: Visibility(
                visible: items.isNotEmpty,
                replacement: Center(
                  child: Text(
                    'No Todo item',
                    style: Theme.of(context).textTheme.headline3,
                  ),
                ),
                child: ListView.builder(
                  itemCount: items.length,
                    padding: EdgeInsets.all(8),
                    itemBuilder: (context, index) {
                    final item = items[index] as Map;
                    final id = item['_id'] as String;
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(child: Text('${index + 1}'),),
                          title: Text(item['title']),
                          subtitle: Text(item['description']),
                          trailing: PopupMenuButton(
                            onSelected: (value) {
                              if (value == 'edit'){
                                navigateToEditPage(item);
                              }
                              if (value == 'delete'){
                                deleteById(id);
                              }
                            },
                            itemBuilder: (context) {
                              return [
                                PopupMenuItem(
                                    child: Text('Edit'),
                                  value: 'edit',
                                ),
                                PopupMenuItem(
                                    child: Text('Delete'),
                                    value: 'delete',
                                ),
                              ];
                            },
                          ),
                        ),
                      );
                    }

                ),
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
        onPressed: navigateToAddPage,
        label: Text('Add Todo'),
    ),
    );
  }


  Future<void> navigateToEditPage(Map item) async{
    final route = MaterialPageRoute(
      builder: (context) => AddTodoPage(todo: item),
    );
    await Navigator.push(context, route);
    setState(() {
      isLoading = true;
    });
    fetchTodo();
  }

  Future <void> navigateToAddPage() async{
    final route = MaterialPageRoute(
      builder: (context) => AddTodoPage(),
    );
    await Navigator.push(context, route);
    setState(() {
      isLoading = true;
    });
    fetchTodo();
  }

  Future<void> deleteById(String id) async {
    final response = await todoService.deleteById(id);

    if (response){
      final filtered = items.where((element) => element['_id'] != id).toList();
      setState(() {
        items = filtered;
      });
    }else{
      showErrorMessage(context, message: 'Deletion failed');
    }
  }

  Future <void> fetchTodo() async {
    final response = await todoService.fetchTodo();
    if (response != null){
      setState(() {
        items = response;
      });
    }else{
      showErrorMessage(context, message: 'Something went wrong');
    }
    setState(() {
      isLoading = false;
    });

  }

  void showSuccessMessage(String message){
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }


}
