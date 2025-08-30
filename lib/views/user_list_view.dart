import 'package:flutter/material.dart';
import '../controllers/user_controller.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';
import 'base_view.dart';

class UserListView extends BaseView<UserController> {
  const UserListView({super.key});

  @override
  UserController createController() {
    return UserController(UserService());
  }

  @override
  State<UserListView> createState() => _UserListViewState();
}

class _UserListViewState extends BaseViewState<UserController, UserListView> {
  @override
  Widget buildView(BuildContext context, UserController controller) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Baggagie - Users'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildUserForm(controller),
          Expanded(
            child: _buildUserList(controller),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => controller.fetchUsers(),
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildUserForm(UserController controller) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty && emailController.text.isNotEmpty) {
                controller.createUser(
                  nameController.text,
                  emailController.text,
                  null,
                );
                nameController.clear();
                emailController.clear();
              }
            },
            child: const Text('Add User'),
          ),
        ],
      ),
    );
  }

  Widget _buildUserList(UserController controller) {
    if (controller.users.isEmpty) {
      return const Center(
        child: Text(
          'No users yet. Add some users or refresh to see existing ones.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: controller.users.length,
      itemBuilder: (context, index) {
        final user = controller.users[index];
        return _buildUserTile(user, controller);
      },
    );
  }

  Widget _buildUserTile(UserModel user, UserController controller) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: user.avatar != null
              ? NetworkImage(user.avatar!)
              : null,
          child: user.avatar == null
              ? Text(user.name[0].toUpperCase())
              : null,
        ),
        title: Text(user.name),
        subtitle: Text(user.email),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () {
            // In a real app, you'd call a delete method
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Delete User'),
                content: Text('Are you sure you want to delete ${user.name}?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // controller.deleteUser(user.id);
                    },
                    child: const Text('Delete'),
                  ),
                ],
              ),
            );
          },
        ),
        onTap: () => controller.selectUser(user),
      ),
    );
  }
}
