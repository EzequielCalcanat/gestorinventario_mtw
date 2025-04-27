import 'package:flutter/material.dart';

class ReportDateFilter extends StatelessWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final VoidCallback onPickStartDate;
  final VoidCallback onPickEndDate;
  final VoidCallback onSearch;

  const ReportDateFilter({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.onPickStartDate,
    required this.onPickEndDate,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: onPickStartDate,
            style: _dateButtonStyle(),
            child: Text(
              startDate == null
                  ? "Desde"
                  : "${startDate!.day}/${startDate!.month}/${startDate!.year}",
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton(
            onPressed: onPickEndDate,
            style: _dateButtonStyle(),
            child: Text(
              endDate == null
                  ? "Hasta"
                  : "${endDate!.day}/${endDate!.month}/${endDate!.year}",
            ),
          ),
        ),
        const SizedBox(width: 8),
        ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: 48,
            minHeight: 48,
            maxWidth: 48,
            maxHeight: 48,
          ),
          child: ElevatedButton(
            onPressed: onSearch,
            style: _searchButtonStyle(),
            child: const Icon(Icons.search, size: 22),
          ),
        ),
      ],
    );
  }

  ButtonStyle _dateButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
        side: const BorderSide(color: Color(0xFFBDBDBD)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      elevation: 0,
    );
  }

  ButtonStyle _searchButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF3491B3),
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      padding: EdgeInsets.zero,
      elevation: 0,
    );
  }
}
