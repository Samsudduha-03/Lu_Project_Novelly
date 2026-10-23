import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../logout_confirmation.dart';
import '../Splash,login,register/login.dart';
import '../chat/direct_chat.dart';
import '../chat/chat_list.dart';
import '../main_page/discover.dart';
import '../main_page/discover_book.dart';
import '../main_page/my_book.dart';
import '../main_page/novelly_bottom_navigation.dart';
import '../main_page/writer_profile.dart';
import '../publisher/publisher_dashboard.dart';
import '../publisher/publisher._directory.dart';
import '../publisher/publisher_profile.dart';
import 'cover_design.dart';
import 'my_designs.dart';

const _ink = Color(0xFF173B43);
const _gold = Color(0xFFC89543);
const _muted = Color(0xFF777873);
const _line = Color(0xFFDDD5C7);
const _paper = Color(0xFFF4F0E7);
const _card = Color(0xFFFFFCF6);

class CoverArtistProfileScreen extends StatefulWidget {
  const CoverArtistProfileScreen({
    this.profile,
    this.covers = const [],
    this.drafts = const [],
    this.books = const [],
    this.publishers = const [],
    this.coverArtists = const [],
    this.isCurrentUser = false,
    super.key,
  });

  final WriterProfile? profile;
  final List<CoverDesign> covers;
  final List<CoverDesign> drafts;
  final List<DiscoverBook> books;
  final List<PublisherEntry> publishers;
  final List<WriterProfile> coverArtists;
  final bool isCurrentUser;

  @override
  State<CoverArtistProfileScreen> createState() =>
      _CoverArtistProfileScreenState();
}

class _CoverArtistProfileScreenState extends State<CoverArtistProfileScreen> {
  String? _avatarPath;
  late final CoverArtistWorkspace _workspace;
  bool _descriptionExpanded = false;

  bool get _isOwnProfile =>
      widget.isCurrentUser &&
      WriterProfileScreen.currentUser.isCoverArtist &&
      (widget.profile == null ||
          (widget.profile!.accountId.isNotEmpty
              ? widget.profile!.accountId ==
                    WriterProfileScreen.currentUser.accountId
              : widget.profile!.name == WriterProfileScreen.currentUser.name));

  WriterProfile get _profile => _isOwnProfile
      ? WriterProfileScreen.currentUser
      : widget.profile ?? const WriterProfile(name: 'Cover Artist');

  List<CoverDesign> get _covers =>
      _isOwnProfile ? _workspace.covers : widget.covers;

  @override
  void initState() {
    super.initState();
    _workspace = CoverArtistWorkspace.forAccount(
      WriterProfileScreen.currentUser.accountId,
      initialCovers: widget.covers,
      initialDrafts: widget.drafts,
    );
    _avatarPath = _isOwnProfile
        ? WriterProfileScreen.currentAvatarPath ??
              WriterProfileScreen.currentUser.profileImagePath
        : widget.profile?.profileImagePath;
  }

  Future<void> _editProfile() async {
    final result = await showDialog<_CoverArtistEditResult>(
      context: context,
      builder: (_) => _CoverArtistProfileEditDialog(
        profile: _profile,
        avatarPath: _avatarPath,
      ),
    );
    if (result == null || !mounted) return;
    WriterProfileScreen.currentUser = result.profile;
    WriterProfileScreen.currentAvatarPath = result.avatarPath;
    setState(() => _avatarPath = result.avatarPath);
  }

