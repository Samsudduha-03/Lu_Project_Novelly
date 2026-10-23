import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../chat/chat_list.dart';
import '../main_page/novelly_bottom_navigation.dart';
import '../main_page/writer_profile.dart';
import 'publisher_profile.dart';

const Color _ink = Color(0xFF173B43);
const Color _deepInk = Color(0xFF12343B);
const Color _gold = Color(0xFFC89543);
const Color _muted = Color(0xFF777873);
const Color _line = Color(0xFFDDD5C7);
const Color _paper = Color(0xFFF4F0E7);
const Color _card = Color(0xFFFFFCF6);

@immutable
class PublisherBookRecord {
  const PublisherBookRecord({
    required this.id,
    required this.title,
    required this.author,
    required this.year,
    this.description = '',
    this.genre = '',
    this.pageCount = '',
    this.goodreadsLink = '',
    this.isbn = '',
    this.publication = '',
    this.imagePath,
  });

  final String id;
  final String title;
  final String author;
  final String year;
  final String description;
  final String genre;
  final String pageCount;
  final String goodreadsLink;
  final String isbn;
  final String publication;
  final String? imagePath;
}

@immutable
class PublisherAuthorRecord {
  const PublisherAuthorRecord({
    required this.id,
    required this.name,
    required this.about,
  });

  final String id;
  final String name;
  final String about;
}

class PublisherWorkspaceStore {
  PublisherWorkspaceStore._();

  static final Map<String, PublisherWorkspaceStore> _workspaces = {};
  static int _nextRecordId = 0;

  static PublisherWorkspaceStore forAccount(String accountId) {
    final normalizedId = accountId.trim();
    if (normalizedId.isEmpty) {
      throw ArgumentError.value(accountId, 'accountId', 'Must not be empty');
    }
    return _workspaces.putIfAbsent(normalizedId, PublisherWorkspaceStore._);
  }

  final List<PublisherBookRecord> books = [];
  final List<PublisherAuthorRecord> authors = [];

  static List<String> get authorDirectory {
    final namesByKey = <String, String>{};
    for (final workspace in _workspaces.values) {
      for (final book in workspace.books) {
        final name = book.author.trim();
        if (name.isNotEmpty) {
          namesByKey.putIfAbsent(name.toLowerCase(), () => name);
        }
      }
    }
    return namesByKey.values.toList()..sort();
  }

  String createBookId() => 'book-${_nextRecordId++}';
  String createAuthorId() => 'author-${_nextRecordId++}';
}

class PublisherDashboardScreen extends StatefulWidget {
  const PublisherDashboardScreen({super.key});

  @override
  State<PublisherDashboardScreen> createState() =>
      _PublisherDashboardScreenState();
}

