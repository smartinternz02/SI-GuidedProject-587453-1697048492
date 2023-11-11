import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:money_management/app_theme.dart';
class ThemeProvider extends ChangeNotifier {
  ThemeData _currentTheme = AppTheme.lightTheme; // Set the initial theme

  ThemeData get currentTheme => _currentTheme;

  void toggleTheme() {
    _currentTheme = (_currentTheme == AppTheme.lightTheme)
        ? AppTheme.darkTheme
        : AppTheme.lightTheme;

    notifyListeners();
  }
}

class YourWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Widget'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                themeProvider.toggleTheme(); // Toggle the theme
              },
              child: const Text('Toggle Theme'),
            ),
            const SizedBox(height: 16),
            Text(
              'Current Theme: ${themeProvider.currentTheme == AppTheme.lightTheme ? 'Light' : 'Dark'}',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
