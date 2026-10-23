import 'package:flutter/material.dart';

import '../main_page/discover.dart';
import '../main_page/discover_book.dart';
import '../main_page/writer_profile.dart';
import '../publisher/publisher._directory.dart';
import 'cover_design.dart';

const _previewArtist = WriterProfile(
  name: 'Mira Rahman',
  accountId: 'preview-cover-artist',
  about:
      'Cover artist creating thoughtful, story-led designs for independent '
      'authors and publishers.',
  isCoverArtist: true,
);

const _previewPublishers = [
  PublisherEntry(name: 'Prothoma', rating: 4.8, bookCount: 42),
  PublisherEntry(name: 'Riverstone Press', rating: 4.6, bookCount: 28),
  PublisherEntry(name: 'Paper Lantern', rating: 4.9, bookCount: 17),
  PublisherEntry(name: 'North Star Books', rating: 4.5, bookCount: 31),
];

const _previewCoverArtists = [
  _previewArtist,
  WriterProfile(
    name: 'Ayan Chowdhury',
    accountId: 'preview-cover-artist-2',
    about: 'Illustration and typography for literary fiction.',
    isCoverArtist: true,
  ),
  WriterProfile(
    name: 'Nadia Sultana',
    accountId: 'preview-cover-artist-3',
    about: 'Book jackets inspired by color, place, and memory.',
    isCoverArtist: true,
  ),
];

const _previewBooks = [
  DiscoverBook(
    title: 'The Quiet Meridian',
    author: 'Eleanor Hart',
    rating: '4.8',
    genre: 'Literary Fiction',
  ),
  DiscoverBook(
    title: 'Salt & Silence',
    author: 'Eleanor Hart',
    rating: '4.6',
    genre: 'Short Stories',
  ),
  DiscoverBook(
    title: 'Before the Clock Stops',
    author: 'James Okafor',
    rating: '4.4',
    genre: 'Science Fiction',
  ),
  DiscoverBook(
    title: 'Echoes in Binary',
    author: 'James Okafor',
    rating: '4.1',
    genre: 'Science Fiction',
  ),
];

const _previewCovers = [
  CoverDesign(
    title: 'The Amber Garden',
    author: 'Lina Ford',
    year: '2025',
    creator: 'Mira Rahman',
    color: Color(0xFFB77928),
  ),
  CoverDesign(
    title: 'Where Rivers Meet',
    author: 'Samir Ahmed',
    year: '2024',
    creator: 'Mira Rahman',
    color: Color(0xFF52756C),
  ),
  CoverDesign(
    title: 'A Map of Quiet',
    author: 'Nadia Islam',
    year: '2023',
    creator: 'Mira Rahman',
    color: Color(0xFF6D617D),
  ),
  CoverDesign(
    title: 'The Last Monsoon',
    author: 'Rafi Hasan',
    year: '2026',
    creator: 'Mira Rahman',
    color: Color(0xFF9A5E49),
  ),
];

const _previewDrafts = [
  CoverDesign(
    title: 'Blue Hour',
    creator: 'Mira Rahman',
    color: Color(0xFF4C6C94),
    isDraft: true,
  ),
  CoverDesign(
    title: 'The Paper Moon',
    creator: 'Mira Rahman',
    color: Color(0xFF997A9D),
    isDraft: true,
  ),
];

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  WriterProfileScreen.currentUser = _previewArtist;

  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DiscoverScreen(
        books: _previewBooks,
        publishers: _previewPublishers,
        coverArtists: _previewCoverArtists,
        coverDesigns: _previewCovers,
        coverDrafts: _previewDrafts,
      ),
    ),
  );
}
