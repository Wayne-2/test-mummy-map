import 'package:flutter/material.dart';
import 'package:mummymap/data/models/track_models.dart';

class RecipeScreen extends StatefulWidget {
  final MealItem meal;

  const RecipeScreen({super.key, required this.meal});

  @override
  State<RecipeScreen> createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Set<int> _checkedIngredients = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final meal = widget.meal;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(
                      meal.imagePath,
                      width: double.infinity,
                      height: 220,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 220,
                        color: Colors.grey.shade200,
                        child: const Center(
                          child: Icon(Icons.restaurant,
                              color: Colors.grey, size: 60),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            meal.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            meal.description,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF555555),
                              height: 1.6,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              _StatItem(
                                label: 'PREP TIME',
                                value: '${meal.prepMins} mins',
                                icon: Icons.restaurant_outlined,
                              ),
                              const SizedBox(width: 24),
                              _StatItem(
                                label: 'COOK TIME',
                                value: '${meal.cookMins} mins',
                                icon: Icons.timer_outlined,
                              ),
                              const SizedBox(width: 24),
                              _StatItem(
                                label: 'SERVINGS',
                                value: '${meal.servings}',
                                icon: Icons.people_outline,
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          TabBar(
                            controller: _tabController,
                            labelColor: const Color(0xFF3F2868),
                            unselectedLabelColor: const Color(0xFF9E9E9E),
                            indicatorColor: const Color(0xFF3F2868),
                            indicatorWeight: 2,
                            labelStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                            unselectedLabelStyle:
                                const TextStyle(fontSize: 14),
                            tabs: const [
                              Tab(text: 'Ingredients'),
                              Tab(text: 'Steps To Prepare'),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 600,
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                _buildIngredients(meal),
                                _buildSteps(meal),
                              ],
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)),
            onPressed: () => Navigator.pop(context),
          ),
          const Text(
            'Recipe',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const Spacer(),
          const Icon(Icons.volume_up_outlined,
              color: Color(0xFF1A1A1A), size: 22),
          const SizedBox(width: 12),
          const Icon(Icons.bookmark_outline,
              color: Color(0xFF1A1A1A), size: 22),
          const SizedBox(width: 12),
          const Icon(Icons.share_outlined,
              color: Color(0xFF1A1A1A), size: 22),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildIngredients(MealItem meal) {
    int globalIndex = 0;
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      children: meal.ingredientGroups.map((group) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              group.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 10),
            ...group.items.map((item) {
              final idx = globalIndex++;
              final checked = _checkedIngredients.contains(idx);
              return GestureDetector(
                onTap: () => setState(() {
                  if (checked) {
                    _checkedIngredients.remove(idx);
                  } else {
                    _checkedIngredients.add(idx);
                  }
                }),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: checked
                              ? const Color(0xFF3F2868)
                              : Colors.transparent,
                          border: Border.all(
                            color: checked
                                ? const Color(0xFF3F2868)
                                : const Color(0xFFBDBDBD),
                            width: 1.5,
                          ),
                        ),
                        child: checked
                            ? const Icon(Icons.check,
                                color: Colors.white, size: 13)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item,
                          style: TextStyle(
                            fontSize: 14,
                            color: checked
                                ? const Color(0xFF9E9E9E)
                                : const Color(0xFF333333),
                            decoration: checked
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildSteps(MealItem meal) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      children: meal.prepGroups.map((group) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              group.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 140,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: group.steps.length,
                itemBuilder: (context, index) {
                  return Container(
                    width: 260,
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5EEFF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF3F2868),
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Expanded(
                          child: Text(
                            group.steps[index],
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF333333),
                              height: 1.5,
                            ),
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        );
      }).toList(),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: const Color(0xFF9E9E9E)),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                  fontSize: 11, color: Color(0xFF9E9E9E)),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
      ],
    );
  }
}