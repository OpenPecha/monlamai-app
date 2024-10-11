import 'package:flutter/material.dart';
// import 'package:flutter_i18n/flutter_i18n.dart';

class ProfessionPage extends StatelessWidget {
  final Map<String, dynamic> formData;
  final Function(Map<String, dynamic>) setFormData;

  const ProfessionPage(
      {required this.formData, required this.setFormData, super.key});

  void handleInputChange(String? value) {
    if (value != null) {
      setFormData({...formData, 'profession': value});
    }
  }

  @override
  Widget build(BuildContext context) {
    // when localization is added, uncomment the following lines
    // final String currentLanguage = FlutterI18n.currentLocale(context)!.languageCode;
    // final List<String> professionOptions = currentLanguage == 'en'
    //     ? Professions_English
    //     : Professions_Tibetan;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "What do you do?",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            // constraints: BoxConstraints(maxWidth: 300),
            child: DropdownButtonFormField<String>(
              value: formData['profession'] ?? '',
              onChanged: handleInputChange,
              items: [
                DropdownMenuItem<String>(
                  value: '',
                  child: Text('Regular Select'),
                ),
                ...Professions_English.map(
                  (String option) {
                    return DropdownMenuItem<String>(
                      value: option,
                      child: Text(option),
                    );
                  },
                ),
              ],
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
          ),
        ],
      ),
    );
  }
}

// Add these lists to your file (you may want to move them to a separate file in a real app)
const List<String> Professions_English = [
  "Monastic Institution",
  "Central Tibetan Administration(CTA)",
  "Tibetan NGOs",
  "Men Tse Khang",
  "Tibetan Centred School",
  "Norbulingka Institute",
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
  "Non-Profit & Social Services",
  "Operations & Logistics",
  "Sales & Marketing",
  "Student",
  "Technology & IT",
  "Miscellaneous",
];

const List<String> Professions_Tibetan = [
  "དགོན་སྡེ་ཁག",
  "དབུས་བོད་མིའི་སྒྲིག་འཛུགས།",
  "བོད་མིའི་གཞུང་འབྲེལ་མ་ཡིན་པའི་ཚོགས་པ་ཁག",
  "སྨན་རྩིས་ཁང་།",
  "བོད་ཀྱི་སློབ་གྲྭ་ཁག",
  "ནོར་གླིང་རིག་གཞུང་གཅེས་སྐྱོང་ཁང་།",
  "ཚོང་ལས་དང་འཛིན་སྐྱོང་།",
  "གསར་གཏོད་དང་བརྒྱུད་ལམ།",
  "བཀོལ་སྤྱོད་ཞབས་ཞུ།",
  "སྒྱུར་བསྟེན།",
  "འཆར་འགོད་ལས་རིགས།",
  "གསར་གཏོད་མཁན།",
  "འགན་འཛིན་དང་སྤྱི་ཁྱབ་འཛིན་སྐྱོང་བ།",
  "དཔལ་འབྱོར་དང་རྩིས་ཁྲ།",
  "འཕྲོད་བསྟེན།",
  "ལས་མི་དོ་དམ།",
  "ཁྲིམས་ལུགས་དང་སྤྱི་ཚོགས་སྲིད་བྱུས།",
  "ཁེ་ལས་མིན་པའི་ཚོགས་པ་དང་སྤྱི་ཚོགས་ཞབས་ཞུ།",
  "ལག་བསྟར་དང་བདག་སྐྱོང་།",
  "ཁེ་ཚོང་དང་ཚོང་འགྲེམས།",
  "སྒྱུར་ཕྲུག",
  "འཕྲུལ་རིག་དང་བརྡ་འཕྲིན།",
  "གཞན་དག"
];
