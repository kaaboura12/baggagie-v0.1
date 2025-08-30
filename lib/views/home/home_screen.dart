import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/travel_controller.dart';
import '../../models/travel.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/blurred_background.dart';
import '../../widgets/glassmorphism_card.dart';
import '../../widgets/glassmorphism_input.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/glassmorphism_nav_bar.dart';
import '../packing_list/packing_list_view.dart';

class HomeScreen extends StatefulWidget {
  final bool showNavBar;
  
  const HomeScreen({super.key, this.showNavBar = true});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadUserTravels();
  }

  void _loadUserTravels() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authController = Provider.of<AuthController>(context, listen: false);
      final travelController = Provider.of<TravelController>(context, listen: false);
      
      if (authController.currentUser != null) {
        travelController.loadUserTravels(authController.currentUser!.id);
      }
    });
  }

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
                          
                          // User's Trips Section
                          _buildUserTrips(context, authController),
                          
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

  Widget _buildUserTrips(BuildContext context, AuthController authController) {
    return Consumer<TravelController>(
      builder: (context, travelController, child) {
        if (travelController.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          );
        }

        if (travelController.error != null) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            child: GlassmorphismCard(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.red[300],
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading trips',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      travelController.error!,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    CustomButton(
                      text: 'Retry',
                      onPressed: () => _loadUserTravels(),
                      isGlassmorphism: true,
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final trips = travelController.travels;
        
        if (trips.isEmpty) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            child: GlassmorphismCard(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(
                      Icons.flight_takeoff,
                      color: Colors.white.withOpacity(0.7),
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No trips yet',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Start planning your first adventure!',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'My Trips',
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
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: trips.length,
              itemBuilder: (context, index) {
                final trip = trips[index];
                return _buildTripCard(context, trip);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildTripCard(BuildContext context, Travel trip) {
    final statusColor = _getStatusColor(trip);
    final statusIcon = _getStatusIcon(trip);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
                  statusColor.withOpacity(0.3),
                  statusColor.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _openPackingList(context, trip),
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with destination and status
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  trip.destination,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${trip.durationDays} days',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: statusColor.withOpacity(0.5),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  statusIcon,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  trip.statusText,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Trip details
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: Colors.white.withOpacity(0.7),
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${_formatDate(trip.startDate)} - ${_formatDate(trip.endDate)}',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      
                      if (trip.purpose != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.flag,
                              color: Colors.white.withOpacity(0.7),
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              trip.purpose!.name,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                      
                      const SizedBox(height: 16),
                      
                      // Packing list info and action button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.luggage,
                                color: Colors.white.withOpacity(0.7),
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                trip.packingLists.isNotEmpty 
                                    ? '${trip.packingLists.first.packedItems}/${trip.packingLists.first.totalItems} packed'
                                    : 'No packing list (${trip.packingLists.length})',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'View Packing List',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.white,
                                  size: 12,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openPackingList(BuildContext context, Travel trip) {
    if (trip.packingLists.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No packing list available for this trip'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PackingListView(
          travel: trip,
          packingList: trip.packingLists.first,
        ),
      ),
    );
  }

  Color _getStatusColor(Travel trip) {
    if (trip.isUpcoming) return const Color(0xFF6C5CE7);
    if (trip.isActive) return const Color(0xFF00B894);
    return const Color(0xFF636E72);
  }

  IconData _getStatusIcon(Travel trip) {
    if (trip.isUpcoming) return Icons.schedule;
    if (trip.isActive) return Icons.flight;
    return Icons.check_circle;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
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

