import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

import 'package:simasu/pages/announcement_detail_page.dart';
import 'package:simasu/pages/kalender_page.dart';
import 'package:simasu/pages/profile_page.dart';
import 'package:simasu/pages/inventaris_page.dart';
import 'package:simasu/pages/ruangan_page.dart';
import 'package:simasu/pages/upcoming_event_page.dart';

import 'package:simasu/models/agenda_model.dart';
import 'package:simasu/services/agenda_service.dart';

import 'package:simasu/models/announcement_model.dart';
import 'package:simasu/services/announcement_service.dart';

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

//HOMEPAGE
class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  late Future<List<AgendaItem>> _agendaFuture;
  final AgendaService _agendaService = AgendaService();

  late Future<List<AnnouncementItem>> _announcementFuture;
  final AnnouncementService _announcementService = AnnouncementService();

  @override
  void initState() {
    super.initState();
    _initNotifications();

    _agendaFuture = _agendaService.fetchAgendas();
    _announcementFuture = _announcementService.fetchAnnouncements();
  }

  Future<void> _refreshData() async {
    setState(() {
      _agendaFuture = _agendaService.fetchAgendas();
      _announcementFuture = _announcementService.fetchAnnouncements();
    });
  }

  Future<void> _initNotifications() async {
    // Initialize timezone
    tz.initializeTimeZones();
    // Set timezone ke Asia/Jakarta (WIB)
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const initSettings = InitializationSettings(android: androidSettings);

    await notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint('Notification clicked: ${response.payload}');
      },
    );

    // Request notification permission untuk Android 13+
    final androidImplementation = notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    final granted = await androidImplementation
        ?.requestNotificationsPermission();
    debugPrint('Notification permission granted: $granted');
  }

  Future<void> _scheduleNotification(AgendaItem item) async {
    try {
      final scheduledTime = item.datetime.subtract(const Duration(minutes: 10));
      final now = DateTime.now();

      debugPrint('Current time: $now');
      debugPrint('Event time: ${item.datetime}');
      debugPrint('Notification scheduled for: $scheduledTime');

      if (scheduledTime.isBefore(now)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Waktu acara terlalu dekat (kurang dari 10 menit). Notifikasi akan muncul sekarang sebagai contoh.',
              ),
              duration: Duration(seconds: 3),
              backgroundColor: Colors.orange,
            ),
          );
        }
        // Untuk testing tampilkan notifikasi sekarang
        await _showImmediateNotification(item);
        return;
      }

      final tzScheduledTime = tz.TZDateTime.from(scheduledTime, tz.local);

      debugPrint('TZ Scheduled time: $tzScheduledTime');
      debugPrint('TZ Current time: ${tz.TZDateTime.now(tz.local)}');

      const androidDetails = AndroidNotificationDetails(
        'masjid_channel',
        'Masjid Syamsul Ulum',
        channelDescription: 'Notifikasi kegiatan masjid',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
        icon: '@mipmap/ic_launcher',
        enableVibration: true,
        playSound: true,
      );
      const details = NotificationDetails(android: androidDetails);

      final notificationId = '${item.title}${item.datetime}'.hashCode.abs();

      await notificationsPlugin.zonedSchedule(
        notificationId,
        'Pengingat: ${item.title}',
        'Acara akan dimulai dalam 10 menit di ${item.tag}',
        tzScheduledTime,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: item.title,
      );

      final pendingNotifications = await notificationsPlugin
          .pendingNotificationRequests();
      debugPrint('Total pending notifications: ${pendingNotifications.length}');
      for (var notif in pendingNotifications) {
        debugPrint('Pending: ID=${notif.id}, Title=${notif.title}');
      }

      if (mounted) {
        final difference = scheduledTime.difference(now);
        final hours = difference.inHours;
        final minutes = difference.inMinutes % 60;

        String timeMessage = '';
        if (hours > 0) {
          timeMessage = '$hours jam $minutes menit';
        } else {
          timeMessage = '$minutes menit';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Pengingat diatur untuk $timeMessage lagi\n(10 menit sebelum acara)',
            ),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'Test Sekarang',
              textColor: Colors.white,
              onPressed: () => _showImmediateNotification(item),
            ),
          ),
        );
      }
    } catch (e, stackTrace) {
      debugPrint('Error scheduling notification: $e');
      debugPrint('Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengatur pengingat: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  //fungsi test notif
  Future<void> _showImmediateNotification(AgendaItem item) async {
    const androidDetails = AndroidNotificationDetails(
      'masjid_channel',
      'Masjid Syamsul Ulum',
      channelDescription: 'Notifikasi kegiatan masjid',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
      enableVibration: true,
      playSound: true,
    );
    const details = NotificationDetails(android: androidDetails);

    final notificationId = DateTime.now().millisecondsSinceEpoch % 100000;

    await notificationsPlugin.show(
      notificationId,
      'Pengingat: ${item.title}',
      'Acara akan dimulai segera di ${item.tag}',
      details,
      payload: item.title,
    );

    debugPrint('Immediate notification sent with ID: $notificationId');
  }

  Future<void> _cancelNotification(AgendaItem item) async {
    final notificationId = '${item.title}${item.datetime}'.hashCode.abs();
    await notificationsPlugin.cancel(notificationId);

    debugPrint('Cancelled notification ID: $notificationId');

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pengingat dibatalkan'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const double horizontalPadding = 16;
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Beranda',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Main scroll area
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refreshData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const GreetingCard(userName: 'Jamaah'),
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

                        // Announcement Cards
                        SizedBox(
                          height: 130,
                          child: FutureBuilder<List<AnnouncementItem>>(
                            future: _announcementFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }

                              if (snapshot.hasError) {
                                return Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      "Gagal memuat berita",
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                );
                              }

                              final list = snapshot.data ?? [];
                              if (list.isEmpty) {
                                return Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      "Belum ada pengumuman",
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                );
                              }

                              return ListView.separated(
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                itemCount: list.length,
                                separatorBuilder: (context, index) =>
                                    const SizedBox(width: 12),
                                itemBuilder: (context, index) {
                                  final item = list[index];
                                  final double cardWidth = index == 0
                                      ? 260
                                      : 220;

                                  return AnnouncementCard(
                                    title: item.title,
                                    subtitle: item.subtitle,
                                    tag: item.tag,
                                    width: cardWidth,
                                  );
                                },
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

                        // Agenda list (FROM API)
                        FutureBuilder<List<AgendaItem>>(
                          future: _agendaFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 32.0),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }

                            if (snapshot.hasError) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 20.0,
                                ),
                                child: Center(
                                  child: Column(
                                    children: [
                                      const Icon(
                                        Icons.error_outline,
                                        color: Colors.red,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        "Gagal memuat agenda.\n${snapshot.error.toString().replaceFirst('Exception: ', '')}",
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: Colors.grey,
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: _refreshData,
                                        child: const Text("Coba Lagi"),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }

                            final agendaList = snapshot.data ?? [];

                            // Filter agenda: belum lewat atau sudah lewat maksimal 1 jam
                            final filteredAgendaList = agendaList.where((item) {
                              final difference = item.datetime.difference(
                                DateTime.now(),
                              );
                              return difference.inMinutes >=
                                  -60; // >= -60 artinya maksimal 1 jam lewat
                            }).toList();

                            if (filteredAgendaList.isEmpty) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 32.0),
                                child: Center(
                                  child: Text(
                                    "Belum ada agenda mendekati atau dalam 1 jam terakhir.",
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                              );
                            }

                            // Optional: urutkan dari yang paling dekat waktunya ke yang paling jauh
                            filteredAgendaList.sort(
                              (a, b) => a.datetime.compareTo(b.datetime),
                            );

                            return Column(
                              children: filteredAgendaList.map((item) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8.0,
                                  ),
                                  child: GestureDetector(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: Text(item.title),
                                          content: Text(
                                            'Pembicara: ${item.subtitle}\nTanggal: ${item.formattedDate}\nJam: ${item.formattedTime}\nTempat: ${item.tag}',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(ctx);
                                                _scheduleNotification(item);
                                              },
                                              child: const Text(
                                                'Ingatkan Saya',
                                              ),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(ctx);
                                                _cancelNotification(item);
                                              },
                                              child: const Text(
                                                'Batalkan Pengingat',
                                                style: TextStyle(
                                                  color: Colors.red,
                                                ),
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
                                    child: AgendaCard(item: item),
                                  ),
                                );
                              }).toList(),
                            );
                          },
                        ),
                        const SizedBox(height: 80),
                      ],
                    ),
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

// ===================== COMPONENTS =====================

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
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
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
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
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
                      item.formattedDate,
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
          if (item.formattedTime.isNotEmpty)
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
                    item.formattedTime,
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
