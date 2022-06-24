import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:pegasus_medical_1808/models/bed_rota_model.dart';
import 'package:pegasus_medical_1808/models/job_refs_model.dart';
import 'package:pegasus_medical_1808/shared/global_config.dart';
import 'package:pegasus_medical_1808/shared/global_functions.dart';
import 'package:pegasus_medical_1808/shared/strings.dart';
import 'package:pegasus_medical_1808/widgets/app_bar_gradient.dart';
import 'package:pegasus_medical_1808/widgets/dropdown_form_field.dart';
import 'package:pegasus_medical_1808/widgets/gradient_button.dart';
import 'package:pegasus_medical_1808/widgets/side_drawer.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';


class BedRota extends StatefulWidget {
  final bool fromJob;
  final String jobId;
  final bool fillDetails;
  final bool edit;
  final bool saved;
  final int savedId;

  BedRota(
      [
        this.fromJob = false,
        this.jobId = '1',
        this.fillDetails = false,
        this.edit = false,
        this.saved = false,
        this.savedId = 0
      ]
      );

  @override
  _BedRotaState createState() => _BedRotaState();
}

class _BedRotaState extends State<BedRota> {

  bool _loadingTemporary = false;
  BedRotaModel bedRotaModel;
  JobRefsModel jobRefsModel;
  final dateFormat = DateFormat("dd/MM/yyyy");
  final dateTimeFormat = DateFormat("dd/MM/yyyy HH:mm");
  final timeFormat = DateFormat("HH:mm");
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController jobRef = TextEditingController();
  final TextEditingController weekCommencing = TextEditingController();
  final TextEditingController mondayAmName1 = TextEditingController();
  final TextEditingController mondayAmFrom1 = TextEditingController();
  final TextEditingController mondayAmTo1 = TextEditingController();
  final TextEditingController mondayPmName1 = TextEditingController();
  final TextEditingController mondayPmFrom1 = TextEditingController();
  final TextEditingController mondayPmTo1 = TextEditingController();
  final TextEditingController mondayNightName1 = TextEditingController();
  final TextEditingController mondayNightFrom1 = TextEditingController();
  final TextEditingController mondayNightTo1 = TextEditingController();
  final TextEditingController mondayAmName2 = TextEditingController();
  final TextEditingController mondayAmFrom2 = TextEditingController();
  final TextEditingController mondayAmTo2 = TextEditingController();
  final TextEditingController mondayPmName2 = TextEditingController();
  final TextEditingController mondayPmFrom2 = TextEditingController();
  final TextEditingController mondayPmTo2 = TextEditingController();
  final TextEditingController mondayNightName2 = TextEditingController();
  final TextEditingController mondayNightFrom2 = TextEditingController();
  final TextEditingController mondayNightTo2 = TextEditingController();
  final TextEditingController mondayAmName3 = TextEditingController();
  final TextEditingController mondayAmFrom3 = TextEditingController();
  final TextEditingController mondayAmTo3 = TextEditingController();
  final TextEditingController mondayPmName3 = TextEditingController();
  final TextEditingController mondayPmFrom3 = TextEditingController();
  final TextEditingController mondayPmTo3 = TextEditingController();
  final TextEditingController mondayNightName3 = TextEditingController();
  final TextEditingController mondayNightFrom3 = TextEditingController();
  final TextEditingController mondayNightTo3 = TextEditingController();
  final TextEditingController mondayAmName4 = TextEditingController();
  final TextEditingController mondayAmFrom4 = TextEditingController();
  final TextEditingController mondayAmTo4 = TextEditingController();
  final TextEditingController mondayPmName4 = TextEditingController();
  final TextEditingController mondayPmFrom4 = TextEditingController();
  final TextEditingController mondayPmTo4 = TextEditingController();
  final TextEditingController mondayNightName4 = TextEditingController();
  final TextEditingController mondayNightFrom4 = TextEditingController();
  final TextEditingController mondayNightTo4 = TextEditingController();
  final TextEditingController mondayAmName5 = TextEditingController();
  final TextEditingController mondayAmFrom5 = TextEditingController();
  final TextEditingController mondayAmTo5 = TextEditingController();
  final TextEditingController mondayPmName5 = TextEditingController();
  final TextEditingController mondayPmFrom5 = TextEditingController();
  final TextEditingController mondayPmTo5 = TextEditingController();
  final TextEditingController mondayNightName5 = TextEditingController();
  final TextEditingController mondayNightFrom5 = TextEditingController();
  final TextEditingController mondayNightTo5 = TextEditingController();
  final TextEditingController tuesdayAmName1 = TextEditingController();
  final TextEditingController tuesdayAmFrom1 = TextEditingController();
  final TextEditingController tuesdayAmTo1 = TextEditingController();
  final TextEditingController tuesdayPmName1 = TextEditingController();
  final TextEditingController tuesdayPmFrom1 = TextEditingController();
  final TextEditingController tuesdayPmTo1 = TextEditingController();
  final TextEditingController tuesdayNightName1 = TextEditingController();
  final TextEditingController tuesdayNightFrom1 = TextEditingController();
  final TextEditingController tuesdayNightTo1 = TextEditingController();
  final TextEditingController tuesdayAmName2 = TextEditingController();
  final TextEditingController tuesdayAmFrom2 = TextEditingController();
  final TextEditingController tuesdayAmTo2 = TextEditingController();
  final TextEditingController tuesdayPmName2 = TextEditingController();
  final TextEditingController tuesdayPmFrom2 = TextEditingController();
  final TextEditingController tuesdayPmTo2 = TextEditingController();
  final TextEditingController tuesdayNightName2 = TextEditingController();
  final TextEditingController tuesdayNightFrom2 = TextEditingController();
  final TextEditingController tuesdayNightTo2 = TextEditingController();
  final TextEditingController tuesdayAmName3 = TextEditingController();
  final TextEditingController tuesdayAmFrom3 = TextEditingController();
  final TextEditingController tuesdayAmTo3 = TextEditingController();
  final TextEditingController tuesdayPmName3 = TextEditingController();
  final TextEditingController tuesdayPmFrom3 = TextEditingController();
  final TextEditingController tuesdayPmTo3 = TextEditingController();
  final TextEditingController tuesdayNightName3 = TextEditingController();
  final TextEditingController tuesdayNightFrom3 = TextEditingController();
  final TextEditingController tuesdayNightTo3 = TextEditingController();
  final TextEditingController tuesdayAmName4 = TextEditingController();
  final TextEditingController tuesdayAmFrom4 = TextEditingController();
  final TextEditingController tuesdayAmTo4 = TextEditingController();
  final TextEditingController tuesdayPmName4 = TextEditingController();
  final TextEditingController tuesdayPmFrom4 = TextEditingController();
  final TextEditingController tuesdayPmTo4 = TextEditingController();
  final TextEditingController tuesdayNightName4 = TextEditingController();
  final TextEditingController tuesdayNightFrom4 = TextEditingController();
  final TextEditingController tuesdayNightTo4 = TextEditingController();
  final TextEditingController tuesdayAmName5 = TextEditingController();
  final TextEditingController tuesdayAmFrom5 = TextEditingController();
  final TextEditingController tuesdayAmTo5 = TextEditingController();
  final TextEditingController tuesdayPmName5 = TextEditingController();
  final TextEditingController tuesdayPmFrom5 = TextEditingController();
  final TextEditingController tuesdayPmTo5 = TextEditingController();
  final TextEditingController tuesdayNightName5 = TextEditingController();
  final TextEditingController tuesdayNightFrom5 = TextEditingController();
  final TextEditingController tuesdayNightTo5 = TextEditingController();
  final TextEditingController wednesdayAmName1 = TextEditingController();
  final TextEditingController wednesdayAmFrom1 = TextEditingController();
  final TextEditingController wednesdayAmTo1 = TextEditingController();
  final TextEditingController wednesdayPmName1 = TextEditingController();
  final TextEditingController wednesdayPmFrom1 = TextEditingController();
  final TextEditingController wednesdayPmTo1 = TextEditingController();
  final TextEditingController wednesdayNightName1 = TextEditingController();
  final TextEditingController wednesdayNightFrom1 = TextEditingController();
  final TextEditingController wednesdayNightTo1 = TextEditingController();
  final TextEditingController wednesdayAmName2 = TextEditingController();
  final TextEditingController wednesdayAmFrom2 = TextEditingController();
  final TextEditingController wednesdayAmTo2 = TextEditingController();
  final TextEditingController wednesdayPmName2 = TextEditingController();
  final TextEditingController wednesdayPmFrom2 = TextEditingController();
  final TextEditingController wednesdayPmTo2 = TextEditingController();
  final TextEditingController wednesdayNightName2 = TextEditingController();
  final TextEditingController wednesdayNightFrom2 = TextEditingController();
  final TextEditingController wednesdayNightTo2 = TextEditingController();
  final TextEditingController wednesdayAmName3 = TextEditingController();
  final TextEditingController wednesdayAmFrom3 = TextEditingController();
  final TextEditingController wednesdayAmTo3 = TextEditingController();
  final TextEditingController wednesdayPmName3 = TextEditingController();
  final TextEditingController wednesdayPmFrom3 = TextEditingController();
  final TextEditingController wednesdayPmTo3 = TextEditingController();
  final TextEditingController wednesdayNightName3 = TextEditingController();
  final TextEditingController wednesdayNightFrom3 = TextEditingController();
  final TextEditingController wednesdayNightTo3 = TextEditingController();
  final TextEditingController wednesdayAmName4 = TextEditingController();
  final TextEditingController wednesdayAmFrom4 = TextEditingController();
  final TextEditingController wednesdayAmTo4 = TextEditingController();
  final TextEditingController wednesdayPmName4 = TextEditingController();
  final TextEditingController wednesdayPmFrom4 = TextEditingController();
  final TextEditingController wednesdayPmTo4 = TextEditingController();
  final TextEditingController wednesdayNightName4 = TextEditingController();
  final TextEditingController wednesdayNightFrom4 = TextEditingController();
  final TextEditingController wednesdayNightTo4 = TextEditingController();
  final TextEditingController wednesdayAmName5 = TextEditingController();
  final TextEditingController wednesdayAmFrom5 = TextEditingController();
  final TextEditingController wednesdayAmTo5 = TextEditingController();
  final TextEditingController wednesdayPmName5 = TextEditingController();
  final TextEditingController wednesdayPmFrom5 = TextEditingController();
  final TextEditingController wednesdayPmTo5 = TextEditingController();
  final TextEditingController wednesdayNightName5 = TextEditingController();
  final TextEditingController wednesdayNightFrom5 = TextEditingController();
  final TextEditingController wednesdayNightTo5 = TextEditingController();
  final TextEditingController thursdayAmName1 = TextEditingController();
  final TextEditingController thursdayAmFrom1 = TextEditingController();
  final TextEditingController thursdayAmTo1 = TextEditingController();
  final TextEditingController thursdayPmName1 = TextEditingController();
  final TextEditingController thursdayPmFrom1 = TextEditingController();
  final TextEditingController thursdayPmTo1 = TextEditingController();
  final TextEditingController thursdayNightName1 = TextEditingController();
  final TextEditingController thursdayNightFrom1 = TextEditingController();
  final TextEditingController thursdayNightTo1 = TextEditingController();
  final TextEditingController thursdayAmName2 = TextEditingController();
  final TextEditingController thursdayAmFrom2 = TextEditingController();
  final TextEditingController thursdayAmTo2 = TextEditingController();
  final TextEditingController thursdayPmName2 = TextEditingController();
  final TextEditingController thursdayPmFrom2 = TextEditingController();
  final TextEditingController thursdayPmTo2 = TextEditingController();
  final TextEditingController thursdayNightName2 = TextEditingController();
  final TextEditingController thursdayNightFrom2 = TextEditingController();
  final TextEditingController thursdayNightTo2 = TextEditingController();
  final TextEditingController thursdayAmName3 = TextEditingController();
  final TextEditingController thursdayAmFrom3 = TextEditingController();
  final TextEditingController thursdayAmTo3 = TextEditingController();
  final TextEditingController thursdayPmName3 = TextEditingController();
  final TextEditingController thursdayPmFrom3 = TextEditingController();
  final TextEditingController thursdayPmTo3 = TextEditingController();
  final TextEditingController thursdayNightName3 = TextEditingController();
  final TextEditingController thursdayNightFrom3 = TextEditingController();
  final TextEditingController thursdayNightTo3 = TextEditingController();
  final TextEditingController thursdayAmName4 = TextEditingController();
  final TextEditingController thursdayAmFrom4 = TextEditingController();
  final TextEditingController thursdayAmTo4 = TextEditingController();
  final TextEditingController thursdayPmName4 = TextEditingController();
  final TextEditingController thursdayPmFrom4 = TextEditingController();
  final TextEditingController thursdayPmTo4 = TextEditingController();
  final TextEditingController thursdayNightName4 = TextEditingController();
  final TextEditingController thursdayNightFrom4 = TextEditingController();
  final TextEditingController thursdayNightTo4 = TextEditingController();
  final TextEditingController thursdayAmName5 = TextEditingController();
  final TextEditingController thursdayAmFrom5 = TextEditingController();
  final TextEditingController thursdayAmTo5 = TextEditingController();
  final TextEditingController thursdayPmName5 = TextEditingController();
  final TextEditingController thursdayPmFrom5 = TextEditingController();
  final TextEditingController thursdayPmTo5 = TextEditingController();
  final TextEditingController thursdayNightName5 = TextEditingController();
  final TextEditingController thursdayNightFrom5 = TextEditingController();
  final TextEditingController thursdayNightTo5 = TextEditingController();
  final TextEditingController fridayAmName1 = TextEditingController();
  final TextEditingController fridayAmFrom1 = TextEditingController();
  final TextEditingController fridayAmTo1 = TextEditingController();
  final TextEditingController fridayPmName1 = TextEditingController();
  final TextEditingController fridayPmFrom1 = TextEditingController();
  final TextEditingController fridayPmTo1 = TextEditingController();
  final TextEditingController fridayNightName1 = TextEditingController();
  final TextEditingController fridayNightFrom1 = TextEditingController();
  final TextEditingController fridayNightTo1 = TextEditingController();
  final TextEditingController fridayAmName2 = TextEditingController();
  final TextEditingController fridayAmFrom2 = TextEditingController();
  final TextEditingController fridayAmTo2 = TextEditingController();
  final TextEditingController fridayPmName2 = TextEditingController();
  final TextEditingController fridayPmFrom2 = TextEditingController();
  final TextEditingController fridayPmTo2 = TextEditingController();
  final TextEditingController fridayNightName2 = TextEditingController();
  final TextEditingController fridayNightFrom2 = TextEditingController();
  final TextEditingController fridayNightTo2 = TextEditingController();
  final TextEditingController fridayAmName3 = TextEditingController();
  final TextEditingController fridayAmFrom3 = TextEditingController();
  final TextEditingController fridayAmTo3 = TextEditingController();
  final TextEditingController fridayPmName3 = TextEditingController();
  final TextEditingController fridayPmFrom3 = TextEditingController();
  final TextEditingController fridayPmTo3 = TextEditingController();
  final TextEditingController fridayNightName3 = TextEditingController();
  final TextEditingController fridayNightFrom3 = TextEditingController();
  final TextEditingController fridayNightTo3 = TextEditingController();
  final TextEditingController fridayAmName4 = TextEditingController();
  final TextEditingController fridayAmFrom4 = TextEditingController();
  final TextEditingController fridayAmTo4 = TextEditingController();
  final TextEditingController fridayPmName4 = TextEditingController();
  final TextEditingController fridayPmFrom4 = TextEditingController();
  final TextEditingController fridayPmTo4 = TextEditingController();
  final TextEditingController fridayNightName4 = TextEditingController();
  final TextEditingController fridayNightFrom4 = TextEditingController();
  final TextEditingController fridayNightTo4 = TextEditingController();
  final TextEditingController fridayAmName5 = TextEditingController();
  final TextEditingController fridayAmFrom5 = TextEditingController();
  final TextEditingController fridayAmTo5 = TextEditingController();
  final TextEditingController fridayPmName5 = TextEditingController();
  final TextEditingController fridayPmFrom5 = TextEditingController();
  final TextEditingController fridayPmTo5 = TextEditingController();
  final TextEditingController fridayNightName5 = TextEditingController();
  final TextEditingController fridayNightFrom5 = TextEditingController();
  final TextEditingController fridayNightTo5 = TextEditingController();
  final TextEditingController saturdayAmName1 = TextEditingController();
  final TextEditingController saturdayAmFrom1 = TextEditingController();
  final TextEditingController saturdayAmTo1 = TextEditingController();
  final TextEditingController saturdayPmName1 = TextEditingController();
  final TextEditingController saturdayPmFrom1 = TextEditingController();
  final TextEditingController saturdayPmTo1 = TextEditingController();
  final TextEditingController saturdayNightName1 = TextEditingController();
  final TextEditingController saturdayNightFrom1 = TextEditingController();
  final TextEditingController saturdayNightTo1 = TextEditingController();
  final TextEditingController saturdayAmName2 = TextEditingController();
  final TextEditingController saturdayAmFrom2 = TextEditingController();
  final TextEditingController saturdayAmTo2 = TextEditingController();
  final TextEditingController saturdayPmName2 = TextEditingController();
  final TextEditingController saturdayPmFrom2 = TextEditingController();
  final TextEditingController saturdayPmTo2 = TextEditingController();
  final TextEditingController saturdayNightName2 = TextEditingController();
  final TextEditingController saturdayNightFrom2 = TextEditingController();
  final TextEditingController saturdayNightTo2 = TextEditingController();
  final TextEditingController saturdayAmName3 = TextEditingController();
  final TextEditingController saturdayAmFrom3 = TextEditingController();
  final TextEditingController saturdayAmTo3 = TextEditingController();
  final TextEditingController saturdayPmName3 = TextEditingController();
  final TextEditingController saturdayPmFrom3 = TextEditingController();
  final TextEditingController saturdayPmTo3 = TextEditingController();
  final TextEditingController saturdayNightName3 = TextEditingController();
  final TextEditingController saturdayNightFrom3 = TextEditingController();
  final TextEditingController saturdayNightTo3 = TextEditingController();
  final TextEditingController saturdayAmName4 = TextEditingController();
  final TextEditingController saturdayAmFrom4 = TextEditingController();
  final TextEditingController saturdayAmTo4 = TextEditingController();
  final TextEditingController saturdayPmName4 = TextEditingController();
  final TextEditingController saturdayPmFrom4 = TextEditingController();
  final TextEditingController saturdayPmTo4 = TextEditingController();
  final TextEditingController saturdayNightName4 = TextEditingController();
  final TextEditingController saturdayNightFrom4 = TextEditingController();
  final TextEditingController saturdayNightTo4 = TextEditingController();
  final TextEditingController saturdayAmName5 = TextEditingController();
  final TextEditingController saturdayAmFrom5 = TextEditingController();
  final TextEditingController saturdayAmTo5 = TextEditingController();
  final TextEditingController saturdayPmName5 = TextEditingController();
  final TextEditingController saturdayPmFrom5 = TextEditingController();
  final TextEditingController saturdayPmTo5 = TextEditingController();
  final TextEditingController saturdayNightName5 = TextEditingController();
  final TextEditingController saturdayNightFrom5 = TextEditingController();
  final TextEditingController saturdayNightTo5 = TextEditingController();
  final TextEditingController sundayAmName1 = TextEditingController();
  final TextEditingController sundayAmFrom1 = TextEditingController();
  final TextEditingController sundayAmTo1 = TextEditingController();
  final TextEditingController sundayPmName1 = TextEditingController();
  final TextEditingController sundayPmFrom1 = TextEditingController();
  final TextEditingController sundayPmTo1 = TextEditingController();
  final TextEditingController sundayNightName1 = TextEditingController();
  final TextEditingController sundayNightFrom1 = TextEditingController();
  final TextEditingController sundayNightTo1 = TextEditingController();
  final TextEditingController sundayAmName2 = TextEditingController();
  final TextEditingController sundayAmFrom2 = TextEditingController();
  final TextEditingController sundayAmTo2 = TextEditingController();
  final TextEditingController sundayPmName2 = TextEditingController();
  final TextEditingController sundayPmFrom2 = TextEditingController();
  final TextEditingController sundayPmTo2 = TextEditingController();
  final TextEditingController sundayNightName2 = TextEditingController();
  final TextEditingController sundayNightFrom2 = TextEditingController();
  final TextEditingController sundayNightTo2 = TextEditingController();
  final TextEditingController sundayAmName3 = TextEditingController();
  final TextEditingController sundayAmFrom3 = TextEditingController();
  final TextEditingController sundayAmTo3 = TextEditingController();
  final TextEditingController sundayPmName3 = TextEditingController();
  final TextEditingController sundayPmFrom3 = TextEditingController();
  final TextEditingController sundayPmTo3 = TextEditingController();
  final TextEditingController sundayNightName3 = TextEditingController();
  final TextEditingController sundayNightFrom3 = TextEditingController();
  final TextEditingController sundayNightTo3 = TextEditingController();
  final TextEditingController sundayAmName4 = TextEditingController();
  final TextEditingController sundayAmFrom4 = TextEditingController();
  final TextEditingController sundayAmTo4 = TextEditingController();
  final TextEditingController sundayPmName4 = TextEditingController();
  final TextEditingController sundayPmFrom4 = TextEditingController();
  final TextEditingController sundayPmTo4 = TextEditingController();
  final TextEditingController sundayNightName4 = TextEditingController();
  final TextEditingController sundayNightFrom4 = TextEditingController();
  final TextEditingController sundayNightTo4 = TextEditingController();
  final TextEditingController sundayAmName5 = TextEditingController();
  final TextEditingController sundayAmFrom5 = TextEditingController();
  final TextEditingController sundayAmTo5 = TextEditingController();
  final TextEditingController sundayPmName5 = TextEditingController();
  final TextEditingController sundayPmFrom5 = TextEditingController();
  final TextEditingController sundayPmTo5 = TextEditingController();
  final TextEditingController sundayNightName5 = TextEditingController();
  final TextEditingController sundayNightFrom5 = TextEditingController();
  final TextEditingController sundayNightTo5 = TextEditingController();


  int rowCountMondayAm = 1;
  int roleCountMondayAm = 1;

  int rowCountMondayPm = 1;
  int roleCountMondayPm = 1;

  int rowCountMondayNight = 1;
  int roleCountMondayNight = 1;

  int rowCountTuesdayAm = 1;
  int roleCountTuesdayAm = 1;

  int rowCountTuesdayPm = 1;
  int roleCountTuesdayPm = 1;

  int rowCountTuesdayNight = 1;
  int roleCountTuesdayNight = 1;

  int rowCountWednesdayAm = 1;
  int roleCountWednesdayAm = 1;

  int rowCountWednesdayPm = 1;
  int roleCountWednesdayPm = 1;

  int rowCountWednesdayNight = 1;
  int roleCountWednesdayNight = 1;

  int rowCountThursdayAm = 1;
  int roleCountThursdayAm = 1;

  int rowCountThursdayPm = 1;
  int roleCountThursdayPm = 1;

  int rowCountThursdayNight = 1;
  int roleCountThursdayNight = 1;

  int rowCountFridayAm = 1;
  int roleCountFridayAm = 1;

  int rowCountFridayPm = 1;
  int roleCountFridayPm = 1;

  int rowCountFridayNight = 1;
  int roleCountFridayNight = 1;

  int rowCountSaturdayAm = 1;
  int roleCountSaturdayAm = 1;

  int rowCountSaturdayPm = 1;
  int roleCountSaturdayPm = 1;

  int rowCountSaturdayNight = 1;
  int roleCountSaturdayNight = 1;

  int rowCountSundayAm = 1;
  int roleCountSundayAm = 1;

  int rowCountSundayPm = 1;
  int roleCountSundayPm = 1;

  int rowCountSundayNight = 1;
  int roleCountSundayNight = 1;

  String jobRefRef = 'Select One';

  List<String> jobRefDrop = [
    'Select One',
  ];


  @override
  void initState() {
    // TODO: implement initState
    _loadingTemporary = true;
    bedRotaModel = Provider.of<BedRotaModel>(context, listen: false);
    jobRefsModel = context.read<JobRefsModel>();
    _setUpTextControllerListeners();
    _getTemporaryBedRota();
    super.initState();
  }

