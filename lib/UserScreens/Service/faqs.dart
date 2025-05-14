import 'package:flutter/material.dart';

class FaqsScreen extends StatefulWidget {
  const FaqsScreen({super.key});

  @override
  State<FaqsScreen> createState() => _FaqsScreenState();
}

class _FaqsScreenState extends State<FaqsScreen> {
  final List<Map<String, String>> faqs = [
    {
      "question": "What is Watch Hub?",
      "answer": "Watch Hub helps you discover, compare, and buy the latest smartwatches and accessories."
    },
    {
      "question": "How do I place an order?",
      "answer": "Tap any product, add it to your cart, and proceed to checkout to complete your order."
    },
    {
      "question": "Can I track my order?",
      "answer": "Yes, order tracking is available in the 'My Orders' section with real-time updates."
    },
    {
      "question": "What payment options are available?",
      "answer": "We support credit/debit cards, UPI, Apple Pay, Google Pay, and digital wallets."
    },
    {
      "question": "Is there a return policy?",
      "answer": "Yes, unused items can be returned within 7 days of delivery in original packaging."
    },
    {
      "question": "Are products under warranty?",
      "answer": "All smartwatches come with a standard 1-year manufacturer warranty."
    },
    {
      "question": "Can I sync my smartwatch with the app?",
      "answer": "Absolutely! Connect via Bluetooth and control features from within Watch Hub."
    },
    {
      "question": "How can I update my address?",
      "answer": "Navigate to 'Account > Addresses' and make your changes easily."
    },
    {
      "question": "Do you offer international shipping?",
      "answer": "Currently, we ship in select countries. Global expansion is coming soon."
    },
    {
      "question": "How to contact customer support?",
      "answer": "Use in-app chat or email support@watchhub.com. We’re available 24/7."
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        title: const Text("FAQs"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: faqs.length,
        itemBuilder: (context, index) {
          final faq = faqs[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                title: Text(
                  faq['question']!,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Text(
                      faq['answer']!,
                      style: const TextStyle(fontSize: 14, color: Colors.black87),
                    ),
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
