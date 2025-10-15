import 'package:flutter/material.dart';
import '../../models/household_member.dart';

/// Household member card widget
/// Displays household member information with edit/delete actions
class HouseholdMemberCard extends StatelessWidget {
  final HouseholdMember member;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const HouseholdMemberCard({
    super.key,
    required this.member,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 28,
                backgroundColor: _getRelationshipColor(member.relationship),
                child: Text(
                  _getInitials(member.fullName),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Member info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.fullName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          _getRelationshipIcon(member.relationship),
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          member.relationshipDisplay,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey.shade600,
                              ),
                        ),
                      ],
                    ),
                    if (member.age != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        '${member.age} years old',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade500,
                            ),
                      ),
                    ],
                    if (member.contactNumber != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.phone,
                            size: 14,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            member.contactNumber!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey.shade500,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              // Actions
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    onPressed: onTap,
                    tooltip: 'Edit',
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 20),
                    onPressed: onDelete,
                    tooltip: 'Delete',
                    color: Colors.red.shade400,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Get initials from full name
  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return 'N/A';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  /// Get color based on relationship
  Color _getRelationshipColor(String relationship) {
    switch (relationship.toLowerCase()) {
      case 'head':
        return const Color(0xFF105640); // Primary green
      case 'spouse':
        return const Color(0xFF2D7D5C); // Secondary green
      case 'child':
        return const Color(0xFFF59E0B); // Amber
      case 'parent':
        return const Color(0xFF8B5CF6); // Purple
      default:
        return Colors.grey.shade600;
    }
  }

  /// Get icon based on relationship
  IconData _getRelationshipIcon(String relationship) {
    switch (relationship.toLowerCase()) {
      case 'head':
        return Icons.account_circle;
      case 'spouse':
        return Icons.favorite;
      case 'child':
        return Icons.child_care;
      case 'parent':
        return Icons.elderly;
      default:
        return Icons.person;
    }
  }
}