  @override
  void dispose() {
    jobRef.dispose();
    weekCommencing.dispose();
    mondayAmName1.dispose();
    mondayAmFrom1.dispose();
    mondayAmTo1.dispose();
    mondayPmName1.dispose();
    mondayPmFrom1.dispose();
    mondayPmTo1.dispose();
    mondayNightName1.dispose();
    mondayNightFrom1.dispose();
    mondayNightTo1.dispose();
    mondayAmName2.dispose();
    mondayAmFrom2.dispose();
    mondayAmTo2.dispose();
    mondayPmName2.dispose();
    mondayPmFrom2.dispose();
    mondayPmTo2.dispose();
    mondayNightName2.dispose();
    mondayNightFrom2.dispose();
    mondayNightTo2.dispose();
    mondayAmName3.dispose();
    mondayAmFrom3.dispose();
    mondayAmTo3.dispose();
    mondayPmName3.dispose();
    mondayPmFrom3.dispose();
    mondayPmTo3.dispose();
    mondayNightName3.dispose();
    mondayNightFrom3.dispose();
    mondayNightTo3.dispose();
    mondayAmName4.dispose();
    mondayAmFrom4.dispose();
    mondayAmTo4.dispose();
    mondayPmName4.dispose();
    mondayPmFrom4.dispose();
    mondayPmTo4.dispose();
    mondayNightName4.dispose();
    mondayNightFrom4.dispose();
    mondayNightTo4.dispose();
    mondayAmName5.dispose();
    mondayAmFrom5.dispose();
    mondayAmTo5.dispose();
    mondayPmName5.dispose();
    mondayPmFrom5.dispose();
    mondayPmTo5.dispose();
    mondayNightName5.dispose();
    mondayNightFrom5.dispose();
    mondayNightTo5.dispose();
    tuesdayAmName1.dispose();
    tuesdayAmFrom1.dispose();
    tuesdayAmTo1.dispose();
    tuesdayPmName1.dispose();
    tuesdayPmFrom1.dispose();
    tuesdayPmTo1.dispose();
    tuesdayNightName1.dispose();
    tuesdayNightFrom1.dispose();
    tuesdayNightTo1.dispose();
    tuesdayAmName2.dispose();
    tuesdayAmFrom2.dispose();
    tuesdayAmTo2.dispose();
    tuesdayPmName2.dispose();
    tuesdayPmFrom2.dispose();
    tuesdayPmTo2.dispose();
    tuesdayNightName2.dispose();
    tuesdayNightFrom2.dispose();
    tuesdayNightTo2.dispose();
    tuesdayAmName3.dispose();
    tuesdayAmFrom3.dispose();
    tuesdayAmTo3.dispose();
    tuesdayPmName3.dispose();
    tuesdayPmFrom3.dispose();
    tuesdayPmTo3.dispose();
    tuesdayNightName3.dispose();
    tuesdayNightFrom3.dispose();
    tuesdayNightTo3.dispose();
    tuesdayAmName4.dispose();
    tuesdayAmFrom4.dispose();
    tuesdayAmTo4.dispose();
    tuesdayPmName4.dispose();
    tuesdayPmFrom4.dispose();
    tuesdayPmTo4.dispose();
    tuesdayNightName4.dispose();
    tuesdayNightFrom4.dispose();
    tuesdayNightTo4.dispose();
    tuesdayAmName5.dispose();
    tuesdayAmFrom5.dispose();
    tuesdayAmTo5.dispose();
    tuesdayPmName5.dispose();
    tuesdayPmFrom5.dispose();
    tuesdayPmTo5.dispose();
    tuesdayNightName5.dispose();
    tuesdayNightFrom5.dispose();
    tuesdayNightTo5.dispose();
    wednesdayAmName1.dispose();
    wednesdayAmFrom1.dispose();
    wednesdayAmTo1.dispose();
    wednesdayPmName1.dispose();
    wednesdayPmFrom1.dispose();
    wednesdayPmTo1.dispose();
    wednesdayNightName1.dispose();
    wednesdayNightFrom1.dispose();
    wednesdayNightTo1.dispose();
    wednesdayAmName2.dispose();
    wednesdayAmFrom2.dispose();
    wednesdayAmTo2.dispose();
    wednesdayPmName2.dispose();
    wednesdayPmFrom2.dispose();
    wednesdayPmTo2.dispose();
    wednesdayNightName2.dispose();
    wednesdayNightFrom2.dispose();
    wednesdayNightTo2.dispose();
    wednesdayAmName3.dispose();
    wednesdayAmFrom3.dispose();
    wednesdayAmTo3.dispose();
    wednesdayPmName3.dispose();
    wednesdayPmFrom3.dispose();
    wednesdayPmTo3.dispose();
    wednesdayNightName3.dispose();
    wednesdayNightFrom3.dispose();
    wednesdayNightTo3.dispose();
    wednesdayAmName4.dispose();
    wednesdayAmFrom4.dispose();
    wednesdayAmTo4.dispose();
    wednesdayPmName4.dispose();
    wednesdayPmFrom4.dispose();
    wednesdayPmTo4.dispose();
    wednesdayNightName4.dispose();
    wednesdayNightFrom4.dispose();
    wednesdayNightTo4.dispose();
    wednesdayAmName5.dispose();
    wednesdayAmFrom5.dispose();
    wednesdayAmTo5.dispose();
    wednesdayPmName5.dispose();
    wednesdayPmFrom5.dispose();
    wednesdayPmTo5.dispose();
    wednesdayNightName5.dispose();
    wednesdayNightFrom5.dispose();
    wednesdayNightTo5.dispose();
    thursdayAmName1.dispose();
    thursdayAmFrom1.dispose();
    thursdayAmTo1.dispose();
    thursdayPmName1.dispose();
    thursdayPmFrom1.dispose();
    thursdayPmTo1.dispose();
    thursdayNightName1.dispose();
    thursdayNightFrom1.dispose();
    thursdayNightTo1.dispose();
    thursdayAmName2.dispose();
    thursdayAmFrom2.dispose();
    thursdayAmTo2.dispose();
    thursdayPmName2.dispose();
    thursdayPmFrom2.dispose();
    thursdayPmTo2.dispose();
    thursdayNightName2.dispose();
    thursdayNightFrom2.dispose();
    thursdayNightTo2.dispose();
    thursdayAmName3.dispose();
    thursdayAmFrom3.dispose();
    thursdayAmTo3.dispose();
    thursdayPmName3.dispose();
    thursdayPmFrom3.dispose();
    thursdayPmTo3.dispose();
    thursdayNightName3.dispose();
    thursdayNightFrom3.dispose();
    thursdayNightTo3.dispose();
    thursdayAmName4.dispose();
    thursdayAmFrom4.dispose();
    thursdayAmTo4.dispose();
    thursdayPmName4.dispose();
    thursdayPmFrom4.dispose();
    thursdayPmTo4.dispose();
    thursdayNightName4.dispose();
    thursdayNightFrom4.dispose();
    thursdayNightTo4.dispose();
    thursdayAmName5.dispose();
    thursdayAmFrom5.dispose();
    thursdayAmTo5.dispose();
    thursdayPmName5.dispose();
    thursdayPmFrom5.dispose();
    thursdayPmTo5.dispose();
    thursdayNightName5.dispose();
    thursdayNightFrom5.dispose();
    thursdayNightTo5.dispose();
    fridayAmName1.dispose();
    fridayAmFrom1.dispose();
    fridayAmTo1.dispose();
    fridayPmName1.dispose();
    fridayPmFrom1.dispose();
    fridayPmTo1.dispose();
    fridayNightName1.dispose();
    fridayNightFrom1.dispose();
    fridayNightTo1.dispose();
    fridayAmName2.dispose();
    fridayAmFrom2.dispose();
    fridayAmTo2.dispose();
    fridayPmName2.dispose();
    fridayPmFrom2.dispose();
    fridayPmTo2.dispose();
    fridayNightName2.dispose();
    fridayNightFrom2.dispose();
    fridayNightTo2.dispose();
    fridayAmName3.dispose();
    fridayAmFrom3.dispose();
    fridayAmTo3.dispose();
    fridayPmName3.dispose();
    fridayPmFrom3.dispose();
    fridayPmTo3.dispose();
    fridayNightName3.dispose();
    fridayNightFrom3.dispose();
    fridayNightTo3.dispose();
    fridayAmName4.dispose();
    fridayAmFrom4.dispose();
    fridayAmTo4.dispose();
    fridayPmName4.dispose();
    fridayPmFrom4.dispose();
    fridayPmTo4.dispose();
    fridayNightName4.dispose();
    fridayNightFrom4.dispose();
    fridayNightTo4.dispose();
    fridayAmName5.dispose();
    fridayAmFrom5.dispose();
    fridayAmTo5.dispose();
    fridayPmName5.dispose();
    fridayPmFrom5.dispose();
    fridayPmTo5.dispose();
    fridayNightName5.dispose();
    fridayNightFrom5.dispose();
    fridayNightTo5.dispose();
    saturdayAmName1.dispose();
    saturdayAmFrom1.dispose();
    saturdayAmTo1.dispose();
    saturdayPmName1.dispose();
    saturdayPmFrom1.dispose();
    saturdayPmTo1.dispose();
    saturdayNightName1.dispose();
    saturdayNightFrom1.dispose();
    saturdayNightTo1.dispose();
    saturdayAmName2.dispose();
    saturdayAmFrom2.dispose();
    saturdayAmTo2.dispose();
    saturdayPmName2.dispose();
    saturdayPmFrom2.dispose();
    saturdayPmTo2.dispose();
    saturdayNightName2.dispose();
    saturdayNightFrom2.dispose();
    saturdayNightTo2.dispose();
    saturdayAmName3.dispose();
    saturdayAmFrom3.dispose();
    saturdayAmTo3.dispose();
    saturdayPmName3.dispose();
    saturdayPmFrom3.dispose();
    saturdayPmTo3.dispose();
    saturdayNightName3.dispose();
    saturdayNightFrom3.dispose();
    saturdayNightTo3.dispose();
    saturdayAmName4.dispose();
    saturdayAmFrom4.dispose();
    saturdayAmTo4.dispose();
    saturdayPmName4.dispose();
    saturdayPmFrom4.dispose();
    saturdayPmTo4.dispose();
    saturdayNightName4.dispose();
    saturdayNightFrom4.dispose();
    saturdayNightTo4.dispose();
    saturdayAmName5.dispose();
    saturdayAmFrom5.dispose();
    saturdayAmTo5.dispose();
    saturdayPmName5.dispose();
    saturdayPmFrom5.dispose();
    saturdayPmTo5.dispose();
    saturdayNightName5.dispose();
    saturdayNightFrom5.dispose();
    saturdayNightTo5.dispose();
    sundayAmName1.dispose();
    sundayAmFrom1.dispose();
    sundayAmTo1.dispose();
    sundayPmName1.dispose();
    sundayPmFrom1.dispose();
    sundayPmTo1.dispose();
    sundayNightName1.dispose();
    sundayNightFrom1.dispose();
    sundayNightTo1.dispose();
    sundayAmName2.dispose();
    sundayAmFrom2.dispose();
    sundayAmTo2.dispose();
    sundayPmName2.dispose();
    sundayPmFrom2.dispose();
    sundayPmTo2.dispose();
    sundayNightName2.dispose();
    sundayNightFrom2.dispose();
    sundayNightTo2.dispose();
    sundayAmName3.dispose();
    sundayAmFrom3.dispose();
    sundayAmTo3.dispose();
    sundayPmName3.dispose();
    sundayPmFrom3.dispose();
    sundayPmTo3.dispose();
    sundayNightName3.dispose();
    sundayNightFrom3.dispose();
    sundayNightTo3.dispose();
    sundayAmName4.dispose();
    sundayAmFrom4.dispose();
    sundayAmTo4.dispose();
    sundayPmName4.dispose();
    sundayPmFrom4.dispose();
    sundayPmTo4.dispose();
    sundayNightName4.dispose();
    sundayNightFrom4.dispose();
    sundayNightTo4.dispose();
    sundayAmName5.dispose();
    sundayAmFrom5.dispose();
    sundayAmTo5.dispose();
    sundayPmName5.dispose();
    sundayPmFrom5.dispose();
    sundayPmTo5.dispose();
    sundayNightName5.dispose();
    sundayNightFrom5.dispose();
    sundayNightTo5.dispose();
    super.dispose();
  }




  _addListener(TextEditingController controller, String value, [bool encrypt = true, bool capitalise = false, bool isName = false]){

    controller.addListener(() {
      setState(() {
      });

      String controllerText = controller.text;

      if(capitalise){
        controllerText = controllerText.toUpperCase();
      }

      if(isName){
        String newString = '';
        List<String> parts = controllerText.split(' ');
        for(String part in parts){
          if(part.isNotEmpty) part = part[0].toUpperCase() + part.substring(1);
          if(newString.isEmpty){
            newString += part;
          } else {
            newString = newString + ' ' + part;
          }
        }

        controllerText = newString;
      }

      //Sembast
      bedRotaModel.updateTemporaryRecord(widget.edit, value, encrypt ? GlobalFunctions.encryptString(controllerText) : GlobalFunctions.databaseValueString(controllerText), widget.jobId, widget.saved, widget.savedId);
    });
  }

  _setUpTextControllerListeners() {
    _addListener(jobRef, Strings.jobRefNo, false, true);
    _addListener(mondayAmName1, Strings.mondayAmName1, true, false, true);
    _addListener(mondayPmName1, Strings.mondayPmName1, true, false, true);
    _addListener(mondayNightName1, Strings.mondayNightName1, true, false, true);
    _addListener(mondayAmName2, Strings.mondayAmName2, true, false, true);
    _addListener(mondayPmName2, Strings.mondayPmName2, true, false, true);
    _addListener(mondayNightName2, Strings.mondayNightName2, true, false, true);
    _addListener(mondayAmName3, Strings.mondayAmName3, true, false, true);
    _addListener(mondayPmName3, Strings.mondayPmName3, true, false, true);
    _addListener(mondayNightName3, Strings.mondayNightName3, true, false, true);
    _addListener(mondayAmName4, Strings.mondayAmName4, true, false, true);
    _addListener(mondayPmName4, Strings.mondayPmName4, true, false, true);
    _addListener(mondayNightName4, Strings.mondayNightName4, true, false, true);
    _addListener(mondayAmName5, Strings.mondayAmName5, true, false, true);
    _addListener(mondayPmName5, Strings.mondayPmName5, true, false, true);
    _addListener(mondayNightName5, Strings.mondayNightName5, true, false, true);
    _addListener(tuesdayAmName1, Strings.tuesdayAmName1, true, false, true);
    _addListener(tuesdayPmName1, Strings.tuesdayPmName1, true, false, true);
    _addListener(tuesdayNightName1, Strings.tuesdayNightName1, true, false, true);
    _addListener(tuesdayAmName2, Strings.tuesdayAmName2, true, false, true);
    _addListener(tuesdayPmName2, Strings.tuesdayPmName2, true, false, true);
    _addListener(tuesdayNightName2, Strings.tuesdayNightName2, true, false, true);
    _addListener(tuesdayAmName3, Strings.tuesdayAmName3, true, false, true);
    _addListener(tuesdayPmName3, Strings.tuesdayPmName3, true, false, true);
    _addListener(tuesdayNightName3, Strings.tuesdayNightName3, true, false, true);
    _addListener(tuesdayAmName4, Strings.tuesdayAmName4, true, false, true);
    _addListener(tuesdayPmName4, Strings.tuesdayPmName4, true, false, true);
    _addListener(tuesdayNightName4, Strings.tuesdayNightName4, true, false, true);
    _addListener(tuesdayAmName5, Strings.tuesdayAmName5, true, false, true);
    _addListener(tuesdayPmName5, Strings.tuesdayPmName5, true, false, true);
    _addListener(tuesdayNightName5, Strings.tuesdayNightName5, true, false, true);
    _addListener(wednesdayAmName1, Strings.wednesdayAmName1, true, false, true);
    _addListener(wednesdayPmName1, Strings.wednesdayPmName1, true, false, true);
    _addListener(wednesdayNightName1, Strings.wednesdayNightName1, true, false, true);
    _addListener(wednesdayAmName2, Strings.wednesdayAmName2, true, false, true);
    _addListener(wednesdayPmName2, Strings.wednesdayPmName2, true, false, true);
    _addListener(wednesdayNightName2, Strings.wednesdayNightName2, true, false, true);
    _addListener(wednesdayAmName3, Strings.wednesdayAmName3, true, false, true);
    _addListener(wednesdayPmName3, Strings.wednesdayPmName3, true, false, true);
    _addListener(wednesdayNightName3, Strings.wednesdayNightName3, true, false, true);
    _addListener(wednesdayAmName4, Strings.wednesdayAmName4, true, false, true);
    _addListener(wednesdayPmName4, Strings.wednesdayPmName4, true, false, true);
    _addListener(wednesdayNightName4, Strings.wednesdayNightName4, true, false, true);
    _addListener(wednesdayAmName5, Strings.wednesdayAmName5, true, false, true);
    _addListener(wednesdayPmName5, Strings.wednesdayPmName5, true, false, true);
    _addListener(wednesdayNightName5, Strings.wednesdayNightName5, true, false, true);
    _addListener(thursdayAmName1, Strings.thursdayAmName1, true, false, true);
    _addListener(thursdayPmName1, Strings.thursdayPmName1, true, false, true);
    _addListener(thursdayNightName1, Strings.thursdayNightName1, true, false, true);
    _addListener(thursdayAmName2, Strings.thursdayAmName2, true, false, true);
    _addListener(thursdayPmName2, Strings.thursdayPmName2, true, false, true);
    _addListener(thursdayNightName2, Strings.thursdayNightName2, true, false, true);
    _addListener(thursdayAmName3, Strings.thursdayAmName3, true, false, true);
    _addListener(thursdayPmName3, Strings.thursdayPmName3, true, false, true);
    _addListener(thursdayNightName3, Strings.thursdayNightName3, true, false, true);
    _addListener(thursdayAmName4, Strings.thursdayAmName4, true, false, true);
    _addListener(thursdayPmName4, Strings.thursdayPmName4, true, false, true);
    _addListener(thursdayNightName4, Strings.thursdayNightName4, true, false, true);
    _addListener(thursdayAmName5, Strings.thursdayAmName5, true, false, true);
    _addListener(thursdayPmName5, Strings.thursdayPmName5, true, false, true);
    _addListener(thursdayNightName5, Strings.thursdayNightName5, true, false, true);
    _addListener(fridayAmName1, Strings.fridayAmName1, true, false, true);
    _addListener(fridayPmName1, Strings.fridayPmName1, true, false, true);
    _addListener(fridayNightName1, Strings.fridayNightName1, true, false, true);
    _addListener(fridayAmName2, Strings.fridayAmName2, true, false, true);
    _addListener(fridayPmName2, Strings.fridayPmName2, true, false, true);
    _addListener(fridayNightName2, Strings.fridayNightName2, true, false, true);
    _addListener(fridayAmName3, Strings.fridayAmName3, true, false, true);
    _addListener(fridayPmName3, Strings.fridayPmName3, true, false, true);
    _addListener(fridayNightName3, Strings.fridayNightName3, true, false, true);
    _addListener(fridayAmName4, Strings.fridayAmName4, true, false, true);
    _addListener(fridayPmName4, Strings.fridayPmName4, true, false, true);
    _addListener(fridayNightName4, Strings.fridayNightName4, true, false, true);
    _addListener(fridayAmName5, Strings.fridayAmName5, true, false, true);
    _addListener(fridayPmName5, Strings.fridayPmName5, true, false, true);
    _addListener(fridayNightName5, Strings.fridayNightName5, true, false, true);
    _addListener(saturdayAmName1, Strings.saturdayAmName1, true, false, true);
    _addListener(saturdayPmName1, Strings.saturdayPmName1, true, false, true);
    _addListener(saturdayNightName1, Strings.saturdayNightName1, true, false, true);
    _addListener(saturdayAmName2, Strings.saturdayAmName2, true, false, true);
    _addListener(saturdayPmName2, Strings.saturdayPmName2, true, false, true);
    _addListener(saturdayNightName2, Strings.saturdayNightName2, true, false, true);
    _addListener(saturdayAmName3, Strings.saturdayAmName3, true, false, true);
    _addListener(saturdayPmName3, Strings.saturdayPmName3, true, false, true);
    _addListener(saturdayNightName3, Strings.saturdayNightName3, true, false, true);
    _addListener(saturdayAmName4, Strings.saturdayAmName4, true, false, true);
    _addListener(saturdayPmName4, Strings.saturdayPmName4, true, false, true);
    _addListener(saturdayNightName4, Strings.saturdayNightName4, true, false, true);
    _addListener(saturdayAmName5, Strings.saturdayAmName5, true, false, true);
    _addListener(saturdayPmName5, Strings.saturdayPmName5, true, false, true);
    _addListener(saturdayNightName5, Strings.saturdayNightName5, true, false, true);
    _addListener(sundayAmName1, Strings.sundayAmName1, true, false, true);
    _addListener(sundayPmName1, Strings.sundayPmName1, true, false, true);
    _addListener(sundayNightName1, Strings.sundayNightName1, true, false, true);
    _addListener(sundayAmName2, Strings.sundayAmName2, true, false, true);
    _addListener(sundayPmName2, Strings.sundayPmName2, true, false, true);
    _addListener(sundayNightName2, Strings.sundayNightName2, true, false, true);
    _addListener(sundayAmName3, Strings.sundayAmName3, true, false, true);
    _addListener(sundayPmName3, Strings.sundayPmName3, true, false, true);
    _addListener(sundayNightName3, Strings.sundayNightName3, true, false, true);
    _addListener(sundayAmName4, Strings.sundayAmName4, true, false, true);
    _addListener(sundayPmName4, Strings.sundayPmName4, true, false, true);
    _addListener(sundayNightName4, Strings.sundayNightName4, true, false, true);
    _addListener(sundayAmName5, Strings.sundayAmName5, true, false, true);
    _addListener(sundayPmName5, Strings.sundayPmName5, true, false, true);
    _addListener(sundayNightName5, Strings.sundayNightName5, true, false, true);
  }

