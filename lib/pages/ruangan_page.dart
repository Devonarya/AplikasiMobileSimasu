import 'package:flutter/material.dart';
import 'package:simasu/pages/dashboard_page.dart' as dashboard;
import 'package:simasu/pages/kalender_page.dart';
import 'package:simasu/pages/profile_page.dart';
import 'package:simasu/pages/inventaris_page.dart';

import 'package:simasu/models/ruangan_model.dart';
import 'package:simasu/services/ruangan_service.dart';
import 'package:simasu/services/booking_service.dart';
import 'package:simasu/services/session_manager.dart';

class RuanganPage extends StatefulWidget {
  const RuanganPage({Key? key}) : super(key: key);

  @override
  State<RuanganPage> createState() => _RuanganPageState();
}

class _RuanganPageState extends State<RuanganPage> {
  int _selectedIndex = 2;

  late Future<List<RuanganItem>> _roomFuture;
  final RuanganService _roomService = RuanganService();
  final BookingService _bookingService = BookingService();

  @override
  void initState() {
    super.initState();
    _roomFuture = _roomService.fetchRuangan();
  }

  Future<void> _refreshRooms() async {
    setState(() {
      _roomFuture = _roomService.fetchRuangan();
    });
    try {
      await _roomFuture;
    } catch (_) {
      // ignore
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Ruangan',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _refreshRooms,
            icon: const Icon(Icons.refresh, color: Colors.black54),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshRooms,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ================= HEADER =================
              Container(
                margin: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF3F9F4), Color(0xFFEAF4ED)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1E8A3E).withOpacity(0.08),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'MASJID SYAMSUL ULUM',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green[700],
                              fontWeight: FontWeight.w700,
                              letterSpacing: 3,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Atur Peminjaman Ruangan',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Sesuaikan jadwal kegiatan masjid sesuai kebutuhan komunitas.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDFF0E5),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.12),
                            blurRadius: 10,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.meeting_room,
                        color: Color(0xFF2F6E3E),
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ),

