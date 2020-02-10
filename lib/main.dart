
import 'package:flutter/material.dart';
import 'root-page.dart';
import 'services/authentication.dart';
 

   
void main() => runApp(
      MaterialApp(
        title: 'Flutter face',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: RootPage(auth: Auth()),
        
      ),
    );

   