  _getTemporaryBedRota() async {

    if (mounted) {

      await jobRefsModel.getJobRefs();

      if(jobRefsModel.allJobRefs.isNotEmpty){
        for(Map<String, dynamic> jobRefMap in jobRefsModel.allJobRefs){
          jobRefDrop.add(jobRefMap['job_ref']);
        }
      }

      await bedRotaModel.setupTemporaryRecord();

      bool hasRecord = await bedRotaModel.checkRecordExists(widget.edit, widget.jobId, widget.saved, widget.savedId);


      if (hasRecord) {
        Map<String, dynamic> bedRota = await bedRotaModel.getTemporaryRecord(widget.edit, widget.jobId, widget.saved, widget.savedId);



        if (bedRota[Strings.jobRefNo] != null) {
          jobRef.text = GlobalFunctions.databaseValueString(
              bedRota[Strings.jobRefNo]);
        } else {
          jobRef.text = '';
        }

        if (bedRota[Strings.jobRefRef] != null) {

          if(jobRefDrop.contains(GlobalFunctions.databaseValueString(bedRota[Strings.jobRefRef]))){
            jobRefRef = GlobalFunctions.databaseValueString(bedRota[Strings.jobRefRef]);
          } else {
            jobRefRef = 'Select One';
          }

        }

        if (bedRota[Strings.weekCommencing] != null) {
          weekCommencing.text =
              dateFormat.format(DateTime.parse(bedRota[Strings.weekCommencing]));
        } else {
          weekCommencing.text = '';
        }

        //Monday Am
        if (bedRota[Strings.mondayAmFrom2] != null ||
            bedRota[Strings.mondayAmTo2] != null ||
            (bedRota[Strings.mondayAmName2] != null && bedRota[Strings.mondayAmName2] != '')) {
          setState(() {
            roleCountMondayAm += 1;
          });
        }

        if (bedRota[Strings.mondayAmFrom3] != null ||
            bedRota[Strings.mondayAmTo3] != null ||
            (bedRota[Strings.mondayAmName3] != null && bedRota[Strings.mondayAmName3] != '')) {
          setState(() {
            roleCountMondayAm += 1;
          });
        }

        if (bedRota[Strings.mondayAmFrom4] != null ||
            bedRota[Strings.mondayAmTo4] != null ||
            (bedRota[Strings.mondayAmName4] != null && bedRota[Strings.mondayAmName4] != '')) {
          setState(() {
            roleCountMondayAm += 1;
          });
        }

        if (bedRota[Strings.mondayAmFrom5] != null ||
            bedRota[Strings.mondayAmTo5] != null ||
            (bedRota[Strings.mondayAmName5] != null && bedRota[Strings.mondayAmName5] != '')) {
          setState(() {
            roleCountMondayAm += 1;
          });
        }

        //Monday Pm
        if (bedRota[Strings.mondayPmFrom2] != null ||
            bedRota[Strings.mondayPmTo2] != null ||
            (bedRota[Strings.mondayPmName2] != null && bedRota[Strings.mondayPmName2] != '')) {
          setState(() {
            roleCountMondayPm += 1;
          });
        }

        if (bedRota[Strings.mondayPmFrom3] != null ||
            bedRota[Strings.mondayPmTo3] != null ||
            (bedRota[Strings.mondayPmName3] != null && bedRota[Strings.mondayPmName3] != '')) {
          setState(() {
            roleCountMondayPm += 1;
          });
        }

        if (bedRota[Strings.mondayPmFrom4] != null ||
            bedRota[Strings.mondayPmTo4] != null ||
            (bedRota[Strings.mondayPmName4] != null && bedRota[Strings.mondayPmName4] != '')) {
          setState(() {
            roleCountMondayPm += 1;
          });
        }

        if (bedRota[Strings.mondayPmFrom5] != null ||
            bedRota[Strings.mondayPmTo5] != null ||
            (bedRota[Strings.mondayPmName5] != null && bedRota[Strings.mondayPmName5] != '')) {
          setState(() {
            roleCountMondayPm += 1;
          });
        }

        //Monday Night
        if (bedRota[Strings.mondayNightFrom2] != null ||
            bedRota[Strings.mondayNightTo2] != null ||
            (bedRota[Strings.mondayNightName2] != null && bedRota[Strings.mondayNightName2] != '')) {
          setState(() {
            roleCountMondayNight += 1;
          });
        }

        if (bedRota[Strings.mondayNightFrom3] != null ||
            bedRota[Strings.mondayNightTo3] != null ||
            (bedRota[Strings.mondayNightName3] != null && bedRota[Strings.mondayNightName3] != '')) {
          setState(() {
            roleCountMondayNight += 1;
          });
        }

        if (bedRota[Strings.mondayNightFrom4] != null ||
            bedRota[Strings.mondayNightTo4] != null ||
            (bedRota[Strings.mondayNightName4] != null && bedRota[Strings.mondayNightName4] != '')) {
          setState(() {
            roleCountMondayNight += 1;
          });
        }

        if (bedRota[Strings.mondayNightFrom5] != null ||
            bedRota[Strings.mondayNightTo5] != null ||
            (bedRota[Strings.mondayNightName5] != null && bedRota[Strings.mondayNightName5] != '')) {
          setState(() {
            roleCountMondayNight += 1;
          });
        }

        //Tuesday Am
        if (bedRota[Strings.tuesdayAmFrom2] != null ||
            bedRota[Strings.tuesdayAmTo2] != null ||
            (bedRota[Strings.tuesdayAmName2] != null && bedRota[Strings.tuesdayAmName2] != '')) {
          setState(() {
            roleCountTuesdayAm += 1;
          });
        }

        if (bedRota[Strings.tuesdayAmFrom3] != null ||
            bedRota[Strings.tuesdayAmTo3] != null ||
            (bedRota[Strings.tuesdayAmName3] != null && bedRota[Strings.tuesdayAmName3] != '')) {
          setState(() {
            roleCountTuesdayAm += 1;
          });
        }

        if (bedRota[Strings.tuesdayAmFrom4] != null ||
            bedRota[Strings.tuesdayAmTo4] != null ||
            (bedRota[Strings.tuesdayAmName4] != null && bedRota[Strings.tuesdayAmName4] != '')) {
          setState(() {
            roleCountTuesdayAm += 1;
          });
        }

        if (bedRota[Strings.tuesdayAmFrom5] != null ||
            bedRota[Strings.tuesdayAmTo5] != null ||
            (bedRota[Strings.tuesdayAmName5] != null && bedRota[Strings.tuesdayAmName5] != '')) {
          setState(() {
            roleCountTuesdayAm += 1;
          });
        }

        //Tuesday Pm
        if (bedRota[Strings.tuesdayPmFrom2] != null ||
            bedRota[Strings.tuesdayPmTo2] != null ||
            (bedRota[Strings.tuesdayPmName2] != null && bedRota[Strings.tuesdayPmName2] != '')) {
          setState(() {
            roleCountTuesdayPm += 1;
          });
        }

        if (bedRota[Strings.tuesdayPmFrom3] != null ||
            bedRota[Strings.tuesdayPmTo3] != null ||
            (bedRota[Strings.tuesdayPmName3] != null && bedRota[Strings.tuesdayPmName3] != '')) {
          setState(() {
            roleCountTuesdayPm += 1;
          });
        }

        if (bedRota[Strings.tuesdayPmFrom4] != null ||
            bedRota[Strings.tuesdayPmTo4] != null ||
            (bedRota[Strings.tuesdayPmName4] != null && bedRota[Strings.tuesdayPmName4] != '')) {
          setState(() {
            roleCountTuesdayPm += 1;
          });
        }

        if (bedRota[Strings.tuesdayPmFrom5] != null ||
            bedRota[Strings.tuesdayPmTo5] != null ||
            (bedRota[Strings.tuesdayPmName5] != null && bedRota[Strings.tuesdayPmName5] != '')) {
          setState(() {
            roleCountTuesdayPm += 1;
          });
        }

        //Tuesday Night
        if (bedRota[Strings.tuesdayNightFrom2] != null ||
            bedRota[Strings.tuesdayNightTo2] != null ||
            (bedRota[Strings.tuesdayNightName2] != null && bedRota[Strings.tuesdayNightName2] != '')) {
          setState(() {
            roleCountTuesdayNight += 1;
          });
        }

        if (bedRota[Strings.tuesdayNightFrom3] != null ||
            bedRota[Strings.tuesdayNightTo3] != null ||
            (bedRota[Strings.tuesdayNightName3] != null && bedRota[Strings.tuesdayNightName3] != '')) {
          setState(() {
            roleCountTuesdayNight += 1;
          });
        }

        if (bedRota[Strings.tuesdayNightFrom4] != null ||
            bedRota[Strings.tuesdayNightTo4] != null ||
            (bedRota[Strings.tuesdayNightName4] != null && bedRota[Strings.tuesdayNightName4] != '')) {
          setState(() {
            roleCountTuesdayNight += 1;
          });
        }

        if (bedRota[Strings.tuesdayNightFrom5] != null ||
            bedRota[Strings.tuesdayNightTo5] != null ||
            (bedRota[Strings.tuesdayNightName5] != null && bedRota[Strings.tuesdayNightName5] != '')) {
          setState(() {
            roleCountTuesdayNight += 1;
          });
        }

        //Wednesday Am
        if (bedRota[Strings.wednesdayAmFrom2] != null ||
            bedRota[Strings.wednesdayAmTo2] != null ||
            (bedRota[Strings.wednesdayAmName2] != null && bedRota[Strings.wednesdayAmName2] != '')) {
          setState(() {
            roleCountWednesdayAm += 1;
          });
        }

        if (bedRota[Strings.wednesdayAmFrom3] != null ||
            bedRota[Strings.wednesdayAmTo3] != null ||
            (bedRota[Strings.wednesdayAmName3] != null && bedRota[Strings.wednesdayAmName3] != '')) {
          setState(() {
            roleCountWednesdayAm += 1;
          });
        }

        if (bedRota[Strings.wednesdayAmFrom4] != null ||
            bedRota[Strings.wednesdayAmTo4] != null ||
            (bedRota[Strings.wednesdayAmName4] != null && bedRota[Strings.wednesdayAmName4] != '')) {
          setState(() {
            roleCountWednesdayAm += 1;
          });
        }

        if (bedRota[Strings.wednesdayAmFrom5] != null ||
            bedRota[Strings.wednesdayAmTo5] != null ||
            (bedRota[Strings.wednesdayAmName5] != null && bedRota[Strings.wednesdayAmName5] != '')) {
          setState(() {
            roleCountWednesdayAm += 1;
          });
        }

        //Wednesday Pm
        if (bedRota[Strings.wednesdayPmFrom2] != null ||
            bedRota[Strings.wednesdayPmTo2] != null ||
            (bedRota[Strings.wednesdayPmName2] != null && bedRota[Strings.wednesdayPmName2] != '')) {
          setState(() {
            roleCountWednesdayPm += 1;
          });
        }

        if (bedRota[Strings.wednesdayPmFrom3] != null ||
            bedRota[Strings.wednesdayPmTo3] != null ||
            (bedRota[Strings.wednesdayPmName3] != null && bedRota[Strings.wednesdayPmName3] != '')) {
          setState(() {
            roleCountWednesdayPm += 1;
          });
        }

        if (bedRota[Strings.wednesdayPmFrom4] != null ||
            bedRota[Strings.wednesdayPmTo4] != null ||
            (bedRota[Strings.wednesdayPmName4] != null && bedRota[Strings.wednesdayPmName4] != '')) {
          setState(() {
            roleCountWednesdayPm += 1;
          });
        }

        if (bedRota[Strings.wednesdayPmFrom5] != null ||
            bedRota[Strings.wednesdayPmTo5] != null ||
            (bedRota[Strings.wednesdayPmName5] != null && bedRota[Strings.wednesdayPmName5] != '')) {
          setState(() {
            roleCountWednesdayPm += 1;
          });
        }

        //Wednesday Night
        if (bedRota[Strings.wednesdayNightFrom2] != null ||
            bedRota[Strings.wednesdayNightTo2] != null ||
            (bedRota[Strings.wednesdayNightName2] != null && bedRota[Strings.wednesdayNightName2] != '')) {
          setState(() {
            roleCountWednesdayNight += 1;
          });
        }

        if (bedRota[Strings.wednesdayNightFrom3] != null ||
            bedRota[Strings.wednesdayNightTo3] != null ||
            (bedRota[Strings.wednesdayNightName3] != null && bedRota[Strings.wednesdayNightName3] != '')) {
          setState(() {
            roleCountWednesdayNight += 1;
          });
        }

        if (bedRota[Strings.wednesdayNightFrom4] != null ||
            bedRota[Strings.wednesdayNightTo4] != null ||
            (bedRota[Strings.wednesdayNightName4] != null && bedRota[Strings.wednesdayNightName4] != '')) {
          setState(() {
            roleCountWednesdayNight += 1;
          });
        }

        if (bedRota[Strings.wednesdayNightFrom5] != null ||
            bedRota[Strings.wednesdayNightTo5] != null ||
            (bedRota[Strings.wednesdayNightName5] != null && bedRota[Strings.wednesdayNightName5] != '')) {
          setState(() {
            roleCountWednesdayNight += 1;
          });
        }

        //Thursday Am
        if (bedRota[Strings.thursdayAmFrom2] != null ||
            bedRota[Strings.thursdayAmTo2] != null ||
            (bedRota[Strings.thursdayAmName2] != null && bedRota[Strings.thursdayAmName2] != '')) {
          setState(() {
            roleCountThursdayAm += 1;
          });
        }

        if (bedRota[Strings.thursdayAmFrom3] != null ||
            bedRota[Strings.thursdayAmTo3] != null ||
            (bedRota[Strings.thursdayAmName3] != null && bedRota[Strings.thursdayAmName3] != '')) {
          setState(() {
            roleCountThursdayAm += 1;
          });
        }

        if (bedRota[Strings.thursdayAmFrom4] != null ||
            bedRota[Strings.thursdayAmTo4] != null ||
            (bedRota[Strings.thursdayAmName4] != null && bedRota[Strings.thursdayAmName4] != '')) {
          setState(() {
            roleCountThursdayAm += 1;
          });
        }

        if (bedRota[Strings.thursdayAmFrom5] != null ||
            bedRota[Strings.thursdayAmTo5] != null ||
            (bedRota[Strings.thursdayAmName5] != null && bedRota[Strings.thursdayAmName5] != '')) {
          setState(() {
            roleCountThursdayAm += 1;
          });
        }

        //Thursday Pm
        if (bedRota[Strings.thursdayPmFrom2] != null ||
            bedRota[Strings.thursdayPmTo2] != null ||
            (bedRota[Strings.thursdayPmName2] != null && bedRota[Strings.thursdayPmName2] != '')) {
          setState(() {
            roleCountThursdayPm += 1;
          });
        }

        if (bedRota[Strings.thursdayPmFrom3] != null ||
            bedRota[Strings.thursdayPmTo3] != null ||
            (bedRota[Strings.thursdayPmName3] != null && bedRota[Strings.thursdayPmName3] != '')) {
          setState(() {
            roleCountThursdayPm += 1;
          });
        }

        if (bedRota[Strings.thursdayPmFrom4] != null ||
            bedRota[Strings.thursdayPmTo4] != null ||
            (bedRota[Strings.thursdayPmName4] != null && bedRota[Strings.thursdayPmName4] != '')) {
          setState(() {
            roleCountThursdayPm += 1;
          });
        }

        if (bedRota[Strings.thursdayPmFrom5] != null ||
            bedRota[Strings.thursdayPmTo5] != null ||
            (bedRota[Strings.thursdayPmName5] != null && bedRota[Strings.thursdayPmName5] != '')) {
          setState(() {
            roleCountThursdayPm += 1;
          });
        }

        //Thursday Night
        if (bedRota[Strings.thursdayNightFrom2] != null ||
            bedRota[Strings.thursdayNightTo2] != null ||
            (bedRota[Strings.thursdayNightName2] != null && bedRota[Strings.thursdayNightName2] != '')) {
          setState(() {
            roleCountThursdayNight += 1;
          });
        }

        if (bedRota[Strings.thursdayNightFrom3] != null ||
            bedRota[Strings.thursdayNightTo3] != null ||
            (bedRota[Strings.thursdayNightName3] != null && bedRota[Strings.thursdayNightName3] != '')) {
          setState(() {
            roleCountThursdayNight += 1;
          });
        }

        if (bedRota[Strings.thursdayNightFrom4] != null ||
            bedRota[Strings.thursdayNightTo4] != null ||
            (bedRota[Strings.thursdayNightName4] != null && bedRota[Strings.thursdayNightName4] != '')) {
          setState(() {
            roleCountThursdayNight += 1;
          });
        }

        if (bedRota[Strings.thursdayNightFrom5] != null ||
            bedRota[Strings.thursdayNightTo5] != null ||
            (bedRota[Strings.thursdayNightName5] != null && bedRota[Strings.thursdayNightName5] != '')) {
          setState(() {
            roleCountThursdayNight += 1;
          });
        }

        //Friday Am
        if (bedRota[Strings.fridayAmFrom2] != null ||
            bedRota[Strings.fridayAmTo2] != null ||
            (bedRota[Strings.fridayAmName2] != null && bedRota[Strings.fridayAmName2] != '')) {
          setState(() {
            roleCountFridayAm += 1;
          });
        }

        if (bedRota[Strings.fridayAmFrom3] != null ||
            bedRota[Strings.fridayAmTo3] != null ||
            (bedRota[Strings.fridayAmName3] != null && bedRota[Strings.fridayAmName3] != '')) {
          setState(() {
            roleCountFridayAm += 1;
          });
        }

        if (bedRota[Strings.fridayAmFrom4] != null ||
            bedRota[Strings.fridayAmTo4] != null ||
            (bedRota[Strings.fridayAmName4] != null && bedRota[Strings.fridayAmName4] != '')) {
          setState(() {
            roleCountFridayAm += 1;
          });
        }

        if (bedRota[Strings.fridayAmFrom5] != null ||
            bedRota[Strings.fridayAmTo5] != null ||
            (bedRota[Strings.fridayAmName5] != null && bedRota[Strings.fridayAmName5] != '')) {
          setState(() {
            roleCountFridayAm += 1;
          });
        }

        //Friday Pm
        if (bedRota[Strings.fridayPmFrom2] != null ||
            bedRota[Strings.fridayPmTo2] != null ||
            (bedRota[Strings.fridayPmName2] != null && bedRota[Strings.fridayPmName2] != '')) {
          setState(() {
            roleCountFridayPm += 1;
          });
        }

        if (bedRota[Strings.fridayPmFrom3] != null ||
            bedRota[Strings.fridayPmTo3] != null ||
            (bedRota[Strings.fridayPmName3] != null && bedRota[Strings.fridayPmName3] != '')) {
          setState(() {
            roleCountFridayPm += 1;
          });
        }

        if (bedRota[Strings.fridayPmFrom4] != null ||
            bedRota[Strings.fridayPmTo4] != null ||
            (bedRota[Strings.fridayPmName4] != null && bedRota[Strings.fridayPmName4] != '')) {
          setState(() {
            roleCountFridayPm += 1;
          });
        }

        if (bedRota[Strings.fridayPmFrom5] != null ||
            bedRota[Strings.fridayPmTo5] != null ||
            (bedRota[Strings.fridayPmName5] != null && bedRota[Strings.fridayPmName5] != '')) {
          setState(() {
            roleCountFridayPm += 1;
          });
        }

        //Friday Night
        if (bedRota[Strings.fridayNightFrom2] != null ||
            bedRota[Strings.fridayNightTo2] != null ||
            (bedRota[Strings.fridayNightName2] != null && bedRota[Strings.fridayNightName2] != '')) {
          setState(() {
            roleCountFridayNight += 1;
          });
        }

        if (bedRota[Strings.fridayNightFrom3] != null ||
            bedRota[Strings.fridayNightTo3] != null ||
            (bedRota[Strings.fridayNightName3] != null && bedRota[Strings.fridayNightName3] != '')) {
          setState(() {
            roleCountFridayNight += 1;
          });
        }

        if (bedRota[Strings.fridayNightFrom4] != null ||
            bedRota[Strings.fridayNightTo4] != null ||
            (bedRota[Strings.fridayNightName4] != null && bedRota[Strings.fridayNightName4] != '')) {
          setState(() {
            roleCountFridayNight += 1;
          });
        }

        if (bedRota[Strings.fridayNightFrom5] != null ||
            bedRota[Strings.fridayNightTo5] != null ||
            (bedRota[Strings.fridayNightName5] != null && bedRota[Strings.fridayNightName5] != '')) {
          setState(() {
            roleCountFridayNight += 1;
          });
        }

        //Saturday Am
        if (bedRota[Strings.saturdayAmFrom2] != null ||
            bedRota[Strings.saturdayAmTo2] != null ||
            (bedRota[Strings.saturdayAmName2] != null && bedRota[Strings.saturdayAmName2] != '')) {
          setState(() {
            roleCountSaturdayAm += 1;
          });
        }

        if (bedRota[Strings.saturdayAmFrom3] != null ||
            bedRota[Strings.saturdayAmTo3] != null ||
            (bedRota[Strings.saturdayAmName3] != null && bedRota[Strings.saturdayAmName3] != '')) {
          setState(() {
            roleCountSaturdayAm += 1;
          });
        }

        if (bedRota[Strings.saturdayAmFrom4] != null ||
            bedRota[Strings.saturdayAmTo4] != null ||
            (bedRota[Strings.saturdayAmName4] != null && bedRota[Strings.saturdayAmName4] != '')) {
          setState(() {
            roleCountSaturdayAm += 1;
          });
        }

        if (bedRota[Strings.saturdayAmFrom5] != null ||
            bedRota[Strings.saturdayAmTo5] != null ||
            (bedRota[Strings.saturdayAmName5] != null && bedRota[Strings.saturdayAmName5] != '')) {
          setState(() {
            roleCountSaturdayAm += 1;
          });
        }

        //Saturday Pm
        if (bedRota[Strings.saturdayPmFrom2] != null ||
            bedRota[Strings.saturdayPmTo2] != null ||
            (bedRota[Strings.saturdayPmName2] != null && bedRota[Strings.saturdayPmName2] != '')) {
          setState(() {
            roleCountSaturdayPm += 1;
          });
        }

        if (bedRota[Strings.saturdayPmFrom3] != null ||
            bedRota[Strings.saturdayPmTo3] != null ||
            (bedRota[Strings.saturdayPmName3] != null && bedRota[Strings.saturdayPmName3] != '')) {
          setState(() {
            roleCountSaturdayPm += 1;
          });
        }

        if (bedRota[Strings.saturdayPmFrom4] != null ||
            bedRota[Strings.saturdayPmTo4] != null ||
            (bedRota[Strings.saturdayPmName4] != null && bedRota[Strings.saturdayPmName4] != '')) {
          setState(() {
            roleCountSaturdayPm += 1;
          });
        }

        if (bedRota[Strings.saturdayPmFrom5] != null ||
            bedRota[Strings.saturdayPmTo5] != null ||
            (bedRota[Strings.saturdayPmName5] != null && bedRota[Strings.saturdayPmName5] != '')) {
          setState(() {
            roleCountSaturdayPm += 1;
          });
        }

        //Saturday Night
        if (bedRota[Strings.saturdayNightFrom2] != null ||
            bedRota[Strings.saturdayNightTo2] != null ||
            (bedRota[Strings.saturdayNightName2] != null && bedRota[Strings.saturdayNightName2] != '')) {
          setState(() {
            roleCountSaturdayNight += 1;
          });
        }

        if (bedRota[Strings.saturdayNightFrom3] != null ||
            bedRota[Strings.saturdayNightTo3] != null ||
            (bedRota[Strings.saturdayNightName3] != null && bedRota[Strings.saturdayNightName3] != '')) {
          setState(() {
            roleCountSaturdayNight += 1;
          });
        }

        if (bedRota[Strings.saturdayNightFrom4] != null ||
            bedRota[Strings.saturdayNightTo4] != null ||
            (bedRota[Strings.saturdayNightName4] != null && bedRota[Strings.saturdayNightName4] != '')) {
          setState(() {
            roleCountSaturdayNight += 1;
          });
        }

        if (bedRota[Strings.saturdayNightFrom5] != null ||
            bedRota[Strings.saturdayNightTo5] != null ||
            (bedRota[Strings.saturdayNightName5] != null && bedRota[Strings.saturdayNightName5] != '')) {
          setState(() {
            roleCountSaturdayNight += 1;
          });
        }

        //Sunday Am
        if (bedRota[Strings.sundayAmFrom2] != null ||
            bedRota[Strings.sundayAmTo2] != null ||
            (bedRota[Strings.sundayAmName2] != null && bedRota[Strings.sundayAmName2] != '')) {
          setState(() {
            roleCountSundayAm += 1;
          });
        }

        if (bedRota[Strings.sundayAmFrom3] != null ||
            bedRota[Strings.sundayAmTo3] != null ||
            (bedRota[Strings.sundayAmName3] != null && bedRota[Strings.sundayAmName3] != '')) {
          setState(() {
            roleCountSundayAm += 1;
          });
        }

        if (bedRota[Strings.sundayAmFrom4] != null ||
            bedRota[Strings.sundayAmTo4] != null ||
            (bedRota[Strings.sundayAmName4] != null && bedRota[Strings.sundayAmName4] != '')) {
          setState(() {
            roleCountSundayAm += 1;
          });
        }

        if (bedRota[Strings.sundayAmFrom5] != null ||
            bedRota[Strings.sundayAmTo5] != null ||
            (bedRota[Strings.sundayAmName5] != null && bedRota[Strings.sundayAmName5] != '')) {
          setState(() {
            roleCountSundayAm += 1;
          });
        }

        //Sunday Pm
        if (bedRota[Strings.sundayPmFrom2] != null ||
            bedRota[Strings.sundayPmTo2] != null ||
            (bedRota[Strings.sundayPmName2] != null && bedRota[Strings.sundayPmName2] != '')) {
          setState(() {
            roleCountSundayPm += 1;
          });
        }

        if (bedRota[Strings.sundayPmFrom3] != null ||
            bedRota[Strings.sundayPmTo3] != null ||
            (bedRota[Strings.sundayPmName3] != null && bedRota[Strings.sundayPmName3] != '')) {
          setState(() {
            roleCountSundayPm += 1;
          });
        }

        if (bedRota[Strings.sundayPmFrom4] != null ||
            bedRota[Strings.sundayPmTo4] != null ||
            (bedRota[Strings.sundayPmName4] != null && bedRota[Strings.sundayPmName4] != '')) {
          setState(() {
            roleCountSundayPm += 1;
          });
        }

        if (bedRota[Strings.sundayPmFrom5] != null ||
            bedRota[Strings.sundayPmTo5] != null ||
            (bedRota[Strings.sundayPmName5] != null && bedRota[Strings.sundayPmName5] != '')) {
          setState(() {
            roleCountSundayPm += 1;
          });
        }

        //Sunday Night
        if (bedRota[Strings.sundayNightFrom2] != null ||
            bedRota[Strings.sundayNightTo2] != null ||
            (bedRota[Strings.sundayNightName2] != null && bedRota[Strings.sundayNightName2] != '')) {
          setState(() {
            roleCountSundayNight += 1;
          });
        }

        if (bedRota[Strings.sundayNightFrom3] != null ||
            bedRota[Strings.sundayNightTo3] != null ||
            (bedRota[Strings.sundayNightName3] != null && bedRota[Strings.sundayNightName3] != '')) {
          setState(() {
            roleCountSundayNight += 1;
          });
        }

        if (bedRota[Strings.sundayNightFrom4] != null ||
            bedRota[Strings.sundayNightTo4] != null ||
            (bedRota[Strings.sundayNightName4] != null && bedRota[Strings.sundayNightName4] != '')) {
          setState(() {
            roleCountSundayNight += 1;
          });
        }

        if (bedRota[Strings.sundayNightFrom5] != null ||
            bedRota[Strings.sundayNightTo5] != null ||
            (bedRota[Strings.sundayNightName5] != null && bedRota[Strings.sundayNightName5] != '')) {
          setState(() {
            roleCountSundayNight += 1;
          });
        }

        setState(() {
          rowCountMondayAm = roleCountMondayAm;
        });

        GlobalFunctions.getTemporaryValue(bedRota, mondayAmName1, Strings.mondayAmName1);
        GlobalFunctions.getTemporaryValueTime(bedRota, mondayAmFrom1, Strings.mondayAmFrom1);
        GlobalFunctions.getTemporaryValueTime(bedRota, mondayAmTo1, Strings.mondayAmTo1);
        GlobalFunctions.getTemporaryValue(bedRota, mondayPmName1, Strings.mondayPmName1);
        GlobalFunctions.getTemporaryValueTime(bedRota, mondayPmFrom1, Strings.mondayPmFrom1);
        GlobalFunctions.getTemporaryValueTime(bedRota, mondayPmTo1, Strings.mondayPmTo1);
        GlobalFunctions.getTemporaryValue(bedRota, mondayNightName1, Strings.mondayNightName1);
        GlobalFunctions.getTemporaryValueTime(bedRota, mondayNightFrom1, Strings.mondayNightFrom1);
        GlobalFunctions.getTemporaryValueTime(bedRota, mondayNightTo1, Strings.mondayNightTo1);
        GlobalFunctions.getTemporaryValue(bedRota, mondayAmName2, Strings.mondayAmName2);
        GlobalFunctions.getTemporaryValueTime(bedRota, mondayAmFrom2, Strings.mondayAmFrom2);
        GlobalFunctions.getTemporaryValueTime(bedRota, mondayAmTo2, Strings.mondayAmTo2);
        GlobalFunctions.getTemporaryValue(bedRota, mondayPmName2, Strings.mondayPmName2);
        GlobalFunctions.getTemporaryValueTime(bedRota, mondayPmFrom2, Strings.mondayPmFrom2);
        GlobalFunctions.getTemporaryValueTime(bedRota, mondayPmTo2, Strings.mondayPmTo2);
        GlobalFunctions.getTemporaryValue(bedRota, mondayNightName2, Strings.mondayNightName2);
        GlobalFunctions.getTemporaryValueTime(bedRota, mondayNightFrom2, Strings.mondayNightFrom2);
        GlobalFunctions.getTemporaryValueTime(bedRota, mondayNightTo2, Strings.mondayNightTo2);
        GlobalFunctions.getTemporaryValue(bedRota, mondayAmName3, Strings.mondayAmName3);
        GlobalFunctions.getTemporaryValueTime(bedRota, mondayAmFrom3, Strings.mondayAmFrom3);
        GlobalFunctions.getTemporaryValueTime(bedRota, mondayAmTo3, Strings.mondayAmTo3);
        GlobalFunctions.getTemporaryValue(bedRota, mondayPmName3, Strings.mondayPmName3);
        GlobalFunctions.getTemporaryValueTime(bedRota, mondayPmFrom3, Strings.mondayPmFrom3);
        GlobalFunctions.getTemporaryValueTime(bedRota, mondayPmTo3, Strings.mondayPmTo3);
        GlobalFunctions.getTemporaryValue(bedRota, mondayNightName3, Strings.mondayNightName3);
        GlobalFunctions.getTemporaryValueTime(bedRota, mondayNightFrom3, Strings.mondayNightFrom3);
        GlobalFunctions.getTemporaryValueTime(bedRota, mondayNightTo3, Strings.mondayNightTo3);
        GlobalFunctions.getTemporaryValue(bedRota, mondayAmName4, Strings.mondayAmName4);
        GlobalFunctions.getTemporaryValueTime(bedRota, mondayAmFrom4, Strings.mondayAmFrom4);
        GlobalFunctions.getTemporaryValueTime(bedRota, mondayAmTo4, Strings.mondayAmTo4);
        GlobalFunctions.getTemporaryValue(bedRota, mondayPmName4, Strings.mondayPmName4);
        GlobalFunctions.getTemporaryValueTime(bedRota, mondayPmFrom4, Strings.mondayPmFrom4);
        GlobalFunctions.getTemporaryValueTime(bedRota, mondayPmTo4, Strings.mondayPmTo4);
        GlobalFunctions.getTemporaryValue(bedRota, mondayNightName4, Strings.mondayNightName4);
        GlobalFunctions.getTemporaryValueTime(bedRota, mondayNightFrom4, Strings.mondayNightFrom4);
        GlobalFunctions.getTemporaryValueTime(bedRota, mondayNightTo4, Strings.mondayNightTo4);
        GlobalFunctions.getTemporaryValue(bedRota, mondayAmName5, Strings.mondayAmName5);
        GlobalFunctions.getTemporaryValueTime(bedRota, mondayAmFrom5, Strings.mondayAmFrom5);
        GlobalFunctions.getTemporaryValueTime(bedRota, mondayAmTo5, Strings.mondayAmTo5);
        GlobalFunctions.getTemporaryValue(bedRota, mondayPmName5, Strings.mondayPmName5);
        GlobalFunctions.getTemporaryValueTime(bedRota, mondayPmFrom5, Strings.mondayPmFrom5);
        GlobalFunctions.getTemporaryValueTime(bedRota, mondayPmTo5, Strings.mondayPmTo5);
        GlobalFunctions.getTemporaryValue(bedRota, mondayNightName5, Strings.mondayNightName5);
        GlobalFunctions.getTemporaryValueTime(bedRota, mondayNightFrom5, Strings.mondayNightFrom5);
        GlobalFunctions.getTemporaryValueTime(bedRota, mondayNightTo5, Strings.mondayNightTo5);
        GlobalFunctions.getTemporaryValue(bedRota, tuesdayAmName1, Strings.tuesdayAmName1);
        GlobalFunctions.getTemporaryValueTime(bedRota, tuesdayAmFrom1, Strings.tuesdayAmFrom1);
        GlobalFunctions.getTemporaryValueTime(bedRota, tuesdayAmTo1, Strings.tuesdayAmTo1);
        GlobalFunctions.getTemporaryValue(bedRota, tuesdayPmName1, Strings.tuesdayPmName1);
        GlobalFunctions.getTemporaryValueTime(bedRota, tuesdayPmFrom1, Strings.tuesdayPmFrom1);
        GlobalFunctions.getTemporaryValueTime(bedRota, tuesdayPmTo1, Strings.tuesdayPmTo1);
        GlobalFunctions.getTemporaryValue(bedRota, tuesdayNightName1, Strings.tuesdayNightName1);
        GlobalFunctions.getTemporaryValueTime(bedRota, tuesdayNightFrom1, Strings.tuesdayNightFrom1 );
        GlobalFunctions.getTemporaryValueTime(bedRota, tuesdayNightTo1, Strings.tuesdayNightTo1 );
        GlobalFunctions.getTemporaryValue(bedRota, tuesdayAmName2, Strings.tuesdayAmName2);
        GlobalFunctions.getTemporaryValueTime(bedRota, tuesdayAmFrom2, Strings.tuesdayAmFrom2);
        GlobalFunctions.getTemporaryValueTime(bedRota, tuesdayAmTo2, Strings.tuesdayAmTo2);
        GlobalFunctions.getTemporaryValue(bedRota, tuesdayPmName2, Strings.tuesdayPmName2);
        GlobalFunctions.getTemporaryValueTime(bedRota, tuesdayPmFrom2, Strings.tuesdayPmFrom2);
        GlobalFunctions.getTemporaryValueTime(bedRota, tuesdayPmTo2, Strings.tuesdayPmTo2);
        GlobalFunctions.getTemporaryValue(bedRota, tuesdayNightName2, Strings.tuesdayNightName2);
        GlobalFunctions.getTemporaryValueTime(bedRota, tuesdayNightFrom2, Strings.tuesdayNightFrom2 );
        GlobalFunctions.getTemporaryValueTime(bedRota, tuesdayNightTo2, Strings.tuesdayNightTo2 );
        GlobalFunctions.getTemporaryValue(bedRota, tuesdayAmName3, Strings.tuesdayAmName3);
        GlobalFunctions.getTemporaryValueTime(bedRota, tuesdayAmFrom3, Strings.tuesdayAmFrom3);
        GlobalFunctions.getTemporaryValueTime(bedRota, tuesdayAmTo3, Strings.tuesdayAmTo3);
        GlobalFunctions.getTemporaryValue(bedRota, tuesdayPmName3, Strings.tuesdayPmName3);
        GlobalFunctions.getTemporaryValueTime(bedRota, tuesdayPmFrom3, Strings.tuesdayPmFrom3);
        GlobalFunctions.getTemporaryValueTime(bedRota, tuesdayPmTo3, Strings.tuesdayPmTo3);
        GlobalFunctions.getTemporaryValue(bedRota, tuesdayNightName3, Strings.tuesdayNightName3);
        GlobalFunctions.getTemporaryValueTime(bedRota, tuesdayNightFrom3, Strings.tuesdayNightFrom3 );
        GlobalFunctions.getTemporaryValueTime(bedRota, tuesdayNightTo3, Strings.tuesdayNightTo3 );
        GlobalFunctions.getTemporaryValue(bedRota, tuesdayAmName4, Strings.tuesdayAmName4);
        GlobalFunctions.getTemporaryValueTime(bedRota, tuesdayAmFrom4, Strings.tuesdayAmFrom4);
        GlobalFunctions.getTemporaryValueTime(bedRota, tuesdayAmTo4, Strings.tuesdayAmTo4);
        GlobalFunctions.getTemporaryValue(bedRota, tuesdayPmName4, Strings.tuesdayPmName4);
        GlobalFunctions.getTemporaryValueTime(bedRota, tuesdayPmFrom4, Strings.tuesdayPmFrom4);
        GlobalFunctions.getTemporaryValueTime(bedRota, tuesdayPmTo4, Strings.tuesdayPmTo4);
        GlobalFunctions.getTemporaryValue(bedRota, tuesdayNightName4, Strings.tuesdayNightName4);
        GlobalFunctions.getTemporaryValueTime(bedRota, tuesdayNightFrom4, Strings.tuesdayNightFrom4 );
        GlobalFunctions.getTemporaryValueTime(bedRota, tuesdayNightTo4, Strings.tuesdayNightTo4 );
        GlobalFunctions.getTemporaryValue(bedRota, tuesdayAmName5, Strings.tuesdayAmName5);
        GlobalFunctions.getTemporaryValueTime(bedRota, tuesdayAmFrom5, Strings.tuesdayAmFrom5);
        GlobalFunctions.getTemporaryValueTime(bedRota, tuesdayAmTo5, Strings.tuesdayAmTo5);
        GlobalFunctions.getTemporaryValue(bedRota, tuesdayPmName5, Strings.tuesdayPmName5);
        GlobalFunctions.getTemporaryValueTime(bedRota, tuesdayPmFrom5, Strings.tuesdayPmFrom5);
        GlobalFunctions.getTemporaryValueTime(bedRota, tuesdayPmTo5, Strings.tuesdayPmTo5);
        GlobalFunctions.getTemporaryValue(bedRota, tuesdayNightName5, Strings.tuesdayNightName5);
        GlobalFunctions.getTemporaryValueTime(bedRota, tuesdayNightFrom5, Strings.tuesdayNightFrom5 );
        GlobalFunctions.getTemporaryValueTime(bedRota, tuesdayNightTo5, Strings.tuesdayNightTo5 );
        GlobalFunctions.getTemporaryValue(bedRota, wednesdayAmName1, Strings.wednesdayAmName1);
        GlobalFunctions.getTemporaryValueTime(bedRota, wednesdayAmFrom1, Strings.wednesdayAmFrom1);
        GlobalFunctions.getTemporaryValueTime(bedRota, wednesdayAmTo1, Strings.wednesdayAmTo1);
        GlobalFunctions.getTemporaryValue(bedRota, wednesdayPmName1, Strings.wednesdayPmName1);
        GlobalFunctions.getTemporaryValueTime(bedRota, wednesdayPmFrom1, Strings.wednesdayPmFrom1);
        GlobalFunctions.getTemporaryValueTime(bedRota, wednesdayPmTo1, Strings.wednesdayPmTo1);
        GlobalFunctions.getTemporaryValue(bedRota, wednesdayNightName1, Strings.wednesdayNightName1);
        GlobalFunctions.getTemporaryValueTime(bedRota, wednesdayNightFrom1, Strings.wednesdayNightFrom1);
        GlobalFunctions.getTemporaryValueTime(bedRota, wednesdayNightTo1, Strings.wednesdayNightTo1);
        GlobalFunctions.getTemporaryValue(bedRota, wednesdayAmName2, Strings.wednesdayAmName2 );
        GlobalFunctions.getTemporaryValueTime(bedRota, wednesdayAmFrom2, Strings.wednesdayAmFrom2);
        GlobalFunctions.getTemporaryValueTime(bedRota, wednesdayAmTo2, Strings.wednesdayAmTo2);
        GlobalFunctions.getTemporaryValue(bedRota, wednesdayPmName2, Strings.wednesdayPmName2);
        GlobalFunctions.getTemporaryValueTime(bedRota, wednesdayPmFrom2, Strings.wednesdayPmFrom2);
        GlobalFunctions.getTemporaryValueTime(bedRota, wednesdayPmTo2, Strings.wednesdayPmTo2);
        GlobalFunctions.getTemporaryValue(bedRota, wednesdayNightName2, Strings.wednesdayNightName2);
        GlobalFunctions.getTemporaryValueTime(bedRota, wednesdayNightFrom2, Strings.wednesdayNightFrom2);
        GlobalFunctions.getTemporaryValueTime(bedRota, wednesdayNightTo2, Strings.wednesdayNightTo2);
        GlobalFunctions.getTemporaryValue(bedRota, wednesdayAmName3, Strings.wednesdayAmName3 );
        GlobalFunctions.getTemporaryValueTime(bedRota, wednesdayAmFrom3, Strings.wednesdayAmFrom3);
        GlobalFunctions.getTemporaryValueTime(bedRota, wednesdayAmTo3, Strings.wednesdayAmTo3);
        GlobalFunctions.getTemporaryValue(bedRota, wednesdayPmName3, Strings.wednesdayPmName3);
        GlobalFunctions.getTemporaryValueTime(bedRota, wednesdayPmFrom3, Strings.wednesdayPmFrom3);
        GlobalFunctions.getTemporaryValueTime(bedRota, wednesdayPmTo3, Strings.wednesdayPmTo3);
        GlobalFunctions.getTemporaryValue(bedRota, wednesdayNightName3, Strings.wednesdayNightName3);
        GlobalFunctions.getTemporaryValueTime(bedRota, wednesdayNightFrom3, Strings.wednesdayNightFrom3);
        GlobalFunctions.getTemporaryValueTime(bedRota, wednesdayNightTo3, Strings.wednesdayNightTo3);
        GlobalFunctions.getTemporaryValue(bedRota, wednesdayAmName4, Strings.wednesdayAmName4 );
        GlobalFunctions.getTemporaryValueTime(bedRota, wednesdayAmFrom4, Strings.wednesdayAmFrom4);
        GlobalFunctions.getTemporaryValueTime(bedRota, wednesdayAmTo4, Strings.wednesdayAmTo4);
        GlobalFunctions.getTemporaryValue(bedRota, wednesdayPmName4, Strings.wednesdayPmName4);
        GlobalFunctions.getTemporaryValueTime(bedRota, wednesdayPmFrom4, Strings.wednesdayPmFrom4);
        GlobalFunctions.getTemporaryValueTime(bedRota, wednesdayPmTo4, Strings.wednesdayPmTo4);
        GlobalFunctions.getTemporaryValue(bedRota, wednesdayNightName4, Strings.wednesdayNightName4);
        GlobalFunctions.getTemporaryValueTime(bedRota, wednesdayNightFrom4, Strings.wednesdayNightFrom4);
        GlobalFunctions.getTemporaryValueTime(bedRota, wednesdayNightTo4, Strings.wednesdayNightTo4);
        GlobalFunctions.getTemporaryValue(bedRota, wednesdayAmName5, Strings.wednesdayAmName5 );
        GlobalFunctions.getTemporaryValueTime(bedRota, wednesdayAmFrom5, Strings.wednesdayAmFrom5);
        GlobalFunctions.getTemporaryValueTime(bedRota, wednesdayAmTo5, Strings.wednesdayAmTo5);
        GlobalFunctions.getTemporaryValue(bedRota, wednesdayPmName5, Strings.wednesdayPmName5);
        GlobalFunctions.getTemporaryValueTime(bedRota, wednesdayPmFrom5, Strings.wednesdayPmFrom5);
        GlobalFunctions.getTemporaryValueTime(bedRota, wednesdayPmTo5, Strings.wednesdayPmTo5);
        GlobalFunctions.getTemporaryValue(bedRota, wednesdayNightName5, Strings.wednesdayNightName5);
        GlobalFunctions.getTemporaryValueTime(bedRota, wednesdayNightFrom5, Strings.wednesdayNightFrom5);
        GlobalFunctions.getTemporaryValueTime(bedRota, wednesdayNightTo5, Strings.wednesdayNightTo5);
        GlobalFunctions.getTemporaryValue(bedRota, thursdayAmName1, Strings.thursdayAmName1 );
        GlobalFunctions.getTemporaryValueTime(bedRota, thursdayAmFrom1, Strings.thursdayAmFrom1);
        GlobalFunctions.getTemporaryValueTime(bedRota, thursdayAmTo1, Strings.thursdayAmTo1);
        GlobalFunctions.getTemporaryValue(bedRota, thursdayPmName1, Strings.thursdayPmName1);
        GlobalFunctions.getTemporaryValueTime(bedRota, thursdayPmFrom1, Strings.thursdayPmFrom1);
        GlobalFunctions.getTemporaryValueTime(bedRota, thursdayPmTo1, Strings.thursdayPmTo1);
        GlobalFunctions.getTemporaryValue(bedRota, thursdayNightName1, Strings.thursdayNightName1);
        GlobalFunctions.getTemporaryValueTime(bedRota, thursdayNightFrom1, Strings.thursdayNightFrom1);
        GlobalFunctions.getTemporaryValueTime(bedRota, thursdayNightTo1, Strings.thursdayNightTo1);
        GlobalFunctions.getTemporaryValue(bedRota, thursdayAmName2, Strings.thursdayAmName2);
        GlobalFunctions.getTemporaryValueTime(bedRota, thursdayAmFrom2, Strings.thursdayAmFrom2);
        GlobalFunctions.getTemporaryValueTime(bedRota, thursdayAmTo2, Strings.thursdayAmTo2);
        GlobalFunctions.getTemporaryValue(bedRota, thursdayPmName2, Strings.thursdayPmName2);
        GlobalFunctions.getTemporaryValueTime(bedRota, thursdayPmFrom2, Strings.thursdayPmFrom2);
        GlobalFunctions.getTemporaryValueTime(bedRota, thursdayPmTo2, Strings.thursdayPmTo2);
        GlobalFunctions.getTemporaryValue(bedRota, thursdayNightName2, Strings.thursdayNightName2);
        GlobalFunctions.getTemporaryValueTime(bedRota, thursdayNightFrom2, Strings.thursdayNightFrom2);
        GlobalFunctions.getTemporaryValueTime(bedRota, thursdayNightTo2, Strings.thursdayNightTo2);
        GlobalFunctions.getTemporaryValue(bedRota, thursdayAmName3, Strings.thursdayAmName3);
        GlobalFunctions.getTemporaryValueTime(bedRota, thursdayAmFrom3, Strings.thursdayAmFrom3);
        GlobalFunctions.getTemporaryValueTime(bedRota, thursdayAmTo3, Strings.thursdayAmTo3);
        GlobalFunctions.getTemporaryValue(bedRota, thursdayPmName3, Strings.thursdayPmName3);
        GlobalFunctions.getTemporaryValueTime(bedRota, thursdayPmFrom3, Strings.thursdayPmFrom3);
        GlobalFunctions.getTemporaryValueTime(bedRota, thursdayPmTo3, Strings.thursdayPmTo3);
        GlobalFunctions.getTemporaryValue(bedRota, thursdayNightName3, Strings.thursdayNightName3);
        GlobalFunctions.getTemporaryValueTime(bedRota, thursdayNightFrom3, Strings.thursdayNightFrom3);
        GlobalFunctions.getTemporaryValueTime(bedRota, thursdayNightTo3, Strings.thursdayNightTo3);
        GlobalFunctions.getTemporaryValue(bedRota, thursdayAmName4, Strings.thursdayAmName4);
        GlobalFunctions.getTemporaryValueTime(bedRota, thursdayAmFrom4, Strings.thursdayAmFrom4);
        GlobalFunctions.getTemporaryValueTime(bedRota, thursdayAmTo4, Strings.thursdayAmTo4);
        GlobalFunctions.getTemporaryValue(bedRota, thursdayPmName4, Strings.thursdayPmName4);
        GlobalFunctions.getTemporaryValueTime(bedRota, thursdayPmFrom4, Strings.thursdayPmFrom4);
        GlobalFunctions.getTemporaryValueTime(bedRota, thursdayPmTo4, Strings.thursdayPmTo4);
        GlobalFunctions.getTemporaryValue(bedRota, thursdayNightName4, Strings.thursdayNightName4);
        GlobalFunctions.getTemporaryValueTime(bedRota, thursdayNightFrom4, Strings.thursdayNightFrom4);
        GlobalFunctions.getTemporaryValueTime(bedRota, thursdayNightTo4, Strings.thursdayNightTo4);
        GlobalFunctions.getTemporaryValue(bedRota, thursdayAmName5, Strings.thursdayAmName5);
        GlobalFunctions.getTemporaryValueTime(bedRota, thursdayAmFrom5, Strings.thursdayAmFrom5);
        GlobalFunctions.getTemporaryValueTime(bedRota, thursdayAmTo5, Strings.thursdayAmTo5);
        GlobalFunctions.getTemporaryValue(bedRota, thursdayPmName5, Strings.thursdayPmName5);
        GlobalFunctions.getTemporaryValueTime(bedRota, thursdayPmFrom5, Strings.thursdayPmFrom5);
        GlobalFunctions.getTemporaryValueTime(bedRota, thursdayPmTo5, Strings.thursdayPmTo5);
        GlobalFunctions.getTemporaryValue(bedRota, thursdayNightName5, Strings.thursdayNightName5);
        GlobalFunctions.getTemporaryValueTime(bedRota, thursdayNightFrom5, Strings.thursdayNightFrom5);
        GlobalFunctions.getTemporaryValueTime(bedRota, thursdayNightTo5, Strings.thursdayNightTo5);
        GlobalFunctions.getTemporaryValue(bedRota, fridayAmName1, Strings.fridayAmName1);
        GlobalFunctions.getTemporaryValueTime(bedRota, fridayAmFrom1, Strings.fridayAmFrom1);
        GlobalFunctions.getTemporaryValueTime(bedRota, fridayAmTo1, Strings.fridayAmTo1);
        GlobalFunctions.getTemporaryValue(bedRota, fridayPmName1, Strings.fridayPmName1);
        GlobalFunctions.getTemporaryValueTime(bedRota, fridayPmFrom1, Strings.fridayPmFrom1);
        GlobalFunctions.getTemporaryValueTime(bedRota, fridayPmTo1, Strings.fridayPmTo1);
        GlobalFunctions.getTemporaryValue(bedRota, fridayNightName1, Strings.fridayNightName1);
        GlobalFunctions.getTemporaryValueTime(bedRota, fridayNightFrom1, Strings.fridayNightFrom1);
        GlobalFunctions.getTemporaryValueTime(bedRota, fridayNightTo1, Strings.fridayNightTo1);
        GlobalFunctions.getTemporaryValue(bedRota, fridayAmName2, Strings.fridayAmName2);
        GlobalFunctions.getTemporaryValueTime(bedRota, fridayAmFrom2, Strings.fridayAmFrom2);
        GlobalFunctions.getTemporaryValueTime(bedRota, fridayAmTo2, Strings.fridayAmTo2);
        GlobalFunctions.getTemporaryValue(bedRota, fridayPmName2, Strings.fridayPmName2);
        GlobalFunctions.getTemporaryValueTime(bedRota, fridayPmFrom2, Strings.fridayPmFrom2);
        GlobalFunctions.getTemporaryValueTime(bedRota, fridayPmTo2, Strings.fridayPmTo2);
        GlobalFunctions.getTemporaryValue(bedRota, fridayNightName2, Strings.fridayNightName2);
        GlobalFunctions.getTemporaryValueTime(bedRota, fridayNightFrom2, Strings.fridayNightFrom2);
        GlobalFunctions.getTemporaryValueTime(bedRota, fridayNightTo2, Strings.fridayNightTo2);
        GlobalFunctions.getTemporaryValue(bedRota, fridayAmName3, Strings.fridayAmName3);
        GlobalFunctions.getTemporaryValueTime(bedRota, fridayAmFrom3, Strings.fridayAmFrom3);
        GlobalFunctions.getTemporaryValueTime(bedRota, fridayAmTo3, Strings.fridayAmTo3);
        GlobalFunctions.getTemporaryValue(bedRota, fridayPmName3, Strings.fridayPmName3);
        GlobalFunctions.getTemporaryValueTime(bedRota, fridayPmFrom3, Strings.fridayPmFrom3);
        GlobalFunctions.getTemporaryValueTime(bedRota, fridayPmTo3, Strings.fridayPmTo3);
        GlobalFunctions.getTemporaryValue(bedRota, fridayNightName3, Strings.fridayNightName3);
        GlobalFunctions.getTemporaryValueTime(bedRota, fridayNightFrom3, Strings.fridayNightFrom3);
        GlobalFunctions.getTemporaryValueTime(bedRota, fridayNightTo3, Strings.fridayNightTo3);
        GlobalFunctions.getTemporaryValue(bedRota, fridayAmName4, Strings.fridayAmName4);
        GlobalFunctions.getTemporaryValueTime(bedRota, fridayAmFrom4, Strings.fridayAmFrom4);
        GlobalFunctions.getTemporaryValueTime(bedRota, fridayAmTo4, Strings.fridayAmTo4);
        GlobalFunctions.getTemporaryValue(bedRota, fridayPmName4, Strings.fridayPmName4);
        GlobalFunctions.getTemporaryValueTime(bedRota, fridayPmFrom4, Strings.fridayPmFrom4);
        GlobalFunctions.getTemporaryValueTime(bedRota, fridayPmTo4, Strings.fridayPmTo4);
        GlobalFunctions.getTemporaryValue(bedRota, fridayNightName4, Strings.fridayNightName4);
        GlobalFunctions.getTemporaryValueTime(bedRota, fridayNightFrom4, Strings.fridayNightFrom4);
        GlobalFunctions.getTemporaryValueTime(bedRota, fridayNightTo4, Strings.fridayNightTo4);
        GlobalFunctions.getTemporaryValue(bedRota, fridayAmName5, Strings.fridayAmName5);
        GlobalFunctions.getTemporaryValueTime(bedRota, fridayAmFrom5, Strings.fridayAmFrom5);
        GlobalFunctions.getTemporaryValueTime(bedRota, fridayAmTo5, Strings.fridayAmTo5);
        GlobalFunctions.getTemporaryValue(bedRota, fridayPmName5, Strings.fridayPmName5);
        GlobalFunctions.getTemporaryValueTime(bedRota, fridayPmFrom5, Strings.fridayPmFrom5);
        GlobalFunctions.getTemporaryValueTime(bedRota, fridayPmTo5, Strings.fridayPmTo5);
        GlobalFunctions.getTemporaryValue(bedRota, fridayNightName5, Strings.fridayNightName5);
        GlobalFunctions.getTemporaryValueTime(bedRota, fridayNightFrom5, Strings.fridayNightFrom5);
        GlobalFunctions.getTemporaryValueTime(bedRota, fridayNightTo5, Strings.fridayNightTo5);
        GlobalFunctions.getTemporaryValue(bedRota, saturdayAmName1, Strings.saturdayAmName1);
        GlobalFunctions.getTemporaryValueTime(bedRota, saturdayAmFrom1, Strings.saturdayAmFrom1);
        GlobalFunctions.getTemporaryValueTime(bedRota, saturdayAmTo1, Strings.saturdayAmTo1);
        GlobalFunctions.getTemporaryValue(bedRota, saturdayPmName1, Strings.saturdayPmName1);
        GlobalFunctions.getTemporaryValueTime(bedRota, saturdayPmFrom1, Strings.saturdayPmFrom1);
        GlobalFunctions.getTemporaryValueTime(bedRota, saturdayPmTo1, Strings.saturdayPmTo1);
        GlobalFunctions.getTemporaryValue(bedRota, saturdayNightName1, Strings.saturdayNightName1);
        GlobalFunctions.getTemporaryValueTime(bedRota, saturdayNightFrom1, Strings.saturdayNightFrom1);
        GlobalFunctions.getTemporaryValueTime(bedRota, saturdayNightTo1, Strings.saturdayNightTo1);
        GlobalFunctions.getTemporaryValue(bedRota, saturdayAmName2, Strings.saturdayAmName2);
        GlobalFunctions.getTemporaryValueTime(bedRota, saturdayAmFrom2, Strings.saturdayAmFrom2);
        GlobalFunctions.getTemporaryValueTime(bedRota, saturdayAmTo2, Strings.saturdayAmTo2);
        GlobalFunctions.getTemporaryValue(bedRota, saturdayPmName2, Strings.saturdayPmName2);
        GlobalFunctions.getTemporaryValueTime(bedRota, saturdayPmFrom2, Strings.saturdayPmFrom2);
        GlobalFunctions.getTemporaryValueTime(bedRota, saturdayPmTo2, Strings.saturdayPmTo2);
        GlobalFunctions.getTemporaryValue(bedRota, saturdayNightName2, Strings.saturdayNightName2);
        GlobalFunctions.getTemporaryValueTime(bedRota, saturdayNightFrom2, Strings.saturdayNightFrom2);
        GlobalFunctions.getTemporaryValueTime(bedRota, saturdayNightTo2, Strings.saturdayNightTo2);
        GlobalFunctions.getTemporaryValue(bedRota, saturdayAmName3, Strings.saturdayAmName3);
        GlobalFunctions.getTemporaryValueTime(bedRota, saturdayAmFrom3, Strings.saturdayAmFrom3);
        GlobalFunctions.getTemporaryValueTime(bedRota, saturdayAmTo3, Strings.saturdayAmTo3);
        GlobalFunctions.getTemporaryValue(bedRota, saturdayPmName3, Strings.saturdayPmName3);
        GlobalFunctions.getTemporaryValueTime(bedRota, saturdayPmFrom3, Strings.saturdayPmFrom3);
        GlobalFunctions.getTemporaryValueTime(bedRota, saturdayPmTo3, Strings.saturdayPmTo3);
        GlobalFunctions.getTemporaryValue(bedRota, saturdayNightName3, Strings.saturdayNightName3);
        GlobalFunctions.getTemporaryValueTime(bedRota, saturdayNightFrom3, Strings.saturdayNightFrom3);
        GlobalFunctions.getTemporaryValueTime(bedRota, saturdayNightTo3, Strings.saturdayNightTo3);
        GlobalFunctions.getTemporaryValue(bedRota, saturdayAmName4, Strings.saturdayAmName4);
        GlobalFunctions.getTemporaryValueTime(bedRota, saturdayAmFrom4, Strings.saturdayAmFrom4);
        GlobalFunctions.getTemporaryValueTime(bedRota, saturdayAmTo4, Strings.saturdayAmTo4);
        GlobalFunctions.getTemporaryValue(bedRota, saturdayPmName4, Strings.saturdayPmName4);
        GlobalFunctions.getTemporaryValueTime(bedRota, saturdayPmFrom4, Strings.saturdayPmFrom4);
        GlobalFunctions.getTemporaryValueTime(bedRota, saturdayPmTo4, Strings.saturdayPmTo4);
        GlobalFunctions.getTemporaryValue(bedRota, saturdayNightName4, Strings.saturdayNightName4);
        GlobalFunctions.getTemporaryValueTime(bedRota, saturdayNightFrom4, Strings.saturdayNightFrom4);
        GlobalFunctions.getTemporaryValueTime(bedRota, saturdayNightTo4, Strings.saturdayNightTo4);
        GlobalFunctions.getTemporaryValue(bedRota, saturdayAmName5, Strings.saturdayAmName5);
        GlobalFunctions.getTemporaryValueTime(bedRota, saturdayAmFrom5, Strings.saturdayAmFrom5);
        GlobalFunctions.getTemporaryValueTime(bedRota, saturdayAmTo5, Strings.saturdayAmTo5);
        GlobalFunctions.getTemporaryValue(bedRota, saturdayPmName5, Strings.saturdayPmName5);
        GlobalFunctions.getTemporaryValueTime(bedRota, saturdayPmFrom5, Strings.saturdayPmFrom5);
        GlobalFunctions.getTemporaryValueTime(bedRota, saturdayPmTo5, Strings.saturdayPmTo5);
        GlobalFunctions.getTemporaryValue(bedRota, saturdayNightName5, Strings.saturdayNightName5);
        GlobalFunctions.getTemporaryValueTime(bedRota, saturdayNightFrom5, Strings.saturdayNightFrom5);
        GlobalFunctions.getTemporaryValueTime(bedRota, saturdayNightTo5, Strings.saturdayNightTo5);
        GlobalFunctions.getTemporaryValue(bedRota, sundayAmName1, Strings.sundayAmName1);
        GlobalFunctions.getTemporaryValueTime(bedRota, sundayAmFrom1, Strings.sundayAmFrom1);
        GlobalFunctions.getTemporaryValueTime(bedRota, sundayAmTo1, Strings.sundayAmTo1);
        GlobalFunctions.getTemporaryValue(bedRota, sundayPmName1, Strings.sundayPmName1);
        GlobalFunctions.getTemporaryValueTime(bedRota, sundayPmFrom1, Strings.sundayPmFrom1);
        GlobalFunctions.getTemporaryValueTime(bedRota, sundayPmTo1, Strings.sundayPmTo1);
        GlobalFunctions.getTemporaryValue(bedRota, sundayNightName1, Strings.sundayNightName1);
        GlobalFunctions.getTemporaryValueTime(bedRota, sundayNightFrom1, Strings.sundayNightFrom1);
        GlobalFunctions.getTemporaryValueTime(bedRota, sundayNightTo1, Strings.sundayNightTo1);
        GlobalFunctions.getTemporaryValue(bedRota, sundayAmName2, Strings.sundayAmName2);
        GlobalFunctions.getTemporaryValueTime(bedRota, sundayAmFrom2, Strings.sundayAmFrom2);
        GlobalFunctions.getTemporaryValueTime(bedRota, sundayAmTo2, Strings.sundayAmTo2);
        GlobalFunctions.getTemporaryValue(bedRota, sundayPmName2, Strings.sundayPmName2);
        GlobalFunctions.getTemporaryValueTime(bedRota, sundayPmFrom2, Strings.sundayPmFrom2);
        GlobalFunctions.getTemporaryValueTime(bedRota, sundayPmTo2, Strings.sundayPmTo2);
        GlobalFunctions.getTemporaryValue(bedRota, sundayNightName2, Strings.sundayNightName2);
        GlobalFunctions.getTemporaryValueTime(bedRota, sundayNightFrom2, Strings.sundayNightFrom2);
        GlobalFunctions.getTemporaryValueTime(bedRota, sundayNightTo2, Strings.sundayNightTo2);
        GlobalFunctions.getTemporaryValue(bedRota, sundayAmName3, Strings.sundayAmName3);
        GlobalFunctions.getTemporaryValueTime(bedRota, sundayAmFrom3, Strings.sundayAmFrom3);
        GlobalFunctions.getTemporaryValueTime(bedRota, sundayAmTo3, Strings.sundayAmTo3);
        GlobalFunctions.getTemporaryValue(bedRota, sundayPmName3, Strings.sundayPmName3);
        GlobalFunctions.getTemporaryValueTime(bedRota, sundayPmFrom3, Strings.sundayPmFrom3);
        GlobalFunctions.getTemporaryValueTime(bedRota, sundayPmTo3, Strings.sundayPmTo3);
        GlobalFunctions.getTemporaryValue(bedRota, sundayNightName3, Strings.sundayNightName3);
        GlobalFunctions.getTemporaryValueTime(bedRota, sundayNightFrom3, Strings.sundayNightFrom3);
        GlobalFunctions.getTemporaryValueTime(bedRota, sundayNightTo3, Strings.sundayNightTo3);
        GlobalFunctions.getTemporaryValue(bedRota, sundayAmName4, Strings.sundayAmName4);
        GlobalFunctions.getTemporaryValueTime(bedRota, sundayAmFrom4, Strings.sundayAmFrom4);
        GlobalFunctions.getTemporaryValueTime(bedRota, sundayAmTo4, Strings.sundayAmTo4);
        GlobalFunctions.getTemporaryValue(bedRota, sundayPmName4, Strings.sundayPmName4);
        GlobalFunctions.getTemporaryValueTime(bedRota, sundayPmFrom4, Strings.sundayPmFrom4);
        GlobalFunctions.getTemporaryValueTime(bedRota, sundayPmTo4, Strings.sundayPmTo4);
        GlobalFunctions.getTemporaryValue(bedRota, sundayNightName4, Strings.sundayNightName4);
        GlobalFunctions.getTemporaryValueTime(bedRota, sundayNightFrom4, Strings.sundayNightFrom4);
        GlobalFunctions.getTemporaryValueTime(bedRota, sundayNightTo4, Strings.sundayNightTo4);
        GlobalFunctions.getTemporaryValue(bedRota, sundayAmName5, Strings.sundayAmName5);
        GlobalFunctions.getTemporaryValueTime(bedRota, sundayAmFrom5, Strings.sundayAmFrom5);
        GlobalFunctions.getTemporaryValueTime(bedRota, sundayAmTo5, Strings.sundayAmTo5);
        GlobalFunctions.getTemporaryValue(bedRota, sundayPmName5, Strings.sundayPmName5);
        GlobalFunctions.getTemporaryValueTime(bedRota, sundayPmFrom5, Strings.sundayPmFrom5);
        GlobalFunctions.getTemporaryValueTime(bedRota, sundayPmTo5, Strings.sundayPmTo5);
        GlobalFunctions.getTemporaryValue(bedRota, sundayNightName5, Strings.sundayNightName5);
        GlobalFunctions.getTemporaryValueTime(bedRota, sundayNightFrom5, Strings.sundayNightFrom5);
        GlobalFunctions.getTemporaryValueTime(bedRota, sundayNightTo5, Strings.sundayNightTo5);




        if (mounted) {
          setState(() {
            _loadingTemporary = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _loadingTemporary = false;
          });
        }
      }
    }
  }