  void _openDesigns() {
    Navigator.of(context)
        .push(
          MaterialPageRoute<void>(
            builder: (_) => MyDesignsScreen(
              covers: List.unmodifiable(_workspace.covers),
              drafts: List.unmodifiable(_workspace.drafts),
            ),
          ),
        )
        .then((_) {
          if (mounted) setState(() {});
        });
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

  void _navigate(NovellyNavigationDestination destination) {
    switch (destination) {
      case NovellyNavigationDestination.discover:
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => DiscoverScreen(
              books: widget.books,
              publishers: widget.publishers,
              coverArtists: widget.coverArtists,
              coverDesigns: List.unmodifiable(_covers),
              coverDrafts: List.unmodifiable(_workspace.drafts),
            ),
          ),
        );
        break;
      case NovellyNavigationDestination.library:
        final account = WriterProfileScreen.currentUser;
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => account.isCoverArtist
                ? MyDesignsScreen(
                    covers: List.unmodifiable(_workspace.covers),
                    drafts: List.unmodifiable(_workspace.drafts),
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
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final account = WriterProfileScreen.currentUser;
    final profile = _profile;
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
              final padding = (constraints.maxWidth * .05).clamp(16.0, 38.0);
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 860),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(padding, 8, padding, 10),
                    child: Column(
                      children: [
                        Expanded(
                          child: ListView(
                            padding: EdgeInsets.zero,
                            children: [
                              _topBar(_isOwnProfile),
                              SizedBox(height: compact ? 20 : 26),
                              _profileHeader(profile, compact),
                              const SizedBox(height: 20),
                              _metrics(compact),
                              const SizedBox(height: 18),
                              _actions(compact),
                              const SizedBox(height: 17),
                              _description(profile, compact),
                              const SizedBox(height: 17),
                              const Divider(color: _line, height: 1),
                              const SizedBox(height: 16),
                              _sectionHeader(
                                _isOwnProfile ? 'My Covers' : 'Covers',
                                compact,
                              ),
                              const SizedBox(height: 10),
                              _coverGallery(_covers, compact),
                              const SizedBox(height: 18),
                              const Divider(color: _line, height: 1),
                              const SizedBox(height: 16),
                              _sectionHeader('Publishers Worked With', compact),
                              const SizedBox(height: 10),
                              _publisherGallery(widget.publishers, compact),
                              const SizedBox(height: 12),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        NovellyBottomNavigation(
                          libraryLabel: account.isCoverArtist
                              ? 'My Designs'
                              : account.isPublisher
                              ? 'My Publishing'
                              : 'My Book',
                          libraryIcon: account.isCoverArtist
                              ? Icons.palette_outlined
                              : Icons.menu_book_outlined,
                          selectedDestination:
                              NovellyNavigationDestination.profile,
                          compact: compact,
                          onDestinationSelected: _navigate,
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

  Widget _topBar(bool isOwnProfile) => Row(
    children: [
      IconButton(
        tooltip: 'Back',
        onPressed: () => Navigator.of(context).maybePop(),
        icon: const Icon(Icons.arrow_back, color: _ink),
      ),
      const Spacer(),
      if (isOwnProfile) LogoutButton(onPressed: _confirmLogout),
    ],
  );

  Widget _profileHeader(WriterProfile profile, bool compact) => Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      SizedBox(
        width: compact ? 82 : 108,
        height: compact ? 82 : 108,
        child: CircleAvatar(
          radius: compact ? 41 : 54,
          backgroundColor: const Color(0xFFEFE6D8),
          backgroundImage: _avatarPath == null
              ? null
              : FileImage(File(_avatarPath!)),
          child: _avatarPath == null
              ? Icon(
                  Icons.person,
                  color: const Color(0xFFAAA79D),
                  size: compact ? 51 : 68,
                )
              : null,
        ),
      ),
      SizedBox(width: compact ? 17 : 24),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Flexible(
                  child: Text(
                    profile.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: _ink,
                      fontSize: compact ? 18 : 23,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Cover Artist',
              style: TextStyle(color: _muted, fontSize: compact ? 14 : 17),
            ),
          ],
        ),
      ),
    ],
  );

  Widget _metrics(bool compact) => Row(
    children: [
      _metric('—', 'Covers', compact),
      _metricDivider(),
      _metric('—', 'Publishers', compact),
      _metricDivider(),
      _metric('—', 'Years on Novelly', compact),
    ],
  );

  Widget _metric(String value, String label, bool compact) => Expanded(
    child: Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: _ink,
            fontSize: compact ? 16 : 19,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(color: _muted, fontSize: compact ? 10 : 13),
        ),
      ],
    ),
  );

  Widget _metricDivider() => Container(
    width: 1,
    height: 30,
    color: _line,
    margin: const EdgeInsets.symmetric(horizontal: 6),
  );

