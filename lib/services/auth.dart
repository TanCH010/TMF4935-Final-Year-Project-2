import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService{
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // sign in with email and password
  Future signInWithEmailAndPassword(String email, String password) async{
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      User? user = result.user;

      if (user != null) {
        // generate FCM token
        String? fcmToken = await FirebaseMessaging.instance.getToken();

        if (fcmToken != null) {
          // store the fcm token in Firestore under the AdminTokens collection
          await _firestore.collection('AdminTokens').doc(user.uid).set({
            'token': fcmToken,
            'email': user.email,
            'createdAt': FieldValue.serverTimestamp()
          });
        }
      }
    
      return user;
    } catch (e){
      print(e.toString());
      return null;
    }
  }

  // sign out
  Future signOut() async{
    try{
      User? user = _auth.currentUser;

      if (user != null) {
        // delete the FCM token from Firestore
        await _firestore.collection('AdminTokens').doc(user.uid).delete();
      }

      return await _auth.signOut();
    } catch(e) {
      print(e.toString());
      return null;
    }

  }
}