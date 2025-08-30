import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';
import '../controllers/travel_controller.dart';
import '../controllers/packing_controller.dart';

class AppProviders {
  static List<ChangeNotifierProvider> get providers => [
    ChangeNotifierProvider<AuthController>(
      create: (_) => AuthController(),
    ),
    ChangeNotifierProvider<TravelController>(
      create: (_) => TravelController(),
    ),
    ChangeNotifierProvider<PackingController>(
      create: (_) => PackingController(),
    ),
  ];
}
