import 'package:flutter/material.dart';

import '../main_page/writer_profile.dart';

const _ink = Color(0xFF173B43);
const _gold = Color(0xFFC89543);
const _muted = Color(0xFF777873);
const _card = Color(0xFFFFFCF6);

class CoverArtistDirectoryView extends StatelessWidget {
  const CoverArtistDirectoryView({
    required this.coverArtists,
    required this.query,
    this.onCoverArtistTap,
    super.key,
  });

  final List<WriterProfile> coverArtists;
  final String query;
  final ValueChanged<WriterProfile>? onCoverArtistTap;

  @override
  Widget build(BuildContext context) {
    final normalizedQuery = query.trim().toLowerCase();
    final visibleArtists = coverArtists
        .where((artist) => artist.isCoverArtist)
        .where(
          (artist) =>
              normalizedQuery.isEmpty ||
              artist.name.toLowerCase().contains(normalizedQuery) ||
              artist.about.toLowerCase().contains(normalizedQuery),
        )
        .toList();

    if (visibleArtists.isEmpty) {
      return Center(
        child: Text(
          normalizedQuery.isEmpty
              ? 'No cover artists yet'
              : 'No cover artists found',
          style: const TextStyle(color: _muted, fontSize: 16),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 6),
      itemCount: visibleArtists.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final artist = visibleArtists[index];
        return _CoverArtistCard(
          artist: artist,
          onTap: onCoverArtistTap == null
              ? null
              : () => onCoverArtistTap!(artist),
        );
      },
    );
  }
}

class _CoverArtistCard extends StatelessWidget {
  const _CoverArtistCard({required this.artist, this.onTap});

  final WriterProfile artist;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 440;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(17),
        child: Container(
          constraints: const BoxConstraints(minHeight: 100),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _card,
            border: Border.all(color: const Color(0xFFF0EADF)),
            borderRadius: BorderRadius.circular(17),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0D675C49),
                blurRadius: 12,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: compact ? 28 : 34,
                backgroundColor: const Color(0xFFF3EBDD),
                child: Icon(
                  Icons.person_outline,
                  color: _gold,
                  size: compact ? 32 : 38,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      artist.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _ink,
                        fontFamily: 'Georgia',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      artist.about.isEmpty ? 'Cover Artist' : artist.about,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _muted,
                        fontSize: 13,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              const Icon(Icons.chevron_right, color: _gold),
            ],
          ),
        ),
      ),
    );
  }
}
