import 'package:bodo_app/models/listing_model.dart';
import 'package:bodo_app/screens/listing_detail_screen.dart';
import 'package:flutter/material.dart';

class ListingCard extends StatelessWidget {
  final ListingModel listing;
  
  const ListingCard({required this.listing, super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ListingDetailScreen(listing: listing)
        ),
      ),
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16/9,
              child: Image.network(
                listing.images.first,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Rs.${listing.price}/month',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(listing.title),
                  Text(listing.location),
                  Text(listing.type),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}