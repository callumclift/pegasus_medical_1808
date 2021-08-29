import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pegasus_medical_1808/models/booking_form_model.dart';
import 'package:pegasus_medical_1808/widgets/app_bar_gradient.dart';
import '../../shared/global_config.dart';
import '../../shared/global_functions.dart';
import 'package:provider/provider.dart';
import 'package:pegasus_medical_1808/widgets/gradient_button.dart';
import 'booking_form.dart';
import 'completed_booking_form.dart';



class BookingFormSearchResults extends StatefulWidget {

  final DateTime dateFrom;
  final DateTime dateTo;

  BookingFormSearchResults(this.dateFrom, this.dateTo);


  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _BookingFormSearchResultsState();
  }
}

class _BookingFormSearchResultsState extends State<BookingFormSearchResults> {

  BookingFormModel bookingFormModel;
  bool _loadingMore = false;



  @override
  initState() {
    bookingFormModel = Provider.of<BookingFormModel>(context, listen: false);
    super.initState();
  }


  void loadMore() async {
    setState(() {
      _loadingMore = true;

    });
    await bookingFormModel.searchMoreBookingForms(widget.dateFrom, widget.dateTo);
    setState(() {
      _loadingMore = false;
    });
  }


  void _viewBookingForm(int index){
    bookingFormModel.selectBookingForm(bookingFormModel.allBookingForms[index]['document_id']);
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (BuildContext context) {
      return CompletedBookingForm();
    })).then((_) {
      bookingFormModel.selectBookingForm(null);
    });
  }

  Widget _buildListTile(int index, List<Map<String, dynamic>> bookingForms) {
    final dateFormat = DateFormat("dd/MM/yyyy HH:mm");
    Widget returnedWidget;

    // if (bookingForms.length >= 10 && index == bookingForms.length) {
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
        InkWell(onTap: () => _viewBookingForm(index),
          child: ListTile(
            leading: Icon(Icons.library_books_sharp, color: bluePurple,),
            title: GlobalFunctions.boldTitleText('Job Ref: ', bookingForms[index]['job_ref'], context),
            subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
              GlobalFunctions.boldTitleText('Date: ', dateFormat.format(
                  DateTime.parse(bookingForms[index]['timestamp'])), context),
            ],),
          ),),
        Divider(),
      ],
    );
    //}
    return returnedWidget;

  }


  Widget _buildPageContent(List<Map<String, dynamic>> bookingForms) {

    return ListView.builder(
      itemBuilder: (BuildContext context, int index) {
        return _buildListTile(index, bookingForms);
      },
      itemCount: bookingForms.length >= 10 ? bookingForms.length + 1 : bookingForms.length,
    );
  }


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Consumer<BookingFormModel>(
      builder: (context, model, child) {
        List<Map<String, dynamic>> bookingForms = model.allBookingForms;
        return Scaffold(
            appBar: AppBar(backgroundColor: greyDesign1,
              iconTheme: IconThemeData(color: Colors.white),
              flexibleSpace: AppBarGradient(),
              title: FittedBox(fit:BoxFit.fitWidth,
                  child: Text('Transport Booking List', style: TextStyle(fontWeight: FontWeight.bold),)),
            ),
            body: _buildPageContent(bookingForms));
      },
    );
  }
}


