import 'package:flutter/material.dart';
import 'package:launchdarkly_flutter_client_sdk/launchdarkly_flutter_client_sdk.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // The LDClient doesn't need to change throughout the lifetime of the
    // application, so we wrap the application in a provider with the client.    
    return Provider<LDClient>(
        create: (_) => LDClient(
            LDConfig(
              // The credentials come from the environment, you can set them
              // using --dart-define.
              // Examples:
              // flutter run --dart-define LAUNCHDARKLY_CLIENT_SIDE_ID=<my-client-side-id> -d Chrome
              // flutter run --dart-define LAUNCHDARKLY_MOBILE_KEY=<my-mobile-key> -d ios
              //
              // Alternatively `CredentialSource.fromEnvironment()` can be replaced with your mobile key.
              'mob-3924cdf5-2e4f-4385-baf2-e9e12905c9fc',
              AutoEnvAttributes.enabled,
              logger : LDLogger(level: LDLogLevel.debug),
            ),
            // Here we are using a default user with 'user-key'.
            LDContextBuilder().kind('user', 'user-key').build()),
        dispose: (_, client) => client.close(),
        // We use a future provider to wait for the client to either start,
        // or for a timeout to elapse.
        child: MaterialApp(
          title: 'LaunchDarkly Example',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          home: const MyHomePage(title: 'LaunchDarkly Example'),
        ));
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

/// Example provider which listens for flag changes and maps them to string
/// values. It would also be possible to map to some application specific model
/// types. When mapping be sure all values are accessed through the client
/// `variation` methods. This ensures that the SDK generates the expected
/// events.
class FlagProviderBool extends StreamProvider<bool> {
  FlagProviderBool(
      {super.key,
      required LDClient client,
      required String flagKey,
      required bool defaultValue,
      required Widget child})
      : super(
            create: (context) => client.flagChanges
                .where((element) => element.keys.contains(flagKey))
                .map((event) => client.boolVariation(flagKey, defaultValue)),
            // Here we get the initial value of the flag. If the SDK is not
            // initialized, then the default value will be returned.
            initialData: client.boolVariation(flagKey, defaultValue),
            child: child);
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FlagProviderBool(
              // The client will not be changing, so we don't need to
              // listen for client changes.
              client:
                  Provider.of<LDClient>(context, listen: false),
              flagKey: 'sample-feature',
              defaultValue: true,
              child: Consumer<bool>(
                  builder: (context, flagValue, _) =>
                      Text('flag value: $flagValue'))),
          ],
        ),
      ),// This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
