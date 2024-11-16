import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = '';
  String _selectedLocation = 'All';
  String _sortBy = 'None';

  final List<Map<String, dynamic>> _boardingHouses = [
    {
      'name': 'Premium Student Dorm',
      'price': 7000,
      'location': 'Colombo',
      'available': true,
      'type': 'Student',
      'image': 'assets/home/image1.jpeg'
    },
    {
      'name': 'Budget Friendly Room',
      'price': 3500,
      'location': 'Matara',
      'available': true,
      'type': 'Budget',
      'image': 'assets/home/image2.jpeg'
    },
    {
      'name': 'Executive Boarding',
      'price': 9000,
      'location': 'Galle',
      'available': true,
      'type': 'Professional',
      'image': 'assets/home/image3.jpeg'
    },
    {
      'name': 'UC Ladies Dorm',
      'price': 5500,
      'location': 'Kandy',
      'available': true,
      'type': 'Student',
      'image': 'assets/home/image4.jpeg'
    },
    {
      'name': 'City Center Boarding',
      'price': 6500,
      'location': 'Jaffna',
      'available': true,
      'type': 'Mixed',
      'image': 'assets/home/image5.jpeg'
    },
    {
      'name': 'CTU Student Housing',
      'price': 4500,
      'location': 'Tangalle',
      'available': true,
      'type': 'Student',
      'image': 'assets/home/image6.jpeg'
    },
  ];

  List<Map<String, dynamic>> get filteredBoardingHouses {
    return _boardingHouses.where((house) {
      final matchesSearch = house['name'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
                          house['location'].toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesLocation = _selectedLocation == 'All' || house['location'] == _selectedLocation;
      return matchesSearch && matchesLocation;
    }).toList()..sort((a, b) {
      if (_sortBy == 'Price Low to High') {
        return a['price'].compareTo(b['price']);
      } else if (_sortBy == 'Price High to Low') {
        return b['price'].compareTo(a['price']);
      }
      return 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Home',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.w900,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search and Filters Section
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Search Bar
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
                  
                  // Filters Row
                  Row(
                    children: [
                      // Location Filter
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedLocation,
                              isExpanded: true,
                              hint: const Text('Location'),
                              items: [
                                'All',
                                'Colombo',
                                'Matara',
                                'Galle',
                                'Tangalle',
                                'Jaffna',
                                'Kandy'
                              ].map((location) {
                                return DropdownMenuItem(
                                  value: location,
                                  child: Text(location),
                                );
                              }).toList(),
                              onChanged: (value) => setState(() => _selectedLocation = value!),
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: 8),
                      
                      // Sort Filter
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

            // Boarding Houses Grid
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: filteredBoardingHouses.length,
                itemBuilder: (context, index) {
                  final house = filteredBoardingHouses[index];
                  return _buildBoardingCard(house);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBoardingCard(Map<String, dynamic> house) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image and Available badge
          Stack(
            children: [
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  image: DecorationImage(
                    image: AssetImage(house['image']),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              if (house['available'])
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Available',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          // Details
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rs.${house['price']}/month',
                  style: const TextStyle(
                    color: Colors.blue,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  house['name'],
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.grey, size: 12),
                    const SizedBox(width: 2),
                    Expanded(
                      child: Text(
                        house['location'],
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    house['type'],
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}