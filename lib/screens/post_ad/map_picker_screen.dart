import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPickerScreen extends StatefulWidget {
  const MapPickerScreen({super.key});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class LocationResult {
  final LatLng coordinates;
  final String address;

  LocationResult({
    required this.coordinates,
    required this.address,
  });
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  LatLng? _selectedLocation;
  final _searchController = TextEditingController();
  bool _isSearching = false;
  List<Placemark> _searchResults = [];
  Timer? _debounceTimer;

  void _onSearchChanged(String query) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (query.length > 2) _searchLocation();
    });
  }

  Future<void> _searchLocation() async {
    setState(() => _isSearching = true);
    
    try {
      if (_searchController.text.isEmpty) {
        setState(() => _searchResults = []);
        return;
      }

      final searchText = '${_searchController.text}, Sri Lanka';
      final List<Location> locations = await locationFromAddress(searchText);

      if (locations.isNotEmpty) {
        final placemarks = <Placemark>[];
        
        for (var location in locations.take(5)) { 
          final marks = await placemarkFromCoordinates(
            location.latitude,
            location.longitude,
          );
          placemarks.addAll(marks);
        }
        
        setState(() {
          _searchResults = placemarks;
          _selectedLocation = LatLng(
            locations.first.latitude,
            locations.first.longitude,
          );
        });

        final controller = await _controller.future;
        controller.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: _selectedLocation!,
              zoom: 15,
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location search failed: $e')),
      );
    } finally {
      setState(() => _isSearching = false);
    }
  }

  void _selectSearchResult(Placemark place) async {
    try {
      final locations = await locationFromAddress(
        [
          place.street,
          place.locality,
          place.subAdministrativeArea,
          'Sri Lanka'
        ].where((e) => e != null && e.isNotEmpty).join(', ')
      );

      if (locations.isNotEmpty) {
        final location = locations.first;
        setState(() {
          _selectedLocation = LatLng(location.latitude, location.longitude);
          _searchController.text = [
            place.street,
            place.locality,
            place.subAdministrativeArea,
          ].where((e) => e != null && e.isNotEmpty).join(', ');
          _searchResults = []; 
        });

        final controller = await _controller.future;
        controller.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: _selectedLocation!,
              zoom: 15,
            ),
          ),
        );
      }
    } catch (e) {
      print('Error selecting location: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(
          'Select Boarding Location',
          style: TextStyle(
            color: Colors.black,
            fontSize: size.width * 0.055,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          if (_selectedLocation != null)
            TextButton(
              onPressed: () => Navigator.pop(
                context, 
                LocationResult(
                  coordinates: _selectedLocation!,
                  address: _searchController.text,
                ),
              ),
              child: Text(
                'Confirm',
                style: TextStyle(
                  fontSize: size.width * 0.04,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue,
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(size.width * 0.04),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search location',
                        prefixIcon: Icon(Icons.search, size: size.width * 0.06),
                        suffixIcon: _isSearching
                          ? Padding(
                              padding: EdgeInsets.all(size.width * 0.03),
                              child: SizedBox(
                                width: size.width * 0.05,
                                height: size.width * 0.05,
                                child: const CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          : IconButton(
                              icon: Icon(Icons.clear, size: size.width * 0.06),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchResults = []);
                              },
                            ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(size.width * 0.03),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      onChanged: _onSearchChanged,
                    ),
                    
                    if (_searchResults.isNotEmpty)
                      Container(
                        margin: EdgeInsets.only(top: size.width * 0.02),
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).viewInsets.bottom > 0 
                              ? MediaQuery.of(context).size.height - 
                                MediaQuery.of(context).viewInsets.bottom - 
                                MediaQuery.of(context).padding.top - 
                                kToolbarHeight - 120  
                              : size.height * 0.5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey.shade200),
                          borderRadius: BorderRadius.circular(size.width * 0.03),
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const ClampingScrollPhysics(),
                          itemCount: _searchResults.length,
                          itemBuilder: (context, index) {
                            final place = _searchResults[index];
                            final address = [
                              place.street,
                              place.locality,
                              place.subAdministrativeArea,
                            ].where((e) => e != null && e.isNotEmpty).join(', ');
                            
                            return ListTile(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: size.width * 0.04,
                                vertical: size.width * 0.01, 
                              ),
                              minVerticalPadding: 0, 
                              dense: true, 
                              leading: Icon(
                                Icons.location_on,
                                size: size.width * 0.06,
                                color: Colors.blue,
                              ),
                              title: Text(
                                address,
                                style: TextStyle(fontSize: size.width * 0.04),
                              ),
                              onTap: () => _selectSearchResult(place),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Map
            Expanded(
              child: Stack(  
                children: [
                  GoogleMap(
                    initialCameraPosition: const CameraPosition(
                      target: LatLng(7.8731, 80.7718),
                      zoom: 7,
                    ),
                    onMapCreated: _controller.complete,
                    onTap: (location) async {
                      setState(() => _selectedLocation = location);
                      try {
                        final placemarks = await placemarkFromCoordinates(
                          location.latitude,
                          location.longitude,
                        );
                        if (placemarks.isNotEmpty) {
                          final place = placemarks.first;
                          _searchController.text = [
                            place.street,
                            place.locality,
                            place.subAdministrativeArea,
                          ].where((e) => e != null && e.isNotEmpty).join(', ');
                        }
                      } catch (e) {
                        print('Error getting address: $e');
                      }
                    },
                    markers: _selectedLocation == null ? {} : {
                      Marker(
                        markerId: const MarkerId('selected'),
                        position: _selectedLocation!,
                        infoWindow: InfoWindow(
                          title: 'Selected Location',
                          snippet: _searchController.text,
                        ),
                      ),
                    },
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                    zoomControlsEnabled: true,
                  ),

                  // Add Location indicator
                  if (_selectedLocation != null)
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 16,
                      child: Container(
                        padding: EdgeInsets.all(size.width * 0.04),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(size.width * 0.03),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.location_on, 
                              color: Colors.blue,
                              size: size.width * 0.06,
                            ),
                            SizedBox(width: size.width * 0.02),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Selected Location',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: size.width * 0.04,
                                    ),
                                  ),
                                  Text(
                                    _searchController.text,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: size.width * 0.035,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}