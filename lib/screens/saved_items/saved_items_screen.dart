import 'package:flutter/material.dart';
import 'package:bodo_app/models/listing_model.dart';
import 'package:bodo_app/repositories/listing_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bodo_app/screens/home/listing_detail_screen.dart';
import 'package:bodo_app/repositories/saved_listings_repository.dart';

class SavedItemsScreen extends StatelessWidget {
  SavedItemsScreen({super.key});

  final _listingRepository = ListingRepository();
  final _savedListingsRepository = SavedListingsRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Saved Items',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.w900,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<List<ListingModel>>(
        stream: _listingRepository.getSavedListings(
          FirebaseAuth.instance.currentUser?.uid ?? ''
        ),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                ],
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final listings = snapshot.data ?? [];

          if (listings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bookmark_border,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No saved items yet',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: listings.length,
            itemBuilder: (context, index) {
              final listing = listings[index];
              return _buildSavedItemCard(context, listing);
            },
          );
        },
      ),
    );
  }

  Widget _buildSavedItemCard(BuildContext context, ListingModel listing) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ListingDetailScreen(listing: listing),
            ),
          );
        },
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
              child: Image.network(
                listing.images.first,
                width: 120,
                height: 120,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 120,
                  height: 120,
                  color: Colors.grey[200],
                  child: const Icon(Icons.error),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rs.${listing.price}/month',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      listing.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on, 
                          color: Colors.grey, 
                          size: 14
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            listing.location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.bookmark),
              color: Colors.lightBlueAccent,
              onPressed: () async {
                final userId = FirebaseAuth.instance.currentUser?.uid;
                if (userId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please sign in to save listings')),
                  );
                  return;
                }
                
                try {
                  await _savedListingsRepository.toggleSavedListing(
                    userId: userId,
                    listingId: listing.id,
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Removed from saved'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}