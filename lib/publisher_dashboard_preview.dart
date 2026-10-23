import 'package:flutter/material.dart';

import 'main_page/writer_profile.dart';
import 'publisher/publisher_dashboard.dart';

void main() {
  const accountId = 'publisher-dashboard-preview';
  WriterProfileScreen.currentUser = const WriterProfile(
    name: 'Novelly Press',
    accountId: accountId,
    isPublisher: true,
  );
  final workspace = PublisherWorkspaceStore.forAccount(accountId);
  workspace.books
    ..add(
      const PublisherBookRecord(
        id: 'preview-book-1',
        title: 'The Salt Orchard',
        author: 'Amina Rahman',
        year: '2021',
      ),
    )
    ..add(
      const PublisherBookRecord(
        id: 'preview-book-2',
        title: 'Letters from Sylhet',
        author: 'Tariq Hasan',
        year: '2019',
      ),
    )
    ..add(
      const PublisherBookRecord(
        id: 'preview-book-3',
        title: 'River Cartographer',
        author: 'Amina Rahman',
        year: '2023',
      ),
    );
  workspace.authors
    ..add(
      const PublisherAuthorRecord(
        id: 'preview-author-1',
        name: 'Amina Rahman',
        about: 'Novelist and short story writer.',
      ),
    )
    ..add(
      const PublisherAuthorRecord(
        id: 'preview-author-2',
        name: 'Tariq Hasan',
        about: 'Poet and essayist.',
      ),
    );

  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PublisherDashboardScreen(),
    ),
  );
}
