import 'package:pegasus_medical_1808/pages/booking_form/booking_form.dart';
import 'package:pegasus_medical_1808/pages/booking_form/booking_form_list.dart';
import 'package:pegasus_medical_1808/pages/booking_form/booking_form_search.dart';
import 'package:pegasus_medical_1808/pages/chat/chat_page.dart';
import 'package:pegasus_medical_1808/pages/incident_report/incident_report.dart';
import 'package:pegasus_medical_1808/pages/incident_report/incident_report_list.dart';
import 'package:pegasus_medical_1808/pages/incident_report/incident_report_search.dart';
import 'package:pegasus_medical_1808/pages/login_page/change_password_page.dart';
import 'package:pegasus_medical_1808/pages/login_page/terms_conditions_page.dart';
import 'package:pegasus_medical_1808/pages/messaging/messaging.dart';
import 'package:pegasus_medical_1808/pages/observation_booking/observation_booking.dart';
import 'package:pegasus_medical_1808/pages/observation_booking/observation_booking_list.dart';
import 'package:pegasus_medical_1808/pages/observation_booking/observation_booking_search.dart';
import 'package:pegasus_medical_1808/pages/settings/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:pegasus_medical_1808/constants/route_paths.dart' as routes;
import 'package:pegasus_medical_1808/pages/spot_checks/spot_checks.dart';
import 'package:pegasus_medical_1808/pages/spot_checks/spot_checks_list.dart';
import 'package:pegasus_medical_1808/pages/spot_checks/spot_checks_search.dart';
import 'package:pegasus_medical_1808/pages/transfer_report/transfer_report_list.dart';
import 'package:pegasus_medical_1808/pages/transfer_report/transfer_report_overall.dart';
import 'package:pegasus_medical_1808/pages/transfer_report/transfer_report_search.dart';
import 'package:pegasus_medical_1808/pages/users/users_admin_page.dart';
import './pages/login_page/login_page.dart';
import './pages/home_page/home_page.dart';
import './pages/undefined_page/undefined_page.dart';
import 'constants/route_paths.dart';

Route<dynamic> generateRoute(RouteSettings settings){
  switch(settings.name) {
    case routes.HomePageRoute:
      var argument = settings.arguments;
      return MaterialPageRoute(builder: (context) => HomePage(argument: argument,));
    case routes.TransferReportPageRoute:
      var argument = settings.arguments;
      return MaterialPageRoute(builder: (context) => TransferReportOverall());
    case routes.IncidentReportPageRoute:
      var argument = settings.arguments;
      return MaterialPageRoute(builder: (context) => IncidentReport());
    case routes.TransferReportListPageRoute:
      return MaterialPageRoute(builder: (context) => CompletedTransferReportsListPage());
      case routes.TransferReportSearchPageRoute:
      return MaterialPageRoute(builder: (context) => TransferReportSearch());
    case routes.IncidentReportListPageRoute:
      return MaterialPageRoute(builder: (context) => CompletedIncidentReportsListPage());
    case routes.IncidentReportSearchPageRoute:
      return MaterialPageRoute(builder: (context) => IncidentReportSearch());
    case routes.ObservationBookingPageRoute:
      var argument = settings.arguments;
      return MaterialPageRoute(builder: (context) => ObservationBooking());
    case routes.ObservationBookingListPageRoute:
      return MaterialPageRoute(builder: (context) => CompletedObservationBookingsListPage());
    case routes.ObservationBookingSearchPageRoute:
      return MaterialPageRoute(builder: (context) => ObservationBookingSearch());
    case routes.SpotChecksPageRoute:
      var argument = settings.arguments;
      return MaterialPageRoute(builder: (context) => SpotChecks());
    case routes.SpotChecksListPageRoute:
      return MaterialPageRoute(builder: (context) => CompletedSpotChecksListPage());
    case routes.SpotChecksSearchPageRoute:
      return MaterialPageRoute(builder: (context) => SpotChecksSearch());
    case routes.BookingFormPageRoute:
      var argument = settings.arguments;
      return MaterialPageRoute(builder: (context) => BookingForm());
    case routes.BookingFormListPageRoute:
      return MaterialPageRoute(builder: (context) => CompletedBookingFormsListPage());
    case routes.BookingFormSearchPageRoute:
      return MaterialPageRoute(builder: (context) => BookingFormSearch());
    case routes.LoginPageRoute:
      return MaterialPageRoute(builder: (context) => LoginPage());
    case routes.SettingsPageRoute:
      return MaterialPageRoute(builder: (context) => SettingsPage());
    case routes.UsersRoute:
      return MaterialPageRoute(builder: (context) => UsersAdminPage());
    case routes.MessagesRoute:
      return MaterialPageRoute(builder: (context) => MessagesPage());
    case routes.ChatRoute:
      return MaterialPageRoute(builder: (context) => ChatPage());
    case routes.ChangePasswordPageRoute:
      return MaterialPageRoute(builder: (context) => ChangePasswordPage());
    case routes.TermsConditionsPageRoute:
      return MaterialPageRoute(builder: (context) => TermsConditionsPage());
      break;
    default:
      return MaterialPageRoute(builder: (context) => UndefinedPage(name: settings.name,));
  }

}
