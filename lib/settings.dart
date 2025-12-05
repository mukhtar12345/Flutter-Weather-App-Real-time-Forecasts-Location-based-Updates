import 'package:flutter/material.dart';
import 'package:weather_appv4/database_helper.dart';

class MySettings extends StatefulWidget {
  const MySettings({super.key});

  @override
  State<MySettings> createState() => _MySettingsState();
}

class _MySettingsState extends State<MySettings> {
  // DB reference (non-null, created once)
  final DBHelper dbRef = DBHelper.getInstance;
  // All Locations in memory
  List<Map<String, dynamic>> allLocations = [];

  // Controllers for Edit
  final TextEditingController editId = TextEditingController();
  final TextEditingController editTitle = TextEditingController();

  // Controllers for Add
  final TextEditingController addTitle = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAllLocations();
  }

  Future<void> _loadAllLocations() async {
    final data = await dbRef.getAllLocations();
    setState(() {
      allLocations = data;
    });
  }

  Future<void> _deleteAllLocations() async {
    await dbRef.emptyDb();
    setState(() {
      allLocations = []; // no need to re-query after emptying
    });
  }

  Future<void> _deleteLocations(int id) async {
    if (id == 1) return;
    await dbRef.deleteLocation(id);
    await _loadAllLocations();
  }

  Future<void> _addNewLocation() async {
    final mTitle = addTitle.text.trim();

    if (mTitle.isEmpty) return;

    final result = await dbRef.addLocation(mTitle: mTitle);

    if (result) {
      addTitle.clear();
      await _loadAllLocations();
    }
  }

  void _openEditNoteSheet(BuildContext context, Map<String, dynamic> note) {
    // Pre-fill with tapped note data
    editId.text = "${note[DBHelper.columnId]}";
    editTitle.text = "${note[DBHelper.columnTitle]}";

    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(20),
              width: double.infinity,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Edit Location Name",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.normal,
                      color: Colors.black,
                    ),
                  ),
                  Opacity(
                    opacity: 0.0,
                    child: TextField(
                      controller: editId,
                      readOnly: true, // id should not be changed
                      decoration: const InputDecoration(label: Text("Id")),
                    ),
                  ),
                  TextField(
                    controller: editTitle,
                    decoration: const InputDecoration(
                      label: Text("Title"),
                      hintText: "Title",
                    ),
                  ),
                  const SizedBox(height: 20),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      await _updateLocation();
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 5,
                      backgroundColor: const Color.fromARGB(255, 109, 177, 236),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                    child: const Text("Update Location"),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _openAddNoteSheet(BuildContext context) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(20),
              width: double.infinity,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Add New Location",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.normal,
                      color: Color.fromARGB(255, 109, 177, 236),
                    ),
                  ),
                  TextField(
                    controller: addTitle,
                    decoration: const InputDecoration(
                      label: Text("Title"),
                      hintText: "Title",
                    ),
                  ),
                  const SizedBox(height: 20),

                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {
                            await _addNewLocation();
                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(11),
                            ),
                            side: const BorderSide(
                              color: Colors.grey,
                              width: 2,
                            ),
                          ),
                          child: const Text("Add Location"),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(11),
                            ),
                            side: const BorderSide(
                              color: Colors.grey,
                              width: 2,
                            ),
                          ),
                          child: const Text("Cancel"),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _updateLocation() async {
    final idText = editId.text.trim();
    final mTitle = editTitle.text.trim();

    if (idText.isEmpty || mTitle.isEmpty) return;
    await dbRef.updateLocation(idText, mTitle);
    editId.clear();
    editTitle.clear();
    await _loadAllLocations();
  }

  @override
  void dispose() {
    super.dispose();
    addTitle.dispose();
    editId.dispose();
    editTitle.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 109, 177, 236),
        title: const Text('Settings'),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.delete_sweep_sharp,
              semanticLabel: 'Clear All',
              color: Color.fromARGB(221, 17, 17, 17),
            ),
            onPressed: () {
              _deleteAllLocations();
            },
          ),
        ],
      ),

      body: Container(
        color: const Color.fromARGB(255, 249, 250, 250),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: allLocations.isNotEmpty
                  ? ListView.builder(
                      itemCount: allLocations.length,
                      itemBuilder: (context, index) {
                        final note = allLocations[index];
                        return InkWell(
                          onTap: () {
                            _openEditNoteSheet(context, note);
                          },
                          child: Card(
                            color: const Color.fromARGB(255, 169, 207, 240),
                            elevation: 2, // Adds a shadow
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                15.0,
                              ), // Rounded corners
                            ),
                            margin: EdgeInsets.all(11),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisSize: MainAxisSize
                                    .min, // Make the column take minimum space
                                children: <Widget>[
                                  ListTile(
                                    leading: Text(
                                      "${note[DBHelper.columnId]}",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10,
                                        color: Colors.black,
                                      ),
                                    ),
                                    title: Text(
                                      "${note[DBHelper.columnTitle]}",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                        color: Colors.black,
                                      ),
                                    ),
                                    subtitle: Text(
                                      note[DBHelper.columnId] == 1
                                          ? "Default Location"
                                          : "",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 15,
                                      ),
                                    ),

                                    trailing: IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Color.fromARGB(221, 21, 10, 10),
                                      ),
                                      onPressed: () {
                                        _deleteLocations(
                                          note[DBHelper.columnId],
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    )
                  : const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "There are no Locations!",
                            style: TextStyle(
                              fontSize: 20,
                              color: Color.fromARGB(255, 72, 146, 236),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          // _addLocation();
          _openAddNoteSheet(context);
        },
      ),
    );
  }
}
