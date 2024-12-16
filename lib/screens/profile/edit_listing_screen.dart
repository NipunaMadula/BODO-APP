import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bodo_app/models/listing_model.dart';
import 'package:bodo_app/repositories/listing_repository.dart';
import 'dart:io';

class EditListingScreen extends StatefulWidget {
  final ListingModel listing;

  const EditListingScreen({required this.listing, super.key});

  @override
  State<EditListingScreen> createState() => _EditListingScreenState();
}

class _EditListingScreenState extends State<EditListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _phoneController = TextEditingController();
  
  String? _selectedDistrict;
  String? _selectedPropertyType;
  List<String> _existingImages = [];
  List<File> _newImages = [];
  bool _isLoading = false;
  final _listingRepository = ListingRepository();

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.listing.title;
    _priceController.text = widget.listing.price.toString();
    _locationController.text = widget.listing.location;
    _descriptionController.text = widget.listing.description;
    _phoneController.text = widget.listing.phone;
    _selectedPropertyType = widget.listing.type;
    _selectedDistrict = widget.listing.district;
    _existingImages = List.from(widget.listing.images);
  }

  Future<void> _updateListing() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Upload any new images first
      List<String> allImages = List.from(_existingImages);
      if (_newImages.isNotEmpty) {
        final newImageUrls = await _listingRepository.uploadImages(
          _newImages,
          FirebaseAuth.instance.currentUser!.uid,
        );
        allImages.addAll(newImageUrls);
      }

      // Update the listing
      await _listingRepository.updateListing(
        widget.listing.id,
        {
          'title': _titleController.text.trim(),
          'description': _descriptionController.text.trim(),
          'type': _selectedPropertyType,
          'price': double.parse(_priceController.text),
          'location': _locationController.text.trim(),
          'district': _selectedDistrict,
          'phone': _phoneController.text.trim(),
          'images': allImages,
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Listing updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating listing: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _removeExistingImage(int index) {
    setState(() {
      _existingImages.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Listing'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Images Section
              const Text(
                'Images',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 150,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    ..._existingImages.asMap().entries.map((entry) {
                      return Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(4),
                            child: Image.network(
                              entry.value,
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => _removeExistingImage(entry.key),
                              color: Colors.red,
                            ),
                          ),
                        ],
                      );
                    }),
                    // Add new images button
                    // ... Rest of your existing image picker UI
                  ],
                ),
              ),

              // Form Fields
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),

              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Monthly Rent (Rs.)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Required';
                  if (double.tryParse(value!) == null) return 'Invalid number';
                  return null;
                },
              ),

              // Add rest of your form fields...

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updateListing,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Update Listing'),
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
    _titleController.dispose();
    _priceController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}