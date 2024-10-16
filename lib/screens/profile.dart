import 'package:flutter/material.dart';
import 'package:monlamai_app/models/user.dart';
import 'package:monlamai_app/services/user_service.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class UserProfileForm extends StatefulWidget {
  final User user;

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
  final UserService _userService = UserService();

  final List<String> _requiredFields = [
    'name',
    'gender',
    'interest',
    'profession',
    'birth_date',
    'city',
    'country'
  ];

  final List<String> _areaOfInterestOptions = [
    "Arts & Culture",
    "Tibetan Culture & Society",
    "Literature & Writing",
    "Geopolitics & International Conflict",
    "Science & Technology",
    "Health & Wellness",
    "Hobbies and Lifestyle",
    "Sports & Entertainment",
    "Education",
    "Business & Economics",
    "Social Impact & Community Development",
    "Environmental & Sustainability",
    "Travel & Adventure",
    "Creativity & Innovation",
    "Politics & Society",
    "Technology & Digital Media",
    "Spirituality & Philosophy"
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
    _nameController = TextEditingController(text: widget.user.name);
    _cityController = TextEditingController(text: widget.user.city);
    _countryController = TextEditingController(text: widget.user.country);
    _dateOfBirth = widget.user.birthdate != null
        ? DateTime.parse(widget.user.birthdate!)
        : DateTime.now();
    _gender = widget.user.gender;
    _areaOfInterest = (widget.user.areaOfInterest)
            ?.split(',')
            .map((e) => e.replaceAll(RegExp(r'\\?"'), ''))
            .toList() ??
        [];
    _profession = widget.user.profession ?? "";
    _completedValue = _calculateCompletionPercentage();
  }

  dynamic _getUserFieldValue(String field) {
    switch (field) {
      case 'name':
        return widget.user.name;
      case 'gender':
        return widget.user.gender;
      case 'profession':
        return widget.user.profession;
      case 'birth_date':
        return widget.user.birthdate;
      case 'city':
        return widget.user.city;
      case 'country':
        return widget.user.country;
      case 'interest':
        return widget.user.areaOfInterest;
      default:
        return null;
    }
  }

  int _calculateCompletionPercentage() {
    int filledFields = 0;

    for (String field in _requiredFields) {
      if (_getUserFieldValue(field) != null) {
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
        title: Text('Profile'),
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
            _buildInputField(
              'Name',
              _nameController,
              (value) {
                setState(() {
                  _nameController.text = value;
                });
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
              value: _professions.contains(_profession) ? _profession : null,
              hint: Text('Select your profession'),
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
                setState(() {
                  _cityController.text = value;
                });
              },
              AutofillHints.addressCity,
            ),
            SizedBox(height: 16),
            _buildInputField(
              'Country',
              _countryController,
              (value) {
                setState(() {
                  _countryController.text = value;
                });
              },
              AutofillHints.countryName,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text('Proceed'),
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

  _submitForm() async {
    if (_nameController.text == widget.user.name &&
            _cityController.text.isEmpty ||
        _cityController.text == widget.user.city &&
            _countryController.text.isEmpty ||
        _countryController.text == widget.user.country &&
            _dateOfBirth.toIso8601String().split('T').first ==
                widget.user.birthdate &&
            _gender == widget.user.gender &&
            _areaOfInterest.join(',') == widget.user.areaOfInterest &&
            _profession == widget.user.profession) {
      return null;
    } else {
      // send api request to update user profile
      var response = await _userService.saveUserData({
        'name': _nameController.text,
        'gender': _gender,
        'city': _cityController.text,
        'country': _countryController.text,
        'dob': _dateOfBirth.toIso8601String().split('T').first,
        'areaOfInterest': _areaOfInterest,
        'profession': _profession
      });
      if (response['error'] != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['error']),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['success']),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }
}
