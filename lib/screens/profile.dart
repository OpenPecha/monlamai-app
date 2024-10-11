import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class UserProfileForm extends StatefulWidget {
  final Map<String, dynamic> user;

  const UserProfileForm({required this.user, super.key});

  @override
  State<UserProfileForm> createState() => _UserProfileFormState();
}

class _UserProfileFormState extends State<UserProfileForm> {
  late TextEditingController _nameController;
  late TextEditingController _cityController;
  late TextEditingController _countryController;
  late DateTime _dateOfBirth;
  String? _gender;
  List<String> _areaOfInterest = [];
  String? _profession;
  int _completedValue = 0;

  final List<String> _requiredFields = [
    'gender',
    'interest',
    'profession',
    'birth_date',
    'city',
    'country'
  ];

  final List<String> _areaOfInterestOptions = [
    "Art & Craft",
    "Culture",
    "Buddhism & Philosophy",
    "Community Development",
    "Cuisine",
    "Education & Knowledge Systems",
    "History & Heritage",
  ];

  final List<String> _professions = [
    "Business & Administration",
    "Creative & Media",
    "Customer Service",
    "Educator",
    "Engineering",
    "Entrepreneur",
    "Executive & Senior Management",
    "Finance & Accounting",
    "Healthcare",
    "Human Resources",
    "Legal & Public Policy",
    "Miscellaneous",
    "Monk",
    "Non-Profit & Social Services",
    "Operations & Logistics",
    "Sales & Marketing",
    "Student",
    "Technology & IT",
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user['username']);
    _cityController = TextEditingController(text: widget.user['city']);
    _countryController = TextEditingController(text: widget.user['country']);
    _dateOfBirth = widget.user['birth_date'].isNotEmpty
        ? DateTime.parse(widget.user['birth_date'])
        : DateTime.now();
    _gender = widget.user['gender'];
    _areaOfInterest = (widget.user['interest'] as String?)
            ?.split(',')
            .map((e) => e.replaceAll(RegExp(r'\\?"'), ''))
            .toList() ??
        [];
    _profession = widget.user['profession'];
    _completedValue = _calculateCompletionPercentage();
  }

  int _calculateCompletionPercentage() {
    int filledFields = 0;

    for (String field in _requiredFields) {
      if (widget.user[field] != null &&
          widget.user[field].toString().isNotEmpty) {
        filledFields++;
      }
    }

    return ((filledFields / _requiredFields.length) * 100).floor();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('User Profile'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircularPercentIndicator(
                radius: 60.0,
                lineWidth: 5.0,
                percent: _completedValue / 100,
                center: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/monlam-logo.png',
                      width: 40,
                      height: 40,
                    ),
                    SizedBox(height: 4),
                    Text(
                      '$_completedValue% complete',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                progressColor: Colors.green,
              ),
            ),
            SizedBox(height: 24),
            // display all the user data
            Text("User Data ${widget.user.toString()}"),
            _buildInputField(
              'Name',
              _nameController,
              (value) {
                // setState(() {
                //   widget.user['username'] = value;
                // });
              },
              AutofillHints.name,
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _gender,
              onChanged: (value) {
                setState(() {
                  _gender = value;
                });
              },
              items: ['Male', 'Female', 'Other']
                  .map((label) => DropdownMenuItem(
                        value: label,
                        child: Text(label),
                      ))
                  .toList(),
              decoration: InputDecoration(
                hintText: 'Select your Gender',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            SizedBox(height: 16),
            Text('Area of Interest',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                )),
            Wrap(
              spacing: 8.0,
              children: _areaOfInterestOptions.map((interest) {
                return FilterChip(
                  label: Text(
                    interest,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  selected: _areaOfInterest.contains(interest),
                  selectedColor: Colors.green.shade100,
                  onSelected: (bool selected) {
                    setState(() {
                      if (selected) {
                        _areaOfInterest.add(interest);
                      } else {
                        _areaOfInterest.remove(interest);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            SizedBox(height: 16),
            Text(
              "What do you do?",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            DropdownButtonFormField<String>(
              value: _profession,
              onChanged: (value) {
                setState(() {
                  _profession = value;
                });
              },
              items: _professions
                  .map((profession) => DropdownMenuItem(
                        value: profession,
                        child: Text(profession),
                      ))
                  .toList(),
              decoration: InputDecoration(
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
            ),
            SizedBox(height: 16),
            Text(
              "Birthday?",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            SizedBox(height: 8),
            InkWell(
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: _dateOfBirth,
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );
                if (picked != null && picked != _dateOfBirth) {
                  setState(() {
                    _dateOfBirth = picked;
                  });
                }
              },
              child: InputDecorator(
                decoration: InputDecoration(
                  hintText: 'Select your birthday',
                  suffixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  _dateOfBirth.toIso8601String().split('T').first,
                ),
              ),
            ),
            SizedBox(height: 16),
            _buildInputField(
              'City',
              _cityController,
              (value) {
                // setState(() {
                //   widget.user['city'] = value;
                // });
              },
              AutofillHints.addressCity,
            ),
            SizedBox(height: 16),
            _buildInputField(
              'Country',
              _countryController,
              (value) {
                // setState(() {
                //   widget.user['country'] = value;
                // });
              },
              AutofillHints.countryName,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submitForm,
              child: Text('Submit'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller,
      Function(String) onChanged, String autofillHint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          autofillHints: [autofillHint],
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: 'Enter your $label',
            helperStyle: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  void _submitForm() {
    // TODO: Implement form submission logic
    print('Form submitted with data:');
    // You would typically send this data to your backend or state management solution
  }
}
