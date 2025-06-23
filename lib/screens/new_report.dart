import 'dart:io';
import 'package:e_vandalism/screens/thank_you_page.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:e_vandalism/models/report_data.dart';
import 'package:e_vandalism/services/database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
// import 'package:e_vandalism/services/send_email.dart';
import 'package:firebase_storage/firebase_storage.dart';

class NewReport extends StatefulWidget {
  const NewReport({super.key});

  @override
  State<NewReport> createState() => _NewReportState();
}

class _NewReportState extends State<NewReport> {

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailOrContactNoController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  DateTime? _selectedDate;
  final TextEditingController _descriptionController = TextEditingController();

  File? _image; // To store the selected image
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    
    if (pickedFile != null) {
      setState(() {
          _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async{
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = '${picked.day}/${picked.month}/${picked.year}';
      });
    }
  }

  Future<void> _getCurrentLocation() async{
    bool serviceEnabled;
    LocationPermission permission;

    // show a loading dialog while fetching the location
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    // check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) Navigator.pop(context); // Close the loading dialog
      if (mounted) {
        // Show a SnackBar to notify the user
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Location services are disabled. Please enable GPS.',
            ),
          ),
        );
      }
      return;
    }

    try{
      // check location permission
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) Navigator.pop(context);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Location permission denied')),
            );
          }
          return;
        }
      }

      // Get the current position
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      // Convert coordinates to address
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        String address = '${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.country}';
        setState( () {
          _locationController.text = address;
        });
      }
    } catch (e) {
       if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to get location: $e')),
        );
      }
    } finally {
      if (mounted) Navigator.pop(context); // close the loading dialog
    }
  }

  Future<void> _submitReport() async{
    if (_formKey.currentState!.validate()) {
      if (_image == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please upload an image')),
        );
        return;
      }

      try{
        // show a loading dialog while submitting the report
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        );

        // get the next ReportID
        final reportId = await DatabaseService(id: '').getAndIncrementReportID();
      
        // upload the image to firebase storage
        final storageRef = FirebaseStorage.instance.ref().child('report_images/$reportId.jpg'); // Store the image with the report ID
        final uploadTask = await storageRef.putFile(_image!);
        final downloadUrl = await uploadTask.ref.getDownloadURL(); // Get the download URL of the image
      
        final report = ReportData(
          id: reportId.toString(),
          emailOrContactNo: _emailOrContactNoController.text,
          picture: downloadUrl, // Store the download URL of the image
          location: _locationController.text,
          date: _selectedDate!,
          description: _descriptionController.text,
          status: 'Pending',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
      );

      // save the report to Firestore
      await DatabaseService(id: reportId.toString()).addReport(report);

      // Send an email to the admin using mailer package (optional)
      // await sendEmail(
      //   'New Report Submitted',
      //   'A new report has been submitted:\n\n'
      //   'Location: ${_locationController.text}\n'
      //   'Date: ${_dateController.text}\n'
      //   'Description: ${_descriptionController.text}',
      // );

      // reset the form
      _formKey.currentState!.reset();
      _locationController.clear();
      _descriptionController.clear();
      setState(() {
        _image = null; // Reset the image after submission
      });

      if (!mounted) return;

      // Navigate to thank you page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ThankYouPage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit report: $e')),
      );
    }
  } else {
    // Check which field is invalid and show specific error messages
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    final contactNumberRegex = RegExp(r'^\d{10,15}$');
    final invalidCharactersRegex = RegExp(r'[-\s]');

    if (_emailOrContactNoController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an email or contact number. Example: 011XXXXXXX or example@gmail.com or 123456@siswa.unimas.my')),
      );
    } else if (invalidCharactersRegex.hasMatch(_emailOrContactNoController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid characters detected. Please remove "-" or spaces. Example: 011XXXXXXX or example@gmail.com or 123456@siswa.unimas.my')),
      );
    }else if (!emailRegex.hasMatch(_emailOrContactNoController.text) && !contactNumberRegex.hasMatch(_emailOrContactNoController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email or contact number. Example: 011XXXXXXX or example@gmail.com or 123456@siswa.unimas.my'),),
      );
    } else if (_locationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a location')),
      );
    } else if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'New Report Submission',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            ),
          ),
        backgroundColor: Colors.red,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Email or Contact Number Section
                const Text(
                  'Email or Contact Number',
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _emailOrContactNoController,
                  decoration: const InputDecoration(
                    enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 2.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.pink, width: 2.0),
                  ),
                    hintText: 'Enter Email or Contact Number',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an email or contact number';
                    }

                    // Regular expression for validating email
                    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');

                    // Regular expression for validating contact number (e.g., 10-15 digits)
                    final contactNumberRegex = RegExp(r'^\d{10,15}$');

                    if (!emailRegex.hasMatch(value) && !contactNumberRegex.hasMatch(value)) {
                      return 'Please enter a valid email or contact number. \n Example: 011XXXXXXX \n example@gmail.com or 123456@siswa.unimas.my';
                    }

                    return null; // Input is valid
                  },
                ),

                // Images Section
                const Text(
                  'Images',
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8.0),
                
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () => _pickImage(ImageSource.gallery),
                      child: const Text ('upload Image'),
                    ),
                    const SizedBox (width: 8.0),
                    ElevatedButton(
                      onPressed: () => _pickImage(ImageSource.camera),
                      child: const Text ('Take Photo'),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                Container(
                  height: 200.0,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue),
                  ),
                  child: _image !=null
                    ? Image.file(
                        _image!, // if image is not null, show the image
                        fit: BoxFit.contain, // fit the image to the container
                      ) 
                    : const Center(child: Text('No image selected'), // if no image selected, show this message
                  ),
                ),
                const SizedBox(height: 16.0),
            
            
                // Location Section
                const Text(
                  'Location',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8.0,),

                ElevatedButton(
                  onPressed: _getCurrentLocation,
                  child: const Text('Use Current Location'),
                ),

                const SizedBox(height: 8.0),
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 2.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.pink, width: 2.0),
                  ),
                    hintText: 'Enter Location',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'Please enter a location' : null,
                ),
                const SizedBox(height: 8.0),
                

                // Date Section
                const Text(
                  'Date',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8.0,),
                TextFormField(
                  controller: _dateController,
                  readOnly: true,
                  decoration: const InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 2.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.pink, width: 2.0),
                  ),
                    hintText: 'DD/MM/YYYY',
                    border: OutlineInputBorder(),
                  ),
                  onTap: () => _selectDate(context),
                  validator: (value) {
                    if (_selectedDate == null) {
                      return 'Please select a date';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                

                // Description Section
                const Text(
                  'Description (Optional)',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8.0,),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 2.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.pink, width: 2.0),
                  ),
                  hintText: 'Tap to add description',
                  ),
                ),
                const SizedBox(height: 32.0),
            

                // Submit Button
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      // Handle form submission
                      _submitReport();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40.0,
                        vertical: 15.0,
                      ),
                    ),
                    child: const Text(
                      'Submit',
                      style: TextStyle(color: Colors.white,),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}