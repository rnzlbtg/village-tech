import 'package:flutter/material.dart';
import '../../models/beneficial_user.dart';

/// Beneficial user card widget with photo thumbnail
class BeneficialUserCard extends StatelessWidget {
  final BeneficialUser user;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onToggleStatus;

  const BeneficialUserCard({
    super.key,
    required this.user,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onToggleStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Photo or initials avatar
                  _buildAvatar(),
                  const SizedBox(width: 16),

                  // User info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                user.fullName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            _buildStatusBadge(),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              _getRelationshipIcon(),
                              size: 14,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              user.relationshipDisplay,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.phone,
                              size: 14,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              user.contactNumber,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        if (user.email != null && user.email!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.email,
                                size: 14,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  user.email!,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),

              // Action buttons
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Toggle status button
                  if (onToggleStatus != null)
                    TextButton.icon(
                      onPressed: onToggleStatus,
                      icon: Icon(
                        user.isActive ? Icons.pause_circle : Icons.play_circle,
                        size: 16,
                      ),
                      label: Text(user.isActive ? 'Deactivate' : 'Activate'),
                      style: TextButton.styleFrom(
                        foregroundColor:
                            user.isActive ? Colors.orange : Colors.green,
                      ),
                    ),

                  // Edit button
                  if (onEdit != null)
                    TextButton.icon(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Edit'),
                    ),

                  // Delete button
                  if (onDelete != null)
                    TextButton.icon(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete, size: 16),
                      label: const Text('Remove'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build avatar with photo or initials
  Widget _buildAvatar() {
    if (user.hasPhoto) {
      return CircleAvatar(
        radius: 32,
        backgroundImage: NetworkImage(user.idPhotoUrl!),
        onBackgroundImageError: (exception, stackTrace) {
          // Fallback to initials if image fails to load
        },
        child: user.idPhotoUrl == null
            ? Text(
                user.initials,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              )
            : null,
      );
    }

    return CircleAvatar(
      radius: 32,
      backgroundColor: _getRelationshipColor(),
      child: Text(
        user.initials,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  /// Build status badge
  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: user.isActive ? Colors.green[50] : Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: user.isActive ? Colors.green[300]! : Colors.grey[400]!,
        ),
      ),
      child: Text(
        user.status.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: user.isActive ? Colors.green[700] : Colors.grey[700],
        ),
      ),
    );
  }

  /// Get relationship color
  Color _getRelationshipColor() {
    switch (user.relationship.toLowerCase()) {
      case 'helper':
        return const Color(0xFF2D7D5C); // Green
      case 'family':
        return const Color(0xFF105640); // Dark green
      case 'friend':
        return const Color(0xFFF59E0B); // Amber
      default:
        return Colors.grey;
    }
  }

  /// Get relationship icon
  IconData _getRelationshipIcon() {
    switch (user.relationship.toLowerCase()) {
      case 'helper':
        return Icons.cleaning_services;
      case 'family':
        return Icons.family_restroom;
      case 'friend':
        return Icons.people;
      default:
        return Icons.person;
    }
  }
}
