import 'package:flutter/material.dart';
import 'package:simasu/pages/dashboard_page.dart' as dashboard;
import 'package:simasu/pages/kalender_page.dart';
import 'package:simasu/pages/profile_page.dart';
import 'inventaris_page.dart';

class RuanganPage extends StatefulWidget {
  const RuanganPage({Key? key}) : super(key: key);

  @override
  State<RuanganPage> createState() => _RuanganPageState();
}

class _RuanganPageState extends State<RuanganPage> {
  int _selectedIndex = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F6),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= HEADER =================
            Container(
              margin: const EdgeInsets.fromLTRB(16, 50, 16, 16),
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

                  _buildRoomCard(
                    title: 'Aula Utama',
                    capacity: 'Kapasitas 250',
                    facilities: 'AC • Sound System • Panggung',
                  ),
                  const SizedBox(height: 12),

                  _buildRoomCard(
                    title: 'Ruang Serbaguna',
                    capacity: 'Kapasitas 20',
                    facilities: 'LCD • Karpet Tebal • Whiteboard',
                  ),
                  const SizedBox(height: 12),

                  _buildRoomCard(
                    title: 'Perpustakaan',
                    capacity: 'Kapasitas 40',
                    facilities: 'Rak Buku • Meja Belajar • Wi-Fi',
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ],
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
  Widget _buildRoomCard({
    required String title,
    required String capacity,
    required String facilities,
  }) {
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
                  title,
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
                    capacity,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2F6E3E),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    Icon(Icons.check_circle_outline,
                        size: 16, color: Colors.green[700]),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        facilities,
                        style:
                            const TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          ElevatedButton(
            onPressed: () => _showPeminjamanDialog(title),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E8A3E),
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
  void _showPeminjamanDialog(String roomName) {
    final nama = TextEditingController();
    final kepentingan = TextEditingController();
    final kontak = TextEditingController();

    DateTime tanggal = DateTime.now();
    TimeOfDay mulai = TimeOfDay.now();
    TimeOfDay selesai =
        TimeOfDay(hour: TimeOfDay.now().hour + 2, minute: 0);

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogCtx, setStateDialog) => Dialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24)),
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Ajukan Peminjaman",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w800),
                          ),
                          Text(
                            roomName,
                            style: TextStyle(
                                fontSize: 14,
                                color: Colors.green[700],
                                fontWeight: FontWeight.w600),
                          ),
                        ],
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
                    onTap: () async {
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
                              onTap: () async {
                                TimeOfDay? pick =
                                    await showTimePicker(
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
                              onTap: () async {
                                TimeOfDay? pick =
                                    await showTimePicker(
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
                          onPressed: () => Navigator.pop(dialogContext),
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
                          onPressed: () {
                            if (nama.text.isEmpty ||
                                kepentingan.text.isEmpty ||
                                kontak.text.isEmpty) {
                              ScaffoldMessenger.of(this.context)
                                  .showSnackBar(SnackBar(
                                backgroundColor: Colors.orange[700],
                                behavior: SnackBarBehavior.floating,
                                content: const Row(
                                  children: [
                                    Icon(Icons.warning_amber_rounded,
                                        color: Colors.white),
                                    SizedBox(width: 12),
                                    Text("Mohon lengkapi semua data"),
                                  ],
                                ),
                              ));
                              return;
                            }

                            Navigator.pop(dialogContext);

                            Future.delayed(
                                const Duration(milliseconds: 120), () {
                              ScaffoldMessenger.of(this.context)
                                  .showSnackBar(SnackBar(
                                backgroundColor: const Color(0xFF1E8A3E),
                                behavior: SnackBarBehavior.floating,
                                margin: const EdgeInsets.all(16),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(16),
                                ),
                                content: Text(
                                    "Peminjaman $roomName berhasil diajukan!"),
                              ));
                            });
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1E8A3E),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14)),
                          child: const Text(
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
            style: const TextStyle(
                fontWeight: FontWeight.w600, fontSize: 14)),
      );

  Widget _input(TextEditingController c, String hint,
      {int max = 1, TextInputType type = TextInputType.text}) {
    return TextField(
      controller: c,
      maxLines: max,
      keyboardType: type,
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12)),
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