  _increaseRowCountMondayAm(){
    if(rowCountMondayAm == 5){
      GlobalFunctions.showToast('Maximum staff added');
    } else {
      setState(() {
        rowCountMondayAm +=1;
      });
    }
  }

  _decreaseRowCountMondayAm(){
    if(rowCountMondayAm == 1){
      GlobalFunctions.showToast('Unable to remove');
    } else {
      setState(() {
        rowCountMondayAm -=1;
      });
    }
  }

  _increaseRowCountMondayPm(){
    if(rowCountMondayPm == 5){
      GlobalFunctions.showToast('Maximum staff added');
    } else {
      setState(() {
        rowCountMondayPm +=1;
      });
    }
  }

  _decreaseRowCountMondayPm(){
    if(rowCountMondayPm == 1){
      GlobalFunctions.showToast('Unable to remove');
    } else {
      setState(() {
        rowCountMondayPm -=1;
      });
    }
  }

  _increaseRowCountMondayNight(){
    if(rowCountMondayNight == 5){
      GlobalFunctions.showToast('Maximum staff added');
    } else {
      setState(() {
        rowCountMondayNight +=1;
      });
    }
  }

  _decreaseRowCountMondayNight(){
    if(rowCountMondayNight == 1){
      GlobalFunctions.showToast('Unable to remove');
    } else {
      setState(() {
        rowCountMondayNight -=1;
      });
    }
  }

  _increaseRowCountTuesdayAm(){
    if(rowCountTuesdayAm == 5){
      GlobalFunctions.showToast('Maximum staff added');
    } else {
      setState(() {
        rowCountTuesdayAm +=1;
      });
    }
  }

  _decreaseRowCountTuesdayAm(){
    if(rowCountTuesdayAm == 1){
      GlobalFunctions.showToast('Unable to remove');
    } else {
      setState(() {
        rowCountTuesdayAm -=1;
      });
    }
  }

  _increaseRowCountTuesdayPm(){
    if(rowCountTuesdayPm == 5){
      GlobalFunctions.showToast('Maximum staff added');
    } else {
      setState(() {
        rowCountTuesdayPm +=1;
      });
    }
  }

  _decreaseRowCountTuesdayPm(){
    if(rowCountTuesdayPm == 1){
      GlobalFunctions.showToast('Unable to remove');
    } else {
      setState(() {
        rowCountTuesdayPm -=1;
      });
    }
  }

  _increaseRowCountTuesdayNight(){
    if(rowCountTuesdayNight == 5){
      GlobalFunctions.showToast('Maximum staff added');
    } else {
      setState(() {
        rowCountTuesdayNight +=1;
      });
    }
  }

  _decreaseRowCountTuesdayNight(){
    if(rowCountTuesdayNight == 1){
      GlobalFunctions.showToast('Unable to remove');
    } else {
      setState(() {
        rowCountTuesdayNight -=1;
      });
    }
  }

  _increaseRowCountWednesdayAm(){
    if(rowCountWednesdayAm == 5){
      GlobalFunctions.showToast('Maximum staff added');
    } else {
      setState(() {
        rowCountWednesdayAm +=1;
      });
    }
  }

  _decreaseRowCountWednesdayAm(){
    if(rowCountWednesdayAm == 1){
      GlobalFunctions.showToast('Unable to remove');
    } else {
      setState(() {
        rowCountWednesdayAm -=1;
      });
    }
  }

  _increaseRowCountWednesdayPm(){
    if(rowCountWednesdayPm == 5){
      GlobalFunctions.showToast('Maximum staff added');
    } else {
      setState(() {
        rowCountWednesdayPm +=1;
      });
    }
  }

