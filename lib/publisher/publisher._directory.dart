import 'dart:io';

import 'package:flutter/material.dart';

const Color _ink = Color(0xFF173B43);
const Color _gold = Color(0xFFC89543);
const Color _muted = Color(0xFF777873);
const Color _line = Color(0xFFDDD5C7);
const Color _card = Color(0xFFFFFCF6);

@immutable
class PublisherEntry {
  const PublisherEntry({
    required this.name,
    required this.rating,
    required this.bookCount,
    this.accountId = '',
    this.imagePath,
  });

  final String name;
  final double rating;
  final int bookCount;
  final String accountId;
  final String? imagePath;
}

class PublisherDirectoryView extends StatelessWidget {
  const PublisherDirectoryView({
    required this.publishers,
    required this.query,
    this.onPublisherTap,
    super.key,
  });

  final List<PublisherEntry> publishers;
  final String query;
  final ValueChanged<PublisherEntry>? onPublisherTap;

  @override
  Widget build(BuildContext context) {
    final normalizedQuery = query.trim().toLowerCase();
    final visiblePublishers = normalizedQuery.isEmpty
        ? publishers
        : publishers
              .where(
                (publisher) =>
                    publisher.name.toLowerCase().contains(normalizedQuery),
              )
              .toList();
    if (visiblePublishers.isEmpty) {
      return Center(
        child: Text(
          normalizedQuery.isEmpty ? 'No publishers yet' : 'No publishers found',
          style: const TextStyle(color: _muted, fontSize: 16),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 6),
      itemCount: visiblePublishers.length,
      separatorBuilder: (context, index) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final publisher = visiblePublishers[index];
        return _PublisherCard(
          publisher: publisher,
          onTap: onPublisherTap == null
              ? null
              : () => onPublisherTap!(publisher),
        );
      },
    );
  }
}

class _PublisherCard extends StatelessWidget {
  const _PublisherCard({required this.publisher, this.onTap});

  final PublisherEntry publisher;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 440;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(19),
        child: Container(
          height: 132,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: _card,
            border: Border.all(color: const Color(0xFFF0EADF)),
            borderRadius: BorderRadius.circular(19),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0D675C49),
                blurRadius: 14,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              _PublisherPicture(imagePath: publisher.imagePath),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      publisher.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _ink,
                        fontFamily: 'Georgia',
                        fontSize: 21,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Flexible(
                          child: FittedBox(
                            alignment: Alignment.centerLeft,
                            fit: BoxFit.scaleDown,
                            child: _RatingStars(
                              rating: publisher.rating,
                              size: compact ? 15 : 21,
                            ),
                          ),
                        ),
                        SizedBox(width: compact ? 4 : 8),
                        Text(
                          publisher.rating.toStringAsFixed(1),
                          style: TextStyle(
                            color: _ink,
                            fontSize: compact ? 12 : 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 11),
              Container(width: 1, height: 72, color: _line),
              SizedBox(
                width: 66,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${publisher.bookCount}',
                      style: const TextStyle(
                        color: _gold,
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Text(
                      'books',
                      style: TextStyle(color: _muted, fontSize: 15),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PublisherPicture extends StatelessWidget {
  const _PublisherPicture({required this.imagePath});

  final String? imagePath;

  @override
  Widget build(BuildContext context) {
    final hasImage = imagePath != null;
    return Container(
      width: 82,
      height: 82,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: hasImage
            ? null
            : Border.all(
                color: const Color(0xFFD9C5A4),
                style: BorderStyle.solid,
              ),
        image: hasImage
            ? DecorationImage(
                image: FileImage(File(imagePath!)),
                fit: BoxFit.cover,
              )
            : null,
        color: const Color(0xFFFBF7EE),
      ),
      child: hasImage
          ? null
          : const Icon(Icons.apartment_rounded, color: _gold, size: 35),
    );
  }
}

class _RatingStars extends StatelessWidget {
  const _RatingStars({required this.rating, this.size = 21});

  final double rating;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final icon = rating >= index + 1
            ? Icons.star
            : rating >= index + 0.5
            ? Icons.star_half
            : Icons.star_border;
        return Icon(icon, color: _gold, size: size);
      }),
    );
  }
}
