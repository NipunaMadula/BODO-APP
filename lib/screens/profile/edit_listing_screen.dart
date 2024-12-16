import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bodo_app/models/listing_model.dart';
import 'package:bodo_app/repositories/listing_repository.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

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

  final List<String> _districts = [
    'Colombo', 'Gampaha', 'Kalutara', 'Kandy', 'Matale', 'Nuwara Eliya',
    'Galle', 'Matara', 'Hambantota', 'Jaffna', 'Kilinochchi', 'Mannar',
    'Mullaitivu', 'Vavuniya', 'Trincomalee', 'Batticaloa', 'Ampara',
    'Kurunegala', 'Puttalam', 'Anuradhapura', 'Polonnaruwa', 'Badulla',
    'Monaragala', 'Ratnapura', 'Kegalle'
  ];

  final List<String> _propertyTypes = ['Student', 'Professional', 'Mixed', 'Family'];

  // Add validation helper for district
  String? _getValidDistrict(String? district) {
    if (district == null) return null;
    return _districts.contains(district) ? district : null;
  }

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    _titleController.text = widget.listing.title;
    _priceController.text = widget.listing.price.toString();
    _locationController.text = widget.listing.location;
    _descriptionController.text = widget.listing.description;
    _phoneController.text = widget.listing.phone;
    _selectedPropertyType = widget.listing.type;
    _selectedDistrict = _getValidDistrict(widget.listing.district);
    _existingImages = List.from(widget.listing.images);
  }

  Future<void> _pickImages() async {
    try {
      final ImagePicker picker = ImagePicker();
      final List<XFile> images = await picker.pickMultiImage(
        imageQuality: 70,
        maxWidth: 1200,
        maxHeight: 1200,
      );
      
      if (images.isNotEmpty) {
        setState(() {
          _newImages.addAll(images.map((image) => File(image.path)));
        });
      }
    } catch (e) {
      _showErrorSnackBar('Failed to pick images: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  Future<void> _updateListing() async {
    if (!_formKey.currentState!.validate()) return;

    // Validate images
    if (_existingImages.isEmpty && _newImages.isEmpty) {
      _showErrorSnackBar('At least one image is required');
      return;
    }

    // Validate district
    if (_selectedDistrict == null) {
      _showErrorSnackBar('Please select a district');
      return;
    }

    // Validate property type
    if (_selectedPropertyType == null) {
      _showErrorSnackBar('Please select a property type');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Upload new images if any
      List<String> allImages = List.from(_existingImages);
      if (_newImages.isNotEmpty) {
        final newImageUrls = await _listingRepository.uploadImages(
          _newImages,
          FirebaseAuth.instance.currentUser!.uid,
        );
        allImages.addAll(newImageUrls);
      }

      // Validate phone number
      final phone = _phoneController.text.trim();
      if (!RegExp(r'^\d{10}$').hasMatch(phone)) {
        throw 'Please enter a valid 10-digit phone number';
      }

      // Update listing
      await _listingRepository.updateListing(
        widget.listing.id,
        {
          'title': _titleController.text.trim(),
          'description': _descriptionController.text.trim(),
          'type': _selectedPropertyType,
          'price': double.parse(_priceController.text),
          'location': _locationController.text.trim(),
          'district': _selectedDistrict,
          'phone': phone,
          'images': allImages,
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Listing updated successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      _showErrorSnackBar(e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Images Section
            Text(
              'Images (${_existingImages.length + _newImages.length})',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 150,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(8),
                children: [
                  // Existing Images
                  ..._existingImages.asMap().entries.map((entry) {
                    return Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(4),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              entry.value,
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () {
                              setState(() {
                                _existingImages.removeAt(entry.key);
                              });
                            },
                          ),
                        ),
                      ],
                    );
                  }),

                  // New Images
                  ..._newImages.asMap().entries.map((entry) {
                    return Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(4),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              entry.value,
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () {
                              setState(() {
                                _newImages.removeAt(entry.key);
                              });
                            },
                          ),
                        ),
                      ],
                    );
                  }),

                  // Add Image Button
                  if (_existingImages.length + _newImages.length < 10)
                    InkWell(
                      onTap: _pickImages,
                      child: Container(
                        width: 120,
                        height: 120,
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate, size: 32),
                            SizedBox(height: 4),
                            Text('Add Photo'),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Form Fields
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Title is required';
                return null;
              },
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Monthly Rent (Rs.)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Price is required';
                final price = double.tryParse(value!);
                if (price == null || price <= 0) return 'Enter a valid price';
                return null;
              },
            ),

            const SizedBox(height: 16),

            // District Dropdown
            DropdownButtonFormField<String>(
              value: _selectedDistrict,
              decoration: InputDecoration(
                labelText: 'District',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: _districts.map((district) {
                return DropdownMenuItem(
                  value: district,
                  child: Text(district),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedDistrict = value);
              },
              validator: (value) {
                if (value == null) return 'Please select a district';
                return null;
              },
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _locationController,
              decoration: InputDecoration(
                labelText: 'Location',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Location is required';
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Property Type Dropdown
            DropdownButtonFormField<String>(
              value: _selectedPropertyType,
              decoration: InputDecoration(
                labelText: 'Property Type',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: _propertyTypes.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedPropertyType = value);
              },
              validator: (value) {
                if (value == null) return 'Please select a property type';
                return null;
              },
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Description is required';
                return null;
              },
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Phone number is required';
                if (!RegExp(r'^\d{10}$').hasMatch(value!)) {
                  return 'Enter a valid 10-digit phone number';
                }
                return null;
              },
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _updateListing,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Update Listing',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
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