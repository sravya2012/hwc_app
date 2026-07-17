import 'dart:async';
import 'dart:js_interop';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/prediction_service.dart';
import '../widgets/risk_card.dart';
import '../widgets/manual_search_sheet.dart';
import 'package:web/web.dart' as web;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  PredictionResult? _result;
  bool   _predicting = false;
  double _lat        = 11.93;
  double _lon        = 76.13;
  String _placeName  = 'Nagarhole';
  bool   _tracked    = false;
  bool   _locating   = false;
  int?   _watchId;

  final List<Map<String, dynamic>> _spots = [
    {'name': '🐘 Nagarhole',  'lat': 11.93, 'lon': 76.13},
    {'name': '🐅 Bandipur',   'lat': 11.67, 'lon': 76.63},
    {'name': '🌿 Wayanad',    'lat': 11.61, 'lon': 76.13},
    {'name': '🦁 Mudumalai',  'lat': 11.56, 'lon': 76.52},
    {'name': '🏔️ Kudremukh',  'lat': 13.15, 'lon': 75.25},
    {'name': '🌲 Kodagu',     'lat': 12.42, 'lon': 75.74},
    {'name': '🦅 BRT Hills',  'lat': 11.98, 'lon': 77.05},
    {'name': '🐆 Anamalai',   'lat': 10.57, 'lon': 76.93},
    {'name': '🏙️ Bengaluru',  'lat': 12.97, 'lon': 77.59},
    {'name': '🏙️ Mysuru',     'lat': 12.30, 'lon': 76.64},
  ];

  @override
  void initState() {
    super.initState();
    _predictAndShow(_lat, _lon);
  }

  @override
  void dispose() {
    _stopWatch();
    super.dispose();
  }

  Future<void> _predictAndShow(double lat, double lon) async {
    setState(() => _predicting = true);
    final result = await PredictionService.predict(lat, lon);
    if (result != null && mounted) {
      setState(() {
        _result     = result;
        _predicting = false;
        _lat        = lat;
        _lon        = lon;
      });
      if (result.risk == 'HIGH') _showRiskAlert(result);
    } else {
      setState(() => _predicting = false);
    }
  }

  void _stopWatch() {
    if (_watchId != null) {
      web.window.navigator.geolocation.clearWatch(_watchId!);
      _watchId = null;
    }
  }

  void _toggleTracking() {
    if (_tracked) {
      _stopWatch();
      setState(() { _tracked = false; _locating = false; });
      return;
    }
    setState(() => _locating = true);

    // Success handler
    void onSuccess(web.GeolocationPosition pos) {
      final lat = pos.coords.latitude.toDouble();
      final lon = pos.coords.longitude.toDouble();
      if (mounted) {
        setState(() {
          _lat       = lat;
          _lon       = lon;
          _placeName = 'My Location';
          _tracked   = true;
          _locating  = false;
        });
        _predictAndShow(lat, lon);
      }
    }

    // Error handler
    void onError(web.GeolocationPositionError err) {
      if (mounted) {
        setState(() { _locating = false; _tracked = false; });
        _showSnack('Location denied. Please allow in browser.');
      }
    }

    final options = web.PositionOptions(
      enableHighAccuracy: true,
      timeout: 10000,
      maximumAge: 0,
    );

    // watchPosition gives continuous live updates
    _watchId = web.window.navigator.geolocation.watchPosition(
      onSuccess.toJS,
      onError.toJS,
      options,
    );

    setState(() => _tracked = true);
  }

  void _showRiskAlert(PredictionResult result) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(children: [
          Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
          SizedBox(width: 8),
          Text('HIGH RISK ALERT!',
              style: TextStyle(color: Colors.red, fontSize: 18)),
        ]),
        content: Text(
          'You are near a high-risk wildlife conflict zone!\n\n'
          '📍 Lat: ${_lat.toStringAsFixed(2)}, Lon: ${_lon.toStringAsFixed(2)}\n'
          '⚠️ Risk: ${result.probability.toStringAsFixed(1)}%\n'
          '🔑 Key factor: ${result.driver}\n\n'
          'Please be cautious and stay alert!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK, Got it',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _openSearch() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ManualSearchSheet(
        onSearch: (lat, lon) {
          Navigator.pop(context);
          setState(() {
            _lat       = lat;
            _lon       = lon;
            _placeName =
                '(${lat.toStringAsFixed(2)}, ${lon.toStringAsFixed(2)})';
          });
          _predictAndShow(lat, lon);
        },
      ),
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), duration: const Duration(seconds: 4)));
  }

  Color get _bgColor {
    if (_result == null) return const Color(0xFF2E7D32);
    switch (_result!.risk) {
      case 'HIGH':   return const Color(0xFFB71C1C);
      case 'MEDIUM': return const Color(0xFFE65100);
      default:       return const Color(0xFF1B5E20);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
              child: Row(children: [
                const Icon(Icons.forest, color: Colors.white, size: 24),
                const SizedBox(width: 8),
                const Text('HWC Alert',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                const Spacer(),
                if (_tracked)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(children: [
                      Icon(Icons.location_on,
                          color: Colors.greenAccent, size: 14),
                      SizedBox(width: 4),
                      Text('Live',
                          style: TextStyle(
                              color: Colors.greenAccent,
                              fontSize: 12,
                              fontWeight: FontWeight.bold)),
                    ]),
                  ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.white),
                  onPressed: () => FirebaseAuth.instance.signOut(),
                ),
              ]),
            ),

            // ── Location pill ─────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white12,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(children: [
                  const Icon(Icons.location_pin,
                      color: Colors.white70, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '$_placeName  •  '
                      'Lat: ${_lat.toStringAsFixed(2)}, '
                      'Lon: ${_lon.toStringAsFixed(2)}',
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 13),
                    ),
                  ),
                  if (_locating)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    ),
                ]),
              ),
            ),

            const SizedBox(height: 16),

            // ── Risk card ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _predicting
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: Colors.white))
                  : _result != null
                      ? RiskCard(result: _result!)
                      : const SizedBox.shrink(),
            ),

            const SizedBox(height: 16),

            // ── Quick spots heading ───────────────────────────
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Quick Check — Known HWC Zones',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
              ),
            ),
            const SizedBox(height: 8),

            // ── Spots grid ────────────────────────────────────
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 3.2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _spots.length,
                itemBuilder: (context, i) {
                  final spot = _spots[i];
                  final isSelected =
                      (_lat == spot['lat'] && _lon == spot['lon']);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _lat       = spot['lat'];
                        _lon       = spot['lon'];
                        _placeName = spot['name'];
                      });
                      _predictAndShow(spot['lat'], spot['lon']);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color:
                            isSelected ? Colors.white : Colors.white24,
                        borderRadius: BorderRadius.circular(10),
                        border: isSelected
                            ? Border.all(color: Colors.white, width: 2)
                            : null,
                      ),
                      child: Text(
                        spot['name'],
                        style: TextStyle(
                          color: isSelected ? _bgColor : Colors.white,
                          fontSize: 13,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  );
                },
              ),
            ),

            // ── Bottom buttons ────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _openSearch,
                    icon: const Icon(Icons.search),
                    label: const Text('Search Location'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: _bgColor,
                      padding:
                          const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _locating ? null : _toggleTracking,
                    icon: _locating
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : Icon(_tracked
                            ? Icons.stop
                            : Icons.my_location),
                    label: Text(_locating
                        ? 'Getting GPS...'
                        : _tracked
                            ? 'Stop Track'
                            : 'Track Me'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _tracked ? Colors.red : Colors.white24,
                      foregroundColor: Colors.white,
                      padding:
                          const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
