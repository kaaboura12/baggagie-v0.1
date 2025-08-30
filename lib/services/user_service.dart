import '../models/user_model.dart';
import 'base_service.dart';

class UserService implements BaseService {
  // Simulated data for demonstration
  final List<UserModel> _mockUsers = [
    UserModel(
      id: '1',
      name: 'John Doe',
      email: 'john@example.com',
      avatar: 'https://via.placeholder.com/150',
    ),
    UserModel(
      id: '2',
      name: 'Jane Smith',
      email: 'jane@example.com',
      avatar: 'https://via.placeholder.com/150',
    ),
  ];

  @override
  Future<T> get<T>(String endpoint) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (endpoint == '/users') {
      return _mockUsers as T;
    }
    
    throw Exception('Endpoint not found: $endpoint');
  }

  @override
  Future<T> post<T>(String endpoint, dynamic data) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (endpoint == '/users') {
      final userData = data as Map<String, dynamic>;
      final newUser = UserModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: userData['name'],
        email: userData['email'],
        avatar: userData['avatar'],
      );
      
      _mockUsers.add(newUser);
      return newUser as T;
    }
    
    throw Exception('Endpoint not found: $endpoint');
  }

  @override
  Future<T> put<T>(String endpoint, dynamic data) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (endpoint.startsWith('/users/')) {
      final userId = endpoint.split('/').last;
      final userData = data as Map<String, dynamic>;
      
      final userIndex = _mockUsers.indexWhere((user) => user.id == userId);
      if (userIndex == -1) {
        throw Exception('User not found');
      }
      
      final updatedUser = _mockUsers[userIndex].copyWith(
        name: userData['name'],
        email: userData['email'],
        avatar: userData['avatar'],
      );
      
      _mockUsers[userIndex] = updatedUser;
      return updatedUser as T;
    }
    
    throw Exception('Endpoint not found: $endpoint');
  }

  @override
  Future<T> delete<T>(String endpoint) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (endpoint.startsWith('/users/')) {
      final userId = endpoint.split('/').last;
      final userIndex = _mockUsers.indexWhere((user) => user.id == userId);
      
      if (userIndex == -1) {
        throw Exception('User not found');
      }
      
      final deletedUser = _mockUsers.removeAt(userIndex);
      return deletedUser as T;
    }
    
    throw Exception('Endpoint not found: $endpoint');
  }

  // Convenience methods for the UserController
  Future<List<UserModel>> getUsers() async {
    return await get<List<UserModel>>('/users');
  }

  Future<UserModel> createUser(String name, String email, String? avatar) async {
    return await post<UserModel>('/users', {
      'name': name,
      'email': email,
      'avatar': avatar,
    });
  }
}
