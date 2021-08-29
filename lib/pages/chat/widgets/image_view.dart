import 'package:flutter/material.dart';
import 'package:pegasus_medical_1808/widgets/app_bar_gradient.dart';
import 'package:photo_view/photo_view.dart';

class ImageView extends StatefulWidget {

  ImageView({Key key, this.image}) : super(key: key);

  final String image;


  @override
  _ImageViewState createState() => _ImageViewState();
}

class _ImageViewState extends State<ImageView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        flexibleSpace: AppBarGradient(),
        title: FittedBox(fit:BoxFit.fitWidth,
            child: Text('Image', style: TextStyle(fontWeight: FontWeight.bold),)),
      ),
      body: Container(
          child: PhotoView(
            minScale: PhotoViewComputedScale.contained,
            initialScale: PhotoViewComputedScale.contained,
            imageProvider: NetworkImage(widget.image),
          )
      ),
    );
  }
}
