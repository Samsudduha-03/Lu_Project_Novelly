import 'package:flutter/material.dart';

import '../chat/chat_list.dart';
import '../main_page/discover.dart';
import '../main_page/novelly_bottom_navigation.dart';
import '../main_page/writer_profile.dart';
import 'cover_design.dart';
import 'cover_design_form.dart';
import 'cover_artist_profile.dart';

const _ink = Color(0xFF173B43);
const _gold = Color(0xFFC89543);
const _muted = Color(0xFF777873);
const _line = Color(0xFFDDD5C7);
const _paper = Color(0xFFF4F0E7);

class MyDesignsScreen extends StatefulWidget {
  const MyDesignsScreen({
    this.covers = const [],
    this.drafts = const [],
    super.key, 
  });

  final List<CoverDesign> covers;
  final List<CoverDesign> drafts;

  @override
  State<MyDesignsScreen> createState() => _MyDesignsScreenState();
}

class _MyDesignsScreenState extends State<MyDesignsScreen> {
  int _selectedTab = 0;
  late final CoverArtistWorkspace _workspace;

  bool get _canManageDesigns => WriterProfileScreen.currentUser.isCoverArtist;
  List<CoverDesign> get _selectedDesigns =>
      _selectedTab == 0 ? _workspace.covers : _workspace.drafts;

  @override
  void initState() {
    super.initState();
    final account = WriterProfileScreen.currentUser;
    _workspace = CoverArtistWorkspace.forAccount(
      account.accountId,
      initialCovers: widget.covers,
      initialDrafts: widget.drafts,
    );
  }

  Future<void> _addCover() async {
    final design = await showCoverDesignForm(
      context,
      creator: WriterProfileScreen.currentUser.name,
    );
    if (design == null || !mounted) return;
    setState(() {
      (design.isDraft ? _workspace.drafts : _workspace.covers).insert(
        0,
        design,
      );
    });
  }

  Future<void> _editCover(CoverDesign current) async {
    final design = await showCoverDesignForm(
      context,
      creator: WriterProfileScreen.currentUser.name,
      design: current,
    );
    if (design == null || !mounted) return;
    setState(() {
      final previousList = current.isDraft
          ? _workspace.drafts
          : _workspace.covers;
      previousList.remove(current);
      (design.isDraft ? _workspace.drafts : _workspace.covers).insert(
        0,
        design,
      );
    });
  }

  void _navigate(NovellyNavigationDestination destination) {
    switch (destination) {
      case NovellyNavigationDestination.discover:
        Navigator.of(context).maybePop();
        break;
      case NovellyNavigationDestination.library:
        break;
      case NovellyNavigationDestination.chat:
        Navigator.of(
          context,
        ).push(MaterialPageRoute<void>(builder: (_) => const ChatListScreen()));
        break;
      case NovellyNavigationDestination.profile:
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => CoverArtistProfileScreen(
              isCurrentUser: true,
              covers: List.unmodifiable(_workspace.covers),
              drafts: List.unmodifiable(_workspace.drafts),
            ),
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_canManageDesigns) {
      return Scaffold(
        backgroundColor: _paper,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lock_outline, color: _muted, size: 42),
                  const SizedBox(height: 12),
                  const Text(
                    'My Designs is only available to cover artists.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: _muted, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute<void>(
                        builder: (_) => const DiscoverScreen(),
                      ),
                    ),
                    child: const Text('Back to Discover'),
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
              final padding = (constraints.maxWidth * .055).clamp(18.0, 38.0);
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 860),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(padding, 10, padding, 12),
                    child: Column(
                      children: [
                        _header(compact),
                        SizedBox(height: compact ? 24 : 30),
                        _tabs(compact),
                        const SizedBox(height: 12),
                        Expanded(
                          child: _designGrid(
                            compact,
                            _selectedDesigns,
                            _selectedTab == 0
                                ? 'No covers yet'
                                : 'No drafts yet',
                          ),
                        ),
                        const SizedBox(height: 10),
                        NovellyBottomNavigation(
                          libraryLabel: 'My Designs',
                          libraryIcon: Icons.palette_outlined,
                          selectedDestination:
                              NovellyNavigationDestination.library,
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

  Widget _designGrid(
    bool compact,
    List<CoverDesign> designs,
    String emptyMessage,
  ) {
    if (designs.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _selectedTab == 0
                  ? Icons.palette_outlined
                  : Icons.drafts_outlined,
              color: const Color(0xFFC9BDA8),
              size: compact ? 48 : 58,
            ),
            const SizedBox(height: 12),
            Text(
              emptyMessage,
              style: TextStyle(color: _muted, fontSize: compact ? 15 : 18),
            ),
          ],
        ),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.only(top: 6, bottom: 8),
      itemCount: designs.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: compact ? 2 : 3,
        crossAxisSpacing: compact ? 10 : 15,
        mainAxisSpacing: compact ? 10 : 15,
        childAspectRatio: .72,
      ),
      itemBuilder: (context, index) {
        final design = designs[index];
        return Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE9E1D4)),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: CoverDesignArtwork(
                        design: design,
                        compact: compact,
                      ),
                    ),
                    Positioned(
                      top: 3,
                      right: 3,
                      child: PopupMenuButton<String>(
                        tooltip: 'Cover options',
                        onSelected: (action) {
                          if (action == 'edit') _editCover(design);
                          if (action == 'delete') {
                            setState(() => designs.remove(design));
                          }
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(value: 'edit', child: Text('Edit')),
                          PopupMenuItem(value: 'delete', child: Text('Delete')),
                        ],
                        icon: const Icon(
                          Icons.more_vert,
                          color: _ink,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 9),
                child: Column(
                  children: [
                    Text(
                      design.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _ink,
                        fontSize: compact ? 12 : 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${design.author}${design.year.isEmpty ? '' : ' · ${design.year}'}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _muted,
                        fontSize: compact ? 10 : 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _header(bool compact) => Row(
    children: [
      Text(
        'My Designs',
        style: TextStyle(
          color: _ink,
          fontFamily: 'Georgia',
          fontSize: compact ? 28 : 34,
          fontWeight: FontWeight.w600,
          letterSpacing: -1,
        ),
      ),
      const Spacer(),
      Material(
        color: _gold,
        shape: const CircleBorder(),
        child: IconButton(
          tooltip: 'Add cover',
          onPressed: _canManageDesigns ? _addCover : null,
          color: Colors.white,
          icon: const Icon(Icons.add_rounded, size: 28),
        ),
      ),
    ],
  );

  Widget _tabs(bool compact) => Column(
    children: [
      Row(
        children: [
          for (var index = 0; index < 2; index++)
            Expanded(
              child: InkWell(
                onTap: () => setState(() => _selectedTab = index),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: compact ? 11 : 14),
                  child: Text(
                    index == 0 ? 'All Covers' : 'Drafts',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _selectedTab == index ? _gold : _ink,
                      fontSize: compact ? 15 : 18,
                      fontWeight: _selectedTab == index
                          ? FontWeight.w600
                          : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      SizedBox(
        height: 2,
        child: Stack(
          children: [
            const Positioned.fill(child: ColoredBox(color: _line)),
            Align(
              alignment: _selectedTab == 0
                  ? Alignment.centerLeft
                  : Alignment.centerRight,
              child: FractionallySizedBox(
                widthFactor: .5,
                child: ColoredBox(
                  color: _selectedTab == 0 ? _gold : _ink,
                  child: const SizedBox(height: 2),
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
