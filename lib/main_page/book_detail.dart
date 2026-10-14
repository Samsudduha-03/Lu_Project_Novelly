import 'dart:io';

import 'package:flutter/material.dart';

import 'writer_profile.dart';

const Color _ink = Color(0xFF173B43);
const Color _deepInk = Color(0xFF12343B);
const Color _gold = Color(0xFFC89543);
const Color _muted = Color(0xFF777873);
const Color _line = Color(0xFFDDD5C7);
const Color _paper = Color(0xFFF4F0E7);

@immutable
class BookDetail {
  const BookDetail({
    required this.title,
    required this.author,
    required this.rating,
    this.reviewCount,
    this.pageCount,
    required this.genres,
    this.description = '',
    this.externalRating,
    this.coverImagePath,
    required this.reviews,
  });

  final String title;
  final String author;
  final double rating;
  final int? reviewCount;
  final int? pageCount;
  final List<String> genres;
  final String description;
  final double? externalRating;
  final String? coverImagePath;
  final List<BookReview> reviews;
}

@immutable
class BookReview {
  const BookReview({
    required this.reviewerName,
    required this.rating,
    required this.createdAt,
    required this.body,
  });

  final String reviewerName;
  final double rating;
  final DateTime createdAt;
  final String body;
}

class BookDetailScreen extends StatefulWidget {
  const BookDetailScreen({required this.book, super.key});

  final BookDetail book;

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  bool _descriptionExpanded = false;
  bool _sortByRating = false;

