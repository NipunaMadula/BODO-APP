import 'package:bodo_app/screens/post_ad/map_picker_screen.dart';
import 'package:bodo_app/services/location_service.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bodo_app/repositories/listing_repository.dart';

class PostAdScreen extends StatefulWidget {
  const PostAdScreen({super.key});

  @override
  State<PostAdScreen> createState() => _PostAdScreenState();
}

class _PostAdScreenState extends State<PostAdScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _phoneController = TextEditingController();

  String? _selectedDistrict;
  String? _selectedPropertyType;
  List<File> _selectedImages = [];
  bool _isLoading = false;
  bool _isAvailable = true;
  final _listingRepository = ListingRepository();
  double? _latitude;
  double? _longitude;
  final _locationService = LocationService();

  static const int maxImageSize = 5 * 1024 * 1024; 
  static const int maxImages = 10;


  Future<void> _getCurrentLocation() async {
  try {
    final position = await _locationService.getCurrentLocation();
    setState(() {
      _latitude = position.latitude;
      _longitude = position.longitude;
    });
  } catch (e) {
    _showErrorSnackBar('Failed to get location: $e');
  }
}

Future<void> _pickImages() async {
  try {
    if (_selectedImages.length >= maxImages) {
      _showErrorSnackBar('Maximum $maxImages images allowed');
      return;
    }

    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage(
      // Add these parameters to optimize image selection
      imageQuality: 70,
      maxWidth: 1200,
      maxHeight: 1200,
    );
    
    if (images.isNotEmpty) {

      if (_selectedImages.length + images.length > maxImages) {
        final remainingSlots = maxImages - _selectedImages.length;
        _showErrorSnackBar('Only $remainingSlots more images allowed');

        final selectedImages = images.take(remainingSlots);
        setState(() {
          _selectedImages.addAll(selectedImages.map((image) => File(image.path)));
        });
      } else {
        setState(() {
          _selectedImages.addAll(images.map((image) => File(image.path)));
        });
      }
    }
  } catch (e) {
    _showErrorSnackBar('Failed to pick images: $e');
  }
}
Future<void> _submitPost() async {
  // Validate form
  if (!_formKey.currentState!.validate()) return;

  if (_selectedImages.any((image) => image.lengthSync() > maxImageSize)) {
  _showErrorSnackBar('One or more images exceed 5MB. Please choose smaller images.');
  return;
}
  
  // Validate images
  if (_selectedImages.isEmpty) {
    _showErrorSnackBar('Please select at least one image');
    return;
  }

  setState(() => _isLoading = true);

  try {
    // Check authentication
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      throw 'Please sign in to post an advertisement';
    }

    // Validate selected type
    if (_selectedPropertyType == null) {
      throw 'Please select a property type';
    }

    // Validate price
    final price = double.tryParse(_priceController.text);
    if (price == null || price <= 0) {
      throw 'Please enter a valid price';
    }

    // Validate phone number format
    final phone = _phoneController.text.trim();
    if (!RegExp(r'^\d{10}$').hasMatch(phone)) {
      throw 'Please enter a valid 10-digit phone number';
    }

    // Create listing
    await _listingRepository.createListingWithImages(
      userId: userId,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      type: _selectedPropertyType!,
      district: _selectedDistrict!,
      price: price,
      location: _locationController.text.trim(),
      images: _selectedImages,
      phone: _phoneController.text.trim(),
      latitude: _latitude,  
      longitude: _longitude, 
      available: _isAvailable,
    );

    if (!mounted) return;

    // Show success and navigate back
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Advertisement posted successfully!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );

      // Clear form after successful posting
  setState(() {
    _titleController.clear();
    _priceController.clear();
    _locationController.clear();
    _descriptionController.clear();
    _phoneController.clear();
    _selectedPropertyType = null;
    _selectedDistrict = null; 
    _selectedImages.clear();
  });

  } catch (e) {
    // Handle specific errors
    String errorMessage = 'Failed to post advertisement. ';
    
    if (e.toString().contains('storage/unauthorized')) {
      errorMessage += 'Permission denied to upload images. Please try again.';
    } else if (e.toString().contains('network')) {
      errorMessage += 'Please check your internet connection.';
    } else {
      errorMessage += e.toString();
    }

    _showErrorSnackBar(errorMessage);
  } finally {
    // Reset loading state if still mounted
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }
}