  _decreaseRowCountWednesdayPm(){
    if(rowCountWednesdayPm == 1){
      GlobalFunctions.showToast('Unable to remove');
    } else {
      setState(() {
        rowCountWednesdayPm -=1;
      });
    }
  }

  _increaseRowCountWednesdayNight(){
    if(rowCountWednesdayNight == 5){
      GlobalFunctions.showToast('Maximum staff added');
    } else {
      setState(() {
        rowCountWednesdayNight +=1;
      });
    }
  }

  _decreaseRowCountWednesdayNight(){
    if(rowCountWednesdayNight == 1){
      GlobalFunctions.showToast('Unable to remove');
    } else {
      setState(() {
        rowCountWednesdayNight -=1;
      });
    }
  }

  _increaseRowCountThursdayAm(){
    if(rowCountThursdayAm == 5){
      GlobalFunctions.showToast('Maximum staff added');
    } else {
      setState(() {
        rowCountThursdayAm +=1;
      });
    }
  }

  _decreaseRowCountThursdayAm(){
    if(rowCountThursdayAm == 1){
      GlobalFunctions.showToast('Unable to remove');
    } else {
      setState(() {
        rowCountThursdayAm -=1;
      });
    }
  }

  _increaseRowCountThursdayPm(){
    if(rowCountThursdayPm == 5){
      GlobalFunctions.showToast('Maximum staff added');
    } else {
      setState(() {
        rowCountThursdayPm +=1;
      });
    }
  }

  _decreaseRowCountThursdayPm(){
    if(rowCountThursdayPm == 1){
      GlobalFunctions.showToast('Unable to remove');
    } else {
      setState(() {
        rowCountThursdayPm -=1;
      });
    }
  }

  _increaseRowCountThursdayNight(){
    if(rowCountThursdayNight == 5){
      GlobalFunctions.showToast('Maximum staff added');
    } else {
      setState(() {
        rowCountThursdayNight +=1;
      });
    }
  }

  _decreaseRowCountThursdayNight(){
    if(rowCountThursdayNight == 1){
      GlobalFunctions.showToast('Unable to remove');
    } else {
      setState(() {
        rowCountThursdayNight -=1;
      });
    }
  }

  _increaseRowCountFridayAm(){
    if(rowCountFridayAm == 5){
      GlobalFunctions.showToast('Maximum staff added');
    } else {
      setState(() {
        rowCountFridayAm +=1;
      });
    }
  }

  _decreaseRowCountFridayAm(){
    if(rowCountFridayAm == 1){
      GlobalFunctions.showToast('Unable to remove');
    } else {
      setState(() {
        rowCountFridayAm -=1;
      });
    }
  }

  _increaseRowCountFridayPm(){
    if(rowCountFridayPm == 5){
      GlobalFunctions.showToast('Maximum staff added');
    } else {
      setState(() {
        rowCountFridayPm +=1;
      });
    }
  }

  _decreaseRowCountFridayPm(){
    if(rowCountFridayPm == 1){
      GlobalFunctions.showToast('Unable to remove');
    } else {
      setState(() {
        rowCountFridayPm -=1;
      });
    }
  }

  _increaseRowCountFridayNight(){
    if(rowCountFridayNight == 5){
      GlobalFunctions.showToast('Maximum staff added');
    } else {
      setState(() {
        rowCountFridayNight +=1;
      });
    }
  }

  _decreaseRowCountFridayNight(){
    if(rowCountFridayNight == 1){
      GlobalFunctions.showToast('Unable to remove');
    } else {
      setState(() {
        rowCountFridayNight -=1;
      });
    }
  }

  _increaseRowCountSaturdayAm(){
    if(rowCountSaturdayAm == 5){
      GlobalFunctions.showToast('Maximum staff added');
    } else {
      setState(() {
        rowCountSaturdayAm +=1;
      });
    }
  }

  _decreaseRowCountSaturdayAm(){
    if(rowCountSaturdayAm == 1){
      GlobalFunctions.showToast('Unable to remove');
    } else {
      setState(() {
        rowCountSaturdayAm -=1;
      });
    }
  }

  _increaseRowCountSaturdayPm(){
    if(rowCountSaturdayPm == 5){
      GlobalFunctions.showToast('Maximum staff added');
    } else {
      setState(() {
        rowCountSaturdayPm +=1;
      });
    }
  }

  _decreaseRowCountSaturdayPm(){
    if(rowCountSaturdayPm == 1){
      GlobalFunctions.showToast('Unable to remove');
    } else {
      setState(() {
        rowCountSaturdayPm -=1;
      });
    }
  }

  _increaseRowCountSaturdayNight(){
    if(rowCountSaturdayNight == 5){
      GlobalFunctions.showToast('Maximum staff added');
    } else {
      setState(() {
        rowCountSaturdayNight +=1;
      });
    }
  }

  _decreaseRowCountSaturdayNight(){
    if(rowCountSaturdayNight == 1){
      GlobalFunctions.showToast('Unable to remove');
    } else {
      setState(() {
        rowCountSaturdayNight -=1;
      });
    }
  }

  _increaseRowCountSundayAm(){
    if(rowCountSundayAm == 5){
      GlobalFunctions.showToast('Maximum staff added');
    } else {
      setState(() {
        rowCountSundayAm +=1;
      });
    }
  }

  _decreaseRowCountSundayAm(){
    if(rowCountSundayAm == 1){
      GlobalFunctions.showToast('Unable to remove');
    } else {
      setState(() {
        rowCountSundayAm -=1;
      });
    }
  }

  _increaseRowCountSundayPm(){
    if(rowCountSundayPm == 5){
      GlobalFunctions.showToast('Maximum staff added');
    } else {
      setState(() {
        rowCountSundayPm +=1;
      });
    }
  }

  _decreaseRowCountSundayPm(){
    if(rowCountSundayPm == 1){
      GlobalFunctions.showToast('Unable to remove');
    } else {
      setState(() {
        rowCountSundayPm -=1;
      });
    }
  }

  _increaseRowCountSundayNight(){
    if(rowCountSundayNight == 5){
      GlobalFunctions.showToast('Maximum staff added');
    } else {
      setState(() {
        rowCountSundayNight +=1;
      });
    }
  }

  _decreaseRowCountSundayNight(){
    if(rowCountSundayNight == 1){
      GlobalFunctions.showToast('Unable to remove');
    } else {
      setState(() {
        rowCountSundayNight -=1;
      });
    }
  }

