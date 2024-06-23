import 'package:flutter/material.dart';

class CardWidget extends StatelessWidget {
  final String title;
  final String creator;
  final String creatorImage;
  final String description;
  final int stars;
  final String language;

  const CardWidget(
      {super.key,
      required this.title,
      required this.creator,
      required this.creatorImage,
      required this.description,
      required this.stars,
      required this.language});

  String stripString(String str) {
    if (str.length > 23) {
      String newStr = "${str.substring(0, 23)}...";
      return newStr;
    }
    return str;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: SizedBox(
          width: double.infinity,
          child: Card(
            clipBehavior: Clip.hardEdge,
            child: InkWell(
              splashColor: Colors.grey,
              // onTap: () {
              //   print("Card Pressed!");
              //   Navigator.push(context,
              //       MaterialPageRoute(builder: (context) => DetailPage()));
              // },
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 15),
                            child: ClipOval(
                              child: Image.network(
                                creatorImage,
                                width: 50,
                                loadingBuilder: (BuildContext context,
                                    Widget child,
                                    ImageChunkEvent? loadingProgress) {
                                  if (loadingProgress == null) {
                                    return child;
                                  } else {
                                    return const CircularProgressIndicator(); // Show a progress indicator while loading
                                  }
                                },
                                errorBuilder: (BuildContext context,
                                    Object exception, StackTrace? stackTrace) {
                                  return const Text(
                                      'Failed to load image'); // Displayed if the image fails to load
                                },
                              ),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                stripString(title),
                                style: const TextStyle(
                                    fontSize: 17, fontWeight: FontWeight.w600),
                              ),
                              Text(
                                creator,
                                style: const TextStyle(fontSize: 13),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: Text(description),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.fromLTRB(7, 3, 7, 3),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(1000),
                              border: Border.all(color: Colors.grey)),
                          child: Text(language),
                        ),
                        Row(
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(right: 7),
                              child: Icon(
                                Icons.star,
                                size:
                                    20, // Adjust the size of the icon as needed
                                color:
                                    Colors.amber, // Set the color of the icon
                              ),
                            ),
                            Text(stars.toString())
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          )),
    );
  }
}

class Repository {
  final String name; // done
  final String creator; // done
  final String creatorImage;

  final String description; // done
  final int stars;
  final String language; // done

  final String license; // done
  final int forkCount;
  final String createdAt; // done

  const Repository(
      {required this.name,
      required this.creator,
      required this.creatorImage,
      required this.description,
      required this.stars,
      required this.language,
      required this.license,
      required this.forkCount,
      required this.createdAt});

  factory Repository.fromJson(Map<String, dynamic> json) {
    return Repository(
        name: json['name'] ?? "No name.",
        creator: json['owner'] != null
            ? (json['owner']['login'] ?? "No creator.")
            : "No owner in JSON",
        creatorImage: json['owner'] != null
            ? (json['owner']['avatar_url'] ?? "No image.")
            : "No owner in JSON",
        description: json['description'] ?? "No description.",
        stars: json['stargazers_count'] ?? -1,
        language: json['language'] ?? "No language",
        license: json['license'] != null
            ? (json['license']['spdx_id'] ?? "No license")
            : "No license in JSON",
        forkCount: json['forks_count'] ?? -1,
        createdAt: json['created_at'] ?? "No creation date.");
  }
}
