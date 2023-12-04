import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movie App UTS',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        scaffoldBackgroundColor: Colors.black,
      ),
      home: MovieListScreen(),
    );
  }
}

class MovieListScreen extends StatefulWidget {
  @override
  _MovieListScreenState createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen>
    with SingleTickerProviderStateMixin {
  final String apiKey = 'cb977fb0b9ceab3f8726c0b739165fba';
  final String apiUrl =
      'https://api.themoviedb.org/3/movie/popular?api_key=';
  final String apiRatingUrl =
      'https://api.themoviedb.org/3/movie/top_rated?api_key=';
  int currentPage = 1;

  List<dynamic>? movies;
  List<dynamic>? filteredMovies;
  List<dynamic>? topRatedMovies;
  List<dynamic>? filteredTopRatedMovies;

  TextEditingController searchController = TextEditingController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 2);
    fetchMovies();
    fetchTopRatedMovies();
  }

  Future<void> fetchMovies({int page = 1}) async {
    final response = await http.get(Uri.parse('$apiUrl$apiKey&page=$page'));

    if (response.statusCode == 200) {
      setState(() {
        movies = json.decode(response.body)['results'];
        filteredMovies = movies;
      });
    } else {
      throw Exception('Failed to load movies');
    }
  }

  Future<void> fetchTopRatedMovies() async {
    final response =
        await http.get(Uri.parse('$apiRatingUrl$apiKey&page=$currentPage'));

    if (response.statusCode == 200) {
      setState(() {
        topRatedMovies = json.decode(response.body)['results'];
        filteredTopRatedMovies = topRatedMovies;
      });
    } else {
      throw Exception('Failed to load top-rated movies');
    }
  }

  String buildPosterUrl(String posterPath) {
    return 'https://image.tmdb.org/t/p/w500$posterPath';
  }

  int calculateRating(dynamic voteAverage) {
    if (voteAverage != null) {
      // Assuming the vote average is on a scale of 0 to 10
      return (voteAverage * 10).round();
    } else {
      return 0; // Return 0 if rating is not available
    }
  }

  void filterMovies(String query) {
    setState(() {
      filteredMovies = movies
          ?.where((movie) =>
              movie['title'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void filterTopRatedMovies(String query) {
    setState(() {
      filteredTopRatedMovies = topRatedMovies
          ?.where((movie) =>
              movie['title'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void loadMoreMovies() {
    setState(() {
      currentPage++;
    });
    fetchMovies(page: currentPage);
  }

  void previousPage() {
    if (currentPage > 1) {
      setState(() {
        currentPage--;
      });
      fetchMovies(page: currentPage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Top Movies', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.green,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Popular'),
            Tab(text: 'Top Rated'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back),
                      onPressed: previousPage,
                    ),
                    Text(
                      'Page $currentPage',
                      style: TextStyle(color: Colors.white),
                    ),
                    IconButton(
                      icon: Icon(Icons.arrow_forward),
                      onPressed: loadMoreMovies,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: searchController,
                  onChanged: filterMovies,
                  decoration: InputDecoration(
                    labelText: 'Search Movies',
                    border: OutlineInputBorder(),
                    fillColor: Color.fromARGB(255, 194, 185, 185),
                    filled: true,
                  ),
                ),
              ),
              Expanded(
                child: NotificationListener<ScrollEndNotification>(
                  onNotification: (scrollEnd) {
                    if (scrollEnd.metrics.pixels ==
                        scrollEnd.metrics.maxScrollExtent) {
                      loadMoreMovies();
                    }
                    return true;
                  },
                  child: ListView.builder(
                    itemCount: filteredMovies?.length ?? 0,
                    itemBuilder: (context, index) {
                      var movie = filteredMovies?[index];
                      return ListTile(
                        contentPadding: EdgeInsets.all(16),
                        title: Row(
                          children: [
                            Image.network(
                              buildPosterUrl(movie['poster_path']),
                              height: 170,
                              width: 170,
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    movie['title'],
                                    style: TextStyle(
                                        fontSize: 20, color: Colors.green),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Release Date: ${movie['release_date']}',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: const Color.fromARGB(
                                            255, 194, 185, 185)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: searchController,
                  onChanged: filterTopRatedMovies,
                  decoration: InputDecoration(
                    labelText: 'Search Top Rated Movies',
                    border: OutlineInputBorder(),
                    fillColor: Color.fromARGB(255, 194, 185, 185),
                    filled: true,
                  ),
                ),
              ),
              Expanded(
                child: NotificationListener<ScrollEndNotification>(
                  onNotification: (scrollEnd) {
                    if (scrollEnd.metrics.pixels ==
                        scrollEnd.metrics.maxScrollExtent) {
                      loadMoreMovies();
                    }
                    return true;
                  },
                  child: ListView.builder(
                    itemCount: filteredTopRatedMovies?.length ?? 0,
                    itemBuilder: (context, index) {
                      var movie = filteredTopRatedMovies?[index];
                      return ListTile(
                        contentPadding: EdgeInsets.all(16),
                        title: Row(
                          children: [
                            Image.network(
                              buildPosterUrl(movie['poster_path']),
                              height: 220,
                              width: 220,
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    movie['title'],
                                    style: TextStyle(
                                        fontSize: 20, color: Colors.green),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Release Date: ${movie['release_date']}',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: const Color.fromARGB(
                                            255, 194, 185, 185)),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Rating: ${calculateRating(movie['vote_average'])}%',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.yellow),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
