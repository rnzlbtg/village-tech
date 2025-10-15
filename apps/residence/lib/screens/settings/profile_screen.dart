import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:developer' as developer;
import '../../providers/auth_provider.dart';
import '../../services/supabase_service.dart';

/// Profile screen showing household and user information
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _householdData;
  Map<String, dynamic>? _residenceData;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final supabase = SupabaseService.instance.client;
      final user = ref.read(currentUserProvider);

      developer.log('Loading profile data...', name: 'ProfileScreen');
      developer.log('User: ${user?.email} (${user?.id})', name: 'ProfileScreen');
      developer.log('User app_metadata: ${user?.appMetadata}', name: 'ProfileScreen');
      developer.log('User user_metadata: ${user?.userMetadata}', name: 'ProfileScreen');

      if (user == null) {
        developer.log('No user logged in', name: 'ProfileScreen');
        setState(() {
          _error = 'Not logged in';
          _isLoading = false;
        });
        return;
      }

      // Get household ID from user metadata or query
      developer.log('Fetching household ID...', name: 'ProfileScreen');
      final householdId = await SupabaseService.instance.getHouseholdId();
      developer.log('Household ID: $householdId', name: 'ProfileScreen');

      if (householdId == null) {
        developer.log('No household found for user', name: 'ProfileScreen');
        setState(() {
          _error = null; // Don't show error, show empty state instead
          _isLoading = false;
          _householdData = null;
          _residenceData = null;
        });
        return;
      }

      // Fetch household data with residence unit information
      developer.log('Fetching household data for ID: $householdId', name: 'ProfileScreen');
      final householdResponse = await supabase
          .from('households')
          .select('''
            *,
            residence_units (
              id,
              unit_number,
              unit_type,
              floor_number,
              building_section,
              lot_number,
              address,
              status,
              properties (
                id,
                name,
                address,
                property_type
              )
            )
          ''')
          .eq('id', householdId)
          .single();

      developer.log('Household data loaded: ${householdResponse['household_name']}', name: 'ProfileScreen');

      setState(() {
        _householdData = householdResponse;
        _residenceData = householdResponse['residence_units'];
        _isLoading = false;
      });
    } catch (e) {
      developer.log('Error loading profile: $e', name: 'ProfileScreen', error: e);
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProfileData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading profile',
                          style: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _error!,
                          style: theme.textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _loadProfileData,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : _householdData == null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.home_outlined,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'No Household Assigned',
                              style: theme.textTheme.titleLarge,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Your account has not been assigned to a household yet. Please contact your village administrator.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 32),
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    CircleAvatar(
                                      radius: 30,
                                      backgroundColor:
                                          theme.colorScheme.primary,
                                      child: Text(
                                        user?.email
                                                ?.substring(0, 1)
                                                .toUpperCase() ??
                                            'U',
                                        style: const TextStyle(
                                          fontSize: 24,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      user?.email ?? 'No email',
                                      style: theme.textTheme.titleSmall,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            OutlinedButton.icon(
                              onPressed: _loadProfileData,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Refresh'),
                            ),
                          ],
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadProfileData,
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          // User info card
                          Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 40,
                                backgroundColor: theme.colorScheme.primary,
                                child: Text(
                                  user?.email?.substring(0, 1).toUpperCase() ??
                                      'U',
                                  style: const TextStyle(
                                    fontSize: 32,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                user?.email ?? 'No email',
                                style: theme.textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Household Member',
                                  style: TextStyle(
                                    color: theme.colorScheme.onPrimaryContainer,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Household info
                      if (_householdData != null) ...[
                        _buildSectionHeader('Household Information'),
                        Card(
                          child: Column(
                            children: [
                              _buildInfoTile(
                                icon: Icons.home,
                                label: 'Household Name',
                                value: _householdData!['household_name'] ??
                                    'N/A',
                              ),
                              const Divider(height: 1),
                              _buildInfoTile(
                                icon: Icons.calendar_today,
                                label: 'Move-in Date',
                                value: _formatDate(
                                    _householdData!['move_in_date']),
                              ),
                              const Divider(height: 1),
                              _buildInfoTile(
                                icon: Icons.info_outline,
                                label: 'Status',
                                value: _householdData!['status'] ?? 'N/A',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Residence info
                      if (_residenceData != null) ...[
                        _buildSectionHeader('Residence Information'),
                        Card(
                          child: Column(
                            children: [
                              _buildInfoTile(
                                icon: Icons.apartment,
                                label: 'Unit Number',
                                value: _residenceData!['unit_number'] ?? 'N/A',
                              ),
                              if (_residenceData!['unit_type'] != null) ...[
                                const Divider(height: 1),
                                _buildInfoTile(
                                  icon: Icons.home_work,
                                  label: 'Unit Type',
                                  value: _residenceData!['unit_type'],
                                ),
                              ],
                              if (_residenceData!['floor_number'] != null) ...[
                                const Divider(height: 1),
                                _buildInfoTile(
                                  icon: Icons.layers,
                                  label: 'Floor',
                                  value: _residenceData!['floor_number'].toString(),
                                ),
                              ],
                              if (_residenceData!['building_section'] != null) ...[
                                const Divider(height: 1),
                                _buildInfoTile(
                                  icon: Icons.business,
                                  label: 'Building Section',
                                  value: _residenceData!['building_section'],
                                ),
                              ],
                              if (_residenceData!['lot_number'] != null) ...[
                                const Divider(height: 1),
                                _buildInfoTile(
                                  icon: Icons.tag,
                                  label: 'Lot Number',
                                  value: _residenceData!['lot_number'],
                                ),
                              ],
                              if (_residenceData!['status'] != null) ...[
                                const Divider(height: 1),
                                _buildInfoTile(
                                  icon: Icons.info_outline,
                                  label: 'Status',
                                  value: _residenceData!['status'],
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Property info
                      if (_residenceData != null &&
                          _residenceData!['properties'] != null) ...[
                        _buildSectionHeader('Property Information'),
                        Card(
                          child: Column(
                            children: [
                              _buildInfoTile(
                                icon: Icons.business,
                                label: 'Property Name',
                                value: _residenceData!['properties']['name'] ??
                                    'N/A',
                              ),
                              const Divider(height: 1),
                              _buildInfoTile(
                                icon: Icons.location_on,
                                label: 'Address',
                                value: _residenceData!['properties']
                                        ['address'] ??
                                    'N/A',
                              ),
                              const Divider(height: 1),
                              _buildInfoTile(
                                icon: Icons.category,
                                label: 'Type',
                                value: _residenceData!['properties']
                                        ['property_type'] ??
                                    'N/A',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      subtitle: Text(
        value,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}
