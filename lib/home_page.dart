import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'dbprovider/dbprovider.dart';
import 'dbprovider/employee_api_provider.dart';
import 'face_detect.dart';
import 'services/authentication.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.auth, this.userId, this.logoutCallback})
      : super(key: key);

  final BaseAuth auth;
  final VoidCallback logoutCallback;
  final String userId;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var isLoading = false;
  
 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
        actions: <Widget>[
          IconButton(
              icon: Icon(FontAwesomeIcons.solidFileImage),
              onPressed: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => FaceDetect()));
              }),
          IconButton(
              icon: Icon(FontAwesomeIcons.signOutAlt), onPressed: signOut)
        ],
      ),
      body: Column(
        children: <Widget>[
          Card(
            elevation: 0.5,
            child: Container(
            height: 200.0,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  RaisedButton(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 10.0),
                    color: Colors.blue,
                    child: Icon(
                      Icons.settings_input_antenna,
                      color: Colors.white,
                      size: 30.0,
                    ),
                    onPressed: () async {
                      await _loadFromApi();
                    },
                  ),
                  RaisedButton(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 10.0),
                      color: Colors.blue,
                      child: Icon(
                        Icons.delete_outline,
                        color: Colors.white,
                        size: 30.0,
                      ),
                      onPressed: () async {
                        await _deleteData();
                      }),
                ],
              ),
            ),
          ),
         
          ),
           Expanded(
            child: isLoading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                :  _buildEmployeeListView()  ,
          )
        ],
      ),
    );
  }

  signOut() async {
    try {
      await widget.auth.signOut();
      widget.logoutCallback();
    } catch (e) {
      print(e);
    }
  }

  _loadFromApi() async {
    setState(() {
      isLoading = true;
      
    });

    var apiProvider = EmployeeApiProvider();
    await apiProvider.getAllEmployees();

    
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      isLoading = false;
     
      
    });
  }

  _deleteData() async {
    setState(() {
      isLoading = true;
      
    });

    await DBProvider.db.deleteAllEmployees();

    
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      isLoading = false;
      
    });

    print('All employees deleted');
  }

  _buildEmployeeListView() {
    return FutureBuilder(
      future: DBProvider.db.getAllEmployees(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else {
         
          return ListView.separated(
            separatorBuilder: (context, index) => Divider(
              color: Colors.black12,
            ),
            itemCount: snapshot.data.length,
            itemBuilder: (BuildContext context, int index) {
             
              return ListTile(
                leading: Container(
                    width: 50.0,
                    height: 50.0,
                    decoration: new BoxDecoration(
                        shape: BoxShape.circle,
                        image: new DecorationImage(
                            fit: BoxFit.fill,
                            image: new NetworkImage(snapshot.data[index].avatar)
                        )
                    )),
                title: Text(
                    "Name: ${snapshot.data[index].firstName} ${snapshot.data[index].lastName} "),
                subtitle: Text('EMAIL: ${snapshot.data[index].email}'),
              );
            },
          );
        }
      },
    );
  }
}
