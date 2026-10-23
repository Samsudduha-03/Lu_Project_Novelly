import 'package:flutter/material.dart';
import 'package:novelly/main_page/discover.dart';
import 'package:novelly/main_page/writer_profile.dart';

import 'fixtures/discover_fixture.dart';
import 'fixtures/publisher_directory_fixture.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  WriterProfileScreen.currentUser = const WriterProfile(
    name: 'Novelly Demo Writer',
    isWriter: true,
  );

  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DiscoverScreen(
        books: sampleDiscoverBooks,
        publishers: samplePublishers,
      ),
    ),
  );
}
