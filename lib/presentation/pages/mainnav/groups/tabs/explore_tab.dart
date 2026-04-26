import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mummymap/presentation/providers/groups_provider.dart';
import 'package:mummymap/presentation/pages/mainnav/groups/create_group.dart';
import 'package:mummymap/presentation/pages/mainnav/groups/group_detail.dart';
import 'package:mummymap/presentation/pages/mainnav/groups/widgets/post_card.dart';

class ExploreTab extends ConsumerStatefulWidget {
  const ExploreTab({super.key});

  @override
  ConsumerState<ExploreTab> createState() => _ExploreTabState();
}

class _ExploreTabState extends ConsumerState<ExploreTab> {
  final _searchController = TextEditingController();
  final _pageController = PageController(viewportFraction: 0.88);
  String _query = '';
  int _currentPage = 0;

  @override
  void dispose() {
    _searchController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(groupsProvider);
    final unjoinedGroups = state.unjoinedGroups.where((g) {
      if (_query.isEmpty) return true;
      return g.name.toLowerCase().contains(_query.toLowerCase()) ||
          g.description.toLowerCase().contains(_query.toLowerCase());
    }).toList();
    final posts = state.posts;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _query = val),
              decoration: InputDecoration(
                hintText: 'Search groups...',
                hintStyle: TextStyle(
                    color: Colors.grey.shade400, fontSize: 14),
                prefixIcon: Icon(Icons.search,
                    color: Colors.grey.shade400),
                suffixIcon: _query.isNotEmpty
                    ? GestureDetector(
                        onTap: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                        child: Icon(Icons.clear,
                            color: Colors.grey.shade400),
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          if (unjoinedGroups.isEmpty && posts.isEmpty)
            _EmptyExplore(
              hasQuery: _query.isNotEmpty,
              onCreateGroup: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const CreateGroup()),
              ),
            )
          else ...[
            if (unjoinedGroups.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _query.isNotEmpty
                          ? 'Results for "$_query"'
                          : 'Suggested Groups To Follow',
                      style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A)),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const CreateGroup()),
                      ),
                      child: const Text('+ Create',
                          style: TextStyle(
                              color: Color(0xFF3F2868),
                              fontWeight: FontWeight.w600,
                              fontSize: 13)),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 200,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: unjoinedGroups.length,
                  onPageChanged: (i) =>
                      setState(() => _currentPage = i),
                  itemBuilder: (context, index) {
                    final group = unjoinedGroups[index];
                    return _GroupCarouselCard(
                      group: group,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                GroupDetail(groupId: group.id)),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  unjoinedGroups.length,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin:
                        const EdgeInsets.symmetric(horizontal: 3),
                    width: _currentPage == i ? 20 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: _currentPage == i
                          ? const Color(0xFF3F2868)
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
            if (posts.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Text(
                  'Recent Posts',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A)),
                ),
              ),
              ...posts.map((post) => Column(
                    children: [
                      PostCard(post: post),
                      Divider(
                          height: 1,
                          color: Colors.grey.shade100),
                    ],
                  )),
            ],
          ],
        ],
      ),
    );
  }
}

class _GroupCarouselCard extends ConsumerWidget {
  final CommunityGroup group;
  final VoidCallback onTap;

  const _GroupCarouselCard(
      {required this.group, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Color(group.avatarColor),
        ),
        child: Stack(
          children: [
          
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                'assets/mum2.jpg',
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(group.avatarColor),
                        Color(group.avatarColor).withOpacity(0.6),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.65),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.white24,
                        child: Text(
                          group.initials,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(group.name,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13)),
                          Text(
                              'Created ${group.createdAt}',
                              style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11)),
                        ],
                      ),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                        
                          ...List.generate(
                            3,
                            (i) => Transform.translate(
                              offset: Offset(i * -8.0, 0),
                              child: CircleAvatar(
                                radius: 10,
                                backgroundColor: Colors.white24,
                                child: const Icon(Icons.person,
                                    color: Colors.white,
                                    size: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text('${group.members}+ Members',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12)),
                        ],
                      ),
                      GestureDetector(
                        onTap: onTap,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.circular(20),
                          ),
                          child: const Row(
                            children: [
                              Text('Join',
                                  style: TextStyle(
                                      color: Color(0xFF3F2868),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13)),
                              SizedBox(width: 4),
                              Icon(Icons.add,
                                  color: Color(0xFF3F2868),
                                  size: 14),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyExplore extends StatelessWidget {
  final bool hasQuery;
  final VoidCallback onCreateGroup;

  const _EmptyExplore(
      {required this.hasQuery, required this.onCreateGroup});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFE8D5F5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              hasQuery
                  ? Icons.search_off
                  : Icons.group_add_outlined,
              size: 40,
              color: const Color(0xFF3F2868),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            hasQuery ? 'No groups found' : 'No groups yet',
            style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A)),
          ),
          const SizedBox(height: 8),
          Text(
            hasQuery
                ? 'Try a different search term'
                : 'Be the first to create a community for mums like you',
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF9E9E9E),
                height: 1.5),
          ),
          if (!hasQuery) ...[
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: onCreateGroup,
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text('Create a Group',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3F2868),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}