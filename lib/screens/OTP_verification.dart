import 'package:flutter/material.dart';

class OTPVerificationPage extends StatefulWidget {
  final String email;

  const OTPVerificationPage({Key? key, required this.email}) : super(key: key);

  @override
  _OTPVerificationPageState createState() => _OTPVerificationPageState();
}

class _OTPVerificationPageState extends State<OTPVerificationPage> {
  TextEditingController _otpController = TextEditingController();

  void _verifyOTP() {
    // Perform OTP verification (in real app, this should call a backend API)
    String enteredOTP = _otpController.text;
    // For demo purposes, validate the OTP here (hardcoded for simplicity)
    String expectedOTP = '123456'; // Replace with actual OTP sent to user

    if (enteredOTP == expectedOTP) {
      // OTP verification successful
      Navigator.pushReplacementNamed(context, '/signin'); // Navigate to sign-in page
    } else {
      // OTP verification failed
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('OTP Verification Failed'),
          content: Text('Invalid OTP. Please try again.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Verify OTP'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'OTP has been sent to ${widget.email}',
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Enter OTP',
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _verifyOTP,
                child: Text('Verify OTP'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