  Widget _textFormField(String label, TextEditingController controller, [int lines = 1, bool required = false, TextInputType textInputType = TextInputType.text]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
              text: label,
              style: TextStyle(
                  fontSize: 16.0, fontFamily: 'Open Sans', color: bluePurple),
              children:
              [
                TextSpan(
                  text: required ? ' *' : '',
                  style: TextStyle(
                      color: Colors.red,
                      fontSize: 16.0),
                ),                                           ]
          ),
        ),
        TextFormField(
          keyboardType: textInputType,
          inputFormatters: textInputType == TextInputType.number ? <TextInputFormatter>[
            FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
          ] : null,
          validator: (String value) {
            String message;
            if(required){
              if (value.trim().length <= 0 && value.isEmpty) {
                message = "Required";
              }
            }
            return message;
          },
          maxLines: lines,
          decoration: InputDecoration(
              filled: required && controller.text.isEmpty ? true : false, fillColor: Color(0xFF0000).withOpacity(0.3),
              suffixIcon: controller.text == ''
                  ? null
                  : IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      SchedulerBinding.instance.addPostFrameCallback((_) {
                        FocusScope.of(context).unfocus();
                        controller.clear();
                      });
                    });
                  })),
          controller: controller,
        ),
        SizedBox(height: 15,),
      ],
    );
  }

  Widget _buildDateField(String label, TextEditingController controller, String value, [bool required = false, bool encrypt = false]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        RichText(
          text: TextSpan(
              text: label,
              style: TextStyle(
                  fontSize: 16.0, fontFamily: 'Open Sans', color: bluePurple),
              children:
              [
                TextSpan(
                  text: required ? ' *' : '',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 16.0, fontFamily: 'Open Sans',),
                ),                                           ]
          ),
        ),
        Row(
          children: <Widget>[
            Flexible(
              child: IgnorePointer(
                child: TextFormField(
                  decoration: InputDecoration(              filled: required && controller.text.isEmpty ? true : false, fillColor: Color(0xFF0000).withOpacity(0.3),
                  ),
                  enabled: true,
                  initialValue: null,
                  controller: controller,
                  onSaved: (String value) {
                    setState(() {
                      controller.text = value;
                    });
                  },

                ),
              ),
            ),
            IconButton(
                color: Colors.grey,
                icon: Icon(Icons.clear),
                onPressed: () {
                  setState(() {
                    controller.clear();
                    bedRotaModel.updateTemporaryRecord(widget.edit, value, null, widget.jobId, widget.saved, widget.savedId);

                    // _databaseHelper.updateTemporaryBedRotaField(widget.edit,
                    //     {value : null}, user.uid, widget.jobId, widget.saved, widget.savedId);

                  });
                }),
            IconButton(
                icon: Icon(Icons.access_time,
                    color: bluePurple),
                onPressed: () async{
                  FocusScope.of(context).unfocus();
                  await Future.delayed(Duration(milliseconds: 100));
                  showDatePicker(
                      builder: (BuildContext context, Widget child) {
                        return Theme(
                          data: ThemeData.light().copyWith(
                            colorScheme: ColorScheme.light().copyWith(
                              primary: bluePurple,
                            ),
                          ),
                          child: child,
                        );
                      },
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1920),
                      lastDate: DateTime(2100))
                      .then((DateTime newDate) {
                    if (newDate != null) {
                      String dateTime = dateFormat.format(newDate);
                      setState(() {
                        controller.text = dateTime;
                        if(encrypt){

                          bedRotaModel.updateTemporaryRecord(widget.edit, value, GlobalFunctions.encryptString(DateTime.fromMillisecondsSinceEpoch(newDate.millisecondsSinceEpoch).toIso8601String()), widget.jobId, widget.saved, widget.savedId);

                        } else {

                          bedRotaModel.updateTemporaryRecord(widget.edit, value, DateTime.fromMillisecondsSinceEpoch(newDate.millisecondsSinceEpoch).toIso8601String(), widget.jobId, widget.saved, widget.savedId);

                        }



                      });
                    }
                  });
                })
          ],
        ),
        SizedBox(height: 15,),
      ],
    );
  }
  Widget _buildTimeField(String label, TextEditingController controller, String value, [bool required = false, bool encrypt = false]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        RichText(
          text: TextSpan(
              text: label,
              style: TextStyle(
                  fontSize: 16.0, fontFamily: 'Open Sans', color: bluePurple),
              children:
              [
                TextSpan(
                  text: required ? ' *' : '',
                  style: TextStyle(
                      color: Colors.red,
                      fontSize: 16.0, fontFamily: 'Open Sans'),
                ),                                           ]
          ),
        ),
        Row(
          children: <Widget>[
            Flexible(
              child: IgnorePointer(
                child: TextFormField(
                  decoration: InputDecoration(              filled: required && controller.text.isEmpty ? true : false, fillColor: Color(0xFF0000).withOpacity(0.3),
                  ),
                  enabled: true,
                  initialValue: null,
                  controller: controller,
                  onSaved: (String value) {
                    setState(() {
                      controller.text = value;
                    });
                  },

                ),
              ),
            ),
            IconButton(
                color: Colors.grey,
                icon: Icon(Icons.clear),
                onPressed: () {
                  setState(() {
                    controller.clear();
                    bedRotaModel.updateTemporaryRecord(widget.edit, value, null, widget.jobId, widget.saved, widget.savedId);
                  });
                }),
            IconButton(
                icon: Icon(Icons.access_time,
                    color: bluePurple),
                onPressed: () async{
                  FocusScope.of(context).unfocus();
                  await Future.delayed(Duration(milliseconds: 100));
                  showTimePicker(
                      initialTime: TimeOfDay.now(),
                      builder: (BuildContext context, Widget child) {
                        return Theme(
                          data: ThemeData.light().copyWith(
                            colorScheme: ColorScheme.light().copyWith(
                              primary: bluePurple,
                            ),
                          ),
                          child: child,
                        );
                      },
                      context: context)
                      .then((TimeOfDay time) {
                    if (time != null) {
                      DateTime today = new DateTime.now();
                      DateTime newDate = new DateTime(today.year, today.month, today.day);
                      newDate = newDate.add(Duration(hours: time.hour, minutes: time.minute));
                      String dateTime = timeFormat.format(newDate);
                      setState(() {
                        controller.text = dateTime;
                        if(encrypt){
                         bedRotaModel.updateTemporaryRecord(widget.edit, value, GlobalFunctions.encryptString(DateTime.fromMillisecondsSinceEpoch(newDate.millisecondsSinceEpoch).toIso8601String()), widget.jobId, widget.saved, widget.savedId);
                        } else {
                          bedRotaModel.updateTemporaryRecord(widget.edit, value, DateTime.fromMillisecondsSinceEpoch(newDate.millisecondsSinceEpoch).toIso8601String(), widget.jobId, widget.saved, widget.savedId);
                        }
                      });
                    }
                  });
                })
          ],
        ),
        SizedBox(height: 15,)
      ],
    );
  }


  Widget _buildJobRefDrop() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
              text: 'Reference',
              style: TextStyle(
                  fontSize: 16.0, fontFamily: 'Open Sans', color: bluePurple),
              children:
              [
                TextSpan(
                  text: ' *',
                  style: TextStyle(
                      color: Colors.red,
                      fontSize: 16.0),
                ),                                           ]
          ),
        ),
        Container(
          color: jobRefRef == 'Select One' ? Color(0xFF0000).withOpacity(0.3) : null,
          child: DropdownFormField(
            expanded: false,
            value: jobRefRef,
            items: jobRefDrop.toList(),
            onChanged: (val) => setState(() {
              jobRefRef = val;
              if(val == 'Select One'){
                bedRotaModel.updateTemporaryRecord(widget.edit, Strings.jobRefRef, null, widget.jobId, widget.saved, widget.savedId);
              } else {
                bedRotaModel.updateTemporaryRecord(widget.edit, Strings.jobRefRef, val, widget.jobId, widget.saved, widget.savedId);
              }

              FocusScope.of(context).unfocus();
            }),
            initialValue: jobRefRef,
          ),
        ),
        SizedBox(height: 15,),
      ],
    );
  }


  void _resetForm() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(32.0))),
            contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
            titlePadding: EdgeInsets.all(0),
            title: Container(
              padding: EdgeInsets.only(top: 10, bottom: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [purpleDesign, purpleDesign]),
                borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
              ),
              child: Center(child: Text("Reset Bed Watch Rota", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),),
            ),
            content: Text('Are you sure you wish to reset this form?'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  FocusScope.of(context).requestFocus(new FocusNode());
                  Navigator.of(context).pop();
                },
                child: Text(
                  'No',
                  style: TextStyle(color: blueDesign, fontWeight: FontWeight.bold),
                ),
              ),
              TextButton(
                onPressed: () {
                  context.read<BedRotaModel>().resetTemporaryRecord(widget.jobId, widget.saved, widget.savedId);
                  //context.read<BedRotaModel>().resetTemporaryBedRota(widget.jobId, widget.saved, widget.savedId);
                  FocusScope.of(context).requestFocus(new FocusNode());
                  setState(() {
                    jobRef.clear();
                    jobRefRef = 'Select One';
                    weekCommencing.clear();
                    mondayAmName1.clear();
                    mondayAmFrom1.clear();
                    mondayAmTo1.clear();
                    mondayPmName1.clear();
                    mondayPmFrom1.clear();
                    mondayPmTo1.clear();
                    mondayNightName1.clear();
                    mondayNightFrom1.clear();
                    mondayNightTo1.clear();
                    mondayAmName2.clear();
                    mondayAmFrom2.clear();
                    mondayAmTo2.clear();
                    mondayPmName2.clear();
                    mondayPmFrom2.clear();
                    mondayPmTo2.clear();
                    mondayNightName2.clear();
                    mondayNightFrom2.clear();
                    mondayNightTo2.clear();
                    mondayAmName3.clear();
                    mondayAmFrom3.clear();
                    mondayAmTo3.clear();
                    mondayPmName3.clear();
                    mondayPmFrom3.clear();
                    mondayPmTo3.clear();
                    mondayNightName3.clear();
                    mondayNightFrom3.clear();
                    mondayNightTo3.clear();
                    mondayAmName4.clear();
                    mondayAmFrom4.clear();
                    mondayAmTo4.clear();
                    mondayPmName4.clear();
                    mondayPmFrom4.clear();
                    mondayPmTo4.clear();
                    mondayNightName4.clear();
                    mondayNightFrom4.clear();
                    mondayNightTo4.clear();
                    mondayAmName5.clear();
                    mondayAmFrom5.clear();
                    mondayAmTo5.clear();
                    mondayPmName5.clear();
                    mondayPmFrom5.clear();
                    mondayPmTo5.clear();
                    mondayNightName5.clear();
                    mondayNightFrom5.clear();
                    mondayNightTo5.clear();
                    tuesdayAmName1.clear();
                    tuesdayAmFrom1.clear();
                    tuesdayAmTo1.clear();
                    tuesdayPmName1.clear();
                    tuesdayPmFrom1.clear();
                    tuesdayPmTo1.clear();
                    tuesdayNightName1.clear();
                    tuesdayNightFrom1.clear();
                    tuesdayNightTo1.clear();
                    tuesdayAmName2.clear();
                    tuesdayAmFrom2.clear();
                    tuesdayAmTo2.clear();
                    tuesdayPmName2.clear();
                    tuesdayPmFrom2.clear();
                    tuesdayPmTo2.clear();
                    tuesdayNightName2.clear();
                    tuesdayNightFrom2.clear();
                    tuesdayNightTo2.clear();
                    tuesdayAmName3.clear();
                    tuesdayAmFrom3.clear();
                    tuesdayAmTo3.clear();
                    tuesdayPmName3.clear();
                    tuesdayPmFrom3.clear();
                    tuesdayPmTo3.clear();
                    tuesdayNightName3.clear();
                    tuesdayNightFrom3.clear();
                    tuesdayNightTo3.clear();
                    tuesdayAmName4.clear();
                    tuesdayAmFrom4.clear();
                    tuesdayAmTo4.clear();
                    tuesdayPmName4.clear();
                    tuesdayPmFrom4.clear();
                    tuesdayPmTo4.clear();
                    tuesdayNightName4.clear();
                    tuesdayNightFrom4.clear();
                    tuesdayNightTo4.clear();
                    tuesdayAmName5.clear();
                    tuesdayAmFrom5.clear();
                    tuesdayAmTo5.clear();
                    tuesdayPmName5.clear();
                    tuesdayPmFrom5.clear();
                    tuesdayPmTo5.clear();
                    tuesdayNightName5.clear();
                    tuesdayNightFrom5.clear();
                    tuesdayNightTo5.clear();
                    wednesdayAmName1.clear();
                    wednesdayAmFrom1.clear();
                    wednesdayAmTo1.clear();
                    wednesdayPmName1.clear();
                    wednesdayPmFrom1.clear();
                    wednesdayPmTo1.clear();
                    wednesdayNightName1.clear();
                    wednesdayNightFrom1.clear();
                    wednesdayNightTo1.clear();
                    wednesdayAmName2.clear();
                    wednesdayAmFrom2.clear();
                    wednesdayAmTo2.clear();
                    wednesdayPmName2.clear();
                    wednesdayPmFrom2.clear();
                    wednesdayPmTo2.clear();
                    wednesdayNightName2.clear();
                    wednesdayNightFrom2.clear();
                    wednesdayNightTo2.clear();
                    wednesdayAmName3.clear();
                    wednesdayAmFrom3.clear();
                    wednesdayAmTo3.clear();
                    wednesdayPmName3.clear();
                    wednesdayPmFrom3.clear();
                    wednesdayPmTo3.clear();
                    wednesdayNightName3.clear();
                    wednesdayNightFrom3.clear();
                    wednesdayNightTo3.clear();
                    wednesdayAmName4.clear();
                    wednesdayAmFrom4.clear();
                    wednesdayAmTo4.clear();
                    wednesdayPmName4.clear();
                    wednesdayPmFrom4.clear();
                    wednesdayPmTo4.clear();
                    wednesdayNightName4.clear();
                    wednesdayNightFrom4.clear();
                    wednesdayNightTo4.clear();
                    wednesdayAmName5.clear();
                    wednesdayAmFrom5.clear();
                    wednesdayAmTo5.clear();
                    wednesdayPmName5.clear();
                    wednesdayPmFrom5.clear();
                    wednesdayPmTo5.clear();
                    wednesdayNightName5.clear();
                    wednesdayNightFrom5.clear();
                    wednesdayNightTo5.clear();
                    thursdayAmName1.clear();
                    thursdayAmFrom1.clear();
                    thursdayAmTo1.clear();
                    thursdayPmName1.clear();
                    thursdayPmFrom1.clear();
                    thursdayPmTo1.clear();
                    thursdayNightName1.clear();
                    thursdayNightFrom1.clear();
                    thursdayNightTo1.clear();
                    thursdayAmName2.clear();
                    thursdayAmFrom2.clear();
                    thursdayAmTo2.clear();
                    thursdayPmName2.clear();
                    thursdayPmFrom2.clear();
                    thursdayPmTo2.clear();
                    thursdayNightName2.clear();
                    thursdayNightFrom2.clear();
                    thursdayNightTo2.clear();
                    thursdayAmName3.clear();
                    thursdayAmFrom3.clear();
                    thursdayAmTo3.clear();
                    thursdayPmName3.clear();
                    thursdayPmFrom3.clear();
                    thursdayPmTo3.clear();
                    thursdayNightName3.clear();
                    thursdayNightFrom3.clear();
                    thursdayNightTo3.clear();
                    thursdayAmName4.clear();
                    thursdayAmFrom4.clear();
                    thursdayAmTo4.clear();
                    thursdayPmName4.clear();
                    thursdayPmFrom4.clear();
                    thursdayPmTo4.clear();
                    thursdayNightName4.clear();
                    thursdayNightFrom4.clear();
                    thursdayNightTo4.clear();
                    thursdayAmName5.clear();
                    thursdayAmFrom5.clear();
                    thursdayAmTo5.clear();
                    thursdayPmName5.clear();
                    thursdayPmFrom5.clear();
                    thursdayPmTo5.clear();
                    thursdayNightName5.clear();
                    thursdayNightFrom5.clear();
                    thursdayNightTo5.clear();
                    fridayAmName1.clear();
                    fridayAmFrom1.clear();
                    fridayAmTo1.clear();
                    fridayPmName1.clear();
                    fridayPmFrom1.clear();
                    fridayPmTo1.clear();
                    fridayNightName1.clear();
                    fridayNightFrom1.clear();
                    fridayNightTo1.clear();
                    fridayAmName2.clear();
                    fridayAmFrom2.clear();
                    fridayAmTo2.clear();
                    fridayPmName2.clear();
                    fridayPmFrom2.clear();
                    fridayPmTo2.clear();
                    fridayNightName2.clear();
                    fridayNightFrom2.clear();
                    fridayNightTo2.clear();
                    fridayAmName3.clear();
                    fridayAmFrom3.clear();
                    fridayAmTo3.clear();
                    fridayPmName3.clear();
                    fridayPmFrom3.clear();
                    fridayPmTo3.clear();
                    fridayNightName3.clear();
                    fridayNightFrom3.clear();
                    fridayNightTo3.clear();
                    fridayAmName4.clear();
                    fridayAmFrom4.clear();
                    fridayAmTo4.clear();
                    fridayPmName4.clear();
                    fridayPmFrom4.clear();
                    fridayPmTo4.clear();
                    fridayNightName4.clear();
                    fridayNightFrom4.clear();
                    fridayNightTo4.clear();
                    fridayAmName5.clear();
                    fridayAmFrom5.clear();
                    fridayAmTo5.clear();
                    fridayPmName5.clear();
                    fridayPmFrom5.clear();
                    fridayPmTo5.clear();
                    fridayNightName5.clear();
                    fridayNightFrom5.clear();
                    fridayNightTo5.clear();
                    saturdayAmName1.clear();
                    saturdayAmFrom1.clear();
                    saturdayAmTo1.clear();
                    saturdayPmName1.clear();
                    saturdayPmFrom1.clear();
                    saturdayPmTo1.clear();
                    saturdayNightName1.clear();
                    saturdayNightFrom1.clear();
                    saturdayNightTo1.clear();
                    saturdayAmName2.clear();
                    saturdayAmFrom2.clear();
                    saturdayAmTo2.clear();
                    saturdayPmName2.clear();
                    saturdayPmFrom2.clear();
                    saturdayPmTo2.clear();
                    saturdayNightName2.clear();
                    saturdayNightFrom2.clear();
                    saturdayNightTo2.clear();
                    saturdayAmName3.clear();
                    saturdayAmFrom3.clear();
                    saturdayAmTo3.clear();
                    saturdayPmName3.clear();
                    saturdayPmFrom3.clear();
                    saturdayPmTo3.clear();
                    saturdayNightName3.clear();
                    saturdayNightFrom3.clear();
                    saturdayNightTo3.clear();
                    saturdayAmName4.clear();
                    saturdayAmFrom4.clear();
                    saturdayAmTo4.clear();
                    saturdayPmName4.clear();
                    saturdayPmFrom4.clear();
                    saturdayPmTo4.clear();
                    saturdayNightName4.clear();
                    saturdayNightFrom4.clear();
                    saturdayNightTo4.clear();
                    saturdayAmName5.clear();
                    saturdayAmFrom5.clear();
                    saturdayAmTo5.clear();
                    saturdayPmName5.clear();
                    saturdayPmFrom5.clear();
                    saturdayPmTo5.clear();
                    saturdayNightName5.clear();
                    saturdayNightFrom5.clear();
                    saturdayNightTo5.clear();
                    sundayAmName1.clear();
                    sundayAmFrom1.clear();
                    sundayAmTo1.clear();
                    sundayPmName1.clear();
                    sundayPmFrom1.clear();
                    sundayPmTo1.clear();
                    sundayNightName1.clear();
                    sundayNightFrom1.clear();
                    sundayNightTo1.clear();
                    sundayAmName2.clear();
                    sundayAmFrom2.clear();
                    sundayAmTo2.clear();
                    sundayPmName2.clear();
                    sundayPmFrom2.clear();
                    sundayPmTo2.clear();
                    sundayNightName2.clear();
                    sundayNightFrom2.clear();
                    sundayNightTo2.clear();
                    sundayAmName3.clear();
                    sundayAmFrom3.clear();
                    sundayAmTo3.clear();
                    sundayPmName3.clear();
                    sundayPmFrom3.clear();
                    sundayPmTo3.clear();
                    sundayNightName3.clear();
                    sundayNightFrom3.clear();
                    sundayNightTo3.clear();
                    sundayAmName4.clear();
                    sundayAmFrom4.clear();
                    sundayAmTo4.clear();
                    sundayPmName4.clear();
                    sundayPmFrom4.clear();
                    sundayPmTo4.clear();
                    sundayNightName4.clear();
                    sundayNightFrom4.clear();
                    sundayNightTo4.clear();
                    sundayAmName5.clear();
                    sundayAmFrom5.clear();
                    sundayAmTo5.clear();
                    sundayPmName5.clear();
                    sundayPmFrom5.clear();
                    sundayPmTo5.clear();
                    sundayNightName5.clear();
                    sundayNightFrom5.clear();
                    sundayNightTo5.clear();
                  });
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Yes',
                  style: TextStyle(color: blueDesign, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          );
        });
  }

  void _saveForLater() async {
    FocusScope.of(context).unfocus();

    bool submitForm = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(32.0))),
            contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
            titlePadding: EdgeInsets.all(0),
            title: Container(
              padding: EdgeInsets.only(top: 10, bottom: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [purpleDesign, purpleDesign]),
                borderRadius: BorderRadius.only(topLeft: Radius.circular(32),
                    topRight: Radius.circular(32)),
              ),
              child: Center(child: Text("Save for later", style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),),),
            ),
            content: Text(
                'This form will be moved to your saved list, do you wish to proceed?'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  FocusScope.of(context).requestFocus(new FocusNode());
                  Navigator.of(context).pop(false);
                },
                child: Text(
                  'No',
                  style: TextStyle(
                      color: blueDesign, fontWeight: FontWeight.bold),
                ),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop(true);
                },
                child: Text(
                  'Yes',
                  style: TextStyle(
                      color: blueDesign, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          );
        });


    if (submitForm) {
      bool success = await context.read<BedRotaModel>().saveForLater(
          widget.jobId, widget.saved, widget.savedId);
      FocusScope.of(context).requestFocus(new FocusNode());


      if (success) {
        setState(() {
          jobRef.clear();
          jobRefRef = 'Select One';
          weekCommencing.clear();
          mondayAmName1.clear();
          mondayAmFrom1.clear();
          mondayAmTo1.clear();
          mondayPmName1.clear();
          mondayPmFrom1.clear();
          mondayPmTo1.clear();
          mondayNightName1.clear();
          mondayNightFrom1.clear();
          mondayNightTo1.clear();
          mondayAmName2.clear();
          mondayAmFrom2.clear();
          mondayAmTo2.clear();
          mondayPmName2.clear();
          mondayPmFrom2.clear();
          mondayPmTo2.clear();
          mondayNightName2.clear();
          mondayNightFrom2.clear();
          mondayNightTo2.clear();
          mondayAmName3.clear();
          mondayAmFrom3.clear();
          mondayAmTo3.clear();
          mondayPmName3.clear();
          mondayPmFrom3.clear();
          mondayPmTo3.clear();
          mondayNightName3.clear();
          mondayNightFrom3.clear();
          mondayNightTo3.clear();
          mondayAmName4.clear();
          mondayAmFrom4.clear();
          mondayAmTo4.clear();
          mondayPmName4.clear();
          mondayPmFrom4.clear();
          mondayPmTo4.clear();
          mondayNightName4.clear();
          mondayNightFrom4.clear();
          mondayNightTo4.clear();
          mondayAmName5.clear();
          mondayAmFrom5.clear();
          mondayAmTo5.clear();
          mondayPmName5.clear();
          mondayPmFrom5.clear();
          mondayPmTo5.clear();
          mondayNightName5.clear();
          mondayNightFrom5.clear();
          mondayNightTo5.clear();
          tuesdayAmName1.clear();
          tuesdayAmFrom1.clear();
          tuesdayAmTo1.clear();
          tuesdayPmName1.clear();
          tuesdayPmFrom1.clear();
          tuesdayPmTo1.clear();
          tuesdayNightName1.clear();
          tuesdayNightFrom1.clear();
          tuesdayNightTo1.clear();
          tuesdayAmName2.clear();
          tuesdayAmFrom2.clear();
          tuesdayAmTo2.clear();
          tuesdayPmName2.clear();
          tuesdayPmFrom2.clear();
          tuesdayPmTo2.clear();
          tuesdayNightName2.clear();
          tuesdayNightFrom2.clear();
          tuesdayNightTo2.clear();
          tuesdayAmName3.clear();
          tuesdayAmFrom3.clear();
          tuesdayAmTo3.clear();
          tuesdayPmName3.clear();
          tuesdayPmFrom3.clear();
          tuesdayPmTo3.clear();
          tuesdayNightName3.clear();
          tuesdayNightFrom3.clear();
          tuesdayNightTo3.clear();
          tuesdayAmName4.clear();
          tuesdayAmFrom4.clear();
          tuesdayAmTo4.clear();
          tuesdayPmName4.clear();
          tuesdayPmFrom4.clear();
          tuesdayPmTo4.clear();
          tuesdayNightName4.clear();
          tuesdayNightFrom4.clear();
          tuesdayNightTo4.clear();
          tuesdayAmName5.clear();
          tuesdayAmFrom5.clear();
          tuesdayAmTo5.clear();
          tuesdayPmName5.clear();
          tuesdayPmFrom5.clear();
          tuesdayPmTo5.clear();
          tuesdayNightName5.clear();
          tuesdayNightFrom5.clear();
          tuesdayNightTo5.clear();
          wednesdayAmName1.clear();
          wednesdayAmFrom1.clear();
          wednesdayAmTo1.clear();
          wednesdayPmName1.clear();
          wednesdayPmFrom1.clear();
          wednesdayPmTo1.clear();
          wednesdayNightName1.clear();
          wednesdayNightFrom1.clear();
          wednesdayNightTo1.clear();
          wednesdayAmName2.clear();
          wednesdayAmFrom2.clear();
          wednesdayAmTo2.clear();
          wednesdayPmName2.clear();
          wednesdayPmFrom2.clear();
          wednesdayPmTo2.clear();
          wednesdayNightName2.clear();
          wednesdayNightFrom2.clear();
          wednesdayNightTo2.clear();
          wednesdayAmName3.clear();
          wednesdayAmFrom3.clear();
          wednesdayAmTo3.clear();
          wednesdayPmName3.clear();
          wednesdayPmFrom3.clear();
          wednesdayPmTo3.clear();
          wednesdayNightName3.clear();
          wednesdayNightFrom3.clear();
          wednesdayNightTo3.clear();
          wednesdayAmName4.clear();
          wednesdayAmFrom4.clear();
          wednesdayAmTo4.clear();
          wednesdayPmName4.clear();
          wednesdayPmFrom4.clear();
          wednesdayPmTo4.clear();
          wednesdayNightName4.clear();
          wednesdayNightFrom4.clear();
          wednesdayNightTo4.clear();
          wednesdayAmName5.clear();
          wednesdayAmFrom5.clear();
          wednesdayAmTo5.clear();
          wednesdayPmName5.clear();
          wednesdayPmFrom5.clear();
          wednesdayPmTo5.clear();
          wednesdayNightName5.clear();
          wednesdayNightFrom5.clear();
          wednesdayNightTo5.clear();
          thursdayAmName1.clear();
          thursdayAmFrom1.clear();
          thursdayAmTo1.clear();
          thursdayPmName1.clear();
          thursdayPmFrom1.clear();
          thursdayPmTo1.clear();
          thursdayNightName1.clear();
          thursdayNightFrom1.clear();
          thursdayNightTo1.clear();
          thursdayAmName2.clear();
          thursdayAmFrom2.clear();
          thursdayAmTo2.clear();
          thursdayPmName2.clear();
          thursdayPmFrom2.clear();
          thursdayPmTo2.clear();
          thursdayNightName2.clear();
          thursdayNightFrom2.clear();
          thursdayNightTo2.clear();
          thursdayAmName3.clear();
          thursdayAmFrom3.clear();
          thursdayAmTo3.clear();
          thursdayPmName3.clear();
          thursdayPmFrom3.clear();
          thursdayPmTo3.clear();
          thursdayNightName3.clear();
          thursdayNightFrom3.clear();
          thursdayNightTo3.clear();
          thursdayAmName4.clear();
          thursdayAmFrom4.clear();
          thursdayAmTo4.clear();
          thursdayPmName4.clear();
          thursdayPmFrom4.clear();
          thursdayPmTo4.clear();
          thursdayNightName4.clear();
          thursdayNightFrom4.clear();
          thursdayNightTo4.clear();
          thursdayAmName5.clear();
          thursdayAmFrom5.clear();
          thursdayAmTo5.clear();
          thursdayPmName5.clear();
          thursdayPmFrom5.clear();
          thursdayPmTo5.clear();
          thursdayNightName5.clear();
          thursdayNightFrom5.clear();
          thursdayNightTo5.clear();
          fridayAmName1.clear();
          fridayAmFrom1.clear();
          fridayAmTo1.clear();
          fridayPmName1.clear();
          fridayPmFrom1.clear();
          fridayPmTo1.clear();
          fridayNightName1.clear();
          fridayNightFrom1.clear();
          fridayNightTo1.clear();
          fridayAmName2.clear();
          fridayAmFrom2.clear();
          fridayAmTo2.clear();
          fridayPmName2.clear();
          fridayPmFrom2.clear();
          fridayPmTo2.clear();
          fridayNightName2.clear();
          fridayNightFrom2.clear();
          fridayNightTo2.clear();
          fridayAmName3.clear();
          fridayAmFrom3.clear();
          fridayAmTo3.clear();
          fridayPmName3.clear();
          fridayPmFrom3.clear();
          fridayPmTo3.clear();
          fridayNightName3.clear();
          fridayNightFrom3.clear();
          fridayNightTo3.clear();
          fridayAmName4.clear();
          fridayAmFrom4.clear();
          fridayAmTo4.clear();
          fridayPmName4.clear();
          fridayPmFrom4.clear();
          fridayPmTo4.clear();
          fridayNightName4.clear();
          fridayNightFrom4.clear();
          fridayNightTo4.clear();
          fridayAmName5.clear();
          fridayAmFrom5.clear();
          fridayAmTo5.clear();
          fridayPmName5.clear();
          fridayPmFrom5.clear();
          fridayPmTo5.clear();
          fridayNightName5.clear();
          fridayNightFrom5.clear();
          fridayNightTo5.clear();
          saturdayAmName1.clear();
          saturdayAmFrom1.clear();
          saturdayAmTo1.clear();
          saturdayPmName1.clear();
          saturdayPmFrom1.clear();
          saturdayPmTo1.clear();
          saturdayNightName1.clear();
          saturdayNightFrom1.clear();
          saturdayNightTo1.clear();
          saturdayAmName2.clear();
          saturdayAmFrom2.clear();
          saturdayAmTo2.clear();
          saturdayPmName2.clear();
          saturdayPmFrom2.clear();
          saturdayPmTo2.clear();
          saturdayNightName2.clear();
          saturdayNightFrom2.clear();
          saturdayNightTo2.clear();
          saturdayAmName3.clear();
          saturdayAmFrom3.clear();
          saturdayAmTo3.clear();
          saturdayPmName3.clear();
          saturdayPmFrom3.clear();
          saturdayPmTo3.clear();
          saturdayNightName3.clear();
          saturdayNightFrom3.clear();
          saturdayNightTo3.clear();
          saturdayAmName4.clear();
          saturdayAmFrom4.clear();
          saturdayAmTo4.clear();
          saturdayPmName4.clear();
          saturdayPmFrom4.clear();
          saturdayPmTo4.clear();
          saturdayNightName4.clear();
          saturdayNightFrom4.clear();
          saturdayNightTo4.clear();
          saturdayAmName5.clear();
          saturdayAmFrom5.clear();
          saturdayAmTo5.clear();
          saturdayPmName5.clear();
          saturdayPmFrom5.clear();
          saturdayPmTo5.clear();
          saturdayNightName5.clear();
          saturdayNightFrom5.clear();
          saturdayNightTo5.clear();
          sundayAmName1.clear();
          sundayAmFrom1.clear();
          sundayAmTo1.clear();
          sundayPmName1.clear();
          sundayPmFrom1.clear();
          sundayPmTo1.clear();
          sundayNightName1.clear();
          sundayNightFrom1.clear();
          sundayNightTo1.clear();
          sundayAmName2.clear();
          sundayAmFrom2.clear();
          sundayAmTo2.clear();
          sundayPmName2.clear();
          sundayPmFrom2.clear();
          sundayPmTo2.clear();
          sundayNightName2.clear();
          sundayNightFrom2.clear();
          sundayNightTo2.clear();
          sundayAmName3.clear();
          sundayAmFrom3.clear();
          sundayAmTo3.clear();
          sundayPmName3.clear();
          sundayPmFrom3.clear();
          sundayPmTo3.clear();
          sundayNightName3.clear();
          sundayNightFrom3.clear();
          sundayNightTo3.clear();
          sundayAmName4.clear();
          sundayAmFrom4.clear();
          sundayAmTo4.clear();
          sundayPmName4.clear();
          sundayPmFrom4.clear();
          sundayPmTo4.clear();
          sundayNightName4.clear();
          sundayNightFrom4.clear();
          sundayNightTo4.clear();
          sundayAmName5.clear();
          sundayAmFrom5.clear();
          sundayAmTo5.clear();
          sundayPmName5.clear();
          sundayPmFrom5.clear();
          sundayPmTo5.clear();
          sundayNightName5.clear();
          sundayNightFrom5.clear();
          sundayNightTo5.clear();
          FocusScope.of(context).requestFocus(new FocusNode());
        });
      }
    }
  }

  void _submitForm() async {
    FocusScope.of(context).unfocus();

    bool continueSubmit = await bedRotaModel.validateBedRota(widget.jobId, widget.edit, widget.saved, widget.savedId);


    if (!continueSubmit) {

      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(32.0))),
              contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
              titlePadding: EdgeInsets.all(0),
              title: Container(
                padding: EdgeInsets.only(top: 10, bottom: 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [purpleDesign, purpleDesign]),
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
                ),
                child: Center(child: Text("Check Form", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                        text: 'Please ensure you have filled in all required fields marked with a',
                        style: TextStyle(color: Colors.black, fontSize: 16, fontFamily: 'Open Sans'),
                        children:
                        [
                          TextSpan(
                            text: ' *',
                            style: TextStyle(
                                color: Colors.red, fontSize: 16, fontFamily: 'Open Sans'),
                          ),                                           ]
                    ),
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    FocusScope.of(context).requestFocus(new FocusNode());
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'OK',
                    style: TextStyle(color: blueDesign, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          });



    } else {

      bool submitForm = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(32.0))),
              contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
              titlePadding: EdgeInsets.all(0),
              title: Container(
                padding: EdgeInsets.only(top: 10, bottom: 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [purpleDesign, purpleDesign]),
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
                ),
                child: Center(child: Text("Submit Bed Watch Rota", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),),
              ),
              content: Text('Are you sure you wish to submit this form?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    FocusScope.of(context).requestFocus(new FocusNode());
                    Navigator.of(context).pop(false);
                  },
                  child: Text(
                    'No',
                    style: TextStyle(color: blueDesign, fontWeight: FontWeight.bold),
                  ),
                ),
                TextButton(
                  onPressed: () async{
                    Navigator.of(context).pop(true);
                  },
                  child: Text(
                    'Yes',
                    style: TextStyle(color: blueDesign, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          });



      if(submitForm){

        bool success;

        if(widget.edit){
          success = await context.read<BedRotaModel>().editBedRota(widget.jobId);
          FocusScope.of(context).requestFocus(new FocusNode());

        } else {
          success = await context.read<BedRotaModel>().submitBedRota(widget.jobId, widget.edit, widget.saved, widget.savedId);
          FocusScope.of(context).requestFocus(new FocusNode());
        }

        if(success){
          setState(() {
            jobRef.clear();
            jobRefRef = 'Select One';
            weekCommencing.clear();
            mondayAmName1.clear();
            mondayAmFrom1.clear();
            mondayAmTo1.clear();
            mondayPmName1.clear();
            mondayPmFrom1.clear();
            mondayPmTo1.clear();
            mondayNightName1.clear();
            mondayNightFrom1.clear();
            mondayNightTo1.clear();
            mondayAmName2.clear();
            mondayAmFrom2.clear();
            mondayAmTo2.clear();
            mondayPmName2.clear();
            mondayPmFrom2.clear();
            mondayPmTo2.clear();
            mondayNightName2.clear();
            mondayNightFrom2.clear();
            mondayNightTo2.clear();
            mondayAmName3.clear();
            mondayAmFrom3.clear();
            mondayAmTo3.clear();
            mondayPmName3.clear();
            mondayPmFrom3.clear();
            mondayPmTo3.clear();
            mondayNightName3.clear();
            mondayNightFrom3.clear();
            mondayNightTo3.clear();
            mondayAmName4.clear();
            mondayAmFrom4.clear();
            mondayAmTo4.clear();
            mondayPmName4.clear();
            mondayPmFrom4.clear();
            mondayPmTo4.clear();
            mondayNightName4.clear();
            mondayNightFrom4.clear();
            mondayNightTo4.clear();
            mondayAmName5.clear();
            mondayAmFrom5.clear();
            mondayAmTo5.clear();
            mondayPmName5.clear();
            mondayPmFrom5.clear();
            mondayPmTo5.clear();
            mondayNightName5.clear();
            mondayNightFrom5.clear();
            mondayNightTo5.clear();
            tuesdayAmName1.clear();
            tuesdayAmFrom1.clear();
            tuesdayAmTo1.clear();
            tuesdayPmName1.clear();
            tuesdayPmFrom1.clear();
            tuesdayPmTo1.clear();
            tuesdayNightName1.clear();
            tuesdayNightFrom1.clear();
            tuesdayNightTo1.clear();
            tuesdayAmName2.clear();
            tuesdayAmFrom2.clear();
            tuesdayAmTo2.clear();
            tuesdayPmName2.clear();
            tuesdayPmFrom2.clear();
            tuesdayPmTo2.clear();
            tuesdayNightName2.clear();
            tuesdayNightFrom2.clear();
            tuesdayNightTo2.clear();
            tuesdayAmName3.clear();
            tuesdayAmFrom3.clear();
            tuesdayAmTo3.clear();
            tuesdayPmName3.clear();
            tuesdayPmFrom3.clear();
            tuesdayPmTo3.clear();
            tuesdayNightName3.clear();
            tuesdayNightFrom3.clear();
            tuesdayNightTo3.clear();
            tuesdayAmName4.clear();
            tuesdayAmFrom4.clear();
            tuesdayAmTo4.clear();
            tuesdayPmName4.clear();
            tuesdayPmFrom4.clear();
            tuesdayPmTo4.clear();
            tuesdayNightName4.clear();
            tuesdayNightFrom4.clear();
            tuesdayNightTo4.clear();
            tuesdayAmName5.clear();
            tuesdayAmFrom5.clear();
            tuesdayAmTo5.clear();
            tuesdayPmName5.clear();
            tuesdayPmFrom5.clear();
            tuesdayPmTo5.clear();
            tuesdayNightName5.clear();
            tuesdayNightFrom5.clear();
            tuesdayNightTo5.clear();
            wednesdayAmName1.clear();
            wednesdayAmFrom1.clear();
            wednesdayAmTo1.clear();
            wednesdayPmName1.clear();
            wednesdayPmFrom1.clear();
            wednesdayPmTo1.clear();
            wednesdayNightName1.clear();
            wednesdayNightFrom1.clear();
            wednesdayNightTo1.clear();
            wednesdayAmName2.clear();
            wednesdayAmFrom2.clear();
            wednesdayAmTo2.clear();
            wednesdayPmName2.clear();
            wednesdayPmFrom2.clear();
            wednesdayPmTo2.clear();
            wednesdayNightName2.clear();
            wednesdayNightFrom2.clear();
            wednesdayNightTo2.clear();
            wednesdayAmName3.clear();
            wednesdayAmFrom3.clear();
            wednesdayAmTo3.clear();
            wednesdayPmName3.clear();
            wednesdayPmFrom3.clear();
            wednesdayPmTo3.clear();
            wednesdayNightName3.clear();
            wednesdayNightFrom3.clear();
            wednesdayNightTo3.clear();
            wednesdayAmName4.clear();
            wednesdayAmFrom4.clear();
            wednesdayAmTo4.clear();
            wednesdayPmName4.clear();
            wednesdayPmFrom4.clear();
            wednesdayPmTo4.clear();
            wednesdayNightName4.clear();
            wednesdayNightFrom4.clear();
            wednesdayNightTo4.clear();
            wednesdayAmName5.clear();
            wednesdayAmFrom5.clear();
            wednesdayAmTo5.clear();
            wednesdayPmName5.clear();
            wednesdayPmFrom5.clear();
            wednesdayPmTo5.clear();
            wednesdayNightName5.clear();
            wednesdayNightFrom5.clear();
            wednesdayNightTo5.clear();
            thursdayAmName1.clear();
            thursdayAmFrom1.clear();
            thursdayAmTo1.clear();
            thursdayPmName1.clear();
            thursdayPmFrom1.clear();
            thursdayPmTo1.clear();
            thursdayNightName1.clear();
            thursdayNightFrom1.clear();
            thursdayNightTo1.clear();
            thursdayAmName2.clear();
            thursdayAmFrom2.clear();
            thursdayAmTo2.clear();
            thursdayPmName2.clear();
            thursdayPmFrom2.clear();
            thursdayPmTo2.clear();
            thursdayNightName2.clear();
            thursdayNightFrom2.clear();
            thursdayNightTo2.clear();
            thursdayAmName3.clear();
            thursdayAmFrom3.clear();
            thursdayAmTo3.clear();
            thursdayPmName3.clear();
            thursdayPmFrom3.clear();
            thursdayPmTo3.clear();
            thursdayNightName3.clear();
            thursdayNightFrom3.clear();
            thursdayNightTo3.clear();
            thursdayAmName4.clear();
            thursdayAmFrom4.clear();
            thursdayAmTo4.clear();
            thursdayPmName4.clear();
            thursdayPmFrom4.clear();
            thursdayPmTo4.clear();
            thursdayNightName4.clear();
            thursdayNightFrom4.clear();
            thursdayNightTo4.clear();
            thursdayAmName5.clear();
            thursdayAmFrom5.clear();
            thursdayAmTo5.clear();
            thursdayPmName5.clear();
            thursdayPmFrom5.clear();
            thursdayPmTo5.clear();
            thursdayNightName5.clear();
            thursdayNightFrom5.clear();
            thursdayNightTo5.clear();
            fridayAmName1.clear();
            fridayAmFrom1.clear();
            fridayAmTo1.clear();
            fridayPmName1.clear();
            fridayPmFrom1.clear();
            fridayPmTo1.clear();
            fridayNightName1.clear();
            fridayNightFrom1.clear();
            fridayNightTo1.clear();
            fridayAmName2.clear();
            fridayAmFrom2.clear();
            fridayAmTo2.clear();
            fridayPmName2.clear();
            fridayPmFrom2.clear();
            fridayPmTo2.clear();
            fridayNightName2.clear();
            fridayNightFrom2.clear();
            fridayNightTo2.clear();
            fridayAmName3.clear();
            fridayAmFrom3.clear();
            fridayAmTo3.clear();
            fridayPmName3.clear();
            fridayPmFrom3.clear();
            fridayPmTo3.clear();
            fridayNightName3.clear();
            fridayNightFrom3.clear();
            fridayNightTo3.clear();
            fridayAmName4.clear();
            fridayAmFrom4.clear();
            fridayAmTo4.clear();
            fridayPmName4.clear();
            fridayPmFrom4.clear();
            fridayPmTo4.clear();
            fridayNightName4.clear();
            fridayNightFrom4.clear();
            fridayNightTo4.clear();
            fridayAmName5.clear();
            fridayAmFrom5.clear();
            fridayAmTo5.clear();
            fridayPmName5.clear();
            fridayPmFrom5.clear();
            fridayPmTo5.clear();
            fridayNightName5.clear();
            fridayNightFrom5.clear();
            fridayNightTo5.clear();
            saturdayAmName1.clear();
            saturdayAmFrom1.clear();
            saturdayAmTo1.clear();
            saturdayPmName1.clear();
            saturdayPmFrom1.clear();
            saturdayPmTo1.clear();
            saturdayNightName1.clear();
            saturdayNightFrom1.clear();
            saturdayNightTo1.clear();
            saturdayAmName2.clear();
            saturdayAmFrom2.clear();
            saturdayAmTo2.clear();
            saturdayPmName2.clear();
            saturdayPmFrom2.clear();
            saturdayPmTo2.clear();
            saturdayNightName2.clear();
            saturdayNightFrom2.clear();
            saturdayNightTo2.clear();
            saturdayAmName3.clear();
            saturdayAmFrom3.clear();
            saturdayAmTo3.clear();
            saturdayPmName3.clear();
            saturdayPmFrom3.clear();
            saturdayPmTo3.clear();
            saturdayNightName3.clear();
            saturdayNightFrom3.clear();
            saturdayNightTo3.clear();
            saturdayAmName4.clear();
            saturdayAmFrom4.clear();
            saturdayAmTo4.clear();
            saturdayPmName4.clear();
            saturdayPmFrom4.clear();
            saturdayPmTo4.clear();
            saturdayNightName4.clear();
            saturdayNightFrom4.clear();
            saturdayNightTo4.clear();
            saturdayAmName5.clear();
            saturdayAmFrom5.clear();
            saturdayAmTo5.clear();
            saturdayPmName5.clear();
            saturdayPmFrom5.clear();
            saturdayPmTo5.clear();
            saturdayNightName5.clear();
            saturdayNightFrom5.clear();
            saturdayNightTo5.clear();
            sundayAmName1.clear();
            sundayAmFrom1.clear();
            sundayAmTo1.clear();
            sundayPmName1.clear();
            sundayPmFrom1.clear();
            sundayPmTo1.clear();
            sundayNightName1.clear();
            sundayNightFrom1.clear();
            sundayNightTo1.clear();
            sundayAmName2.clear();
            sundayAmFrom2.clear();
            sundayAmTo2.clear();
            sundayPmName2.clear();
            sundayPmFrom2.clear();
            sundayPmTo2.clear();
            sundayNightName2.clear();
            sundayNightFrom2.clear();
            sundayNightTo2.clear();
            sundayAmName3.clear();
            sundayAmFrom3.clear();
            sundayAmTo3.clear();
            sundayPmName3.clear();
            sundayPmFrom3.clear();
            sundayPmTo3.clear();
            sundayNightName3.clear();
            sundayNightFrom3.clear();
            sundayNightTo3.clear();
            sundayAmName4.clear();
            sundayAmFrom4.clear();
            sundayAmTo4.clear();
            sundayPmName4.clear();
            sundayPmFrom4.clear();
            sundayPmTo4.clear();
            sundayNightName4.clear();
            sundayNightFrom4.clear();
            sundayNightTo4.clear();
            sundayAmName5.clear();
            sundayAmFrom5.clear();
            sundayAmTo5.clear();
            sundayPmName5.clear();
            sundayPmFrom5.clear();
            sundayPmTo5.clear();
            sundayNightName5.clear();
            sundayNightFrom5.clear();
            sundayNightTo5.clear();
            FocusScope.of(context).requestFocus(new FocusNode());
          });
        }


      }
    }
  }




  Widget _buildPageContent(BuildContext context) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth = deviceWidth > 768.0 ? 600.0 : deviceWidth * 0.95;
    final double targetPadding = deviceWidth - targetWidth;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Container(
        margin: EdgeInsets.all(10.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: targetPadding / 2),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: [
                      Flexible(child: _buildJobRefDrop()),
                      Container(width: 10,),
                      Flexible(child: _textFormField('', jobRef, 1, true, TextInputType.number),),
                    ],
                  ),
                  _buildDateField('Week Commencing', weekCommencing, Strings.weekCommencing, true, false),
                  SizedBox(height: 10,),
                  Text('Monday', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold, fontSize: 18),),
                  SizedBox(height: 5,),
                  Container(decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey)
                  ),
                    padding: EdgeInsets.all(10),
                    child: Column(
                      children: [
                        Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                          Text('AM', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold, fontSize: 16),)
                        ],),
                        SizedBox(height: 10,),
                        Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey)
                          ),
                          padding: EdgeInsets.all(10),
                          child: Column(
                            children: [
                              _textFormField('Name', mondayAmName1),
                              _buildTimeField('Shift Start', mondayAmFrom1, Strings.mondayAmFrom1),
                              _buildTimeField('Shift End', mondayAmTo1, Strings.mondayAmTo1),
                            ],
                          ),
                        ),
                        rowCountMondayAm >= 2 ? Column(
                          children: [
                            SizedBox(height: 10,),
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey)
                              ),
                              padding: EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  _textFormField('Name', mondayAmName2),
                                  _buildTimeField('Shift Start', mondayAmFrom2, Strings.mondayAmFrom2),
                                  _buildTimeField('Shift End', mondayAmTo2, Strings.mondayAmTo2),
                                ],
                              ),
                            ),
                          ],
                        ) : Container(),
                        rowCountMondayAm >= 3 ? Column(
                          children: [
                            SizedBox(height: 10,),
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey)
                              ),
                              padding: EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  _textFormField('Name', mondayAmName3),
                                  _buildTimeField('Shift Start', mondayAmFrom3, Strings.mondayAmFrom3),
                                  _buildTimeField('Shift End', mondayAmTo3, Strings.mondayAmTo3),
                                ],
                              ),
                            ),
                          ],
                        ) : Container(),
                        rowCountMondayAm >= 4 ? Column(
                          children: [
                            SizedBox(height: 10,),
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey)
                              ),
                              padding: EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  _textFormField('Name', mondayAmName4),
                                  _buildTimeField('Shift Start', mondayAmFrom4, Strings.mondayAmFrom4),
                                  _buildTimeField('Shift End', mondayAmTo4, Strings.mondayAmTo4),
                                ],
                              ),
                            ),
                          ],
                        ) : Container(),
                        rowCountMondayAm >= 5 ? Column(
                          children: [
                            SizedBox(height: 10,),
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey)
                              ),
                              padding: EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  _textFormField('Name', mondayAmName5),
                                  _buildTimeField('Shift Start', mondayAmFrom5, Strings.mondayAmFrom5),
                                  _buildTimeField('Shift End', mondayAmTo5, Strings.mondayAmTo5),
                                ],
                              ),
                            ),
                          ],
                        ) : Container(),
                        SizedBox(height: 10,),
                        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                          rowCountMondayAm < 2 ? Container() :
                          SizedBox(width: 150, child: GradientButton('Remove Staff', () => _decreaseRowCountMondayAm()),),
                          SizedBox(width: 10,),
                          SizedBox(width: 150, child: GradientButton('Add Staff', () => _increaseRowCountMondayAm()),),
                        ],),
                        SizedBox(height: 10,),
                        Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                          Text('PM', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold, fontSize: 16),)
                        ],),
                        SizedBox(height: 10,),
                        Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey)
                          ),
                          padding: EdgeInsets.all(10),
                          child: Column(
                            children: [
                              _textFormField('Name', mondayPmName1),
                              _buildTimeField('Shift Start', mondayPmFrom1, Strings.mondayPmFrom1),
                              _buildTimeField('Shift End', mondayPmTo1, Strings.mondayPmTo1),
                            ],
                          ),
                        ),
                        rowCountMondayPm >= 2 ? Column(
                          children: [
                            SizedBox(height: 10,),
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey)
                              ),
                              padding: EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  _textFormField('Name', mondayPmName2),
                                  _buildTimeField('Shift Start', mondayPmFrom2, Strings.mondayPmFrom2),
                                  _buildTimeField('Shift End', mondayPmTo2, Strings.mondayPmTo2),
                                ],
                              ),
                            ),
                          ],
                        ) : Container(),
                        rowCountMondayPm >= 3 ? Column(
                          children: [
                            SizedBox(height: 10,),
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey)
                              ),
                              padding: EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  _textFormField('Name', mondayPmName3),
                                  _buildTimeField('Shift Start', mondayPmFrom3, Strings.mondayPmFrom3),
                                  _buildTimeField('Shift End', mondayPmTo3, Strings.mondayPmTo3),
                                ],
                              ),
                            ),
                          ],
                        ) : Container(),
                        rowCountMondayPm >= 4 ? Column(
                          children: [
                            SizedBox(height: 10,),
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey)
                              ),
                              padding: EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  _textFormField('Name', mondayPmName4),
                                  _buildTimeField('Shift Start', mondayPmFrom4, Strings.mondayPmFrom4),
                                  _buildTimeField('Shift End', mondayPmTo4, Strings.mondayPmTo4),
                                ],
                              ),
                            ),
                          ],
                        ) : Container(),
                        rowCountMondayPm >= 5 ? Column(
                          children: [
                            SizedBox(height: 10,),
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey)
                              ),
                              padding: EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  _textFormField('Name', mondayPmName5),
                                  _buildTimeField('Shift Start', mondayPmFrom5, Strings.mondayPmFrom5),
                                  _buildTimeField('Shift End', mondayPmTo5, Strings.mondayPmTo5),
                                ],
                              ),
                            ),
                          ],
                        ) : Container(),
                        SizedBox(height: 10,),
                        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                          rowCountMondayPm < 2 ? Container() :
                          SizedBox(width: 150, child: GradientButton('Remove Staff', () => _decreaseRowCountMondayPm()),),
                          SizedBox(width: 10,),
                          SizedBox(width: 150, child: GradientButton('Add Staff', () => _increaseRowCountMondayPm()),),
                        ],),
                        SizedBox(height: 10,),
                        Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                          Text('Night', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold, fontSize: 16),)
                        ],),
                        SizedBox(height: 10,),
                        Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey)
                          ),
                          padding: EdgeInsets.all(10),
                          child: Column(
                            children: [
                              _textFormField('Name', mondayNightName1),
                              _buildTimeField('Shift Start', mondayNightFrom1, Strings.mondayNightFrom1),
                              _buildTimeField('Shift End', mondayNightTo1, Strings.mondayNightTo1),
                            ],
                          ),
                        ),
                        rowCountMondayNight >= 2 ? Column(
                          children: [
                            SizedBox(height: 10,),
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey)
                              ),
                              padding: EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  _textFormField('Name', mondayNightName2),
                                  _buildTimeField('Shift Start', mondayNightFrom2, Strings.mondayNightFrom2),
                                  _buildTimeField('Shift End', mondayNightTo2, Strings.mondayNightTo2),
                                ],
                              ),
                            ),
                          ],
                        ) : Container(),
                        rowCountMondayNight >= 3 ? Column(
                          children: [
                            SizedBox(height: 10,),
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey)
                              ),
                              padding: EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  _textFormField('Name', mondayNightName3),
                                  _buildTimeField('Shift Start', mondayNightFrom3, Strings.mondayNightFrom3),
                                  _buildTimeField('Shift End', mondayNightTo3, Strings.mondayNightTo3),
                                ],
                              ),
                            ),
                          ],
                        ) : Container(),
                        rowCountMondayNight >= 4 ? Column(
                          children: [
                            SizedBox(height: 10,),
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey)
                              ),
                              padding: EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  _textFormField('Name', mondayNightName4),
                                  _buildTimeField('Shift Start', mondayNightFrom4, Strings.mondayNightFrom4),
                                  _buildTimeField('Shift End', mondayNightTo4, Strings.mondayNightTo4),
                                ],
                              ),
                            ),
                          ],
                        ) : Container(),
                        rowCountMondayNight >= 5 ? Column(
                          children: [
                            SizedBox(height: 10,),
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey)
                              ),
                              padding: EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  _textFormField('Name', mondayNightName5),
                                  _buildTimeField('Shift Start', mondayNightFrom5, Strings.mondayNightFrom5),
                                  _buildTimeField('Shift End', mondayNightTo5, Strings.mondayNightTo5),
                                ],
                              ),
                            ),
                          ],
                        ) : Container(),
                        SizedBox(height: 10,),
                        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                          rowCountMondayNight < 2 ? Container() :
                          SizedBox(width: 150, child: GradientButton('Remove Staff', () => _decreaseRowCountMondayNight()),),
                          SizedBox(width: 10,),
                          SizedBox(width: 150, child: GradientButton('Add Staff', () => _increaseRowCountMondayNight()),),
                        ],),
                      ],
                    ),
                  ),
                  SizedBox(height: 10,),
                  Text('Tuesday', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold, fontSize: 18),),
                  SizedBox(height: 5,),
                  Container(decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey)
                  ),
                    padding: EdgeInsets.all(10),
                    child: Column(
                      children: [
                        Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                          Text('AM', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold, fontSize: 16),)
                        ],),
                        SizedBox(height: 10,),
                        Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey)
                          ),
                          padding: EdgeInsets.all(10),
                          child: Column(
                            children: [
                              _textFormField('Name', tuesdayAmName1),
                              _buildTimeField('Shift Start', tuesdayAmFrom1, Strings.tuesdayAmFrom1),
                              _buildTimeField('Shift End', tuesdayAmTo1, Strings.tuesdayAmTo1),
                            ],
                          ),
                        ),
                        rowCountTuesdayAm >= 2 ? Column(
                          children: [
                            SizedBox(height: 10,),
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey)
                              ),
                              padding: EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  _textFormField('Name', tuesdayAmName2),
                                  _buildTimeField('Shift Start', tuesdayAmFrom2, Strings.tuesdayAmFrom2),
                                  _buildTimeField('Shift End', tuesdayAmTo2, Strings.tuesdayAmTo2),
                                ],
                              ),
                            ),
                          ],
                        ) : Container(),
                        rowCountTuesdayAm >= 3 ? Column(
                          children: [
                            SizedBox(height: 10,),
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey)
                              ),
                              padding: EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  _textFormField('Name', tuesdayAmName3),
                                  _buildTimeField('Shift Start', tuesdayAmFrom3, Strings.tuesdayAmFrom3),
                                  _buildTimeField('Shift End', tuesdayAmTo3, Strings.tuesdayAmTo3),
                                ],
                              ),
                            ),
                          ],
                        ) : Container(),
                        rowCountTuesdayAm >= 4 ? Column(
                          children: [
                            SizedBox(height: 10,),
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey)
                              ),
                              padding: EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  _textFormField('Name', tuesdayAmName4),
                                  _buildTimeField('Shift Start', tuesdayAmFrom4, Strings.tuesdayAmFrom4),
                                  _buildTimeField('Shift End', tuesdayAmTo4, Strings.tuesdayAmTo4),
                                ],
                              ),
                            ),
                          ],
                        ) : Container(),
                        rowCountTuesdayAm >= 5 ? Column(
                          children: [
                            SizedBox(height: 10,),
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey)
                              ),
                              padding: EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  _textFormField('Name', tuesdayAmName5),
                                  _buildTimeField('Shift Start', tuesdayAmFrom5, Strings.tuesdayAmFrom5),
                                  _buildTimeField('Shift End', tuesdayAmTo5, Strings.tuesdayAmTo5),
                                ],
                              ),
                            ),
                          ],
                        ) : Container(),
                        SizedBox(height: 10,),
                        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                          rowCountTuesdayAm < 2 ? Container() :
                          SizedBox(width: 150, child: GradientButton('Remove Staff', () => _decreaseRowCountTuesdayAm()),),
                          SizedBox(width: 10,),
                          SizedBox(width: 150, child: GradientButton('Add Staff', () => _increaseRowCountTuesdayAm()),),
                        ],),
                        SizedBox(height: 10,),
                        Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                          Text('PM', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold, fontSize: 16),)
                        ],),
                        SizedBox(height: 10,),
                        Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey)
                          ),
                          padding: EdgeInsets.all(10),
                          child: Column(
                            children: [
                              _textFormField('Name', tuesdayPmName1),
                              _buildTimeField('Shift Start', tuesdayPmFrom1, Strings.tuesdayPmFrom1),
                              _buildTimeField('Shift End', tuesdayPmTo1, Strings.tuesdayPmTo1),
                            ],
                          ),
                        ),
                        rowCountTuesdayPm >= 2 ? Column(
                          children: [
                            SizedBox(height: 10,),
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey)
                              ),
                              padding: EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  _textFormField('Name', tuesdayPmName2),
                                  _buildTimeField('Shift Start', tuesdayPmFrom2, Strings.tuesdayPmFrom2),
                                  _buildTimeField('Shift End', tuesdayPmTo2, Strings.tuesdayPmTo2),
                                ],
                              ),
                            ),
                          ],
                        ) : Container(),
                        rowCountTuesdayPm >= 3 ? Column(
                          children: [
                            SizedBox(height: 10,),
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey)
                              ),
                              padding: EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  _textFormField('Name', tuesdayPmName3),
                                  _buildTimeField('Shift Start', tuesdayPmFrom3, Strings.tuesdayPmFrom3),
                                  _buildTimeField('Shift End', tuesdayPmTo3, Strings.tuesdayPmTo3),
                                ],
                              ),
                            ),
                          ],
                        ) : Container(),
                        rowCountTuesdayPm >= 4 ? Column(
                          children: [
                            SizedBox(height: 10,),
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey)
                              ),
                              padding: EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  _textFormField('Name', tuesdayPmName4),
                                  _buildTimeField('Shift Start', tuesdayPmFrom4, Strings.tuesdayPmFrom4),
                                  _buildTimeField('Shift End', tuesdayPmTo4, Strings.tuesdayPmTo4),
                                ],
                              ),
                            ),
                          ],
                        ) : Container(),
                        rowCountTuesdayPm >= 5 ? Column(
                          children: [
                            SizedBox(height: 10,),
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey)
                              ),
                              padding: EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  _textFormField('Name', tuesdayPmName5),
                                  _buildTimeField('Shift Start', tuesdayPmFrom5, Strings.tuesdayPmFrom5),
                                  _buildTimeField('Shift End', tuesdayPmTo5, Strings.tuesdayPmTo5),
                                ],
                              ),
                            ),
                          ],
                        ) : Container(),
                        SizedBox(height: 10,),
                        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                          rowCountTuesdayPm < 2 ? Container() :
                          SizedBox(width: 150, child: GradientButton('Remove Staff', () => _decreaseRowCountTuesdayPm()),),
                          SizedBox(width: 10,),
                          SizedBox(width: 150, child: GradientButton('Add Staff', () => _increaseRowCountTuesdayPm()),),
                        ],),
                        SizedBox(height: 10,),
                        Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                          Text('Night', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold, fontSize: 16),)
                        ],),
                        SizedBox(height: 10,),
                        Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey)
                          ),
                          padding: EdgeInsets.all(10),
                          child: Column(
                            children: [
                              _textFormField('Name', tuesdayNightName1),
                              _buildTimeField('Shift Start', tuesdayNightFrom1, Strings.tuesdayNightFrom1),
                              _buildTimeField('Shift End', tuesdayNightTo1, Strings.tuesdayNightTo1),
                            ],
                          ),
                        ),
                        rowCountTuesdayNight >= 2 ? Column(
                          children: [
                            SizedBox(height: 10,),
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey)
                              ),
                              padding: EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  _textFormField('Name', tuesdayNightName2),
                                  _buildTimeField('Shift Start', tuesdayNightFrom2, Strings.tuesdayNightFrom2),
                                  _buildTimeField('Shift End', tuesdayNightTo2, Strings.tuesdayNightTo2),
                                ],
                              ),
                            ),
                          ],
                        ) : Container(),
                        rowCountTuesdayNight >= 3 ? Column(
                          children: [
                            SizedBox(height: 10,),
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey)
                              ),
                              padding: EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  _textFormField('Name', tuesdayNightName3),
                                  _buildTimeField('Shift Start', tuesdayNightFrom3, Strings.tuesdayNightFrom3),
                                  _buildTimeField('Shift End', tuesdayNightTo3, Strings.tuesdayNightTo3),
                                ],
                              ),
                            ),
                          ],
                        ) : Container(),
                        rowCountTuesdayNight >= 4 ? Column(
                          children: [
                            SizedBox(height: 10,),
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey)
                              ),
                              padding: EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  _textFormField('Name', tuesdayNightName4),
                                  _buildTimeField('Shift Start', tuesdayNightFrom4, Strings.tuesdayNightFrom4),
                                  _buildTimeField('Shift End', tuesdayNightTo4, Strings.tuesdayNightTo4),
                                ],
                              ),
                            ),
                          ],
                        ) : Container(),
                        rowCountTuesdayNight >= 5 ? Column(
                          children: [
                            SizedBox(height: 10,),
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey)
                              ),
                              padding: EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  _textFormField('Name', tuesdayNightName5),
                                  _buildTimeField('Shift Start', tuesdayNightFrom5, Strings.tuesdayNightFrom5),
                                  _buildTimeField('Shift End', tuesdayNightTo5, Strings.tuesdayNightTo5),
                                ],
                              ),
                            ),
                          ],
                        ) : Container(),
                        SizedBox(height: 10,),
                        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                          rowCountTuesdayNight < 2 ? Container() :
                          SizedBox(width: 150, child: GradientButton('Remove Staff', () => _decreaseRowCountTuesdayNight()),),
                          SizedBox(width: 10,),
                          SizedBox(width: 150, child: GradientButton('Add Staff', () => _increaseRowCountTuesdayNight()),),
                        ],),
                      ],
                    ),
                  ),
                  SizedBox(height: 10,),
                  Text('Wednesday', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold, fontSize: 18),),
                  SizedBox(height: 5,),
                  Container(decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey)
                  ),
                    padding: EdgeInsets.all(10),
                    child: Column(
                      children: [
                        Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                          Text('AM', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold, fontSize: 16),)
                        ],),
                        SizedBox(height: 10,),
                        Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey)
                          ),
                          padding: EdgeInsets.all(10),
                          child: Column(
                            children: [
                              _textFormField('Name', wednesdayAmName1),
                              _buildTimeField('Shift Start', wednesdayAmFrom1, Strings.wednesdayAmFrom1),
                              _buildTimeField('Shift End', wednesdayAmTo1, Strings.wednesdayAmTo1),
                            ],
                          ),
                        ),
                        rowCountWednesdayAm >= 2 ? Column(
                          children: [
                            SizedBox(height: 10,),
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey)
                              ),
                              padding: EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  _textFormField('Name', wednesdayAmName2),
                                  _buildTimeField('Shift Start', wednesdayAmFrom2, Strings.wednesdayAmFrom2),
                                  _buildTimeField('Shift End', wednesdayAmTo2, Strings.wednesdayAmTo2),
                                ],
                              ),
                            ),
                          ],
                        ) : Container(),
                        rowCountWednesdayAm >= 3 ? Column(
                          children: [
                            SizedBox(height: 10,),
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey)
                              ),
                              padding: EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  _textFormField('Name', wednesdayAmName3),
                                  _buildTimeField('Shift Start', wednesdayAmFrom3, Strings.wednesdayAmFrom3),
                                  _buildTimeField('Shift End', wednesdayAmTo3, Strings.wednesdayAmTo3),
                                ],
                              ),
                            ),
                          ],
                        ) : Container(),
                        rowCountWednesdayAm >= 4 ? Column(
                          children: [
                            SizedBox(height: 10,),
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey)
                              ),
                              padding: EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  _textFormField('Name', wednesdayAmName4),
                                  _buildTimeField('Shift Start', wednesdayAmFrom4, Strings.wednesdayAmFrom4),
                                  _buildTimeField('Shift End', wednesdayAmTo4, Strings.wednesdayAmTo4),
                                ],
                              ),
                            ),
                          ],
                        ) : Container(),
                        rowCountWednesdayAm >= 5 ? Column(
                          children: [
                            SizedBox(height: 10,),
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey)
                              ),
                              padding: EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  _textFormField('Name', wednesdayAmName5),
                                  _buildTimeField('Shift Start', wednesdayAmFrom5, Strings.wednesdayAmFrom5),
                                  _buildTimeField('Shift End', wednesdayAmTo5, Strings.wednesdayAmTo5),
                                ],
                              ),
                            ),
                          ],
                        ) : Container(),
                        SizedBox(height: 10,),
                        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                          rowCountWednesdayAm < 2 ? Container() :
                          SizedBox(width: 150, child: GradientButton('Remove Staff', () => _decreaseRowCountWednesdayAm()),),
                          SizedBox(width: 10,),
                          SizedBox(width: 150, child: GradientButton('Add Staff', () => _increaseRowCountWednesdayAm()),),
                        ],),
                        SizedBox(height: 10,),
                        Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                          Text('PM', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold, fontSize: 16),)
                        ],),
                        SizedBox(height: 10,),
                        Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey)
                          ),
                          padding: EdgeInsets.all(10),
                          child: Column(
                            children: [
                              _textFormField('Name', wednesdayPmName1),
                              _buildTimeField('Shift Start', wednesdayPmFrom1, Strings.wednesdayPmFrom1),
                              _buildTimeField('Shift End', wednesdayPmTo1, Strings.wednesdayPmTo1),
                            ],
                          ),
                        ),
                        rowCountWednesdayPm >= 2 ? Column(
                          children: [
                            SizedBox(height: 10,),
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey)
                              ),
                              padding: EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  _textFormField('Name', wednesdayPmName2),
                                  _buildTimeField('Shift Start', wednesdayPmFrom2, Strings.wednesdayPmFrom2),
                                  _buildTimeField('Shift End', wednesdayPmTo2, Strings.wednesdayPmTo2),
                                ],
                              ),
                            ),
                          ],
                        ) : Container(),
                        rowCountWednesdayPm >= 3 ? Column(
                          children: [
                            SizedBox(height: 10,),
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey)
                              ),
                              padding: EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  _textFormField('Name', wednesdayPmName3),
                                  _buildTimeField('Shift Start', wednesdayPmFrom3, Strings.wednesdayPmFrom3),
                                  _buildTimeField('Shift End', wednesdayPmTo3, Strings.wednesdayPmTo3),
                                ],
                              ),
                            ),
                          ],
                        ) : Container(),
                        rowCountWednesdayPm >= 4 ? Column(
                          children: [
                            SizedBox(height: 10,),
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey)
                              ),
                              padding: EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  _textFormField('Name', wednesdayPmName4),
                                  _buildTimeField('Shift Start', wednesdayPmFrom4, Strings.wednesdayPmFrom4),
                                  _buildTimeField('Shift End', wednesdayPmTo4, Strings.wednesdayPmTo4),
                                ],
                              ),
                            ),
                          ],
                        ) : Container(),
                        rowCountWednesdayPm >= 5 ? Column(
                          children: [
                            SizedBox(height: 10,),
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey)
                              ),
                              padding: EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  _textFormField('Name', wednesdayPmName5),
                                  _buildTimeField('Shift Start', wednesdayPmFrom5, Strings.wednesdayPmFrom5),
                                  _buildTimeField('Shift End', wednesdayPmTo5, Strings.wednesdayPmTo5),
                                ],
                              ),
                            ),
                          ],
                        ) : Container(),
                        SizedBox(height: 10,),
                        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                          rowCountWednesdayPm < 2 ? Container() :
                          SizedBox(width: 150, child: GradientButton('Remove Staff', () => _decreaseRowCountWednesdayPm()),),
                          SizedBox(width: 10,),
                          SizedBox(width: 150, child: GradientButton('Add Staff', () => _increaseRowCountWednesdayPm()),),
                        ],),
                        SizedBox(height: 10,),
                        Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                          Text('Night', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold, fontSize: 16),)
                        ],),
                        SizedBox(height: 10,),
                        Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey)
                          ),
                          padding: EdgeInsets.all(10),
                          child: Column(
                            children: [
                              _textFormField('Name', wednesdayNightName1),
                              _buildTimeField('Shift Start', wednesdayNightFrom1, Strings.wednesdayNightFrom1),
                              _buildTimeField('Shift End', wednesdayNightTo1, Strings.wednesdayNightTo1),
                            ],
                          ),
                        ),
                        rowCountWednesdayNight >= 2 ? Column(
                          children: [
                            SizedBox(height: 10,),
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey)
                              ),
                              padding: EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  _textFormField('Name', wednesdayNightName2),
                                  _buildTimeField('Shift Start', wednesdayNightFrom2, Strings.wednesdayNightFrom2),
                                  _buildTimeField('Shift End', wednesdayNightTo2, Strings.wednesdayNightTo2),
                                ],
                              ),
                            ),
                          ],
                        ) : Container(),
                        rowCountWednesdayNight >= 3 ? Column(
                          children: [
                            SizedBox(height: 10,),
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey)
                              ),
                              padding: EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  _textFormField('Name', wednesdayNightName3),
                                  _buildTimeField('Shift Start', wednesdayNightFrom3, Strings.wednesdayNightFrom3),
                                  _buildTimeField('Shift End', wednesdayNightTo3, Strings.wednesdayNightTo3),
                                ],
                              ),
                            ),
                          ],
                        ) : Container(),
                        rowCountWednesdayNight >= 4 ? Column(
                          children: [
                            SizedBox(height: 10,),
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey)
                              ),
                              padding: EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  _textFormField('Name', wednesdayNightName4),
                                  _buildTimeField('Shift Start', wednesdayNightFrom4, Strings.wednesdayNightFrom4),
                                  _buildTimeField('Shift End', wednesdayNightTo4, Strings.wednesdayNightTo4),
                                ],
                              ),
                            ),
                          ],
                        ) : Container(),
                        rowCountWednesdayNight >= 5 ? Column(
                          children: [
                            SizedBox(height: 10,),
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey)
                              ),
                              padding: EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  _textFormField('Name', wednesdayNightName5),
                                  _buildTimeField('Shift Start', wednesdayNightFrom5, Strings.wednesdayNightFrom5),
                                  _buildTimeField('Shift End', wednesdayNightTo5, Strings.wednesdayNightTo5),
                                ],
                              ),
                            ),
                          ],
                        ) : Container(),
                        SizedBox(height: 10,),
                        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                          rowCountWednesdayNight < 2 ? Container() :
                          SizedBox(width: 150, child: GradientButton('Remove Staff', () => _decreaseRowCountWednesdayNight()),),
                          SizedBox(width: 10,),
                          SizedBox(width: 150, child: GradientButton('Add Staff', () => _increaseRowCountWednesdayNight()),),
                        ],),
                      ],
                    ),
                  ),
                  SizedBox(height: 10,),
                  Text('Thursday', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold, fontSize: 18),),
                  SizedBox(height: 5,),
                  Container(decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey)
                  ),
                    padding: EdgeInsets.all(10),
                    child: Column(
                      children: [
                        Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                          Text('AM', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold, fontSize: 16),)
                        ],),
                        SizedBox(height: 10,),
                        Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey)
                          ),
                          padding: EdgeInsets.all(10),
                          child: Column(
                            children: [
                              _textFormField('Name', thursdayAmName1),
                              _buildTimeField('Shift Start', thursdayAmFrom1, Strings.thursdayAmFrom1),
                              _buildTimeField('Shift End', thursdayAmTo1, Strings.thursdayAmTo1),
                            ],
                          ),
                        ),
                        rowCountThursdayAm >= 2 ? Column(
                          children: [
                            SizedBox(height: 10,),
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey)
                              ),
                              padding: EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  _textFormField('Name', thursdayAmName2),
                                  _buildTimeField('Shift Start', thursdayAmFrom2, Strings.thursdayAmFrom2),
                                  _buildTimeField('Shift End', thursdayAmTo2, Strings.thursdayAmTo2),
                                ],
                              ),
                            ),
                          ],
                        ) : Container(),
                        rowCountThursdayAm >= 3 ? Column(
                          children: [
                            SizedBox(height: 10,),
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey)
                              ),
                              padding: EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  _textFormField('Name', thursdayAmName3),
                                  _buildTimeField('Shift Start', thursdayAmFrom3, Strings.thursdayAmFrom3),
                                  _buildTimeField('Shift End', thursdayAmTo3, Strings.thursdayAmTo3),
                                ],
                              ),
                            ),
                          ],
                        ) : Container(),
                        rowCountThursdayAm >= 4 ? Column(
                          children: [
                            SizedBox(height: 10,),
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey)
                              ),
                              padding: EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  _textFormField('Name', thursdayAmName4),
                                  _buildTimeField('Shift Start', thursdayAmFrom4, Strings.thursdayAmFrom4),
                                  _buildTimeField('Shift End', thursdayAmTo4, Strings.thursdayAmTo4),
                                ],
                              ),
                            ),
                          ],
                        ) : Container(),
                        rowCountThursdayAm >= 5 ? Column(
                          children: [
                            SizedBox(height: 10,),
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey)
                              ),
                              padding: EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  _textFormField('Name', thursdayAmName5),
                                  _buildTimeField('Shift Start', thursdayAmFrom5, Strings.thursdayAmFrom5),
                                  _buildTimeField('Shift End', thursdayAmTo5, Strings.thursdayAmTo5),
                                ],
                              ),
                            ),
                          ],
                        ) : Container(),
                        SizedBox(height: 10,),
                        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                          rowCountThursdayAm < 2 ? Container() :
                          SizedBox(width: 150, child: GradientButton('Remove Staff', () => _decreaseRowCountThursdayAm()),),
                          SizedBox(width: 10,),
                          SizedBox(width: 150, child: GradientButton('Add Staff', () => _increaseRowCountThursdayAm()),),
                        ],),
                        SizedBox(height: 10,),
                        Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                          Text('PM', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold, fontSize: 16),)
                        ],),
                        SizedBox(height: 10,),
                        Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey)
                          ),
                          padding: EdgeInsets.all(10),
                          child: Column(
                            children: [
                              _textFormField('Name', thursdayPmName1),
                              _buildTimeField('Shift Start', thursdayPmFrom1, Strings.thursdayPmFrom1),
                              _buildTimeField('Shift End', thursdayPmTo1, Strings.thursdayPmTo1),
                            ],
                          ),
                        ),
                        rowCountThursdayPm >= 2 ? Column(
                          children: [
                            SizedBox(height: 10,),
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey)
                              ),
                              padding: EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  _textFormField('Name', thursdayPmName2),
                                  _buildTimeField('Shift Start', thursdayPmFrom2, Strings.thursdayPmFrom2),
                                  _buildTimeField('Shift End', thursdayPmTo2, Strings.thursdayPmTo2),
                                ],
                              ),
                            ),
                          ],
                        ) : Container(),
                        rowCountThursdayPm >= 3 ? Column(
                          children: [
                            SizedBox(height: 10,),
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey)
                              ),
                              padding: EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  _textFormField('Name', thursdayPmName3),
                                  _buildTimeField('Shift Start', thursdayPmFrom3, Strings.thursdayPmFrom3),
                                  _buildTimeField('Shift End', thursdayPmTo3, Strings.thursdayPmTo3),
                                ],
                              ),
                            ),
                          ],
                        ) : Container(),
                        rowCountThursdayPm >= 4 ? Column(
                          children: [
                            SizedBox(height: 10,),
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey)
                              ),
                              padding: EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  _textFormField('Name', thursdayPmName4),
                                  _buildTimeField('Shift Start', thursdayPmFrom4, Strings.thursdayPmFrom4),
                                  _buildTimeField('Shift End', thursdayPmTo4, Strings.thursdayPmTo4),
                                ],
                              ),
                            ),
                          ],
                        ) : Container(),
                        rowCountThursdayPm >= 5 ? Column(
                          children: [
                            SizedBox(height: 10,),
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey)
                              ),
                              padding: EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  _textFormField('Name', thursdayPmName5),
                                  _buildTimeField('Shift Start', thursdayPmFrom5, Strings.thursdayPmFrom5),
                                  _buildTimeField('Shift End', thursdayPmTo5, Strings.thursdayPmTo5),
                                ],
                              ),
                            ),
                          ],
                        ) : Container(),
                        SizedBox(height: 10,),
                        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                          rowCountThursdayPm < 2 ? Container() :
                          SizedBox(width: 150, child: GradientButton('Remove Staff', () => _decreaseRowCountThursdayPm()),),
                          SizedBox(width: 10,),
                          SizedBox(width: 150, child: GradientButton('Add Staff', () => _increaseRowCountThursdayPm()),),
                        ],),
                        SizedBox(height: 10,),
                        Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                          Text('Night', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold, fontSize: 16),)
                        ],),
                        SizedBox(height: 10,),
                        Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey)
                          ),
                          padding: EdgeInsets.all(10),
                          child: Column(
                            children: [
                              _textFormField('Name', thursdayNightName1),
                              _buildTimeField('Shift Start', thursdayNightFrom1, Strings.thursdayNightFrom1),
                              _buildTimeField('Shift End', thursdayNightTo1, Strings.thursdayNightTo1),
                            ],
                          ),
                        ),
                        rowCountThursdayNight >= 2 ? Column(
                          children: [
                            SizedBox(height: 10,),
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey)
                              ),
                              padding: EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  _textFormField('Name', thursdayNightName2),
                                  _buildTimeField('Shift Start', thursdayNightFrom2, Strings.thursdayNightFrom2),
                                  _buildTimeField('Shift End', thursdayNightTo2, Strings.thursdayNightTo2),
                                ],
                              ),
                            ),
                          ],
                        ) : Container(),
                        rowCountThursdayNight >= 3 ? Column(
                          children: [
                            SizedBox(height: 10,),
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey)
                              ),
                              padding: EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  _textFormField('Name', thursdayNightName3),
                                  _buildTimeField('Shift Start', thursdayNightFrom3, Strings.thursdayNightFrom3),
                                  _buildTimeField('Shift End', thursdayNightTo3, Strings.thursdayNightTo3),
                                ],
                              ),
                            ),
                          ],
                        ) : Container(),
                        rowCountThursdayNight >= 4 ? Column(
                          children: [
                            SizedBox(height: 10,),
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey)
                              ),
                              padding: EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  _textFormField('Name', thursdayNightName4),
                                  _buildTimeField('Shift Start', thursdayNightFrom4, Strings.thursdayNightFrom4),
                                  _buildTimeField('Shift End', thursdayNightTo4, Strings.thursdayNightTo4),
                                ],
                              ),
                            ),
                          ],
                        ) : Container(),
                        rowCountThursdayNight >= 5 ? Column(
                          children: [
                            SizedBox(height: 10,),
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey)
                              ),
                              padding: EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  _textFormField('Name', thursdayNightName5),
                                  _buildTimeField('Shift Start', thursdayNightFrom5, Strings.thursdayNightFrom5),
                                  _buildTimeField('Shift End', thursdayNightTo5, Strings.thursdayNightTo5),
                                ],
                              ),
                            ),
                          ],
                        ) : Container(),
                        SizedBox(height: 10,),
                        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                          rowCountThursdayNight < 2 ? Container() :
                          SizedBox(width: 150, child: GradientButton('Remove Staff', () => _decreaseRowCountThursdayNight()),),
                          SizedBox(width: 10,),
                          SizedBox(width: 150, child: GradientButton('Add Staff', () => _increaseRowCountThursdayNight()),),
                        ],),
                      ],
                    ),
                  ),
                  SizedBox(height: 10,),
                  Text('Friday', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold, fontSize: 18),),
                  SizedBox(height: 5,),
                  Container(decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey)
                  ),
                    padding: EdgeInsets.all(10),
                    child: Column(
                      children: [
                        Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                          Text('AM', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold, fontSize: 16),)
                        ],),
                        SizedBox(height: 10,),
                        Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey)
                          ),
                          padding: EdgeInsets.all(10),
                          child: Column(
                            children: [
                              _textFormField('Name', fridayAmName1),
                              _buildTimeField('Shift Start', fridayAmFrom1, Strings.fridayAmFrom1),
                              _buildTimeField('Shift End', fridayAmTo1, Strings.fridayAmTo1),
                            ],
                          ),
                        ),
                        rowCountFridayAm >= 2 ? Column(
                          children: [
                            SizedBox(height: 10,),
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey)
                              ),
                              padding: EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  _textFormField('Name', fridayAmName2),
                                  _buildTimeField('Shift Start', fridayAmFrom2, Strings.fridayAmFrom2),
                                  _buildTimeField('Shift End', fridayAmTo2, Strings.fridayAmTo2),
                                ],
                              ),
                            ),
                          ],
                        ) : Container(),
                        rowCountFridayAm >= 3 ? Column(
                          children: [
                            SizedBox(height: 10,),
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey)
                              ),
                              padding: EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  _textFormField('Name', fridayAmName3),
                                  _buildTimeField('Shift Start', fridayAmFrom3, Strings.fridayAmFrom3),
                                  _buildTimeField('Shift End', fridayAmTo3, Strings.fridayAmTo3),
                                ],
                              ),
                            ),
                          ],
                        ) : Container(),
                        rowCountFridayAm >= 4 ? Column(
                          children: [
                            SizedBox(height: 10,),
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey)
                              ),
                              padding: EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  _textFormField('Name', fridayAmName4),
                                  _buildTimeField('Shift Start', fridayAmFrom4, Strings.fridayAmFrom4),
                                  _buildTimeField('Shift End', fridayAmTo4, Strings.fridayAmTo4),
                                ],
                              ),
                            ),
                          ],
                        ) : Container(),
                        rowCountFridayAm >= 5 ? Column(
                          children: [
                            SizedBox(height: 10,),
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey)
                              ),
                              padding: EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  _textFormField('Name', fridayAmName5),
                                  _buildTimeField('Shift Start', fridayAmFrom5, Strings.fridayAmFrom5),
                                  _buildTimeField('Shift End', fridayAmTo5, Strings.fridayAmTo5),
                                ],
                              ),
                            ),
                          ],
                        ) : Container(),
                        SizedBox(height: 10,),
                        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                          rowCountFridayAm < 2 ? Container() :
                          SizedBox(width: 150, child: GradientButton('Remove Staff', () => _decreaseRowCountFridayAm()),),
                          SizedBox(width: 10,),
                          SizedBox(width: 150, child: GradientButton('Add Staff', () => _increaseRowCountFridayAm()),),
                        ],),
                        SizedBox(height: 10,),
                        Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                          Text('PM', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold, fontSize: 16),)
                        ],),
                        SizedBox(height: 10,),
                        Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey)
                          ),
                          padding: EdgeInsets.all(10),
                          child: Column(
                            children: [
                              _textFormField('Name', fridayPmName1),
                              _buildTimeField('Shift Start', fridayPmFrom1, Strings.fridayPmFrom1),
                              _buildTimeField('Shift End', fridayPmTo1, Strings.fridayPmTo1),
                            ],
                          ),
                        ),
                        rowCountFridayPm >= 2 ? Column(
                          children: [
                            SizedBox(height: 10,),
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey)
                              ),
                              padding: EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  _textFormField('Name', fridayPmName2),
                                  _buildTimeField('Shift Start', fridayPmFrom2, Strings.fridayPmFrom2),
                                  _buildTimeField('Shift End', fridayPmTo2, Strings.fridayPmTo2),
                                ],
                              ),
                            ),
                          ],
                        ) : Container(),
                        rowCountFridayPm >= 3 ? Column(
                          children: [
                            SizedBox(height: 10,),
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey)
                              ),
                              padding: EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  _textFormField('Name', fridayPmName3),
                                  _buildTimeField('Shift Start', fridayPmFrom3, Strings.fridayPmFrom3),
                                  _buildTimeField('Shift End', fridayPmTo3, Strings.fridayPmTo3),
                                ],
                              ),
                            ),
                          ],
                        ) : Container(),
                        rowCountFridayPm >= 4 ? Column(
                          children: [
                            SizedBox(height: 10,),
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey)
                              ),
                              padding: EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  _textFormField('Name', fridayPmName4),
                                  _buildTimeField('Shift Start', fridayPmFrom4, Strings.fridayPmFrom4),
                                  _buildTimeField('Shift End', fridayPmTo4, Strings.fridayPmTo4),
                                ],
                              ),
                            ),
                          ],
                        ) : Container(),
                        rowCountFridayPm >= 5 ? Column(
                          children: [
                            SizedBox(height: 10,),
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey)
                              ),
                              padding: EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  _textFormField('Name', fridayPmName5),
                                  _buildTimeField('Shift Start', fridayPmFrom5, Strings.fridayPmFrom5),
                                  _buildTimeField('Shift End', fridayPmTo5, Strings.fridayPmTo5),
                                ],
                              ),
                            ),
                          ],
                        ) : Container(),
                        SizedBox(height: 10,),
                        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                          rowCountFridayPm < 2 ? Container() :
                          SizedBox(width: 150, child: GradientButton('Remove Staff', () => _decreaseRowCountFridayPm()),),
                          SizedBox(width: 10,),
                          SizedBox(width: 150, child: GradientButton('Add Staff', () => _increaseRowCountFridayPm()),),
                        ],),
                        SizedBox(height: 10,),
                        Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                          Text('Night', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold, fontSize: 16),)
                        ],),
                        SizedBox(height: 10,),
                        Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey)
                          ),
                          padding: EdgeInsets.all(10),
                          child: Column(
                            children: [
                              _textFormField('Name', fridayNightName1),
                              _buildTimeField('Shift Start', fridayNightFrom1, Strings.fridayNightFrom1),
                              _buildTimeField('Shift End', fridayNightTo1, Strings.fridayNightTo1),
                            ],
                          ),
                        ),
                        rowCountFridayNight >= 2 ? Column(
                          children: [
                            SizedBox(height: 10,),
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey)
                              ),
                              padding: EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  _textFormField('Name', fridayNightName2),
                                  _buildTimeField('Shift Start', fridayNightFrom2, Strings.fridayNightFrom2),
                                  _buildTimeField('Shift End', fridayNightTo2, Strings.fridayNightTo2),
                                ],
                              ),
                            ),
                          ],
                        ) : Container(),
                        rowCountFridayNight >= 3 ? Column(
                          children: [
                            SizedBox(height: 10,),
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey)
                              ),
                              padding: EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  _textFormField('Name', fridayNightName3),
                                  _buildTimeField('Shift Start', fridayNightFrom3, Strings.fridayNightFrom3),
                                  _buildTimeField('Shift End', fridayNightTo3, Strings.fridayNightTo3),
                                ],
                              ),
                            ),
                          ],
                        ) : Container(),
                        rowCountFridayNight >= 4 ? Column(
                          children: [
                            SizedBox(height: 10,),
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey)
                              ),
                              padding: EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  _textFormField('Name', fridayNightName4),
                                  _buildTimeField('Shift Start', fridayNightFrom4, Strings.fridayNightFrom4),
                                  _buildTimeField('Shift End', fridayNightTo4, Strings.fridayNightTo4),
                                ],
                              ),
                            ),
                          ],
                        ) : Container(),
                        rowCountFridayNight >= 5 ? Column(
                          children: [
                            SizedBox(height: 10,),
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey)
                              ),
                              padding: EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  _textFormField('Name', fridayNightName5),
                                  _buildTimeField('Shift Start', fridayNightFrom5, Strings.fridayNightFrom5),
                                  _buildTimeField('Shift End', fridayNightTo5, Strings.fridayNightTo5),
                                ],
                              ),
                            ),
                          ],
                        ) : Container(),
                        SizedBox(height: 10,),
                        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                          rowCountFridayNight < 2 ? Container() :
                          SizedBox(width: 150, child: GradientButton('Remove Staff', () => _decreaseRowCountFridayNight()),),
                          SizedBox(width: 10,),
                          SizedBox(width: 150, child: GradientButton('Add Staff', () => _increaseRowCountFridayNight()),),
                        ],),
                      ],
                    ),
                  ),
                  SizedBox(height: 10,),
                  Text('Saturday', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold, fontSize: 18),),
                  SizedBox(height: 5,),
                  Container(decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey)
                  ),
                    padding: EdgeInsets.all(10),
                    child: Column(
                      children: [
                        Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                          Text('AM', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold, fontSize: 16),)
                        ],),
                        SizedBox(height: 10,),
                        Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey)
                          ),
                          padding: EdgeInsets.all(10),
                          child: Column(
                            children: [
                              _textFormField('Name', saturdayAmName1),
                              _buildTimeField('Shift Start', saturdayAmFrom1, Strings.saturdayAmFrom1),
                              _buildTimeField('Shift End', saturdayAmTo1, Strings.saturdayAmTo1),
                            ],
                          ),
                        ),
                        rowCountSaturdayAm >= 2 ? Column(
                          children: [
                            SizedBox(height: 10,),
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey)
                              ),
                              padding: EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  _textFormField('Name', saturdayAmName2),
                                  _buildTimeField('Shift Start', saturdayAmFrom2, Strings.saturdayAmFrom2),
                                  _buildTimeField('Shift End', saturdayAmTo2, Strings.saturdayAmTo2),
                                ],
                              ),
                            ),
                          ],
                        ) : Container(),
                        rowCountSaturdayAm >= 3 ? Column(
                          children: [
                            SizedBox(height: 10,),
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey)
                              ),
                              padding: EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  _textFormField('Name', saturdayAmName3),
                                  _buildTimeField('Shift Start', saturdayAmFrom3, Strings.saturdayAmFrom3),
                                  _buildTimeField('Shift End', saturdayAmTo3, Strings.saturdayAmTo3),
                                ],
                              ),
                            ),
                          ],
                        ) : Container(),
                        rowCountSaturdayAm >= 4 ? Column(
                          children: [
                            SizedBox(height: 10,),
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey)
                              ),
                              padding: EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  _textFormField('Name', saturdayAmName4),
                                  _buildTimeField('Shift Start', saturdayAmFrom4, Strings.saturdayAmFrom4),
                                  _buildTimeField('Shift End', saturdayAmTo4, Strings.saturdayAmTo4),
                                ],
                              ),
                            ),
                          ],
                        ) : Container(),
                        rowCountSaturdayAm >= 5 ? Column(
                          children: [
                            SizedBox(height: 10,),
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey)
                              ),
                              padding: EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  _textFormField('Name', saturdayAmName5),
                                  _buildTimeField('Shift Start', saturdayAmFrom5, Strings.saturdayAmFrom5),
                                  _buildTimeField('Shift End', saturdayAmTo5, Strings.saturdayAmTo5),
                                ],
                              ),
                            ),
                          ],
                        ) : Container(),
                        SizedBox(height: 10,),
                        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                          rowCountSaturdayAm < 2 ? Container() :
                          SizedBox(width: 150, child: GradientButton('Remove Staff', () => _decreaseRowCountSaturdayAm()),),
                          SizedBox(width: 10,),
                          SizedBox(width: 150, child: GradientButton('Add Staff', () => _increaseRowCountSaturdayAm()),),
                        ],),
                        SizedBox(height: 10,),
                        Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                          Text('PM', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold, fontSize: 16),)
                        ],),
                        SizedBox(height: 10,),
                        Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey)
                          ),
                          padding: EdgeInsets.all(10),
                          child: Column(
                            children: [
                              _textFormField('Name', saturdayPmName1),
                              _buildTimeField('Shift Start', saturdayPmFrom1, Strings.saturdayPmFrom1),
                              _buildTimeField('Shift End', saturdayPmTo1, Strings.saturdayPmTo1),
                            ],
                          ),
                        ),
                        rowCountSaturdayPm >= 2 ? Column(
                          children: [
                            SizedBox(height: 10,),
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey)
                              ),
                              padding: EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  _textFormField('Name', saturdayPmName2),
                                  _buildTimeField('Shift Start', saturdayPmFrom2, Strings.saturdayPmFrom2),
                                  _buildTimeField('Shift End', saturdayPmTo2, Strings.saturdayPmTo2),
                                ],
                              ),
                            ),
                          ],
                        ) : Container(),
                        rowCountSaturdayPm >= 3 ? Column(
                          children: [
                            SizedBox(height: 10,),
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey)
                              ),
                              padding: EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  _textFormField('Name', saturdayPmName3),
                                  _buildTimeField('Shift Start', saturdayPmFrom3, Strings.saturdayPmFrom3),
                                  _buildTimeField('Shift End', saturdayPmTo3, Strings.saturdayPmTo3),
                                ],
                              ),
                            ),
                          ],
                        ) : Container(),
                        rowCountSaturdayPm >= 4 ? Column(
                          children: [
                            SizedBox(height: 10,),
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey)
                              ),
                              padding: EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  _textFormField('Name', saturdayPmName4),
                                  _buildTimeField('Shift Start', saturdayPmFrom4, Strings.saturdayPmFrom4),
                                  _buildTimeField('Shift End', saturdayPmTo4, Strings.saturdayPmTo4),
                                ],
                              ),
                            ),
                          ],
                        ) : Container(),
                        rowCountSaturdayPm >= 5 ? Column(
                          children: [
                            SizedBox(height: 10,),
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey)
                              ),
                              padding: EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  _textFormField('Name', saturdayPmName5),
                                  _buildTimeField('Shift Start', saturdayPmFrom5, Strings.saturdayPmFrom5),
                                  _buildTimeField('Shift End', saturdayPmTo5, Strings.saturdayPmTo5),
                                ],
                              ),
                            ),
                          ],
                        ) : Container(),
                        SizedBox(height: 10,),
                        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                          rowCountSaturdayPm < 2 ? Container() :
                          SizedBox(width: 150, child: GradientButton('Remove Staff', () => _decreaseRowCountSaturdayPm()),),
                          SizedBox(width: 10,),
                          SizedBox(width: 150, child: GradientButton('Add Staff', () => _increaseRowCountSaturdayPm()),),
                        ],),
                        SizedBox(height: 10,),
                        Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                          Text('Night', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold, fontSize: 16),)
                        ],),
                        SizedBox(height: 10,),
                        Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey)
                          ),
                          padding: EdgeInsets.all(10),
                          child: Column(
                            children: [
                              _textFormField('Name', saturdayNightName1),
                              _buildTimeField('Shift Start', saturdayNightFrom1, Strings.saturdayNightFrom1),
                              _buildTimeField('Shift End', saturdayNightTo1, Strings.saturdayNightTo1),
                            ],
                          ),
                        ),
                        rowCountSaturdayNight >= 2 ? Column(
                          children: [
                            SizedBox(height: 10,),
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey)
                              ),
                              padding: EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  _textFormField('Name', saturdayNightName2),
                                  _buildTimeField('Shift Start', saturdayNightFrom2, Strings.saturdayNightFrom2),
                                  _buildTimeField('Shift End', saturdayNightTo2, Strings.saturdayNightTo2),
                                ],
                              ),
                            ),
                          ],
                        ) : Container(),
                        rowCountSaturdayNight >= 3 ? Column(
                          children: [
                            SizedBox(height: 10,),
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey)
                              ),
                              padding: EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  _textFormField('Name', saturdayNightName3),
                                  _buildTimeField('Shift Start', saturdayNightFrom3, Strings.saturdayNightFrom3),
                                  _buildTimeField('Shift End', saturdayNightTo3, Strings.saturdayNightTo3),
                                ],
                              ),
                            ),
                          ],
                        ) : Container(),
                        rowCountSaturdayNight >= 4 ? Column(
                          children: [
                            SizedBox(height: 10,),
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey)
                              ),
                              padding: EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  _textFormField('Name', saturdayNightName4),
                                  _buildTimeField('Shift Start', saturdayNightFrom4, Strings.saturdayNightFrom4),
                                  _buildTimeField('Shift End', saturdayNightTo4, Strings.saturdayNightTo4),
                                ],
                              ),
                            ),
                          ],
                        ) : Container(),
                        rowCountSaturdayNight >= 5 ? Column(
                          children: [
                            SizedBox(height: 10,),
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey)
                              ),
                              padding: EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  _textFormField('Name', saturdayNightName5),
                                  _buildTimeField('Shift Start', saturdayNightFrom5, Strings.saturdayNightFrom5),
                                  _buildTimeField('Shift End', saturdayNightTo5, Strings.saturdayNightTo5),
                                ],
                              ),
                            ),
                          ],
                        ) : Container(),
                        SizedBox(height: 10,),
                        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                          rowCountSaturdayNight < 2 ? Container() :
                          SizedBox(width: 150, child: GradientButton('Remove Staff', () => _decreaseRowCountSaturdayNight()),),
                          SizedBox(width: 10,),
                          SizedBox(width: 150, child: GradientButton('Add Staff', () => _increaseRowCountSaturdayNight()),),
                        ],),
                      ],
                    ),
                  ),
                  SizedBox(height: 10,),
                  Text('Sunday', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold, fontSize: 18),),
                  SizedBox(height: 5,),
                  Container(decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey)
                  ),
                    padding: EdgeInsets.all(10),
                    child: Column(
                      children: [
                        Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                          Text('AM', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold, fontSize: 16),)
                        ],),
                        SizedBox(height: 10,),
                        Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey)
                          ),
                          padding: EdgeInsets.all(10),
                          child: Column(
                            children: [
                              _textFormField('Name', sundayAmName1),
                              _buildTimeField('Shift Start', sundayAmFrom1, Strings.sundayAmFrom1),
                              _buildTimeField('Shift End', sundayAmTo1, Strings.sundayAmTo1),
                            ],
                          ),
                        ),
                        rowCountSundayAm >= 2 ? Column(
                          children: [
                            SizedBox(height: 10,),
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey)
                              ),
                              padding: EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  _textFormField('Name', sundayAmName2),
                                  _buildTimeField('Shift Start', sundayAmFrom2, Strings.sundayAmFrom2),
                                  _buildTimeField('Shift End', sundayAmTo2, Strings.sundayAmTo2),
                                ],
                              ),
                            ),
                          ],
                        ) : Container(),
                        rowCountSundayAm >= 3 ? Column(
                          children: [
                            SizedBox(height: 10,),
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey)
                              ),
                              padding: EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  _textFormField('Name', sundayAmName3),
                                  _buildTimeField('Shift Start', sundayAmFrom3, Strings.sundayAmFrom3),
                                  _buildTimeField('Shift End', sundayAmTo3, Strings.sundayAmTo3),
                                ],
                              ),
                            ),
                          ],
                        ) : Container(),
                        rowCountSundayAm >= 4 ? Column(
                          children: [
                            SizedBox(height: 10,),
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey)
                              ),
                              padding: EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  _textFormField('Name', sundayAmName4),
                                  _buildTimeField('Shift Start', sundayAmFrom4, Strings.sundayAmFrom4),
                                  _buildTimeField('Shift End', sundayAmTo4, Strings.sundayAmTo4),
                                ],
                              ),
                            ),
                          ],
                        ) : Container(),
                        rowCountSundayAm >= 5 ? Column(
                          children: [
                            SizedBox(height: 10,),
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey)
                              ),
                              padding: EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  _textFormField('Name', sundayAmName5),
                                  _buildTimeField('Shift Start', sundayAmFrom5, Strings.sundayAmFrom5),
                                  _buildTimeField('Shift End', sundayAmTo5, Strings.sundayAmTo5),
                                ],
                              ),
                            ),
                          ],
                        ) : Container(),
                        SizedBox(height: 10,),
                        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                          rowCountSundayAm < 2 ? Container() :
                          SizedBox(width: 150, child: GradientButton('Remove Staff', () => _decreaseRowCountSundayAm()),),
                          SizedBox(width: 10,),
                          SizedBox(width: 150, child: GradientButton('Add Staff', () => _increaseRowCountSundayAm()),),
                        ],),
                        SizedBox(height: 10,),
                        Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                          Text('PM', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold, fontSize: 16),)
                        ],),
                        SizedBox(height: 10,),
                        Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey)
                          ),
                          padding: EdgeInsets.all(10),
                          child: Column(
                            children: [
                              _textFormField('Name', sundayPmName1),
                              _buildTimeField('Shift Start', sundayPmFrom1, Strings.sundayPmFrom1),
                              _buildTimeField('Shift End', sundayPmTo1, Strings.sundayPmTo1),
                            ],
                          ),
                        ),
                        rowCountSundayPm >= 2 ? Column(
                          children: [
                            SizedBox(height: 10,),
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey)
                              ),
                              padding: EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  _textFormField('Name', sundayPmName2),
                                  _buildTimeField('Shift Start', sundayPmFrom2, Strings.sundayPmFrom2),
                                  _buildTimeField('Shift End', sundayPmTo2, Strings.sundayPmTo2),
                                ],
                              ),
                            ),
                          ],
                        ) : Container(),
                        rowCountSundayPm >= 3 ? Column(
                          children: [
                            SizedBox(height: 10,),
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey)
                              ),
                              padding: EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  _textFormField('Name', sundayPmName3),
                                  _buildTimeField('Shift Start', sundayPmFrom3, Strings.sundayPmFrom3),
                                  _buildTimeField('Shift End', sundayPmTo3, Strings.sundayPmTo3),
                                ],
                              ),
                            ),
                          ],
                        ) : Container(),
                        rowCountSundayPm >= 4 ? Column(
                          children: [
                            SizedBox(height: 10,),
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey)
                              ),
                              padding: EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  _textFormField('Name', sundayPmName4),
                                  _buildTimeField('Shift Start', sundayPmFrom4, Strings.sundayPmFrom4),
                                  _buildTimeField('Shift End', sundayPmTo4, Strings.sundayPmTo4),
                                ],
                              ),
                            ),
                          ],
                        ) : Container(),
                        rowCountSundayPm >= 5 ? Column(
                          children: [
                            SizedBox(height: 10,),
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey)
                              ),
                              padding: EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  _textFormField('Name', sundayPmName5),
                                  _buildTimeField('Shift Start', sundayPmFrom5, Strings.sundayPmFrom5),
                                  _buildTimeField('Shift End', sundayPmTo5, Strings.sundayPmTo5),
                                ],
                              ),
                            ),
                          ],
                        ) : Container(),
                        SizedBox(height: 10,),
                        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                          rowCountSundayPm < 2 ? Container() :
                          SizedBox(width: 150, child: GradientButton('Remove Staff', () => _decreaseRowCountSundayPm()),),
                          SizedBox(width: 10,),
                          SizedBox(width: 150, child: GradientButton('Add Staff', () => _increaseRowCountSundayPm()),),
                        ],),
                        SizedBox(height: 10,),
                        Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                          Text('Night', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold, fontSize: 16),)
                        ],),
                        SizedBox(height: 10,),
                        Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey)
                          ),
                          padding: EdgeInsets.all(10),
                          child: Column(
                            children: [
                              _textFormField('Name', sundayNightName1),
                              _buildTimeField('Shift Start', sundayNightFrom1, Strings.sundayNightFrom1),
                              _buildTimeField('Shift End', sundayNightTo1, Strings.sundayNightTo1),
                            ],
                          ),
                        ),
                        rowCountSundayNight >= 2 ? Column(
                          children: [
                            SizedBox(height: 10,),
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey)
                              ),
                              padding: EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  _textFormField('Name', sundayNightName2),
                                  _buildTimeField('Shift Start', sundayNightFrom2, Strings.sundayNightFrom2),
                                  _buildTimeField('Shift End', sundayNightTo2, Strings.sundayNightTo2),
                                ],
                              ),
                            ),
                          ],
                        ) : Container(),
                        rowCountSundayNight >= 3 ? Column(
                          children: [
                            SizedBox(height: 10,),
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey)
                              ),
                              padding: EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  _textFormField('Name', sundayNightName3),
                                  _buildTimeField('Shift Start', sundayNightFrom3, Strings.sundayNightFrom3),
                                  _buildTimeField('Shift End', sundayNightTo3, Strings.sundayNightTo3),
                                ],
                              ),
                            ),
                          ],
                        ) : Container(),
                        rowCountSundayNight >= 4 ? Column(
                          children: [
                            SizedBox(height: 10,),
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey)
                              ),
                              padding: EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  _textFormField('Name', sundayNightName4),
                                  _buildTimeField('Shift Start', sundayNightFrom4, Strings.sundayNightFrom4),
                                  _buildTimeField('Shift End', sundayNightTo4, Strings.sundayNightTo4),
                                ],
                              ),
                            ),
                          ],
                        ) : Container(),
                        rowCountSundayNight >= 5 ? Column(
                          children: [
                            SizedBox(height: 10,),
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey)
                              ),
                              padding: EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  _textFormField('Name', sundayNightName5),
                                  _buildTimeField('Shift Start', sundayNightFrom5, Strings.sundayNightFrom5),
                                  _buildTimeField('Shift End', sundayNightTo5, Strings.sundayNightTo5),
                                ],
                              ),
                            ),
                          ],
                        ) : Container(),
                        SizedBox(height: 10,),
                        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                          rowCountSundayNight < 2 ? Container() :
                          SizedBox(width: 150, child: GradientButton('Remove Staff', () => _decreaseRowCountSundayNight()),),
                          SizedBox(width: 10,),
                          SizedBox(width: 150, child: GradientButton('Add Staff', () => _increaseRowCountSundayNight()),),
                        ],),
                      ],
                    ),
                  ),
                  SizedBox(height: 10,),
                ]),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      drawer: widget.edit || widget.saved ? null : SideDrawer(),
      appBar: AppBar(
        flexibleSpace: AppBarGradient(),
        title: FittedBox(fit:BoxFit.fitWidth,
            child: Text('Bed Watch Rota', style: TextStyle(fontWeight: FontWeight.bold),)),
        actions: <Widget>[
          widget.edit || widget.saved ? Container() : IconButton(icon: Icon(Icons.refresh), onPressed: _resetForm),
          widget.saved || widget.edit ? Container() : IconButton(icon: Icon(Icons.watch_later_outlined), onPressed: _saveForLater),
          IconButton(icon: Icon(Icons.send), onPressed: _submitForm),
        ],
      ),
      body: _loadingTemporary
          ? Center(
        child: CircularProgressIndicator(
          valueColor: new AlwaysStoppedAnimation<Color>(bluePurple),
        ),
      )
          : _buildPageContent(context),
    );
  }
}
