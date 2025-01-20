import 'dart:math'; // Tambahkan untuk warna acak
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:intl/intl.dart';

class CalendarTab extends StatelessWidget {
  final CollectionReference announcementReference =
      FirebaseFirestore.instance.collection("Announcements");

  // Format tanggal kustom yang digunakan di Firestore
  final DateFormat customDateFormat = DateFormat('h:mm a EEE, MMM d, yyyy');
  final Random random = Random(); // Inisialisasi generator angka acak

  // Mengambil data pengumuman dari Firestore dan mengonversinya ke format Meeting
  Future<List<Meeting>> _fetchAnnouncementsFromFirestore() async {
    final List<Meeting> meetings = [];
    final QuerySnapshot querySnapshot = await announcementReference.get();

    for (var doc in querySnapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;

      // Pastikan data memiliki field 'dateTime' dan 'dueDate' yang valid
      if (data['dateTime'] != null && data['dueDate'] != null) {
        DateTime? startDateTime;
        DateTime? endDateTime;

        // Konversi 'dateTime' ke DateTime
        if (data['dateTime'] is Timestamp) {
          startDateTime = (data['dateTime'] as Timestamp).toDate();
        } else if (data['dateTime'] is String) {
          try {
            startDateTime = customDateFormat.parse(data['dateTime']);
          } catch (e) {
            print("Error parsing dateTime: ${data['dateTime']}");
          }
        }

        // Konversi 'dueDate' ke DateTime
        if (data['dueDate'] is Timestamp) {
          endDateTime = (data['dueDate'] as Timestamp).toDate();
        } else if (data['dueDate'] is String) {
          try {
            endDateTime = customDateFormat.parse(data['dueDate']);
          } catch (e) {
            print("Error parsing dueDate: ${data['dueDate']}");
          }
        }

        // Warna acak untuk setiap tugas
        Color randomColor = Color.fromARGB(
          255,
          random.nextInt(256), // Nilai Red (0-255)
          random.nextInt(256), // Nilai Green (0-255)
          random.nextInt(256), // Nilai Blue (0-255)
        );

        // Jika keduanya berhasil dikonversi, tambahkan ke list Meeting
        if (startDateTime != null && endDateTime != null) {
          meetings.add(Meeting(
            data['title'] ?? 'No Title',  // Judul pengumuman
            startDateTime,                // Waktu mulai
            endDateTime,                  // Waktu berakhir (deadline)
            randomColor,                  // Warna acak untuk event
            false,                        // Event ini bukan all-day
          ));
        } else {
          print('Invalid date fields in document: ${doc.id}');
        }
      }
    }

    return meetings;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Meeting>>(
        future: _fetchAnnouncementsFromFirestore(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Tidak ada pengumuman.'));
          }

          return SfCalendar(
            view: CalendarView.week,  // Menampilkan kalender dalam tampilan minggu
            dataSource: MeetingDataSource(snapshot.data ?? []),  // Menyediakan data ke kalender
            monthViewSettings: MonthViewSettings(
              appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
            ),
          );
        },
      ),
    );
  }
}

class Meeting {
  Meeting(this.eventName, this.from, this.to, this.background, this.isAllDay);

  String eventName;
  DateTime from;
  DateTime to;
  Color background;
  bool isAllDay;
}

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Meeting> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return appointments![index].from;
  }

  @override
  DateTime getEndTime(int index) {
    return appointments![index].to;
  }

  @override
  String getSubject(int index) {
    return appointments![index].eventName;
  }

  @override
  Color getColor(int index) {
    return appointments![index].background;
  }

  @override
  bool isAllDay(int index) {
    return appointments![index].isAllDay;
  }
}

