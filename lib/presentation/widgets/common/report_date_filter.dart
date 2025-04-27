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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Inicio",
                  style: TextStyle(fontSize: 10, color: Colors.grey),
                ),
                const SizedBox(height: 2),
                Text(
                  startDate == null
                      ? "--/--/----"
                      : "${startDate!.day.toString().padLeft(2, '0')}/${startDate!.month.toString().padLeft(2, '0')}/${startDate!.year}",
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton(
            onPressed: startDate == null ? null : onPickEndDate,
            style: _dateButtonStyle(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Fin",
                  style: TextStyle(fontSize: 10, color: Colors.grey),
                ),
                const SizedBox(height: 2),
                Text(
                  endDate == null
                      ? "--/--/----"
                      : "${endDate!.day.toString().padLeft(2, '0')}/${endDate!.month.toString().padLeft(2, '0')}/${endDate!.year}",
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: 44,
            minHeight: 44,
            maxWidth: 44,
            maxHeight: 44,
          ),
          child: ElevatedButton(
            onPressed: (startDate != null && endDate != null) ? onSearch : null,
            style: _searchButtonStyle(),
            child: const Icon(Icons.search, size: 20),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), // Menos vertical
      elevation: 0,
      minimumSize: const Size(0, 44), // Forzar altura mínima
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
