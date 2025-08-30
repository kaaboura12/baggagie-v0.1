import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/blurred_background.dart';
import '../../widgets/glassmorphism_card.dart';
import '../../widgets/glassmorphism_input.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/glassmorphism_nav_bar.dart';

class HomeScreen extends StatefulWidget {
  final bool showNavBar;
  
  const HomeScreen({super.key, this.showNavBar = true});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  void _onNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });
    
    // Handle navigation
    switch (index) {
      case 0:
        // Already on home
        break;
      case 1:
        // New travel navigation is handled by MainWrapper
        break;
      case 2:
        // Profile navigation is handled by MainWrapper
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlurredBackground(
        child: Consumer<AuthController>(
          builder: (context, authController, child) {
            final user = authController.currentUser;
            
            return SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          // Beautiful Header with Logo and Profile
                          _buildHeader(context, user),
                          
                          const SizedBox(height: 24),
                          
                          // Creative Search Bar
                          _buildSearchBar(context),
                          
                          const SizedBox(height: 32),
                          
                          // Travel Destinations Section
                          _buildTravelDestinations(context),
                          
                          const SizedBox(height: 32),
                          
                          // Quick Actions Section
                          _buildQuickActions(context, authController),
                          
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                  
                  // Glassmorphism Navigation Bar (only show if showNavBar is true)
                  if (widget.showNavBar)
                    GlassmorphismNavBar(
                      currentIndex: _currentIndex,
                      onTap: _onNavTap,
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, dynamic user) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo
          const AppLogo(
            size: 50,
            showText: false,
          ),
          
          // Profile Avatar with Menu
          _buildProfileMenu(context, user),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: GlassmorphismCard(
        child: Row(
          children: [
            Icon(
              Icons.search,
              color: Colors.white.withOpacity(0.8),
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Where do you want to go?',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 16,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.tune,
                color: Colors.white.withOpacity(0.8),
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTravelDestinations(BuildContext context) {
    final destinations = [
      {
        'name': 'Paris, France',
        'image': '🏛️',
        'description': 'City of Lights',
        'price': '\$1,200',
        'rating': 4.8,
        'color': const Color(0xFF6C5CE7),
      },
      {
        'name': 'Tokyo, Japan',
        'image': '🗼',
        'description': 'Modern Metropolis',
        'price': '\$1,800',
        'rating': 4.9,
        'color': const Color(0xFFE17055),
      },
      {
        'name': 'Santorini, Greece',
        'image': '🏝️',
        'description': 'Aegean Paradise',
        'price': '\$900',
        'rating': 4.7,
        'color': const Color(0xFF00B894),
      },
      {
        'name': 'New York, USA',
        'image': '🗽',
        'description': 'The Big Apple',
        'price': '\$1,500',
        'rating': 4.6,
        'color': const Color(0xFFE84393),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Explore Destinations',
            style: TextStyle(
              fontFamily: 'Pacifico',
              fontSize: 24,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.3),
                  offset: const Offset(0, 2),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: destinations.length,
            itemBuilder: (context, index) {
              final destination = destinations[index];
              return _buildDestinationCard(context, destination);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDestinationCard(BuildContext context, Map<String, dynamic> destination) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  destination['color'].withOpacity(0.3),
                  destination['color'].withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Stack(
              children: [
                // Background Pattern
                Positioned.fill(
                  child: CustomPaint(
                    painter: DestinationPatternPainter(destination['color']),
                  ),
                ),
                
                // Content
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Emoji Icon
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Center(
                          child: Text(
                            destination['image'],
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                      
                      const Spacer(),
                      
                      // Destination Name
                      Text(
                        destination['name'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      
                      const SizedBox(height: 4),
                      
                      // Description
                      Text(
                        destination['description'],
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Price and Rating Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            destination['price'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                destination['rating'].toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, AuthController authController) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: TextStyle(
              fontFamily: 'Pacifico',
              fontSize: 24,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.3),
                  offset: const Offset(0, 2),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  context,
                  'Start New Trip',
                  Icons.flight_takeoff,
                  const Color(0xFF6C5CE7),
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Trip creation feature coming soon!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionCard(
                  context,
                  'My Trips',
                  Icons.luggage,
                  const Color(0xFFE17055),
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Trips list feature coming soon!'),
                        backgroundColor: Colors.blue,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withOpacity(0.3),
                  color.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DestinationPatternPainter extends CustomPainter {
  final Color color;

  DestinationPatternPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    // Draw some decorative circles
    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.2),
      size.width * 0.1,
      paint,
    );
    
    canvas.drawCircle(
      Offset(size.width * 0.2, size.height * 0.7),
      size.width * 0.08,
      paint,
    );
    
    canvas.drawCircle(
      Offset(size.width * 0.9, size.height * 0.8),
      size.width * 0.06,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

  Widget _buildProfileMenu(BuildContext context, dynamic user) {
    return PopupMenuButton<String>(
      onSelected: (value) async {
        if (value == 'logout') {
          final authController = Provider.of<AuthController>(context, listen: false);
          await authController.signOut();
          if (context.mounted) {
            Navigator.pushReplacementNamed(context, '/signin');
          }
        }
      },
      color: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      itemBuilder: (BuildContext context) => [
        PopupMenuItem<String>(
          value: 'profile',
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.2),
                  Colors.white.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.person, color: Colors.white.withOpacity(0.9)),
                const SizedBox(width: 12),
                Text(
                  'Profile',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        PopupMenuItem<String>(
          value: 'settings',
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.2),
                  Colors.white.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.settings, color: Colors.white.withOpacity(0.9)),
                const SizedBox(width: 12),
                Text(
                  'Settings',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        PopupMenuItem<String>(
          value: 'logout',
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.red.withOpacity(0.2),
                  Colors.red.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.red.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.logout, color: Colors.red[300]),
                const SizedBox(width: 12),
                Text(
                  'Logout',
                  style: TextStyle(
                    color: Colors.red[300],
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.2),
              Colors.white.withOpacity(0.1),
            ],
          ),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Center(
              child: Text(
                (user?.fullName?.isNotEmpty == true 
                    ? user!.fullName![0].toUpperCase()
                    : user?.email?.isNotEmpty == true 
                        ? user!.email![0].toUpperCase()
                        : 'U'),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Pacifico',
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
