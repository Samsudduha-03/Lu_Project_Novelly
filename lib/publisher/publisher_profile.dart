import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../logout_confirmation.dart';
import '../Splash,login,register/login.dart';
import '../chat/direct_chat.dart';
import '../main_page/writer_profile.dart';

const Color _ink = Color(0xFF173B43);
const Color _gold = Color(0xFFC89543);
const Color _muted = Color(0xFF777873);
const Color _paper = Color(0xFFF4F0E7);
const Color _line = Color(0xFFDDD5C7);
const Color _card = Color(0xFFFFFCF6);

@immutable
class PublisherProfile {
  const PublisherProfile({
    required this.name,
    this.accountId = '',
    this.publishedBookCount = 0,
    this.imagePath,
    this.writersWorkedWith = const [],
    this.books = const [],
    this.description = '',
    this.genresPublished = '',
    this.bookFairParticipation = '',
    this.publishingModel = '',
    this.printOnDemand = '',
    this.manuscriptSubmissionGuidelines = '',
    this.manuscriptFeedbackTime = '',
    this.averageBookPublishingTime = '',
    this.inHouseEditorialTeam = '',
    this.isbnSupport = '',
    this.authorRoyaltyTerms = '',
    this.royaltyModel = '',
    this.salesReportsForAuthors = '',
    this.complimentaryCopies = '',
    this.contractDuration = '',
  });

  factory PublisherProfile.preview({
    required String name,
    required int publishedBookCount,
    String accountId = '',
    String? imagePath,
  }) => PublisherProfile(
    name: name,
    accountId: accountId,
    publishedBookCount: publishedBookCount,
    imagePath: imagePath,
  );

  final String name;
  final String accountId;
  final int publishedBookCount;
  final String? imagePath;
  final List<String> writersWorkedWith;
  final List<PublisherBook> books;
  final String description;
  final String genresPublished;
  final String bookFairParticipation;
  final String publishingModel;
  final String printOnDemand;
  final String manuscriptSubmissionGuidelines;
  final String manuscriptFeedbackTime;
  final String averageBookPublishingTime;
  final String inHouseEditorialTeam;
  final String isbnSupport;
  final String authorRoyaltyTerms;
  final String royaltyModel;
  final String salesReportsForAuthors;
  final String complimentaryCopies;
  final String contractDuration;

  PublisherProfile withPublicationData({
    required List<String> writersWorkedWith,
    required List<PublisherBook> books,
  }) => PublisherProfile(
    name: name,
    accountId: accountId,
    publishedBookCount: books.length,
    imagePath: imagePath,
    writersWorkedWith: List.unmodifiable(writersWorkedWith),
    books: List.unmodifiable(books),
    description: description,
    genresPublished: genresPublished,
    bookFairParticipation: bookFairParticipation,
    publishingModel: publishingModel,
    printOnDemand: printOnDemand,
    manuscriptSubmissionGuidelines: manuscriptSubmissionGuidelines,
    manuscriptFeedbackTime: manuscriptFeedbackTime,
    averageBookPublishingTime: averageBookPublishingTime,
    inHouseEditorialTeam: inHouseEditorialTeam,
    isbnSupport: isbnSupport,
    authorRoyaltyTerms: authorRoyaltyTerms,
    royaltyModel: royaltyModel,
    salesReportsForAuthors: salesReportsForAuthors,
    complimentaryCopies: complimentaryCopies,
    contractDuration: contractDuration,
  );
}

@immutable
class PublisherBook {
  const PublisherBook({
    required this.title,
    required this.year,
    this.author = '',
  });

  final String title;
  final String year;
  final String author;
}

class PublisherProfileScreen extends StatefulWidget {
  static PublisherProfile? currentUser;

  const PublisherProfileScreen({
    this.profile,
    this.isCurrentUser = false,
    super.key,
  });

  final PublisherProfile? profile;
  final bool isCurrentUser;

