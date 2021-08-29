import 'package:pegasus_medical_1808/models/booking_form_model.dart';
import 'package:pegasus_medical_1808/models/incident_report_model.dart';
import 'package:pegasus_medical_1808/models/observation_booking_model.dart';
import 'package:pegasus_medical_1808/models/spot_checks_model.dart';
import 'package:pegasus_medical_1808/models/transfer_report_model.dart';
import 'package:pegasus_medical_1808/shared/global_functions.dart';
import 'package:pegasus_medical_1808/shared/strings.dart';
import 'package:pegasus_medical_1808/utils/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:pegasus_medical_1808/widgets/app_bar_gradient.dart';
import 'package:provider/provider.dart';
import '../models/authentication_model.dart';
import '../shared/global_config.dart';
import '../services/navigation_service.dart';
import '../constants/route_paths.dart' as routes;
import '../locator.dart';



class SideDrawer extends StatefulWidget {
  @override
  _SideDrawerState createState() => _SideDrawerState();
}

class _SideDrawerState extends State<SideDrawer> {

  final NavigationService _navigationService = locator<NavigationService>();
  DatabaseHelper _databaseHelper = DatabaseHelper();
  bool _pendingItems = false;



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _checkPendingItems();
  }

  _checkPendingItems() async{
    bool hasIncidentReports = await context.read<IncidentReportModel>().checkPendingRecordExists();
    if(hasIncidentReports){
      setState(() {
        _pendingItems = true;
      });
    }
    bool hasTransferReports = await context.read<TransferReportModel>().checkPendingRecordExists();
    if(hasTransferReports){
      setState(() {
        _pendingItems = true;
      });
    }
    bool hasObservationBookings = await context.read<ObservationBookingModel>().checkPendingRecordExists();
    if(hasObservationBookings){
      setState(() {
        _pendingItems = true;
      });
    }
    bool hasBookingForms = await context.read<BookingFormModel>().checkPendingRecordExists();
    if(hasBookingForms){
      setState(() {
        _pendingItems = true;
      });
    }
    bool hasSpotChecks = await context.read<SpotChecksModel>().checkPendingRecordExists();
    if(hasSpotChecks){
      setState(() {
        _pendingItems = true;
      });
    }
  }

  _uploadPendingItems() async{

    bool hasConnection = await GlobalFunctions.hasDataConnection();
    bool successfulTransferReportUploads = true;
    bool successfulIncidentReportUploads = true;
    bool successfulObservationBookingUploads = true;
    bool successfulBookingFormUploads = true;
    bool successfulSpotChecksUploads = true;
    String message;


    if(hasConnection){

      GlobalFunctions.showLoadingDialog('Uploading data...');

      bool pendingIncidentReport = await context.read<IncidentReportModel>().checkPendingRecordExists();
      bool pendingTransferReport = await context.read<TransferReportModel>().checkPendingRecordExists();
      bool pendingObservationBooking = await context.read<ObservationBookingModel>().checkPendingRecordExists();
      bool pendingBookingForm = await context.read<BookingFormModel>().checkPendingRecordExists();
      bool pendingSpotChecks = await context.read<SpotChecksModel>().checkPendingRecordExists();

      if(pendingIncidentReport){
        Map<String, dynamic> uploadIncidentReports = await context.read<IncidentReportModel>().uploadPendingIncidentReports();
        successfulIncidentReportUploads = uploadIncidentReports['success'];
        message = uploadIncidentReports['message'];
      }

      if (pendingTransferReport) {
        Map<String, dynamic> uploadTransferReports = await context.read<TransferReportModel>().uploadPendingTransferReports();
        successfulTransferReportUploads = uploadTransferReports['success'];
        message = uploadTransferReports['message'];
      }
      if (pendingObservationBooking) {
        Map<String, dynamic> uploadObservationBookings = await context.read<ObservationBookingModel>().uploadPendingObservationBookings();
        successfulObservationBookingUploads = uploadObservationBookings['success'];
        message = uploadObservationBookings['message'];
      }
      if (pendingBookingForm) {
        Map<String, dynamic> uploadBookingForms = await context.read<BookingFormModel>().uploadPendingBookingForms();
        successfulBookingFormUploads = uploadBookingForms['success'];
        message = uploadBookingForms['message'];
      }
      if (pendingSpotChecks) {
        Map<String, dynamic> uploadSpotChecks = await context.read<SpotChecksModel>().uploadPendingSpotChecks();
        successfulSpotChecksUploads = uploadSpotChecks['success'];
        message = uploadSpotChecks['message'];
      }


      GlobalFunctions.dismissLoadingDialog();
      GlobalFunctions.showToast(message);

      if(successfulTransferReportUploads && successfulIncidentReportUploads && successfulObservationBookingUploads && successfulBookingFormUploads && successfulSpotChecksUploads){
        setState(() {
          _pendingItems = false;
        });
      }



    } else {
      GlobalFunctions.showToast('No data connection, please try again when you have a valid connection');
    }
  }


  // _checkPendingItems() async{
  //   _databaseHelper.checkExistsTwoArguments(Strings.transferReportTable, Strings.serverUploaded, 0, Strings.uid, user.uid).then((int value) {
  //     if (value == 1) {
  //       setState(() {
  //         _pendingItems = true;
  //       });
  //     }
  //   });
  //   _databaseHelper.checkExistsTwoArguments(Strings.incidentReportTable, Strings.serverUploaded, 0, Strings.uid, user.uid).then((int value) {
  //     if (value == 1) {
  //       setState(() {
  //         _pendingItems = true;
  //       });
  //     }
  //   });
  //   _databaseHelper.checkExistsTwoArguments(Strings.observationBookingTable, Strings.serverUploaded, 0, Strings.uid, user.uid).then((int value) {
  //     if (value == 1) {
  //       setState(() {
  //         _pendingItems = true;
  //       });
  //     }
  //   });
  //   _databaseHelper.checkExistsTwoArguments(Strings.bookingFormTable, Strings.serverUploaded, 0, Strings.uid, user.uid).then((int value) {
  //     if (value == 1) {
  //       setState(() {
  //         _pendingItems = true;
  //       });
  //     }
  //   });
  // }

  // _uploadPendingItems() async{
  //
  //   bool hasConnection = await GlobalFunctions.hasDataConnection();
  //   bool successfulTransferReportUploads = true;
  //   bool successfulIncidentReportUploads = true;
  //   bool successfulObservationBookingUploads = true;
  //   bool successfulBookingFormUploads = true;
  //   String message;
  //
  //
  //   if(hasConnection){
  //
  //     GlobalFunctions.showLoadingDialog('Uploading data...');
  //     int pendingTransferReport = await _databaseHelper.checkExistsTwoArguments(Strings.transferReportTable, Strings.serverUploaded, 0, Strings.uid, user.uid);
  //     int pendingIncidentReport = await _databaseHelper.checkExistsTwoArguments(Strings.incidentReportTable, Strings.serverUploaded, 0, Strings.uid, user.uid);
  //     int pendingObservationBooking = await _databaseHelper.checkExistsTwoArguments(Strings.observationBookingTable, Strings.serverUploaded, 0, Strings.uid, user.uid);
  //     int pendingBookingForm = await _databaseHelper.checkExistsTwoArguments(Strings.bookingFormTable, Strings.serverUploaded, 0, Strings.uid, user.uid);
  //
  //
  //     if (pendingTransferReport == 1) {
  //       Map<String, dynamic> uploadTransferReports = await context.read<TransferReportModel>().uploadPendingTransferReports();
  //       successfulTransferReportUploads = uploadTransferReports['success'];
  //       message = uploadTransferReports['message'];
  //     }
  //     if (pendingIncidentReport == 1) {
  //       Map<String, dynamic> uploadIncidentReports = await context.read<IncidentReportModel>().uploadPendingIncidentReports();
  //       successfulIncidentReportUploads = uploadIncidentReports['success'];
  //       message = uploadIncidentReports['message'];
  //     }
  //     if (pendingObservationBooking == 1) {
  //       Map<String, dynamic> uploadObservationBookings = await context.read<ObservationBookingModel>().uploadPendingObservationBookings();
  //       successfulObservationBookingUploads = uploadObservationBookings['success'];
  //       message = uploadObservationBookings['message'];
  //     }
  //     if (pendingBookingForm == 1) {
  //       Map<String, dynamic> uploadBookingForms = await context.read<BookingFormModel>().uploadPendingBookingForms();
  //       successfulBookingFormUploads = uploadBookingForms['success'];
  //       message = uploadBookingForms['message'];
  //     }
  //
  //
  //     GlobalFunctions.dismissLoadingDialog();
  //     GlobalFunctions.showToast(message);
  //
  //     if(successfulTransferReportUploads && successfulIncidentReportUploads && successfulObservationBookingUploads && successfulBookingFormUploads){
  //       setState(() {
  //         _pendingItems = false;
  //       });
  //     }
  //
  //
  //
  //   } else {
  //     GlobalFunctions.showToast('No data connection, please try again when you have a valid connection');
  //   }
  // }


  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: user == null ? Container() : Column(
        children: [
          Expanded(child: Container(
            child: ListView(
              padding: EdgeInsets.symmetric(vertical: 0.0),
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.15, child: DrawerHeader(child: Image.asset(
                  'assets/images/pegasusPurple.png',
                  //color: Colors.black,
                ), decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [purpleDesign, purpleDesign])
                        //colors: [purpleDesign, purpleDesign])
                ),),),
                ExpansionTile(
                  leading: Icon(Icons.content_paste, color: bluePurple,),
                  title: Text('Transfer Report', style: TextStyle(fontWeight: FontWeight.bold, color: bluePurple),),
                  children: <Widget>[
                    ListTile(
                      leading: Icon(Icons.create, color: bluePurple,),
                      title: Text('Create Transfer Report', style: TextStyle(color: bluePurple),),
                      onTap: () => _navigationService.navigateToReplacement(routes.TransferReportPageRoute),
                    ),
                    user.role == 'Super User' ? ListTile(
                      leading: Icon(Icons.library_books_sharp, color: bluePurple,),
                      title: Text('Transfer Report List', style: TextStyle(color: bluePurple),),
                      onTap: () => _navigationService.navigateToReplacement(routes.TransferReportListPageRoute),
                    ) : Container(),
                    user.role == 'Super User' ? ListTile(
                      leading: Icon(Icons.search, color: bluePurple,),
                      title: Text('Search Transfer Reports', style: TextStyle(color: bluePurple),),
                      onTap: () => _navigationService.navigateToReplacement(routes.TransferReportSearchPageRoute),
                    ) : Container(),
                  ],),
                Divider(),
                ExpansionTile(
                  leading: Icon(Icons.warning_amber_outlined, color: bluePurple,),
                  title: Text('Incident Report', style: TextStyle(fontWeight: FontWeight.bold, color: bluePurple),),
                  children: <Widget>[
                    ListTile(
                      leading: Icon(Icons.create, color: bluePurple,),
                      title: Text('Create Incident Report', style: TextStyle(color: bluePurple),),
                      onTap: () => _navigationService.navigateToReplacement(routes.IncidentReportPageRoute),
                    ),
                    user.role == 'Super User' ? ListTile(
                      leading: Icon(Icons.library_books_sharp, color: bluePurple,),
                      title: Text('Incident Report List', style: TextStyle(color: bluePurple),),
                      onTap: () => _navigationService.navigateToReplacement(routes.IncidentReportListPageRoute),
                    ) : Container(),
                    user.role == 'Super User' ? ListTile(
                      leading: Icon(Icons.search, color: bluePurple,),
                      title: Text('Search Incident Reports', style: TextStyle(color: bluePurple),),
                      onTap: () => _navigationService.navigateToReplacement(routes.IncidentReportSearchPageRoute),
                    ) : Container(),
                  ],),
                Divider(),
                user.role != 'Normal User' ? Column(children: [
                  ExpansionTile(
                    leading: Icon(Icons.content_paste, color: bluePurple,),
                    title: Text('Observation Booking', style: TextStyle(fontWeight: FontWeight.bold, color: bluePurple),),
                    children: <Widget>[
                      ListTile(
                        leading: Icon(Icons.create, color: bluePurple,),
                        title: Text('Create Observation Booking', style: TextStyle(color: bluePurple),),
                        onTap: () => _navigationService.navigateToReplacement(routes.ObservationBookingPageRoute),
                      ),
                      ListTile(
                        leading: Icon(Icons.library_books_sharp, color: bluePurple,),
                        title: Text('Observation Booking List', style: TextStyle(color: bluePurple),),
                        onTap: () => _navigationService.navigateToReplacement(routes.ObservationBookingListPageRoute),
                      ),
                      ListTile(
                        leading: Icon(Icons.search, color: bluePurple,),
                        title: Text('Search Observation Bookings', style: TextStyle(color: bluePurple),),
                        onTap: () => _navigationService.navigateToReplacement(routes.ObservationBookingSearchPageRoute),
                      ),
                    ],),
                  Divider(),
                  ExpansionTile(
                    leading: Icon(Icons.content_paste, color: bluePurple,),
                    title: Text('Transport Booking', style: TextStyle(fontWeight: FontWeight.bold, color: bluePurple),),
                    children: <Widget>[
                      ListTile(
                        leading: Icon(Icons.create, color: bluePurple,),
                        title: Text('Create Transport Booking', style: TextStyle(color: bluePurple),),
                        onTap: () => _navigationService.navigateToReplacement(routes.BookingFormPageRoute),
                      ),
                      ListTile(
                        leading: Icon(Icons.library_books_sharp, color: bluePurple,),
                        title: Text('Transport Booking List', style: TextStyle(color: bluePurple),),
                        onTap: () => _navigationService.navigateToReplacement(routes.BookingFormListPageRoute),
                      ),
                      ListTile(
                        leading: Icon(Icons.search, color: bluePurple,),
                        title: Text('Search Transport Bookings', style: TextStyle(color: bluePurple),),
                        onTap: () => _navigationService.navigateToReplacement(routes.BookingFormSearchPageRoute),
                      ),
                    ],),
                  Divider(),
                ],) : Container(),
                ExpansionTile(
                  leading: Icon(Icons.content_paste, color: bluePurple,),
                  title: Text('Pegasus Spot Checks', style: TextStyle(fontWeight: FontWeight.bold, color: bluePurple),),
                  children: <Widget>[
                    ListTile(
                      leading: Icon(Icons.create, color: bluePurple,),
                      title: Text('Create Spot Checks', style: TextStyle(color: bluePurple),),
                      onTap: () => _navigationService.navigateToReplacement(routes.SpotChecksPageRoute),
                    ),
                    user.role == 'Super User' ? ListTile(
                      leading: Icon(Icons.library_books_sharp, color: bluePurple,),
                      title: Text('Spot Checks List', style: TextStyle(color: bluePurple),),
                      onTap: () => _navigationService.navigateToReplacement(routes.SpotChecksListPageRoute),
                    ) : Container(),
                    user.role == 'Super User' ? ListTile(
                      leading: Icon(Icons.search, color: bluePurple,),
                      title: Text('Search Spot Checks', style: TextStyle(color: bluePurple),),
                      onTap: () => _navigationService.navigateToReplacement(routes.SpotChecksSearchPageRoute),
                    ) : Container(),
                  ],),
                Divider(),
                _pendingItems ? Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.cloud_upload, color: bluePurple,),
                      title: Text('Upload Pending Reports', style: TextStyle(fontWeight: FontWeight.bold, color: darkBlue),),
                      onTap: () => _uploadPendingItems(),
                    ),
                    Divider()
                  ],
                ) : Container(),
                ListTile(
                  leading: Icon(Icons.message, color: bluePurple,),
                  title: Text('Messages', style: TextStyle(fontWeight: FontWeight.bold, color: bluePurple),),
                  onTap: () => _navigationService.navigateToReplacement(routes.MessagesRoute),
                ),
                Divider(),
                user == null || user.role != 'Super User' ? Container() : Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.people, color: bluePurple,),
                      title: Text('Manage Users', style: TextStyle(fontWeight: FontWeight.bold, color: bluePurple),),
                      onTap: () => _navigationService.navigateToReplacement(routes.UsersRoute),
                    ),
                    Divider(),
                  ],
                ),
                ListTile(
                  leading: Icon(Icons.settings, color: bluePurple,),
                  title: Text('Settings', style: TextStyle(fontWeight: FontWeight.bold, color: bluePurple),),
                  onTap: () =>  _navigationService.navigateToReplacement(routes.SettingsPageRoute),
                ),
                Divider(),
                ListTile(
                    leading: Icon(Icons.logout, color: bluePurple,),
                    title: Text('Logout', style: TextStyle(fontWeight: FontWeight.bold, color: bluePurple),),
                    onTap: () => context.read<AuthenticationModel>().logout()
                ),
              ],
            ),
          ))

        ],
      ),

    );
  }
}
