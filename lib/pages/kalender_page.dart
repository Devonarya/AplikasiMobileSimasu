import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dashboard_page.dart';
import 'inventaris_page.dart';
import 'profile_page.dart';
import 'ruangan_page.dart';
import '../models/booking_model.dart';
import '../models/inventory_model.dart';
import '../models/ruangan_model.dart';
import '../services/booking_service.dart';
import '../services/inventory_service.dart';
import '../services/ruangan_service.dart';

class SimasuApp extends StatelessWidget {
  const SimasuApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: KalenderPage(),
    );
  }
}

class KalenderPage extends StatefulWidget {
  const KalenderPage({Key? key}) : super(key: key);

  @override
  State<KalenderPage> createState() => _KalenderPageState();
}

class _KalenderPageState extends State<KalenderPage> {
  DateTime selectedMonth = DateTime(2025, 1);
  int selectedDay = 0;
  int currentNavIndex = 3;

  List<BookingItem> allBookings = [];
  List<InventoryItem> inventoryItems = [];
  List<RuanganItem> ruanganItems = [];

  bool isLoading = true;
  String? errorMessage;

  final BookingService _bookingService = BookingService();
  final InventoryService _inventoryService = InventoryService();
  final RuanganService _ruanganService = RuanganService();

  static const Duration _apiTimeout = Duration(seconds: 20);

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      await _fetchAllData();
      if (!mounted) return;
      setState(() => isLoading = false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  /// Refresh data TANPA nyalain full-page loader.
  /// - Untuk pull-to-refresh: throwOnError = false (biar indikator stop)
  /// - Untuk submit booking: throwOnError = true (biar masuk catch)
  Future<void> _refreshData({bool throwOnError = false}) async {
    if (!mounted) return;
    setState(() => errorMessage = null);

    try {
      await _fetchAllData();
    } catch (e) {
      if (!mounted) return;
      setState(() => errorMessage = e.toString());
      if (throwOnError) rethrow;
    }
  }

  Future<void> _fetchAllData() async {
    final bookingsFuture = _bookingService.fetchBookings().timeout(_apiTimeout);
    final inventoryFuture = _inventoryService.fetchInventory().timeout(
      _apiTimeout,
    );
    final ruanganFuture = _ruanganService.fetchRuangan().timeout(_apiTimeout);

    final results = await Future.wait([
      bookingsFuture,
      inventoryFuture,
      ruanganFuture,
    ], eagerError: true).timeout(_apiTimeout);

    if (!mounted) return;
    setState(() {
      allBookings = results[0] as List<BookingItem>;
      inventoryItems = results[1] as List<InventoryItem>;
      ruanganItems = results[2] as List<RuanganItem>;
    });
  }

  Map<String, List<String>> get reservations {
    final Map<String, List<String>> result = {};

    for (final booking in allBookings) {
      final dateKey = DateFormat('yyyy-MM-dd').format(booking.startTime);

      result.putIfAbsent(dateKey, () => []);

      final type = booking.type == 'inventory' ? 'barang' : 'ruangan';
      if (!result[dateKey]!.contains(type)) {
        result[dateKey]!.add(type);
      }
    }

    return result;
  }

  List<BookingItem> _getFilteredBookings() {
    final yearMonth =
        '${selectedMonth.year}-${selectedMonth.month.toString().padLeft(2, '0')}';

    return allBookings.where((booking) {
      final bookingMonth = DateFormat('yyyy-MM').format(booking.startTime);
      return bookingMonth == yearMonth;
    }).toList();
  }

  void previousMonth() {
    setState(() {
      selectedMonth = DateTime(selectedMonth.year, selectedMonth.month - 1);
    });
  }

  void nextMonth() {
    setState(() {
      selectedMonth = DateTime(selectedMonth.year, selectedMonth.month + 1);
    });
  }

  int getDaysInMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0).day;
  }

  int getFirstDayOfWeek(DateTime date) {
    return DateTime(date.year, date.month, 1).weekday % 7;
  }

  String _getDateKey(int day) {
    return '${selectedMonth.year}-${selectedMonth.month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
  }

  void onDayTapped(int day) {
    setState(() {
      selectedDay = day;
    });
    _showReservationForm(day);
  }

  void _showReservationForm(int day) {
    String selectedType = 'Sewa Ruangan';
    int? selectedItemId;
    String selectedItemName = '';
    int quantity = 1;

    final peminjamController = TextEditingController();
    final notesController = TextEditingController();

    DateTime tanggalMulai = DateTime(
      selectedMonth.year,
      selectedMonth.month,
      day,
      8,
      0,
    );
    DateTime tanggalSelesai = DateTime(
      selectedMonth.year,
      selectedMonth.month,
      day,
      17,
      0,
    );
    TimeOfDay jamMulai = const TimeOfDay(hour: 8, minute: 0);
    TimeOfDay jamSelesai = const TimeOfDay(hour: 17, minute: 0);

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          final availableItems = selectedType == 'Sewa Ruangan'
              ? ruanganItems.where((r) => r.isAvailable).toList()
              : inventoryItems.where((i) => i.isAvailable).toList();

          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tambah Peminjaman/Sewa',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),

                    const Text(
                      'Tipe',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: selectedType,
                          items: ['Sewa Ruangan', 'Pinjam Barang']
                              .map(
                                (type) => DropdownMenuItem(
                                  value: type,
                                  child: Text(type),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setDialogState(() {
                              selectedType = value!;
                              selectedItemId = null;
                              selectedItemName = '';
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      'Pilih Item/Ruangan',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          isExpanded: true,
                          hint: const Text('Pilih item'),
                          value: selectedItemId,
                          items: availableItems.map((item) {
                            final name = selectedType == 'Sewa Ruangan'
                                ? (item as RuanganItem).name
                                : (item as InventoryItem).name;
                            final id = selectedType == 'Sewa Ruangan'
                                ? (item as RuanganItem).id
                                : (item as InventoryItem).id;

                            return DropdownMenuItem<int>(
                              value: id,
                              child: Text(name),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setDialogState(() {
                              selectedItemId = value;
                              final item = availableItems.firstWhere((i) {
                                if (selectedType == 'Sewa Ruangan') {
                                  return (i as RuanganItem).id == value;
                                } else {
                                  return (i as InventoryItem).id == value;
                                }
                              });
                              selectedItemName = selectedType == 'Sewa Ruangan'
                                  ? (item as RuanganItem).name
                                  : (item as InventoryItem).name;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    if (selectedType == 'Pinjam Barang') ...[
                      const Text(
                        'Jumlah',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: '1',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                        onChanged: (value) {
                          quantity = int.tryParse(value) ?? 1;
                        },
                      ),
                      const SizedBox(height: 16),
                    ],

                    const Text(
                      'Peminjam/Penyewa',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: peminjamController,
                      decoration: InputDecoration(
                        hintText: 'Contoh: Acara Walimah',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      'Tanggal Mulai',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: dialogContext,
                          initialDate: tanggalMulai,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) {
                          setDialogState(() {
                            tanggalMulai = DateTime(
                              picked.year,
                              picked.month,
                              picked.day,
                              jamMulai.hour,
                              jamMulai.minute,
                            );
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(DateFormat('dd/MM/yyyy').format(tanggalMulai)),
                            const Icon(Icons.calendar_today, size: 18),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: dialogContext,
                          initialTime: jamMulai,
                        );
                        if (picked != null) {
                          setDialogState(() {
                            jamMulai = picked;
                            tanggalMulai = DateTime(
                              tanggalMulai.year,
                              tanggalMulai.month,
                              tanggalMulai.day,
                              picked.hour,
                              picked.minute,
                            );
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${jamMulai.hour.toString().padLeft(2, '0')}:${jamMulai.minute.toString().padLeft(2, '0')}',
                            ),
                            const Icon(Icons.access_time, size: 18),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      'Tanggal Selesai',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: dialogContext,
                          initialDate: tanggalSelesai,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) {
                          setDialogState(() {
                            tanggalSelesai = DateTime(
                              picked.year,
                              picked.month,
                              picked.day,
                              jamSelesai.hour,
                              jamSelesai.minute,
                            );
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              DateFormat('dd/MM/yyyy').format(tanggalSelesai),
                            ),
                            const Icon(Icons.calendar_today, size: 18),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: dialogContext,
                          initialTime: jamSelesai,
                        );
                        if (picked != null) {
                          setDialogState(() {
                            jamSelesai = picked;
                            tanggalSelesai = DateTime(
                              tanggalSelesai.year,
                              tanggalSelesai.month,
                              tanggalSelesai.day,
                              picked.hour,
                              picked.minute,
                            );
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${jamSelesai.hour.toString().padLeft(2, '0')}:${jamSelesai.minute.toString().padLeft(2, '0')}',
                            ),
                            const Icon(Icons.access_time, size: 18),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      'Catatan (Opsional)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: notesController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Tambahkan catatan...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          child: const Text(
                            'Batal',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () async {
                            // Pakai context milik PAGE, bukan context dialog.
                            final rootContext = this.context;

                            if (selectedItemId == null) {
                              ScaffoldMessenger.of(rootContext).showSnackBar(
                                const SnackBar(
                                  content: Text('Pilih item terlebih dahulu'),
                                ),
                              );
                              return;
                            }

                            // Tutup form dialog dulu (pakai dialogContext).
                            Navigator.of(dialogContext).pop();

                            // Tampilkan loading dialog (pakai rootContext).
                            bool loadingShown = false;
                            showDialog(
                              context: rootContext,
                              barrierDismissible: false,
                              useRootNavigator: true,
                              builder: (_) {
                                loadingShown = true;
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              },
                            );

                            try {
                              await _bookingService
                                  .createBooking(
                                    type: selectedType == 'Sewa Ruangan'
                                        ? 'room'
                                        : 'inventory',
                                    itemId: selectedItemId!,
                                    itemName: selectedItemName,
                                    start: tanggalMulai,
                                    end: tanggalSelesai,
                                    quantity: quantity,
                                    notes: notesController.text.isEmpty
                                        ? peminjamController.text
                                        : notesController.text,
                                  )
                                  .timeout(_apiTimeout);

                              // Refresh data (kalau gagal, biar masuk catch)
                              await _refreshData(
                                throwOnError: true,
                              ).timeout(_apiTimeout);

                              if (!mounted) return;

                              // Tutup loading dialog
                              if (loadingShown &&
                                  Navigator.of(
                                    rootContext,
                                    rootNavigator: true,
                                  ).canPop()) {
                                Navigator.of(
                                  rootContext,
                                  rootNavigator: true,
                                ).pop();
                              }

                              ScaffoldMessenger.of(rootContext).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Reservasi berhasil ditambahkan',
                                  ),
                                ),
                              );
                            } catch (e) {
                              if (!mounted) return;

                              // Tutup loading dialog walaupun error
                              if (loadingShown &&
                                  Navigator.of(
                                    rootContext,
                                    rootNavigator: true,
                                  ).canPop()) {
                                Navigator.of(
                                  rootContext,
                                  rootNavigator: true,
                                ).pop();
                              }

                              ScaffoldMessenger.of(rootContext).showSnackBar(
                                SnackBar(content: Text('Gagal: $e')),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4CAF50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Simpan',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Error: $errorMessage'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadInitialData,
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () => _refreshData(throwOnError: false),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'MASJID Symasul Ulum',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Kalender',
                                            style: TextStyle(
                                              fontSize: 26,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            'Reservasi',
                                            style: TextStyle(
                                              fontSize: 26,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE8F5E9),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: const Icon(
                                        Icons.calendar_today,
                                        color: Color(0xFF4CAF50),
                                        size: 24,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'Untuk pilihan peminjaman\nruangan atau barang masjid',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _buildCalendar(),
                          const SizedBox(height: 20),
                          _keterangan(),
                          const SizedBox(height: 20),
                          _daftarReservasi(),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: _bottomNavBar(),
    );
  }

  Widget _buildCalendar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_getMonthName(selectedMonth.month)} ${selectedMonth.year}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Row(
                children: [
                  InkWell(
                    onTap: previousMonth,
                    child: _circleIcon(Icons.chevron_left),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: nextMonth,
                    child: _circleIcon(Icons.chevron_right),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab']
                .map(
                  (day) => SizedBox(
                    width: 36,
                    child: Center(
                      child: Text(
                        day,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 10),
          ...List.generate(6, (weekIndex) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(7, (dayIndex) {
                  final dayNumber =
                      weekIndex * 7 +
                      dayIndex -
                      getFirstDayOfWeek(selectedMonth) +
                      1;
                  final daysInMonth = getDaysInMonth(selectedMonth);

                  if (dayNumber < 1 || dayNumber > daysInMonth) {
                    return const SizedBox(width: 36, height: 36);
                  }

                  final dateKey = _getDateKey(dayNumber);
                  final hasReservation = reservations.containsKey(dateKey);
                  final types = reservations[dateKey];
                  final hasRuangan = types?.contains('ruangan') ?? false;
                  final hasBarang = types?.contains('barang') ?? false;

                  return InkWell(
                    onTap: () => onDayTapped(dayNumber),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: selectedDay == dayNumber
                            ? const Color(0xFF4CAF50)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: Text(
                              '$dayNumber',
                              style: TextStyle(
                                color: selectedDay == dayNumber
                                    ? Colors.white
                                    : Colors.black87,
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          if (hasReservation)
                            Positioned(
                              bottom: 4,
                              left: 0,
                              right: 0,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (hasRuangan)
                                    _dot(
                                      const Color.fromARGB(255, 37, 41, 255),
                                    ),
                                  if (hasBarang)
                                    _dot(const Color.fromARGB(255, 241, 16, 4)),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _circleIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: const BoxDecoration(
        color: Color(0xFFE8F5E9),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: const Color(0xFF4CAF50), size: 18),
    );
  }

  Widget _dot(Color color, {double opacity = 1.0}) {
    return Container(
      width: 4,
      height: 4,
      margin: const EdgeInsets.symmetric(horizontal: 1),
      decoration: BoxDecoration(
        color: color.withOpacity(opacity),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _keterangan() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Keterangan',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _dot(const Color.fromARGB(255, 37, 41, 255)),
              const SizedBox(width: 10),
              const Text(
                'Tanggal dengan peminjaman ruangan',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _dot(const Color.fromARGB(255, 241, 16, 4)),
              const SizedBox(width: 10),
              const Text(
                'Tanggal dengan peminjaman barang',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _daftarReservasi() {
    final filteredBookings = _getFilteredBookings();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Reservasi di Bulan Ini',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          if (filteredBookings.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              child: const Center(
                child: Text(
                  'Belum ada reservasi di bulan ini',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ),
            )
          else
            ...filteredBookings.map((booking) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          booking.startTime.day.toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking.itemName,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${DateFormat('HH:mm').format(booking.startTime)} - ${DateFormat('HH:mm').format(booking.endTime)}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                          ),
                          if (booking.type == 'inventory' &&
                              booking.quantity > 1)
                            Text(
                              'Jumlah: ${booking.quantity}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(booking.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _getStatusText(booking.status),
                        style: TextStyle(
                          fontSize: 10,
                          color: _getStatusColor(booking.status),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return const Color(0xFF4CAF50);
      case 'pending':
        return const Color(0xFFFFA726);
      case 'rejected':
        return const Color(0xFFEF5350);
      case 'completed':
        return const Color(0xFF42A5F5);
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return 'Disetujui';
      case 'pending':
        return 'Menunggu';
      case 'rejected':
        return 'Ditolak';
      case 'completed':
        return 'Selesai';
      default:
        return status;
    }
  }

  Widget _bottomNavBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildBottomIcon(Icons.home, 'Beranda', 0),
            _buildBottomIcon(Icons.inventory_2, 'Inventaris', 1),
            _buildBottomIcon(Icons.meeting_room, 'Ruangan', 2),
            _buildBottomIcon(Icons.calendar_month, 'Kalender', 3),
            _buildBottomIcon(Icons.person, 'Profil', 4),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomIcon(IconData icon, String label, int index) {
    final isSelected = currentNavIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() => currentNavIndex = index);
        if (index == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const InventarisPage()),
          );
        } else if (index == 2) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const RuanganPage()),
          );
        } else if (index == 0) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        } else if (index == 4) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProfilePage()),
          );
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF1E8A3E) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 22,
              color: isSelected ? Colors.white : Colors.black54,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isSelected ? const Color(0xFF1E8A3E) : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
