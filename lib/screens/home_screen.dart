import 'package:flutter/material.dart';
import 'package:localdb_manager_app/data/local/database_operations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final DatabaseOperations dbOperations = DatabaseOperations();
  List<Map<String, dynamic>> users = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  // loads users from the database and update the UI
  void _loadUsers() async {
    try {
      final data = await dbOperations.getUsers();
      setState(() {
        users = data;
      });
    } catch (e) {
      _showSnackBar('Error loading users: $e');
    }
  }

  // adds a user to the database
  void _addUser() async {
    if (nameController.text.isEmpty || ageController.text.isEmpty) {
      _showSnackBar('Name and age are required.');
      return;
    }

    try {
      await dbOperations.insertUser(
          nameController.text, int.parse(ageController.text));
      _loadUsers();
      nameController.clear();
      ageController.clear();
      _showSnackBar('User added successfully.');
    } catch (e) {
      _showSnackBar('Error adding user: $e');
    }
  }

  // updates a user details in the database
  void _updateUser(int id) async {
    showDialog(
      context: context,
      builder: (context) {
        String updatedName =
            users.firstWhere((user) => user['id'] == id)['name'];
        int updatedAge = users.firstWhere((user) => user['id'] == id)['age'];

        return AlertDialog(
          title: Text('Edit User'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Name'),
                onChanged: (value) => updatedName = value,
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Age'),
                onChanged: (value) =>
                    updatedAge = int.tryParse(value) ?? updatedAge,
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                bool isMounted = mounted;

                try {
                  await dbOperations.updateUser(id, updatedName, updatedAge);
                  if (isMounted) {
                    _loadUsers();
                    Navigator.pop(context);
                    _showSnackBar('User updated successfully.');
                  }
                } catch (e) {
                  if (isMounted) {
                    _showSnackBar('Error updating user: $e');
                  }
                }
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }

  // deletes a user from the database
  void _deleteUser(int id) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Delete'),
        content: Text('Are you sure you want to delete this user?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              bool isMounted = mounted;
              try {
                await dbOperations.deleteUser(id);
                if (isMounted == true) {
                  _loadUsers();
                  Navigator.pop(context);
                  _showSnackBar('User deleted successfully.');
                }
              } catch (e) {
                if (isMounted) {
                  _showSnackBar('Error deleting user: $e');
                }
              }
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  // Display a snackbar message
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16),
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('LocalDB Manager')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: ageController,
              decoration: InputDecoration(labelText: 'Age'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            ElevatedButton(onPressed: _addUser, child: Text('Add User')),
            SizedBox(height: 16),
            Expanded(
              child: users.isEmpty
                  ? Center(child: Text('No users found.'))
                  : ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(users[index]['name']),
                          subtitle: Text('Age: ${users[index]['age']}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () =>
                                      _updateUser(users[index]['id'])),
                              IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () =>
                                      _deleteUser(users[index]['id'])),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
