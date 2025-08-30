import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/packing_controller.dart';
import '../../models/travel.dart';
import '../../models/packing_list.dart';
import '../../models/packing_item.dart';
import '../../widgets/blurred_background.dart';
import '../../widgets/glassmorphism_card.dart';
import '../../widgets/glassmorphism_input.dart';
import '../../widgets/custom_button.dart';

class PackingListView extends StatefulWidget {
  final Travel travel;
  final PackingList packingList;

  const PackingListView({
    super.key,
    required this.travel,
    required this.packingList,
  });

  @override
  State<PackingListView> createState() => _PackingListViewState();
}

class _PackingListViewState extends State<PackingListView>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final _newItemController = TextEditingController();
  bool _isAddingItem = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadPackingList();
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

  void _loadPackingList() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final packingController = Provider.of<PackingController>(context, listen: false);
      packingController.loadPackingList(widget.packingList.id);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _newItemController.dispose();
    super.dispose();
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
              child: Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: Consumer<PackingController>(
                      builder: (context, packingController, child) {
                        final currentPackingList = packingController.getPackingListById(widget.packingList.id);
                        final items = currentPackingList?.items ?? widget.packingList.items;

                        return SingleChildScrollView(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildProgressCard(items),
                              const SizedBox(height: 24),
                              _buildAddItemSection(),
                              const SizedBox(height: 24),
                              _buildItemsList(items),
                              const SizedBox(height: 100), // Space for FAB
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
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
                  widget.travel.destination,
                  style: TextStyle(
                    fontFamily: 'Pacifico',
                    fontSize: 24,
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
                  'Packing List',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(List<PackingItem> items) {
    final totalItems = items.length;
    final packedItems = items.where((item) => item.isPacked).length;
    final progress = totalItems > 0 ? packedItems / totalItems : 0.0;

    return GlassmorphismCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Packing Progress',
                  style: TextStyle(
                    fontFamily: 'Pacifico',
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                progress == 1.0 ? Colors.green : const Color(0xFF6C5CE7),
              ),
              minHeight: 8,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$packedItems of $totalItems items packed',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
                if (progress == 1.0)
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Complete!',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddItemSection() {
    return GlassmorphismCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add Custom Item',
              style: TextStyle(
                fontFamily: 'Pacifico',
                fontSize: 18,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            if (_isAddingItem) ...[
              GlassmorphismInput(
                controller: _newItemController,
                hintText: 'Enter item name',
                prefixIcon: Icons.add,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Cancel',
                      onPressed: () {
                        setState(() {
                          _isAddingItem = false;
                          _newItemController.clear();
                        });
                      },
                      isGlassmorphism: true,
                      backgroundColor: Colors.red.withOpacity(0.3),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      text: 'Add Item',
                      onPressed: _addCustomItem,
                      isGlassmorphism: true,
                    ),
                  ),
                ],
              ),
            ] else
              CustomButton(
                text: 'Add Custom Item',
                onPressed: () {
                  setState(() {
                    _isAddingItem = true;
                  });
                },
                isGlassmorphism: true,
                icon: Icons.add,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsList(List<PackingItem> items) {
    if (items.isEmpty) {
      return GlassmorphismCard(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            children: [
              Icon(
                Icons.luggage,
                color: Colors.white.withOpacity(0.5),
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                'No items in packing list',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Add some items to get started',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Packing Items',
          style: TextStyle(
            fontFamily: 'Pacifico',
            fontSize: 20,
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
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return _buildItemCard(item);
          },
        ),
      ],
    );
  }

  Widget _buildItemCard(PackingItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  item.isPacked 
                      ? Colors.green.withOpacity(0.3)
                      : Colors.white.withOpacity(0.1),
                  item.isPacked 
                      ? Colors.green.withOpacity(0.1)
                      : Colors.white.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: item.isPacked 
                    ? Colors.green.withOpacity(0.3)
                    : Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _toggleItemPacked(item),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Checkbox
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: item.isPacked 
                              ? Colors.green
                              : Colors.transparent,
                          border: Border.all(
                            color: item.isPacked 
                                ? Colors.green
                                : Colors.white.withOpacity(0.5),
                            width: 2,
                          ),
                        ),
                        child: item.isPacked
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 16,
                              )
                            : null,
                      ),
                      const SizedBox(width: 16),
                      // Item name
                      Expanded(
                        child: Text(
                          item.name,
                          style: TextStyle(
                            color: item.isPacked 
                                ? Colors.white.withOpacity(0.7)
                                : Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            decoration: item.isPacked 
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                      ),
                      // Delete button
                      GestureDetector(
                        onTap: () => _deleteItem(item),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.delete_outline,
                            color: Colors.red[300],
                            size: 20,
                          ),
                        ),
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

  Widget _buildFloatingActionButton() {
    return Consumer<PackingController>(
      builder: (context, packingController, child) {
        return FloatingActionButton.extended(
          onPressed: packingController.isLoading ? null : () => _regeneratePackingList(),
          backgroundColor: const Color(0xFF6C5CE7),
          icon: packingController.isLoading 
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Icon(Icons.auto_awesome),
          label: Text(
            packingController.isLoading ? 'Regenerating...' : 'Regenerate with AI',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      },
    );
  }

  void _toggleItemPacked(PackingItem item) {
    final packingController = Provider.of<PackingController>(context, listen: false);
    packingController.toggleItemPackedStatus(item.id);
  }

  void _deleteItem(PackingItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Delete Item',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to delete "${item.name}"?',
          style: TextStyle(color: Colors.white.withOpacity(0.8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              final packingController = Provider.of<PackingController>(context, listen: false);
              packingController.deleteItem(item.id);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _addCustomItem() {
    final itemName = _newItemController.text.trim();
    if (itemName.isEmpty) return;

    final packingController = Provider.of<PackingController>(context, listen: false);
    packingController.addCustomItem(widget.packingList.id, itemName);

    setState(() {
      _isAddingItem = false;
      _newItemController.clear();
    });
  }

  void _regeneratePackingList() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Regenerate Packing List',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'This will replace all current items with new AI-generated suggestions. Are you sure?',
          style: TextStyle(color: Colors.white.withOpacity(0.8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              final packingController = Provider.of<PackingController>(context, listen: false);
              packingController.regeneratePackingList(widget.packingList, widget.travel);
            },
            child: const Text(
              'Regenerate',
              style: TextStyle(color: Color(0xFF6C5CE7)),
            ),
          ),
        ],
      ),
    );
  }
}
