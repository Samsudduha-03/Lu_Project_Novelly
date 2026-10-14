import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

const _ink = Color(0xFF173B43);
const _gold = Color(0xFFC89543);
const _paper = Color(0xFFF4F0E7);
const _line = Color(0xFFDDD5C7);

@immutable
class WriterProfile {
  const WriterProfile({
    required this.name,
    this.goodreads = '',
    this.facebook = '',
    this.instagram = '',
    this.website = '',
    this.about = '',
    this.isWriter = false,
    this.books = const [],
    this.followerIds = const [],
    this.publishers = const [],
  });

  final String name;
  final String goodreads;
  final String facebook;
  final String instagram;
  final String website;
  final String about;
  final bool isWriter;
  final List<WriterBook> books;
  final List<String> followerIds;
  final List<String> publishers;

  int get publishedBookCount => books.length;
  int get reviewCount =>
      books.fold(0, (total, book) => total + book.reviews.length);
  int get followerCount => followerIds.length;
  double get rating => books.isEmpty
      ? 0
      : books.fold(0.0, (total, book) => total + book.rating) / books.length;
}

@immutable
class WriterBook {
  const WriterBook({
    required this.title,
    this.rating = 0,
    this.reviews = const [],
  });

  final String title;
  final double rating;
  final List<WriterBookReview> reviews;
}

@immutable
class WriterBookReview {
  const WriterBookReview({
    required this.reviewerName,
    required this.rating,
    required this.body,
  });

  final String reviewerName;
  final double rating;
  final String body;
}

class _ProfileEditResult {
  const _ProfileEditResult(this.profile, this.avatarPath);

  final WriterProfile profile;
  final String? avatarPath;
}

class WriterProfileScreen extends StatefulWidget {
  static WriterProfile currentUser = const WriterProfile(name: 'Your profile');
  static String? currentAvatarPath;

  const WriterProfileScreen({
    this.profile = const WriterProfile(name: 'Author'),
    this.isCurrentUser = false,
    super.key,
  });

  final WriterProfile profile;
  final bool isCurrentUser;

  @override
  State<WriterProfileScreen> createState() => _WriterProfileScreenState();
}

