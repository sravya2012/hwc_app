import 'package:flutter/material.dart';

class ManualSearchSheet extends StatefulWidget {
  final void Function(double lat, double lon) onSearch;
  const ManualSearchSheet({super.key, required this.onSearch});
  @override
  State<ManualSearchSheet> createState() => _ManualSearchSheetState();
}

class _ManualSearchSheetState extends State<ManualSearchSheet> {
  final _latController = TextEditingController();
  final _lonController = TextEditingController();
  String _error = '';

  final List<Map<String, dynamic>> _presets = [
    {'name': '🐘 Nagarhole',     'lat': 11.93, 'lon': 76.13},
    {'name': '🐅 Bandipur',      'lat': 11.67, 'lon': 76.63},
    {'name': '🌿 Wayanad',       'lat': 11.61, 'lon': 76.13},
    {'name': '🦁 Mudumalai',     'lat': 11.56, 'lon': 76.52},
    {'name': '🏔️ Kudremukh',     'lat': 13.15, 'lon': 75.25},
    {'name': '🌲 Kodagu',        'lat': 12.42, 'lon': 75.74},
    {'name': '🦅 BRT Hills',     'lat': 11.98, 'lon': 77.05},
    {'name': '🐆 Anamalai',      'lat': 10.57, 'lon': 76.93},
    {'name': '🏙️ Bengaluru',     'lat': 12.97, 'lon': 77.59},
    {'name': '🏙️ Mysuru',        'lat': 12.30, 'lon': 76.64},
  ];

  void _submit() {
    final lat = double.tryParse(_latController.text.trim());
    final lon = double.tryParse(_lonController.text.trim());
    if (lat == null || lon == null) {
      setState(() => _error = 'Enter valid numbers for Lat and Lon');
      return;
    }
    if (lat < 10 || lat > 15 || lon < 74 || lon > 80) {
      setState(() => _error = 'Lat: 10–15, Lon: 74–80 (South India range)');
      return;
    }
    widget.onSearch(lat, lon);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            const Text('Search Location',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Text('Enter coordinates or pick a known location',
                style: TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(child: TextField(
                controller: _latController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Latitude', hintText: '11.93',
                  prefixIcon: const Icon(Icons.north),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true, fillColor: Colors.grey[100],
                ),
              )),
              const SizedBox(width: 12),
              Expanded(child: TextField(
                controller: _lonController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Longitude', hintText: '76.13',
                  prefixIcon: const Icon(Icons.east),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true, fillColor: Colors.grey[100],
                ),
              )),
            ]),
            if (_error.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(_error, style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.search),
                label: const Text('Check Risk', style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Known HWC Locations',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: _presets.map((p) => ActionChip(
                label: Text(p['name']),
                backgroundColor: Colors.green[50],
                side: const BorderSide(color: Color(0xFF2E7D32)),
                onPressed: () {
                  _latController.text = p['lat'].toString();
                  _lonController.text = p['lon'].toString();
                },
              )).toList(),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
