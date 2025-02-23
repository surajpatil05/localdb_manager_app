import 'package:flutter/foundation.dart';

import 'database_helper.dart';

// Class to handle CRUD operations on the database
class DatabaseOperations {
  // Inserts a user into the database. If the insertion fails, the error is
  // printed to the console and re-thrown to be handled in the UI.
  Future<void> insertUser(String name, int age) async {
    try {
      final db = await DatabaseHelper().database;
      await db.insert('users', {'name': name, 'age': age});
    } catch (e) {
      debugPrint('Error inserting user: $e');
      rethrow; // Re-throw for handling in the UI
    }
  }

  // Retrieves a list of all users from the database. If the retrieval fails,
  // an error is printed to the console and re-thrown to be handled in the UI.
  // Each user is represented as a [Map] with the keys 'id', 'name', and 'age'.
  Future<List<Map<String, dynamic>>> getUsers() async {
    try {
      final db = await DatabaseHelper().database;
      return await db.query('users');
    } catch (e) {
      debugPrint('Error getting users: $e');
      rethrow;
    }
  }

  // Updates a user in the database with the given [id] to have the given
  // [newName] and [newAge]. If the update fails, the error is printed to the
  // console and re-thrown to be handled in the UI.
  Future<void> updateUser(int id, String newName, int newAge) async {
    try {
      final db = await DatabaseHelper().database;
      await db.update('users', {'name': newName, 'age': newAge},
          where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      debugPrint('Error updating user: $e');
      rethrow;
    }
  }

  // Deletes a user with the given [id] from the database. If the deletion fails,
  // an error is printed to the console and re-thrown to be handled in the UI.
  Future<void> deleteUser(int id) async {
    try {
      final db = await DatabaseHelper().database;
      await db.delete('users', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      debugPrint('Error deleting user: $e');
      rethrow;
    }
  }
}
