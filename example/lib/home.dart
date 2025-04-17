import 'package:example/editor/ui/pages/editor_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final TextEditingController _textController = TextEditingController();
  bool _hasSavedSession = false;
  static const String _savedRecipeKey = 'saved_recipe';

  @override
  void initState() {
    super.initState();
    _checkForSavedSession();
  }

  Future<void> _checkForSavedSession() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSession = prefs.containsKey(_savedRecipeKey);

    setState(() {
      _hasSavedSession = hasSession;
    });
  }

  Future<void> _loadSavedSession() async {
    final prefs = await SharedPreferences.getInstance();
    final savedRecipe = prefs.getString(_savedRecipeKey);

    if (savedRecipe != null) {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => EditorPage(recipeStr: savedRecipe)));
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  // Function to clear the text field
  void _clearTextField() {
    setState(() {
      _textController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Stack(
                    alignment: Alignment.topRight,
                    children: [
                      TextField(
                        controller: _textController,
                        maxLines: 10,
                        decoration: const InputDecoration(
                          hintText: "Enter your text here...",
                          contentPadding: EdgeInsets.only(
                              right: 40.0, left: 12.0, top: 12.0, bottom: 12.0),
                          border: InputBorder.none,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: _clearTextField,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Button to go to editor with input text
                MaterialButton(
                  onPressed: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(
                            builder: (context) => EditorPage(
                                recipeStr: _textController.text.isNotEmpty
                                    ? _textController.text
                                    : null)))
                        .then((_) {
                      _checkForSavedSession();
                    });
                  },
                  color: Theme.of(context)
                      .buttonTheme
                      .colorScheme
                      ?.primaryContainer,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 12.0),
                  elevation: 2.0,
                  child: const Text(
                    "Go to Editor with Input Text",
                  ),
                ),

                const SizedBox(height: 40),
                MaterialButton(
                  onPressed: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(
                            builder: (context) => const EditorPage()))
                        .then((_) {
                      _checkForSavedSession();
                    });
                  },
                  color: Theme.of(context)
                      .buttonTheme
                      .colorScheme
                      ?.primaryContainer,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 12.0),
                  elevation: 2.0,
                  child: const Text(
                    "Go to Editor",
                  ),
                ),
                if (_hasSavedSession) ...[
                  const SizedBox(height: 40),
                  MaterialButton(
                    onPressed: _loadSavedSession,
                    color: Theme.of(context)
                        .buttonTheme
                        .colorScheme
                        ?.primaryContainer,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 12.0),
                    elevation: 2.0,
                    child: const Text(
                      "Restore Saved Session",
                    ),
                  ),
                ],
                const SizedBox(
                  height: 40,
                ),
              ],
            ),
          ),
        ));
  }
}
