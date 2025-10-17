import 'dart:io';
import 'package:feedyou/service/auth.dart';
import 'package:feedyou/service/shared_pref.dart';
import 'package:feedyou/pages/LogIn.dart'; 
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:random_string/random_string.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String? name, profile, email;
  final ImagePicker _picker = ImagePicker();
  File? selectedImage;
  bool _isPickingImage = false; // prevents multiple taps
  bool _isUploading = false; // shows progress while uploading

  @override
  void initState() {
    super.initState();
    onTheLoad();
  }

  // Load user data from SharedPreferences
  Future<void> getTheSharedPref() async {
    name = await SharedPreferenceHelper().getUserName();
    email = await SharedPreferenceHelper().getUserEmail();
    profile = await SharedPreferenceHelper().getUserProfile();
    setState(() {});
  }

  void onTheLoad() {
    getTheSharedPref();
  }

  // ✅ Pick image from gallery safely
  Future<void> getImage() async {
    if (_isPickingImage) return; // avoid int taps
    _isPickingImage = true;

    try {
      final image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          selectedImage = File(image.path);
        });
        await uploadItem(); // auto-upload after selecting
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    } finally {
      _isPickingImage = false;
    }
  }

  // ✅ Upload image to Firebase Storage and save URL
  Future<void> uploadItem() async {
    if (selectedImage == null) return;

    setState(() => _isUploading = true);

    try {
      String addId = randomAlphaNumeric(10);
      Reference firebaseStorageRef =
          FirebaseStorage.instance.ref().child("userProfiles").child(addId);
      UploadTask uploadTask = firebaseStorageRef.putFile(selectedImage!);
      var downloadUrl = await (await uploadTask).ref.getDownloadURL();

      await SharedPreferenceHelper().saveUserProfile(downloadUrl);
      setState(() {
        profile = downloadUrl;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile picture updated successfully!')),
      );
    } catch (e) {
      debugPrint("Upload error: $e");
    } finally {
      setState(() => _isUploading = false);
    }
  }

  // ✅ Confirm before deleting account
  Future<void> _confirmDelete() async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Account"),
        content: const Text("Are you sure you want to delete your account?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await AuthMethods().deleteUser();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: name == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.only(
                                top: 45, left: 20, right: 20),
                            height: MediaQuery.of(context).size.height / 4.3,
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.vertical(
                                bottom: Radius.elliptical(
                                    MediaQuery.of(context).size.width, 105),
                              ),
                            ),
                          ),
                          Center(
                            child: Container(
                              margin: EdgeInsets.only(
                                top: MediaQuery.of(context).size.height / 6.5,
                              ),
                              child: Material(
                                elevation: 10,
                                borderRadius: BorderRadius.circular(60),
                                child: GestureDetector(
                                  onTap: getImage,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(60),
                                    child: selectedImage == null
                                        ? (profile != null &&
                                                profile!.isNotEmpty
                                            ? Image.network(
                                                profile!,
                                                height: 120,
                                                width: 120,
                                                fit: BoxFit.cover,
                                              )
                                            : Image.asset(
                                                "assets/images/profilePic.png",
                                                height: 120,
                                                width: 120,
                                                fit: BoxFit.cover,
                                              ))
                                        : Image.file(
                                            selectedImage!,
                                            height: 120,
                                            width: 120,
                                            fit: BoxFit.cover,
                                          ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 70,
                            left: 20,
                            child: Text(
                              name ?? "User Name",
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 25,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Poppins'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),

                      // Name container
                      _buildInfoTile(
                          Icons.person, "Name", name ?? "Unknown User"),

                      const SizedBox(height: 20),

                      // Email container
                      _buildInfoTile(Icons.email, "Email", email ?? "No email"),

                      const SizedBox(height: 20),

                      // Delete Account container
                      _buildActionTile(Icons.delete, "Delete Account"),

                      const SizedBox(height: 20),

                      // Logout container
                      _buildActionTile(Icons.logout, "Logout"),
                    ],
                  ),
                ),

                // Show loading indicator while uploading image
                if (_isUploading)
                  Container(
                    color: Colors.black54,
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.black),
              const SizedBox(width: 20, height: 40),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: Colors.black, fontWeight: FontWeight.w600)),
                  Text(value,
                      style: const TextStyle(
                          color: Colors.black, fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionTile(IconData icon, String title) {
    return GestureDetector(
      onTap: () async {
        if (title.toLowerCase() == "logout") {
          await AuthMethods().SignOut();
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LogIn()),
            );
          }
        }

        if (title.toLowerCase() == "delete account") {
          await _confirmDelete();
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LogIn()),
            );
          }
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        child: Material(
          elevation: 2,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding:
                const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.black),
                const SizedBox(width: 20, height: 40),
                Text(title,
                    style: const TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