class _PublisherDashboardScreenState extends State<PublisherDashboardScreen> {
  final String _accountId = WriterProfileScreen.currentUser.accountId;
  late final PublisherWorkspaceStore _workspace;
  final _bookFormKey = GlobalKey<FormState>();
  final _bookTitle = TextEditingController();
  final _bookAuthor = TextEditingController();
  final _bookDescription = TextEditingController();
  final _bookPages = TextEditingController();
  final _bookGoodreads = TextEditingController();
  final _bookIsbn = TextEditingController();
  final _bookPublication = TextEditingController();
  final _bookYear = TextEditingController();
  String? _bookGenre;
  String? _bookImagePath;
  String? _editingBookId;
  bool _addingBook = false;
  bool get _authorized =>
      WriterProfileScreen.currentUser.isPublisher &&
      _accountId.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    if (_authorized) {
      _workspace = PublisherWorkspaceStore.forAccount(_accountId);
    }
  }

  @override
  void dispose() {
    _bookTitle.dispose();
    _bookAuthor.dispose();
    _bookDescription.dispose();
    _bookPages.dispose();
    _bookGoodreads.dispose();
    _bookIsbn.dispose();
    _bookPublication.dispose();
    _bookYear.dispose();
    super.dispose();
  }

  void _addBook() {
    _clearBookForm();
    setState(() => _addingBook = true);
  }

  void _startEditingBook(PublisherBookRecord book) {
    _bookTitle.text = book.title;
    _bookAuthor.text = book.author;
    _bookDescription.text = book.description;
    _bookPages.text = book.pageCount;
    _bookGoodreads.text = book.goodreadsLink;
    _bookIsbn.text = book.isbn;
    _bookPublication.text = book.publication;
    _bookYear.text = book.year;
    _bookGenre = book.genre.isEmpty ? null : book.genre;
    _bookImagePath = book.imagePath;
    _editingBookId = book.id;
    setState(() => _addingBook = true);
  }

  void _clearBookForm() {
    _bookTitle.clear();
    _bookAuthor.clear();
    _bookDescription.clear();
    _bookPages.clear();
    _bookGoodreads.clear();
    _bookIsbn.clear();
    _bookPublication.clear();
    _bookYear.clear();
    _bookGenre = null;
    _bookImagePath = null;
    _editingBookId = null;
  }

  void _saveBook() {
    if (!_bookFormKey.currentState!.validate()) return;
    final id = _editingBookId ?? _workspace.createBookId();
    final book = PublisherBookRecord(
      id: id,
      title: _bookTitle.text.trim(),
      author: _bookAuthor.text.trim(),
      year: _bookYear.text.trim(),
      description: _bookDescription.text.trim(),
      genre: _bookGenre ?? '',
      pageCount: _bookPages.text.trim(),
      goodreadsLink: _bookGoodreads.text.trim(),
      isbn: _bookIsbn.text.trim(),
      publication: _bookPublication.text.trim(),
      imagePath: _bookImagePath,
    );
    setState(() {
      final index = _workspace.books.indexWhere((item) => item.id == id);
      if (index < 0) {
        _workspace.books.insert(0, book);
      } else {
        _workspace.books[index] = book;
      }
      _addingBook = false;
      _clearBookForm();
    });
  }

  Future<void> _pickBookImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null && mounted) {
      setState(() => _bookImagePath = image.path);
    }
  }

  Future<void> _editBook(PublisherBookRecord book) async {
    _startEditingBook(book);
  }

  Future<void> _manageBook(PublisherBookRecord book) async {
    final action = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(book.title),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'close'),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'edit'),
            child: const Text('Edit book'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'delete'),
            child: const Text('Remove book'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (action == 'edit') {
      _editBook(book);
    } else if (action == 'delete') {
      setState(
        () => _workspace.books.removeWhere((item) => item.id == book.id),
      );
    }
  }

  Future<void> _addAuthor() async {
    final authorName = await showDialog<String>(
      context: context,
      builder: (_) => _PublisherAuthorSearchDialog(
        authorNames: PublisherWorkspaceStore.authorDirectory,
        alreadyAdded: _workspace.authors.map((author) => author.name),
      ),
    );
    if (authorName == null || !mounted) return;
    final alreadyAdded = _workspace.authors.any(
      (author) => author.name.trim().toLowerCase() == authorName.toLowerCase(),
    );
    if (alreadyAdded) return;
    setState(() {
      _workspace.authors.insert(
        0,
        PublisherAuthorRecord(
          id: _workspace.createAuthorId(),
          name: authorName,
          about: '',
        ),
      );
    });
  }

  Future<void> _editAuthor(PublisherAuthorRecord author) async {
    final updated = await showDialog<PublisherAuthorRecord>(
      context: context,
      builder: (_) => _PublisherAuthorDialog(author: author),
    );
    if (updated == null || !mounted) return;
    final index = _workspace.authors.indexWhere((item) => item.id == author.id);
    if (index < 0) return;
    setState(() {
      _workspace.authors[index] = PublisherAuthorRecord(
        id: author.id,
        name: updated.name,
        about: updated.about,
      );
    });
  }

  void _navigate(NovellyNavigationDestination destination) {
    switch (destination) {
      case NovellyNavigationDestination.discover:
        Navigator.of(context).maybePop();
      case NovellyNavigationDestination.library:
        break;
      case NovellyNavigationDestination.chat:
        Navigator.of(
          context,
        ).push(MaterialPageRoute<void>(builder: (_) => const ChatListScreen()));
      case NovellyNavigationDestination.profile:
        final account = WriterProfileScreen.currentUser;
        final currentProfile =
            PublisherProfileScreen.currentUser ??
            PublisherProfile(name: account.name, accountId: account.accountId);
        final profile = currentProfile.withPublicationData(
          writersWorkedWith: _workspace.authors
              .map((author) => author.name)
              .toList(),
          books: _workspace.books
              .map(
                (book) => PublisherBook(
                  title: book.title,
                  author: book.author,
                  year: book.year,
                ),
              )
              .toList(),
        );
        PublisherProfileScreen.currentUser = profile;
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) =>
                PublisherProfileScreen(isCurrentUser: true, profile: profile),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_authorized) {
      return Scaffold(
        backgroundColor: _paper,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lock_outline, color: _deepInk, size: 42),
                  const SizedBox(height: 12),
                  const Text(
                    'Publisher access required',
                    style: TextStyle(
                      color: _ink,
                      fontSize: 21,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    child: const Text('Back'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

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
              final compact = constraints.maxWidth < 600;
              final padding = (constraints.maxWidth * .03).clamp(18.0, 32.0);
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1000),
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _card.withValues(alpha: .52),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            padding: EdgeInsets.fromLTRB(
                              padding,
                              10,
                              padding,
                              18,
                            ),
                            child: _addingBook
                                ? _addBookForm(compact)
                                : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      _buildHeader(compact),
                                      SizedBox(height: compact ? 21 : 25),
                                      _buildCollectionHeader(compact),
                                      const SizedBox(height: 15),
                                      if (_workspace.books.isEmpty)
                                        _emptyBooks()
                                      else
                                        _bookGrid(
                                          constraints.maxWidth,
                                          compact,
                                        ),
                                      const SizedBox(height: 9),
                                      _addAction(
                                        label: 'Add book',
                                        onPressed: _addBook,
                                      ),
                                      const SizedBox(height: 23),
                                      Container(height: 1, color: _line),
                                      SizedBox(height: compact ? 20 : 25),
                                      _buildAuthorsHeader(compact),
                                      const SizedBox(height: 14),
                                      if (_workspace.authors.isEmpty)
                                        _emptyAuthors()
                                      else
                                        _authorGrid(
                                          constraints.maxWidth,
                                          compact,
                                        ),
                                      const SizedBox(height: 8),
                                      _addAction(
                                        label: 'Add author',
                                        onPressed: _addAuthor,
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                        if (!_addingBook)
                          Padding(
                            padding: EdgeInsets.fromLTRB(
                              padding,
                              0,
                              padding,
                              10,
                            ),
                            child: NovellyBottomNavigation(
                              libraryLabel: 'My Publishing',
                              selectedDestination:
                                  NovellyNavigationDestination.library,
                              compact: compact,
                              onDestinationSelected: _navigate,
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

  Widget _addBookForm(bool compact) => Form(
    key: _bookFormKey,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                _editingBookId == null ? 'Add a New Book' : 'Edit Book',
                style: const TextStyle(
                  color: _ink,
                  fontFamily: 'Georgia',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            IconButton(
              tooltip: 'Cancel',
              onPressed: () => setState(() {
                _addingBook = false;
                _clearBookForm();
              }),
              icon: const Icon(Icons.close_rounded, color: _ink),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: [
                  _bookField(
                    Icons.menu_book_outlined,
                    'Title',
                    'Enter book title',
                    _bookTitle,
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Enter a book title'
                        : null,
                  ),
                  _bookField(
                    Icons.description_outlined,
                    'Description',
                    'Write description',
                    _bookDescription,
                    lines: 3,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            _imagePicker(compact),
          ],
        ),
        _bookField(
          Icons.person_outline,
          'Author',
          'Enter author name',
          _bookAuthor,
          validator: (value) => value == null || value.trim().isEmpty
              ? 'Enter an author name'
              : null,
        ),
        _bookField(
          Icons.sell_outlined,
          'Genre',
          'Select genre',
          null,
          isGenre: true,
        ),
        _bookField(
          Icons.book_outlined,
          'Page',
          'Enter number of pages',
          _bookPages,
          keyboard: TextInputType.number,
        ),
        _bookField(
          Icons.link,
          'Goodreads Link',
          'Paste goodreads link',
          _bookGoodreads,
          keyboard: TextInputType.url,
        ),
        _bookField(
          Icons.numbers,
          'ISBN Number',
          'Enter ISBN number',
          _bookIsbn,
        ),
        _bookField(
          Icons.account_balance_outlined,
          'Publication',
          'Enter publication name',
          _bookPublication,
        ),
        _bookField(
          Icons.calendar_today_outlined,
          'Publication Year',
          'Enter publication year',
          _bookYear,
          keyboard: TextInputType.number,
          validator: (value) => value == null || value.trim().isEmpty
              ? 'Enter a publication year'
              : null,
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 48,
          child: FilledButton.icon(
            onPressed: _saveBook,
            icon: const Icon(Icons.add_circle_outline),
            label: Text(_editingBookId == null ? 'Add Book' : 'Save Book'),
            style: FilledButton.styleFrom(
              backgroundColor: _deepInk,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9),
              ),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _imagePicker(bool compact) => InkWell(
    onTap: _pickBookImage,
    borderRadius: BorderRadius.circular(10),
    child: Container(
      width: compact ? 78 : 96,
      height: 108,
      decoration: BoxDecoration(
        border: Border.all(color: _gold),
        borderRadius: BorderRadius.circular(10),
        image: _bookImagePath == null
            ? null
            : DecorationImage(
                image: kIsWeb
                    ? NetworkImage(_bookImagePath!)
                    : FileImage(File(_bookImagePath!)) as ImageProvider,
                fit: BoxFit.cover,
              ),
      ),
      child: _bookImagePath == null
          ? const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_photo_alternate_outlined, color: _gold),
                SizedBox(height: 5),
                Text(
                  'Add Image',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF9C641D), fontSize: 12),
                ),
              ],
            )
          : null,
    ),
  );

  Widget _bookField(
    IconData icon,
    String label,
    String hint,
    TextEditingController? controller, {
    int lines = 1,
    TextInputType? keyboard,
    bool isGenre = false,
    String? Function(String?)? validator,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 13),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 36,
          height: 36,
          margin: const EdgeInsets.only(right: 11),
          decoration: const BoxDecoration(
            color: Color(0xFFF3EDE1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 19, color: _gold),
        ),
        Expanded(
          child: isGenre
              ? DropdownButtonFormField<String>(
                  initialValue: _bookGenre,
                  decoration: _bookFieldDecoration(label, hint),
                  icon: const Icon(Icons.keyboard_arrow_down, color: _ink),
                  items:
                      const [
                            'Fantasy',
                            'Fiction',
                            'Mystery',
                            'Romance',
                            'Science Fiction',
                            'Non-fiction',
                          ]
                          .map(
                            (genre) => DropdownMenuItem(
                              value: genre,
                              child: Text(genre),
                            ),
                          )
                          .toList(),
                  onChanged: (value) => setState(() => _bookGenre = value),
                )
              : TextFormField(
                  controller: controller,
                  validator: validator,
                  keyboardType: keyboard,
                  maxLines: lines,
                  decoration: _bookFieldDecoration(label, hint),
                ),
        ),
      ],
    ),
  );

  InputDecoration _bookFieldDecoration(String label, String hint) =>
      InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(
          color: _ink,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: const TextStyle(color: _muted, fontSize: 14),
        filled: true,
        fillColor: _card.withValues(alpha: .65),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 13,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _gold, width: 1.4),
        ),
      );

  Widget _buildHeader(bool compact) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Row(
        children: [
          _CircleButton(
            tooltip: 'Back',
            icon: Icons.arrow_back_rounded,
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          const Spacer(),
          _CircleButton(
            tooltip: 'Add book',
            icon: Icons.add_rounded,
            filled: true,
            onPressed: _addBook,
          ),
        ],
      ),
      SizedBox(height: compact ? 22 : 26),
      Text(
        'My Publishing',
        style: TextStyle(
          color: _ink,
          fontFamily: 'Georgia',
          fontSize: compact ? 34 : 40,
          fontWeight: FontWeight.w700,
          letterSpacing: -1.2,
        ),
      ),
    ],
  );

  Widget _buildCollectionHeader(bool compact) => Row(
    children: [
      Expanded(
        child: Text(
          'Published Books',
          style: TextStyle(
            color: _ink,
            fontFamily: 'Georgia',
            fontSize: compact ? 21 : 24,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      Text(
        '${_workspace.books.length} books',
        style: const TextStyle(color: _gold, fontSize: 16),
      ),
    ],
  );

  Widget _emptyBooks() => Container(
    height: 168,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: _card.withValues(alpha: .55),
      borderRadius: BorderRadius.circular(17),
      border: Border.all(color: _line),
    ),
    child: const Text(
      'Your published books will appear here.',
      style: TextStyle(color: _muted, fontSize: 15),
    ),
  );

  Widget _bookGrid(double maxWidth, bool compact) {
    final columns = maxWidth < 400 ? 2 : 3;
    return GridView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 16,
        mainAxisSpacing: 15,
        childAspectRatio: compact ? .56 : .61,
      ),
      itemCount: _workspace.books.length,
      itemBuilder: (context, index) {
        final book = _workspace.books[index];
        return _PublisherBookCard(
          book: book,
          onManage: () => _manageBook(book),
        );
      },
    );
  }

  Widget _buildAuthorsHeader(bool compact) => Row(
    children: [
      Expanded(
        child: Text(
          'Authors Worked With',
          style: TextStyle(
            color: _ink,
            fontFamily: 'Georgia',
            fontSize: compact ? 20 : 24,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      Text(
        '${_workspace.authors.length} '
        '${_workspace.authors.length == 1 ? 'author' : 'authors'}',
        style: const TextStyle(color: _gold, fontSize: 16),
      ),
    ],
  );

  Widget _authorGrid(double maxWidth, bool compact) {
    final columns = maxWidth < 400 ? 2 : 3;
    return GridView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 16,
        mainAxisSpacing: 15,
        childAspectRatio: compact ? .94 : 1,
      ),
      itemCount: _workspace.authors.length,
      itemBuilder: (context, index) {
        final author = _workspace.authors[index];
        final bookCount = _workspace.books
            .where(
              (book) =>
                  book.author.trim().toLowerCase() ==
                  author.name.trim().toLowerCase(),
            )
            .length;
        return _PublisherAuthorCard(
          author: author,
          bookCount: bookCount,
          onOpen: () => _showAuthorProfile(author),
        );
      },
    );
  }

  Widget _emptyAuthors() => Container(
    height: 132,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: _card.withValues(alpha: .55),
      borderRadius: BorderRadius.circular(17),
      border: Border.all(color: _line),
    ),
    child: const Text(
      'Add authors you have worked with.',
      style: TextStyle(color: _muted, fontSize: 15),
    ),
  );

  Widget _addAction({required String label, required VoidCallback onPressed}) =>
      Align(
        alignment: Alignment.centerLeft,
        child: TextButton.icon(
          onPressed: onPressed,
          icon: const Icon(Icons.add_circle_outline_rounded, size: 25),
          label: Text(label),
          style: TextButton.styleFrom(
            foregroundColor: _gold,
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
          ),
        ),
      );

  Future<void> _showAuthorProfile(PublisherAuthorRecord author) async {
    final action = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(author.name),
        content: Text(
          author.about.isEmpty ? 'No profile details added yet.' : author.about,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'close'),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'edit'),
            child: const Text('Edit profile'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'delete'),
            child: const Text('Remove author'),
          ),
        ],
      ),
    );
    if (action == 'edit') await _editAuthor(author);
    if (action == 'delete' && mounted) {
      setState(
        () => _workspace.authors.removeWhere((item) => item.id == author.id),
      );
    }
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    this.filled = false,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;
  final bool filled;

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: tooltip,
    onPressed: onPressed,
    style: IconButton.styleFrom(
      fixedSize: const Size(46, 46),
      backgroundColor: filled ? _gold : const Color(0xFFF6EBDD),
      foregroundColor: filled ? Colors.white : _ink,
    ),
    icon: Icon(icon, size: filled ? 29 : 22),
  );
}

