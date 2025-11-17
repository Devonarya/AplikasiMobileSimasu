import 'package:flutter/material.dart';
import 'dashboard_page.dart';
import 'inventaris_page.dart';
import 'profile_page.dart';
import 'ruangan_page.dart';

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

  // Data reservasi (tanggal: [jenis]) - hijau tua untuk ruangan, hijau muda untuk barang
  Map<int, List<String>> reservations = {
    9: ['ruangan'],
    10: ['barang'],
    15: ['ruangan', 'barang'],
    16: ['ruangan'],
    17: ['barang'],
    23: ['ruangan'],
  };

  // Data peminjaman
  List<Map<String, String>> peminjaman = [
    {'nama': 'Spanduk Peringkat Jitu', 'tanggal': '09'},
    {'nama': 'Proyektor Full HD', 'tanggal': '10'},
    {'nama': 'Spanduk Peringkat Jitu', 'tanggal': '15'},
    {'nama': 'Ruang Serbaguna', 'tanggal': '16'},
    {'nama': 'Ayub Haruna', 'tanggal': '17'},
    {'nama': 'Perpustakaan', 'tanggal': '23'},
    {'nama': 'Ayub Haruna', 'tanggal': '23'},
  ];

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

  void onDayTapped(int day) {
    setState(() {
      selectedDay = day;
    });
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Reservasi $day ${_getMonthName(selectedMonth.month)} ${selectedMonth.year}',
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.meeting_room, color: Colors.green),
              title: const Text('Sewa Ruangan'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Form sewa ruangan dibuka')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.inventory_2, color: Colors.green),
              title: const Text('Pinjam Barang'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Form pinjam barang dibuka')),
                );
              },
            ),
          ],
        ),
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
          // Header dengan scroll
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'MASJID AL-KAUTSAR',
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
                                crossAxisAlignment: CrossAxisAlignment.start,
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

                  // Kalender
                  Container(
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
                        // Month selector
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

                        // Days header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children:
                              ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab']
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

                        // Calendar grid
                        ...List.generate(6, (weekIndex) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 3),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: List.generate(7, (dayIndex) {
                                int dayNumber =
                                    weekIndex * 7 +
                                    dayIndex -
                                    getFirstDayOfWeek(selectedMonth) +
                                    1;
                                int daysInMonth = getDaysInMonth(selectedMonth);
                                if (dayNumber < 1 || dayNumber > daysInMonth) {
                                  return const SizedBox(width: 36, height: 36);
                                }

                                bool hasReservation = reservations.containsKey(
                                  dayNumber,
                                );
                                List<String>? types = reservations[dayNumber];
                                bool hasRuangan =
                                    types?.contains('ruangan') ?? false;
                                bool hasBarang =
                                    types?.contains('barang') ?? false;

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
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                if (hasRuangan)
                                                  _dot(const Color(0xFF2E7D32)),
                                                if (hasBarang)
                                                  _dot(
                                                    const Color(0xFF4CAF50),
                                                    opacity: 0.3,
                                                  ),
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
                  ),
                  const SizedBox(height: 20),

                  // Keterangan
                  _keterangan(),

                  const SizedBox(height: 20),

                  // Daftar Reservasi
                  _daftarReservasi(),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: _bottomNavBar(),
    );
  }

  // ======== Widget Helper ========
  Widget _circleIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: const BoxDecoration(
        color: Color(0xFFE8F5E9),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Color(0xFF4CAF50), size: 18),
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
              _dot(const Color(0xFF2E7D32)),
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
              _dot(const Color(0xFF4CAF50), opacity: 0.3),
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
          ...peminjaman.map((item) {
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
                        item['tanggal']!,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item['nama']!,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
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
    bool isSelected = currentNavIndex == index;
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
