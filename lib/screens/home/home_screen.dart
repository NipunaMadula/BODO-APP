import 'package:bodo_app/models/listing_model.dart';
import 'package:bodo_app/repositories/listing_repository.dart';
import 'package:bodo_app/screens/home/listing_detail_screen.dart';
import 'package:bodo_app/screens/home/nearby_listings_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _listingRepository = ListingRepository();
  String _searchQuery = '';
  String _selectedDistrict = 'All'; 
  String _sortBy = 'None';

    final List<String> _districts = [
    'All',
    'Colombo',
    'Gampaha',
    'Kalutara',
    'Kandy',
    'Matale',
    'Nuwara Eliya',
    'Galle',
    'Matara',
    'Hambantota',
    'Jaffna',
    'Kilinochchi',
    'Mannar',
    'Mullaitivu',
    'Vavuniya',
    'Trincomalee',
    'Batticaloa',
    'Ampara',
    'Kurunegala',
    'Puttalam',
    'Anuradhapura',
    'Polonnaruwa',
    'Badulla',
    'Monaragala',
    'Ratnapura',
    'Kegalle',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Home',
          style: TextStyle(
            color: Colors.black,
            fontSize: 25,
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.location_on,
              color: Colors.black,
            ),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NearbyListingsScreen()),
            ),
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
   
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
       
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      onChanged: (value) => setState(() => _searchQuery = value),
                      decoration: const InputDecoration(
                        hintText: 'Search by name or location...',
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Row(
                    children: [
                      // District Dropdown
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedDistrict,
                              isExpanded: true,
                              hint: const Text('District'),
                              items: _districts.map((district) {
                                return DropdownMenuItem(
                                  value: district,
                                  child: Text(district),
                                );
                              }).toList(),
                              onChanged: (value) => setState(() => _selectedDistrict = value!),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),
                      
                  
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _sortBy,
                              isExpanded: true,
                              hint: const Text('Sort by'),
                              items: [
                                'None',
                                'Price Low to High',
                                'Price High to Low',
                              ].map((sort) {
                                return DropdownMenuItem(
                                  value: sort,
                                  child: Text(sort),
                                );
                              }).toList(),
                              onChanged: (value) => setState(() => _sortBy = value!),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          
            Expanded(
              child: StreamBuilder<List<ListingModel>>(
                stream: _listingRepository.getListings(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    print('Stream error: ${snapshot.error}'); // Debug print
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    print('Waiting for stream data...'); // Debug print
                    return const Center(child: CircularProgressIndicator());
                  }

                  var listings = snapshot.data ?? [];
                  print('Received ${listings.length} listings'); // Debug print

                  listings = listings.where((listing) {
                    final matchesSearch = listing.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                                        listing.location.toLowerCase().contains(_searchQuery.toLowerCase());
                    final matchesDistrict = _selectedDistrict == 'All' || listing.district == _selectedDistrict;
                    return matchesSearch && matchesDistrict;
                  }).toList();
 
                  if (_sortBy == 'Price Low to High') {
                    listings.sort((a, b) => a.price.compareTo(b.price));
                  } else if (_sortBy == 'Price High to Low') {
                    listings.sort((a, b) => b.price.compareTo(a.price));
                  }

                  return GridView.builder(
                    padding: EdgeInsets.all(MediaQuery.of(context).size.width > 600 ? 20 : 16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
                      childAspectRatio: 0.77, 
                      crossAxisSpacing: MediaQuery.of(context).size.width > 600 ? 16 : 12,
                      mainAxisSpacing: MediaQuery.of(context).size.width > 600 ? 16 : 12,
                    ),
                    itemCount: listings.length,
                    itemBuilder: (context, index) => _buildListingCard(listings[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

Widget _buildListingCard(ListingModel listing) {
 
  final size = MediaQuery.of(context).size;
  final isTablet = size.width > 600;

  final cardWidth = (size.width - 48) / (isTablet ? 3 : 2); 
  final imageHeight = cardWidth * 0.7; 

  return GestureDetector(
    onTap: () => Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ListingDetailScreen(listing: listing)),
    ),
    child: Container(
   
      width: cardWidth,
      height: cardWidth * 1.3, 
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
    
          SizedBox(
            height: imageHeight,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: listing.images.isNotEmpty
                      ? Image.network(
                          listing.images.first,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.error, color: Colors.red),
                        )
                      : Container(
                          color: Colors.grey[100],
                          child: const Icon(Icons.image_not_supported, color: Colors.grey),
                        ),
                ),
            
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 10 : 8,
                      vertical: isTablet ? 5 : 4,
                    ),
                    decoration: BoxDecoration(
                      color: listing.available ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      listing.available ? 'Available' : 'Not available',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isTablet ? 12 : 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),


          Expanded(
            child: Padding(
              padding: EdgeInsets.all(isTablet ? 12 : 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Price
                  Text(
                    'Rs.${listing.price}/month',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: isTablet ? 16 : 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  // Title
                  Text(
                    listing.title,
                    style: TextStyle(
                      fontSize: isTablet ? 14 : 12,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Location
                  Row(
                    children: [
                      Icon(Icons.location_on, 
                        color: Colors.grey, 
                        size: isTablet ? 14 : 12,
                      ),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          listing.location,
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: isTablet ? 12 : 10,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  // Type badge 
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 8 : 6,
                      vertical: isTablet ? 4 : 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      listing.type,
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontSize: isTablet ? 11 : 9,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
}