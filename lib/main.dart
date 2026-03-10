import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:screenshot/screenshot.dart';
import 'package:gal/gal.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
    ),
    home: const SplashScreen(), 
  ));
}

// --- LAYAR SPLASH SCREEN ---
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const TimeMarkPro()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.edit_location_alt, size: 100, color: Colors.white),
            const SizedBox(height: 20),
            const Text(
              "Timemark Editor",
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.2),
            ),
            const SizedBox(height: 10),
            Text(
              "Versi 1.0.0",
              style: TextStyle(fontSize: 16, color: Colors.white.withValues(alpha: 0.7)),
            ),
            const SizedBox(height: 50),
            const CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
          ],
        ),
      ),
    );
  }
}

// --- LAYAR UTAMA (EDITOR WATERMARK) ---
class TimeMarkPro extends StatefulWidget {
  const TimeMarkPro({super.key});

  @override
  State<TimeMarkPro> createState() => _TimeMarkProState();
}

class _TimeMarkProState extends State<TimeMarkPro> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  final ScreenshotController _screenshotController = ScreenshotController();
  final TextEditingController _textController = TextEditingController();

  String _currentTime = "";
  double _xOffset = 20.0;
  double _yOffset = 20.0;
  double _textSize = 14.0;
  double _bgOpacity = 0.0; 
  bool _isMirrored = true; 

  @override
  void initState() {
    super.initState();
    _updateTime();
    _textController.addListener(() {
      setState(() {});
    });
  }

  void _updateTime() {
    setState(() {
      _currentTime = DateFormat('d MMM yyyy HH.mm.ss').format(DateTime.now());
    });
  }

  // Dialog Ubah Waktu Manual
  void _showEditTimeDialog() {
    TextEditingController timeEditController = TextEditingController(text: _currentTime);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Waktu & Tanggal"),
          content: TextField(
            controller: timeEditController,
            decoration: const InputDecoration(
              labelText: "Format Bebas",
              border: OutlineInputBorder(),
              hintText: "Contoh: 2 Mar 2026 16.30.28",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
              onPressed: () {
                setState(() {
                  _currentTime = timeEditController.text; 
                });
                Navigator.pop(context);
              },
              child: const Text("Simpan"),
            ),
          ],
        );
      },
    );
  }

  // Ambil Foto
  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _updateTime(); 
        _xOffset = 20.0;
        _yOffset = 20.0;
      });
    }
  }

  // Simpan Hasil Akhir ke Galeri
  Future<void> _saveWatermark() async {
    if (_selectedImage == null) return;
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sedang menyimpan foto...')));
    }
    
    final Uint8List? imageBytes = await _screenshotController.capture(delay: const Duration(milliseconds: 100));

    if (imageBytes != null) {
      final tempDir = Directory.systemTemp;
      final file = await File('${tempDir.path}/timemark_custom.png').create();
      await file.writeAsBytes(imageBytes);
      await Gal.putImage(file.path);
      
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("✅ Foto berhasil disimpan!"), backgroundColor: Colors.green));
      }
    }
  }

  // Pindah ke Layar Peta
  Future<void> _openMapPicker() async {
    final selectedAddress = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MapPickerScreen()),
    );
    if (selectedAddress != null) {
      setState(() {
        _textController.text = selectedAddress;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Timemark Editor", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Area Preview Gambar
            Card(
              elevation: 4,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Screenshot(
                controller: _screenshotController,
                child: Container(
                  color: Colors.white,
                  child: Stack(
                    children: [
                      _selectedImage == null
                          ? Container(
                              height: 300,
                              width: double.infinity,
                              color: Colors.grey[200],
                              child: const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [Icon(Icons.add_a_photo, size: 60, color: Colors.grey), Text("Belum ada foto")],
                                ),
                              ),
                            )
                          : Image.file(_selectedImage!, width: double.infinity, fit: BoxFit.contain),

                      // Watermark Teks Bisa Digeser
                      if (_selectedImage != null)
                        Positioned(
                          left: _xOffset,
                          top: _yOffset,
                          child: GestureDetector(
                            onPanUpdate: (details) {
                              setState(() {
                                _xOffset += details.delta.dx;
                                _yOffset += details.delta.dy;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: _bgOpacity), 
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: _buildTextKeterangan(),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Tombol Kamera & Galeri
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera), 
                  icon: const Icon(Icons.camera_alt), 
                  label: const Text("Kamera"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
                ),
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery), 
                  icon: const Icon(Icons.photo_library), 
                  label: const Text("Galeri"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Area Pengaturan
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Mirror & Rata Kanan", style: TextStyle(fontWeight: FontWeight.bold)),
                        Switch(value: _isMirrored, onChanged: (val) => setState(() => _isMirrored = val)),
                      ],
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Waktu:", style: TextStyle(fontWeight: FontWeight.bold)),
                        Text("  $_currentTime", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        TextButton.icon(onPressed: _showEditTimeDialog, icon: const Icon(Icons.edit, size: 16), label: const Text("Ubah")),
                      ],
                    ),
                    const Divider(),
                    Row(
                      children: [
                        const Text("Ukuran"),
                        Expanded(child: Slider(value: _textSize, min: 10.0, max: 30.0, onChanged: (val) => setState(() => _textSize = val))),
                      ],
                    ),
                    Row(
                      children: [
                        const Text("Transparansi"),
                        Expanded(child: Slider(value: _bgOpacity, min: 0.0, max: 1.0, onChanged: (val) => setState(() => _bgOpacity = val))),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 15),

            // Input Teks & Maps
            TextField(
              controller: _textController,
              maxLines: 6,
              decoration: InputDecoration(
                labelText: "Keterangan Detail Lokasi",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: Colors.white,
                suffixIcon: IconButton(icon: const Icon(Icons.map, color: Colors.redAccent, size: 30), onPressed: _openMapPicker),
              ),
            ),
            const SizedBox(height: 20),

            // Tombol Simpan Akhir
            ElevatedButton.icon(
              onPressed: _selectedImage == null ? null : _saveWatermark,
              icon: const Icon(Icons.save_alt),
              label: const Text("Simpan Foto", style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 50)),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Komponen Teks Watermark
  Widget _buildTextKeterangan() {
    TextAlign align = _isMirrored ? TextAlign.right : TextAlign.left;
    CrossAxisAlignment crossAlign = _isMirrored ? CrossAxisAlignment.end : CrossAxisAlignment.start;

    return Column(
      crossAxisAlignment: crossAlign,
      children: [
        Text(
          _currentTime,
          textAlign: align,
          style: TextStyle(
            color: Colors.white,
            fontSize: _textSize,
            fontWeight: FontWeight.w500,
            shadows: const [Shadow(color: Colors.black, blurRadius: 3, offset: Offset(1, 1))],
          ),
        ),
        const SizedBox(height: 2),
        if (_textController.text.isNotEmpty)
          Text(
            _textController.text,
            textAlign: align,
            style: TextStyle(
              color: Colors.white,
              fontSize: _textSize,
              fontWeight: FontWeight.w500,
              height: 1.3,
              shadows: const [Shadow(color: Colors.black, blurRadius: 3, offset: Offset(1, 1))],
            ),
          ),
      ],
    );
  }
}

// --- LAYAR PETA PENCARIAN ---
class MapPickerScreen extends StatefulWidget {
  const MapPickerScreen({super.key});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  LatLng _centerPosition = const LatLng(-7.7256, 110.6006);
  bool _isLoading = false;
  
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();

  // Format ke Derajat (DMS)
  String _toDMS(double coordinate, bool isLatitude) {
    String direction = "";
    if (isLatitude) {
      direction = coordinate < 0 ? "S" : "N";
    } else {
      direction = coordinate < 0 ? "W" : "E";
    }
    
    double absolute = coordinate.abs();
    int degrees = absolute.floor();
    double minutesNotTruncated = (absolute - degrees) * 60;
    int minutes = minutesNotTruncated.floor();
    double seconds = (minutesNotTruncated - minutes) * 60;

    return "$degrees°$minutes'${seconds.toStringAsFixed(3)}\" $direction";
  }

  // Eksekusi Pencarian Lokasi
  Future<void> _searchLocation() async {
    if (_searchController.text.isEmpty) return;
    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);
    try {
      List<Location> locations = await locationFromAddress(_searchController.text);
      if (locations.isNotEmpty) {
        LatLng newPosition = LatLng(locations.first.latitude, locations.first.longitude);
        setState(() => _centerPosition = newPosition);
        _mapController.move(newPosition, 16.0);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lokasi tidak ditemukan!")));
      }
    }
    setState(() => _isLoading = false);
  }

  // Tarik Data Alamat dan Kembali ke Layar Utama
  Future<void> _getAddressAndReturn() async {
    setState(() => _isLoading = true);
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(_centerPosition.latitude, _centerPosition.longitude);

      String latDMS = _toDMS(_centerPosition.latitude, true);
      String longDMS = _toDMS(_centerPosition.longitude, false);
      String coordinateString = "$latDMS $longDMS";

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        List<String> addressLines = [];
        addressLines.add(coordinateString); 
        
        // --- BLOK NULL SAFETY YANG BENAR ---
        String street = place.street ?? "";
        String subLocality = place.subLocality ?? "";
        String locality = place.locality ?? "";
        String subAdmin = place.subAdministrativeArea ?? "";
        String adminArea = place.administrativeArea ?? "";

        if (street.isNotEmpty && street != subLocality) {
          addressLines.add(street);
        }
        if (subLocality.isNotEmpty) {
          addressLines.add(subLocality);
        }
        if (locality.isNotEmpty) {
          addressLines.add(locality);
        }
        if (subAdmin.isNotEmpty) {
          addressLines.add(subAdmin);
        }
        if (adminArea.isNotEmpty) {
          addressLines.add(adminArea);
        }
        // -----------------------------------

        String finalDetailAddress = addressLines.join("\n");
        if (mounted) Navigator.pop(context, finalDetailAddress);
      }
    } catch (e) {
      String latDMS = _toDMS(_centerPosition.latitude, true);
      String longDMS = _toDMS(_centerPosition.longitude, false);
      if (mounted) Navigator.pop(context, "$latDMS $longDMS\n(Detail jalan tidak tersedia)");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pilih Lokasi"), backgroundColor: Colors.indigo, foregroundColor: Colors.white),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController, 
            options: MapOptions(
              initialCenter: _centerPosition,
              initialZoom: 16.0, 
              onPositionChanged: (position, hasGesture) {
                if (hasGesture) setState(() => _centerPosition = position.center);
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://mt1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}',
                userAgentPackageName: 'com.example.timemark',
              ),
            ],
          ),
          const Center(child: Padding(padding: EdgeInsets.only(bottom: 40.0), child: Icon(Icons.location_pin, size: 50, color: Colors.red))),
          
          // Kolom Pencarian Melayang
          Positioned(
            top: 15, left: 15, right: 15,
            child: Card(
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Cari lokasi atau nama jalan...", border: InputBorder.none,
                  prefixIcon: const Icon(Icons.search), suffixIcon: IconButton(icon: const Icon(Icons.send), onPressed: _searchLocation),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                ),
                onSubmitted: (_) => _searchLocation(), 
              ),
            ),
          ),
          
          // Tombol Konfirmasi Melayang
          Positioned(
            bottom: 30, left: 20, right: 20,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _getAddressAndReturn,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 15)),
              child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("Gunakan Lokasi Ini", style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}