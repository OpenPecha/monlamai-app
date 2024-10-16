import 'package:flutter/material.dart';
import 'package:monlamai_app/screens/home.dart';
import 'package:monlamai_app/screens/questions/widgets/dob.dart';
import 'package:monlamai_app/screens/questions/widgets/gender.dart';
import 'package:monlamai_app/screens/questions/widgets/interest.dart';
import 'package:monlamai_app/screens/questions/widgets/location.dart';
import 'package:monlamai_app/screens/questions/widgets/profession.dart';
import 'package:monlamai_app/services/user_service.dart';
import 'package:monlamai_app/services/user_session.dart';

class QuestionnaireSteps extends StatefulWidget {
  const QuestionnaireSteps({super.key});
  @override
  State<QuestionnaireSteps> createState() => _QuestionnaireStepsState();
}

class _QuestionnaireStepsState extends State<QuestionnaireSteps> {
  int step = 1;
  double progress = 0;
  final int maxSteps = 5;
  UserService userService = UserService();
  UserSession userSession = UserSession();

  Map<String, dynamic> formData = {
    'name': '',
    'dob': '',
    'gender': '',
    'areaOfInterest': [],
    'profession': '',
    'city': '',
    'country': '',
  };

  @override
  void initState() {
    super.initState();
    updateProgress();
  }

  void updateProgress() {
    setState(() {
      progress = (step / maxSteps) * 100;
    });
  }

  void handleBack() {
    if (step > 1) {
      setState(() {
        step--;
        updateProgress();
      });
    }
  }

  void handleNext() {
    if (step < maxSteps) {
      setState(() {
        step++;
        updateProgress();
      });
    } else {
      handleSubmit();
    }
  }

  void handleSubmit() async {
    // save form data to database
    final result = await userService.saveUserData(formData);
    if (result['success'] != null) {
      // navigate to home screen
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => HomeScreen(),
        ),
      );
    } else {
      debugPrint('Error saving user data: ${result['error']}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable saving user data. Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: step > 1
            ? IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: handleBack,
              )
            : null,
        actions: [
          if (step > 2)
            TextButton(
              onPressed: handleNext,
              child: Text(
                'Skip',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontSize: 14,
                ),
              ),
            ),
        ],
      ),
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          LinearProgressIndicator(
            value: progress / 100,
            color: Colors.blue[600],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
          ),
          const SizedBox(height: 60),
          Expanded(child: buildCurrentStep()),
          Padding(
            padding: const EdgeInsets.only(
              bottom: 80.0,
              left: 24.0,
              right: 24.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: handleNext,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: 80,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(
                        color: Colors.grey.shade300,
                      ),
                    ),
                  ),
                  child: Text(step == maxSteps ? 'Submit' : 'Next',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontSize: 16,
                      )),
                ),
                if (step == 3)
                  TextButton(
                    onPressed: () async {
                      await userSession.setSkipQuestion(true);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => HomeScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'Will fill up later',
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: Theme.of(context).colorScheme.secondary,
                        fontSize: 16,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCurrentStep() {
    switch (step) {
      case 1:
        return GenderPage(
          formData: formData,
          setFormData: (newFormData) => setState(() => formData = newFormData),
        );
      case 2:
        return DOBPage(
          formData: formData,
          setFormData: (newFormData) => setState(() => formData = newFormData),
        );
      case 3:
        return ProfessionPage(
          formData: formData,
          setFormData: (newFormData) => setState(() => formData = newFormData),
        );
      case 4:
        return LocationPage(
          formData: formData,
          setFormData: (newFormData) => setState(() => formData = newFormData),
        );
      case 5:
        return InterestPage(
          formData: formData,
          setFormData: (newFormData) => setState(() => formData = newFormData),
        );
      default:
        return Container();
    }
  }
}
