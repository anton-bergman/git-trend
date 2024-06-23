import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'card_widget.dart';
import 'detail_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Git Trends'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String headerTest = "My Git Project";
  String descriptionTest =
      "This is my own personal Git project that i use to learn programming.";

  late Future<List<Repository>> trendingRepos;
  String fromDateValue = 'Today'; // default value
  String languageValue = 'All';

  @override
  void initState() {
    super.initState();
    trendingRepos = fetchTrendingRepos(getDateAgo(fromDateValue));
  }

  Future<List<Repository>> fetchTrendingRepos(String fromDate,
      [String? language]) async {
    String searchUrl;

    if (language != null) {
      searchUrl =
          "https://api.github.com/search/repositories?q=created:>$fromDate+sort:stars+language:$language&order=desc&per_page=10";
    } else {
      searchUrl =
          "https://api.github.com/search/repositories?q=created:>$fromDate+stars:>=10&sort=stars&order=desc&per_page=10";
    }

    final response = await http.get(
      Uri.parse(searchUrl),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonDecoded = json.decode(response.body);
      List<Repository> listOfRepositories = [];

      int numRepos = jsonDecoded['items'].length;
      for (int i = 0; i < numRepos; i++) {
        Repository newRepository = Repository.fromJson(jsonDecoded['items'][i]);
        listOfRepositories.add(newRepository);
      }

      return listOfRepositories;
    } else {
      throw Exception('Failed to load trending repositories');
    }
  }

  String getDateAgo(String date) {
    DateTime currentDate = DateTime.now();
    DateTime resultDate;

    switch (date) {
      case 'Today':
        resultDate = currentDate.subtract(const Duration(days: 1));
        break;
      case 'This week':
        resultDate = currentDate.subtract(const Duration(days: 7));
        break;
      case 'This month':
        resultDate =
            DateTime(currentDate.year, currentDate.month - 1, currentDate.day);
        break;
      case 'This year':
        resultDate =
            DateTime(currentDate.year - 1, currentDate.month, currentDate.day);
        break;
      default:
        throw ArgumentError('Invalid duration specified');
    }

    return '${resultDate.year}-${resultDate.month.toString().padLeft(2, '0')}-${resultDate.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    //trendingRepos = fetchTrendingRepos();
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
        ),
        body: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 0, 30, 0),
                  child: DropdownButton<String>(
                    value: fromDateValue,
                    onChanged: (String? newValue) {
                      setState(() {
                        fromDateValue = newValue!;
                        // You can perform actions based on the selected dropdown value here
                      });
                      if (languageValue == 'All') {
                        trendingRepos =
                            fetchTrendingRepos(getDateAgo(fromDateValue));
                      } else {
                        trendingRepos = fetchTrendingRepos(
                            getDateAgo(fromDateValue),
                            languageValue!.toLowerCase());
                      }
                    },
                    items: <String>[
                      'Today',
                      'This week',
                      'This month',
                      'This year'
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 0, 30, 0),
                  child: DropdownButton<String>(
                    value: languageValue,
                    onChanged: (String? newValue) {
                      setState(() {
                        languageValue = newValue!;
                        // You can perform actions based on the selected dropdown value here
                      });
                      if (languageValue == 'All') {
                        trendingRepos =
                            fetchTrendingRepos(getDateAgo(fromDateValue));
                      } else {
                        trendingRepos = fetchTrendingRepos(
                            getDateAgo(fromDateValue),
                            languageValue!.toLowerCase());
                      }
                    },
                    items: <String>[
                      'All',
                      'JavaScript',
                      'Python',
                      'Java',
                      'C',
                      'PHP',
                      'TypeScript',
                      'Swift',
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                )
              ],
            ),
            FutureBuilder(
                future: trendingRepos,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    List<Repository> repositories = snapshot.data!;

                    return Expanded(
                      child: ListView.builder(
                          itemCount: repositories.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => DetailPage(
                                              repository: repositories[index],
                                            )));
                              },
                              child: CardWidget(
                                title: repositories[index].name,
                                creator: repositories[index].creator,
                                creatorImage: repositories[index].creatorImage,
                                description: repositories[index].description,
                                stars: repositories[index].stars,
                                language: repositories[index].language,
                              ),
                            );
                          }),
                    );
                  } else if (snapshot.hasError) {
                    return Text('ERROR: ${snapshot.error}');
                  }
                  return const CircularProgressIndicator();
                })
          ],
        )));
  }
}
