import 'package:FSOUNotes/app/router.gr.dart';
import 'package:FSOUNotes/enums/constants.dart';
import 'package:FSOUNotes/enums/enums.dart';
import 'package:FSOUNotes/models/document.dart';
import 'package:FSOUNotes/services/funtional_services/cloud_storage_service.dart';
import 'package:FSOUNotes/services/funtional_services/google_drive_service.dart';
import 'package:stacked/stacked.dart';
import 'package:FSOUNotes/app/locator.dart';
import 'package:FSOUNotes/models/report.dart';
import 'package:FSOUNotes/services/funtional_services/authentication_service.dart';
import 'package:FSOUNotes/services/funtional_services/firestore_service.dart';
import 'package:FSOUNotes/services/funtional_services/sharedpref_service.dart';
import 'package:FSOUNotes/services/state_services/report_service.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:FSOUNotes/models/download.dart';
import 'package:FSOUNotes/models/question_paper.dart';



class QuestionPaperTileViewModel extends BaseViewModel {
  FirestoreService _firestoreService = locator<FirestoreService>();
  AuthenticationService _authenticationService =
      locator<AuthenticationService>();
  SharedPreferencesService _sharedPreferencesService =
      locator<SharedPreferencesService>();
  ReportsService _reportsService = locator<ReportsService>();
  DialogService _dialogService = locator<DialogService>();
  CloudStorageService _cloudStorageService = locator<CloudStorageService>();
  GoogleDriveService _googleDriveService = locator<GoogleDriveService>();
  NavigationService _navigationService = locator<NavigationService>();

  bool get isAdmin => _authenticationService.user.isAdmin;
  bool _isQPdownloaded = false;
  bool get isQPdownloaded => _isQPdownloaded;

  checkIfQpIsDownloaded(List<Download> downloadedQpbySub,QuestionPaper questionPaper) {
    for (int j = 0; j < downloadedQpbySub.length; j++) {
      if (downloadedQpbySub[j].filename == questionPaper.title) {
        _isQPdownloaded = true;
        notifyListeners();
      }
    }
  }

  void reportNote(
      {@required AbstractDocument doc}) async {
    setBusy(true);
    Report report =
        Report(doc.id, doc.subjectName, doc.type, doc.title, _authenticationService.user.email);
    var dialogResult = await _dialogService.showConfirmationDialog(
        title: "Are You Sure?",
        description: "Are you sure you want to report this Document?\nUnnecessary reporting may result in a ban from the application!",
        cancelTitle: "NO",
        confirmationTitle: "YES");
    if (!dialogResult.confirmed) {
      setBusy(false);
      return;
    }
    var result = await _reportsService.addReport(report);
    if (result is String) {
      _dialogService.showDialog(
          title: "Thank you for reporting", description: result);
    } else {
      await _firestoreService.reportNote(report: report,doc: doc);
      Fluttertoast.showToast(
          msg: "Your report has been recorded. The admins will look into this.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
    setBusy(false);
  }

  Future delete(AbstractDocument doc) async {
    var result = await _dialogService.showConfirmationDialog(
        title: "Are you sure?",
        description: "You sure you want to delete this?",
        cancelTitle: "NO",
        confirmationTitle: "YES");
    if (!result.confirmed) {
      setBusy(false);
      return;
    }
    setBusy(true);
    var response = await _googleDriveService.deleteFile(doc: doc);
    setBusy(false);
    if (response is String) {
      _dialogService.showDialog(title: "Error", description: response);
    }
    Fluttertoast.showToast(
        msg: "Delete hogaya , khush? baigan...",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  navigateToEditView(QuestionPaper note) {
    _navigationService.navigateTo(Routes.editViewRoute,arguments:EditViewArguments(path: Document.QuestionPapers,subjectName: note.subjectName,textFieldsMap: Constants.QuestionPaper,note: note,title:note.title));
  }
}