class _PublisherAuthorCard extends StatelessWidget {
  const _PublisherAuthorCard({
    required this.author,
    required this.bookCount,
    required this.onOpen,
  });

  final PublisherAuthorRecord author;
  final int bookCount;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) => Material(
    color: _card.withValues(alpha: .5),
    borderRadius: BorderRadius.circular(17),
    child: InkWell(
      onTap: onOpen,
      borderRadius: BorderRadius.circular(17),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: _line),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(13, 12, 13, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Center(
                  child: Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFFAF1E6),
                      border: Border.all(color: _line.withValues(alpha: .8)),
                    ),
                    child: const Icon(
                      Icons.person_outline_rounded,
                      color: _gold,
                      size: 47,
                    ),
                  ),
                ),
              ),
              Text(
                author.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _ink,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 7),
              Row(
                children: [
                  const Icon(Icons.menu_book_outlined, color: _muted, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    '$bookCount ${bookCount == 1 ? 'book' : 'books'}',
                    style: const TextStyle(color: _muted, fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _PublisherBookCard extends StatelessWidget {
  const _PublisherBookCard({required this.book, required this.onManage});

  final PublisherBookRecord book;
  final VoidCallback onManage;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => Container(
      decoration: BoxDecoration(
        color: _card.withValues(alpha: .45),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: _line.withValues(alpha: .9)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onManage,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: constraints.maxWidth * 1.01,
                child: Container(
                  color: const Color(0xFFFBF5EE).withValues(alpha: .75),
                  child: book.imagePath == null
                      ? const Center(
                          child: Icon(
                            Icons.menu_book_outlined,
                            color: _gold,
                            size: 64,
                          ),
                        )
                      : Image(
                          image: kIsWeb
                              ? NetworkImage(book.imagePath!)
                              : FileImage(File(book.imagePath!)),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Center(
                                child: Icon(
                                  Icons.menu_book_outlined,
                                  color: _gold,
                                  size: 64,
                                ),
                              ),
                        ),
                ),
              ),
              Container(
                height: constraints.maxWidth * .62,
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: _line)),
                ),
                padding: const EdgeInsets.fromLTRB(12, 10, 10, 9),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _ink,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      book.author,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: _muted, fontSize: 12),
                    ),
                    const Spacer(),
                    Text(
                      book.year,
                      style: const TextStyle(
                        color: _gold,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _PublisherAuthorDialog extends StatefulWidget {
  const _PublisherAuthorDialog({this.author});

  final PublisherAuthorRecord? author;

  @override
  State<_PublisherAuthorDialog> createState() => _PublisherAuthorDialogState();
}

class _PublisherAuthorDialogState extends State<_PublisherAuthorDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.author?.name ?? '');
  late final _about = TextEditingController(text: widget.author?.about ?? '');

  @override
  void dispose() {
    _name.dispose();
    _about.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.author == null ? 'Add author' : 'Edit author profile'),
    content: Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _field(_name, 'Author name'),
          TextFormField(
            controller: _about,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Profile details'),
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: () {
          if (!_formKey.currentState!.validate()) return;
          Navigator.pop(
            context,
            PublisherAuthorRecord(
              id: widget.author?.id ?? '',
              name: _name.text.trim(),
              about: _about.text.trim(),
            ),
          );
        },
        child: const Text('Save'),
      ),
    ],
  );
}

