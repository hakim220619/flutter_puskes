import 'package:flutter/material.dart';

class BlogDetailPage extends StatelessWidget {
  final Map<String, dynamic> blogItem;

  // Constructor to accept blogItem data
  BlogDetailPage({required this.blogItem});

  @override
  Widget build(BuildContext context) {
    // Create a TextEditingController for the comment input
    TextEditingController commentController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text(blogItem['title']),
      ),
      body: SingleChildScrollView( // Make the page scrollable
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display blog image
              Image.network(
                blogItem['imageUrl'].toString(),
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
              SizedBox(height: 16),

              // Blog title
              Text(
                blogItem['title'],
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  // Ensure the title text scales well on smaller screens
                ),
              ),
              SizedBox(height: 8),

              // Blog description
              Text(
                blogItem['description'],
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  // Use flexible text styling
                ),
              ),
              SizedBox(height: 16),

              // Blog date
              Text(
                'Published on: ${blogItem['date']}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 16),

              // Input field for comment
              // TextField(
              //   controller: commentController,
              //   decoration: InputDecoration(
              //     labelText: 'Add a comment...',
              //     border: OutlineInputBorder(),
              //     contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              //   ),
              //   maxLines: 3,
              //   keyboardType: TextInputType.text,
              // ),
              // SizedBox(height: 16),

              // Submit button for the comment
              // ElevatedButton(
              //   onPressed: () {
              //     // Handle comment submission
              //     final comment = commentController.text;
              //     if (comment.isNotEmpty) {
              //       // Here you could store the comment or show a confirmation message
              //       showDialog(
              //         context: context,
              //         builder: (_) => AlertDialog(
              //           title: Text('Comment Submitted'),
              //           content: Text('Your comment: "$comment" has been added.'),
              //           actions: [
              //             TextButton(
              //               onPressed: () => Navigator.pop(context),
              //               child: Text('OK'),
              //             ),
              //           ],
              //         ),
              //       );
              //     }
              //   },
              //   child: Text('Submit Comment'),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
