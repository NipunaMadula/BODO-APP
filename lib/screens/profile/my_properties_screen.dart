import 'package:bodo_app/screens/home/listing_detail_screen.dart';
import 'package:bodo_app/screens/profile/edit_listing_screen.dart';
import 'package:bodo_app/screens/profile/rate_user_screen.dart';
import 'package:bodo_app/screens/payments/payments_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bodo_app/models/listing_model.dart';
import 'package:bodo_app/repositories/listing_repository.dart';

class MyPropertiesScreen extends StatefulWidget {
  const MyPropertiesScreen({super.key});

  @override
  State<MyPropertiesScreen> createState() => _MyPropertiesScreenState();
}

class _MyPropertiesScreenState extends State<MyPropertiesScreen> {
  final _listingRepository = ListingRepository();

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      return const Scaffold(
        body: Center(
          child: Text('Please sign in to view your properties'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Properties'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: StreamBuilder<List<ListingModel>>(
        stream: _listingRepository.getListingsByUserId(userId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading properties\n${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {}); // Refresh
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final listings = snapshot.data ?? [];

          if (listings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.home_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No properties posted yet',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: listings.length,
            itemBuilder: (context, index) => _buildPropertyCard(context, listings[index]),
          );
        },
      ),
    );
  }

  Widget _buildPropertyCard(BuildContext context, ListingModel listing) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ListingDetailScreen(listing: listing),
          ),
        ),
        child: Container(
          height: 120,
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Image with error handling
              AspectRatio(
                aspectRatio: 1,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    listing.images.first,
                    width: 96,
                    height: 96,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.error_outline),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      listing.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Rs.${listing.price}/month',
                      style: const TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${listing.district}, ${listing.location}',
                            style: TextStyle(color: Colors.grey[600]),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        listing.type,
                        style: TextStyle(
                          color: Colors.grey[800],
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Menu
              PopupMenuButton(
                icon: const Icon(Icons.more_vert),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: const Row(
                      children: [
                        Icon(Icons.edit),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: const Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'rate_user',
                    child: const Row(
                      children: [
                        Icon(Icons.rate_review),
                        SizedBox(width: 8),
                        Text('Rate User'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'view_payments',
                    child: const Row(
                      children: [
                        Icon(Icons.payment),
                        SizedBox(width: 8),
                        Text('View Payments'),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditListingScreen(listing: listing),
                        ),
                      );
                      break;
                    case 'delete':
                      _showDeleteDialog(context, listing);
                      break;
                    case 'rate_user':
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => RateUserScreen(listingId: listing.id)),
                      );
                      break;
                    case 'view_payments':
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => PaymentsListScreen(listingId: listing.id)),
                      );
                      break;
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showDeleteDialog(BuildContext context, ListingModel listing) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Listing'),
        content: const Text('Are you sure you want to delete this listing?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _listingRepository.deleteListing(listing.id);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting listing: $e')),
          );
        }
      }
    }
  }
}