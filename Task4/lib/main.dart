import 'package:flutter/material.dart';

void main() => runApp(ProfileApp());

class ProfileApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ProfilePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final String name = 'Abdullah Nadeem';
  final String email = 'abdullah.nadeem492@gmail.com';
  final String phone = '+923176711871';
  final String tagline = 'Full-Stack Web Developer';

  int selectedTheme = 0;
  int imageIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile App By Abdullah Nadeem'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: _getBackgroundDecoration(),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildGradientButton('Classic', [Colors.black87, Colors.purple], 0),
                    _buildGradientButton('Modern', [Colors.orange, Colors.red], 1),
                    _buildGradientButton('Creative', [Colors.green, Colors.teal], 2),
                  ],
                ),
                SizedBox(height: 20),
                _buildProfileCard(),
                SizedBox(height: 22),
                _buildAboutCard(),
                SizedBox(height: 22),
                _buildSkillsCard(),
                SizedBox(height: 22),
                _buildExperienceCard(),
                SizedBox(height: 22),
                _buildContactCard(),
                SizedBox(height: 22),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            imageIndex = imageIndex == 3 ? 1 : imageIndex + 1;
          });
        },
        backgroundColor: Colors.indigo,
        child: Text('🖼️', style: TextStyle(fontSize: 24)), // Emoji instead of Icon
        tooltip: 'Change Profile Image',
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 2, blurRadius: 10, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 60,
                backgroundImage: AssetImage('images/abdullah$imageIndex.png'),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 25,
                  height: 25,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 15),
          Text(
            name,
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.indigo),
          ),
          SizedBox(height: 5),
          Text(
            tagline,
            style: TextStyle(fontSize: 16, color: Colors.grey[600], fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 2, blurRadius: 10, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('👤', style: TextStyle(fontSize: 24)),
              SizedBox(width: 10),
              Text(
                'About Me',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.indigo),
              ),
            ],
          ),
          SizedBox(height: 15),
          Text(
            'A Full-Stack Web Developer, Flutter App Development, and Database. I specialize in transforming complex challenges into elegant, user-friendly solutions.',
            style: TextStyle(fontSize: 16, height: 1.5, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsCard() {
    List<Map<String, dynamic>> skills = [
      {'name': 'Full Stack Web Developer', 'icon': '💻', 'color': Colors.purple},
      {'name': 'Flutter App Development', 'icon': '📱', 'color': Colors.blue},
      {'name': 'WordPress', 'icon': '🌐', 'color': Colors.green},
      {'name': 'Database', 'icon': '🗄️', 'color': Colors.orange},
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 2, blurRadius: 10, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('✨', style: TextStyle(fontSize: 24)),
              SizedBox(width: 10),
              Text(
                'Core Skills',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.indigo),
              ),
            ],
          ),
          SizedBox(height: 15),
          Container(
            height: 200,
            child: ListView.builder(
              itemCount: skills.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: EdgeInsets.symmetric(vertical: 5),
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: skills[index]['color'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: skills[index]['color'].withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Text(skills[index]['icon'], style: TextStyle(fontSize: 24)),
                      SizedBox(width: 15),
                      Expanded(
                        child: Text(
                          skills[index]['name'],
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[800]),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExperienceCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 2, blurRadius: 10, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('💼', style: TextStyle(fontSize: 24)), // Emoji instead of Icon
              SizedBox(width: 10),
              Text(
                'Experience',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.indigo),
              ),
            ],
          ),
          SizedBox(height: 15),
          _buildExperienceItem('Flutter Developer', 'CUI Vehari Campus', '2025'),
          _buildExperienceItem('Full Stack Web Developer', 'AWC', '2024 - 2025'),
          _buildExperienceItem('WordPress Developer', 'Digital Agency', '2022 - 2023'),
        ],
      ),
    );
  }

  Widget _buildExperienceItem(String title, String company, String period) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.indigo)),
          Text(company, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          Text(period, style: TextStyle(fontSize: 12, color: Colors.grey[500], fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }

  Widget _buildContactCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 2, blurRadius: 10, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('📞', style: TextStyle(fontSize: 24)),
              SizedBox(width: 10),
              Text(
                'Contact Information',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.indigo),
              ),
            ],
          ),
          SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildContactItem('📧', email, 'Email'),
              _buildContactItem('📱', phone, 'Phone'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(String emoji, String text, String label) {
    return Container(
      width: 150,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.indigo.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(emoji, style: TextStyle(fontSize: 28)),
          SizedBox(height: 8),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          SizedBox(height: 4),
          Text(
            text,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildGradientButton(String text, List<Color> colors, int themeIndex) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTheme = themeIndex;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(text, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  BoxDecoration _getBackgroundDecoration() {
    switch (selectedTheme) {
      case 1:
        return BoxDecoration(
          gradient: LinearGradient(colors: [Colors.purple, Colors.blue, Colors.teal], begin: Alignment.topLeft, end: Alignment.bottomRight),
        );
      case 2:
        return BoxDecoration(
          gradient: LinearGradient(colors: [Colors.orange, Colors.pink, Colors.red], begin: Alignment.topCenter, end: Alignment.bottomCenter),
        );
      default:
        return BoxDecoration(color: Colors.grey[100]);
    }
  }
}
