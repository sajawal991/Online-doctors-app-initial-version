import 'dart:io';
import 'package:demopatient/Provider/auth_provider.dart';
import 'package:demopatient/Provider/notify_provider.dart';
import 'package:demopatient/Screen/202020EyePage.dart';
import 'package:demopatient/Screen/addMediconeReminderPage.dart';
import 'package:demopatient/Screen/chooseCityDrPage.dart';
import 'package:demopatient/Screen/cityListPage.dart';
import 'package:demopatient/Screen/cityListReachUsPage.dart';
import 'package:demopatient/Screen/clinicListPage.dart';
import 'package:demopatient/Screen/contactuspage.dart';
import 'package:demopatient/Screen/departmentPage.dart';
import 'package:demopatient/Screen/editUserprofiel.dart';
import 'package:demopatient/Screen/feedbackpage.dart';
import 'package:demopatient/Screen/gallery.dart';
import 'package:demopatient/Screen/labTest/ciltyListLabTest.dart';
import 'package:demopatient/Screen/labTest/getLabTestAppPagge.dart';
import 'package:demopatient/Screen/medicineReminderPage.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:demopatient/Screen/pharmacy/cityListPharammaPage.dart';
import 'package:demopatient/Screen/pharmacy/pharmaReqListPage.dart';
import 'package:demopatient/Screen/prescription/prescriptionListPage.dart';
import 'package:demopatient/Screen/privicypage.dart';
import 'package:demopatient/Screen/refundpolicyPage.dart';
import 'package:demopatient/Screen/reports/addReportsPage.dart';
import 'package:demopatient/Screen/reports/reportListPage.dart';
import 'package:demopatient/Screen/resch/rescConfimrationPage.dart';
import 'package:demopatient/Screen/resch/walkinReschConfirmationPage.dart';
import 'package:demopatient/Screen/services.dart';
import 'package:demopatient/Screen/aboutus.dart';
import 'package:demopatient/Screen/appointment/registerpatient.dart';
import 'package:demopatient/Screen/appointment/appointment.dart';
import 'package:demopatient/Screen/appointment/appointmentStatus.dart';
import 'package:demopatient/Screen/appointment/choosetimeslots.dart';
import 'package:demopatient/Screen/appointment/confirmation.dart';
import 'package:demopatient/Screen/availiblity.dart';
import 'package:demopatient/Screen/home.dart';
import 'package:demopatient/Screen/login.dart';
import 'package:demopatient/Screen/reachus.dart';
import 'package:demopatient/Screen/notificationPage.dart';
import 'package:demopatient/Screen/testimonials.dart';
import 'package:demopatient/Screen/video/videoList.dart';
import 'package:demopatient/Service/AuthService/authservice.dart';
import 'package:demopatient/widgets/errorWidget.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:demopatient/Screen/blogPost/blogPostPage.dart';
import 'package:demopatient/Screen/moreService.dart';
import 'package:demopatient/translation.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Module/Doctor/Provider/DoctorProvider.dart';
import 'Module/User/Provider/auth_provider.dart';
import 'Screen/Invoice_list_screen.dart';
import 'Screen/appointment/ChatScreen.dart';

void main() async {
  Future<void> initializeService() async {
    final service = FlutterBackgroundService();
    /// OPTIONAL, using custom notification channel id
    AndroidNotificationChannel channel = AndroidNotificationChannel(
      channleId, // id

      'MY FOREGROUND SERVICE', // title
      description:
      'This channel is used for important notifications.', // description
      importance: Importance.low,
      playSound: false,
      // importance must be at low or higher level
    );

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
    //
    // if (Platform.isIOS) {
    //   await flutterLocalNotificationsPlugin.initialize(
    //     const InitializationSettings(
    //       iOS: IOSInitializationSettings(),
    //     ),
    //   );
    // }
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        // this will be executed when app is in foreground or background in separated isolate
        onStart: onStart,
        // auto start service
        autoStart: false,
        isForegroundMode: true,
        notificationChannelId: channleId,
        initialNotificationTitle: 'Eye Reminder',
        initialNotificationContent: 'Initializing',
        foregroundServiceNotificationId: notifiaionId,

      ),
      iosConfiguration: IosConfiguration(
        // auto start service
        autoStart: true,

        // this will be executed when app is in foreground in separated isolate
        onForeground: onStart,

        // you have to enable background fetch capability on xcode project
        onBackground: onIosBackground,
      ),
    );
    SharedPreferences preferences = await SharedPreferences.getInstance();
    final startTimer=  preferences.getBool("startTimer")??false;
    if(startTimer) {
      service.startService();
    }
  }
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await initializeService();
  await FlutterDownloader.initialize(
    debug: true,
      ignoreSsl: true
  );
  initializeDateFormatting();

  // if (USE_FIRESTORE_EMULATOR) {
  //   FirebaseFirestore.instance.settings = Settings(
  //       host: 'localhost:8080', sslEnabled: false, persistenceEnabled: false);
  // }

  try {
    final result = await InternetAddress.lookup('google.com');
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      // print('connected');
      runApp(const MyApp());
    }
  } on SocketException catch (_) {
    runApp(NoInterConnectionApp());
    // print('not connected');
  }

}

class NoInterConnectionApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
        translations: Messages(), // your translations
        locale: Locale('en'), // translations will be displayed in that locale
        fallbackLocale: Locale('en'),
        debugShowCheckedModeBanner: false,
        routes: {
        '/': (context) => Scaffold(
              body: Container(
                  child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: NoInternetErrorWidget(),
              )),
            )
      });
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
   // return //      <--- ChangeNotifierProvider
    return  MultiProvider(
          providers: [
            ChangeNotifierProvider(create:(_) => AuthProvider(),),
            ChangeNotifierProvider(create:(_) => DoctorProvider(),),
            ChangeNotifierProvider(create:(_) => NotifyProvider(),),
            ChangeNotifierProvider(create:(_) => ReportProvider(),),

            // ChangeNotifierProvider(create:(_) => ChangeSlider(),),
            // ChangeNotifierProvider(create:(_) => FavouriteItem(),),
            // ChangeNotifierProvider(create:(_) => ThemeChangerProvider(),),
            // ChangeNotifierProvider(create:(_) => AuthProvider(),)
          ],
          child: Builder(builder: (BuildContext context){

            Provider.of<DoctorProvider>(context, listen:false).callSingleDoctorApi();

            // WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
            // });

            return GetMaterialApp(
              translations: Messages(), // your translations
              locale: Locale('en'), // translations will be displayed in that locale
              fallbackLocale: Locale('en'),
              builder: EasyLoading.init(),

              debugShowCheckedModeBanner: false,
              // home: _defaultHome,
              initialRoute: '/',
              routes: {
                '/': (context) =>LoginPage(),
                //   AuthService().handleAuth(),
                '/LoginPage': (context) => LoginPage(),
                '/HomePage': (context) => HomeScreen(),
                '/AppoinmentPage': (context) => AppointmentPage(),
                // '/IndividualPage': (context) => IndividualPage(),
                '/AboutusPage': (context) => AboutUs(),
                '/ChatScreen': (context) => ChatScreen(null, null, null, Provider.of<AuthProvider>(context, listen: false).activeUser.id.toString(), null),
                "/ChooseTimeSlotPage": (context) => ChooseTimeSlotPage(),
                '/AvaliblityPage': (context) => AvailabilityPage(),
                '/GalleryPage': (context) => GalleryPage(),
                '/ContactUsPage': (context) => AboutUs(), // ContactUs(),
                '/Appointmentstatus': (context) => AppointmentStatus(),
                // '/ReachUsPage': (context) => ReachUS(),
                '/TestimonialsPage': (context) => Testimonials(),
                '/ServicesPage': (context) => ServicesPage(),
                '/RegisterPatientPage': (context) => RegisterPatient(),
                '/ConfirmationPage': (context) => ConfirmationPage(),
                '/NotificationPage': (context) => NotificationPage(),
                '/MoreServiceScreen': (context) => MoreServiceScreen(),
                '/BlogPostPage': (context) => BlogPostPage(),
                '/AuthScreen': (context) => AuthService().handleAuth(),
                '/EditUserProfilePage': (context) => EditUserProfilePage(),
                '/PrescriptionListPage': (context) => PrescriptionListPage(),
                '/ChooseDepartmentPage': (context) => ChooseDepartmentPage(),
                '/InvoiceListPage': (context) => InvoiceListPage(),
                // '/PrivacyPage': (context) => PrivacyPage(),
                // '/RefundPolicyPage': (context) => RefundPolicyPage(),
                // '/Contactuspage': (context) => Contactuspage(),
                // '/FeedBackPage': (context) => FeedBackPage(),
                '/ClinicListPage': (context) => ClinicListPage(), // comment this
                '/CityListPage': (context) => CityListPage(), // comment this
                '/CityDRListPage': (context) => CityDRListPage(), // comment this
                '/CityListReachUsPage': (context) => CityListReachUsPage(),
                '/ReschConfirmationPage': (context) => ReschConfirmationPage(),
                // '/NearByDoctorsListPage': (context) => NearByDoctorsListPage(),
                '/WalkinReschConfirmationPage': (context) => WalkinReschConfirmationPage(),
                '/CityListPharmaPage': (context) => CityListPharmaPage(),
                '/PharmaReqListPage': (context) => PharmaReqListPage(),
                '/AddReportPage': (context) => AddReportPage(),
                '/ReportListPage': (context) => ReportListPage(),
                '/LabTestAppListPage': (context) => LabTestAppListPage(),
                '/CityListLabTestPage': (context) => CityListLabTestPage(),
                '/VideoListPage': (context) => VideoListPage(),
                '/MedicineReminderPage': (context) => MedicineReminderPage(),
                '/AddMedicineReminderPage': (context) => AddMedicineReminderPage(),
                '/EyeSafeReminderPage': (context) => EyeSafeReminderPage(),

              },
            );
          },)
      );

  }
}

class NotificationDotModel {}
