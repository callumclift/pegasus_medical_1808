import 'package:pegasus_medical_1808/models/bed_rota_model.dart';
import 'package:pegasus_medical_1808/models/booking_form_model.dart';
import 'package:pegasus_medical_1808/models/incident_report_model.dart';
import 'package:pegasus_medical_1808/models/observation_booking_model.dart';
import 'package:pegasus_medical_1808/models/patient_observation_model.dart';
import 'package:pegasus_medical_1808/models/spot_checks_model.dart';
import 'package:pegasus_medical_1808/models/transfer_report_model.dart';
import 'package:pegasus_medical_1808/shared/global_functions.dart';
import 'package:pegasus_medical_1808/utils/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/authentication_model.dart';
import '../shared/global_config.dart';
import '../services/navigation_service.dart';
import '../constants/route_paths.dart' as routes;
import '../locator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';



class SideDrawer extends StatefulWidget {
  @override
  _SideDrawerState createState() => _SideDrawerState();
}

class _SideDrawerState extends State<SideDrawer> {

  final NavigationService _navigationService = locator<NavigationService>();
  bool _pendingItems = false;
  bool _showTransferReport = false;



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _checkPendingItems();
    if(user.role == 'Normal User') _checkTransferReport();
  }

  _checkTransferReport() async {
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

    Map<String, dynamic> userMap = userSnapshot.data() as Map<String, dynamic>;

    if(userMap.containsKey('transport_bookings')){
      int numberOfForms = userMap['transport_bookings'];
      print(numberOfForms);
      if(numberOfForms > 0){
        setState(() {
          _showTransferReport = true;
          print('setting true');
        });
      }
    }


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
    bool hasBedRotas = await context.read<BedRotaModel>().checkPendingRecordExists();
    if(hasBedRotas){
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
    bool hasPatientObservations = await context.read<PatientObservationModel>().checkPendingRecordExists();
    if(hasPatientObservations){
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
    bool successfulBedRotaUploads = true;
    bool successfulBookingFormUploads = true;
    bool successfulSpotChecksUploads = true;
    bool successfulPatientObservationsUploads = true;
    String message;


    if(hasConnection){

      GlobalFunctions.showLoadingDialog('Uploading data...');

      bool pendingIncidentReport = await context.read<IncidentReportModel>().checkPendingRecordExists();
      bool pendingTransferReport = await context.read<TransferReportModel>().checkPendingRecordExists();
      bool pendingObservationBooking = await context.read<ObservationBookingModel>().checkPendingRecordExists();
      bool pendingBedRota = await context.read<BedRotaModel>().checkPendingRecordExists();
      bool pendingBookingForm = await context.read<BookingFormModel>().checkPendingRecordExists();
      bool pendingSpotChecks = await context.read<SpotChecksModel>().checkPendingRecordExists();
      bool pendingPatientObservations = await context.read<PatientObservationModel>().checkPendingRecordExists();


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
      if (pendingBedRota) {
        Map<String, dynamic> uploadBedRotas = await context.read<BedRotaModel>().uploadPendingBedRotas();
        successfulBedRotaUploads = uploadBedRotas['success'];
        message = uploadBedRotas['message'];
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
      if (pendingPatientObservations) {
        Map<String, dynamic> uploadPatientObservations = await context.read<PatientObservationModel>().uploadPendingPatientObservations();
        successfulPatientObservationsUploads = uploadPatientObservations['success'];
        message = uploadPatientObservations['message'];
      }


      GlobalFunctions.dismissLoadingDialog();
      GlobalFunctions.showToast(message);

      if(successfulTransferReportUploads && successfulIncidentReportUploads && successfulObservationBookingUploads && successfulBedRotaUploads && successfulBookingFormUploads && successfulSpotChecksUploads && successfulPatientObservationsUploads){
        setState(() {
          _pendingItems = false;
        });
      }



    } else {
      GlobalFunctions.showToast('No data connection, please try again when you have a valid connection');
    }
  }


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
                user.role == 'Normal User' && _showTransferReport == false ? Container() : ExpansionTile(
                  leading: Icon(Icons.content_paste, color: bluePurple,),
                  title: Text('Transfer Report', style: TextStyle(fontWeight: FontWeight.bold, color: bluePurple),),
                  children: <Widget>[
                    ListTile(
                      leading: Icon(Icons.create, color: bluePurple,),
                      title: Text('Create Transfer Report', style: TextStyle(color: bluePurple),),
                      onTap: () => _navigationService.navigateToReplacement(routes.TransferReportPageRoute),
                    ),
                    ListTile(
                      leading: Icon(Icons.watch_later_outlined, color: bluePurple,),
                      title: Text('Saved Transfer Reports', style: TextStyle(color: bluePurple),),
                      onTap: () => _navigationService.navigateToReplacement(routes.SavedTransferReportListPageRoute),
                    ),
                    user.role == 'Super User' ? ListTile(
                      leading: Icon(Icons.library_books_sharp, color: bluePurple,),
                      title: Text('Completed Transfer Reports', style: TextStyle(color: bluePurple),),
                      onTap: () => _navigationService.navigateToReplacement(routes.TransferReportListPageRoute),
                    ) : Container(),
                    user.role == 'Super User' ? ListTile(
                      leading: Icon(Icons.search, color: bluePurple,),
                      title: Text('Search Transfer Reports', style: TextStyle(color: bluePurple),),
                      onTap: () => _navigationService.navigateToReplacement(routes.TransferReportSearchPageRoute),
                    ) : Container(),
                  ],),
                user.role == 'Normal User' && _showTransferReport == false ? Container() : Divider(),
                user.role != 'Normal User' ? Column(children: [
                  ExpansionTile(
                    leading: Icon(Icons.warning_amber_outlined, color: bluePurple,),
                    title: Text('Incident Report', style: TextStyle(fontWeight: FontWeight.bold, color: bluePurple),),
                    children: <Widget>[
                      ListTile(
                        leading: Icon(Icons.create, color: bluePurple,),
                        title: Text('Create Incident Report', style: TextStyle(color: bluePurple),),
                        onTap: () => _navigationService.navigateToReplacement(routes.IncidentReportPageRoute),
                      ),
                      user.role != 'Normal User' ? ListTile(
                        leading: Icon(Icons.watch_later_outlined, color: bluePurple,),
                        title: Text('Saved Incident Reports', style: TextStyle(color: bluePurple),),
                        onTap: () => _navigationService.navigateToReplacement(routes.SavedIncidentReportListPageRoute),
                      ) : Container(),
                      user.role == 'Super User' ? ListTile(
                        leading: Icon(Icons.library_books_sharp, color: bluePurple,),
                        title: Text('Completed Incident Reports', style: TextStyle(color: bluePurple),),
                        onTap: () => _navigationService.navigateToReplacement(routes.IncidentReportListPageRoute),
                      ) : Container(),
                      user.role == 'Super User' ? ListTile(
                        leading: Icon(Icons.search, color: bluePurple,),
                        title: Text('Search Incident Reports', style: TextStyle(color: bluePurple),),
                        onTap: () => _navigationService.navigateToReplacement(routes.IncidentReportSearchPageRoute),
                      ) : Container(),
                    ],),
                  Divider(),
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
                        leading: Icon(Icons.watch_later_outlined, color: bluePurple,),
                        title: Text('Saved Observation Bookings', style: TextStyle(color: bluePurple),),
                        onTap: () => _navigationService.navigateToReplacement(routes.SavedObservationBookingListPageRoute),
                      ),
                      ListTile(
                        leading: Icon(Icons.library_books_sharp, color: bluePurple,),
                        title: Text('Completed Observation Bookings', style: TextStyle(color: bluePurple),),
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
                    title: Text('Bed Watch Rota', style: TextStyle(fontWeight: FontWeight.bold, color: bluePurple),),
                    children: <Widget>[
                      ListTile(
                        leading: Icon(Icons.create, color: bluePurple,),
                        title: Text('Create Bed Watch Rota', style: TextStyle(color: bluePurple),),
                        onTap: () => _navigationService.navigateToReplacement(routes.BedRotaPageRoute),
                      ),
                      ListTile(
                        leading: Icon(Icons.watch_later_outlined, color: bluePurple,),
                        title: Text('Saved Bed Watch Rotas', style: TextStyle(color: bluePurple),),
                        onTap: () => _navigationService.navigateToReplacement(routes.SavedBedRotaListPageRoute),
                      ),
                      ListTile(
                        leading: Icon(Icons.library_books_sharp, color: bluePurple,),
                        title: Text('Completed Bed Watch Rotas', style: TextStyle(color: bluePurple),),
                        onTap: () => _navigationService.navigateToReplacement(routes.BedRotaListPageRoute),
                      ),
                      ListTile(
                        leading: Icon(Icons.search, color: bluePurple,),
                        title: Text('Search Bed Watch Rotas', style: TextStyle(color: bluePurple),),
                        onTap: () => _navigationService.navigateToReplacement(routes.BedRotaSearchPageRoute),
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
                        leading: Icon(Icons.watch_later_outlined, color: bluePurple,),
                        title: Text('Saved Transport Bookings', style: TextStyle(color: bluePurple),),
                        onTap: () => _navigationService.navigateToReplacement(routes.SavedBookingFormListPageRoute),
                      ),
                      ListTile(
                        leading: Icon(Icons.library_books_sharp, color: bluePurple,),
                        title: Text('Completed Transport Bookings', style: TextStyle(color: bluePurple),),
                        onTap: () => _navigationService.navigateToReplacement(routes.BookingFormListPageRoute),
                      ),
                      ListTile(
                        leading: Icon(Icons.search, color: bluePurple,),
                        title: Text('Search Transport Bookings', style: TextStyle(color: bluePurple),),
                        onTap: () => _navigationService.navigateToReplacement(routes.BookingFormSearchPageRoute),
                      ),
                    ],),
                  Divider(),
                  ExpansionTile(
                    leading: Icon(Icons.content_paste, color: bluePurple,),
                    title: Text('Patient Observation Timesheet', style: TextStyle(fontWeight: FontWeight.bold, color: bluePurple),),
                    children: <Widget>[
                      ListTile(
                        leading: Icon(Icons.create, color: bluePurple,),
                        title: Text('Create Patient Observation Timesheet', style: TextStyle(color: bluePurple),),
                        onTap: () => _navigationService.navigateToReplacement(routes.PatientObservationPageRoute),
                      ),
                      ListTile(
                        leading: Icon(Icons.watch_later_outlined, color: bluePurple,),
                        title: Text('Saved Patient Observation Timesheets', style: TextStyle(color: bluePurple),),
                        onTap: () => _navigationService.navigateToReplacement(routes.SavedPatientObservationListPageRoute),
                      ),
                      user.role == 'Super User' || user.role == 'Enhanced User' ? ListTile(
                        leading: Icon(Icons.library_books_sharp, color: bluePurple,),
                        title: Text('Completed Patient Observation Timesheets', style: TextStyle(color: bluePurple),),
                        onTap: () => _navigationService.navigateToReplacement(routes.PatientObservationListPageRoute),
                      ) : Container(),
                      user.role == 'Super User' || user.role == 'Enhanced User' ? ListTile(
                        leading: Icon(Icons.search, color: bluePurple,),
                        title: Text('Search Patient Observation Timesheets', style: TextStyle(color: bluePurple),),
                        onTap: () => _navigationService.navigateToReplacement(routes.PatientObservationSearchPageRoute),
                      ) : Container(),
                    ],),
                  Divider(),
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
                        title: Text('Completed Spot Checks', style: TextStyle(color: bluePurple),),
                        onTap: () => _navigationService.navigateToReplacement(routes.SpotChecksListPageRoute),
                      ) : Container(),
                      user.role == 'Super User' ? ListTile(
                        leading: Icon(Icons.search, color: bluePurple,),
                        title: Text('Search Spot Checks', style: TextStyle(color: bluePurple),),
                        onTap: () => _navigationService.navigateToReplacement(routes.SpotChecksSearchPageRoute),
                      ) : Container(),
                    ],),
                  Divider(),
                ],) : Column(children: [
                  ExpansionTile(
                    leading: Icon(Icons.content_paste, color: bluePurple,),
                    title: Text('Patient Observation Timesheet', style: TextStyle(fontWeight: FontWeight.bold, color: bluePurple),),
                    children: <Widget>[
                      ListTile(
                        leading: Icon(Icons.create, color: bluePurple,),
                        title: Text('Create Patient Observation Timesheet', style: TextStyle(color: bluePurple),),
                        onTap: () => _navigationService.navigateToReplacement(routes.PatientObservationPageRoute),
                      ),
                      ListTile(
                        leading: Icon(Icons.watch_later_outlined, color: bluePurple,),
                        title: Text('Saved Patient Observation Timesheets', style: TextStyle(color: bluePurple),),
                        onTap: () => _navigationService.navigateToReplacement(routes.SavedPatientObservationListPageRoute),
                      ),
                      user.role == 'Super User' || user.role == 'Enhanced User' ? ListTile(
                        leading: Icon(Icons.library_books_sharp, color: bluePurple,),
                        title: Text('Completed Patient Observation Timesheets', style: TextStyle(color: bluePurple),),
                        onTap: () => _navigationService.navigateToReplacement(routes.PatientObservationListPageRoute),
                      ) : Container(),
                      user.role == 'Super User' || user.role == 'Enhanced User' ? ListTile(
                        leading: Icon(Icons.search, color: bluePurple,),
                        title: Text('Search Patient Observation Timesheets', style: TextStyle(color: bluePurple),),
                        onTap: () => _navigationService.navigateToReplacement(routes.PatientObservationSearchPageRoute),
                      ) : Container(),
                    ],),
                  Divider(),
                ],),

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
                user.role == 'Super User' ? Column(children: [
                  ExpansionTile(
                    leading: Icon(Icons.admin_panel_settings, color: bluePurple,),
                    title: Text('Admin', style: TextStyle(fontWeight: FontWeight.bold, color: bluePurple),),
                    children: <Widget>[
                      ListTile(
                        leading: Icon(Icons.create, color: bluePurple,),
                        title: Text('Manage Job Refs', style: TextStyle(color: bluePurple),),
                        onTap: () => _navigationService.navigateToReplacement(routes.ManageJobRefsPageRoute),
                      ),
                    ],),
                  Divider(),
                ],) : Container(),
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
