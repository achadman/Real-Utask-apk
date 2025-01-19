import 'package:online_classroom/data/accounts.dart';
import 'package:online_classroom/data/announcements.dart';
import 'package:online_classroom/data/attachments.dart';
import 'package:online_classroom/data/classrooms.dart';
import 'package:online_classroom/services/submissions_db.dart';

class Submission {
  Account user;
  String dateTime;
  ClassRooms classroom;
  Announcement assignment;
  bool submitted = false;
  List attachments;

  Submission({
    required this.user,
    this.dateTime = "",
    required this.classroom,
    required this.assignment,
    this.submitted = false,
    required this.attachments,
  });
}

List submissionList = [];

// updates the submissionList with DB values
Future<bool> getsubmissionList() async {
  submissionList = [];

  List? jsonList = await SubmissionDB().createSubmissionListDB();
  if (jsonList == null) return false;

  jsonList.forEach((element) {
    var data = element.data();

    Account? userAccount = getAccount(data["uid"]);
    ClassRooms? classroom = getClassroom(data["classroom"]);
    Announcement? assignment = getAnnouncement(data["classroom"], data["assignment"]);
    List? attachments = getAttachmentListForStudent(data["uid"], data["classroom"], data["assignment"]);

    // Check if any of the values are null and handle them accordingly
    if (userAccount != null && classroom != null && assignment != null) {
      submissionList.add(
        Submission(
          user: userAccount,
          classroom: classroom,
          assignment: assignment,
          dateTime: data["dateTime"] ?? "",
          submitted: data["submitted"] ?? false,
          attachments: attachments ?? [],
        ),
      );
    } else {
      // Log the issue if necessary
      print("Skipping a submission due to missing data (userAccount, classroom, or assignment is null).");
    }
  });

  print("\t\t\t\tGot submissions list");
  return true;
}