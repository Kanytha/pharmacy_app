import 'package:flutter/material.dart';

class DeveloperPage extends StatelessWidget {
  const DeveloperPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text("Meet Our Team"),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          SizedBox(height: 20),
          // Text(
          //   "Meet Our Team",
          //   style: TextStyle(
          //     fontSize: 26,
          //     fontWeight: FontWeight.bold,
          //     color: Colors.teal,
          //   ),
          //   textAlign: TextAlign.center,
          // ),
          // SizedBox(height: 30),

          // Pharmacy Team
          TeamCard(
            name: "San Kanytha",
            role: "Pharmacy Manager",
            passion:
            "I oversee the entire pharmacy operation — ensuring every medicine is authentic, every customer is cared for, and every service meets our health standards.",
            isLocalImage: true,
            imageUrl: "assets/images/myLove.png",
          ),
          SizedBox(height: 20),
          TeamCard(
            name: "Hout Chanmonyroth",
            role: "Pharmaceutical Sales & Inventory Officer",
            passion:
            "I handle our medicine stock and product availability — making sure every prescription and over-the-counter item is always ready for our customers.",
            isLocalImage: true,
            imageUrl: "lib/images/ni-ki wallpaper.jpg",
          ),
          SizedBox(height: 20),
          TeamCard(
            name: "Mol Chhenghong",
            role: "Customer Care & Health Consultant",
            passion:
            "I guide our customers toward the right treatments and provide friendly, trusted advice for their health and wellbeing.",
            isLocalImage: true,
            imageUrl: "lib/images/ni-ki wallpaper.jpg",
          ),

        ],
      ),
    );
  }
}

class TeamCard extends StatelessWidget {
  final String name;
  final String role;
  final String imageUrl;
  final String passion;
  final bool isLocalImage;

  const TeamCard({
    super.key,
    required this.name,
    required this.role,
    required this.imageUrl,
    required this.passion,
    this.isLocalImage = false,
  });


  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.teal,
              backgroundImage: isLocalImage
                  ? AssetImage(imageUrl) as ImageProvider
                  : NetworkImage(imageUrl),
              onBackgroundImageError: (exception, stackTrace) {
                // If image fails, it will show the child (initials)
                print('Image failed to load: $imageUrl');
              },
              child: Text(
                _getInitials(name),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              role,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              passion,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.facebook, color: Color(0xFF1877F2), size: 28),
                SizedBox(width: 16),
                Icon(Icons.mail, color: Color(0xFF1DA1F2), size: 28),
                SizedBox(width: 16),
                Icon(Icons.work, color: Color(0xFF0A66C2), size: 28),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getInitials(String name) {
    List<String> names = name.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }
}