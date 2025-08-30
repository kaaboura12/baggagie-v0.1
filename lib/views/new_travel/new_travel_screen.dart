import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/travel_controller.dart';
import '../../models/activity.dart';
import '../../models/trip_purpose.dart';
import '../../services/activity_service.dart';
import '../../services/purpose_service.dart';
import '../../widgets/blurred_background.dart';
import '../../widgets/glassmorphism_card.dart';
import '../../widgets/glassmorphism_input.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/custom_button.dart';

class NewTravelScreen extends StatefulWidget {
  final VoidCallback? onTravelCreated;
  
  const NewTravelScreen({super.key, this.onTravelCreated});

  @override
  State<NewTravelScreen> createState() => _NewTravelScreenState();
}

class _NewTravelScreenState extends State<NewTravelScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _destinationController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  DateTime? _startDate;
  DateTime? _endDate;
  TripPurpose? _selectedPurpose;
  List<Activity> _selectedActivities = [];
  List<Activity> _availableActivities = [];
  List<TripPurpose> _availablePurposes = [];
  bool _isLoading = false;
  bool _isLoadingData = true;
  
  // Pagination state
  int _activityPage = 1;
  int _purposePage = 1;
  int _activityTotalPages = 1;
  int _purposeTotalPages = 1;
  bool _hasNextActivityPage = false;
  bool _hasPreviousActivityPage = false;
  bool _hasNextPurposePage = false;
  bool _hasPreviousPurposePage = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadData();
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
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  Future<void> _loadData() async {
    try {
      final activityData = await ActivityService.getActivitiesPaginated(page: _activityPage);
      final purposeData = await PurposeService.getPurposesPaginated(page: _purposePage);
      
      if (mounted) {
        setState(() {
          _availableActivities = List<Activity>.from(activityData['activities']);
          _availablePurposes = List<TripPurpose>.from(purposeData['purposes']);
          _activityTotalPages = activityData['totalPages'];
          _purposeTotalPages = purposeData['totalPages'];
          _hasNextActivityPage = activityData['hasNextPage'];
          _hasPreviousActivityPage = activityData['hasPreviousPage'];
          _hasNextPurposePage = purposeData['hasNextPage'];
          _hasPreviousPurposePage = purposeData['hasPreviousPage'];
          _isLoadingData = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingData = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _destinationController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate 
          ? (_startDate ?? DateTime.now())
          : (_endDate ?? _startDate ?? DateTime.now().add(const Duration(days: 1))),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF6C5CE7),
              onPrimary: Colors.white,
              surface: Color(0xFF1A1A2E),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          _startDateController.text = _formatDate(picked);
          // Reset end date if it's before start date
          if (_endDate != null && _endDate!.isBefore(picked)) {
            _endDate = null;
            _endDateController.clear();
          }
        } else {
          _endDate = picked;
          _endDateController.text = _formatDate(picked);
        }
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _toggleActivity(Activity activity) {
    if (mounted) {
      setState(() {
        if (_selectedActivities.contains(activity)) {
          _selectedActivities.remove(activity);
        } else {
          _selectedActivities.add(activity);
        }
      });
    }
  }

  Future<void> _loadActivityPage(int page) async {
    if (mounted) {
      setState(() {
        _isLoadingData = true;
        _activityPage = page;
      });
    }

    try {
      final activityData = await ActivityService.getActivitiesPaginated(page: page);
      
      if (mounted) {
        setState(() {
          _availableActivities = List<Activity>.from(activityData['activities']);
          _activityTotalPages = activityData['totalPages'];
          _hasNextActivityPage = activityData['hasNextPage'];
          _hasPreviousActivityPage = activityData['hasPreviousPage'];
          _isLoadingData = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingData = false;
        });
      }
    }
  }

  Future<void> _loadPurposePage(int page) async {
    if (mounted) {
      setState(() {
        _isLoadingData = true;
        _purposePage = page;
      });
    }

    try {
      final purposeData = await PurposeService.getPurposesPaginated(page: page);
      
      if (mounted) {
        setState(() {
          _availablePurposes = List<TripPurpose>.from(purposeData['purposes']);
          _purposeTotalPages = purposeData['totalPages'];
          _hasNextPurposePage = purposeData['hasNextPage'];
          _hasPreviousPurposePage = purposeData['hasPreviousPage'];
          _isLoadingData = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingData = false;
        });
      }
    }
  }

  Future<void> _createTravel() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select both start and end dates'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final authController = Provider.of<AuthController>(context, listen: false);
      final travelController = Provider.of<TravelController>(context, listen: false);
      final user = authController.currentUser;
      
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Show loading message for AI generation
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Creating travel and generating AI packing list...'),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 3),
          ),
        );
      }

      final travel = await travelController.createTravelWithPackingList(
        userId: user.id,
        destination: _destinationController.text.trim(),
        startDate: _startDate!,
        endDate: _endDate!,
        purposeId: _selectedPurpose?.id,
        activityIds: _selectedActivities.map((a) => a.id).toList(),
      );

      if (travel != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Travel created successfully with AI-generated packing list!'),
              backgroundColor: Colors.green,
            ),
          );
          
          // Navigate back to home using callback
          widget.onTravelCreated?.call();
        }
      } else {
        throw Exception('Failed to create travel');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating travel: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlurredBackground(
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 30),
                      _buildTravelForm(),
                      const SizedBox(height: 30),
                      _buildPurposeSelection(),
                      const SizedBox(height: 30),
                      _buildActivitySelection(),
                      const SizedBox(height: 40),
                      _buildCreateButton(),
                      const SizedBox(height: 100), // Space for navbar
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

  Widget _buildHeader() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => widget.onTravelCreated?.call(),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Plan New Travel',
                style: TextStyle(
                  fontFamily: 'Pacifico',
                  fontSize: 28,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      offset: const Offset(0, 2),
                      blurRadius: 4,
                      color: Colors.black.withOpacity(0.3),
                    ),
                  ],
                ),
              ),
              Text(
                'Create your perfect journey',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTravelForm() {
    return GlassmorphismCard(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Travel Details',
              style: TextStyle(
                fontFamily: 'Pacifico',
                fontSize: 20,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            GlassmorphismInput(
              controller: _destinationController,
              hintText: 'Where are you going?',
              prefixIcon: Icons.location_on_outlined,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a destination';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _selectDate(context, true),
                    child: GlassmorphismInput(
                      controller: _startDateController,
                      hintText: 'Start Date',
                      prefixIcon: Icons.calendar_today_outlined,
                      enabled: false,
                      validator: (value) {
                        if (_startDate == null) {
                          return 'Please select start date';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _selectDate(context, false),
                    child: GlassmorphismInput(
                      controller: _endDateController,
                      hintText: 'End Date',
                      prefixIcon: Icons.calendar_today_outlined,
                      enabled: false,
                      validator: (value) {
                        if (_endDate == null) {
                          return 'Please select end date';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPurposeSelection() {
    return GlassmorphismCard(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Trip Purpose',
              style: TextStyle(
                fontFamily: 'Pacifico',
                fontSize: 20,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            if (_isLoadingData)
              const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            else
              Column(
                children: [
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: _availablePurposes.map((purpose) {
                      final isSelected = _selectedPurpose?.id == purpose.id;
                      return GestureDetector(
                        onTap: () {
                          if (mounted) {
                            setState(() {
                              _selectedPurpose = isSelected ? null : purpose;
                            });
                          }
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? const LinearGradient(
                                    colors: [Color(0xFF6C5CE7), Color(0xFF8E44AD)],
                                  )
                                : null,
                            color: isSelected ? null : Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                              color: isSelected 
                                  ? Colors.transparent 
                                  : Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            purpose.name,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  if (_purposeTotalPages > 1) ...[
                    const SizedBox(height: 16),
                    _buildPaginationControls(
                      currentPage: _purposePage,
                      totalPages: _purposeTotalPages,
                      hasNext: _hasNextPurposePage,
                      hasPrevious: _hasPreviousPurposePage,
                      onPrevious: () => _loadPurposePage(_purposePage - 1),
                      onNext: () => _loadPurposePage(_purposePage + 1),
                    ),
                  ],
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivitySelection() {
    return GlassmorphismCard(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Activities',
                  style: TextStyle(
                    fontFamily: 'Pacifico',
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                if (_selectedActivities.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6C5CE7),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      '${_selectedActivities.length} selected',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (_isLoadingData)
              const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            else
              Column(
                children: [
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: _availableActivities.map((activity) {
                      final isSelected = _selectedActivities.contains(activity);
                      return GestureDetector(
                        onTap: () => _toggleActivity(activity),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? const LinearGradient(
                                    colors: [Color(0xFF6C5CE7), Color(0xFF8E44AD)],
                                  )
                                : null,
                            color: isSelected ? null : Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected 
                                  ? Colors.transparent 
                                  : Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isSelected)
                                const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              if (isSelected) const SizedBox(width: 6),
                              Text(
                                activity.name,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  if (_activityTotalPages > 1) ...[
                    const SizedBox(height: 16),
                    _buildPaginationControls(
                      currentPage: _activityPage,
                      totalPages: _activityTotalPages,
                      hasNext: _hasNextActivityPage,
                      hasPrevious: _hasPreviousActivityPage,
                      onPrevious: () => _loadActivityPage(_activityPage - 1),
                      onNext: () => _loadActivityPage(_activityPage + 1),
                    ),
                  ],
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateButton() {
    return CustomButton(
      text: 'Create Travel',
      onPressed: _isLoading ? null : _createTravel,
      isLoading: _isLoading,
      isGlassmorphism: true,
    );
  }

  Widget _buildPaginationControls({
    required int currentPage,
    required int totalPages,
    required bool hasNext,
    required bool hasPrevious,
    required VoidCallback onPrevious,
    required VoidCallback onNext,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Previous button
        GestureDetector(
          onTap: hasPrevious ? onPrevious : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: hasPrevious 
                  ? Colors.white.withOpacity(0.1)
                  : Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: hasPrevious 
                    ? Colors.white.withOpacity(0.3)
                    : Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.chevron_left,
                  color: hasPrevious ? Colors.white : Colors.white.withOpacity(0.3),
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  'Previous',
                  style: TextStyle(
                    color: hasPrevious ? Colors.white : Colors.white.withOpacity(0.3),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(width: 16),
        
        // Page indicator
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF6C5CE7),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Text(
            '$currentPage / $totalPages',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        
        const SizedBox(width: 16),
        
        // Next button
        GestureDetector(
          onTap: hasNext ? onNext : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: hasNext 
                  ? Colors.white.withOpacity(0.1)
                  : Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: hasNext 
                    ? Colors.white.withOpacity(0.3)
                    : Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Next',
                  style: TextStyle(
                    color: hasNext ? Colors.white : Colors.white.withOpacity(0.3),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.chevron_right,
                  color: hasNext ? Colors.white : Colors.white.withOpacity(0.3),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
