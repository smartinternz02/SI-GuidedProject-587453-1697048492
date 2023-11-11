import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppData with ChangeNotifier {
  String _selectedCurrency = 'USD'; // default currency

  List<String> currencies = ['USD', 'EUR', 'GBP', 'INR']; // add your currencies

  String get selectedCurrency => _selectedCurrency;

  set selectedCurrency(String newCurrency) {
    _selectedCurrency = newCurrency;
    notifyListeners(); // This notifies all listeners that the value has changed
  }
}


class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Currency:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _CurrencyDropdown(),
          ],
        ),
      ),
    );
  }
}



class _CurrencyDropdown extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appData = Provider.of<AppData>(context, listen: false);

    return DropdownButton<String>(
      value: appData.selectedCurrency,
      onChanged: (newValue) {
        appData.selectedCurrency = newValue!;
      },
      items: appData.currencies.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}
