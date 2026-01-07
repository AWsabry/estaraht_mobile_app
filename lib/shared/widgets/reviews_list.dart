import 'package:videocalling/core/config/app_imports.dart';
import 'package:videocalling/shared/models/review_model.dart';
import 'package:videocalling/shared/services/review_service.dart';

class ReviewsList extends StatelessWidget {
  final String doctorId;
  final int maxReviews;
  final bool showHeader;

  const ReviewsList({
    Key? key,
    required this.doctorId,
    this.maxReviews = 5,
    this.showHeader = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ReviewModel>>(
      future: reviewService.getReviewsForDoctor(doctorId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(color: AppColors.color1),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.rate_review_outlined,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'no_reviews_yet'.tr,
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
              ),
            ),
          );
        }

        final reviews = snapshot.data!;
        final displayReviews = reviews.take(maxReviews).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showHeader) ...[
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'reviews'.tr,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (reviews.length > maxReviews)
                      TextButton(
                        onPressed: () {
                          // Navigate to all reviews screen
                        },
                        child: Text(
                          '${'see_all'.tr} (${reviews.length})',
                          style: const TextStyle(color: AppColors.color1),
                        ),
                      ),
                  ],
                ),
              ),
            ],
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: displayReviews.length,
              separatorBuilder: (_, __) =>
                  Divider(height: 1, color: Colors.grey[200]),
              itemBuilder: (context, index) {
                return ReviewCard(review: displayReviews[index]);
              },
            ),
          ],
        );
      },
    );
  }
}

class ReviewCard extends StatelessWidget {
  final ReviewModel review;

  const ReviewCard({Key? key, required this.review}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey[200],
                backgroundImage:
                    review.patientImage != null &&
                        review.patientImage!.isNotEmpty
                    ? CachedNetworkImageProvider(review.patientImage!)
                    : null,
                child:
                    review.patientImage == null || review.patientImage!.isEmpty
                    ? Icon(Icons.person, color: Colors.grey[400])
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.patientName ?? 'anonymous'.tr,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    Row(
                      children: [
                        ...List.generate(5, (index) {
                          return Icon(
                            index < review.rating
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber,
                            size: 16,
                          );
                        }),
                        const SizedBox(width: 8),
                        Text(
                          review.timeAgo,
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (review.comment != null && review.comment!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              review.comment!,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class DoctorRatingDisplay extends StatelessWidget {
  final double averageRating;
  final int totalReviews;
  final bool showLabel;
  final double starSize;

  const DoctorRatingDisplay({
    Key? key,
    required this.averageRating,
    required this.totalReviews,
    this.showLabel = true,
    this.starSize = 18,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.star, color: Colors.amber, size: starSize),
        const SizedBox(width: 4),
        Text(
          averageRating.toStringAsFixed(1),
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: starSize - 2),
        ),
        if (showLabel) ...[
          const SizedBox(width: 4),
          Text(
            '($totalReviews ${totalReviews == 1 ? 'review'.tr : 'reviews'.tr})',
            style: TextStyle(color: Colors.grey[600], fontSize: starSize - 4),
          ),
        ],
      ],
    );
  }
}
