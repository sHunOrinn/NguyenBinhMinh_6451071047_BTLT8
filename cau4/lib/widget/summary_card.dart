import 'package:flutter/material.dart';
import '../utils/currency_formatter.dart';

class SummaryCard extends StatelessWidget {
  final List<Map<String, dynamic>> summaryData;
  final double totalAmount;

  const SummaryCard({
    super.key,
    required this.summaryData,
    required this.totalAmount,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 0,
      color: colorScheme.primaryContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tổng chi tiêu',
                  style: TextStyle(
                    color: colorScheme.onPrimaryContainer,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Icon(Icons.account_balance_wallet,
                    color: colorScheme.onPrimaryContainer),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              CurrencyFormatter.format(totalAmount),
              style: TextStyle(
                color: colorScheme.onPrimaryContainer,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (summaryData.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Text(
                'Theo danh mục',
                style: TextStyle(
                  color: colorScheme.onPrimaryContainer.withOpacity(0.7),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              ...summaryData.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item['categoryName'] ?? '',
                      style: TextStyle(
                        color: colorScheme.onPrimaryContainer,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      CurrencyFormatter.format(
                          (item['total'] as num).toDouble()),
                      style: TextStyle(
                        color: colorScheme.onPrimaryContainer,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              )),
            ],
          ],
        ),
      ),
    );
  }
}