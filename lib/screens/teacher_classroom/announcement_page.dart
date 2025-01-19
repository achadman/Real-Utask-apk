import 'package:flutter/material.dart';
import 'package:online_classroom/data/announcements.dart';
import 'package:online_classroom/data/custom_user.dart';
import 'package:online_classroom/services/announcements_db.dart';
import 'package:online_classroom/services/attachments_db.dart';
import 'package:online_classroom/services/submissions_db.dart';
import 'package:online_classroom/services/updatealldata.dart';
import 'package:online_classroom/widgets/profile_tile.dart';
import 'package:online_classroom/data/submissions.dart';
import 'package:online_classroom/widgets/attachment_composer.dart';
import 'package:online_classroom/screens/teacher_classroom/submission_page.dart';
import 'package:online_classroom/screens/teacher_classroom/announcement_crud/edit_announcement.dart';
import 'package:provider/provider.dart';
import 'package:online_classroom/widgets/submit_composer.dart';

class AnnouncementPage extends StatefulWidget {
  Announcement announcement;

  AnnouncementPage({required this.announcement});

  @override
  _AnnouncementPageState createState() => _AnnouncementPageState();
}

class _AnnouncementPageState extends State<AnnouncementPage> {
  List<Widget> buildSubmissions() {
    if (widget.announcement.type == 'Assignment') {
      // Membagi siswa menjadi "Pending" dan "Submitted"
      List submissionsAssigned = submissionList
          .where((i) => i.assignment == widget.announcement && !i.submitted)
          .toList();
      List submissionsDone = submissionList
          .where((i) => i.assignment == widget.announcement && i.submitted)
          .toList();
      List<bool> tempChecklist = [];

      @override
      void initState() {
        super.initState();
        submissionsAssigned = submissionList
            .where((i) => i.assignment == widget.announcement && !i.submitted)
            .toList();

        // Inisialisasi tempChecklist berdasarkan submitted
        tempChecklist =
            submissionsAssigned.map((e) => e.submitted as bool).toList();
      }

      // Fungsi untuk membangun UI list submissions
      // Remove redundant buildSubmissions method
      return [
        if (submissionsDone.isNotEmpty)
          Container(
            padding: EdgeInsets.only(top: 15, left: 15, bottom: 10),
            child: Text(
              "Submitted",
              style: TextStyle(
                  fontSize: 20,
                  color: widget.announcement.classroom.uiColor,
                  letterSpacing: 1),
            ),
          ),
        if (submissionsDone.isNotEmpty)
          Container(
            margin: EdgeInsets.only(left: 15),
            width: MediaQuery.of(context).size.width - 30,
            height: 2,
            color: widget.announcement.classroom.uiColor,
          ),
        Container(
          child: ListView.builder(
            shrinkWrap: true,
            primary: false,
            itemCount: submissionsDone.length,
            itemBuilder: (context, int index) {
              return InkWell(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => SubmissionPage(
                      submission: submissionsDone[index],
                    ),
                  ),
                ),
                child: Profile(user: submissionsDone[index].user),
              );
            },
          ),
        ),
        if (submissionsAssigned.isNotEmpty)
          Container(
            padding: EdgeInsets.only(top: 15, left: 15, bottom: 10),
            child: Text(
              "Pending",
              style: TextStyle(
                  fontSize: 20,
                  color: widget.announcement.classroom.uiColor,
                  letterSpacing: 1),
            ),
          ),
        if (submissionsAssigned.isNotEmpty)
          Container(
            margin: EdgeInsets.only(left: 15),
            width: MediaQuery.of(context).size.width - 30,
            height: 2,
            color: widget.announcement.classroom.uiColor,
          ),
        Container(
          child: ListView.builder(
            shrinkWrap: true,
            primary: false,
            itemCount: submissionsAssigned.length,
            itemBuilder: (context, int index) {
              return CheckboxListTile(
                title: Profile(user: submissionsAssigned[index].user),
                value: submissionsAssigned[index].submitted,
                onChanged: (bool? value) {
                  // Perbarui state untuk item tertentu
                  setState(() {
                    submissionsAssigned[index].submitted = value ?? false;
                  });
                },
              );
            },
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 20,
          ), // Jarak tombol dari tepi
          child: ElevatedButton(
            onPressed: () {
              // Logika submit
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green, // Warna tombol hijau
              padding: EdgeInsets.symmetric(
                  horizontal: 30, vertical: 15), // Ukuran tombol
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(10), // Sudut melengkung tombol
              ),
            ),
            child: Text(
              'Submit',
              style:
                  TextStyle(fontSize: 18, color: Colors.white), // Teks tombol
            ),
          ),
        ),
      ];
    }
    return [];
  }

  void submitTasks() {
    // Implement your task submission logic here
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<CustomUser?>(context);

    Future<void> deleteAnnouncement() async {
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Delete ' + widget.announcement.type),
            content: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Text('This cannot be undone. Continue?'),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Delete', style: TextStyle(color: Colors.red)),
                onPressed: () async {
                  await AnnouncementDB(user: user).deleteAnnouncements(
                      widget.announcement.title,
                      widget.announcement.classroom.className);

                  for (int i = 0;
                      i < widget.announcement.attachments.length;
                      i++) {
                    var attachment = widget.announcement.attachments[i];
                    String safeURL =
                        attachment.url.replaceAll(RegExp(r'[^\w\s]+'), '');
                    AttachmentsDB()
                        .deleteAttachmentsDB(attachment.name, safeURL);

                    AttachmentsDB().deleteAttachAnnounceDB(
                        widget.announcement.title, safeURL);
                  }

                  if (widget.announcement.type == 'Assignment') {
                    List students = widget.announcement.classroom.students;
                    for (int index = 0; index < students.length; index++) {
                      await SubmissionDB(user: user).deleteSubmissions(
                          students[index].uid,
                          widget.announcement.classroom.className,
                          widget.announcement.classroom.className +
                              "__" +
                              widget.announcement.title);
                    }
                  }

                  await updateAllData();
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }

    return Scaffold(
        body: ListView(
            children: [
                  Container(
                    padding: EdgeInsets.only(top: 50, left: 15, bottom: 10),
                    child: Text(
                      widget.announcement.title,
                      style: TextStyle(
                          fontSize: 25,
                          color: widget.announcement.classroom.uiColor,
                          letterSpacing: 1),
                    ),
                  ),
                  if (widget.announcement.type == 'Assignment')
                    Container(
                      padding: EdgeInsets.only(left: 15, bottom: 10),
                      child: Text(
                        "Due " + widget.announcement.dueDate,
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1),
                      ),
                    ),
                  Container(
                    margin: EdgeInsets.only(left: 15),
                    width: MediaQuery.of(context).size.width - 30,
                    height: 2,
                    color: widget.announcement.classroom.uiColor,
                  ),
                  Container(
                      margin: EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  SizedBox(width: 10),
                                  CircleAvatar(
                                    backgroundImage: AssetImage(
                                        "${widget.announcement.user.userDp}"),
                                  ),
                                  SizedBox(width: 10),
                                  Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          widget.announcement.user.firstName! +
                                              " " +
                                              widget
                                                  .announcement.user.lastName!,
                                          style: TextStyle(),
                                        ),
                                        Text(
                                          "Last updated " +
                                              widget.announcement.dateTime,
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      ]),
                                ],
                              )
                            ],
                          ),
                          Container(
                              width: MediaQuery.of(context).size.width - 40,
                              margin: EdgeInsets.only(top: 15),
                              child: Text(widget.announcement.description))
                        ],
                      )),
                  SizedBox(width: 10),
                  widget.announcement.attachments.isNotEmpty
                      ? Padding(
                          padding:
                              EdgeInsets.only(top: 15, left: 15, bottom: 10),
                          child: Text(
                            "Attachments:",
                            style: TextStyle(
                                fontSize: 15,
                                color: Colors.black,
                                letterSpacing: 1,
                                fontWeight: FontWeight.bold),
                          ))
                      : Container(),
                  AttachmentComposer(widget.announcement.attachments),
                ] +
                buildSubmissions()),
        floatingActionButton:
            Column(mainAxisAlignment: MainAxisAlignment.end, children: [
          FloatingActionButton(
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(
                    builder: (context) =>
                        EditAnnouncement(announcement: widget.announcement),
                  ))
                  .then((_) => setState(() {
                        widget.announcement = getAnnouncement(
                            widget.announcement.classroom.className,
                            widget.announcement.title)!;
                      }));
            },
            backgroundColor: widget.announcement.classroom.uiColor,
            child: Icon(
              Icons.edit,
              color: Colors.white,
              size: 32,
            ),
            heroTag: null,
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            onPressed: deleteAnnouncement,
            backgroundColor: Colors.red,
            child: Icon(Icons.delete, color: Colors.white, size: 32),
            heroTag: null,
          ),
        ]));
  }
}
