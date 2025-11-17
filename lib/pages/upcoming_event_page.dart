import 'package:flutter/material.dart';

class UpcomingEventPage extends StatelessWidget {
  const UpcomingEventPage({super.key});

  // contoh data agenda (bisa pakai dari DB nanti)
  final List<Map<String, String>> agendaList = const [
    {
      'title': 'Kajian Tafsir Surah Yasin',
      'subtitle': 'Ust. Ahmad Faiz, Lc.',
      'datetime': 'Ahad, 12 Januari 2025',
      'tag': 'Ruang Utama',
      'timeLabel': '19.00 WIB'
    },
    {
      'title': 'Majelis Dzikir & Shalawat',
      'subtitle': 'Majelis Shalawat Al-Hikam',
      'datetime': 'Kamis, 16 Januari 2025',
      'tag': 'Aula Masjid',
      'timeLabel': '19.30 WIB'
    },
    {
      'title': 'Kelas Tahsin Remaja',
      'subtitle': 'Ustadzah Nur Aini',
      'datetime': 'Sabtu, 18 Januari 2025',
      'tag': 'Perpustakaan',
      'timeLabel': '08.00 WIB'
    },
    {
      'title': 'Kelas Agama Umum',
      'subtitle': 'Ustad Subhan',
      'datetime': 'Minggu, 19 Januari 2025',
      'tag': 'Ruang Sekre',
      'timeLabel': '08.00 WIB'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F6),
      appBar: AppBar(
        title: const Text(
          'Upcoming Event',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: ListView.builder(
        physics: const BouncingScrollPhysics(),
        itemCount: agendaList.length,
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          final item = agendaList[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon kalender
                Container(
                  margin: const EdgeInsets.only(right: 12, top: 4),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6F7EC),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.event, color: Color(0xFF1E8A3E)),
                ),
                // Informasi event
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['title'] ?? '',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['subtitle'] ?? '',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF8F0),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              item['tag'] ?? '',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            item['datetime'] ?? '',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black45,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.access_time,
                              size: 14, color: Colors.black45),
                          const SizedBox(width: 4),
                          Text(
                            item['timeLabel'] ?? '',
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
              ],
            ),
          );
        },
      ),
    );
  }
}
