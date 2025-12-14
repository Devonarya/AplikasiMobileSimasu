import 'package:flutter/material.dart';
import 'package:simasu/pages/announcement_detail_page.dart';
import 'package:simasu/pages/kalender_page.dart';
import 'package:simasu/pages/profile_page.dart';
import 'package:simasu/pages/inventaris_page.dart';
import 'package:simasu/pages/ruangan_page.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:simasu/pages/upcoming_event_page.dart';
import 'dart:convert';
import 'package:simasu/models/announcement_model.dart';
import 'package:simasu/models/event_model.dart';
import 'package:simasu/services/api_service.dart';

class MasjidApp extends StatelessWidget {
  const MasjidApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Masjid Syamsul Ulum',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(0xFFF6F8F6),
        brightness: Brightness.light,
      ),
      home: const HomePage(),
    );
  }
}

// ===================== HOMEPAGE =====================
class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  List<AnnouncementModel> _announcements = [];
  List<EventModel> _events = [];
  bool _isLoading = true;

  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> _initNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);

    await notificationsPlugin.initialize(settings);

    final androidImplementation = notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await androidImplementation?.requestNotificationsPermission();
  }

  Future<void> _showNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'masjid_channel',
      'Masjid Syamsul Ulum',
      channelDescription: 'Notifikasi kegiatan masjid',
      importance: Importance.high,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: androidDetails);
    await notificationsPlugin.show(
      0,
      'Pengingat Kegiatan',
      'Jangan lupa hadir di acara malam ini!',
      details,
    );
  }

  Future<void> loadDashboardData() async {
    final annRes = await ApiService.getAnnouncements();
    final evRes = await ApiService.getEvents();

    final List annData = jsonDecode(annRes.body);
    final List evData = jsonDecode(evRes.body);

    setState(() {
      _announcements = annData
          .map((e) => AnnouncementModel.fromJson(e))
          .toList();
      _events = evData.map((e) => EventModel.fromJson(e)).toList();
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _initNotifications();
    loadDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    final double horizontalPadding = 16;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: 12,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Small header "Home"
              const Text(
                'Home',
                style: TextStyle(color: Colors.black87, fontSize: 14),
              ),
              const SizedBox(height: 12),

              // Main scroll area
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GreetingCard(userName: 'A'),
                      const SizedBox(height: 18),

                      // Berita section
                      const Text(
                        'Berita & Pengumuman',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Announcement cards
                      SizedBox(
                        height: 130,
                        child: _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _announcements.length,
                                itemBuilder: (context, index) {
                                  final a = _announcements[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 12),
                                    child: AnnouncementCard(
                                      title: a.title,
                                      subtitle: a.content,
                                      tag: a.tag,
                                      width: 230,
                                    ),
                                  );
                                },
                              ),
                      ),

                      const SizedBox(height: 22),

                      // Agenda header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Upcoming Event',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const UpcomingEventPage(),
                                ),
                              );
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(40, 30),
                            ),
                            child: const Text('Lihat semua'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Agenda list
                      _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : Column(
                              children: _events
                                  .map(
                                    (e) => Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8.0,
                                      ),
                                      child: GestureDetector(
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (ctx) => AlertDialog(
                                              title: Text(e.title),
                                              content: Text(
                                                'Pembicara: ${e.speaker}\n'
                                                'Tanggal: ${e.eventDate}\n'
                                                'Tempat: ${e.location}',
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(ctx);
                                                    _showNotification();
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                          'Peringatan sudah diaktifkan',
                                                        ),
                                                        duration: Duration(
                                                          seconds: 2,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  child: const Text(
                                                    'Ingatkan Saya',
                                                  ),
                                                ),
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(ctx),
                                                  child: const Text('Tutup'),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                        child: AgendaCard(
                                          item: AgendaItem(
                                            title: e.title,
                                            subtitle: e.speaker,
                                            datetime: e.eventDate,
                                            tag: e.location,
                                            timeLabel: e.eventTime,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),

                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      // Navbar
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
}

// Components

class GreetingCard extends StatelessWidget {
  final String userName;
  const GreetingCard({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.06),
            blurRadius: 20,
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
                const Text(
                  'MASJID SYAMSUL ULUM',
                  style: TextStyle(fontSize: 11, color: Colors.green),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Text(
                      'Assalamualaikum, ',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      userName,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text('👋', style: TextStyle(fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Semoga harimu penuh keberkahan. Pantau aktivitas masjid dengan mudah.',
                  style: TextStyle(fontSize: 13, color: Colors.black54),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFE6F7EC),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(8),
            child: const Icon(Icons.settings, color: Color(0xFF1E8A3E)),
          ),
        ],
      ),
    );
  }
}

class AnnouncementCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String tag;
  final double width;

  const AnnouncementCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.tag,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AnnouncementDetailPage(
              title: title,
              subtitle: subtitle,
              tag: tag,
            ),
          ),
        );
      },
      child: Container(
        width: width,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1E8A3E), Color(0xFF60C375)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.12),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                tag,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Text(
                subtitle,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AgendaCard extends StatelessWidget {
  final AgendaItem item;
  const AgendaCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.subtitle,
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF8F0),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        item.tag,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      item.datetime,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black45,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (item.timeLabel != null)
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF8F0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    item.timeLabel!,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class AgendaItem {
  final String title;
  final String subtitle;
  final String datetime;
  final String tag;
  final String? timeLabel;

  AgendaItem({
    required this.title,
    required this.subtitle,
    required this.datetime,
    required this.tag,
    this.timeLabel,
  });
}
