import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'settings_page.dart';
import 'package:sqflite/sqflite.dart';
import 'package:provider/provider.dart';
import 'package:money_management/database_helper.dart';
import'package:money_management/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the database
  await DatabaseHelper.instance.database;

  runApp(
    ChangeNotifierProvider(

      create: (context) => ThemeProvider(),

      child: const ExpenseTrackerApp(),
    ),
  );
}

class AppData extends ChangeNotifier {

  String _selectedCurrency = 'USD'; // Add this line


  String get selectedCurrency => _selectedCurrency; // Add this line



  void updateSelectedCurrency(String newCurrency) {
    _selectedCurrency = newCurrency;
    notifyListeners();
  }
}



class ExpenseTrackerApp extends StatefulWidget {
  const ExpenseTrackerApp({super.key});

  @override
  _ExpenseTrackerAppState createState() => _ExpenseTrackerAppState();
}

class _ExpenseTrackerAppState extends State<ExpenseTrackerApp> {




  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);



    return MaterialApp(
      title: 'Expense Tracker',
      theme: themeProvider.currentTheme,
      home: ChangeNotifierProvider(
        create: (context) => AppData(),

        child: Builder(
          builder: (context) {
            final appData = Provider.of<AppData>(context);

            return MaterialApp(


              initialRoute: '/',
              theme: themeProvider.currentTheme,
              routes: {
                '/': (context) => const WelcomePage(),
                '/settings': (context) => const SettingsPage(),
              },
            );
          },
        ),
      ),
    );


  }
}

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
        child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
        const Text(
        'Money Matters',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    ),
    const SizedBox(height: 40),
    ElevatedButton(
    onPressed: () {
    Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => LoginPage()),
    );
    },
      child: const Text('Login'),
    ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RegistrationPage()),
              );
            },
            child: const Text('New User Registration'),
          ),
        ],
        ),
        ),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isDarkMode = false;
  bool _isMounted = false; // Add this line

  @override
  void initState() {
    super.initState();
    _isMounted = true; // Set _isMounted to true when the widget is mounted
  }

  @override
  void dispose() {
    _isMounted = false; // Set _isMounted to false when the widget is disposed
    super.dispose();
  }

  void _toggleTheme() {
    if (_isMounted) {
      setState(() {
        _isDarkMode = !_isDarkMode;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        title: const Text('Login'),
    ),
    body: Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
    TextField(
    controller: _usernameController,
    decoration: const InputDecoration(labelText: 'Username'),
    ),
    TextField(
    controller: _passwordController,
    decoration: const InputDecoration(labelText: 'Password'),
    obscureText: true,
    ),
      const SizedBox(height: 20),
      ElevatedButton(
        onPressed: () {
          _login(context);
        },
        child: const Text('Login'),
      ),
    ],
    ),
    ),
    );
  }
  Future<void> _login(BuildContext context) async {
    final dbHelper = DatabaseHelper.instance;
    final List<Map<String, dynamic>> user = await dbHelper.queryUser(
        _usernameController.text, _passwordController.text);

    // Now that the 'user' has been retrieved, you can work with it
    if (user.isNotEmpty) {
      // Successful login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ExpenseListScreen(

          ),
        ),
      );
      print('Login successful');
    } else {
      // Invalid credentials
      print('Invalid credentials');
    }
  }







 // Replace with your actual logic
}



class RegistrationPage extends StatelessWidget {
  final TextEditingController _newUsernameController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();

  RegistrationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('New User Registration'),
        ),
        body: Padding(
        padding: const EdgeInsets.all(16.0),
    child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
    TextField(
    controller: _newUsernameController,
    decoration: const InputDecoration(labelText: 'New Username'),
    ),
    TextField(
    controller: _newPasswordController,
    decoration: const InputDecoration(labelText: 'New Password'),
    obscureText: true,
    ),

      const SizedBox(height: 20),
      ElevatedButton(
        onPressed: () {
          _register(context);
        },
        child: const Text('Register'),
      ),
    ],
    ),
        ),
    );
  }
  Future<void> _register(BuildContext context) async {
    final dbHelper = DatabaseHelper.instance;
    final newUsername = _newUsernameController.text;
    final newPassword = _newPasswordController.text;

    if (newUsername.isNotEmpty && newPassword.isNotEmpty) {
      // Store new user registration data
      final id = await dbHelper.insert({
        DatabaseHelper.columnName: newUsername,
        DatabaseHelper.columnPassword: newPassword,
      });

      if (id != null) {
        // Navigate back to the welcome page after registration
        Navigator.pop(context);
        print('Registration successful');
      } else {
        print('Failed to register user');
      }
    } else {
      // Handle invalid input
      print('Invalid registration data');
    }
  }
}

class Expense {
  final String name;
  final double amount;
  final DateTime? date;

  Expense({required this.name, required this.amount, this.date});
}

class MonthlyExpenseChartScreen extends StatelessWidget {
  final List<Expense> expenses;

