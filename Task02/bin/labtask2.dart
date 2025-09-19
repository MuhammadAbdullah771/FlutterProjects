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
    print('3. Search Student By Name');
    print('4. Filter Hobbies & Subject');
    print('5. Exit');
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
        searchStudentByName(students);
        break;
      case '4':
        filterHobbiesAndSubjects(students);
        break;
      case '5':
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

  print('\nStudent added successfully!');
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

  // Export to JSON-like format just for display
  String jsonData = jsonEncode(students.map((s) => s.toMap()).toList());
  print('JSON Export:\n$jsonData');
}

void searchStudentByName(List<Student> students) {
  if (students.isEmpty) {
    print('\nNo students found to search.');
    return;
  }

  stdout.write('Enter name to search: ');
  String searchName = (stdin.readLineSync() ?? '').trim();

  if (searchName.isEmpty) {
    print('Search name cannot be empty.');
    return;
  }

  List<Student> matchedStudents = students
      .where((s) => s.name.toLowerCase() == searchName.toLowerCase())
      .toList();

  if (matchedStudents.isEmpty) {
    print('\nNo student found with name "$searchName".');
  } else {
    print('\n=== Search Results ===');
    for (var s in matchedStudents) {
      print(s);
      print('-------------------------');
    }
  }
}

void filterHobbiesAndSubjects(List<Student> students) {
  if (students.isEmpty) {
    print('\nNo students found to filter.');
    return;
  }

  stdout.write('Enter hobby or subject to filter: ');
  String filter = (stdin.readLineSync() ?? '').trim().toLowerCase();

  if (filter.isEmpty) {
    print('Filter cannot be empty.');
    return;
  }

  List<Student> filteredStudents = students.where((s) {
    bool hobbyMatch = s.hobbies.any((h) => h.toLowerCase() == filter);
    bool subjectMatch = s.subjects.any((subj) => subj.toLowerCase() == filter);
    return hobbyMatch || subjectMatch;
  }).toList();

  if (filteredStudents.isEmpty) {
    print('\nNo students found with hobby/subject "$filter".');
  } else {
    print('\n=== Filtered Results ===');
    for (var s in filteredStudents) {
      print(s);
      print('-------------------------');
    }
  }
}
