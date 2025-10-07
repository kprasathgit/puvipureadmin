import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pinput/pinput.dart';

class CommonMethods {
  static Future<bool> showPinConfirmDialog(BuildContext context) async {
    final storage = const FlutterSecureStorage();
    final savedPin = await storage.read(key: 'admin_pin');

    String enteredPin = '';
    final errorNotifier = ValueNotifier<bool>(false);
    final pinController = TextEditingController();
    final pinFocusNode = FocusNode(); // 🔹 focus node for Pinput

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // 🔹 Use smaller side of screen for scaling
    final baseSize = screenWidth < screenHeight ? screenWidth : screenHeight;

    // Each PIN box = 10% of smaller side
    double pinBoxSize = baseSize * 0.1;

    // 🔹 Clamp between 50–70 so it never gets too small or too huge
    pinBoxSize = pinBoxSize.clamp(50, 70).toDouble();

    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (ctx) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                "Enter PIN to change status",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              content: SizedBox(
                width: screenWidth * 0.3, // Dialog width = 30% of screen
                height: screenHeight * 0.12, // Enough height for Pinput
                child: ValueListenableBuilder<bool>(
                  valueListenable: errorNotifier,
                  builder: (context, hasError, _) {
                    return Pinput(
                      controller: pinController,
                      focusNode: pinFocusNode, // 🔹 attach focus node
                      length: 4,
                      showCursor: true,
                      autofocus: true,
                      obscureText: true,
                      keyboardType: TextInputType.number,
                      onChanged: (val) => enteredPin = val,
                      defaultPinTheme: PinTheme(
                        width: pinBoxSize,
                        height: pinBoxSize,
                        textStyle: TextStyle(
                          fontSize: pinBoxSize * 0.5,
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blue, width: 2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      errorPinTheme: PinTheme(
                        width: pinBoxSize,
                        height: pinBoxSize,
                        textStyle: TextStyle(
                          fontSize: pinBoxSize * 0.5,
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          border: Border.all(color: Colors.red, width: 2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      forceErrorState: hasError,
                    );
                  },
                ),
              ),
              actionsAlignment: MainAxisAlignment.spaceEvenly,
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (enteredPin == savedPin) {
                      Navigator.pop(ctx, true);
                    } else {
                      errorNotifier.value = true;
                      pinController.clear();
                      pinFocusNode.requestFocus(); // 🔹 refocus first box
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Incorrect PIN")),
                      );
                    }
                  },
                  child: const Text("Confirm"),
                ),
              ],
            );
          },
        ) ??
        false;
  }
}