// Helper method to show error messages
void _showErrorSnackBar(String message) {
  if (!mounted) return;
  
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
      duration: const Duration(seconds: 3),
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

// Helper method to validate phone number
bool _isValidPhoneNumber(String phone) {
  phone = phone.trim();
  if (phone.isEmpty) return false;
  if (phone.length != 10) return false;
  return RegExp(r'^[0-9]+$').hasMatch(phone);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Post Advertisement',
          style: TextStyle(
            color: Colors.black,
            fontSize: 25,
            fontWeight: FontWeight.w900,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Picker
              GestureDetector(
                onTap: _isLoading ? null : _pickImages,
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: _selectedImages.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_photo_alternate_outlined, 
                                size: 40, 
                                color: Colors.blue.shade300,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Add Photos (0/$maxImages)', 
                                style: TextStyle(
                                  color: Colors.blue.shade300,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _selectedImages.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Stack(
                                children: [
                                  Image.file(
                                    _selectedImages[index],
                                    height: 134,
                                    width: 134,
                                    fit: BoxFit.cover,
                                  ),
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: IconButton(
                                      icon: const Icon(Icons.close, color: Colors.white),
                                      onPressed: () {
                                        setState(() {
                                          _selectedImages.removeAt(index);
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ),

              const SizedBox(height: 24),

              // Property Details Form
              Text(
                'Property Details',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 16),

              // Title
              TextFormField(
                controller: _titleController,
                enabled: !_isLoading,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: 'Title',
                  hintText: 'Enter property title',
                  labelStyle: TextStyle(color: Colors.grey.shade600),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.blue.shade300),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Price
              TextFormField(
                controller: _priceController,
                enabled: !_isLoading,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the rent amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: 'Monthly Rent (Rs.)',
                  hintText: 'Enter monthly rent',
                  labelStyle: TextStyle(color: Colors.grey.shade600),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.blue.shade300),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // District    
              DropdownButtonFormField<String>(
                value: _selectedDistrict,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: 'District',
                  labelStyle: TextStyle(color: Colors.grey.shade600),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.blue.shade300),
                  ),
                ),
                icon: Icon(Icons.arrow_drop_down, color: Colors.grey.shade400),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a district';
                  }
                  return null;
                },
                items: [
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
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: _isLoading 
                    ? null 
                    : (String? newValue) {
                        setState(() {
                          _selectedDistrict = newValue;
                        });
                      },
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _locationController,
                      enabled: !_isLoading,
                      decoration: InputDecoration(
                        labelText: 'Location',
                        hintText: 'Enter boarding location',
                        prefixIcon: const Icon(Icons.location_on),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.map),
                    onPressed: () async {
                      final result = await Navigator.push<LocationResult>(
                        context,
                        MaterialPageRoute(builder: (_) => const MapPickerScreen()),
                      );
                      
                      if (result != null) {
                        setState(() {
                          _latitude = result.coordinates.latitude;
                          _longitude = result.coordinates.longitude;
                          _locationController.text = result.address; // Autofill the location text
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Location saved'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Property Type
              DropdownButtonFormField<String>(
                value: _selectedPropertyType,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: 'Property Type',
                  labelStyle: TextStyle(color: Colors.grey.shade600),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.blue.shade300),
                  ),
                ),
                icon: Icon(Icons.arrow_drop_down, color: Colors.grey.shade400),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a property type';
                  }
                  return null;
                },
                items: ['Student', 'Boys Only', 'Girls Only',  'Professional', 'Family']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: _isLoading 
                    ? null 
                    : (String? newValue) {
                        setState(() {
                          _selectedPropertyType = newValue;
                        });
                      },
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                enabled: !_isLoading,
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: 'Description',
                  hintText: 'Enter property description',
                  labelStyle: TextStyle(color: Colors.grey.shade600),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.blue.shade300),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Contact Information
              const Text(
                'Contact Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Phone Number
              TextFormField(
                controller: _phoneController,
                enabled: !_isLoading,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  hintText: 'Enter your phone number',
                  labelStyle: TextStyle(color: Colors.grey.shade600),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.blue.shade300),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SwitchListTile(
                title: const Text('Available'),
                value: _isAvailable,
                onChanged: _isLoading ? null : (v) => setState(() => _isAvailable = v),
                secondary: Icon(
                  _isAvailable ? Icons.check_circle : Icons.block,
                  color: _isAvailable ? Colors.green : Colors.red,
                ),
              ),

              // Post Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitPost,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade400,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Post Advertisement',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}