  Widget _description(WriterProfile profile, bool compact) {
    final description = profile.about.trim().isEmpty
        ? _isOwnProfile
              ? 'Add a short introduction about yourself and your creative approach.'
              : 'No artist introduction provided.'
        : profile.about;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About the Artist',
          style: TextStyle(
            color: _ink,
            fontSize: compact ? 15 : 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 7),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.topCenter,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                description,
                maxLines: _descriptionExpanded ? null : 3,
                overflow: _descriptionExpanded
                    ? TextOverflow.visible
                    : TextOverflow.ellipsis,
                style: TextStyle(
                  color: profile.about.trim().isEmpty ? _muted : _ink,
                  fontSize: compact ? 14 : 16,
                  height: 1.55,
                ),
              ),
              if (_descriptionExpanded) ...[
                const SizedBox(height: 14),
                _artistDetails(profile, compact),
              ],
            ],
          ),
        ),
        TextButton(
          onPressed: () =>
              setState(() => _descriptionExpanded = !_descriptionExpanded),
          style: TextButton.styleFrom(
            foregroundColor: _gold,
            padding: const EdgeInsets.symmetric(vertical: 6),
            visualDensity: VisualDensity.compact,
          ),
          child: Text(_descriptionExpanded ? 'See less' : 'See more'),
        ),
      ],
    );
  }

  Widget _artistDetails(WriterProfile profile, bool compact) {
    const details = [
      'Design Specialization',
      'Art Style',
      'Services Offered',
      'Years of Experience',
      'Design Tools',
      'Work Availability',
      'Custom Design Requests',
      'Pricing & Packages',
      'Average Delivery Time',
      'Revision Policy',
    ];
    final values = <String>[
      profile.designSpecialization,
      profile.artStyle,
      profile.servicesOffered,
      profile.yearsOfExperience,
      profile.designTools,
      profile.workAvailability,
      profile.acceptsCustomRequests,
      profile.pricingPackages,
      profile.averageDeliveryTime,
      profile.revisionPolicy,
    ];
    final hasDetails = values.any((value) => value.trim().isNotEmpty);
    if (!hasDetails && !_isOwnProfile) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: _card.withValues(alpha: .7),
        border: Border.all(color: _line),
        borderRadius: BorderRadius.circular(14),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 13 : 17,
        vertical: compact ? 10 : 14,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var index = 0; index < details.length; index++) ...[
            if (index > 0) const Divider(height: 15, color: _line),
            _artistDetailRow(
              details[index],
              values[index].trim().isEmpty
                  ? _isOwnProfile
                        ? 'Add this information to your profile.'
                        : 'Not specified'
                  : values[index],
              compact,
              muted: values[index].trim().isEmpty,
            ),
          ],
        ],
      ),
    );
  }

  Widget _artistDetailRow(
    String label,
    String value,
    bool compact, {
    required bool muted,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(
          color: _ink,
          fontSize: compact ? 12 : 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(height: 3),
      Text(
        value,
        style: TextStyle(
          color: muted ? _muted : _ink,
          fontSize: compact ? 12 : 14,
          height: 1.4,
        ),
      ),
    ],
  );

  Widget _actions(bool compact) => Row(
    children: [
      Expanded(
        child: _isOwnProfile
            ? OutlinedButton.icon(
                onPressed: _editProfile,
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('Edit Profile'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _ink,
                  side: const BorderSide(color: _line),
                  padding: EdgeInsets.symmetric(vertical: compact ? 12 : 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9),
                  ),
                ),
              )
            : FilledButton(
                onPressed: () => openDirectChat(
                  context,
                  userId: _profile.accountId,
                  userName: _profile.name,
                  avatarPath: _avatarPath,
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: _gold,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: compact ? 12 : 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9),
                  ),
                ),
                child: const Text('Message'),
              ),
      ),
      if (_isOwnProfile) ...[
        const SizedBox(width: 9),
        Expanded(
          child: FilledButton(
            onPressed: _openDesigns,
            style: FilledButton.styleFrom(
              backgroundColor: _gold,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: compact ? 12 : 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9),
              ),
            ),
            child: const Text('My Designs'),
          ),
        ),
      ],
    ],
  );

  Widget _sectionHeader(String title, bool compact) => Row(
    children: [
      Expanded(
        child: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: _ink,
            fontSize: compact ? 15 : 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      TextButton(
        onPressed: title == 'My Covers' && _isOwnProfile
            ? _openDesigns
            : title == 'Covers'
            ? () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => DiscoverScreen(
                    books: widget.books,
                    publishers: widget.publishers,
                    coverArtists: widget.coverArtists,
                    coverDesigns: _covers,
                    coverDrafts: List.unmodifiable(_workspace.drafts),
                    initialTab: 2,
                  ),
                ),
              )
            : null,
        style: TextButton.styleFrom(
          foregroundColor: _gold,
          padding: EdgeInsets.zero,
          minimumSize: const Size(40, 32),
        ),
        child: const Text('See all'),
      ),
    ],
  );

  Widget _emptySection(String message, IconData icon, bool compact) =>
      Container(
        height: compact ? 92 : 118,
        decoration: BoxDecoration(
          color: _card.withValues(alpha: .48),
          border: Border.all(color: _line.withValues(alpha: .7)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: const Color(0xFFC9BDA8), size: 22),
              const SizedBox(width: 9),
              Text(message, style: const TextStyle(color: _muted)),
            ],
          ),
        ),
      );

  Widget _coverGallery(List<CoverDesign> covers, bool compact) {
    if (covers.isEmpty) {
      return _emptySection('No covers yet', Icons.palette_outlined, compact);
    }
    return SizedBox(
      height: compact ? 125 : 160,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: covers.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final cover = covers[index];
          return SizedBox(
            width: compact ? 82 : 110,
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: _card,
                      border: Border.all(color: _line),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: CoverDesignArtwork(design: cover, compact: true),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  cover.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: _ink, fontSize: compact ? 10 : 12),
                ),
                Text(
                  '${cover.author}${cover.year.isEmpty ? '' : ' · ${cover.year}'}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: _muted, fontSize: compact ? 9 : 11),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _publisherGallery(List<PublisherEntry> publishers, bool compact) {
    if (publishers.isEmpty) {
      return _emptySection(
        'No publishers yet',
        Icons.apartment_outlined,
        compact,
      );
    }
    return SizedBox(
      height: compact ? 84 : 106,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: publishers.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) => Container(
          width: compact ? 82 : 110,
          decoration: BoxDecoration(
            color: _card.withValues(alpha: .7),
            border: Border.all(color: _line),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.apartment_outlined,
                color: const Color(0xFFC9BDA8),
                size: compact ? 29 : 37,
              ),
              const SizedBox(height: 5),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Text(
                  publishers[index].name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: _ink, fontSize: compact ? 10 : 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CoverArtistEditResult {
  const _CoverArtistEditResult(this.profile, this.avatarPath);

  final WriterProfile profile;
  final String? avatarPath;
}

class _CoverArtistProfileEditDialog extends StatefulWidget {
  const _CoverArtistProfileEditDialog({
    required this.profile,
    required this.avatarPath,
  });

  final WriterProfile profile;
  final String? avatarPath;

  @override
  State<_CoverArtistProfileEditDialog> createState() =>
      _CoverArtistProfileEditDialogState();
}

class _CoverArtistProfileEditDialogState
    extends State<_CoverArtistProfileEditDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.profile.name);
  late final _about = TextEditingController(text: widget.profile.about);
  late final _specialization = TextEditingController(
    text: widget.profile.designSpecialization,
  );
  late final _artStyle = TextEditingController(text: widget.profile.artStyle);
  late final _services = TextEditingController(
    text: widget.profile.servicesOffered,
  );
  late final _experience = TextEditingController(
    text: widget.profile.yearsOfExperience,
  );
  late final _tools = TextEditingController(text: widget.profile.designTools);
  late final _availability = TextEditingController(
    text: widget.profile.workAvailability,
  );
  late final _customRequests = TextEditingController(
    text: widget.profile.acceptsCustomRequests,
  );
  late final _pricing = TextEditingController(
    text: widget.profile.pricingPackages,
  );
  late final _deliveryTime = TextEditingController(
    text: widget.profile.averageDeliveryTime,
  );
  late final _revisionPolicy = TextEditingController(
    text: widget.profile.revisionPolicy,
  );
  late String? _avatarPath = widget.avatarPath;
  bool _pickingAvatar = false;

  @override
  void dispose() {
    _name.dispose();
    _about.dispose();
    _specialization.dispose();
    _artStyle.dispose();
    _services.dispose();
    _experience.dispose();
    _tools.dispose();
    _availability.dispose();
    _customRequests.dispose();
    _pricing.dispose();
    _deliveryTime.dispose();
    _revisionPolicy.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    setState(() => _pickingAvatar = true);
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image != null && mounted) setState(() => _avatarPath = image.path);
    } finally {
      if (mounted) setState(() => _pickingAvatar = false);
    }
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final profile = widget.profile;
    Navigator.of(context).pop(
      _CoverArtistEditResult(
        WriterProfile(
          name: _name.text.trim(),
          accountId: profile.accountId,
          goodreads: profile.goodreads,
          facebook: profile.facebook,
          instagram: profile.instagram,
          website: profile.website,
          about: _about.text.trim(),
          profileImagePath: _avatarPath,
          designSpecialization: _specialization.text.trim(),
          artStyle: _artStyle.text.trim(),
          servicesOffered: _services.text.trim(),
          yearsOfExperience: _experience.text.trim(),
          designTools: _tools.text.trim(),
          workAvailability: _availability.text.trim(),
          acceptsCustomRequests: _customRequests.text.trim(),
          pricingPackages: _pricing.text.trim(),
          averageDeliveryTime: _deliveryTime.text.trim(),
          revisionPolicy: _revisionPolicy.text.trim(),
          isWriter: profile.isWriter,
          isPublisher: profile.isPublisher,
          isCoverArtist: profile.isCoverArtist,
          books: profile.books,
          followerIds: profile.followerIds,
          publishers: profile.publishers,
        ),
        _avatarPath,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Dialog(
    backgroundColor: const Color(0xFFFFFCF7),
    insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 560, maxHeight: 760),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 9, 10, 9),
            decoration: const BoxDecoration(
              color: _ink,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Edit Profile',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Close',
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ],
            ),
          ),
          Flexible(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: const Color(0xFFFFF8EA),
                          backgroundImage: _avatarPath == null
                              ? null
                              : FileImage(File(_avatarPath!)),
                          child: _avatarPath == null
                              ? const Icon(
                                  Icons.person_outline,
                                  color: _gold,
                                  size: 27,
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Profile picture',
                            style: TextStyle(
                              color: _ink,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _pickingAvatar ? null : _pickAvatar,
                          icon: Icon(
                            _pickingAvatar
                                ? Icons.hourglass_top
                                : Icons.photo_library_outlined,
                          ),
                          label: Text(_pickingAvatar ? 'Loading...' : 'Change'),
                          style: TextButton.styleFrom(foregroundColor: _ink),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _editField(
                      label: 'Name',
                      controller: _name,
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Name is required'
                          : null,
                      capitalization: TextCapitalization.words,
                    ),
                    const SizedBox(height: 13),
                    _editField(
                      label: 'About the Artist',
                      hint: 'A short introduction and your creative approach.',
                      controller: _about,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 13),
                    _editField(
                      label: 'Design Specialization',
                      hint: 'Fantasy, Romance, Thriller, Horror, Sci-Fi...',
                      controller: _specialization,
                    ),
                    const SizedBox(height: 13),
                    _editField(
                      label: 'Art Style',
                      hint:
                          'Minimalist, illustrated, typography-based, vintage...',
                      controller: _artStyle,
                    ),
                    const SizedBox(height: 13),
                    _editField(
                      label: 'Services Offered',
                      hint:
                          'Front cover, back cover, full-wrap, ebook, audiobook...',
                      controller: _services,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 13),
                    _editField(
                      label: 'Years of Experience',
                      hint: 'How long you have worked in cover design.',
                      controller: _experience,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 13),
                    _editField(
                      label: 'Design Tools',
                      hint: 'Photoshop, Illustrator, Canva, Procreate...',
                      controller: _tools,
                    ),
                    const SizedBox(height: 13),
                    _editField(
                      label: 'Work Availability',
                      hint: 'Available or unavailable for new projects.',
                      controller: _availability,
                    ),
                    const SizedBox(height: 13),
                    _editField(
                      label: 'Custom Design Requests',
                      hint: 'Do you accept personalized design requests?',
                      controller: _customRequests,
                    ),
                    const SizedBox(height: 13),
                    _editField(
                      label: 'Pricing & Packages',
                      hint: 'Example: 2000-5000 tk',
                      controller: _pricing,
                    ),
                    const SizedBox(height: 13),
                    _editField(
                      label: 'Average Delivery Time',
                      hint: 'How long a typical cover takes to complete.',
                      controller: _deliveryTime,
                    ),
                    const SizedBox(height: 13),
                    _editField(
                      label: 'Revision Policy',
                      hint: 'Number of revisions and any conditions.',
                      controller: _revisionPolicy,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
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
                    onPressed: _save,
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

  Widget _editField({
    required String label,
    required TextEditingController controller,
    String? hint,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    TextCapitalization capitalization = TextCapitalization.sentences,
    int maxLines = 1,
  }) => TextFormField(
    controller: controller,
    keyboardType: keyboardType,
    textCapitalization: capitalization,
    minLines: maxLines == 1 ? 1 : maxLines,
    maxLines: maxLines,
    validator: validator,
    decoration: InputDecoration(
      labelText: label,
      hintText: hint,
      alignLabelWithHint: maxLines > 1,
      filled: true,
      fillColor: const Color(0xFFFFFCF7),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: _line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: _line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: _ink, width: 1.3),
      ),
    ),
  );
}
