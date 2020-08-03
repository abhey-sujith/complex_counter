import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:just_a_counter/card.dart';
import "package:just_a_counter/db.dart";


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'just a counter',
      theme: ThemeData(
        //primarySwatch: Colors.blue,
        canvasColor: Colors.white12,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Simple Counter Flutter'),
    );
  }
}



class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  final titleController = TextEditingController();
  final countController = TextEditingController();
  List<CounterDetails> countDetails=[];
    //CounterDetails(id:DateTime.now().toString(),title: 'first counter',count: 0,),
    //CounterDetails(id:DateTime.now().toString(),title: 'second counter',count: 0,),
    //CounterDetails(id:DateTime.now().toString(),title: 'third counter',count: 0,),


  void _addNewCounter(String ti,int co){

    if (ti==null || co<0){
      return;
    }
    final newcx=CounterDetails(
      title: ti,
      count: co,
      id: DateTime.now().toString(),
    );
    setState(() {
      countDetails.add(newcx);
    });

    DBHelper.insert('countflutter',{
      'id': newcx.id,
      'title': newcx.title,
      'count':newcx.count,
    });

    Navigator.of(context).pop();
  }

  Future<void> fetchAndSetPlaces() async {
    final dataList=await DBHelper.getData('countflutter');
    countDetails=dataList.map((item)=>CounterDetails(id: item['id'],count: item['count'],title: item['title'])).toList();
  }

  void _startAddNewTransaction(BuildContext ctx){
    showModalBottomSheet(context: ctx, builder: (_) {
      return GestureDetector(
        onTap: () {},
        behavior: HitTestBehavior.opaque,
        child: Card(
          color: Colors.black54,
          elevation: 5,
          child: Container(
            padding: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: InputDecoration(labelText: 'Title',filled: true,focusColor: Colors.pink,
                      fillColor: Colors.white54,),
                    controller: titleController,
                    keyboardType: TextInputType.text,

                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: InputDecoration(labelText: 'Count',filled: true,
                      fillColor: Colors.white54,),
                    controller: countController,
                    keyboardType: TextInputType.number,
                    // onChanged: (val) => amountInput = val,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: FlatButton(
                    child: Text('Add Counter',style: TextStyle(fontSize: 20),),
                    textColor: Colors.purple,
                    onPressed: () {
                      
                      _addNewCounter(titleController.text,int.parse(countController.text));
                      titleController.clear();
                      countController.clear();
                    }
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
    );
  }

  Future<bool> showReview(context,co) async{
    await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return DynamicDialog(co);
        }).then((value) {
          setState(() {
            co.count=value;
          });
          DBHelper.insert('countflutter',{
            'id': co.id,
            'title': co.title,
            'count':value,
          });
    });

  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.black54,
      ),
      body:
        FutureBuilder(
          future: fetchAndSetPlaces(),
          builder:(ctx,snapshot) =>snapshot.connectionState== ConnectionState.waiting? Center(child:CircularProgressIndicator()) :
          countDetails.isEmpty? Center(child:Text('Add new Counter',style: TextStyle(color: Colors.white),),) : GridView(
            children: countDetails.map((co) {
              return InkWell(
                onTap: () => showReview(context,co),
                splashColor: Colors.black,
                borderRadius: BorderRadius.circular(10),
                child: Dismissible(
                  key: ValueKey(co.id),
                  background: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.red,
                    ),

                    child: Icon(
                      Icons.delete,
                      color: Colors.white,
                      size: 40,
                    ),
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.only(right: 20,),
                  ),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    setState(() {
                      countDetails.removeWhere((item) {

                        return item.id == co.id;
                      });
                    },
                    );
                    DBHelper.deleteData('countflutter',co.id);

                  },
                  child: Container(
                    margin: EdgeInsets.all(5),
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      //border: Border.all(),
                      color: Colors.white30,
                      gradient: LinearGradient(
                        colors: [Colors.white30, Colors.white10],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),

                         child: Column(
                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                           children: <Widget>[
                                 Flexible(
                                   //alignment: Alignment.center,
                                    //fit: BoxFit.contain,
                                   child: Text(
                                     co.title,
                                     textAlign: TextAlign.center,
                                     overflow: TextOverflow.ellipsis,
                                     maxLines: 2,
                                     style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold,color: Colors.white70,),
                                   ),
                                 ),
                             Text(
                               co.count.toString(),
                               style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold,color: Colors.white,),
                             ),
                           ],
                         ),
                  ),
                ),
              );
            }
            ).toList(),
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 200,
                  childAspectRatio:   3/2,
                  crossAxisSpacing:   10,
                  mainAxisSpacing:    10,
              ),
          ),
        ),

      floatingActionButton: FloatingActionButton(
        onPressed: () =>_startAddNewTransaction(context),
        tooltip: 'Increment',
        child: Icon(Icons.add),
        backgroundColor: Colors.white30,
      ),
    );
  }
}




class DynamicDialog extends StatefulWidget {
  DynamicDialog(this.co);

  CounterDetails co;

  @override
  _DynamicDialogState createState() => _DynamicDialogState();
}

class _DynamicDialogState extends State<DynamicDialog> {
  int _count;
  String _title;

  @override
  void initState() {
    _count = widget.co.count;
    _title = widget.co.title;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: ()  async => false,
      child: Dialog(

        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0)),
        child: Container(
          height: 350.0,
          width: 200.0,
          decoration:
          BoxDecoration(borderRadius: BorderRadius.circular(20.0)),
          child: Column(
            children: <Widget>[
              Container(
                height: 200.0,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10.0),
                    topRight: Radius.circular(10.0),
                  ),
                  color: Colors.black87,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth: 20,
                          maxWidth: double.infinity,
                          minHeight: 10.0,
                          maxHeight: 150,
                        ),
                        child: AutoSizeText(
                          _title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.white70,),
                        ),
                      ),
                    ),
                    Text(
                      _count.toString(),
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,),
                    ),
                  ],
                ),
              ),

              // SizedBox(height: 15.0,),
              Container(
                  height: 150,
                  color: Colors.black54,
                  padding: EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        IconButton(
                          icon: Icon(Icons.remove_circle_outline),
                          color: Colors.green,
                          iconSize: 50.0,
                          onPressed: () {
                            setState(() {
                              _count--;
                            }
                            );
                          },

                        ),
                        IconButton(
                          icon: Icon(Icons.add_circle_outline),
                          color: Colors.red,
                          iconSize: 50.0,
                          onPressed: () {
                            setState(() {
                              _count++;
                              widget.co.count=_count;
                            },
                            );
                          },
                        ),

                      ],
                    ),
                      RaisedButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(10.0),
                              bottomRight: Radius.circular(10.0),
                            ),
                          ),
                        padding: EdgeInsets.all(1),
                          child: Center(
                            child: IconButton(
                              icon: Icon(Icons.check),
                              color: Colors.greenAccent,
                              iconSize: 40.0,
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context,_count);
                          },
                          color: Colors.transparent
                      ),
                ],
                  ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}