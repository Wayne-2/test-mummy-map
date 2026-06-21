import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mummymap/data/models/doctor_model.dart';
import 'package:mummymap/presentation/providers/doctors_provider.dart';

class AllReviewsScreen extends ConsumerStatefulWidget {
  final String doctorId;
  final int reviewCount;

  const AllReviewsScreen({
    super.key,
    required this.doctorId,
    required this.reviewCount,
  });

  @override
  ConsumerState<AllReviewsScreen> createState() => _AllReviewsScreenState();
}

class _AllReviewsScreenState extends ConsumerState<AllReviewsScreen> {
  List<DoctorReview> _reviews = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final reviews =
        await ref.read(doctorsProvider.notifier).loadReviews(widget.doctorId);
    if (!mounted) return;
    setState(() {
      _reviews = reviews;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back,
                        color: Color(0xFF1A1A1A)),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        const Text(
                          'Reviews',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '(${widget.reviewCount})',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF9E9E9E),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE0E0E0)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.tune,
                        size: 18, color: Color(0xFF1A1A1A)),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE0E0E0)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Text('Today',
                            style: TextStyle(
                                fontSize: 13, color: Color(0xFF1A1A1A))),
                        SizedBox(width: 4),
                        Icon(Icons.keyboard_arrow_down,
                            size: 16, color: Color(0xFF1A1A1A)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: Color(0xFF3F2868)),
                    )
                  : _reviews.isEmpty
                      ? const Center(
                          child: Text(
                            'No reviews yet',
                            style: TextStyle(
                                fontSize: 14, color: Color(0xFF9E9E9E)),
                          ),
                        )
                      : ListView.separated(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _reviews.length,
                          separatorBuilder: (_, __) => const Divider(
                            height: 32,
                            color: Color(0xFFEEEEEE),
                          ),
                          itemBuilder: (context, index) =>
                              _ExpandableReviewCard(review: _reviews[index]),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpandableReviewCard extends StatefulWidget {
  final DoctorReview review;

  const _ExpandableReviewCard({required this.review});

  @override
  State<_ExpandableReviewCard> createState() => _ExpandableReviewCardState();
}

class _ExpandableReviewCardState extends State<_ExpandableReviewCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final review = widget.review;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                review.avatarPath,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.primaries[
                          review.author.hashCode % Colors.primaries.length]
                      .shade200,
                  child: Text(
                    review.author[0],
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    review.author,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: List.generate(5, (i) {
                      if (i < review.rating.floor()) {
                        return const Icon(Icons.star,
                            color: Color(0xFFFFC107), size: 13);
                      } else if (i < review.rating) {
                        return const Icon(Icons.star_half,
                            color: Color(0xFFFFC107), size: 13);
                      }
                      return const Icon(Icons.star_outline,
                          color: Color(0xFFFFC107), size: 13);
                    }),
                  ),
                ],
              ),
            ),
            Text(
              review.date,
              style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E)),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          review.body,
          maxLines: _expanded ? null : 2,
          overflow: _expanded ? null : TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF555555),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Text(
            _expanded ? 'See Less' : 'See More',
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF3F2868),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}