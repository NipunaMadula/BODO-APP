import 'dart:async';
import 'package:bodo_app/models/listing_model.dart';
import 'package:bodo_app/repositories/listing_repository.dart';
import 'package:bodo_app/widgets/listing_card.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SearchByLocationScreen extends StatefulWidget {
  const SearchByLocationScreen({super.key});

  @override
  State<SearchByLocationScreen> createState() => _SearchByLocationScreenState();
}

class _SearchByLocationScreenState extends State<SearchByLocationScreen> {
  final _locationController = TextEditingController();
  final _listingRepository = ListingRepository();
  List<ListingModel> _nearbyListings = [];
  List<Location> _searchSuggestions = [];
  LatLng? _searchLocation;
  bool _isLoading = false;
  bool _isSearching = false;
  Timer? _debounceTimer;
  double _searchRadius = 5.0;

  void _onSearchChanged(String query) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (query.length >= 3) _getSuggestions(query);
    });
  }

  Future<void> _getSuggestions(String query) async {
    if (query.isEmpty) {
      setState(() => _searchSuggestions = []);
      return;
    }

    try {
      setState(() => _isSearching = true);
      final locations = await locationFromAddress(
        '$query, Sri Lanka',
        localeIdentifier: "en_US"
      );
      setState(() => _searchSuggestions = locations);
    } catch (e) {
      print('Error getting suggestions: $e');
      setState(() => _searchSuggestions = []);
    } finally {
      setState(() => _isSearching = false);
    }
  }

  Future<void> _searchByLocation(Location location) async {
    setState(() {
      _isLoading = true;
      _searchSuggestions = [];
      _searchLocation = LatLng(location.latitude, location.longitude);
    });

    try {
      final placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        final address = [
          placemark.street,
          placemark.locality,
          placemark.subAdministrativeArea,
        ].where((e) => e?.isNotEmpty ?? false).join(', ');
        _locationController.text = address;
      }

      await _filterListings();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _filterListings() async {
    if (_searchLocation == null) return;

    try {
      final allListings = await _listingRepository.getAllListings();
      
      _nearbyListings = allListings.where((listing) {
        if (listing.latitude == null || listing.longitude == null) return false;
        
        final distance = Geolocator.distanceBetween(
          _searchLocation!.latitude,
          _searchLocation!.longitude,
          listing.latitude!,
          listing.longitude!,
        );
        
        return distance <= _searchRadius * 1000;
      }).toList();

      setState(() {});
    } catch (e) {
      print('Error filtering listings: $e');
      setState(() => _nearbyListings = []);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text(
          'Search By Location',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(bottom: bottomPadding > 0 ? 48 : 0),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(size.width * 0.04),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(
                        bottom: _searchSuggestions.isNotEmpty ? 0 : 16
                      ),
                      child: TextField(
                        controller: _locationController,
                        decoration: InputDecoration(
                          hintText: 'Enter location to search...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _isSearching || _isLoading
                            ? Padding(
                                padding: const EdgeInsets.all(14),
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.blue
                                    ),
                                  ),
                                ),
                              )
                            : IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _locationController.clear();
                                  setState(() {
                                    _searchSuggestions = [];
                                    _nearbyListings = [];
                                    _searchLocation = null;
                                  });
                                },
                              ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.blue),
                          ),
                        ),
                        onChanged: _onSearchChanged,
                      ),
                    ),
                    
                    if (_searchSuggestions.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        constraints: BoxConstraints(
                          maxHeight: bottomPadding > 0 
                              ? size.height * 0.2
                              : size.height * 0.25,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey.shade200),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          physics: const ClampingScrollPhysics(),
                          itemCount: _searchSuggestions.length,
                          itemBuilder: (context, index) {
                            final location = _searchSuggestions[index];
                            return ListTile(
                              dense: true,
                              leading: const Icon(
                                Icons.location_on,
                                color: Colors.blue,
                              ),
                              title: FutureBuilder<List<Placemark>>(
                                future: placemarkFromCoordinates(
                                  location.latitude,
                                  location.longitude,
                                ),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return const Text('Loading...');
                                  }
                                  final placemark = snapshot.data!.first;
                                  final address = [
                                    placemark.street,
                                    placemark.locality,
                                    placemark.subAdministrativeArea,
                                  ].where((e) => e?.isNotEmpty ?? false).join(', ');
                                  return Text(
                                    address,
                                    style: const TextStyle(fontSize: 14),
                                    overflow: TextOverflow.ellipsis,
                                  );
                                },
                              ),
                              onTap: () => _searchByLocation(location),
                            );
                          },
                        ),
                      ),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Search Radius',
                              style: TextStyle(
                                fontSize: size.width * 0.04,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${_searchRadius.round()} km',
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Slider(
                          value: _searchRadius,
                          min: 1,
                          max: 50,
                          divisions: 49,
                          activeColor: Colors.blue,
                          label: '${_searchRadius.round()} km',
                          onChanged: (value) {
                            setState(() => _searchRadius = value);
                            if (_searchLocation != null) {
                              _filterListings();
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Expanded(
                child: _isLoading 
                  ? const Center(child: CircularProgressIndicator())
                  : _nearbyListings.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.location_off,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No listings found nearby',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.all(size.width * 0.04),
                        itemCount: _nearbyListings.length,
                        itemBuilder: (context, index) {
                          final listing = _nearbyListings[index];
                          final distance = Geolocator.distanceBetween(
                            _searchLocation!.latitude,
                            _searchLocation!.longitude,
                            listing.latitude!,
                            listing.longitude!,
                          );
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: ListingCard(
                              listing: listing,
                              distance: distance,
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _locationController.dispose();
    super.dispose();
  }
}