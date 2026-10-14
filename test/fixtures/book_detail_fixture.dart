import 'package:novelly/main_page/book_detail.dart';

final BookDetail sampleBookDetail = BookDetail(
  title: '1984',
  author: 'George Orwell',
  rating: 4.8,
  reviewCount: 312,
  pageCount: 384,
  genres: ['Political', 'Satire', 'Dystopia', 'Literary', 'War'],
  description:
      'A chilling dystopian novel that explores a totalitarian society, '
      'constant surveillance, and the erosion of individual freedom. 1984 '
      'remains a powerful and timeless warning about the dangers of '
      'unchecked power.',
  externalRating: 4.8,
  reviews: [
    BookReview(
      reviewerName: 'Aarav Mehta',
      rating: 4.5,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      body:
          'A thought-provoking and unsettling read. Orwell’s vision feels '
          'more relevant than ever.',
    ),
    BookReview(
      reviewerName: 'Priya Sharma',
      rating: 5,
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      body:
          'A powerful classic that stayed with me long after I finished it.',
    ),
  ],
);
