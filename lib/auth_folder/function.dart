// ignore: depend_on_referenced_packages
import 'package:firebase_auth/firebase_auth.dart';

final _auth = FirebaseAuth.instance;
void authWithPhoneNumber(
  String phone, {
  required Function(String value, int? value1) onCodeSend,
  required Function(PhoneAuthCredential value) onAutoVerify,
  required Function(FirebaseAuthException value) onFailed,
  required Function(String value) autoRetrieval,
}) async {
  _auth.verifyPhoneNumber(
    phoneNumber: phone,
    timeout: const Duration(seconds: 10),
    verificationCompleted: onAutoVerify,
    verificationFailed: onFailed,
    codeSent: onCodeSend,
    codeAutoRetrievalTimeout: autoRetrieval,
  );
}

Future<void> validateOtp(String smsCode, String verificationId) async {
  final credential = PhoneAuthProvider.credential(
      verificationId: verificationId, smsCode: smsCode);
  _auth.signInWithCredential(credential);

  return;
}

Future<void> logOut() async {
  await _auth.signOut();
  return;
}