  const MonthlyExpenseChartScreen({super.key, required this.expenses});

  @override
  Widget build(BuildContext context) {
    final List<BarChartGroupData> barGroups = generateBarGroups();
    final double maxExpense = getMaxMonthlyExpense();
    final bool hasExpenses = barGroups.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Monthly Expense Chart'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: hasExpenses
            ? BarChart(

          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: maxExpense * 1.2,
            titlesData: const FlTitlesData(

              leftTitles:AxisTitles(sideTitles: SideTitles(reservedSize: 40, showTitles: true)),
              bottomTitles:AxisTitles(sideTitles: SideTitles(reservedSize: 6, showTitles: true))
              ,
            ),
            barGroups: barGroups,
          ),
        )


            : const Center(
          child: Text(
            'No data available',
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
  double getMaxMonthlyExpense() {
    double maxExpense = 0.0;

    for (var expense in expenses) {
      if (expense.date != null) {
        final month = DateTime(expense.date!.year, expense.date!.month);
        final monthlyTotal = getMonthlyExpense(month);
        if (monthlyTotal > maxExpense) {
          maxExpense = monthlyTotal;
        }
      }
    }

    return maxExpense;
  }

  List<BarChartGroupData> generateBarGroups() {
    final Map<String, double> monthlyExpenses = {};

    for (var expense in expenses) {
      if (expense.date != null) {
        final month = DateTime(expense.date!.year, expense.date!.month);
        final monthKey = '${month.year}-${month.month}';

        monthlyExpenses.update(
          monthKey,
              (value) => value + expense.amount,
          ifAbsent: () => expense.amount,
        );
      }
    }

    double maxExpense = getMaxMonthlyExpense();
    final List<BarChartGroupData> barGroups = [];

    monthlyExpenses.forEach((month, totalExpense) {
      final isMaxMonth = totalExpense == maxExpense;

      barGroups.add(
        BarChartGroupData(
          x: barGroups.length,
          barsSpace: 12,
          barRods: [
            BarChartRodData(
              toY: totalExpense,
              color: isMaxMonth ? Colors.red : Colors.blue,
              width: 16,
            ),
          ],
        ),
      );
    });

    return barGroups;
  }

  double getMonthlyExpense(DateTime month) {
    double monthlyTotal = 0.0;

    for (var expense in expenses) {
      if (expense.date != null) {
        final expenseMonth = DateTime(expense.date!.year, expense.date!.month);

        if (expenseMonth == month) {
          monthlyTotal += expense.amount;
        }
      }
    }

    return monthlyTotal;
  }
  List<String> getUniqueMonths(List<Expense> expenses) {
    Set<String> uniqueMonths = <String>{};

    for (var expense in expenses) {
      if (expense.date != null) {
        final month = DateTime(expense.date!.year, expense.date!.month);
        uniqueMonths.add('${month.year}-${month.month}');
      }
    }

    return List<String>.from(uniqueMonths);
  }
}




class ExpenseListScreen extends StatefulWidget {

  const ExpenseListScreen({super.key, });

  @override
  _ExpenseListScreenState createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  final List<Expense> expenses = [];
  double budget = 0;
  DateTime? selectedDate;




  @override
  void initState() {
    super.initState();
    _loadExpenses();
    _loadBudgetAsync(); // Corrected method name
  }


  Future<void> _loadBudget() async {
    final prefs = await SharedPreferences.getInstance();
    final storedBudget = prefs.getDouble('budget');

    if (storedBudget != null) {
      setState(() {
        budget = storedBudget;
      });
    }
  }



  Future<void> _loadExpenses() async {
    final dbHelper = DatabaseHelper.instance;
    final Database? db = await dbHelper.database;

    if (db != null) {
      final List<Map<String, dynamic>> queryResult = await db.query('expenses');
      setState(() {
        expenses.addAll(queryResult.map((e) => Expense(
          name: e['name'],
          amount: e['amount'],
          date: e['date'] != null ? DateTime.parse(e['date']) : null,
        )).toList());
      });
    } else {
      // Handle the case where the database is null
      print('Error: Database is null');
    }
  }






  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker'),
        actions: [

        ],
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Budget: ${budget.toStringAsFixed(2)} ${Provider.of<AppData>(context).selectedCurrency}',
              style: const TextStyle(fontSize: 18),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _setBudget(context);
            },
            style: ElevatedButton.styleFrom(

            ),
            child: Text('Set Budget', style: TextStyle(color:   Colors.white )),
          ),
          ElevatedButton(
            onPressed: () {
              _sortExpensesByMonth();
            },
            style: ElevatedButton.styleFrom(

            ),
            child: Text('Sort by Month', style: TextStyle(color:Colors.white )),
          ),

          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
            child: const Text('Settings'),
          ),

          ListView.builder(
            shrinkWrap: true,
            itemCount: expenses.length,
            itemBuilder: (context, index) {
              final expense = expenses[index];
              final monthHeading = _getMonthHeading(expense.date);

              return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
              if (index == 0 || monthHeading != _getMonthHeading(expenses[index - 1].date))
              Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(monthHeading),
              ),
              Card(
              margin: const EdgeInsets.all(8.0),

              child: ListTile(
              title: Text(
              expense.name,
              style: TextStyle(
              fontWeight: FontWeight.bold,

              ),
                  ),
              subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
              Text(
              '\$${expense.amount.toStringAsFixed(2)}',

              ),
              if (expense.date != null)
              Text(
              'Date: ${expense.date!.toLocal().toString().split(' ')[0] ?? "N/A"}',

              ),
              ],
              ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    color: Colors.red,
                    onPressed: () {
                      _deleteExpense(expenses[index]);
                    },
                  ),
                ),
              )]);
            },
          ),
        ],
      ),


      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addExpense(context);
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: ExpenseGraphNavBar(
        onChartPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MonthlyExpenseChartScreen(expenses: expenses),
            ),
          );
        },
      ),
    );
  }



  Future<void> _loadBudgetAsync() async {
    final prefs = await SharedPreferences.getInstance();
    final storedBudget = prefs.getDouble('budget');

    if (storedBudget != null) {
      setState(() {
        budget = storedBudget;
      });
    }
  }

  void _sortExpensesByMonth() {
    setState(() {
      expenses.sort((a, b) {
        if (a.date == null || b.date == null) {
          return 0;
        }
        return a.date!.compareTo(b.date!);
      });
    });
  }


  String _getMonthHeading(DateTime? date) {
    if (date == null) {
      return 'Unknown Month';
    }
    return DateFormat.yMMMM().format(date);
  }

  void _deleteExpense(Expense expense) {
    setState(() {
      expenses.remove(expense);
    });
  }

  // Replace your existing code for _addExpense
  // Replace your existing code for _addExpense
  Future<void> _addExpense(BuildContext context) async {
    TextEditingController nameController = TextEditingController();
    TextEditingController amountController = TextEditingController();
    selectedDate = DateTime.now();

    Future<void> _selectDate() async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate!,
        firstDate: DateTime(2000),
        lastDate: DateTime(2101),
      );
      if (picked != null) {
        setState(() {
          selectedDate = picked;
        });
      }
    }

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Expense'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Expense Name'),
              ),
              TextField(
                controller: amountController,
                decoration: const InputDecoration(labelText: 'Amount budget'),
                keyboardType: TextInputType.number,
              ),
              Row(
                children: [
                  const Text('Date: '),
                  Text(selectedDate!.toLocal().toString().split(' ')[0] ?? "N/A"),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: _selectDate,
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final name = nameController.text;
                final amount = double.tryParse(amountController.text) ?? 0.0;

        if (name.isNotEmpty && amount > 0) {
        if (getTotalExpenses() + amount <= budget) {
        // Insert the expense into the database
        final dbHelper = DatabaseHelper.instance;
        final db = await dbHelper.database;

        try {
        final id = await db?.insert(
        'expenses',
        {
        'name': name,
        'amount': amount,
        'date': selectedDate?.toIso8601String(),
        },
        );


        if (id != null) {
          setState(() {
            expenses.add(Expense(name: name, amount: amount, date: selectedDate));
          });
          Navigator.of(context).pop();
          print('Expense added successfully');
        } else {
          print('Failed to add expense. Insert returned null.');
        }
        } catch (e) {
          print('Error during database insertion: $e');
        }
        } else {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Exceeded Budget'),
                content: const Text('Your expenses exceed the budget.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('OK'),
                  ),
                ],
              );
            },
          );
        }
        } else {
          // Handle invalid input
        }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }



  double getTotalExpenses() {
    return expenses.isNotEmpty ? expenses.map((expense) => expense.amount).reduce((a, b) => a + b) : 0.0;
  }

  Future<void> _setBudget(BuildContext context) async {
    TextEditingController budgetController = TextEditingController();
    budgetController.text = budget.toStringAsFixed(2);

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Set Budget'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: budgetController,
                decoration: const InputDecoration(labelText: 'Budget ()'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async { // Add async keyword here
                final newBudget = double.tryParse(budgetController.text) ?? 0.0;
                if (newBudget >= 0) {
                  setState(() {
                    budget = newBudget;
                  });

                  // Save the budget to SharedPreferences
                  final prefs = await SharedPreferences.getInstance();
                  prefs.setDouble('budget', newBudget);

                  Navigator.of(context).pop();
                } else {
                  // Handle invalid input
                }
              },
              child: const Text('Set'),
            ),

          ],
        );
      },
    );
  }
}

class ExpenseGraphNavBar extends StatelessWidget {
  final VoidCallback onChartPressed;

  const ExpenseGraphNavBar({super.key, required this.onChartPressed});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.list),
          label: 'List',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.show_chart),
          label: 'Chart',
        ),
      ],
      currentIndex: 0,
      onTap: (index) {
        if (index == 1) {
          onChartPressed();
        }
      },
    );
  }
}



















