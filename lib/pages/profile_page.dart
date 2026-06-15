import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../main.dart'; // untuk AuthPage saat logout
import '../models/booking_model.dart';
import '../services/booking_service.dart';
import '../services/session_manager.dart';
import '../services/profile_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _userName = 'Sheila';
  String _userEmail = 'sheilaa@gmail.com';
  String _userPhone = '';
  String _userAddress = '';
  String _profilePhotoUrl = '';

  final BookingService _bookingService = BookingService();
  final ProfileService _profileService = ProfileService();
  final ImagePicker _imagePicker = ImagePicker();

  late Future<List<BookingItem>> _bookingsFuture;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _bookingsFuture = _bookingService.fetchBookings();
    _loadUserFromSession();
    _fetchProfileFromServer();
  }

  Future<void> _loadUserFromSession() async {
    final name = await SessionManager.getUserName();
    final email = await SessionManager.getUserEmail();
    final phone = await SessionManager.getUserPhone();
    final address = await SessionManager.getUserAddress();
    final photo = await SessionManager.getUserPhoto();
    if (!mounted) return;
    setState(() {
      if (name != null && name.isNotEmpty) _userName = name;
      if (email != null && email.isNotEmpty) _userEmail = email;
      if (phone != null) _userPhone = phone;
      if (address != null) _userAddress = address;
      if (photo != null) _profilePhotoUrl = photo;
    });
  }

  Future<void> _fetchProfileFromServer() async {
    try {
      final data = await _profileService.fetchProfile();
      if (!mounted) return;
      setState(() {
        _userName = (data['name'] ?? '').toString();
        _userEmail = (data['email'] ?? '').toString();
        _userPhone = (data['phone'] ?? '').toString();
        _userAddress = (data['address'] ?? '').toString();
        _profilePhotoUrl = (data['profile_photo'] ?? '').toString();
      });
    } catch (_) {
      // Abaikan error jaringan saat inisialisasi awal, pakai cache lokal
    }
  }

  void _refreshBookings() {
    setState(() {
      _bookingsFuture = _bookingService.fetchBookings();
    });
  }

  String _categoryLabel(String type) {
    return type == 'room' ? 'PEMINJAMAN RUANGAN' : 'PEMINJAMAN BARANG';
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'Menunggu';
      case 'approved':
        return 'Disetujui';
      case 'rejected':
        return 'Ditolak';
      case 'completed':
        return 'Selesai';
      default:
        return status;
    }
  }

  Color _statusBg(String status) {
    switch (status) {
      case 'approved':
        return const Color(0xFFCDE7D6);
      case 'completed':
        return const Color(0xFFB9E0C7);
      case 'rejected':
        return const Color(0xFFFFCDD2);
      case 'pending':
      default:
        return const Color(0xFFFFE0B2);
    }
  }

  Color _statusFg(String status) {
    switch (status) {
      case 'approved':
      case 'completed':
        return const Color(0xFF2F6E3E);
      case 'rejected':
        return const Color(0xFFC62828);
      case 'pending':
      default:
        return const Color(0xFFEF6C00);
    }
  }

  Future<void> _handleLogout() async {
    await SessionManager.clear();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AuthPage()),
      (route) => false,
    );
  }

  // Pilih foto dari galeri HP dan langsung upload ke server
  Future<void> _handleSelectAndUploadPhoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image == null) return;

      setState(() {
        _isLoading = true;
      });

      final File file = File(image.path);
      final newPhotoPath = await _profileService.uploadPhoto(file);

      setState(() {
        _profilePhotoUrl = newPhotoPath;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto profil berhasil diperbarui')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Menampilkan modal dialog untuk mengubah biodata profil
  void _showEditProfileDialog() {
    final nameController = TextEditingController(text: _userName);
    final emailController = TextEditingController(text: _userEmail);
    final phoneController = TextEditingController(text: _userPhone);
    final addressController = TextEditingController(text: _userAddress);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text(
                'Edit Profil',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Nama Lengkap',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        hintText: 'Masukkan nama',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Email',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        hintText: 'Masukkan email',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Nomor Telepon',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        hintText: '08xxxxxxxxxx',
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Alamat',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: addressController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        hintText: 'Masukkan alamat',
                        prefixIcon: Icon(Icons.location_on_outlined),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: _isLoading ? null : () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2F6E3E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _isLoading
                      ? null
                      : () async {
                          setModalState(() => _isLoading = true);
                          try {
                            await _profileService.updateProfile(
                              name: nameController.text.trim(),
                              email: emailController.text.trim(),
                              phone: phoneController.text.trim(),
                              address: addressController.text.trim(),
                            );
                            await _loadUserFromSession();
                            if (mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Profil berhasil diperbarui'),
                                ),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    e.toString().replaceFirst(
                                      'Exception: ',
                                      '',
                                    ),
                                  ),
                                ),
                              );
                            }
                          } finally {
                            setModalState(() => _isLoading = false);
                          }
                        },
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Simpan',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Menampilkan modal dialog untuk mengganti password
  void _showChangePasswordDialog() {
    final currentPassController = TextEditingController();
    final newPassController = TextEditingController();
    final confirmPassController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text(
                'Ganti Password',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Password Lama',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: currentPassController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        hintText: 'Password saat ini',
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Password Baru',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: newPassController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        hintText: 'Password baru',
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Konfirmasi Password Baru',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: confirmPassController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        hintText: 'Ulangi password baru',
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: _isLoading ? null : () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2F6E3E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _isLoading
                      ? null
                      : () async {
                          if (newPassController.text !=
                              confirmPassController.text) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Konfirmasi password tidak cocok',
                                ),
                              ),
                            );
                            return;
                          }

                          setModalState(() => _isLoading = true);
                          try {
                            await _profileService.updatePassword(
                              currentPassword: currentPassController.text,
                              newPassword: newPassController.text,
                            );
                            if (mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Password berhasil diubah'),
                                ),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    e.toString().replaceFirst(
                                      'Exception: ',
                                      '',
                                    ),
                                  ),
                                ),
                              );
                            }
                          } finally {
                            setModalState(() => _isLoading = false);
                          }
                        },
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Ganti',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildProfilePhoto() {
    return GestureDetector(
      onTap: _isLoading ? null : _handleSelectAndUploadPhoto,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (_profilePhotoUrl.isNotEmpty)
            CircleAvatar(
              radius: 32,
              backgroundColor: const Color(0xFFEAF4ED),
              backgroundImage: NetworkImage(
                '${ProfileService.baseUrl}/$_profilePhotoUrl',
              ),
            )
          else
            const CircleAvatar(
              radius: 32,
              backgroundColor: const Color(0xFFEAF4ED),
              backgroundImage: AssetImage('assets/images/profile_default.png'),
            ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Color(0xFF2F6E3E),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.camera_alt,
                size: 14,
                color: Colors.white,
              ),
            ),
          ),
          if (_isLoading)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F6),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HeaderProfile(),
              const SizedBox(height: 16),

              // Kartu Informasi Akun
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        _buildProfilePhoto(),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _userName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _userEmail,
                                style: const TextStyle(color: Colors.black54),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24, thickness: 1),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton.icon(
                          onPressed: _showEditProfileDialog,
                          icon: const Icon(
                            Icons.edit,
                            color: Color(0xFF2F6E3E),
                            size: 18,
                          ),
                          label: const Text(
                            'Edit Profil',
                            style: TextStyle(color: Color(0xFF2F6E3E)),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                          child: VerticalDivider(
                            width: 1,
                            thickness: 1,
                            color: Colors.grey,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _showChangePasswordDialog,
                          icon: const Icon(
                            Icons.lock_outline,
                            color: Color(0xFF2F6E3E),
                            size: 18,
                          ),
                          label: const Text(
                            'Ganti Sandi',
                            style: TextStyle(color: Color(0xFF2F6E3E)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),
              const Text(
                'Pantau status pengajuan kapan pun.',
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 20),
              const Text(
                'Riwayat Peminjaman',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              FutureBuilder<List<BookingItem>>(
                future: _bookingsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
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
                            'Gagal memuat riwayat peminjaman',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            snapshot.error.toString().replaceFirst(
                              'Exception: ',
                              '',
                            ),
                            style: const TextStyle(color: Colors.red),
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: _refreshBookings,
                              child: const Text('Coba lagi'),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final bookings = snapshot.data ?? <BookingItem>[];
                  if (bookings.isEmpty) {
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
                          'Belum ada riwayat peminjaman.',
                          style: TextStyle(color: Colors.black54),
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: [
                      for (final b in bookings) ...[
                        _LoanHistoryCard(
                          category: _categoryLabel(b.type),
                          title: b.itemName,
                          start: 'Mulai: ${b.startLabel}',
                          end: 'Selesai: ${b.endLabel}',
                          note:
                              'Catatan: ${b.notes == null || b.notes!.trim().isEmpty ? '-' : b.notes!}',
                          statusLabel: _statusLabel(b.status),
                          statusColor: _statusBg(b.status),
                          statusTextColor: _statusFg(b.status),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ],
                  );
                },
              ),
              const SizedBox(height: 12),
              const SizedBox(height: 24),

              _LogoutButton(
                onTap: () {
                  _handleLogout();
                },
              ),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderProfile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MASJID AL-BAROKAH',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green[700],
                    fontWeight: FontWeight.w700,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Profil Jamaah',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Lihat riwayat peminjaman dan kelola akun Anda.',
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
              Icons.add_shopping_cart_rounded,
              color: Color(0xFF2F6E3E),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoanHistoryCard extends StatelessWidget {
  final String category;
  final String title;
  final String start;
  final String end;
  final String note;
  final String statusLabel;
  final Color statusColor;
  final Color statusTextColor;

  const _LoanHistoryCard({
    required this.category,
    required this.title,
    required this.start,
    required this.end,
    required this.note,
    required this.statusLabel,
    required this.statusColor,
    required this.statusTextColor,
  });

  @override
  Widget build(BuildContext context) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF4ED),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.receipt_long_outlined,
              color: Color(0xFF2F6E3E),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category,
                  style: TextStyle(
                    letterSpacing: 1.5,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Colors.green[700],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(start, style: const TextStyle(color: Colors.black54)),
                Text(end, style: const TextStyle(color: Colors.black54)),
                const SizedBox(height: 8),
                Text(note, style: const TextStyle(color: Colors.black87)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              statusLabel,
              style: TextStyle(
                color: statusTextColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  final VoidCallback onTap;
  const _LogoutButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: const Color(0xFFE06B6B),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE06B6B).withOpacity(0.3),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: const Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.logout, color: Colors.white),
              SizedBox(width: 10),
              Text(
                'Keluar',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