class _PublisherAuthorSearchDialog extends StatefulWidget {
  const _PublisherAuthorSearchDialog({
    required this.authorNames,
    required this.alreadyAdded,
  });

  final List<String> authorNames;
  final Iterable<String> alreadyAdded;

  @override
  State<_PublisherAuthorSearchDialog> createState() =>
      _PublisherAuthorSearchDialogState();
}

class _PublisherAuthorSearchDialogState
    extends State<_PublisherAuthorSearchDialog> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _search.text.trim().toLowerCase();
    final addedNames = widget.alreadyAdded
        .map((name) => name.trim().toLowerCase())
        .toSet();
    final matches = widget.authorNames
        .where((name) => name.toLowerCase().contains(query))
        .toList();

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420, maxHeight: 560),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFFFCF7),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE8CDA6)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1472552D),
                blurRadius: 18,
                offset: Offset(0, 7),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(19, 12, 19, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFFFF8EA),
                      border: Border.all(color: const Color(0xFFE8CDA6)),
                    ),
                    child: const Icon(
                      Icons.person_outline,
                      color: _gold,
                      size: 21,
                    ),
                  ),
                  const SizedBox(width: 18),
                  const Expanded(
                    child: Text(
                      'Add author',
                      style: TextStyle(
                        color: _ink,
                        fontFamily: 'Georgia',
                        fontSize: 21,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints.tightFor(
                      width: 30,
                      height: 30,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: _gold, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 13),
              const Text(
                'Author name',
                style: TextStyle(
                  color: _ink,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _search,
                onChanged: (_) => setState(() {}),
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 11,
                  ),
                  prefixIcon: const Icon(Icons.search, color: _gold, size: 19),
                  prefixIconConstraints: const BoxConstraints(
                    minWidth: 38,
                    minHeight: 36,
                  ),
                  hintText: 'Search authors',
                  hintStyle: const TextStyle(color: _muted, fontSize: 12),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(7),
                    borderSide: const BorderSide(color: Color(0xFFE8CDA6)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(7),
                    borderSide: const BorderSide(color: _gold),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Flexible(
                child: matches.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            query.isEmpty
                                ? 'No authors found in published books yet.'
                                : 'No authors found.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: _muted, fontSize: 13),
                          ),
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        itemCount: matches.length,
                        separatorBuilder: (_, _) =>
                            const Divider(height: 1, color: _line),
                        itemBuilder: (context, index) {
                          final name = matches[index];
                          final isAdded = addedNames.contains(
                            name.toLowerCase(),
                          );
                          return ListTile(
                            dense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 2,
                            ),
                            leading: const Icon(
                              Icons.person_outline,
                              color: _gold,
                              size: 20,
                            ),
                            title: Text(
                              name,
                              style: const TextStyle(color: _ink, fontSize: 13),
                            ),
                            trailing: IconButton(
                              tooltip: isAdded ? 'Already added' : 'Add $name',
                              onPressed: isAdded
                                  ? null
                                  : () => Navigator.of(context).pop(name),
                              icon: Icon(
                                isAdded ? Icons.check : Icons.add,
                                color: isAdded ? _muted : _gold,
                              ),
                            ),
                          );
                        },
                      ),
              ),
              const Divider(height: 1, color: _line),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(foregroundColor: _ink),
                  child: const Text('Cancel'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _field(TextEditingController controller, String label) => TextFormField(
  controller: controller,
  decoration: InputDecoration(labelText: label),
  validator: (value) =>
      value == null || value.trim().isEmpty ? 'Required' : null,
);
