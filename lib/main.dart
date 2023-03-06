import 'dart:async';

import 'package:flutter/material.dart';
import 'package:poly_geofence_service/poly_geofence_service.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatefulWidget {
  const ExampleApp({Key? key}) : super(key: key);

  @override
  _ExampleAppState createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  final _streamController = StreamController<PolyGeofence>();

  // Create a [PolyGeofenceService] instance and set options.
  final _polyGeofenceService = PolyGeofenceService.instance.setup(
      interval: 5000,
      accuracy: 100,
      loiteringDelayMs: 60000,
      statusChangeDelayMs: 10000,
      allowMockLocations: false,
      printDevLog: false);

  // Create a [PolyGeofence] list.
  final _polyGeofenceList = <PolyGeofence>[
    PolyGeofence(
      id: 'park1',
      data: {
        'about': 'Park 1',
      },
      polygon: <LatLng>[
        const LatLng(52.04304, -0.746968),
        const LatLng(52.04286, -0.747408),
        const LatLng(52.0429, -0.747454),
        const LatLng(52.04132, -0.751141),
        const LatLng(52.04004, -0.749702),
        const LatLng(52.04028, -0.749138),
        const LatLng(52.04065, -0.749569),
        const LatLng(52.04068, -0.749614),
        const LatLng(52.04069, -0.749940),
        const LatLng(52.04063, -0.750076),
        const LatLng(52.04089, -0.750373),
        const LatLng(52.04095, -0.750237),
        const LatLng(52.04114, -0.750153),
        const LatLng(52.04118, -0.750162),
        const LatLng(52.04148, -0.750496),
        const LatLng(52.04174, -0.749874),
        const LatLng(52.0417, -0.749826),
        const LatLng(52.04209, -0.748882),
        const LatLng(52.04219, -0.748504),
        const LatLng(52.04231, -0.747969),
        const LatLng(52.04236, -0.747617),
        const LatLng(52.0425, -0.746996),
        const LatLng(52.04268, -0.746566),
        const LatLng(52.04225, -0.746084),
        const LatLng(52.04212, -0.746400),
        const LatLng(52.04202, -0.746452),
        const LatLng(52.04186, -0.746694),
        const LatLng(52.04159, -0.747033),
        const LatLng(52.04145, -0.747203),
        const LatLng(52.04129, -0.747326),
        const LatLng(52.04109, -0.747755),
        const LatLng(52.04094, -0.747591),
        const LatLng(52.04179, -0.745637),
        const LatLng(52.04182, -0.745676),
        const LatLng(52.04185, -0.745624),
      ],
    ),
    PolyGeofence(
      id: 'park2',
      data: {
        'about': 'Park 2',
      },
      polygon: <LatLng>[
        const LatLng(52.04108, -0.751603),
        const LatLng(52.03987, -0.750246),
        const LatLng(52.0399, -0.750178),
        const LatLng(52.03987, -0.750136),
        const LatLng(52.04001, -0.749784),
        const LatLng(52.04005, -0.749828),
        const LatLng(52.03999, -0.749977),
        const LatLng(52.04126, -0.751373),
        const LatLng(52.04217, -0.749251),
        const LatLng(52.04246, -0.748582),
        const LatLng(52.04293, -0.747486),
        const LatLng(52.04301, -0.747581),
        const LatLng(52.04307, -0.747435),
        const LatLng(52.04311, -0.747485),
        const LatLng(52.04258, -0.748717),
        const LatLng(52.04246, -0.748586),
        const LatLng(52.04217, -0.749257),
        const LatLng(52.0423, -0.749399),
        const LatLng(52.04138, -0.751510),
        const LatLng(52.0412, -0.751316),
      ],
    ),
  ];

  // This function is to be called when the geofence status is changed.
  Future<void> _onPolyGeofenceStatusChanged(PolyGeofence polyGeofence,
      PolyGeofenceStatus polyGeofenceStatus, Location location) async {
    print('polyGeofence: ${polyGeofence.toJson()}');
    print('polyGeofenceStatus: ${polyGeofenceStatus.toString()}');
    _streamController.sink.add(polyGeofence);
  }

  // This function is to be called when the location has changed.
  void _onLocationChanged(Location location) {
    print('location: ${location.toJson()}');
  }

  // This function is to be called when a location services status change occurs
  // since the service was started.
  void _onLocationServicesStatusChanged(bool status) {
    print('isLocationServicesEnabled: $status');
  }

  // This function is used to handle errors that occur in the service.
  void _onError(error) {
    final errorCode = getErrorCodesFromError(error);
    if (errorCode == null) {
      print('Undefined error: $error');
      return;
    }

    print('ErrorCode: $errorCode');
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _polyGeofenceService
          .addPolyGeofenceStatusChangeListener(_onPolyGeofenceStatusChanged);
      _polyGeofenceService.addLocationChangeListener(_onLocationChanged);
      _polyGeofenceService.addLocationServicesStatusChangeListener(
          _onLocationServicesStatusChanged);
      _polyGeofenceService.addStreamErrorListener(_onError);
      _polyGeofenceService.start(_polyGeofenceList).catchError(_onError);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // A widget used when you want to start a foreground task when trying to minimize or close the app.
      // Declare on top of the [Scaffold] widget.
      home: WillStartForegroundTask(
        onWillStart: () async {
          // You can add a foreground task start condition.
          return _polyGeofenceService.isRunningService;
        },
        androidNotificationOptions: AndroidNotificationOptions(
          channelId: 'geofence_service_notification_channel',
          channelName: 'Geofence Service Notification',
          channelDescription:
              'This notification appears when the geofence service is running in the background.',
          channelImportance: NotificationChannelImportance.LOW,
          priority: NotificationPriority.LOW,
          isSticky: false,
        ),
        iosNotificationOptions: const IOSNotificationOptions(),
        foregroundTaskOptions: const ForegroundTaskOptions(
          interval: 5000,
          autoRunOnBoot: true,
        ),
        notificationTitle: 'Geofence Service is running',
        notificationText: 'Tap to return to the app',
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Poly Geofence Demo for Colin'),
            centerTitle: true,
          ),
          body: _buildContentView(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _streamController.close();
    super.dispose();
  }

  Widget _buildContentView() {
    return StreamBuilder<PolyGeofence>(
      stream: _streamController.stream,
      builder: (context, snapshot) {
        final updatedDateTime = DateTime.now();
        var content = snapshot.data?.toJson()['data']['about'] ?? '';

        if (content != '') {
          if (snapshot.data?.status == PolyGeofenceStatus.DWELL) {
            content = 'Parking at: ' + content;
          } else if (snapshot.data?.status == PolyGeofenceStatus.ENTER) {
            content = 'Entered: ' + content;
          } else if (snapshot.data?.status == PolyGeofenceStatus.EXIT) {
            content = 'Left: ' + content;
          }
        }

        return ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(8.0),
          children: [
            // Text('•\t\tPolyGeofence (updated: $updatedDateTime)'),
            // const SizedBox(height: 10.0),
            Text(content),
          ],
        );
      },
    );
  }
}
