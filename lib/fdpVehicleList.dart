import 'package:aapkaparking/PassRate.dart';
import 'package:aapkaparking/dueInRate.dart';
import 'package:aapkaparking/fixrate.dart';
import 'package:auto_size_text/auto_size_text.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FdpVehicles extends StatefulWidget {
  final String keyboardtype;
  final String title;
  const FdpVehicles({super.key, required this.keyboardtype,required this.title});

  @override
  State<FdpVehicles> createState() => _fdpState();
}

class _fdpState extends State<FdpVehicles> {
  // Replace with the current user's phone number

 // String? adminPhoneNumber;
  CollectionReference? vehiclesCollection;

  @override
  void initState() {
    super.initState();
    findAdminPhoneNumber();
  }

  

Future<void> findAdminPhoneNumber() async {
  User? currentUser = FirebaseAuth.instance.currentUser;
  String currentUserPhoneNumber = currentUser?.phoneNumber ?? 'unknown';

  try {
    // Retrieve the admin phone number from SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? adminPhoneNumber = prefs.getString('AdminNum');

    if (adminPhoneNumber != null) {
      // Admin number exists in SharedPreferences, so use it
      CollectionReference allUsersRef = FirebaseFirestore.instance.collection('AllUsers');
      DocumentReference adminDocRef = allUsersRef.doc(adminPhoneNumber);

      // Reference to the Users subcollection
      CollectionReference usersRef = adminDocRef.collection('Users');
      DocumentSnapshot userDoc = await usersRef.doc(currentUserPhoneNumber).get();

      if (userDoc.exists) {
        // Set admin phone number and update the vehiclesCollection reference
        setState(() {
          vehiclesCollection = adminDocRef.collection('Vehicles');
        });
      } else {
        // Handle case where user does not exist under the admin's Users subcollection
        setState(() {
          vehiclesCollection = null;
        });
      }
    } else {
      // Handle case where adminPhoneNumber is not in SharedPreferences
      setState(() {
        vehiclesCollection = null;
      });
    }
  } catch (e) {
    print('Error retrieving admin phone number: $e');
    setState(() {
      vehiclesCollection = null;
    });
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 225, 215, 206),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(0, 253, 216, 53),
        title: Text(
          'All Vehicles',
          style: GoogleFonts.nunito(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: vehiclesCollection == null
          ? const Center(child: CircularProgressIndicator(color: Color.fromARGB(255, 9, 9, 9)))
          : StreamBuilder<QuerySnapshot>(
              stream: vehiclesCollection!
                  .where('pricingdone', isEqualTo: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color.fromARGB(255, 5, 5, 5)),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No vehicle images found.'));
                }

                List<DocumentSnapshot> docs = snapshot.data!.docs;

                return GridView.builder(
                  padding: const EdgeInsets.all(8.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                  ),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    var doc = docs[index];
                    var imageUrl = doc['vehicleImage'];
                    var vehicleName =
                        capitalize(doc['vehicleName'] ?? 'Unknown');

                    return GestureDetector(
                      onTap: () {
                        if (widget.title=='Fix') {
                          
                        
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Fixirate(
                              imgUrl: imageUrl,
                              keyboardtype: widget.keyboardtype,
                            ),
                          ),
                        );
                         }
                         if (widget.title=='Due') {
                          
                        
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Duerate(
                              imgUrl: imageUrl,
                              keyboardtype: widget.keyboardtype,
                            ),
                          ),
                        );
                         }
                         if (widget.title=='Pass') {
                          
                        
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Passrate(
                              imgUrl: imageUrl,
                              keyboardtype: widget.keyboardtype,
                            ),
                          ),
                        );
                         }
                      },
                      child: Card(
                        elevation: 10.0,
                        color: const Color.fromARGB(
                            255, 225, 215, 206), // 3D effect
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: const BorderSide(
                            color: Colors.black, // Black color for the border
                            width: 1, // 2px width
                          ),
                        ),
                        child: Column(
                          children: [
                            Container(
                              height: 130,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.asset(
                                      'assets/animations/placeholder.png',
                                      fit: BoxFit.cover,
                                      height: 134,
                                      width: double.infinity,
                                    ),
                                  ),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: CachedNetworkImage(
                                      imageUrl: imageUrl,
                                      fit: BoxFit.cover,
                                      height: 134,
                                      width: double.infinity,
                                      placeholder: (context, url) => Container(
                                        alignment: Alignment.center,
                                        color: Colors.transparent,
                                        child: const CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.yellow),
                                        ),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          const Icon(Icons.error),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: AutoSizeText(
                                vehicleName,
                                style: GoogleFonts.nunito(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                ),
                                maxLines: 1, // Ensure single line
                                minFontSize: 12,
                                maxFontSize:
                                    17, // Minimum font size to shrink to
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  String capitalize(String s) => s[0].toUpperCase() + s.substring(1);
}
