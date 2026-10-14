import 'package:flutter/material.dart';
import 'book_detail.dart';
import 'my_book.dart';
import 'writer_profile.dart';

const Color _ink = Color(0xFF173B43);
const Color _deepInk = Color(0xFF12343B);
const Color _gold = Color(0xFFC89543);
const Color _muted = Color(0xFF777873);
const Color _line = Color(0xFFDDD5C7);
const Color _paper = Color(0xFFF4F0E7);

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  int _selectedTab = 0;
  bool _gridView = false;

  static const List<_Book> _books = [
    _Book(
      title: 'The Quiet Meridian',
      author: 'Eleanor Hart',
      rating: '4.8',
      genre: 'Literary Fiction',
    ),
    _Book(
      title: 'Salt & Silence',
      author: 'Eleanor Hart',
      rating: '4.6',
      genre: 'Short Stories',
    ),
    _Book(
      title: 'Before the Clock Stops',
      author: 'James Okafor',
      rating: '4.4',
      genre: 'Science Fiction',
    ),
    _Book(
      title: 'Echoes in Binary',
      author: 'James Okafor',
      rating: '4.1',
      genre: 'Science Fiction',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_Book> get _visibleBooks {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return _books;
    return _books
        .where(
          (book) =>
              book.title.toLowerCase().contains(query) ||
              book.author.toLowerCase().contains(query) ||
              book.genre.toLowerCase().contains(query),
        )
        .toList();
  }

  void _openBook(_Book book) {
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
                          : _buildEmptySection(
                              _selectedTab == 1 ? 'Publishers' : 'Covers',
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(21),
                ),
              ),
              icon: Icon(
                _gridView ? Icons.view_list_rounded : Icons.tune_rounded,
                size: mobile ? 25 : 31,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs(bool mobile) {
    const labels = ['Books', 'Publishers', 'Covers'];
    return SizedBox(
      height: mobile ? 48 : 57,
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: List.generate(labels.length, (index) {
                final selected = _selectedTab == index;
                return Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _selectedTab = index),
                    child: Center(
                      child: Text(
                        labels[index],
                        style: TextStyle(
                          color: selected ? _ink : _muted,
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
                  alignment: [
                    Alignment.centerLeft,
                    Alignment.center,
                    Alignment.centerRight,
                  ][_selectedTab],
                  child: FractionallySizedBox(
                    widthFactor: 0.16,
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: _ink,
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
      child: Text(
        title == 'No books found' ? title : '$title coming soon',
        style: const TextStyle(color: _muted, fontSize: 17),
      ),
    );
  }

  Widget _buildBottomNavigation(bool mobile) {
    return Container(
      height: mobile ? 68 : 92,
      decoration: BoxDecoration(
        color: _deepInk,
        borderRadius: BorderRadius.circular(mobile ? 23 : 29),
      ),
      child: Row(
        children: [
          _BottomNavigationItem(
            icon: Icons.search_rounded,
            label: 'Search',
            selected: true,
            compact: mobile,
          ),
          _BottomNavigationItem(
            icon: Icons.menu_book_outlined,
            label: 'My Book',
            compact: mobile,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const MyBookScreen()),
            ),
          ),
          _BottomNavigationItem(
            icon: Icons.chat_bubble_outline,
            label: 'Chat',
            compact: mobile,
          ),
          _BottomNavigationItem(
            icon: Icons.person_outline,
            label: 'Profile',
            compact: mobile,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const WriterProfileScreen(isCurrentUser: true),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Book {
  const _Book({
    required this.title,
    required this.author,
    required this.rating,
    required this.genre,
  });

  final String title;
  final String author;
  final String rating;
  final String genre;
}

class _ListBookCard extends StatelessWidget {
  const _ListBookCard({required this.book, required this.onTap});

  final _Book book;
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

  final _Book book;
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

class _BottomNavigationItem extends StatelessWidget {
  const _BottomNavigationItem({
    required this.icon,
    required this.label,
    this.selected = false,
    this.compact = false,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final bool compact;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? const Color(0xFFE5AE4D) : Colors.white;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: compact ? 25 : 34),
            SizedBox(height: compact ? 2 : 4),
            Text(
              label,
              style: TextStyle(color: color, fontSize: compact ? 12 : 16),
            ),
          ],
        ),
      ),
    );
  }
}
