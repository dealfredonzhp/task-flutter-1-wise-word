import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigoAccent),
          textTheme: TextTheme(
            titleLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
            bodyMedium: TextStyle(fontSize: 18, color: Colors.indigo),
          ),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
  var favorites = <WordPair>[];
  var history = <WordPair>[]; // List to store generated words

  void getNext() {
    history.add(current); // Add current word to history before generating a new one
    current = WordPair.random();
    notifyListeners();
  }

  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = FavoritesPage();
        break;
      case 2:
        page = HistoryPage(); // New History page
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return Scaffold(
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            selectedIndex = index;
          });
        },
        selectedIndex: selectedIndex,
        destinations: [
          NavigationDestination(
              selectedIcon: Icon(Icons.home_filled),
              icon: Icon(Icons.home_outlined),
              label: 'Home'),
          NavigationDestination(
              selectedIcon: Icon(Icons.favorite_rounded),
              icon: Icon(Icons.favorite_border),
              label: "Favorite"),
          NavigationDestination(
              selectedIcon: Icon(Icons.history),
              icon: Icon(Icons.history_outlined),
              label: "History"),
        ],
      ),
      body: Container(color: Colors.grey[100], child: page),
    );
  }
}

class GeneratorPage extends StatelessWidget {
  const GeneratorPage({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BigCard(pair: pair),
          SizedBox(height: 20),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavorite();
                },
                icon: Icon(icon, color: Colors.indigoAccent),
                label: Text('Like'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.indigoAccent,
                ),
              ),
              SizedBox(width: 20),
              ElevatedButton(
                onPressed: () {
                  appState.getNext();
                },
                child: Text('Next'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigoAccent,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({super.key, required this.pair});

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.titleLarge!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Card(
      color: theme.colorScheme.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Text(
          pair.asPascalCase,
          style: style,
          semanticsLabel: "${pair.first} ${pair.second}",
        ),
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Container(
      color: Colors.white,
      child: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'You have ${appState.favorites.length} favorite words:',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          ...appState.favorites.map(
            (pair) => ListTile(
              title: Text(
                pair.asPascalCase,
                style: TextStyle(color: Colors.indigo),
              ),
              textColor: Theme.of(context).colorScheme.primary,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("It’s ${pair.asPascalCase}!"),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class HistoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Container(
      color: Colors.white,
      child: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'History of generated words:',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          ...appState.history.map(
            (pair) => ListTile(
              title: Text(pair.asPascalCase, style: TextStyle(color: Colors.black)),
            ),
          ),
        ],
      ),
    );
  }
}