  @override
  State<PublisherProfileScreen> createState() => _PublisherProfileScreenState();
}

class _PublisherProfileScreenState extends State<PublisherProfileScreen> {
  late PublisherProfile _profile = widget.isCurrentUser
      ? PublisherProfileScreen.currentUser ??
            widget.profile ??
            PublisherProfile(
              name: WriterProfileScreen.currentUser.name,
              accountId: WriterProfileScreen.currentUser.accountId,
              publishedBookCount:
                  WriterProfileScreen.currentUser.publishedBookCount,
            )
      : widget.profile ?? const PublisherProfile(name: 'Publisher');
  bool _expanded = false;

  Future<void> _editProfile() async {
    final result = await showDialog<PublisherProfile>(
      context: context,
      builder: (_) => _PublisherProfileEditDialog(profile: _profile),
    );
    if (result == null || !mounted) return;
    setState(() => _profile = result);
    if (widget.isCurrentUser) PublisherProfileScreen.currentUser = result;
  }

  Future<void> _confirmLogout() async {
    final shouldLogout = await showLogoutConfirmationDialog(context);
    if (shouldLogout != true || !mounted) return;

    WriterProfileScreen.currentUser = const WriterProfile(name: 'Your profile');
    WriterProfileScreen.currentAvatarPath = null;
    PublisherProfileScreen.currentUser = null;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final editable = widget.isCurrentUser;
    return Scaffold(
      backgroundColor: _paper,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFFCF7), Color(0xFFF8F4EB), _paper],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final mobile = constraints.maxWidth < 600;
              final horizontalPadding = (constraints.maxWidth * .07).clamp(
                20.0,
                48.0,
              );
              return ListView(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  10,
                  horizontalPadding,
                  30,
                ),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _RoundButton(
                        tooltip: 'Back',
                        icon: Icons.arrow_back_rounded,
                        onPressed: () => Navigator.maybePop(context),
                      ),
                      if (editable)
                        LogoutButton(onPressed: _confirmLogout)
                      else
                        const SizedBox(width: 42),
                    ],
                  ),
                  SizedBox(height: mobile ? 18 : 26),
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 900),
                      child: _profileHeader(mobile, editable),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 900),
                      child: _descriptionSection(),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 900),
                      child: _writersSection(),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 900),
                      child: _booksSection(),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _profileHeader(bool mobile, bool editable) {
    final imageSize = mobile ? 116.0 : 178.0;
    final image = _PublisherImage(path: _profile.imagePath, size: imageSize);
    final details = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _profile.name.trim().isEmpty ? 'Publisher' : _profile.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: _ink,
            fontFamily: 'Georgia',
            fontSize: mobile ? 27 : 36,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          '${_profile.publishedBookCount} books published',
          style: TextStyle(color: _muted, fontSize: mobile ? 15 : 17),
        ),
        const SizedBox(height: 15),
        if (editable)
          FilledButton.icon(
            onPressed: _editProfile,
            icon: const Icon(Icons.edit_outlined, size: 19),
            label: const Text('Edit Profile'),
            style: FilledButton.styleFrom(
              backgroundColor: _gold,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 19, vertical: 13),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          )
        else
          FilledButton.icon(
            onPressed: () => openDirectChat(
              context,
              userId: _profile.accountId,
              userName: _profile.name,
              avatarPath: _profile.imagePath,
            ),
            icon: const Icon(Icons.chat_bubble_outline, size: 19),
            label: const Text('Message'),
            style: FilledButton.styleFrom(
              backgroundColor: _gold,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 19, vertical: 13),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
      ],
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        image,
        SizedBox(width: mobile ? 18 : 26),
        Expanded(child: details),
      ],
    );
  }

  Widget _descriptionSection() {
    final description = _profile.description.trim();
    final genres = _profile.genresPublished.trim();
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 19, 22, 13),
      decoration: BoxDecoration(
        color: _card.withValues(alpha: .78),
        border: Border.all(color: const Color(0xFFEDE4D7)),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Description',
            style: TextStyle(
              color: _ink,
              fontFamily: 'Georgia',
              fontSize: 21,
              fontWeight: FontWeight.w600,
            ),
          ),
          Container(
            width: 25,
            height: 2,
            margin: const EdgeInsets.only(top: 8, bottom: 12),
            color: _gold,
          ),
          Text(
            description.isEmpty ? 'Not specified' : description,
            style: const TextStyle(color: _muted, height: 1.5, fontSize: 15),
          ),
          if (genres.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 13),
              child: Divider(height: 1, color: Color(0xFFF0EADF)),
            ),
            Text(
              'Publishes: $genres',
              style: const TextStyle(color: _muted, height: 1.45, fontSize: 14),
            ),
          ],
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: _expanded
                ? Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 7),
                        child: Divider(height: 1, color: Color(0xFFF0EADF)),
                      ),
                      _detailRow('Genres Published', _profile.genresPublished),
                      _detailRow(
                        'Book Fair Participation',
                        _profile.bookFairParticipation,
                      ),
                      _detailRow('Publishing Model', _profile.publishingModel),
                      _detailRow('Print-on-Demand', _profile.printOnDemand),
                      _detailRow(
                        'Manuscript Submission Guidelines',
                        _profile.manuscriptSubmissionGuidelines,
                      ),
                      _detailRow(
                        'Manuscript Feedback Time',
                        _profile.manuscriptFeedbackTime,
                      ),
                      _detailRow(
                        'Average Book Publishing Time',
                        _profile.averageBookPublishingTime,
                      ),
                      _detailRow(
                        'In-house Editorial Team',
                        _profile.inHouseEditorialTeam,
                      ),
                      _detailRow('ISBN Support', _profile.isbnSupport),
                      _detailRow(
                        'Author Royalty Percentage or Terms',
                        _profile.authorRoyaltyTerms,
                      ),
                      _detailRow('Royalty Model', _profile.royaltyModel),
                      _detailRow(
                        'Sales Reports for Authors',
                        _profile.salesReportsForAuthors,
                      ),
                      _detailRow(
                        'Complimentary Copies',
                        _profile.complimentaryCopies,
                      ),
                      _detailRow(
                        'Contract Duration',
                        _profile.contractDuration,
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () => setState(() => _expanded = !_expanded),
              style: TextButton.styleFrom(
                foregroundColor: _gold,
                padding: const EdgeInsets.symmetric(vertical: 10),
                visualDensity: VisualDensity.compact,
              ),
              child: Text(
                _expanded ? 'See less ↑' : 'See more →',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: _ink,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value.trim().isEmpty ? 'Not specified' : value,
              style: const TextStyle(color: _muted, height: 1.45, fontSize: 14),
            ),
          ],
        ),
      ),
      const Divider(height: 1, color: Color(0xFFF0EADF)),
    ],
  );

  Widget _profileSection({required Widget child}) => Container(
    padding: const EdgeInsets.all(19),
    decoration: BoxDecoration(
      color: _card.withValues(alpha: .78),
      border: Border.all(color: const Color(0xFFEDE4D7)),
      borderRadius: BorderRadius.circular(18),
    ),
    child: child,
  );

  Widget _writersSection() => _profileSection(
    child: Row(
      children: [
        Container(
          width: 54,
          height: 54,
          decoration: const BoxDecoration(
            color: Color(0xFFF7EFE3),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.edit_note_rounded, color: _gold, size: 31),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Writer worked with',
                style: TextStyle(
                  color: _ink,
                  fontFamily: 'Georgia',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 9),
              Wrap(
                spacing: 7,
                runSpacing: 7,
                children: _profile.writersWorkedWith.take(5).map((writer) {
                  return SizedBox(
                    width: 48,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: const Color(0xFFE8D8C1),
                          child: Text(
                            _initials(writer),
                            style: const TextStyle(
                              color: _ink,
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 3),
                        SizedBox(
                          height: 26,
                          child: Text(
                            writer,
                            maxLines: 2,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: _ink,
                              fontSize: 9,
                              height: 1.1,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        if (_profile.writersWorkedWith.length > 5)
          TextButton(
            onPressed: () => _showAllWriters(context),
            style: TextButton.styleFrom(foregroundColor: _gold),
            child: const Text('See more  ›'),
          ),
      ],
    ),
  );

  Widget _booksSection() => _profileSection(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Books',
                style: TextStyle(
                  color: _ink,
                  fontFamily: 'Georgia',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              '${_profile.books.length} titles',
              style: const TextStyle(color: _muted, fontSize: 13),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (_profile.books.isEmpty)
          const Text(
            'No books listed yet.',
            style: TextStyle(color: _muted, fontSize: 14),
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _profile.books.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: .66,
                ),
                itemBuilder: (context, index) => _PublisherBookTile(
                  book: _profile.books[index],
                  index: index,
                ),
              );
            },
          ),
      ],
    ),
  );

  String _initials(String name) {
    final words = name.trim().split(RegExp(r'\s+'));
    if (words.length > 1) return '${words.first[0]}${words.last[0]}';
    return words.first.isEmpty ? '?' : words.first[0];
  }

  Future<void> _showAllWriters(BuildContext context) => showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: _paper,
      title: const Text('Writers worked with'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _profile.writersWorkedWith
            .map(
              (writer) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Text(writer, style: const TextStyle(color: _ink)),
              ),
            )
            .toList(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}

class _PublisherBookTile extends StatelessWidget {
  const _PublisherBookTile({required this.book, required this.index});

  final PublisherBook book;
  final int index;

  static const _coverColors = [
    Color(0xFFEEDCC2),
    Color(0xFFD9D8B9),
    Color(0xFF173B43),
    Color(0xFFE9D0A8),
  ];

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: _coverColors[index % _coverColors.length],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Icon(
              Icons.menu_book_rounded,
              color: index % _coverColors.length == 2 ? _gold : _ink,
              size: 34,
            ),
          ),
        ),
      ),
      const SizedBox(height: 7),
      Text(
        book.title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: _ink,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
      if (book.author.trim().isNotEmpty) ...[
        const SizedBox(height: 3),
        Text(
          book.author,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: _muted, fontSize: 11),
        ),
      ],
      const SizedBox(height: 3),
      Text(book.year, style: const TextStyle(color: _muted, fontSize: 12)),
    ],
  );
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: tooltip,
    onPressed: onPressed,
    icon: Icon(icon, color: _ink, size: 21),
    style: IconButton.styleFrom(
      backgroundColor: const Color(0xFFF7F0E6),
      minimumSize: const Size(42, 42),
    ),
  );
}

