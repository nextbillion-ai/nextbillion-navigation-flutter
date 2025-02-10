import 'package:flutter/material.dart';

class SegmentSelector extends StatefulWidget {
  final List<String> segments;
  final Function(int) onSegmentSelected;
  final int defaultIndex;

  SegmentSelector({required this.segments,required this.defaultIndex, required this.onSegmentSelected});

  @override
  _SegmentSelectorState createState() => _SegmentSelectorState();
}

class _SegmentSelectorState extends State<SegmentSelector> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.defaultIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: widget.segments.map((segment) {
        int index = widget.segments.indexOf(segment);
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedIndex = index;
            });
            widget.onSegmentSelected(index);
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: _selectedIndex == index ? Colors.blue : Colors.grey,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              segment,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        );
      }).toList(),
    );
  }
}
