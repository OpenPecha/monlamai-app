import 'package:flutter/material.dart';

class DOBPage extends StatelessWidget {
  final Map<String, dynamic> formData;
  final Function(Map<String, dynamic>) setFormData;

  const DOBPage({required this.formData, required this.setFormData, super.key});

  void handleInputChange(String? value) {
    if (value != null) {
      setFormData({...formData, 'dob': value});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Birthday?",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'No age limit here, just word limit!',
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            // constraints: BoxConstraints(maxWidth: 300),
            child: TextFormField(
              decoration: InputDecoration(
                hintText: 'Select your birthday',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: Theme.of(context).primaryColor,
                    width: 2,
                  ),
                ),
              ),
              // display modern date format
              controller: TextEditingController(text: formData['dob'] ?? ''),
              onTap: () async {
                FocusScope.of(context).requestFocus(FocusNode());
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: formData['dob'].isNotEmpty
                      ? DateTime.parse(formData['dob'])
                      : DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  final formattedDate = picked.toIso8601String().split('T')[0];
                  handleInputChange(formattedDate);
                }
              },
              readOnly: true,
            ),
          ),
        ],
      ),
    );
  }
}
