import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:todo/utils/user_prefs.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  await UserPrefs.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Taskify',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primaryColor: Colors.white),
      home: const MyHomePage(title: 'Taskify'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _selection = false;
  int _selected = 0;
  List<String> _arrTask = [];
  List<String> _arrCheckState = [];
  List<bool> _arrSelectedTask = [];

  final _taskController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _arrTask = UserPrefs.getTasks() ?? [];
    _arrCheckState = UserPrefs.getCheckState() ?? [];
    _arrSelectedTask = List.generate(_arrTask.length, (index) => false);
  }

  void _addTask() async {
    if (_taskController.text.trim().isNotEmpty) {
      _arrTask.add(_taskController.text.trim());
      _arrCheckState.add("false");
      _arrSelectedTask.add(false);
      await UserPrefs.setTasks(_arrTask);
      await UserPrefs.setCheckState(_arrCheckState);
      setState(() {
        _taskController.clear();
      });
    }
  }

  void _deleteTask() async {
    int count = 0;
    for (int i = 0; i < _arrSelectedTask.length; i++) {
      if (_arrSelectedTask[i] == true) {
        _arrTask.removeAt(i - count);
        _arrCheckState.removeAt(i - count);
        count++;
      }
    }
    await UserPrefs.setTasks(_arrTask);
    await UserPrefs.setCheckState(_arrCheckState);
    _clearSelected();
  }

  void _clearSelected() {
    _selection = false;
    _selected = 0;
    _arrSelectedTask = List.generate(_arrTask.length, (index) => false);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: _selection
            ? TextButton.icon(
                onPressed: () => _clearSelected(),
                icon: const Icon(Icons.clear, color: Colors.white),
                label: Text(
                  "$_selected",
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ))
            : Text(widget.title),
        actions: _selection
            ? [
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: IconButton(
                      onPressed: () => _deleteTask(),
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.white,
                      )),
                )
              ]
            : null,
        backgroundColor: Colors.pink[600],
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Card(
              elevation: 3,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: TextField(
                    controller: _taskController,
                    decoration: InputDecoration(
                        hintText: "Enter a task",
                        border: InputBorder.none,
                        suffixIcon: IconButton(
                          icon: Icon(
                            Icons.add_circle,
                            color: Colors.pink[600],
                          ),
                          onPressed: () => _addTask(),
                        ))),
              )),
          const Padding(
            padding: EdgeInsets.only(top: 32, bottom: 8, left: 32),
            child: Text(
              "All Tasks",
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.w500),
            ),
          ),
          _arrTask.isEmpty
              ? const Expanded(
                  child: Column(children: [
                  Spacer(
                    flex: 2,
                  ),
                  Center(
                      child: Text(
                    "Add a Task",
                    style: TextStyle(fontSize: 18),
                  )),
                  Spacer(
                    flex: 3,
                  )
                ]))
              : Expanded(
                  child: ListView.builder(
                    itemCount: _arrTask.length,
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return Card(
                          color: _arrSelectedTask[index]
                              ? Colors.grey[400]
                              : Colors.white,
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 6),
                          child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: ListTile(
                                onTap: () async {
                                  if (_selection == true) {
                                    if (_arrSelectedTask[index]) {
                                      _arrSelectedTask[index] = false;
                                      _selected--;
                                      if (_selected == 0) {
                                        _selection = false;
                                      }
                                    } else {
                                      _arrSelectedTask[index] = true;
                                      _selected++;
                                    }
                                  } else {
                                    _arrCheckState[index] == "true"
                                        ? _arrCheckState[index] = "flase"
                                        : _arrCheckState[index] = "true";
                                    await UserPrefs.setCheckState(
                                        _arrCheckState);
                                  }
                                  setState(() {});
                                },
                                onLongPress: () {
                                  _selection = true;
                                  !_arrSelectedTask[index] ? _selected++ : null;
                                  _arrSelectedTask[index] = true;
                                  setState(() {});
                                },
                                title: Text(
                                  _arrTask[index],
                                  style: TextStyle(
                                      decoration:
                                          _arrCheckState[index] == "true"
                                              ? TextDecoration.lineThrough
                                              : TextDecoration.none),
                                ),
                                leading: Icon(
                                  _arrCheckState[index] == "true"
                                      ? Icons.check_box
                                      : Icons.check_box_outline_blank,
                                  color: Colors.pink[600],
                                ),
                              )));
                    },
                  ),
                ),
        ]),
      ),
    );
  }
}
