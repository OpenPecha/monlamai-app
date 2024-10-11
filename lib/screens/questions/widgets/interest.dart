import 'package:flutter/material.dart';
// import 'package:flutter_i18n/flutter_i18n.dart';

class InterestPage extends StatefulWidget {
  final Map<String, dynamic> formData;
  final Function(Map<String, dynamic>) setFormData;

  const InterestPage(
      {required this.formData, required this.setFormData, super.key});

  @override
  State<InterestPage> createState() => _InterestPageState();
}

class _InterestPageState extends State<InterestPage> {
  String searchTerm = "";
  final int maxSelections = 5;

  late List<String> interestsData;

  // when localization is added, uncomment the following lines
  @override
  void initState() {
    super.initState();
    // String currentLanguage = FlutterI18n.currentLocale(context)!.languageCode;
    // interestsData =
    //     currentLanguage == "en" ? Interests_English : Interests_Tibetan;
    interestsData = interestsEnglish;
  }

  void handleAreaOfInterestChange(String interest) {
    if (widget.formData['areaOfInterest'].length == maxSelections &&
        !widget.formData['areaOfInterest'].contains(interest)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('You can only select up to $maxSelections interests')),
      );
      return;
    }

    List<String> newInterests = List.from(widget.formData['areaOfInterest']);
    if (newInterests.contains(interest)) {
      newInterests.remove(interest);
    } else {
      newInterests.add(interest);
    }

    widget.setFormData({...widget.formData, 'areaOfInterest': newInterests});
  }

  void handleSearch(String value) {
    setState(() {
      searchTerm = value.toLowerCase();
    });
  }

  List<String> get filteredInterests {
    return interestsData
        .where((interest) => interest.toLowerCase().contains(searchTerm))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Interests?",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              Text(
                '${widget.formData['areaOfInterest'].length} of $maxSelections',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
          SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: (widget.formData['areaOfInterest'] as List<dynamic>)
                .map((interest) {
              return Chip(
                label: Text(interest),
                deleteIcon: Icon(Icons.close),
                onDeleted: () => handleAreaOfInterestChange(interest),
                backgroundColor: Colors.blue.shade100,
                labelStyle: TextStyle(color: Colors.blue.shade700),
              );
            }).toList(),
          ),
          SizedBox(height: 16),
          TextField(
            onChanged: handleSearch,
            decoration: InputDecoration(
              hintText: 'Search',
              prefixIcon: Icon(Icons.search),
              suffixIcon: searchTerm.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          searchTerm = '';
                        });
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: filteredInterests
                    .where((interest) =>
                        !(widget.formData['areaOfInterest'] as List<dynamic>)
                            .contains(interest))
                    .map((interest) {
                  return OutlinedButton(
                    onPressed: widget.formData['areaOfInterest'].length ==
                            maxSelections
                        ? null
                        : () => handleAreaOfInterestChange(interest),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                    ),
                    child: Text(interest,
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.secondary,
                        )),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Add these lists to your file (you may want to move them to a separate file in a real app)
const List<String> interestsEnglish = [
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

const List<String> interestsTibetan = [
  "སྒྱུ་རྩལ་དང་རིག་གཞུང་།",
  "བོད་ཀྱི་རིག་གཞུང་དང་སྤྱི་ཚོགས།",
  "རྩོམ་རིག་དང་རྩོམ་འབྲི།",
  "ས་ཁམས་ཆབ་སྲིད་དང་རྒྱལ་སྤྱིའི་རྩོད་རྙོག།",
  "ཚན་རིག་དང་འཕྲུལ་རིག",
  "འཕྲོད་བསྟེན་དང་བདེ་ཐང་།",
  "དགའ་ཕྱོགས་དང་འཚོ་བའི་གོམས་གཤིས།",
  "རྩེད་རིགས་དང་སྤྲོ་སྐྱིད།",
  "ཤེས་ཡོན།",
  "ཚོང་ལས་དང་དཔལ་འབྱོར།",
  "སྤྱི་ཚོགས་ཤུགས་རྐྱེན་དང་། སྤྱི་ཚོགས་འཕེལ་རྒྱས།",
  "ཁོར་ཡུག་དང་རྒྱུན་འཁྱོངས།",
  "འགྲུལ་བཞུད་དང་གདོང་ལེན།",
  "གསར་གཏོད་དང་ལེགས་བཅོས།",
  "ཆབ་སྲིད་དང་ཚོགས་སྡེ།",
  "འཕྲུལ་རིག་དང་དྲ་རྒྱའི་བརྒྱུད་ལམ།",
  "ཆོས་ལུགས་དང་ལྟ་གྲུབ།"
];
