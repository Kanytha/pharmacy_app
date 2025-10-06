import 'package:flutter/material.dart';

class TeamScreen extends StatelessWidget {
  const TeamScreen({super.key});

  final List<Map<String, String>> teamMembers = const [
    {
      "name": "San Kanytha",
      "role": "Pharmacy Manager",
      "email": "kanytha@pharmacy.com",
      "description":
      "Oversees the overall operations of the pharmacy, ensures compliance with medical standards, manages inventory, and maintains strong customer relationships."
    },
    {
      "name": "Hout Chanmonyroth",
      "role": "Pharmaceutical Sales & Inventory Officer",
      "email": "chanmonyroth@pharmacy.com",
      "description":
      "Handles product listing, restocking, and sales records. Ensures that all medicines are up-to-date, properly stored, and easily accessible to customers."
    },
    {
      "name": "Mol Chhenghong",
      "role": "Customer Care & Health Consultant",
      "email": "chhenghong@pharmacy.com",
      "description":
      "Provides customer support and medicine guidance, ensuring patients receive the right advice and service for their health and safety."
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Our Pharmacy Team",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: teamMembers.length,
        itemBuilder: (context, index) {
          final member = teamMembers[index];
          return Card(
            elevation: 3,
            margin: const EdgeInsets.symmetric(vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member["name"]!,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    member["role"]!,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    member["description"]!,
                    style: const TextStyle(fontSize: 15, height: 1.4),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.email, color: Colors.grey, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        member["email"]!,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
