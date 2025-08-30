import '../models/user_model.dart';
import '../services/user_service.dart';
import 'base_controller.dart';

class UserController extends BaseController {
  final UserService _userService;
  List<UserModel> _users = [];
  UserModel? _selectedUser;

  UserController(this._userService);

  List<UserModel> get users => _users;
  UserModel? get selectedUser => _selectedUser;

  Future<void> fetchUsers() async {
    try {
      setLoading(true);
      clearError();
      
      final fetchedUsers = await _userService.getUsers();
      _users = fetchedUsers;
      
      notifyListeners();
    } catch (e) {
      setError(e.toString());
    } finally {
      setLoading(false);
    }
  }

  Future<void> createUser(String name, String email, String? avatar) async {
    try {
      setLoading(true);
      clearError();
      
      final newUser = await _userService.createUser(name, email, avatar);
      _users.add(newUser);
      
      notifyListeners();
    } catch (e) {
      setError(e.toString());
    } finally {
      setLoading(false);
    }
  }

  void selectUser(UserModel user) {
    _selectedUser = user;
    notifyListeners();
  }

  void clearSelection() {
    _selectedUser = null;
    notifyListeners();
  }
}
