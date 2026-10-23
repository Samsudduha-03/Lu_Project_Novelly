import 'package:flutter/material.dart';
import '../chat/chat_list.dart';
import '../publisher/publisher_dashboard.dart';
import '../cover/cover_artist_profile.dart';
import '../cover/cover_artist_directory.dart';
import '../cover/cover_design.dart';
import '../cover/my_designs.dart';
import 'book_detail.dart';
import 'discover_book.dart';
import 'my_book.dart';
import 'novelly_bottom_navigation.dart';
import 'writer_profile.dart';
import '../publisher/publisher._directory.dart';
import '../publisher/publisher_profile.dart';

const Color _ink = Color(0xFF173B43);
const Color _deepInk = Color(0xFF12343B);
const Color _gold = Color(0xFFC89543);
const Color _muted = Color(0xFF777873);
const Color _line = Color(0xFFDDD5C7);
const Color _paper = Color(0xFFF4F0E7);

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({
    super.key,
    this.books = const [],
    this.publishers = const [],
    this.coverArtists = const [],
    this.coverDesigns = const [],
    this.coverDrafts = const [],
    this.initialTab = 0,
  });

  final List<DiscoverBook> books;
  final List<PublisherEntry> publishers;
  final List<WriterProfile> coverArtists;
  final List<CoverDesign> coverDesigns;
  final List<CoverDesign> coverDrafts;
  final int initialTab;

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  late int _selectedTab;
  bool _gridView = false;

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTab;
  }

  List<int> get _visibleTabIds =>
      WriterProfileScreen.currentUser.isWriter ||
          WriterProfileScreen.currentUser.isPublisher ||
          WriterProfileScreen.currentUser.isCoverArtist
      ? [0, 1, 2]
      : [0, 2];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<DiscoverBook> get _visibleBooks {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return widget.books;
    return widget.books
        .where(
          (book) =>
              book.title.toLowerCase().contains(query) ||
              book.author.toLowerCase().contains(query) ||
              book.genre.toLowerCase().contains(query),
        )
        .toList();
  }

  void _openBook(DiscoverBook book) {
    final rating = double.tryParse(book.rating) ?? 0;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BookDetailScreen(
          book: BookDetail(
            title: book.title,
            author: book.author,
            rating: rating,
            genres: [book.genre],
            reviews: const [],
          ),
        ),
      ),
    );
  }

  void _openPublisher(PublisherEntry publisher) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PublisherProfileScreen(
          profile: PublisherProfile.preview(
            name: publisher.name,
            publishedBookCount: publisher.bookCount,
            accountId: publisher.accountId,
            imagePath: publisher.imagePath,
          ),
        ),
      ),
    );
  }

  void _navigate(NovellyNavigationDestination destination) {
    switch (destination) {
      case NovellyNavigationDestination.discover:
        break;
      case NovellyNavigationDestination.library:
        final account = WriterProfileScreen.currentUser;
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => account.isCoverArtist
                ? MyDesignsScreen(
                    covers: widget.coverDesigns,
                    drafts: widget.coverDrafts,
                  )
                : account.isPublisher
                ? const PublisherDashboardScreen()
                : const MyBookScreen(),
          ),
        );
        break;
      case NovellyNavigationDestination.chat:
        Navigator.of(
          context,
        ).push(MaterialPageRoute<void>(builder: (_) => const ChatListScreen()));
        break;
      case NovellyNavigationDestination.profile:
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) {
              final account = WriterProfileScreen.currentUser;
              if (account.isCoverArtist) {
                return CoverArtistProfileScreen(
                  isCurrentUser: true,
                  covers: widget.coverDesigns,
                  drafts: widget.coverDrafts,
                );
              }
              if (account.isPublisher) {
                return PublisherProfileScreen(
                  isCurrentUser: true,
                  profile: PublisherProfileScreen.currentUser,
                );
              }
              return const WriterProfileScreen(isCurrentUser: true);
            },
          ),
        );
        break;
    }
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
              final mobile = constraints.maxWidth < 600;
              final horizontalPadding = (constraints.maxWidth * 0.05).clamp(
                mobile ? 16.0 : 20.0,
                38.0,
              );
              return Padding(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  mobile ? 8 : 12,
                  horizontalPadding,
                  mobile ? 8 : 10,
                ),
                child: Column(
                  children: [
                    _buildHeader(constraints.maxWidth, mobile),
                    SizedBox(height: mobile ? 8 : 16),
                    _buildTabs(mobile),
                    SizedBox(height: mobile ? 15 : 25),
                    _buildSearchField(mobile),
                    SizedBox(height: mobile ? 17 : 27),
                    Expanded(
                      child: _selectedTab == 0
                          ? _buildBookResults(constraints.maxWidth)
                          : _selectedTab == 1
                          ? PublisherDirectoryView(
                              publishers: widget.publishers,
                              query: _query,
                              onPublisherTap: _openPublisher,
                            )
                          : CoverArtistDirectoryView(
                              coverArtists: widget.coverArtists,
                              query: _query,
                              onCoverArtistTap: _openCoverArtist,
                            ),
                    ),
                    SizedBox(height: mobile ? 7 : 10),
                    _buildBottomNavigation(mobile),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _openCoverArtist(WriterProfile artist) {
    final currentUser = WriterProfileScreen.currentUser;
    final isCurrentUser =
        currentUser.isCoverArtist &&
        (artist.accountId.isNotEmpty
            ? artist.accountId == currentUser.accountId
            : artist.name == currentUser.name);
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CoverArtistProfileScreen(
          profile: artist,
          isCurrentUser: isCurrentUser,
          covers: isCurrentUser ? widget.coverDesigns : const [],
          drafts: isCurrentUser ? widget.coverDrafts : const [],
          books: widget.books,
          publishers: widget.publishers,
          coverArtists: widget.coverArtists,
        ),
      ),
    );
  }

  Widget _buildHeader(double availableWidth, bool mobile) {
    final titleSize = mobile
        ? (availableWidth * 0.075).clamp(29.0, 34.0)
        : (availableWidth * 0.062).clamp(36.0, 48.0);
    final controlSize = mobile ? 54.0 : 68.0;
    return SizedBox(
      height: controlSize,
      child: Row(
        children: [
          Text(
            'Novelly',
            style: TextStyle(
              color: _ink,
              fontFamily: 'Georgia',
              fontSize: titleSize,
              fontWeight: FontWeight.w600,
              letterSpacing: -2.2,
              height: 1,
            ),
          ),
          const Spacer(),
          if (_selectedTab == 0)
            SizedBox(
              width: controlSize,
              height: controlSize,
              child: IconButton(
                tooltip: _gridView
                    ? 'Switch to list view'
                    : 'Switch to grid view',
                onPressed: () => setState(() => _gridView = !_gridView),
                style: IconButton.styleFrom(
                  foregroundColor: _deepInk,
                  side: const BorderSide(color: _line),
                  shape: const CircleBorder(),
                ),
                icon: Icon(
                  _gridView ? Icons.view_list_rounded : Icons.tune_rounded,
                  size: mobile ? 29 : 35,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTabs(bool mobile) {
    const allLabels = ['Books', 'Publishers', 'Covers'];
    final tabIds = _visibleTabIds;
    final selectedPosition = tabIds.indexOf(_selectedTab);
    return SizedBox(
      height: mobile ? 48 : 57,
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: List.generate(tabIds.length, (position) {
                final tabId = tabIds[position];
                final selected = _selectedTab == tabId;
                return Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _selectedTab = tabId),
                    child: Center(
                      child: Text(
                        allLabels[tabId],
                        style: TextStyle(
                          color: selected
                              ? tabId == 1
                                    ? _gold
                                    : _ink
                              : _muted,
                          fontSize: mobile ? 19 : 23,
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          SizedBox(
            height: 2,
            child: Stack(
              children: [
                const Positioned.fill(child: ColoredBox(color: _line)),
                Align(
                  alignment: switch (selectedPosition) {
                    0 => Alignment.centerLeft,
                    1 when tabIds.length == 2 => Alignment.centerRight,
                    1 => Alignment.center,
                    _ => Alignment.centerRight,
                  },
                  child: FractionallySizedBox(
                    widthFactor: tabIds.length == 2 ? 0.22 : 0.16,
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: _selectedTab == 1 ? _gold : _ink,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField(bool mobile) {
    return SizedBox(
      height: mobile ? 62 : 76,
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _query = value),
        style: TextStyle(color: _ink, fontSize: mobile ? 17 : 21),
        decoration: InputDecoration(
          hintText: _selectedTab == 0
              ? 'Search books, authors, genres...'
              : 'Search ${_selectedTab == 1 ? 'publishers' : 'covers'}...',
          hintStyle: TextStyle(color: _muted, fontSize: mobile ? 17 : 21),
          prefixIcon: Icon(Icons.search, color: _muted, size: mobile ? 25 : 31),
          contentPadding: EdgeInsets.symmetric(vertical: mobile ? 16 : 22),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),
            borderSide: const BorderSide(color: _line, width: 1.4),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),
            borderSide: const BorderSide(color: _ink, width: 1.4),
          ),
        ),
      ),
    );
  }

  Widget _buildBookResults(double availableWidth) {
    final books = _visibleBooks;
    if (books.isEmpty) {
      return _buildEmptySection('No books found');
    }

    if (_gridView) {
      final mobile = availableWidth < 600;
      final columns = availableWidth >= 900
          ? 4
          : availableWidth >= 650
          ? 3
          : 2;
      return GridView.builder(
        padding: EdgeInsets.zero,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          crossAxisSpacing: mobile ? 12 : 16,
          mainAxisSpacing: mobile ? 12 : 16,
          childAspectRatio: mobile ? 0.95 : 0.72,
        ),
        itemCount: books.length,
        itemBuilder: (context, index) => _GridBookCard(
          book: books[index],
          onTap: () => _openBook(books[index]),
          compact: mobile,
        ),
      );
    }

    final cardHeight = (availableWidth * 0.225).clamp(138.0, 172.0);
    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: books.length,
      separatorBuilder: (context, index) => const SizedBox(height: 19),
      itemBuilder: (context, index) => SizedBox(
        height: cardHeight,
        child: _ListBookCard(
          book: books[index],
          onTap: () => _openBook(books[index]),
        ),
      ),
    );
  }

  Widget _buildEmptySection(String title) {
    return Center(
      child: Text(title, style: const TextStyle(color: _muted, fontSize: 17)),
    );
  }

  Widget _buildBottomNavigation(bool mobile) {
    final account = WriterProfileScreen.currentUser;
    return NovellyBottomNavigation(
      libraryLabel: account.isCoverArtist
          ? 'My Designs'
          : account.isPublisher
          ? 'My Publishing'
          : 'My Book',
      libraryIcon: account.isCoverArtist
          ? Icons.palette_outlined
          : Icons.menu_book_outlined,
      selectedDestination: NovellyNavigationDestination.discover,
      compact: mobile,
      onDestinationSelected: _navigate,
    );
  }
}

class _ListBookCard extends StatelessWidget {
  const _ListBookCard({required this.book, required this.onTap});

  final DiscoverBook book;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < 500;
        final coverWidth = (constraints.maxWidth * 0.185).clamp(
          narrow ? 74.0 : 84.0,
          128.0,
        );
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              border: Border.all(color: _line, width: 1.4),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                SizedBox(width: coverWidth, child: const _BookCover()),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(narrow ? 13 : 24, 12, 8, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          book.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: _ink,
                            fontSize: narrow ? 16 : 25,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.6,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          book.author,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: _muted,
                            fontSize: narrow ? 14 : 20,
                          ),
                        ),
                        SizedBox(height: narrow ? 10 : 15),
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: narrow ? 7 : 13,
                          runSpacing: 4,
                          children: [
                            _RatingStars(size: narrow ? 14 : 19),
                            Text(
                              book.rating,
                              style: TextStyle(
                                color: _ink,
                                fontSize: narrow ? 12 : 16,
                              ),
                            ),
                            Container(width: 1, height: 19, color: _line),
                            Text(
                              book.genre,
                              style: TextStyle(
                                color: _muted,
                                fontSize: narrow ? 12 : 15,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(right: 9),
                  child: Icon(Icons.chevron_right, color: _muted, size: 34),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _GridBookCard extends StatelessWidget {
  const _GridBookCard({
    required this.book,
    required this.onTap,
    required this.compact,
  });

  final DiscoverBook book;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          border: Border.all(color: _line, width: 1.2),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(flex: compact ? 7 : 6, child: const _BookCover()),
            Expanded(
              flex: compact ? 4 : 5,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: compact ? 8 : 12,
                  vertical: compact ? 4 : 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: compact
                      ? MainAxisAlignment.spaceBetween
                      : MainAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      maxLines: compact ? 1 : 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _ink,
                        fontSize: compact ? 13 : 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (!compact) const SizedBox(height: 4),
                    Text(
                      book.author,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _muted,
                        fontSize: compact ? 11 : 14,
                      ),
                    ),
                    if (!compact) const Spacer(),
                    Row(
                      children: [
                        Icon(Icons.star, color: _gold, size: compact ? 12 : 17),
                        SizedBox(width: compact ? 2 : 4),
                        Text(
                          book.rating,
                          style: TextStyle(
                            color: _ink,
                            fontSize: compact ? 11 : 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookCover extends StatelessWidget {
  const _BookCover();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => Container(
        width: constraints.maxWidth,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1D4850), _deepInk],
          ),
        ),
        child: Icon(
          Icons.menu_book_rounded,
          color: const Color(0xFFE7B45F),
          size: (constraints.maxWidth * 0.48).clamp(42.0, 67.0),
        ),
      ),
    );
  }
}

class _RatingStars extends StatelessWidget {
  const _RatingStars({this.size = 19});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.star, color: _gold, size: size),
        Icon(Icons.star, color: _gold, size: size),
        Icon(Icons.star, color: _gold, size: size),
        Icon(Icons.star, color: _gold, size: size),
        Icon(Icons.star_half, color: _gold, size: size),
      ],
    );
  }
}
