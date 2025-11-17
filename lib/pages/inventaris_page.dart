import 'package:flutter/material.dart';
import 'package:simasu/pages/dashboard_page.dart';
import 'package:simasu/pages/kalender_page.dart';
import 'package:simasu/pages/profile_page.dart';
import 'package:simasu/pages/ruangan_page.dart';

class InventarisPage extends StatefulWidget {
  const InventarisPage({Key? key}) : super(key: key);

  @override
  State<InventarisPage> createState() => _InventarisPageState();
}

class _InventarisPageState extends State<InventarisPage> {
  int _selectedIndex = 1;

  // Data inventaris dengan stok
  final List<Map<String, dynamic>> _inventoryItems = [
    {
      'title': 'Speaker Portable JBL',
      'subtitle': 'Peralatan Audiovisual',
      'icon': Icons.speaker,
      'stock': 4,
    },
    {
      'title': 'Proyektor Full HD',
      'subtitle': 'Multimedia Sangat baik',
      'icon': Icons.videocam,
      'stock': 0,
    },
    {
      'title': 'Karpet Tambahan',
      'subtitle': 'Perabotan Sholat-Lantai',
      'icon': Icons.calendar_view_day,
      'stock': 15,
    },
    {
      'title': 'Microphone Wireless',
      'subtitle': 'Peralatan Audio',
      'icon': Icons.mic,
      'stock': 8,
    },
  ];

  String _getStockStatus(int stock) {
    if (stock == 0) return 'Habis';
    if (stock < 10) return 'Terbatas';
    return 'Tersedia';
  }

  Color _getStockColor(int stock) {
    if (stock == 0) return Colors.red;
    if (stock < 10) return Colors.orange;
    return const Color(0xFF4CAF50);
  }

  void _handleBooking(String itemName, int stock) {
    if (stock == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Maaf, $itemName sedang tidak tersedia'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    TextEditingController nameController = TextEditingController();
    TextEditingController phoneController = TextEditingController();
    int quantity = 1;

    DateTime? bookingDate;
    DateTime? returnDate;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                "Booking $itemName",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Nama Peminjam", style: TextStyle(fontSize: 13)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        hintText: "Masukkan nama",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    const Text("Nomor Telepon", style: TextStyle(fontSize: 13)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        hintText: "Masukkan nomor telepon",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    const Text("Jumlah Barang", style: TextStyle(fontSize: 13)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            if (quantity > 1) setState(() => quantity--);
                          },
                          icon: const Icon(
                            Icons.remove_circle,
                            color: Colors.red,
                            size: 28,
                          ),
                        ),

                        Text(
                          quantity.toString(),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        IconButton(
                          onPressed: () {
                            if (quantity < stock) setState(() => quantity++);
                          },
                          icon: const Icon(
                            Icons.add_circle,
                            color: Colors.green,
                            size: 28,
                          ),
                        ),

                        const SizedBox(width: 8),
                        Text(
                          "/ $stock unit tersedia",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    const Text(
                      "Tanggal Booking",
                      style: TextStyle(fontSize: 13),
                    ),
                    const SizedBox(height: 6),

                    GestureDetector(
                      onTap: () async {
                        DateTime? pick = await showDatePicker(
                          context: context,
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2030),
                          initialDate: bookingDate ?? DateTime.now(),
                        );

                        if (pick != null) {
                          setState(() => bookingDate = pick);
                          if (returnDate != null &&
                              returnDate!.isBefore(pick)) {
                            setState(() => returnDate = null);
                          }
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              bookingDate == null
                                  ? "Pilih tanggal booking"
                                  : "${bookingDate!.day}-${bookingDate!.month}-${bookingDate!.year}",
                              style: TextStyle(
                                fontSize: 13,
                                color: bookingDate == null
                                    ? Colors.grey
                                    : Colors.black,
                              ),
                            ),
                            const Icon(Icons.calendar_today, size: 18),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // TANGGAL KEMBALI
                    const Text(
                      "Tanggal Kembali",
                      style: TextStyle(fontSize: 13),
                    ),
                    const SizedBox(height: 6),

                    GestureDetector(
                      onTap: () async {
                        if (bookingDate == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Harap pilih tanggal booking terlebih dahulu',
                              ),
                              backgroundColor: Colors.orange,
                            ),
                          );
                          return;
                        }

                        DateTime? pick = await showDatePicker(
                          context: context,
                          firstDate: bookingDate!,
                          lastDate: DateTime(2030),
                          initialDate: bookingDate!,
                        );

                        if (pick != null) {
                          setState(() => returnDate = pick);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              returnDate == null
                                  ? "Pilih tanggal kembali"
                                  : "${returnDate!.day}-${returnDate!.month}-${returnDate!.year}",
                              style: TextStyle(
                                fontSize: 13,
                                color: returnDate == null
                                    ? Colors.grey
                                    : Colors.black,
                              ),
                            ),
                            const Icon(Icons.calendar_today, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Batal"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    if (nameController.text.isEmpty ||
                        phoneController.text.isEmpty ||
                        bookingDate == null ||
                        returnDate == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Harap isi semua data"),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      return;
                    }

                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Berhasil booking $itemName x$quantity!"),
                        backgroundColor: const Color(0xFF4CAF50),
                      ),
                    );
                  },
                  child: const Text("Booking"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Inventaris',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
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
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'MASJID SYAMSUL ULUM',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Kelola Inventaris',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Peminjaman barang cepat dan transparan untuk semua jamaah',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.inventory_2,
                        color: Color(0xFF4CAF50),
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.inventory_2_outlined,
                      color: Color(0xFF4CAF50),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'INVENTARIS MASJID',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[600],
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Peminjaman Barang',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Pilih barang yang tersedia dan ajukan peminjaman dengan mudah.',
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
              const SizedBox(height: 20),

              // List inventaris
              ...List.generate(_inventoryItems.length, (index) {
                final item = _inventoryItems[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildInventoryItem(
                    item['title'],
                    item['subtitle'],
                    item['icon'],
                    item['stock'],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
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
      ),
    );
  }

  Widget _buildBottomIcon(IconData icon, String label, int index) {
    final bool active = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedIndex = index);
        if (index == 0) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        } else if (index == 2) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const RuanganPage()),
          );
        } else if (index == 3) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const KalenderPage()),
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

  Widget _buildInventoryItem(
    String title,
    String subtitle,
    IconData icon,
    int stock,
  ) {
    final stockStatus = _getStockStatus(stock);
    final stockColor = _getStockColor(stock);
    final isAvailable = stock > 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF4CAF50), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: stockColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.circle, size: 8, color: stockColor),
                          const SizedBox(width: 4),
                          Text(
                            stockStatus,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: stockColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$stock unit',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => _handleBooking(title, stock),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: isAvailable ? const Color(0xFF4CAF50) : Colors.grey[400],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Book',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
