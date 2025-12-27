import 'package:videocalling/core/config/app_imports.dart';

class ReviewsScreen extends GetView<ReviewController> {
  final ReviewController reviewController = Get.put(ReviewController());

  ReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isArabic = Get.locale?.languageCode == 'ar';

    return WillPopScope(
      onWillPop: () {
        Get.back(result: reviewController.isChangesMade.value);
        return Future.value(false);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          titleSpacing: 0,
          title: Text(
            'review'.tr,
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w400,
              fontFamily: isArabic ? 'NotoKufiArabic' : 'Roboto',
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, size: 20, color: Colors.black),
            onPressed: () =>
                Get.back(result: reviewController.isChangesMade.value),
          ),
        ),
        body: Obx(() {
          return Stack(
            children: [
              // Error state
              if (reviewController.isErrorInReview.value) _buildErrorState(),

              // Loading state
              if (!reviewController.isReviewLoaded.value)
                _buildLoadingState(context),

              // Empty state
              if (reviewController.isReviewLoaded.value &&
                  !reviewController.isReviewExist.value)
                _buildEmptyState(),

              // Content state
              if (reviewController.isReviewLoaded.value &&
                  reviewController.isReviewExist.value)
                _buildReviewsList(),

              // Bottom action button
              Align(
                alignment: Alignment.bottomCenter,
                child: _buildActionButton(context),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.mood_bad_rounded, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'unable_to_load_data'.tr,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
              fontFamily: AppFontStyleTextStrings.regular,
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => reviewController.fetchReviews(),
            child: Text(
              'try_again'.tr,
              style: const TextStyle(
                color: Color(0xFF204FCF),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF204FCF)),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'loading_reviews'.tr,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 15,
              fontFamily: AppFontStyleTextStrings.regular,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.rate_review_outlined,
              size: 50,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'no_review'.tr,
            style: TextStyle(
              fontFamily: AppFontStyleTextStrings.medium,
              fontSize: 18,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              'be_the_first_to_review'.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppFontStyleTextStrings.regular,
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsList() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 80),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: reviewController.reviewsClass!.data!.length,
        separatorBuilder: (context, index) => const Divider(height: 32),
        itemBuilder: (context, index) {
          final review = reviewController.reviewsClass!.data![index];
          return _buildReviewItem(review);
        },
      ),
    );
  }

  Widget _buildReviewItem(dynamic review) {
    final rating = int.parse(review.rating ?? "0");

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // User avatar
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: CachedNetworkImage(
                fit: BoxFit.cover,
                imageUrl: review.image ?? "",
                height: 40,
                width: 40,
                placeholder: (context, url) => Container(
                  color: Colors.grey[200],
                  child: Icon(Icons.person, color: Colors.grey[400], size: 24),
                ),
                errorWidget: (context, url, err) => Container(
                  color: Colors.grey[200],
                  child: Icon(Icons.person, color: Colors.grey[400], size: 24),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // User info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    review.name ?? "",
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: List.generate(
                      5,
                      (i) => Padding(
                        padding: const EdgeInsets.only(right: 3),
                        child: Icon(
                          i < rating ? Icons.star : Icons.star_border,
                          size: 16,
                          color: i < rating
                              ? const Color(0xFFFFB800)
                              : Colors.grey[400],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Review date
            Text(
              review.date ?? "",
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),

        // Review text
        if (review.description != null && review.description.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 12, left: 52),
            child: Text(
              review.description ?? "",
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Colors.grey[800],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(34),
      decoration: const BoxDecoration(
        color: Colors.white,
        // boxShadow: [
        //   // BoxShadow(
        //   //   color: Colors.black.withOpacity(0.08),
        //   //   blurRadius: 10,
        //   //   offset: const Offset(0, -2),
        //   // ),
        // ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            if (reviewController.isLoggedIn.value) {
              _showReviewBottomSheet(context);
            } else {
              await Get.toNamed(
                Routes.loginUserScreen,
                arguments: {"isBack": false},
              );
            }
          },
          borderRadius: BorderRadius.circular(8),
          child: Ink(
            decoration: BoxDecoration(
              color: const Color(0xFF204FCF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Container(
              height: 56,
              alignment: Alignment.center,
              child: Text(
                reviewController.isLoggedIn.value
                    ? 'add_a_review'.tr
                    : 'login_to_review'.tr,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showReviewBottomSheet(BuildContext context) {
    Get.bottomSheet(
      isScrollControlled: true,
      Obx(
        () => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Review sheet header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'add_a_review'.tr,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.close),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      iconSize: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Rating selector
                Text(
                  'your_rating'.tr,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    5,
                    (index) => GestureDetector(
                      onTap: () => reviewController.starCount.value = index + 1,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Icon(
                          reviewController.starCount.value >= index + 1
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          size: 32,
                          color: reviewController.starCount.value >= index + 1
                              ? const Color(0xFFFFB800)
                              : Colors.grey[400],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Review text field
                TextField(
                  controller: reviewController.textEditingController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'enter_message'.tr,
                    hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  style: const TextStyle(color: Colors.black, fontSize: 14),
                  onChanged: (val) => reviewController.message.value = val,
                ),
                const SizedBox(height: 24),

                // Submit button
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Get.focusScope?.unfocus();
                      reviewController.uploadReview();
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Ink(
                      decoration: BoxDecoration(
                        color: const Color(0xFF204FCF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Container(
                        height: 48,
                        alignment: Alignment.center,
                        child: Text(
                          'btn_submit'.tr,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
