import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class Adduser2 extends StatefulWidget {
  const Adduser2({super.key});

  @override
  State<Adduser2> createState() => _AdduserState();
}

class _AdduserState extends State<Adduser2> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  bool _buttonEnabled = false;

  // Function to save user data
  void saveUser() async {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    final String phoneNumber = '+91' + phoneController.text.trim();
    final String currentAdminId =
        FirebaseAuth.instance.currentUser?.phoneNumber ?? '';
    final String userName = nameController.text.trim();
    if (phoneController.text.isEmpty && nameController.text.isEmpty) {
      // Handle validation
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('please provide  name and phone number.'),
            duration: const Duration(milliseconds: 300)),
      );
      return;
    }
    if (phoneController.text.isEmpty) {
      // Handle validation
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('please provide Phone number also.'),
          duration: const Duration(milliseconds: 300),
        ),
      );
      return;
    }

    if (nameController.text.isEmpty) {
      // Handle validation
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('please provide name also.'),
          duration: const Duration(milliseconds: 300),
        ),
      );
      return;
    }
    if (phoneController.text.length < 10) {
      // Handle validation
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide a valid phone number of 10 digit.'),
          duration: const Duration(milliseconds: 300),
        ),
      );
      return;
    }
    if (phoneController.text.startsWith(RegExp(r'[0-6]'))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Phone number cannot start with 0, 1, 2, 3, 4, 5, or 6. Please provide a valid phone number.'),
          duration: Duration(milliseconds: 400),
        ),
      );
      return;
    }

    final Map<String, dynamic> UserData = {
      'uid': phoneNumber,
      'userName': userName,
      'CreatedAt': DateTime.now(),
      'isdeleted': false
    };
    // final Map<String, dynamic> AdminData = {
    //   'uid': currentAdminId,
    //   'ParkingSubscribePackage': 0,
    //   'CreatedAt': DateTime.now(),
    //   'Usertype': 'Admin',
    //   'isdeleted': false
    // };
    // Get the current admin's phone number

    if (currentAdminId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No admin logged in')),
      );
      return;
    }
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing the dialog
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(
            backgroundColor: Color.fromARGB(255, 206, 200, 200),
            color: Colors.black,
          ), // Show loader
        );
      },
    );
    try {
      // Save user data in "All Users" collection
      // await FirebaseFirestore.instance
      //     .collection('AllUsers')
      //     .doc(currentAdminId)
      //     .set(AdminData);
      await FirebaseFirestore.instance
          .collection('LoginUsers')
          .doc(phoneNumber)
          .set(UserData);

      // Save user data in current admin's "Users" collection
      await FirebaseFirestore.instance
          .collection('AllUsers')
          .doc(currentAdminId)
          .collection('Users')
          .doc(phoneNumber)
          .set(UserData);

      // Show success dialog
      Navigator.of(context).pop();
      _showSuccessDialog();

      phoneController.clear();
      nameController.clear();
      setState(() {
        _buttonEnabled = false;
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add user: $error')),
      );
    }
  }

  // Function to show success dialog
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                'assets/animations/complete.json',
                height: 100,
                width: 100,
              ),
              const SizedBox(height: 20),
              const Text(
                'New User Added Successfully!',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromARGB(255, 225, 215, 206),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  // Orange and yellow splash with blur effect at the top left corner

                  Positioned(
                    top: 30,
                    left: 20,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.orange.shade300,
                            Colors.yellow.shade200
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(
                          sigmaX: 30.0,
                          sigmaY: 30.0,
                        ),
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.transparent,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 80,
                    left: 70,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color.fromARGB(255, 243, 255, 77),
                            Color.fromARGB(255, 251, 230, 190)
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(
                          sigmaX: 30.0,
                          sigmaY: 30.0,
                        ),
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.transparent,
                          ),
                        ),
                      ),
                    ),
                  ),

                  SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title and Name
                        const SizedBox(
                          height: 250,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 10.0),
                                child: Text(
                                  'Add User',
                                  style: GoogleFonts.playfairDisplay(
                                    fontSize:
                                        constraints.maxWidth > 600 ? 50 : 40,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 10.0),
                                child: Text(
                                  'Name',
                                  style: GoogleFonts.playfairDisplay(
                                    fontSize:
                                        constraints.maxWidth > 600 ? 50 : 40,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        // TextFields
                        SizedBox(
                          width: double.infinity,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                  child: Text(
                                'User name',
                                style: GoogleFonts.notoSansHanunoo(
                                    color: const Color.fromARGB(255, 5, 5, 5)),
                              )),
                              const SizedBox(
                                height: 5,
                              ),
                              TextField(
                                controller: nameController,
                                style: const TextStyle(
                                    color: Colors.black, fontSize: 20),
                                decoration: InputDecoration(
                                  counterText: '',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(0),
                                    borderSide: const BorderSide(
                                      color: Colors.black,
                                      width: 2,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(0),
                                    borderSide: const BorderSide(
                                      color: Colors.black,
                                      width: 2,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(0),
                                    borderSide: const BorderSide(
                                      color: Colors.black,
                                      width: 2,
                                    ),
                                  ),
                                  hintText: 'Enter user name',
                                  hintStyle: GoogleFonts.notoSansHanunoo(
                                      color: Colors.grey, fontSize: 14),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(RegExp(
                                      r'[a-zA-Z0-9 ]')), // Allows only letters, numbers, and spaces
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _buttonEnabled = value.isNotEmpty &&
                                        phoneController.text.length == 10;
                                  });
                                },
                              )
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                  child: Text(
                                'Phone number',
                                style: GoogleFonts.notoSansHanunoo(
                                    color: const Color.fromARGB(255, 5, 5, 5)),
                              )),
                              const SizedBox(
                                height: 5,
                              ),
                              TextField(
                                controller: phoneController,
                                keyboardType: TextInputType.phone,
                                maxLength: 10,
                                style: const TextStyle(
                                    color: Colors.black, fontSize: 20),
                                decoration: InputDecoration(
                                  counterText: '',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(0),
                                    borderSide: const BorderSide(
                                      color: Colors.black,
                                      width: 2,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(0),
                                    borderSide: const BorderSide(
                                      color: Colors.black,
                                      width: 2,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(0),
                                    borderSide: const BorderSide(
                                      color: Colors.black,
                                      width: 2,
                                    ),
                                  ),
                                  hintText: 'Enter phone number',
                                  hintStyle: GoogleFonts.notoSansHanunoo(
                                      color: Colors.grey, fontSize: 14),
                                  prefixIcon: const Padding(
                                    padding:
                                        EdgeInsets.only(right: 5.0, left: 10),
                                    child: Text(
                                      '+91 |',
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: Color.fromARGB(255, 11, 11, 11),
                                      ),
                                    ),
                                  ),
                                  prefixIconConstraints: const BoxConstraints(
                                      minWidth: 0, minHeight: 0),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    _buttonEnabled = value.length == 10 &&
                                        nameController.text.isNotEmpty;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 80),
                        GestureDetector(
                          onTap: saveUser,
                          child: Container(
                            width: double.infinity,
                            height: 52,
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 24),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.4),
                                  offset: const Offset(4, 4),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                                const BoxShadow(
                                  color: Colors.white,
                                  offset: Offset(-4, -4),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                'ADD USER',
                                style: GoogleFonts.notoSansHanunoo(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                      top: 40,
                      left: -14,
                      child: IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon: const Icon(
                            Icons.chevron_left,
                            size: 37,
                            color: Colors.black,
                          ))),
                ],
              );
            },
          ),
        ));
  }
}
