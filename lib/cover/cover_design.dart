import 'dart:typed_data';

import 'package:flutter/material.dart';

@immutable
class CoverDesign {
  const CoverDesign({
    required this.title,
    required this.creator,
    required this.color,
    this.author = '',
    this.year = '',
    this.imageBytes,
    this.isDraft = false,
  });

  final String title;
  final String creator;
  final Color color;
  final String author;
  final String year;
  final Uint8List? imageBytes;
  final bool isDraft;

  CoverDesign copyWith({
    String? title,
    String? creator,
    Color? color,
    String? author,
    String? year,
    Uint8List? imageBytes,
    bool? isDraft,
  }) => CoverDesign(
    title: title ?? this.title,
    creator: creator ?? this.creator,
    color: color ?? this.color,
    author: author ?? this.author,
    year: year ?? this.year,
    imageBytes: imageBytes ?? this.imageBytes,
    isDraft: isDraft ?? this.isDraft,
  );
}

class CoverArtistWorkspace {
  CoverArtistWorkspace._();

  static final Map<String, CoverArtistWorkspace> _workspaces = {};

  static CoverArtistWorkspace forAccount(
    String accountId, {
    List<CoverDesign> initialCovers = const [],
    List<CoverDesign> initialDrafts = const [],
  }) {
    final key = accountId.trim().isEmpty ? 'local-cover-artist' : accountId;
    return _workspaces.putIfAbsent(key, () {
      final workspace = CoverArtistWorkspace._();
      workspace.covers.addAll(initialCovers);
      workspace.drafts.addAll(initialDrafts);
      return workspace;
    });
  }

  static void clearForTesting() => _workspaces.clear();

  final List<CoverDesign> covers = [];
  final List<CoverDesign> drafts = [];
}

class CoverDesignArtwork extends StatelessWidget {
  const CoverDesignArtwork({
    required this.design,
    this.compact = false,
    super.key,
  });

  final CoverDesign design;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (design.imageBytes != null) {
      return Container(
        margin: EdgeInsets.all(compact ? 8 : 12),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          border: Border.all(color: design.color.withValues(alpha: .48)),
          borderRadius: BorderRadius.circular(compact ? 5 : 7),
        ),
        child: Image.memory(
          design.imageBytes!,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
        ),
      );
    }
    return AspectRatio(
      aspectRatio: compact ? .74 : .7,
      child: Container(
      margin: EdgeInsets.all(compact ? 8 : 12),
      decoration: BoxDecoration(
        color: design.color.withValues(alpha: .12),
        border: Border.all(color: design.color.withValues(alpha: .48)),
        borderRadius: BorderRadius.circular(compact ? 5 : 7),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.all(compact ? 8 : 12),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: design.color.withValues(alpha: .32)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.auto_awesome_outlined,
                      color: design.color,
                      size: compact ? 18 : 28,
                    ),
                    SizedBox(height: compact ? 7 : 11),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Text(
                        design.title,
                        maxLines: compact ? 2 : 3,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: design.color,
                          fontFamily: 'Georgia',
                          fontSize: compact ? 9 : 14,
                          fontWeight: FontWeight.w600,
                          height: 1.15,
                        ),
                      ),
                    ),
                    SizedBox(height: compact ? 5 : 8),
                    Container(
                      width: compact ? 23 : 34,
                      height: 1,
                      color: design.color.withValues(alpha: .65),
                    ),
                    if (!compact) ...[
                      const SizedBox(height: 7),
                      Text(
                        design.creator,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: design.color, fontSize: 9),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: compact ? 3 : 5,
            left: compact ? 3 : 5,
            child: Icon(
              Icons.auto_awesome,
              color: design.color.withValues(alpha: .5),
              size: compact ? 8 : 11,
            ),
          ),
          Positioned(
            right: compact ? 3 : 5,
            bottom: compact ? 3 : 5,
            child: Icon(
              Icons.auto_awesome,
              color: design.color.withValues(alpha: .5),
              size: compact ? 8 : 11,
            ),
          ),
        ],
      ),
      ),
    );
  }
}
