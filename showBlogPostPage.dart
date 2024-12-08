import 'package:demopatient/utilities/decoration.dart';
import 'package:demopatient/widgets/appbarsWidget.dart';
import 'package:demopatient/widgets/errorWidget.dart';
import 'package:demopatient/widgets/imageWidget.dart';
import 'package:demopatient/widgets/loadingIndicator.dart';
import 'package:demopatient/widgets/noDataWidget.dart';
import 'package:flutter/material.dart';
import 'package:demopatient/Service/blogPostService.dart';
import 'package:demopatient/Screen/blogPost/showBlogPostPage.dart';
import 'package:get/get.dart';
import 'package:html/parser.dart';
import 'package:flutter_html/flutter_html.dart';


class ShowBlogPostPage extends StatefulWidget {
  final body;
  final title;
  final thumbUrl;

  ShowBlogPostPage({this.body, this.title, this.thumbUrl});
  @override
  _ShowBlogPostPageState createState() => _ShowBlogPostPageState();
}

class _ShowBlogPostPageState extends State<ShowBlogPostPage> {
  
  ScrollController _scrollController = new ScrollController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(child: _buildContent()),
    );
  }

  Widget _buildContent() {
    return Stack(
      //overflow: Overflow.visible,
      children: <Widget>[
        CAppBarWidget(title: 'Health Blog'.tr),
        Positioned(
          top: 80,
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            height: MediaQuery.of(context).size.height,
            decoration: IBoxDecoration.upperBoxDecoration(),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  imageBox(widget.thumbUrl),
                  // ImageBoxFillWidget(imageUrl: widget.thumbUrl),
                  const SizedBox(height: 5,),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Text(widget.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22
                      ),),
                  ),

                  // const SizedBox(height: 10,),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Html(data: widget.body),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }


  Widget imageBox(String imageUrl) {
    return Container(
        width: MediaQuery.of(context).size.width,
        height: 250,
        child: ImageBoxFillWidget(imageUrl: imageUrl));
  }


}



// import 'dart:convert';
// import 'package:demopatient/utilities/color.dart';
// import 'package:demopatient/widgets/imageWidget.dart';
// import 'package:demopatient/widgets/loadingIndicator.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// // import 'package:flutter_quill/flutter_quill.dart';
// // import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
// import 'package:http/http.dart' as http;
// import 'package:light_html_editor/editor.dart';
// import 'package:light_html_editor/html_editor_controller.dart';
// import 'package:light_html_editor/placeholder.dart';
//
// import '../../utilities/style.dart';
//
// class ShowBlogPostPage extends StatefulWidget {
//   final body;
//   final title;
//   final thumbUrl;
//
//   ShowBlogPostPage({this.body, this.title, this.thumbUrl});
//   @override
//   _ShowBlogPostPageState createState() => _ShowBlogPostPageState();
// }
//
// class _ShowBlogPostPageState extends State<ShowBlogPostPage> {
//
//   bool _isLoading = false;
//   // QuillController _controller = QuillController.basic();
//
//   HtmlEditorController _controller = HtmlEditorController();
//   final FocusNode _focusNode = FocusNode();
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     // _getDoc();
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: _isLoading
//             ? AppBar(
//                 title: Text(
//                   widget.title,
//                   style: kAppbarTitleStyle,
//                 ),
//                 backgroundColor: appBarColor,
//               )
//             : null,
//         body: Column(
//           children: [
//             _isLoading?  LoadingIndicatorWidget():
//             Container(
//               height: 280,
//               decoration: BoxDecoration(
//                 color: appBarColor,
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Column(
//                 children: [
//                   Text(widget.body),
//                 ],
//               ),
//             ),
//           ],
//         )
//         // _isLoading
//         //     ? LoadingIndicatorWidget()
//         //     : CustomScrollView(
//         //         slivers: <Widget>[
//         //           SliverAppBar(
//         //               backgroundColor: appBarColor,
//         //               pinned: false,
//         //               snap: false,
//         //               floating: false,
//         //               expandedHeight: 250.0,
//         //               flexibleSpace: FlexibleSpaceBar(
//         //                   background:
//         //                       ImageBoxFillWidget(imageUrl: widget.thumbUrl))),
//         //           SliverToBoxAdapter(
//         //               child: QuillEditor(
//         //                 embedBuilders:FlutterQuillEmbeds.builders(),
//         //                   controller: _controller,
//         //                   scrollController: ScrollController(),
//         //                   scrollable: true,
//         //                   focusNode: _focusNode,
//         //                   autoFocus: true,
//         //                   readOnly: true,
//         //                   expands: false,
//         //                   showCursor: false,
//         //                   padding: EdgeInsets.all(8))),
//         //         ],
//         //       )
//
//         );
//   }
//
//   void _getDoc() async {
//     //print(widget.blogPost.body);
//     setState(() {
//       _isLoading = true;
//     });
//     final _viewUrl = widget.body;
//     final response = await http.get(Uri.parse(_viewUrl));
//     if (response.statusCode == 200) {
//       var myJSON = jsonDecode(response.body);
//       setState(() {
//         _controller = HtmlEditorController(
//
//         );
//         // _controller = QuillController(
//         //     document: Document.fromJson(myJSON),
//         //     selection: TextSelection.collapsed(offset: 0));
//         _isLoading = false;
//       });
//     }
//     // print("Data ${res[0].body}");
//   }
// }