  List<BookReview> get _sortedReviews {
    final reviews = [...widget.book.reviews];
    if (_sortByRating) {
      reviews.sort((a, b) => b.rating.compareTo(a.rating));
    } else {
      reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    return reviews;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _paper,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFAF8F1), _paper, Color(0xFFEFECE2)],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final horizontalPadding = (constraints.maxWidth * 0.06).clamp(
                18.0,
                32.0,
              );
              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  8,
                  horizontalPadding,
                  28,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 640),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildBackButton(),
                        const SizedBox(height: 15),
                        _buildBookHeader(constraints.maxWidth),
                        const SizedBox(height: 20),
                        _buildGenreTags(),
                        const SizedBox(height: 28),
                        _buildSectionHeading('Book Description'),
                        const SizedBox(height: 13),
                        _buildDescription(),
                        if (widget.book.externalRating != null) ...[
                          const SizedBox(height: 17),
                          _buildExternalRating(),
                        ],
                        const SizedBox(height: 22),
                        _buildReviewsHeading(),
                        const SizedBox(height: 12),
                        ..._sortedReviews.map(
                          (review) => Padding(
                            padding: const EdgeInsets.only(bottom: 13),
                            child: _ReviewCard(review: review),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return Align(
      alignment: Alignment.centerLeft,
      child: IconButton(
        tooltip: 'Back',
        onPressed: () => Navigator.of(context).maybePop(),
        style: IconButton.styleFrom(
          backgroundColor: const Color(0xFFE9E4D8),
          foregroundColor: _deepInk,
          fixedSize: const Size(46, 46),
        ),
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 19),
      ),
    );
  }

  Widget _buildBookHeader(double availableWidth) {
    final compact = availableWidth <= 420;
    final coverWidth = (availableWidth * 0.27).clamp(104.0, 158.0);
    final coverHeight = coverWidth * 1.42;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _BookCover(
          width: coverWidth,
          height: coverHeight,
          imagePath: widget.book.coverImagePath,
        ),
        SizedBox(width: compact ? 14 : 20),
        Expanded(
          child: SizedBox(
            height: coverHeight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.book.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _ink,
                    fontFamily: 'Georgia',
                    fontSize: compact ? 31 : 38,
                    fontWeight: FontWeight.w600,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 5),
                InkWell(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => WriterProfileScreen(
                        profile: WriterProfile(
                          name: widget.book.author,
                          books: [
                            WriterBook(
                              title: widget.book.title,
                              rating: widget.book.rating,
                              reviews: widget.book.reviews
                                  .map(
                                    (review) => WriterBookReview(
                                      reviewerName: review.reviewerName,
                                      rating: review.rating,
                                      body: review.body,
                                    ),
                                  )
                                  .toList(),
                            ),
                          ],
                          publishers: const [],
                          about:
                              'More information about ${widget.book.author}.',
                        ),
                      ),
                    ),
                  ),
                  child: Text(
                    'by ${widget.book.author}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: _deepInk,
                      fontSize: compact ? 16 : 19,
                    ),
                  ),
                ),
                SizedBox(height: compact ? 7 : 12),
                Row(
                  children: [
                    _RatingStars(
                      rating: widget.book.rating,
                      size: compact ? 20 : 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.book.rating.toStringAsFixed(1),
                      style: TextStyle(
                        color: _deepInk,
                        fontSize: compact ? 15 : 17,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                if (widget.book.reviewCount != null ||
                    widget.book.pageCount != null) ...[
                  SizedBox(height: compact ? 5 : 8),
                  Flexible(
                    child: Text(
                      [
                        if (widget.book.reviewCount != null)
                          '${widget.book.reviewCount} reviews',
                        if (widget.book.pageCount != null)
                          '${widget.book.pageCount} pages',
                      ].join('   |   '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _muted,
                        fontSize: compact ? 13 : 16,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenreTags() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: widget.book.genres
          .map(
            (genre) => Container(
              constraints: const BoxConstraints(minWidth: 108),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
              decoration: BoxDecoration(
                border: Border.all(color: _line, width: 1.2),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Text(
                genre,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF514D45), fontSize: 16),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildSectionHeading(String title) {
    final compact = MediaQuery.sizeOf(context).width <= 420;
    return Row(
      children: [
        const Expanded(child: Divider(color: _line, thickness: 1.2)),
        Expanded(
          flex: 3,
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _ink,
              fontFamily: 'Georgia',
              fontSize: compact ? 20 : 24,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const Expanded(child: Divider(color: _line, thickness: 1.2)),
      ],
    );
  }

  Widget _buildDescription() {
    return Column(
      children: [
        Text(
          widget.book.description.isEmpty
              ? 'Description coming soon.'
              : widget.book.description,
          maxLines: _descriptionExpanded ? null : 4,
          overflow: _descriptionExpanded
              ? TextOverflow.visible
              : TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFF626568),
            fontSize: 17,
            height: 1.52,
          ),
        ),
        IconButton(
          tooltip: _descriptionExpanded ? 'Show less' : 'Read full description',
          visualDensity: VisualDensity.compact,
          onPressed: () =>
              setState(() => _descriptionExpanded = !_descriptionExpanded),
          icon: Icon(
            _descriptionExpanded
                ? Icons.keyboard_arrow_up_rounded
                : Icons.keyboard_arrow_down_rounded,
            color: _muted,
            size: 29,
          ),
        ),
      ],
    );
  }

  Widget _buildExternalRating() {
    final externalRating = widget.book.externalRating!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: _line, width: 1.1),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Goodreads Review',
                  style: TextStyle(
                    color: _deepInk,
                    fontSize: 19,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                _RatingStars(rating: externalRating, size: 22),
              ],
            ),
          ),
          Text(
            externalRating.toStringAsFixed(1),
            style: const TextStyle(
              color: _ink,
              fontFamily: 'Georgia',
              fontSize: 42,
            ),
          ),
          const SizedBox(width: 5),
          const Icon(Icons.chevron_right, color: _deepInk, size: 28),
        ],
      ),
    );
  }

  Widget _buildReviewsHeading() {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Reviews (${widget.book.reviewCount ?? widget.book.reviews.length})',
            style: const TextStyle(
              color: _deepInk,
              fontSize: 21,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        PopupMenuButton<bool>(
          initialValue: _sortByRating,
          onSelected: (sortByRating) =>
              setState(() => _sortByRating = sortByRating),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          itemBuilder: (context) => const [
            PopupMenuItem(value: false, child: Text('Most Recent')),
            PopupMenuItem(value: true, child: Text('Highest Rated')),
          ],
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
            decoration: BoxDecoration(
              border: Border.all(color: _line, width: 1.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Text(
                  _sortByRating ? 'Highest Rated' : 'Most Recent',
                  style: const TextStyle(
                    color: Color(0xFF514D45),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.keyboard_arrow_down, size: 19),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _BookCover extends StatelessWidget {
  const _BookCover({required this.width, required this.height, this.imagePath});

  final double width;
  final double height;
  final String? imagePath;

  @override
  Widget build(BuildContext context) {
    final hasImage = imagePath != null && imagePath!.trim().isNotEmpty;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF153A40), Color(0xFF0D292E)],
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      clipBehavior: Clip.antiAlias,
      child: hasImage
          ? Image.file(
              File(imagePath!),
              fit: BoxFit.cover,
              width: width,
              height: height,
              errorBuilder: (context, error, stackTrace) => _fallbackCover(),
            )
          : _fallbackCover(),
    );
  }

  Widget _fallbackCover() {
    return Center(
      child: Icon(
        Icons.menu_book_rounded,
        color: const Color(0xFFE5B55F),
        size: width * 0.55,
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review});

  final BookReview review;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: _line, width: 1.1),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 24,
            backgroundColor: _deepInk,
            child: Icon(Icons.person, color: Color(0xFFE5B55F), size: 31),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        review.reviewerName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _deepInk,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _relativeDate(review.createdAt),
                      style: const TextStyle(color: _muted, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _RatingStars(rating: review.rating, size: 19),
                    const SizedBox(width: 8),
                    Text(
                      review.rating.toStringAsFixed(1),
                      style: const TextStyle(color: _muted, fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                Text(
                  review.body,
                  style: const TextStyle(
                    color: Color(0xFF626568),
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _relativeDate(DateTime date) {
    final days = DateTime.now().difference(date).inDays;
    if (days <= 0) return 'Today';
    if (days == 1) return '1 day ago';
    if (days < 7) return '$days days ago';
    if (days < 14) return '1 week ago';
    if (days < 30) return '${days ~/ 7} weeks ago';
    if (days < 365) return '${days ~/ 30} months ago';
    return '${days ~/ 365} years ago';
  }
}

class _RatingStars extends StatelessWidget {
  const _RatingStars({required this.rating, required this.size});

  final double rating;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final difference = rating - index;
        final icon = difference >= 0.75
            ? Icons.star_rounded
            : difference >= 0.25
            ? Icons.star_half_rounded
            : Icons.star_outline_rounded;
        return Icon(icon, color: _gold, size: size);
      }),
    );
  }
}
