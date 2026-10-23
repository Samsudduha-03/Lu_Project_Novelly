import 'package:novelly/main_page/discover_book.dart';
import 'package:novelly/publisher/publisher._directory.dart';

const List<DiscoverBook> demoDiscoverBooks = [
  DiscoverBook(
    title: 'The Silent Ink',
    author: 'Amina Rahman',
    rating: '4.8',
    genre: 'Literary Fiction',
  ),
  DiscoverBook(
    title: 'Whispers of the Valley',
    author: 'Rafiq Hasan',
    rating: '4.6',
    genre: 'Contemporary Fiction',
  ),
  DiscoverBook(
    title: 'Beyond the Horizon',
    author: 'Nadia Islam',
    rating: '4.7',
    genre: 'Literary Fiction',
  ),
  DiscoverBook(
    title: 'Fragments of Time',
    author: 'Arman Chowdhury',
    rating: '4.5',
    genre: 'Poetry',
  ),
  DiscoverBook(
    title: 'Before the Clock Stops',
    author: 'Leena Akter',
    rating: '4.4',
    genre: 'Science Fiction',
  ),
  DiscoverBook(
    title: 'Echoes in Binary',
    author: 'Amina Rahman',
    rating: '4.3',
    genre: 'Science Fiction',
  ),
];

const List<PublisherEntry> demoPublisherDirectory = [
  PublisherEntry(name: 'Prothoma', rating: 4.5, bookCount: 222),
  PublisherEntry(name: 'Bangla Bazar', rating: 5, bookCount: 302),
  PublisherEntry(name: 'Sahitya Prakash', rating: 4.5, bookCount: 190),
  PublisherEntry(name: 'Bibliophile', rating: 4.5, bookCount: 71),
];