class _WriterProfileScreenState extends State<WriterProfileScreen> {
  late WriterProfile _profile = widget.isCurrentUser
      ? WriterProfileScreen.currentUser
      : widget.profile;
  String? _avatarPath;
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    if (widget.isCurrentUser) {
      _avatarPath = WriterProfileScreen.currentAvatarPath;
    }
  }

  Future<void> _editProfile() async {
    final result = await showDialog<_ProfileEditResult>(
      context: context,
      builder: (_) =>
          _ProfileEditDialog(profile: _profile, avatarPath: _avatarPath),
    );
    if (result == null || !mounted) return;

    setState(() {
      _profile = result.profile;
      _avatarPath = result.avatarPath;
    });
    if (widget.isCurrentUser) WriterProfileScreen.currentUser = _profile;
    if (widget.isCurrentUser) {
      WriterProfileScreen.currentAvatarPath = _avatarPath;
    }
  }

  @override
  Widget build(BuildContext context) {
    final editable = widget.isCurrentUser;
    return Scaffold(
      backgroundColor: _paper,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final pad = (constraints.maxWidth * .055).clamp(18.0, 34.0);
            return ListView(
              padding: EdgeInsets.fromLTRB(pad, 8, pad, 28),
              children: [
                Row(
                  children: [
                    IconButton(
                      tooltip: 'Back',
                      onPressed: () => Navigator.maybePop(context),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    ),
                    const Text(
                      'Author Profile',
                      style: TextStyle(
                        color: _ink,
                        fontFamily: 'Georgia',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _profileCard(editable),
                const SizedBox(height: 22),
                _sectionTitle('About the Author'),
                const SizedBox(height: 8),
                Text(
                  _profile.about,
                  maxLines: _expanded ? null : 4,
                  overflow: _expanded ? null : TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, height: 1.7),
                ),
                TextButton.icon(
                  onPressed: () => setState(() => _expanded = !_expanded),
                  icon: Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 20,
                  ),
                  label: Text(_expanded ? 'Read less' : 'Read more'),
                  style: TextButton.styleFrom(foregroundColor: _gold),
                ),
                const Divider(color: _line),
                _sectionTitle('Books by ${_profile.name}', fontSize: 11),
                const SizedBox(height: 10),
                LayoutBuilder(
                  builder: (context, box) {
                    final columns = box.maxWidth > 650 ? 3 : 2;
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _profile.books.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 2.35,
                      ),
                      itemBuilder: (context, index) =>
                          _bookTile(_profile.books[index]),
                    );
                  },
                ),
                Center(
                  child: TextButton.icon(
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('All books are shown here.'),
                      ),
                    ),
                    icon: const Icon(Icons.chevron_right),
                    label: Text(
                      'View all books (${_profile.publishedBookCount})',
                    ),
                    style: TextButton.styleFrom(foregroundColor: _gold),
                  ),
                ),
                const Divider(color: _line),
                _sectionTitle('Worked with', fontSize: 11),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _profile.publishers.map(_publisher).toList(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _profileCard(bool editable) => Container(
    padding: const EdgeInsets.all(16),
    decoration: _cardDecoration(),
    child: Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                border: Border.fromBorderSide(
                  BorderSide(color: _gold, width: 2),
                ),
              ),
              child: CircleAvatar(
                radius: 52,
                backgroundColor: _ink,
                backgroundImage: _avatarPath == null
                    ? null
                    : FileImage(File(_avatarPath!)),
                child: _avatarPath == null
                    ? const Icon(Icons.person, color: _gold, size: 65)
                    : null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _profile.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _ink,
                            fontFamily: 'Georgia',
                            fontSize: 25,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (_profile.isWriter)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _gold.withValues(alpha: .18),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Writer',
                            style: TextStyle(
                              color: _ink,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  Text('Author of ${_profile.publishedBookCount} books'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      for (var i = 1; i <= 5; i++)
                        Icon(
                          _profile.rating >= i
                              ? Icons.star
                              : _profile.rating >= i - .5
                              ? Icons.star_half
                              : Icons.star_border,
                          color: _gold,
                          size: 21,
                        ),
                      const SizedBox(width: 8),
                      Text(_profile.rating.toStringAsFixed(2)),
                    ],
                  ),
                  if (_profile.goodreads.isNotEmpty)
                    TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.link, size: 20),
                      label: Text(_profile.goodreads),
                      style: TextButton.styleFrom(
                        foregroundColor: _gold,
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  if (_profile.facebook.isNotEmpty ||
                      _profile.instagram.isNotEmpty ||
                      _profile.website.isNotEmpty)
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        if (_profile.facebook.isNotEmpty)
                          _socialLink(
                            'Facebook',
                            _profile.facebook,
                            Icons.facebook,
                          ),
                        if (_profile.instagram.isNotEmpty)
                          _socialLink(
                            'Instagram',
                            _profile.instagram,
                            Icons.camera_alt_outlined,
                          ),
                        if (_profile.website.isNotEmpty)
                          _socialLink(
                            'Website',
                            _profile.website,
                            Icons.language_rounded,
                          ),
                      ],
                    ),
                  OutlinedButton.icon(
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Messaging coming soon.')),
                    ),
                    icon: const Icon(Icons.chat_bubble_outline, size: 20),
                    label: const Text('Message'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _ink,
                      minimumSize: const Size(180, 40),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 14),
          child: Divider(color: _line, height: 1),
        ),
        Row(
          children: [
            _stat(
              'Published books',
              '${_profile.publishedBookCount}',
              Icons.menu_book_outlined,
            ),
            const SizedBox(height: 62, child: VerticalDivider(color: _line)),
            _stat('Reviews', '${_profile.reviewCount}', Icons.star_border),
            const SizedBox(height: 62, child: VerticalDivider(color: _line)),
            _stat(
              'Followers',
              _formatCount(_profile.followerCount),
              Icons.people_outline,
            ),
          ],
        ),
        if (editable) ...[
          const SizedBox(height: 12),
          Tooltip(
            message: 'Edit profile',
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _editProfile,
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('Edit profile'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _ink,
                  side: const BorderSide(color: _ink),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),
        ],
      ],
    ),
  );

  Widget _stat(String label, String value, IconData icon) => Expanded(
    child: Column(
      children: [
        Icon(icon, color: _ink, size: 29),
        Text(label),
        Text(
          value,
          style: const TextStyle(
            color: _ink,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );

  Widget _sectionTitle(String title, {double fontSize = 21}) => Text(
    title,
    style: const TextStyle(
      color: _ink,
      fontFamily: 'Georgia',
      fontWeight: FontWeight.w600,
    ).copyWith(fontSize: fontSize),
  );

  Widget _bookTile(WriterBook book) => Container(
    decoration: _cardDecoration(),
    clipBehavior: Clip.antiAlias,
    child: Row(
      children: [
        Container(
          width: 44,
          color: _ink,
          child: const Center(
            child: Icon(Icons.menu_book_rounded, color: _gold, size: 29),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(book.title, maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(
                  '${book.rating.toStringAsFixed(1)}  ★★★★★',
                  style: const TextStyle(color: _gold),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );

  Widget _publisher(String name) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
    decoration: _cardDecoration(),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircleAvatar(
          radius: 14,
          backgroundColor: _gold,
          child: Icon(Icons.apartment, size: 16, color: _ink),
        ),
        const SizedBox(width: 7),
        Text(name, style: const TextStyle(fontSize: 12)),
      ],
    ),
  );

  Widget _socialLink(String label, String value, IconData icon) => Tooltip(
    message: value,
    child: Chip(
      avatar: Icon(icon, size: 16, color: _ink),
      label: Text(label, style: const TextStyle(fontSize: 11)),
      visualDensity: VisualDensity.compact,
      side: const BorderSide(color: _line),
      backgroundColor: Colors.white.withValues(alpha: .5),
    ),
  );

  String _formatCount(int count) => count >= 1000
      ? '${(count / 1000).toStringAsFixed(count % 1000 == 0 ? 0 : 1)}K'
      : '$count';

  BoxDecoration _cardDecoration() => BoxDecoration(
    color: _paper,
    border: Border.all(color: const Color(0xFFE9E2D7)),
    borderRadius: BorderRadius.circular(15),
    boxShadow: const [
      BoxShadow(color: Color(0x10000000), blurRadius: 8, offset: Offset(0, 3)),
    ],
  );
}

class _ProfileEditDialog extends StatefulWidget {
  const _ProfileEditDialog({required this.profile, required this.avatarPath});

  final WriterProfile profile;
  final String? avatarPath;

  @override
  State<_ProfileEditDialog> createState() => _ProfileEditDialogState();
}

class _ProfileEditDialogState extends State<_ProfileEditDialog> {
  String? _avatarPath;
  late final _name = TextEditingController(text: widget.profile.name);
  late final _goodreads = TextEditingController(text: widget.profile.goodreads);
  late final _facebook = TextEditingController(text: widget.profile.facebook);
  late final _instagram = TextEditingController(text: widget.profile.instagram);
  late final _website = TextEditingController(text: widget.profile.website);
  late final _about = TextEditingController(text: widget.profile.about);
  late final _publishers = TextEditingController(
    text: widget.profile.publishers.join(', '),
  );

  @override
  void initState() {
    super.initState();
    _avatarPath = widget.avatarPath;
  }

  Future<void> _pickAvatar() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null && mounted) setState(() => _avatarPath = image.path);
  }

  @override
  void dispose() {
    _name.dispose();
    _goodreads.dispose();
    _facebook.dispose();
    _instagram.dispose();
    _website.dispose();
    _about.dispose();
    _publishers.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Dialog(
    backgroundColor: _paper,
    insetPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 28),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 520, maxHeight: 680),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(22, 20, 14, 18),
            decoration: const BoxDecoration(
              color: _ink,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Edit profile',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Close',
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ],
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .55),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _line),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: _ink,
                          backgroundImage: _avatarPath == null
                              ? null
                              : FileImage(File(_avatarPath!)),
                          child: _avatarPath == null
                              ? const Icon(Icons.person, color: _gold, size: 34)
                              : null,
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Profile photo',
                            style: TextStyle(
                              color: _ink,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _pickAvatar,
                          icon: const Icon(Icons.photo_library_outlined),
                          label: const Text('Change'),
                          style: TextButton.styleFrom(foregroundColor: _ink),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _field('Display name', _name, Icons.badge_outlined),
                  const SizedBox(height: 14),
                  _field('Goodreads link', _goodreads, Icons.link_rounded),
                  const SizedBox(height: 14),
                  _field('Facebook link', _facebook, Icons.facebook),
                  const SizedBox(height: 14),
                  _field(
                    'Instagram link',
                    _instagram,
                    Icons.camera_alt_outlined,
                  ),
                  const SizedBox(height: 14),
                  _field('Website link', _website, Icons.language_rounded),
                  const SizedBox(height: 14),
                  _field(
                    'About the author',
                    _about,
                    Icons.edit_note_rounded,
                    maxLines: 5,
                  ),
                  const SizedBox(height: 14),
                  _field(
                    'Worked with',
                    _publishers,
                    Icons.apartment_rounded,
                    helperText: 'Separate publisher names with commas.',
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 10, 22, 20),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _ink,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      side: const BorderSide(color: _line),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => Navigator.pop(
                      context,
                      _ProfileEditResult(
                        WriterProfile(
                          name: _name.text.trim().isEmpty
                              ? widget.profile.name
                              : _name.text.trim(),
                          goodreads: _goodreads.text.trim(),
                          facebook: _facebook.text.trim(),
                          instagram: _instagram.text.trim(),
                          website: _website.text.trim(),
                          about: _about.text.trim(),
                          isWriter: widget.profile.isWriter,
                          books: widget.profile.books,
                          followerIds: widget.profile.followerIds,
                          publishers: _publishers.text
                              .split(',')
                              .map((name) => name.trim())
                              .where((name) => name.isNotEmpty)
                              .toList(),
                        ),
                        _avatarPath,
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: _ink,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                    icon: const Icon(Icons.check_rounded, size: 19),
                    label: const Text('Save changes'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  Widget _field(
    String label,
    TextEditingController controller,
    IconData icon, {
    int maxLines = 1,
    String? helperText,
  }) => TextField(
    controller: controller,
    maxLines: maxLines,
    minLines: maxLines == 1 ? 1 : 3,
    textCapitalization: TextCapitalization.sentences,
    decoration: InputDecoration(
      labelText: label,
      helperText: helperText,
      prefixIcon: Icon(icon, color: _ink),
      filled: true,
      fillColor: Colors.white.withValues(alpha: .62),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: _line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: _line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: _ink, width: 1.5),
      ),
    ),
  );
}
