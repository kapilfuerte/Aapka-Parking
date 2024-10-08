import 'dart:io';
import 'dart:ui' as ui;
import 'package:aapkaparking/bluetoothManager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Receipt extends StatefulWidget {
  final String vehicleNumber;
  final String rateType;
  final String price;
  final String page;

  const Receipt({
    super.key,
    required this.vehicleNumber,
    required this.rateType,
    required this.price,
    required this.page,
  });

  @override
  State<Receipt> createState() => _ReceiptState();
}

class _ReceiptState extends State<Receipt> {
  final DateFormat formatter = DateFormat('HH:mm:ss');
  String parkingLogo = '';
  String parkingName = '';
  bool isLoading = true;
  BluetoothManager bluetoothManager = BluetoothManager();

  @override
  void initState() {
    super.initState();
    findAdminAndFetchParkingDetails();
  }

  Future<void> findAdminAndFetchParkingDetails() async {
    try {
      // Get the admin's phone number from SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? adminPhoneNumber = prefs.getString('AdminNum');

      if (adminPhoneNumber == null) {
        // Handle the case where the admin phone number is not available
        setState(() {
          isLoading = false;
        });
        return;
      }

      // Reference to the AllUsers collection
      DocumentReference adminDocRef = FirebaseFirestore.instance
          .collection('AllUsers')
          .doc(adminPhoneNumber);

      // Fetch the admin document
      DocumentSnapshot adminDoc = await adminDocRef.get();

      if (adminDoc.exists) {
        // Extract parking name and logo from the admin's document
        Map<String, dynamic> adminData =
            adminDoc.data() as Map<String, dynamic>;

        setState(() {
          parkingLogo = adminData['ParkingLogo'] ?? '';
          parkingName = adminData['ParkingName'] ?? 'Parking Name';
          isLoading = false;
        });

        // Call printReceipt to print the receipt
        printReceipt();
      } else {
        // If admin document doesn't exist
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching parking details: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<String> _saveQrCodeToFile(String data) async {
    // Create a QrPainter with the data
    final qrPainter = QrPainter(
      data: data,
      version: QrVersions.auto,
      gapless: false,
    );

    // Create a picture recorder to capture the QR code image
    final picRecorder = ui.PictureRecorder();
    final canvas = Canvas(picRecorder);
    final size = 400.0; // QR code size
    qrPainter.paint(canvas, Size(size, size));

    // Convert canvas to an image
    final image =
        await picRecorder.endRecording().toImage(size.toInt(), size.toInt());

    // Convert image to byte data (BMP format)
    final byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    final bmpBytes = byteData!.buffer.asUint8List();

    // Save the image to a temporary directory as BMP
    final tempDir = await getTemporaryDirectory();
    final qrFile = File('${tempDir.path}/qrcode.bmp');

    // Write bytes to file
    await qrFile.writeAsBytes(bmpBytes);

    // Return the file path
    return qrFile.path;
  }

  Future<void> printReceipt() async {
    final printer = bluetoothManager.printer;

    printer.printNewLine();
    printer.printCustom('${widget.page} Receipt Details', 4, 1);
    printer.printNewLine();

    printer.printCustom(parkingName, 4, 1);
    printer.printNewLine();

    String dateTime =
        'DATE: ${DateFormat('dd MMMM yyyy').format(DateTime.now())}, Time: ${DateFormat('hh:mm a').format(DateTime.now())}';
    printer.printCustom(dateTime, 1, 1);
    printer.printNewLine();

    printer.printCustom('Vehicle No.:${widget.vehicleNumber}', 2, 1);
    printer.printNewLine();
    printer.printCustom('Amount: Rs:${widget.price}', 2, 1);
    printer.printNewLine();

    printer.printQRcode(widget.vehicleNumber, 220, 220, 1);
    printer.printNewLine();
    // final qrFilePath = await _saveQrCodeToFile(widget.vehicleNumber);

   // Print the QR code image from the file path
    // printer.printImage(qrFilePath);
    printer.printNewLine();
    printer.printCustom('Thank you, Lucky Road!', 1, 1);
    printer.printNewLine();
    printer.paperCut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 225, 215, 206),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 225, 215, 206),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        title: Text(
          'Receipt Details',
          style: GoogleFonts.nunito(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 3.0, // Add elevation
        shadowColor: const Color.fromARGB(
            255, 25, 239, 1), // Green shadow color with slight transparency
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
              color: ui.Color.fromARGB(255, 2, 2, 2),
            ))
          : LayoutBuilder(
              builder: (context, constraints) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SizedBox(
                      height: constraints.maxHeight,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            children: [
                              Image.network(
                                parkingLogo,
                                height: constraints.maxHeight * 0.15,
                              ),
                              const SizedBox(height: 20),
                              Text(
                                parkingName,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                          Container(
                            height: 2,
                            color: const Color.fromARGB(255, 25, 239, 1),
                          ),
                          Text(
                            'Paid Parking',
                            style: GoogleFonts.nunito(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            'DATE: ${DateFormat('dd MMM yyyy').format(DateTime.now())}, Time: ${DateFormat('hh:mm a').format(DateTime.now())}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Column(
                            children: [
                              Text(
                                'Vehicle No.: ${widget.vehicleNumber}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Amount: ₹${widget.price}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                          QrImageView(
                            data: widget.vehicleNumber,
                            size: constraints.maxHeight * 0.3,
                            backgroundColor: Colors.white,
                          ),
                          Container(
                            height: 2,
                            color: Color.fromARGB(255, 25, 239, 1),
                          ),
                          const Text(
                            'Thank you, Lucky Road!',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
