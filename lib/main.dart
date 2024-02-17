import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        designSize: const Size(428, 926),
        builder: (context, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Postman App',
            theme: ThemeData(
                scaffoldBackgroundColor: const Color.fromARGB(255, 0, 31, 63)),
            home: FutureBuilder(
                future: getData(),
                builder: (context, snap) {
                  if (snap.hasData) {
                    return MyHomePage(
                      courseList: snap.data!,
                    );
                  } else if (!snap.hasError) {
                    return const Scaffold(
                      body: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  } else {
                    return Center(
                      child: Text(snap.error.toString()),
                    );
                  }
                }),
          );
        });
  }
}

class MyHomePage extends StatefulWidget {
  final List<dynamic> courseList;
  var modList = [];
  MyHomePage({
    super.key,
    required this.courseList,
  }) {
    modList = courseList;
  }

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int branch = 0;
  int year = 0;
  final TextEditingController _searchController = TextEditingController();
  List<String> years = ["", "1st", "2nd", "3rd", "4th"];
  List<String> branches = ["", "CS", "Elec.", "Mech."];

  void listModifier(String query) {
    widget.modList = widget.courseList
        .where((element) =>
            (element['courseName'].toString().toLowerCase() +
                    element['courseCode'].toString().toLowerCase())
                .contains(query.toLowerCase()) &&
            element['year'].toString().contains(years[year]) &&
            element['department'].toString().contains(branches[branch]))
        .toList();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Stack(
          children: [
            Positioned(
              top: 300.h,
              child: SvgPicture.asset(
                'assets/cloudsbg.svg',
                width: MediaQuery.of(context).size.width,
              ),
            ),
            Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                      top: 50.h, left: 10.w, right: 10.w, bottom: 10.h),
                  child: Container(
                    decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 5.r,
                              spreadRadius: 5.r)
                        ],
                        color: const Color.fromARGB(255, 65, 105, 225),
                        borderRadius: BorderRadius.circular(15.r)),
                    child: Padding(
                      padding: EdgeInsets.only(left: 15.w, right: 8.w),
                      child: TextField(
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: "Search ...",
                            hintStyle: TextStyle(color: Colors.white)),
                        controller: _searchController,
                        onChanged: (q) {
                          listModifier(q);
                        },
                      ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: EdgeInsets.only(left: 10.w, right: 20.w),
                        child: Container(
                            decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 65, 105, 225),
                                borderRadius: BorderRadius.circular(20.r)),
                            height: 50.h,
                            child: Padding(
                              padding: EdgeInsets.only(
                                left: 5.w,
                              ),
                              child: DropdownButtonFormField<int>(
                                  alignment: AlignmentDirectional.topStart,
                                  borderRadius: BorderRadius.circular(10.r),
                                  dropdownColor:
                                      const Color.fromARGB(255, 65, 105, 225),
                                  decoration: const InputDecoration(
                                    labelStyle: TextStyle(color: Colors.white),
                                    hintText: "Branch",
                                    border: InputBorder.none,
                                  ),
                                  icon: const Icon(
                                    Icons.arrow_drop_down,
                                    color: Colors.white,
                                  ),
                                  value: branch,
                                  items: const [
                                    DropdownMenuItem<int>(
                                      value: 0,
                                      child:
                                          dropdownText(text: "Select Branch"),
                                    ),
                                    DropdownMenuItem<int>(
                                        value: 1,
                                        child: dropdownText(text: "CS")),
                                    DropdownMenuItem<int>(
                                        value: 2,
                                        child: dropdownText(text: "Elec.")),
                                    DropdownMenuItem<int>(
                                        value: 3,
                                        child: dropdownText(text: "Mech.")),
                                  ],
                                  onChanged: (index) {
                                    branch = index!;
                                    listModifier("");
                                  }),
                            )),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: EdgeInsets.only(left: 20.w, right: 10.w),
                        child: Center(
                          child: Container(
                              decoration: BoxDecoration(
                                  color:
                                      const Color.fromARGB(255, 65, 105, 225),
                                  borderRadius: BorderRadius.circular(20.r)),
                              height: 50.h,
                              child: Padding(
                                padding: EdgeInsets.only(left: 5.w),
                                child: DropdownButtonFormField<int>(
                                    alignment: AlignmentDirectional.topStart,
                                    borderRadius: BorderRadius.circular(10.r),
                                    dropdownColor:
                                        const Color.fromARGB(255, 65, 105, 225),
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                    ),
                                    icon: const Icon(
                                      Icons.arrow_drop_down,
                                      color: Colors.white,
                                    ),
                                    value: year,
                                    items: const [
                                      DropdownMenuItem<int>(
                                        value: 0,
                                        child:
                                            dropdownText(text: "Select Year"),
                                      ),
                                      DropdownMenuItem<int>(
                                          value: 1,
                                          child: dropdownText(text: "1st")),
                                      DropdownMenuItem<int>(
                                          value: 2,
                                          child: dropdownText(text: "2nd")),
                                      DropdownMenuItem<int>(
                                          value: 3,
                                          child: dropdownText(text: "3rd")),
                                      DropdownMenuItem<int>(
                                          value: 4,
                                          child: dropdownText(text: "4th")),
                                    ],
                                    onChanged: (index) {
                                      year = index!;
                                      listModifier("");
                                    }),
                              )),
                        ),
                      ),
                    )
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(top: 12.h),
                  child: SizedBox(
                    width: 420.w,
                    height: 740.h,
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemBuilder: (context, index) => Padding(
                        padding: EdgeInsets.all(8.0.r),
                        child: Container(
                          height: 200.h,
                          decoration: BoxDecoration(
                              color: const Color.fromARGB(120, 52, 152, 219),
                              borderRadius: BorderRadius.circular(30.r)),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(top: 28.h, left: 28.w),
                                child: Text(
                                  widget.modList[index]['courseName'],
                                  style: const TextStyle(
                                      fontSize: 20,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800),
                                ),
                              ),
                              Padding(
                                padding:
                                    EdgeInsets.only(left: 28.w, right: 28.h),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Course Code: " +
                                          widget.modList[index]['courseCode'],
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 19.sp),
                                    ),
                                    Text(
                                      widget.modList[index]['year'] + " year",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 19.sp),
                                    )
                                  ],
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 25, bottom: 25),
                                child: Text(
                                  "Department: " +
                                      widget.modList[index]['department'],
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 19.sp),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      itemCount: widget.modList.length,
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class dropdownText extends StatelessWidget {
  final String text;
  const dropdownText({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(color: Colors.white, fontSize: 15.sp),
    );
  }
}

Future<List<dynamic>> getData() async {
  final res =
      await http.get(Uri.parse('https://smsapp.bits-postman-lab.in/courses'));
  // print(jsonDecode(res.body)['courses']);
  final List<dynamic> courseList = jsonDecode(res.body)['courses'];

  return courseList;
}
