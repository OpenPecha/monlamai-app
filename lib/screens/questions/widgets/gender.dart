import 'package:flutter/material.dart';

class GenderPage extends StatelessWidget {
  final Map<String, dynamic> formData;
  final Function(Map<String, dynamic>) setFormData;

  const GenderPage(
      {required this.formData, required this.setFormData, super.key});

  void handleInputChange(String value) {
    setFormData({...formData, 'gender': value});
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Gender ?",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: Column(
              children: [
                _buildRadioOption(context, 'Male'),
                _buildRadioOption(context, 'Female'),
                _buildRadioOption(context, 'Other'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadioOption(BuildContext context, String value) {
    return InkWell(
      onTap: () => handleInputChange(value),
      child: Row(
        children: [
          Radio<String>(
            value: value,
            groupValue: formData['gender'],
            onChanged: (String? newValue) {
              if (newValue != null) {
                handleInputChange(newValue);
              }
            },
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
        ],
      ),
    );
  }
}
