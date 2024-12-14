import 'package:bodo_app/models/listing_model.dart';
import 'package:flutter/material.dart';

class ListingDetailScreen extends StatelessWidget {
  final ListingModel listing;
  
  const ListingDetailScreen({required this.listing, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(listing.title)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image carousel
            // Detail sections
            // Contact info
          ],
        ),
      ),
    );
  }
}