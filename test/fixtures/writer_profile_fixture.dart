import 'package:novelly/main_page/writer_profile.dart';

const _titles = [
  '1984',
  'Animal Farm',
  'Homage to Catalonia',
  'Down and Out in Paris and London',
  'Burmese Days',
  'The Road to Wigan Pier',
  'Keep the Aspidistra Flying',
  'Coming Up for Air',
  "A Clergyman's Daughter",
  'The Lion and the Unicorn',
  'Inside the Whale',
  'Shooting an Elephant',
  'Why I Write',
  'Politics and the English Language',
  'Nineteen Eighty-Four',
];

final WriterProfile sampleWriterProfile = WriterProfile(
  name: 'George Orwell',
  goodreads: 'Goodreads Link',
  facebook: 'https://facebook.com/georgeorwell',
  instagram: 'https://instagram.com/georgeorwell',
  website: 'https://george-orwell.example',
  isWriter: true,
  about:
      'George Orwell was an English novelist, essayist, journalist, and critic. '
      'His work is known for its biting social commentary, opposition to '
      'totalitarianism, and defense of democratic socialism.',
  books: List.generate(
    _titles.length,
    (index) => WriterBook(
      title: _titles[index],
      rating: 4.12,
      reviews: List.generate(
        index == _titles.length - 1 ? 4 : 22,
        (reviewIndex) => WriterBookReview(
          reviewerName: 'Reader ${index * 22 + reviewIndex + 1}',
          rating: 4.12,
          body: 'A sample review.',
        ),
      ),
    ),
  ),
  followerIds: List.generate(8400, (index) => 'reader-$index'),
  publishers: const [
    'Penguin Books',
    'Harvill Secker',
    'Harcourt Brace',
    'Faber & Faber',
    'Secker & Warburg',
  ],
);
