import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/blurred_background.dart';
import '../../widgets/glassmorphism_card.dart';
import '../../widgets/glassmorphism_input.dart';
import '../../widgets/glassmorphism_nav_bar.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/custom_button.dart';

class ProfileScreen extends StatefulWidget {
  final bool showNavBar;
  
  const ProfileScreen({super.key, this.showNavBar = true});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 2; // Profile tab is selected
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _bioController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadUserData();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
    ));

    _animationController.forward();
  }

  void _loadUserData() {
    final authController = Provider.of<AuthController>(context, listen: false);
    final user = authController.currentUser;
    
    if (user != null) {
      _fullNameController.text = user.fullName ?? '';
      _emailController.text = user.email ?? '';
      _bioController.text = ''; // Bio not available in current User model
      _phoneController.text = ''; // Phone not available in current User model
    }
  }

  void _onNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });
    
    switch (index) {
      case 0:
        // Home navigation is handled by MainWrapper
        break;
      case 1:
        // New travel navigation is handled by MainWrapper
        break;
      case 2:
        // Already on profile - do nothing
        break;
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authController = Provider.of<AuthController>(context, listen: false);
      
      // Simulate API call - replace with actual update logic
      await Future.delayed(const Duration(seconds: 2));
      
      // Update user data (this would be your actual update logic)
      // await authController.updateProfile(
      //   fullName: _fullNameController.text.trim(),
      //   bio: _bioController.text.trim(),
      //   phone: _phoneController.text.trim(),
      // );

      setState(() {
        _isEditing = false;
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    _phoneController.dispose();
    super.dispose();
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
                      child: AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          return FadeTransition(
                            opacity: _fadeAnimation,
                            child: SlideTransition(
                              position: _slideAnimation,
                              child: Column(
                                children: [
                                  // Header with Logo and Edit Button
                                  _buildHeader(context, user),
                                  
                                  const SizedBox(height: 24),
                                  
                                  // Profile Avatar Section
                                  _buildProfileAvatar(context, user),
                                  
                                  const SizedBox(height: 32),
                                  
                                  // Profile Form
                                  _buildProfileForm(context),
                                  
                                  const SizedBox(height: 32),
                                  
                                  // Stats Cards
                                  _buildStatsCards(context, user),
                                  
                                  const SizedBox(height: 32),
                                  
                                  // Action Buttons
                                  _buildActionButtons(context, authController),
                                  
                                  const SizedBox(height: 24),
                                ],
                              ),
                            ),
                          );
                        },
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
          // Back Button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          
          // Logo
          const AppLogo(
            size: 40,
            showText: false,
          ),
          
          // Edit Button
          GestureDetector(
            onTap: () {
              setState(() {
                _isEditing = !_isEditing;
              });
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: _isEditing
                    ? LinearGradient(
                        colors: [
                          const Color(0xFF6C5CE7),
                          const Color(0xFF8E44AD),
                        ],
                      )
                    : null,
                color: _isEditing ? null : Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Icon(
                _isEditing ? Icons.close : Icons.edit,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileAvatar(BuildContext context, dynamic user) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: GlassmorphismCard(
        child: Column(
          children: [
            // Avatar
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF6C5CE7),
                    const Color(0xFF8E44AD),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6C5CE7).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  (user?.fullName?.isNotEmpty == true 
                      ? user!.fullName![0].toUpperCase()
                      : user?.email?.isNotEmpty == true 
                          ? user!.email![0].toUpperCase()
                          : 'U'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Pacifico',
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Name
            Text(
              user?.fullName ?? 'User Name',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'Pacifico',
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Email
            Text(
              user?.email ?? 'user@example.com',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 16,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Member Since
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Text(
                'Member since ${user?.createdAt != null ? '${user!.createdAt.day}/${user.createdAt.month}/${user.createdAt.year}' : '2024'}',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileForm(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: GlassmorphismCard(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Profile Information',
                style: TextStyle(
                  fontFamily: 'Pacifico',
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Full Name
              GlassmorphismInput(
                controller: _fullNameController,
                labelText: 'Full Name',
                hintText: 'Enter your full name',
                prefixIcon: Icons.person_outline,
                enabled: _isEditing,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your full name';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Email (Read-only)
              GlassmorphismInput(
                controller: _emailController,
                labelText: 'Email',
                hintText: 'Your email address',
                prefixIcon: Icons.email_outlined,
                enabled: false, // Email is read-only
              ),
              
              const SizedBox(height: 16),
              
              // Phone
              GlassmorphismInput(
                controller: _phoneController,
                labelText: 'Phone Number',
                hintText: 'Enter your phone number',
                prefixIcon: Icons.phone_outlined,
                enabled: _isEditing,
                keyboardType: TextInputType.phone,
              ),
              
              const SizedBox(height: 16),
              
              // Bio
              GlassmorphismInput(
                controller: _bioController,
                labelText: 'Bio',
                hintText: 'Tell us about yourself',
                prefixIcon: Icons.info_outline,
                enabled: _isEditing,
                maxLines: 3,
              ),
              
              if (_isEditing) ...[
                const SizedBox(height: 24),
                
                // Update Button
                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    text: _isLoading ? 'Updating...' : 'Update Profile',
                    onPressed: _isLoading ? null : _updateProfile,
                    isLoading: _isLoading,
                    isGlassmorphism: true,
                    borderRadius: 16.0,
                    icon: Icons.save,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCards(BuildContext context, dynamic user) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Travel Statistics',
            style: TextStyle(
              fontFamily: 'Pacifico',
              fontSize: 20,
              color: Colors.white,
            ),
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  'Trips',
                  '12',
                  Icons.flight_takeoff,
                  const Color(0xFF6C5CE7),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  'Countries',
                  '8',
                  Icons.public,
                  const Color(0xFFE17055),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  'Cities',
                  '24',
                  Icons.location_city,
                  const Color(0xFF00B894),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  'Days',
                  '156',
                  Icons.calendar_today,
                  const Color(0xFFE84393),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
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
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              
              const SizedBox(height: 8),
              
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 4),
              
              Text(
                title,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, AuthController authController) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Settings Button
          _buildActionButton(
            context,
            'Settings',
            Icons.settings,
            const Color(0xFF6C5CE7),
            () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Settings feature coming soon!'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
          ),
          
          const SizedBox(height: 12),
          
          // Sign Out Button
          _buildActionButton(
            context,
            'Sign Out',
            Icons.logout,
            const Color(0xFFE17055),
            () async {
              await authController.signOut();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/signin');
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
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
            width: double.infinity,
            padding: const EdgeInsets.all(16),
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
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                
                const SizedBox(width: 16),
                
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                
                const Spacer(),
                
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white.withOpacity(0.6),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
