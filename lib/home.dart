import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:call_log/call_log.dart';
import 'package:flutter/services.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with WidgetsBindingObserver {

  String baseUrl = "https://wa.me/91";
  String number = "";
  final _formKey = GlobalKey<FormState>();

  var callEntries = [];

  int _selectedIndex = 0;

  void fetchLogEntries() async {
    callEntries.clear();
    var entries = await CallLog.get();
    entries.forEach((element) {
      // print("${element.name}: ${element.number}");
      callEntries.add(element);
    });
    setState(() {});
  }

  Future<void> openUrl({String? urlString}) async {
    print(urlString);
    if (urlString == null) {
      throw "urlString params are invalid";
    }
    if (await canLaunch(urlString)) {
      await launch(
        urlString,
      );
    } else {
      throw 'Could not open the url.';
    }
  }

  @override
  void initState() {
    super.initState();
    fetchLogEntries();
    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance!.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print(state);
    if(state == AppLifecycleState.resumed) {
      fetchLogEntries();
    } else if(state == AppLifecycleState.inactive) {
      // app is inactive
    } else if(state == AppLifecycleState.paused) {
      // user is about quit our app temporally
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(18.0, 18.0, 18.0, 0.0),
              // margin: EdgeInsets.all(10.0),
              // color: Colors.greenAccent,
              child: Row(
                children: [
                  Text(
                    baseUrl,
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: "RobotoMono",
                      fontSize: 22.0,
                    ),
                  ),
                  Text(
                    number,
                    style: TextStyle(
                      color: Colors.greenAccent,
                      fontFamily: "RobotoMono",
                      fontSize: 22.0,
                    ),
                  ),
                ],
              ),
            ),
            Form(
              key: _formKey,
              child: Container(
                padding: EdgeInsets.fromLTRB(18.0, 12.0, 18.0, 18.0),
                child: TextFormField(
                  initialValue: number,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(10)
                  ],
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24.0
                  ),
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.dialpad,
                      color: Colors.white70,
                      size: 24.0,
                    ),
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide( color: Colors.white70),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.greenAccent)
                    ),
                    labelText: 'Mobile Number',
                    labelStyle: TextStyle(
                      color: Colors.white70,
                      fontFamily: "RobotoMono",
                      fontSize: 24.0
                    ),
                    fillColor: Colors.white70,
                  ),
                  validator: (val) {
                    if (val == null) return "Enter a valid a number";
                    else return (val.isEmpty || val.length != 10) ? "Enter a valid number" : null;
                  },
                  onChanged: (val) {
                    setState(() {
                      number = val;
                    });
                  },
                  keyboardType: TextInputType.phone,
                ),
              ),
            ),
            Divider(
              height: 1.0,
              color: Colors.greenAccent,
            ),
            Expanded(child: ListView.builder(
              itemCount: callEntries.length,
              itemBuilder: (context, index) {
                var entry = callEntries[index];
                return ListTile(
                  title: Text(
                    entry.name ?? "#na",
                    style: TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent,
                      letterSpacing: 1.0
                    ),
                  ),
                  subtitle: Text(
                    entry.number ?? "#na",
                    style: TextStyle(
                      fontFamily: "RobotoMono",
                      fontSize: 28.0,
                      color: Colors.white,
                    ),
                  ),
                  selectedTileColor: Colors.white10,
                  selected: index == _selectedIndex,
                  onTap: () {
                    if (entry.number != null) {
                      var num = entry.number.toString().replaceAll("+91", "");
                      setState(() {
                        number = num;
                        _selectedIndex = index;
                      });
                    }
                  },
                );
              },
            ))
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_formKey.currentState!.validate() || (number.isNotEmpty && number.length == 10)) {
            openUrl(urlString: baseUrl+number);
          }
        },
        child: Icon(
          Icons.send,
          color: Colors.grey.shade900,
        ),
        backgroundColor: Colors.greenAccent,
      ),
    );
  }
}
