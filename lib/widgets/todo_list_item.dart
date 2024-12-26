import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:todo_list/models/todo.dart';

class TodoListItem extends StatefulWidget {
  const TodoListItem({
    super.key,
    required this.todo,
    required this.onDelete,
    required this.isPressed,
    required this.onPress,
  });

  final Todo todo;
  final Function(Todo) onDelete;
  final VoidCallback onPress;
  final bool isPressed;


  @override
  State<TodoListItem> createState() => _TodoListItemState();
}

class _TodoListItemState extends State<TodoListItem> {

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Slidable(
        actionPane: SlidableDrawerActionPane(),
        actionExtentRatio: 0.25,
        secondaryActions: [
          IconSlideAction(
            color: Colors.red,
            icon: Icons.delete,
            onTap: (){
              widget.onDelete(widget.todo);
            },
            caption: "Deletar",
          )
        ],
        child: GestureDetector(
          onLongPress: widget.onPress,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
              border: widget.isPressed ? Border.all(color: Colors.deepPurple) : null,
            ),
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  DateFormat("dd/MM/yyyy - HH:mm").format(widget.todo.dateTime),
                  style: TextStyle(fontSize: 12),
                ),
                Text(
                  widget.todo.title,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
