import 'dart:async';

import 'package:bodo_app/models/listing_model.dart';
import 'package:bodo_app/repositories/listing_repository.dart';
import 'package:bodo_app/screens/home/listing_detail_screen.dart';
import 'package:bodo_app/services/location_service.dart';
import 'package:bodo_app/widgets/distance_filter_widget.dart';
import 'package:bodo_app/widgets/listing_card.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class NearbyListingsScreen extends StatefulWidget {
  const NearbyListingsScreen({super.key});

  @override
  State<NearbyListingsScreen> createState() => _NearbyListingsScreenState();
}

class _NearbyListingsScreenState extends State<NearbyListingsScreen> {
  final _locationService = LocationService();
  final _listingRepository = ListingRepository();
  final Completer<GoogleMapController> _controller = Completer();
  double _searchRadius = 5.0;
  Position? _userLocation;
  List<ListingModel> _nearbyListings = [];
  bool _isLoading = true;
  bool _showMap = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await _locationService.getCurrentLocation();
      setState(() {
        _userLocation = position;
      });
      await _loadNearbyListings();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error getting location: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }


  Future<void> _loadNearbyListings() async {
    if (_userLocation == null) {
      print('User location is null. Cannot load nearby listings.');
      setState(() => _nearbyListings = []);
      return;
    }

    final allListings = await _listingRepository.getAllListings();
    print('Total listings fetched: [32m${allListings.length}[0m');
    int missingCoords = 0;
    int outOfRadius = 0;
    final nearbyListings = allListings.where((listing) {
      if (listing.latitude == null || listing.longitude == null) {
        missingCoords++;
        return false;
      }
      final distance = Geolocator.distanceBetween(
        _userLocation!.latitude,
        _userLocation!.longitude,
        listing.latitude!,
        listing.longitude!,
      );
      if (distance > _searchRadius * 1000) {
        outOfRadius++;
        return false;
      }
      return true;
    }).toList();
    print('Listings missing coordinates: [33m$missingCoords[0m');
    print('Listings out of radius: [33m$outOfRadius[0m');
    print('Nearby listings found: [32m${nearbyListings.length}[0m');
    setState(() => _nearbyListings = nearbyListings);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Nearby Listings',
          style: TextStyle(
            color: Colors.black,
            fontSize: size.width * 0.06,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _showMap ? Icons.list : Icons.map,
              size: size.width * 0.06,
            ),
            onPressed: () => setState(() => _showMap = !_showMap),
          ),
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              // Distance Filter
              DistanceFilterWidget(
                currentRadius: _searchRadius,
                onRadiusChanged: (value) {
                  setState(() => _searchRadius = value);
                  _loadNearbyListings();
                },
              ),

              // Listings or Map
              Expanded(
                child: _showMap ? _buildMap() : _buildListView(),
              ),
            ],
          ),
    );
  }

  Widget _buildListView() {
    final size = MediaQuery.of(context).size;

    if (_nearbyListings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_off,
              size: size.width * 0.15,
              color: Colors.grey,
            ),
            SizedBox(height: size.width * 0.04),
            Text(
              'No listings found nearby',
              style: TextStyle(
                fontSize: size.width * 0.045,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: size.width * 0.03),
            Text(
              'Possible reasons:\n• No listings in your area\n• Listings missing location data\n• Location permission not granted\n• Search radius too small',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: size.width * 0.04, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(size.width * 0.04),
      itemCount: _nearbyListings.length,
      itemBuilder: (context, index) {
        final listing = _nearbyListings[index];
        final distance = Geolocator.distanceBetween(
          _userLocation!.latitude,
          _userLocation!.longitude,
          listing.latitude!,
          listing.longitude!,
        );

        return Padding(
          padding: EdgeInsets.only(bottom: size.width * 0.03),
          child: ListingCard(
            listing: listing,
            distance: distance,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ListingDetailScreen(listing: listing),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMap() {
    if (_userLocation == null) {
      return const Center(
        child: Text('Location not available'),
      );
    }

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: LatLng(_userLocation!.latitude, _userLocation!.longitude),
        zoom: 12,
      ),
      onMapCreated: _controller.complete,
      markers: {
        Marker(
          markerId: const MarkerId('user'),
          position: LatLng(_userLocation!.latitude, _userLocation!.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(title: 'Your Location'),
        ),
        ..._nearbyListings.map((listing) {
          if (listing.latitude == null || listing.longitude == null) return null;
          
          return Marker(
            markerId: MarkerId(listing.id),
            position: LatLng(listing.latitude!, listing.longitude!),
            infoWindow: InfoWindow(
              title: listing.title,
              snippet: 'Rs.${listing.price}/month',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ListingDetailScreen(listing: listing),
                ),
              ),
            ),
          );
        }).whereType<Marker>(),
      },
      circles: {
        Circle(
          circleId: const CircleId('searchArea'),
          center: LatLng(_userLocation!.latitude, _userLocation!.longitude),
          radius: _searchRadius * 1000,
          fillColor: Colors.blue.withOpacity(0.1),
          strokeColor: Colors.blue,
          strokeWidth: 1,
        ),
      },
    );
  }
}