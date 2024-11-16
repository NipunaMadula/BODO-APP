import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.w900,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Clear all button
          TextButton(
            onPressed: () {
              // TODO: Implement clear all notifications
            },
            child: const Text(
              'Clear All',
              style: TextStyle(
                color: Colors.lightBlueAccent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildNotificationItem(
            title: 'New Boarding House Available',
            message: 'A new boarding house has been listed in Colombo area',
            time: '2 mins ago',
            icon: Icons.home_outlined,
            isNew: true,
          ),
          _buildNotificationItem(
            title: 'Booking Confirmation',
            message: 'Your booking request has been accepted by the owner',
            time: '1 hour ago',
            icon: Icons.check_circle_outline,
            isNew: true,
          ),
          _buildNotificationItem(
            title: 'Price Update',
            message: 'Price has been updated for a boarding house you saved',
            time: '3 hours ago',
            icon: Icons.monetization_on_outlined,
          ),
          _buildNotificationItem(
            title: 'New Message',
            message: 'You have received a message from property owner',
            time: '5 hours ago',
            icon: Icons.message_outlined,
          ),
          _buildNotificationItem(
            title: 'Booking Request',
            message: 'Someone requested to book your listed property',
            time: 'Yesterday',
            icon: Icons.bookmark_outline,
          ),
          _buildNotificationItem(
            title: 'New Review',
            message: 'Someone left a review on your property',
            time: '2 days ago',
            icon: Icons.star_outline,
          ),
          _buildNotificationItem(
            title: 'Payment Reminder',
            message: 'Your rent payment is due in 3 days',
            time: '2 days ago',
            icon: Icons.payment_outlined,
          ),
          _buildNotificationItem(
            title: 'Special Offer',
            message: 'Special discount available on selected properties',
            time: '3 days ago',
            icon: Icons.local_offer_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem({
    required String title,
    required String message,
    required String time,
    required IconData icon,
    bool isNew = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isNew ? Colors.blue.withOpacity(0.05) : Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.lightBlueAccent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Colors.lightBlueAccent,
            size: 24,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            if (isNew)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'NEW',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              message,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 12,
              ),
            ),
          ],
        ),
        onTap: () {
          // TODO: Handle notification tap
        },
      ),
    );
  }
}