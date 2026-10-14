import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'writer_profile.dart';

const _ink = Color(0xFF173B43);
const _deepInk = Color(0xFF12343B);
const _gold = Color(0xFFC89543);
const _muted = Color(0xFF777873);
const _line = Color(0xFFDDD5C7);
const _paper = Color(0xFFF4F0E7);

class MyBookScreen extends StatefulWidget {
  const MyBookScreen({super.key});

  @override
  State<MyBookScreen> createState() => _MyBookScreenState();
}

class _MyBookScreenState extends State<MyBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final _search = TextEditingController();
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _pages = TextEditingController();
  final _goodreads = TextEditingController();
  final _isbn = TextEditingController();
  final _publication = TextEditingController();
  final List<_MyBook> _books = [
    _MyBook('1984'),
    _MyBook('Animal Farm'),
    _MyBook('Homage to Catalonia'),
    _MyBook('Down and Out in Paris and London'),
    _MyBook('Burmese Days'),
    _MyBook('The Road to Wigan Pier'),
  ];
  String _query = '';
  String? _genre;
  String? _imagePath;
  bool _adding = false;

  @override
  void dispose() {
    _search.dispose();
    _title.dispose();
    _description.dispose();
    _pages.dispose();
    _goodreads.dispose();
    _isbn.dispose();
    _publication.dispose();
    super.dispose();
  }

  List<_MyBook> get _visibleBooks => _books
      .where((book) => book.title.toLowerCase().contains(_query.toLowerCase()))
      .toList();

  void _saveBook() {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _books.insert(0, _MyBook(_title.text.trim(), imagePath: _imagePath));
      _adding = false;
      _search.clear();
      _query = '';
      _title.clear();
      _description.clear();
      _pages.clear();
      _goodreads.clear();
      _isbn.clear();
      _publication.clear();
      _genre = null;
      _imagePath = null;
    });
  }

  Future<void> _pickImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null && mounted) setState(() => _imagePath = image.path);
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
              final compact = constraints.maxWidth < 600;
              final padding = (constraints.maxWidth * .055).clamp(18.0, 38.0);
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 860),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(padding, 8, padding, 20),
                    child: Column(
                      children: [
                        _header(compact),
                        const SizedBox(height: 14),
                        Expanded(
                          child: _adding
                              ? _addBookForm(compact)
                              : _bookList(compact),
                        ),
                        if (!_adding) ...[
                          const SizedBox(height: 10),
                          _bottomNavigation(compact),
                        ],
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

  Widget _header(bool compact) => Row(
    children: [
      if (_adding) ...[
        IconButton(
          tooltip: 'Back',
          onPressed: () => setState(() => _adding = false),
          style: IconButton.styleFrom(
            backgroundColor: const Color(0xFFF3EDE1),
            foregroundColor: _ink,
          ),
          icon: const Icon(Icons.arrow_back),
        ),
        const SizedBox(width: 8),
      ],
      Text(
        'My Book',
        style: TextStyle(
          color: _ink,
          fontFamily: 'Georgia',
          fontSize: compact ? 25 : 30,
          fontWeight: FontWeight.w600,
        ),
      ),
      const Spacer(),
      const SizedBox(
        width: 48,
        height: 48,
        child: Icon(Icons.grid_view_rounded, color: _ink),
      ),
    ],
  );

  Widget _bottomNavigation(bool compact) => Container(
    height: compact ? 68 : 92,
    decoration: BoxDecoration(
      color: _deepInk,
      borderRadius: BorderRadius.circular(compact ? 23 : 29),
    ),
    child: Row(
      children: [
        _MyBookNavItem(
          icon: Icons.search_rounded,
          label: 'Search',
          compact: compact,
          onTap: () => Navigator.of(context).maybePop(),
        ),
        _MyBookNavItem(
          icon: Icons.menu_book_outlined,
          label: 'My Book',
          selected: true,
          compact: compact,
        ),
        _MyBookNavItem(
          icon: Icons.chat_bubble_outline,
          label: 'Chat',
          compact: compact,
        ),
        _MyBookNavItem(
          icon: Icons.person_outline,
          label: 'Profile',
          compact: compact,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const WriterProfileScreen(isCurrentUser: true),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _bookList(bool compact) => Column(
    children: [
      TextField(
        controller: _search,
        onChanged: (value) => setState(() => _query = value),
        decoration: InputDecoration(
          hintText: 'Search your books...',
          prefixIcon: const Icon(Icons.search, color: Color(0xFF998C79)),
          filled: true,
          fillColor: const Color(0xFFFFFCF7).withValues(alpha: .55),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(11),
            borderSide: const BorderSide(color: _line),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(11),
            borderSide: const BorderSide(color: _line),
          ),
        ),
      ),
      const SizedBox(height: 22),
      Row(
        children: [
          const Text(
            'All Books',
            style: TextStyle(
              color: _ink,
              fontFamily: 'Georgia',
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          OutlinedButton.icon(
            onPressed: () => setState(() => _adding = true),
            icon: const Icon(Icons.add, size: 22),
            label: const Text('Add Book'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF9C641D),
              side: const BorderSide(color: _line),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      Expanded(
        child: _visibleBooks.isEmpty
            ? const Center(
                child: Text('No books found', style: TextStyle(color: _muted)),
              )
            : GridView.builder(
                itemCount: _visibleBooks.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: compact ? 3 : 4,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: compact ? .78 : .82,
                ),
                itemBuilder: (context, index) =>
                    _bookCard(_visibleBooks[index]),
              ),
      ),
      const SizedBox(height: 8),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(width: 55, child: Divider(color: _line)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Text(
              '${_books.length} Books',
              style: const TextStyle(
                color: Color(0xFF9C641D),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 55, child: Divider(color: _line)),
        ],
      ),
      const Icon(Icons.spa, size: 17, color: _gold),
    ],
  );

  Widget _bookCard(_MyBook book) => Container(
    padding: const EdgeInsets.all(9),
    decoration: BoxDecoration(
      color: const Color(0xFFFFFCF7).withValues(alpha: .45),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFE9E2D7)),
      boxShadow: const [
        BoxShadow(
          color: Color(0x09000000),
          blurRadius: 7,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      children: [
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFF2E9DC),
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: const Color(0xFFE9D9C2)),
              image: book.imagePath == null
                  ? null
                  : DecorationImage(
                      image: FileImage(File(book.imagePath!)),
                      fit: BoxFit.cover,
                    ),
            ),
            child: book.imagePath == null
                ? const Icon(Icons.menu_book_outlined, color: _gold, size: 38)
                : null,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          book.title,
          maxLines: 2,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: _ink,
            fontFamily: 'Georgia',
            fontSize: 13,
            height: 1.3,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );

  Widget _addBookForm(bool compact) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Add a New Book',
        style: TextStyle(
          color: _ink,
          fontFamily: 'Georgia',
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(height: 18),
      Expanded(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        _formField(
                          Icons.menu_book_outlined,
                          'Title',
                          'Enter book title',
                          _title,
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                              ? 'Enter a book title'
                              : null,
                        ),
                        _formField(
                          Icons.description_outlined,
                          'Description',
                          'Write description',
                          _description,
                          lines: 3,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  _imagePicker(compact),
                ],
              ),
              _formField(Icons.sell_outlined, 'Genre', 'Select genre', null),
              _formField(
                Icons.book_outlined,
                'Page',
                'Enter number of pages',
                _pages,
                keyboard: TextInputType.number,
              ),
              _formField(
                Icons.link,
                'Goodreads Link',
                'Paste goodreads link',
                _goodreads,
              ),
              _formField(
                Icons.numbers,
                'ISBN Number',
                'Enter ISBN number',
                _isbn,
              ),
              _formField(
                Icons.account_balance_outlined,
                'Publication',
                'Enter publication name',
                _publication,
              ),
              const SizedBox(height: 6),
              SizedBox(
                height: 48,
                child: FilledButton.icon(
                  onPressed: _saveBook,
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('Add Book'),
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
        ),
      ),
    ],
  );

  Widget _imagePicker(bool compact) => InkWell(
    onTap: _pickImage,
    borderRadius: BorderRadius.circular(10),
    child: Container(
      width: compact ? 78 : 96,
      height: 108,
      decoration: BoxDecoration(
        border: Border.all(color: _gold),
        borderRadius: BorderRadius.circular(10),
        image: _imagePath == null
            ? null
            : DecorationImage(
                image: FileImage(File(_imagePath!)),
                fit: BoxFit.cover,
              ),
      ),
      child: _imagePath == null
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

  Widget _formField(
    IconData icon,
    String label,
    String hint,
    TextEditingController? controller, {
    int lines = 1,
    TextInputType? keyboard,
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
          child: label == 'Genre'
              ? DropdownButtonFormField<String>(
                  initialValue: _genre,
                  decoration: _fieldDecoration(label, hint),
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
                  onChanged: (value) => setState(() => _genre = value),
                )
              : TextFormField(
                  controller: controller,
                  validator: validator,
                  keyboardType: keyboard,
                  maxLines: lines,
                  decoration: _fieldDecoration(label, hint),
                ),
        ),
      ],
    ),
  );

  InputDecoration _fieldDecoration(String label, String hint) =>
      InputDecoration(
        labelText: label,
        hintText: hint,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        labelStyle: const TextStyle(
          color: _ink,
          fontFamily: 'Georgia',
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        hintStyle: const TextStyle(color: _muted, fontSize: 13),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 13,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _line),
        ),
      );
}

class _MyBook {
  const _MyBook(this.title, {this.imagePath});

  final String title;
  final String? imagePath;
}

class _MyBookNavItem extends StatelessWidget {
  const _MyBookNavItem({
    required this.icon,
    required this.label,
    required this.compact,
    this.selected = false,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final bool compact;
  final bool selected;
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
