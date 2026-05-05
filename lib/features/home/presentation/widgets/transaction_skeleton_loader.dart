import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Skeleton loader widget for transactions
class TransactionSkeletonLoader extends StatelessWidget {
  final int itemCount;

  const TransactionSkeletonLoader({
    Key? key,
    this.itemCount = 5,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return _buildSkeletonItem();
      },
    );
  }

  Widget _buildSkeletonItem() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12, left: 16, right: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[300],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 16,
                    width: 150,
                    color: Colors.grey[300],
                    margin: const EdgeInsets.only(bottom: 8),
                  ),
                  Container(
                    height: 12,
                    width: 100,
                    color: Colors.grey[300],
                  ),
                ],
              ),
            ),
            Container(
              height: 16,
              width: 60,
              color: Colors.grey[300],
            ),
          ],
        ),
      ),
    );
  }
}

/// Summary skeleton loader
class SummarySkeletonLoader extends StatelessWidget {
  const SummarySkeletonLoader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}

/// Accounts list skeleton loader
class AccountsSkeletonLoader extends StatelessWidget {
  final int itemCount;

  const AccountsSkeletonLoader({
    Key? key,
    this.itemCount = 3,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: SizedBox(
        height: 150,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: itemCount,
          itemBuilder: (context, index) {
            return Container(
              width: 140,
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            );
          },
        ),
      ),
    );
  }
}
