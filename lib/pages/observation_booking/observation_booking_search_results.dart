import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pegasus_medical_1808/models/observation_booking_model.dart';
import 'package:pegasus_medical_1808/widgets/app_bar_gradient.dart';
import '../../shared/global_config.dart';
import '../../shared/global_functions.dart';
import 'package:provider/provider.dart';
import 'package:pegasus_medical_1808/widgets/gradient_button.dart';
import 'completed_observation_booking.dart';



class ObservationBookingSearchResults extends StatefulWidget {

  final DateTime dateFrom;
  final DateTime dateTo;

  ObservationBookingSearchResults(this.dateFrom, this.dateTo);


  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ObservationBookingSearchResultsState();
  }
}

class _ObservationBookingSearchResultsState extends State<ObservationBookingSearchResults> {

  ObservationBookingModel observationBookingModel;
  bool _loadingMore = false;



  @override
  initState() {
    observationBookingModel = Provider.of<ObservationBookingModel>(context, listen: false);
    super.initState();
  }


  void loadMore() async {
    setState(() {
      _loadingMore = true;

    });
    await observationBookingModel.searchMoreObservationBookings(widget.dateFrom, widget.dateTo);
    setState(() {
      _loadingMore = false;
    });
  }


  void _viewObservationBooking(int index){
    observationBookingModel.selectObservationBooking(observationBookingModel.allObservationBookings[index]['document_id']);
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (BuildContext context) {
      return CompletedObservationBooking();
    })).then((_) {
      observationBookingModel.selectObservationBooking(null);
    });
  }

  Widget _buildListTile(int index, List<Map<String, dynamic>> observationBookings) {
    final dateFormat = DateFormat("dd/MM/yyyy HH:mm");
    Widget returnedWidget;

    // if (observationBookings.length >= 10 && index == observationBookings.length) {
    //   if (_loadingMore) {
    //     returnedWidget = Center(child: Center(child: CircularProgressIndicator(
    //       valueColor: AlwaysStoppedAnimation<Color>(
    //           bluePurple),
    //     ),),);
    //   } else {
    //     returnedWidget = Container(
    //       child: Center(child: Container(width: MediaQuery.of(context).size.width * 0.5, child: GradientButton('Load More', loadMore),),),
    //     );
    //   }
    // } else {
    returnedWidget = Column(
      children: <Widget>[
        InkWell(onTap: () => _viewObservationBooking(index),
          child: ListTile(
            leading: Icon(Icons.library_books_sharp, color: bluePurple,),
            title: GlobalFunctions.boldTitleText('Job Ref: ', observationBookings[index]['job_ref'], context),
            subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
              GlobalFunctions.boldTitleText('Date: ', dateFormat.format(
                  DateTime.parse(observationBookings[index]['timestamp'])), context),
            ],),
          ),),
        Divider(),
      ],
    );
    //}
    return returnedWidget;

  }


  Widget _buildPageContent(List<Map<String, dynamic>> observationBookings) {

    return ListView.builder(
      itemBuilder: (BuildContext context, int index) {
        return _buildListTile(index, observationBookings);
      },
      itemCount: observationBookings.length >= 10 ? observationBookings.length + 1 : observationBookings.length,
    );
  }


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Consumer<ObservationBookingModel>(
      builder: (context, model, child) {
        List<Map<String, dynamic>> observationBookings = model.allObservationBookings;
        return Scaffold(
            appBar: AppBar(backgroundColor: greyDesign1,
              iconTheme: IconThemeData(color: Colors.white),
              flexibleSpace: AppBarGradient(),
              title: FittedBox(fit:BoxFit.fitWidth,
                  child: Text('Observation Booking List', style: TextStyle(fontWeight: FontWeight.bold),)),
            ),
            body: _buildPageContent(observationBookings));
      },
    );
  }
}


