//best final
import 'dart:async';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('DraggableScrollableSheet Example')),
        body: DraggableScrollableSheetExample(),
      ),
    );
  }
}

class DraggableScrollableSheetExample extends StatefulWidget {
  @override
  _DraggableScrollableSheetExampleState createState() =>
      _DraggableScrollableSheetExampleState();
}

class _DraggableScrollableSheetExampleState
    extends State<DraggableScrollableSheetExample> {
  final DraggableScrollableController _controller =
  DraggableScrollableController();
  final ScrollController _scrollController = ScrollController();
  bool _isDragging = false;
  double previousValue = 0.3;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
  }

  void _onScrollStart() {
    print("Scrolling started...");
    setState(() {
      _isDragging = true;
    });

    // Unfocus the TextFormField when dragging starts
    FocusScope.of(context).unfocus();

    // Cancel any ongoing debounce if scroll starts again
    _debounce?.cancel();
  }

  void _onScrollEnd() {
    print("Scrolling ended...");
    setState(() {
      _isDragging = false;
    });

    // Debounce logic: Schedule the adjustment after a short delay
    _debounce = Timer(Duration(milliseconds: 100), () {
      setState(() {
        if (_controller.size < 0.6) {
          previousValue = 0.3;
        } else {
          previousValue = 1.0;
        }

        _controller.animateTo(
          previousValue,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          color: Colors.blue,
        ),
        NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification notification) {
            if (notification is ScrollStartNotification) {
              _onScrollStart();
            } else if (notification is ScrollEndNotification) {
              _onScrollEnd();
            }
            return true;
          },
          child: DraggableScrollableSheet(
            controller: _controller,
            initialChildSize: previousValue,
            minChildSize: 0.3,
            maxChildSize: 1.0,
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                color: Colors.white,
                child: Column(
                  children: [
                    GestureDetector(
                      onPanUpdate: (details) {
                        // Adjust the size of the draggable sheet while dragging
                        _onScrollStart();
                        _controller.jumpTo(
                          _controller.size - details.delta.dy / 500,
                        );
                      },
                      onPanEnd: (details) {
                        // Trigger scroll end logic when dragging ends
                        _onScrollEnd();
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Enter text',
                          ),
                          onTap: (){
                            //_debounce = Timer(Duration(milliseconds: 100), () {
                            setState(() {
                              previousValue = 1.0;
                              _controller.animateTo(
                                previousValue,
                                duration: Duration(milliseconds: 300),
                                curve: Curves.easeOut,
                              );
                            });
                            //});
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 20,),
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: 25,
                        itemBuilder: (BuildContext context, int index) {
                          return ListTile(title: Text('Item $index'));
                        },
                      ),
                    ),
                    GestureDetector(
                      onPanUpdate: (details) {
                        _controller.jumpTo(
                          _controller.size - details.delta.dy / 500,
                        );
                      },
                      onPanEnd: (details) {
                        // Trigger scroll end logic when dragging ends
                        _onScrollEnd();
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          onPressed: () {},
                          child: Text("Submit"),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController.dispose();
    _controller.dispose();
    super.dispose();
  }
}





















////final
// import 'dart:async';
// import 'package:flutter/material.dart';
//
// void main() => runApp(MyApp());
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(title: Text('DraggableScrollableSheet Example')),
//         body: DraggableScrollableSheetExample(),
//       ),
//     );
//   }
// }
//
// class DraggableScrollableSheetExample extends StatefulWidget {
//   @override
//   _DraggableScrollableSheetExampleState createState() =>
//       _DraggableScrollableSheetExampleState();
// }
//
// class _DraggableScrollableSheetExampleState
//     extends State<DraggableScrollableSheetExample> {
//   final DraggableScrollableController _controller =
//   DraggableScrollableController();
//   final ScrollController _scrollController = ScrollController();
//   bool _isDragging = false;
//   double previousValue = 0.3;
//   Timer? _debounce;
//
//   @override
//   void initState() {
//     super.initState();
//   }
//
//   void _onScrollStart() {
//     print("Scrolling started...");
//     setState(() {
//       _isDragging = true;
//     });
//
//     // Unfocus the TextFormField when dragging starts
//     FocusScope.of(context).unfocus();
//
//     // Cancel any ongoing debounce if scroll starts again
//     _debounce?.cancel();
//   }
//
//   void _onScrollEnd() {
//     print("Scrolling ended...");
//     setState(() {
//       _isDragging = false;
//     });
//
//     // Debounce logic: Schedule the adjustment after a short delay
//     _debounce = Timer(Duration(milliseconds: 100), () {
//       setState(() {
//         if (_controller.size < 0.6) {
//           previousValue = 0.3;
//         } else {
//           previousValue = 1.0;
//         }
//
//         _controller.animateTo(
//           previousValue,
//           duration: Duration(milliseconds: 300),
//           curve: Curves.easeOut,
//         );
//       });
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: <Widget>[
//         Container(
//           color: Colors.blue,
//         ),
//         NotificationListener<ScrollNotification>(
//           onNotification: (ScrollNotification notification) {
//             if (notification is ScrollStartNotification) {
//               _onScrollStart();
//             } else if (notification is ScrollEndNotification) {
//               _onScrollEnd();
//             }
//             return true;
//           },
//           child: DraggableScrollableSheet(
//             controller: _controller,
//             initialChildSize: previousValue,
//             minChildSize: 0.3,
//             maxChildSize: 1.0,
//             builder: (BuildContext context, ScrollController scrollController) {
//               return Container(
//                 color: Colors.white,
//                 child: Column(
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: TextFormField(
//                         decoration: InputDecoration(
//                           border: OutlineInputBorder(),
//                           labelText: 'Enter text',
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: 20,),
//                     Expanded(
//                       child: ListView.builder(
//                         controller: scrollController,
//                         itemCount: 25,
//                         itemBuilder: (BuildContext context, int index) {
//                           return ListTile(title: Text('Item $index'));
//                         },
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: ElevatedButton(
//                         onPressed: () {},
//                         child: Text("Submit"),
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }
//
//   @override
//   void dispose() {
//     _debounce?.cancel();
//     _scrollController.dispose();
//     _controller.dispose();
//     super.dispose();
//   }
// }





























// import 'dart:async'; // Import this for debounce functionality
// import 'package:flutter/material.dart';
//
// void main() => runApp(MyApp());
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(title: Text('DraggableScrollableSheet Example')),
//         body: DraggableScrollableSheetExample(),
//       ),
//     );
//   }
// }
//
// class DraggableScrollableSheetExample extends StatefulWidget {
//   @override
//   _DraggableScrollableSheetExampleState createState() =>
//       _DraggableScrollableSheetExampleState();
// }
//
// class _DraggableScrollableSheetExampleState
//     extends State<DraggableScrollableSheetExample> {
//   final DraggableScrollableController _controller =
//   DraggableScrollableController();
//   final ScrollController _scrollController = ScrollController();
//   bool _isDragging = false;
//   double previousValue = 0.3;
//   Timer? _debounce; // Timer for debouncing scroll end events
//
//   @override
//   void initState() {
//     super.initState();
//   }
//
//   void _onScrollStart() {
//     print("Scrolling started...");
//     setState(() {
//       _isDragging = true;
//     });
//
//     // Cancel any ongoing debounce if scroll starts again
//     _debounce?.cancel();
//   }
//
//   void _onScrollEnd() {
//     print("Scrolling ended...");
//     setState(() {
//       _isDragging = false;
//     });
//
//     // Debounce logic: Schedule the adjustment after a short delay
//     _debounce = Timer(Duration(milliseconds: 100), () {
//       setState(() {
//         // Adjust initialChildSize or any other logic based on the current size
//         if (_controller.size < 0.6) {
//           previousValue = 0.3;
//         } else {
//           previousValue = 1.0;
//         }
//
//         _controller.animateTo(
//           previousValue,
//           duration: Duration(milliseconds: 300),
//           curve: Curves.easeOut,
//         );
//       });
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: <Widget>[
//         Container(
//           color: Colors.blue,
//         ),
//         NotificationListener<ScrollNotification>(
//           onNotification: (ScrollNotification notification) {
//             if (notification is ScrollStartNotification) {
//               _onScrollStart();
//             } else if (notification is ScrollEndNotification) {
//               _onScrollEnd();
//             }
//             return true;
//           },
//           child: DraggableScrollableSheet(
//             controller: _controller,
//             initialChildSize: previousValue, // initial size of the sheet
//             minChildSize: 0.3, // minimum size when dragged down
//             maxChildSize: 1.0, // maximum size when dragged up
//             builder: (BuildContext context, ScrollController scrollController) {
//               return Container(
//                 color: Colors.white,
//                 child: Column(
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: TextFormField(
//                         decoration: InputDecoration(
//                           border: OutlineInputBorder(),
//                           labelText: 'Enter text',
//                         ),
//                       ),
//                     ),
//                     Expanded(
//                       child: ListView.builder(
//                         controller: scrollController,
//                         itemCount: 25,
//                         itemBuilder: (BuildContext context, int index) {
//                           return ListTile(title: Text('Item $index'));
//                         },
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: ElevatedButton(
//                         onPressed: () {},
//                         child: Text("Submit"),
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }
//
//   @override
//   void dispose() {
//     _debounce?.cancel(); // Clean up the debounce timer
//     _scrollController.dispose();
//     _controller.dispose();
//     super.dispose();
//   }
// }
//
//








// import 'package:flutter/material.dart';
//
// void main() => runApp(MyApp());
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(title: Text('DraggableScrollableSheet Example')),
//         body: DraggableScrollableSheetExample(),
//       ),
//     );
//   }
// }
//
// class DraggableScrollableSheetExample extends StatefulWidget {
//   @override
//   _DraggableScrollableSheetExampleState createState() =>
//       _DraggableScrollableSheetExampleState();
// }
//
// class _DraggableScrollableSheetExampleState
//     extends State<DraggableScrollableSheetExample> {
//   final DraggableScrollableController _controller =
//   DraggableScrollableController();
//   final ScrollController _scrollController = ScrollController();
//   bool _isDragging = false;
//   double previousValue = 0.3;
//   double initialChildSize = 0.3;
//
//   @override
//   void initState() {
//     super.initState();
//
//     _scrollController.addListener(() {
//       print("_scrollController.position.isScrollingNotifier.value.....${_scrollController.position.isScrollingNotifier.value}");
//       if (_scrollController.position.isScrollingNotifier.value && !_isDragging) {
//         // The sheet is being dragged
//         setState(() {
//           _isDragging = true;
//         });
//         print("Dragging started...");
//       }
//
//       if (!_scrollController.position.isScrollingNotifier.value && _isDragging) {
//         // The sheet has stopped dragging
//         setState(() {
//           _isDragging = false;
//         });
//         print("Dragging ended...");
//        // _onDragEnd();
//       }
//     });
//
//     _controller.addListener(() {
//       final size = _controller.size;
//       print("size...$size");
//
//       // if (previousValue == 0.3) {
//       //   if (double.parse(size.toStringAsFixed(1)) > 0.4) {
//       //     setState(() {
//       //       previousValue = 1;
//       //     });
//       //     _controller.animateTo(
//       //       previousValue,
//       //       duration: Duration(milliseconds: 300),
//       //       curve: Curves.easeOut,
//       //     );
//       //   }
//       // } else if (previousValue == 1) {
//       //   if (double.parse(size.toStringAsFixed(1)) < 0.9) {
//       //     setState(() {
//       //       previousValue = 0.3;
//       //     });
//       //     _controller.animateTo(
//       //       previousValue,
//       //       duration: Duration(milliseconds: 300),
//       //       curve: Curves.easeOut,
//       //     );
//       //   }
//       // }
//     });
//   }
//
//   void _onDragEnd() {
//     print("Handling drag end...");
//     if (_controller.size < 1) {
//       _controller.animateTo(
//         0.3,
//         duration: Duration(milliseconds: 300),
//         curve: Curves.easeOut,
//       );
//     } else if (_controller.size > 0.3) {
//       _controller.animateTo(
//         1.0,
//         duration: Duration(milliseconds: 300),
//         curve: Curves.easeOut,
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: <Widget>[
//         Container(
//           color: Colors.blue,
//         ),
//         DraggableScrollableSheet(
//           controller: _controller,
//           initialChildSize: previousValue, // initial size of the sheet
//           minChildSize: 0.3, // minimum size when dragged down
//           maxChildSize: 1.0, // maximum size when dragged up
//           builder: (BuildContext context, ScrollController scrollController) {
//             return NotificationListener<ScrollNotification>(
//
//               onNotification: (scrollNotification) {
//                 if (scrollNotification is ScrollUpdateNotification) {
//                   scrollController.jumpTo(scrollNotification.metrics.pixels);
//                   print("scrolll..true");
//                 }
//                 print("scrolll..false===${scrollNotification}");
//                 return true;
//               },
//               child: Container(
//                 color: Colors.white,
//                 child: Column(
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: SingleChildScrollView(
//                         controller: scrollController,
//                         child: TextFormField(
//                           decoration: InputDecoration(
//                             border: OutlineInputBorder(),
//                             labelText: 'Enter text',
//                           ),
//                         ),
//                       ),
//                     ),
//                     Expanded(
//                       child: ListView.builder(
//                         controller: scrollController,
//                         itemCount: 25,
//                         itemBuilder: (BuildContext context, int index) {
//                           return ListTile(title: Text('Item $index'));
//                         },
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: ElevatedButton(
//                         onPressed: () {},
//                         child: Text("Submit"),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         ),
//       ],
//     );
//   }
// }


















// import 'package:flutter/material.dart';
//
// void main() => runApp(MyApp());
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(title: Text('DraggableScrollableSheet Example')),
//         body: DraggableScrollableSheetExample(),
//       ),
//     );
//   }
// }
//
// class DraggableScrollableSheetExample extends StatefulWidget {
//   @override
//   _DraggableScrollableSheetExampleState createState() => _DraggableScrollableSheetExampleState();
// }
//
// class _DraggableScrollableSheetExampleState extends State<DraggableScrollableSheetExample> {
//   final DraggableScrollableController _controller = DraggableScrollableController();
//   bool _isDragging = false;
//   double previousValue = 0.3;
//   double initialChildSize = 0.3;
//
//   void _onDragEnd() {
//     print("inDraggaing...");
//     if (_isDragging) {
//       print("false....");
//       print("size.....${_controller.size}");
//       _isDragging = false;
//       if (_controller.size < 1){
//         _controller.animateTo(
//           0.3,
//           duration: Duration(milliseconds: 300),
//           curve: Curves.easeOut,
//         );
//       }else if (_controller.size > 0.3) {
//         _controller.animateTo(
//           1.0,
//           duration: Duration(milliseconds: 300),
//           curve: Curves.easeOut,
//         );
//       }
//     }
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     _controller.addListener(() {
//
//         // final size = _controller.size;
//         // print("size...$size");
//         // if (!_isDragging) {
//         //   if (size > 0.3) {
//         //     // Full screen
//         //     _controller.jumpTo(1.0);
//         //   } else if (size < 1.0) {
//         //     // Minimum size
//         //     _controller.jumpTo(0.3);
//         //   }
//         // }
//
//       final size = _controller.size;
//       print("size...$size");
//       if(previousValue == 0.3){
//         if (double.parse(size.toStringAsFixed(1)) > 0.4) {
//         // Minimum size
//         // _controller.jumpTo(0.3);
//           setState(() {
//             previousValue = 1;
//           });
//         _controller.animateTo(
//           previousValue,
//           duration: Duration(milliseconds: 300),
//           curve: Curves.easeOut,
//         );
//       }
//       }else if(previousValue == 1){
//         if (double.parse(size.toStringAsFixed(1)) < 0.9) {
//           // Minimum size
//           // _controller.jumpTo(0.3);
//           setState(() {
//             previousValue = 0.3;
//           });
//           _controller.animateTo(
//             previousValue,
//             duration: Duration(milliseconds: 300),
//             curve: Curves.easeOut,
//           );
//         }
//       }
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: <Widget>[
//         Container(
//           color: Colors.blue,
//         ),
//         DraggableScrollableSheet(
//           controller: _controller,
//           initialChildSize: previousValue, // initial size of the sheet
//           minChildSize: 0.3, // minimum size when dragged down
//           maxChildSize: 1.0, // maximum size when dragged up
//           builder: (BuildContext context, ScrollController scrollController) {
//             return Container(
//               color: Colors.white,
//               child: Column(
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: TextFormField(
//                       decoration: InputDecoration(
//                         border: OutlineInputBorder(),
//                         labelText: 'Enter text',
//                       ),
//                     ),
//                   ),
//                   Expanded(
//                     child: ListView.builder(
//                       controller: scrollController,
//                       itemCount: 25,
//                       itemBuilder: (BuildContext context, int index) {
//                         return ListTile(title: Text('Item $index'));
//                       },
//                     ),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: ElevatedButton(
//                       onPressed: () {},
//                       child: Text("Submit"),
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           },
//         ),
//       ],
//     );
//   }
// }