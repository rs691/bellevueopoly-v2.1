import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '/models/business_model.dart';
import '/providers/business_provider.dart';
import '/widgets/async_image.dart';
import '/theme/app_colors.dart';
import '/theme/app_spacing.dart';
import '/widgets/search_bar.dart' as custom_search;

class BoulevardPartnersScreen extends ConsumerStatefulWidget {
  const BoulevardPartnersScreen({super.key});

  @override
  ConsumerState<BoulevardPartnersScreen> createState() =>
      _BoulevardPartnersScreenState();
}

class _BoulevardPartnersScreenState
    extends ConsumerState<BoulevardPartnersScreen> {
  String _searchQuery = '';

  // Filter States
  String _selectedCategory = 'All';
  bool _onlyWithRewards = false;
  bool _onlyWithPoints = false;

  final List<String> _categories = [
    'All',
    'Boulevard Partners',
    'Patriotic Partners',
    'Merch Partners',
    'Giving Partners',
    'Community Chest',
    'Wild Cards',
    'Fun House',
  ];

  @override
  Widget build(BuildContext context) {
    final businessListAsync = ref.watch(businessListProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Boulevard Partners',
          style: GoogleFonts.baloo2(fontSize: 38, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        automaticallyImplyLeading: true,
        foregroundColor: Colors.white,
        toolbarHeight: 80,
      ),
      body: Column(
        children: [
          // Search bar and Filter Button
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [
                Expanded(
                  child: custom_search.SearchBar(
                    hintText: 'Search businesses...',
                    onChanged: (query) => setState(() => _searchQuery = query),
                    onClear: () => setState(() => _searchQuery = ''),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Container(
                  decoration: BoxDecoration(
                    color:
                        (_onlyWithRewards ||
                            _onlyWithPoints ||
                            _selectedCategory != 'All')
                        ? AppColors.primaryPurple
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.tune,
                      color:
                          (_onlyWithRewards ||
                              _onlyWithPoints ||
                              _selectedCategory != 'All')
                          ? Colors.white
                          : AppColors.darkGrey,
                    ),
                    onPressed: () => _showFilterSheet(context),
                    tooltip: 'Filters',
                  ),
                ),
              ],
            ),
          ),

          // Active Filters Summary
          if (_onlyWithRewards || _onlyWithPoints || _selectedCategory != 'All')
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                children: [
                  if (_onlyWithRewards)
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Chip(
                        label: const Text(
                          'Has Rewards',
                          style: TextStyle(fontSize: 12),
                        ),
                        backgroundColor: AppColors.primaryPurple.withOpacity(
                          0.1,
                        ),
                        deleteIcon: const Icon(Icons.close, size: 16),
                        onDeleted: () =>
                            setState(() => _onlyWithRewards = false),
                      ),
                    ),
                  if (_onlyWithPoints)
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Chip(
                        label: const Text(
                          'Has Points',
                          style: TextStyle(fontSize: 12),
                        ),
                        backgroundColor: AppColors.primaryPurple.withOpacity(
                          0.1,
                        ),
                        deleteIcon: const Icon(Icons.close, size: 16),
                        onDeleted: () =>
                            setState(() => _onlyWithPoints = false),
                      ),
                    ),
                  if (_selectedCategory != 'All')
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Chip(
                        label: Text(
                          _selectedCategory,
                          style: const TextStyle(fontSize: 12),
                        ),
                        backgroundColor: AppColors.primaryPurple.withOpacity(
                          0.1,
                        ),
                        deleteIcon: const Icon(Icons.close, size: 16),
                        onDeleted: () =>
                            setState(() => _selectedCategory = 'All'),
                      ),
                    ),
                ],
              ),
            ),

          // Business List
          Expanded(
            child: businessListAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
              error: (err, stack) => Center(
                child: Text(
                  'Error: $err',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              data: (businesses) {
                // Filter businesses
                final filteredBusinesses = businesses.where((business) {
                  // Search filter
                  if (_searchQuery.isNotEmpty &&
                      !business.name.toLowerCase().contains(
                        _searchQuery.toLowerCase(),
                      )) {
                    return false;
                  }

                  // Category filter
                  if (_selectedCategory != 'All' &&
                      business.category != _selectedCategory) {
                    return false;
                  }

                  // Rewards filter
                  if (_onlyWithRewards && !business.hasReward) {
                    return false;
                  }

                  // Points filter
                  if (_onlyWithPoints && business.points <= 0) {
                    return false;
                  }

                  return true;
                }).toList();

                if (filteredBusinesses.isEmpty) {
                  return Center(
                    child: Text(
                      'No businesses found',
                      style: GoogleFonts.baloo2(
                        fontSize: 18,
                        color: Colors.white70,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 8,
                    bottom: 120, // Extra padding for bottom nav
                  ),
                  itemCount: filteredBusinesses.length,
                  itemBuilder: (context, index) {
                    final business = filteredBusinesses[index];
                    return _BusinessCard(business: business);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppColors.darkGrey.withOpacity(0.95),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filters',
              style: GoogleFonts.baloo2(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Category Dropdown
            Text(
              'Category',
              style: GoogleFonts.baloo2(fontSize: 16, color: Colors.white70),
            ),
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButton<String>(
                value: _selectedCategory,
                isExpanded: true,
                dropdownColor: AppColors.darkGrey,
                underline: const SizedBox(),
                style: const TextStyle(color: Colors.white),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedCategory = value!);
                  Navigator.pop(context);
                },
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Rewards Toggle
            SwitchListTile(
              title: const Text(
                'Only show businesses with rewards',
                style: TextStyle(color: Colors.white),
              ),
              value: _onlyWithRewards,
              onChanged: (value) {
                setState(() => _onlyWithRewards = value);
                Navigator.pop(context);
              },
              activeColor: AppColors.primaryPurple,
            ),

            // Points Toggle
            SwitchListTile(
              title: const Text(
                'Only show businesses with points',
                style: TextStyle(color: Colors.white),
              ),
              value: _onlyWithPoints,
              onChanged: (value) {
                setState(() => _onlyWithPoints = value);
                Navigator.pop(context);
              },
              activeColor: AppColors.primaryPurple,
            ),

            const SizedBox(height: AppSpacing.md),

            // Clear Filters Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _selectedCategory = 'All';
                    _onlyWithRewards = false;
                    _onlyWithPoints = false;
                  });
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryPurple,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Clear All Filters'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BusinessCard extends StatelessWidget {
  final Business business;

  const _BusinessCard({required this.business});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/business/${business.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.purple.withOpacity(0.3),
              Colors.deepPurple.withOpacity(0.2),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
          child: Row(
            children: [
              // Business Icon/Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: AsyncImage(
                  imageUrl: business.heroImageUrl,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  placeholderAsset: 'assets/icons/heart_outline.png',
                ),
              ),
              const SizedBox(width: 16),

              // Business Name and Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      business.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      business.category,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Chevron Icon
              const Icon(Icons.chevron_right, size: 20, color: Colors.white54),
            ],
          ),
        ),
      ),
    );
  }
}