class _PublisherImage extends StatelessWidget {
  const _PublisherImage({required this.path, required this.size});

  final String? path;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size * 1.24,
    decoration: BoxDecoration(
      color: const Color(0xFFFAF5EC),
      border: Border.all(color: const Color(0xFFE2CEB3)),
      borderRadius: BorderRadius.circular(19),
      image: path == null
          ? null
          : DecorationImage(image: FileImage(File(path!)), fit: BoxFit.cover),
    ),
    child: path == null
        ? const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.apartment_outlined, color: _gold, size: 39),
              SizedBox(height: 8),
              Text('Publisher', style: TextStyle(color: _ink, fontSize: 13)),
            ],
          )
        : null,
  );
}

class _PublisherProfileEditDialog extends StatefulWidget {
  const _PublisherProfileEditDialog({required this.profile});

  final PublisherProfile profile;

  @override
  State<_PublisherProfileEditDialog> createState() =>
      _PublisherProfileEditDialogState();
}

class _PublisherProfileEditDialogState
    extends State<_PublisherProfileEditDialog> {
  late final _name = TextEditingController(text: widget.profile.name);
  late final _description = TextEditingController(
    text: widget.profile.description,
  );
  late final _genres = TextEditingController(
    text: widget.profile.genresPublished,
  );
  late final _guidelines = TextEditingController(
    text: widget.profile.manuscriptSubmissionGuidelines,
  );
  late final _feedbackTime = TextEditingController(
    text: widget.profile.manuscriptFeedbackTime,
  );
  late final _publishingTime = TextEditingController(
    text: widget.profile.averageBookPublishingTime,
  );
  late final _royaltyTerms = TextEditingController(
    text: widget.profile.authorRoyaltyTerms,
  );
  late final _contractDuration = TextEditingController(
    text: widget.profile.contractDuration,
  );
  late String _bookFairParticipation = widget.profile.bookFairParticipation;
  late String _publishingModel = widget.profile.publishingModel;
  late String _printOnDemand = widget.profile.printOnDemand;
  late String _editorialTeam = widget.profile.inHouseEditorialTeam;
  late String _isbnSupport = widget.profile.isbnSupport;
  late String _royaltyModel = widget.profile.royaltyModel;
  late String _salesReports = widget.profile.salesReportsForAuthors;
  late String _complimentaryCopies = widget.profile.complimentaryCopies;
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    _imagePath = widget.profile.imagePath;
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _genres.dispose();
    _guidelines.dispose();
    _feedbackTime.dispose();
    _publishingTime.dispose();
    _royaltyTerms.dispose();
    _contractDuration.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null && mounted) setState(() => _imagePath = image.path);
  }

  @override
  Widget build(BuildContext context) => Dialog(
    backgroundColor: _paper,
    insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
    child: ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: 540,
        maxHeight: MediaQuery.sizeOf(context).height * .88,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(22, 16, 12, 16),
            decoration: const BoxDecoration(
              color: _ink,
              borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Edit Profile',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
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
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFAF5EC),
                          border: Border.all(color: const Color(0xFFE2CEB3)),
                          shape: BoxShape.circle,
                          image: _imagePath == null
                              ? null
                              : DecorationImage(
                                  image: FileImage(File(_imagePath!)),
                                  fit: BoxFit.cover,
                                ),
                        ),
                        child: _imagePath == null
                            ? const Icon(Icons.apartment_outlined, color: _gold)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Publisher image',
                          style: const TextStyle(
                            color: _ink,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.photo_library_outlined),
                        label: const Text('Change'),
                        style: TextButton.styleFrom(foregroundColor: _ink),
                      ),
                    ],
                  ),
                  const SizedBox(height: 17),
                  _textField('Publisher name', _name),
                  const SizedBox(height: 13),
                  _textField(
                    'Description',
                    _description,
                    maxLines: 4,
                    helperText:
                        'Introduce your publishing house and the books you publish.',
                  ),
                  const SizedBox(height: 13),
                  _textField('Genres Published', _genres),
                  const SizedBox(height: 13),
                  _choiceField(
                    'Book Fair Participation',
                    _bookFairParticipation,
                    const ['Yes', 'No'],
                    (value) => _bookFairParticipation = value,
                  ),
                  const SizedBox(height: 13),
                  _choiceField(
                    'Publishing Model',
                    _publishingModel,
                    const ['Self-publishing', 'Traditional', 'Hybrid'],
                    (value) => _publishingModel = value,
                  ),
                  const SizedBox(height: 13),
                  _choiceField(
                    'Print-on-Demand',
                    _printOnDemand,
                    const ['Yes', 'No'],
                    (value) => _printOnDemand = value,
                  ),
                  const SizedBox(height: 13),
                  _textField(
                    'Manuscript Submission Guidelines',
                    _guidelines,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 13),
                  _textField('Manuscript Feedback Time', _feedbackTime),
                  const SizedBox(height: 13),
                  _textField('Average Book Publishing Time', _publishingTime),
                  const SizedBox(height: 13),
                  _choiceField(
                    'In-house Editorial Team',
                    _editorialTeam,
                    const ['Yes', 'No'],
                    (value) => _editorialTeam = value,
                  ),
                  const SizedBox(height: 13),
                  _choiceField('ISBN Support', _isbnSupport, const [
                    'Yes',
                    'No',
                  ], (value) => _isbnSupport = value),
                  const SizedBox(height: 13),
                  _textField(
                    'Author Royalty Percentage or Terms',
                    _royaltyTerms,
                    helperText: 'For example, a percentage or contract terms.',
                  ),
                  const SizedBox(height: 13),
                  _choiceField('Royalty Model', _royaltyModel, const [
                    'Prepaid',
                    'Postpaid',
                    'Both',
                  ], (value) => _royaltyModel = value),
                  const SizedBox(height: 13),
                  _choiceField(
                    'Sales Reports for Authors',
                    _salesReports,
                    const ['Yes', 'No'],
                    (value) => _salesReports = value,
                  ),
                  const SizedBox(height: 13),
                  _choiceField(
                    'Complimentary Copies',
                    _complimentaryCopies,
                    const ['Yes', 'No'],
                    (value) => _complimentaryCopies = value,
                  ),
                  const SizedBox(height: 13),
                  _textField('Contract Duration', _contractDuration),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _ink,
                      side: const BorderSide(color: _line),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.pop(
                      context,
                      PublisherProfile(
                        name: _name.text.trim().isEmpty
                            ? widget.profile.name
                            : _name.text.trim(),
                        accountId: widget.profile.accountId,
                        publishedBookCount: widget.profile.publishedBookCount,
                        imagePath: _imagePath,
                        writersWorkedWith: widget.profile.writersWorkedWith,
                        books: widget.profile.books,
                        description: _description.text.trim(),
                        genresPublished: _genres.text.trim(),
                        bookFairParticipation: _bookFairParticipation,
                        publishingModel: _publishingModel,
                        printOnDemand: _printOnDemand,
                        manuscriptSubmissionGuidelines: _guidelines.text.trim(),
                        manuscriptFeedbackTime: _feedbackTime.text.trim(),
                        averageBookPublishingTime: _publishingTime.text.trim(),
                        inHouseEditorialTeam: _editorialTeam,
                        isbnSupport: _isbnSupport,
                        authorRoyaltyTerms: _royaltyTerms.text.trim(),
                        royaltyModel: _royaltyModel,
                        salesReportsForAuthors: _salesReports,
                        complimentaryCopies: _complimentaryCopies,
                        contractDuration: _contractDuration.text.trim(),
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: _gold,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Save changes'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  Widget _textField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
    String? helperText,
  }) => TextField(
    controller: controller,
    maxLines: maxLines,
    minLines: maxLines == 1 ? 1 : 3,
    textCapitalization: TextCapitalization.sentences,
    decoration: _inputDecoration(label, helperText: helperText),
  );

  Widget _choiceField(
    String label,
    String value,
    List<String> choices,
    ValueChanged<String> onChanged,
  ) {
    final options = [
      '',
      if (value.isNotEmpty && !choices.contains(value)) value,
      ...choices,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 5),
          child: Text(
            label,
            style: const TextStyle(
              color: _ink,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        DropdownButtonFormField<String>(
          initialValue: value,
          decoration: _inputDecoration(label, showHint: false),
          items: options
              .map(
                (option) => DropdownMenuItem(
                  value: option,
                  child: Text(option.isEmpty ? 'Not specified' : option),
                ),
              )
              .toList(),
          onChanged: (selection) {
            if (selection != null) setState(() => onChanged(selection));
          },
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(
    String label, {
    String? helperText,
    bool showHint = true,
  }) => InputDecoration(
    hintText: showHint ? label : null,
    helperText: helperText,
    filled: true,
    fillColor: const Color(0xFFFFFCF6),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: _line),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: _line),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: _ink, width: 1.4),
    ),
  );
}