              // ================= SECTION RUANGAN =================
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: const Color(0xFFDFF0E5),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(
                            Icons.calendar_today,
                            color: Color(0xFF2F6E3E),
                            size: 14,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'RUANGAN MASJID',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green[700],
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Peminjaman Ruangan',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Ajukan peminjaman ruangan untuk kegiatan masjid dengan mudah.',
                      style: TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                    const SizedBox(height: 16),

                    // ================= ROOM LIST FROM API =================
                    FutureBuilder<List<RuanganItem>>(
                      future: _roomFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 40),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        if (snapshot.hasError) {
                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Gagal memuat ruangan',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  snapshot.error.toString().replaceFirst(
                                    'Exception: ',
                                    '',
                                  ),
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  height: 40,
                                  child: ElevatedButton.icon(
                                    onPressed: _refreshRooms,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF4CAF50),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    icon: const Icon(
                                      Icons.refresh,
                                      color: Colors.white,
                                    ),
                                    label: const Text('Coba lagi'),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        final rooms = snapshot.data ?? <RuanganItem>[];
                        if (rooms.isEmpty) {
                          return Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Text(
                                'Belum ada data ruangan.',
                                style: TextStyle(color: Colors.black54),
                              ),
                            ),
                          );
                        }

                        return Column(
                          children: [
                            for (final room in rooms) ...[
                              _buildRoomCard(room),
                              const SizedBox(height: 12),
                            ],
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      // ================= BOTTOM NAVIGATION =================
      bottomNavigationBar: _buildBottomNavbar(),
    );
  }

  // ================= BOTTOM NAVIGATION =================
  Widget _buildBottomNavbar() {
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

  // ================= BOTTOM ICON =================
  Widget _buildBottomIcon(IconData icon, String label, int index) {
    final bool active = _selectedIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() => _selectedIndex = index);

        switch (index) {
          case 0:
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const dashboard.MasjidApp()));
            break;
          case 1:
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const InventarisPage()));
            break;
          case 3:
            Navigator.push(
                context, MaterialPageRoute(builder: (_) => const KalenderPage()));
            break;
          case 4:
            Navigator.push(
                context, MaterialPageRoute(builder: (_) => const ProfilePage()));
            break;
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: active ? const Color(0xFF1E8A3E) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 22,
              color: active ? Colors.white : Colors.black54,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: active ? const Color(0xFF1E8A3E) : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  // ================= RUANGAN CARD =================
  Widget _buildRoomCard(RuanganItem room) {
    final isAvailable = room.isAvailable;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  room.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),

                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDFF0E5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'Kapasitas ${room.capacity}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2F6E3E),
                    ),
                  ),
                ),

                if (room.facilities != null &&
                    room.facilities!.trim().isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.check_circle_outline,
                          size: 16, color: Colors.green[700]),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          room.facilities!,
                          style: const TextStyle(
                              fontSize: 12, color: Colors.black54),
                        ),
                      ),
                    ],
                  ),
                ],

                if (room.description != null &&
                    room.description!.trim().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    room.description!,
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  ),
                ],

                if (!isAvailable) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Sedang Tidak Tersedia',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(width: 12),

          ElevatedButton(
            onPressed: isAvailable ? () => _showPeminjamanDialog(room) : null,
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isAvailable ? const Color(0xFF1E8A3E) : Colors.grey[400],
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              elevation: 0,
            ),
            child: const Text(
              'Ajukan\nPeminjaman',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= FORM DIALOG =================
  void _showPeminjamanDialog(RuanganItem room) {
    final nama = TextEditingController();
    final kepentingan = TextEditingController();
    final kontak = TextEditingController();

    DateTime tanggal = DateTime.now();
    TimeOfDay mulai = TimeOfDay.now();
    TimeOfDay selesai = TimeOfDay(hour: TimeOfDay.now().hour + 2, minute: 0);
    bool isSubmitting = false;

    // Prefill dari session
    SessionManager.getUserName().then((v) {
      if (v != null && v.trim().isNotEmpty && nama.text.trim().isEmpty) {
        nama.text = v;
      }
    });
    SessionManager.getUserPhone().then((v) {
      if (v != null && v.trim().isNotEmpty && kontak.text.trim().isEmpty) {
        kontak.text = v;
      }
    });

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogCtx, setStateDialog) => Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ------------------- Header -------------------
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDFF0E5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.meeting_room,
                          color: Color(0xFF2F6E3E),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Ajukan Peminjaman",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w800),
                            ),
                            Text(
                              room.name,
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.green[700],
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ------------------- Fields -------------------
                  _label("Nama Pemohon"),
                  _input(nama, "Contoh: Ahmad Fauzi"),
                  const SizedBox(height: 16),

                  _label("Kepentingan/Acara"),
                  _input(kepentingan, "Contoh: Kajian Bulanan", max: 2),
                  const SizedBox(height: 16),

                  _label("Nomor Kontak"),
                  _input(kontak, "Contoh: 081234567890",
                      type: TextInputType.phone),
                  const SizedBox(height: 16),

                  _label("Tanggal Peminjaman"),
                  InkWell(
                    onTap: isSubmitting
                        ? null
                        : () async {
                            DateTime? pick = await showDatePicker(
                              context: dialogContext,
                              initialDate: tanggal,
                              firstDate: DateTime.now(),
                              lastDate:
                                  DateTime.now().add(const Duration(days: 365)),
                            );
                            if (pick != null) {
                              setStateDialog(() => tanggal = pick);
                            }
                          },
                    child: _dateBox(
                        "${tanggal.day.toString().padLeft(2, '0')}/${tanggal.month.toString().padLeft(2, '0')}/${tanggal.year}"),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _label("Waktu Mulai"),
                            InkWell(
                              onTap: isSubmitting
                                  ? null
                                  : () async {
                                      TimeOfDay? pick = await showTimePicker(
                                          context: dialogContext,
                                          initialTime: mulai);
                                      if (pick != null) {
                                        setStateDialog(() => mulai = pick);
                                      }
                                    },
                              child: _dateBox(
                                  "${mulai.hour.toString().padLeft(2, '0')}:${mulai.minute.toString().padLeft(2, '0')}"),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _label("Waktu Selesai"),
                            InkWell(
                              onTap: isSubmitting
                                  ? null
                                  : () async {
                                      TimeOfDay? pick = await showTimePicker(
                                          context: dialogContext,
                                          initialTime: selesai);
                                      if (pick != null) {
                                        setStateDialog(() => selesai = pick);
                                      }
                                    },
                              child: _dateBox(
                                  "${selesai.hour.toString().padLeft(2, '0')}:${selesai.minute.toString().padLeft(2, '0')}"),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ------------------- Buttons -------------------
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: isSubmitting
                              ? null
                              : () => Navigator.pop(dialogContext),
                          style: TextButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14)),
                          child: const Text("Batal",
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isSubmitting
                              ? null
                              : () async {
                                  if (nama.text.trim().isEmpty ||
                                      kepentingan.text.trim().isEmpty ||
                                      kontak.text.trim().isEmpty) {
                                    ScaffoldMessenger.of(this.context)
                                        .showSnackBar(
                                      const SnackBar(
                                        backgroundColor: Colors.orange,
                                        behavior: SnackBarBehavior.floating,
                                        content: Text(
                                            'Harap lengkapi semua data'),
                                      ),
                                    );
                                    return;
                                  }

                                  final start = DateTime(
                                    tanggal.year,
                                    tanggal.month,
                                    tanggal.day,
                                    mulai.hour,
                                    mulai.minute,
                                  );
                                  final end = DateTime(
                                    tanggal.year,
                                    tanggal.month,
                                    tanggal.day,
                                    selesai.hour,
                                    selesai.minute,
                                  );

                                  if (!end.isAfter(start)) {
                                    ScaffoldMessenger.of(this.context)
                                        .showSnackBar(
                                      const SnackBar(
                                        backgroundColor: Colors.orange,
                                        behavior: SnackBarBehavior.floating,
                                        content: Text(
                                          'Waktu selesai harus setelah waktu mulai',
                                        ),
                                      ),
                                    );
                                    return;
                                  }

                                  final notes =
                                      'Nama Pemohon: ${nama.text.trim()}\n'
                                      'Kontak: ${kontak.text.trim()}\n'
                                      'Keperluan: ${kepentingan.text.trim()}';

                                  setStateDialog(() => isSubmitting = true);

                                  try {
                                    await _bookingService.createBooking(
                                      type: 'room',
                                      itemId: room.id,
                                      itemName: room.name,
                                      start: start,
                                      end: end,
                                      quantity: 1,
                                      notes: notes,
                                    );

                                    if (!mounted) return;
                                    Navigator.pop(dialogContext);

                                    ScaffoldMessenger.of(this.context)
                                        .showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Pengajuan peminjaman ${room.name} berhasil dikirim — menunggu persetujuan admin',
                                        ),
                                        backgroundColor:
                                            const Color(0xFF4CAF50),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  } catch (e) {
                                    setStateDialog(() => isSubmitting = false);
                                    ScaffoldMessenger.of(this.context)
                                        .showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          e.toString().replaceFirst(
                                            'Exception: ',
                                            '',
                                          ),
                                        ),
                                        backgroundColor: Colors.red,
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1E8A3E),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14)),
                          child: isSubmitting
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Text(
                                  "Ajukan",
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white),
                                ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ================= Helper Widgets =================

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text,
            style:
                const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      );

  Widget _input(TextEditingController c, String hint,
      {int max = 1, TextInputType type = TextInputType.text}) {
    return TextField(
      controller: c,
      maxLines: max,
      keyboardType: type,
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
    );
  }

  Widget _dateBox(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(text),
          const Icon(Icons.calendar_today,
              size: 18, color: Color(0xFF2F6E3E)),
        ],
      ),
    );
  }
}