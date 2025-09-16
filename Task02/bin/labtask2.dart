import 'dart:io';
import 'dart:convert';

class Student {
  String name;
  int age;
  String city;
  List<String> hobbies;
  Set<String> subjects;

  Student({
    required this.name,
    required this.age,
    required this.city,
    required this.hobbies,
    required this.subjects,
  });

  bool isEligible() => age >= 18;

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'age': age,
      'city': city,
      'hobbies': hobbies,
      'subjects': subjects.toList(),
      'eligible': isEligible(),
    };
  }

  @override
  String toString() {
    return '''
Name: $name
Age: $age
City: $city
Eligible: ${isEligible() ? "Yes" : "No"}
Hobbies: ${hobbies.join(", ")}
Subjects: ${subjects.join(", ")}
''';
  }
}

void main() {
  List<Student> students = [];

  while (true) {
    print('\n=== Student Management System ===');
    print('1. Add Student');
    print('2. Show Data');
    print('3. Exit');
    stdout.write('Choose an option: ');
    String? choice = stdin.readLineSync();

    switch (choice) {
      case '1':
        addStudent(students);
        break;
      case '2':
        showData(students);
        break;
      case '3':
        print('\nExiting program... Goodbye!');
        return;
      default:
        print('Invalid choice. Please try again.');
    }
  }
}

void addStudent(List<Student> students) {
  stdout.write('Enter name: ');
  String name = stdin.readLineSync() ?? '';

  int age;
  while (true) {
    try {
      stdout.write('Enter age: ');
      age = int.parse(stdin.readLineSync() ?? '');
      break;
    } catch (e) {
      print('Invalid input! Please enter a valid number for age.');
    }
  }

  stdout.write('Enter city: ');
  String city = stdin.readLineSync() ?? '';

  stdout.write('Enter hobbies (comma separated): ');
  List<String> hobbies = (stdin.readLineSync() ?? '')
      .split(',')
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();

  stdout.write('Enter subjects (comma separated): ');
  Set<String> subjects = (stdin.readLineSync() ?? '')
      .split(',')
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toSet();

  students.add(Student(
    name: name,
    age: age,
    city: city,
    hobbies: hobbies,
    subjects: subjects,
  ));

  print('\n Student added successfully!');
}

void showData(List<Student> students) {
  if (students.isEmpty) {
    print('\nNo students found.');
    return;
  }

  print('\n=== Student Data ===');
  for (var s in students) {
    print(s);
    print('-------------------------');
  }

  //  Export to JSON-like format just for display
  String jsonData = jsonEncode(students.map((s) => s.toMap()).toList());
  print('JSON Export:\n$jsonData');
}
