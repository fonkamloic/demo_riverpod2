import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class WebsocketClient {
  Stream<int> getCounterStream([int start]);
}

class FakeWebsocketClient implements WebsocketClient {
  @override
  Stream<int> getCounterStream([int start = 0]) async* {
    int i = 0;
    while (true) {
      yield i++;
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }
}

final websocketClientProvider =
    Provider<WebsocketClient>((ref) => FakeWebsocketClient());
final counterProvider = StreamProvider.family<int, int>((ref, int start) {
  final wsClient = ref.watch(websocketClientProvider);
  return wsClient.getCounterStream(start);
});

void main() => runApp(const ProviderScope(child: MyApp()));

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Counter App',
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          surface: const Color(0xff003909),
          seedColor: Colors.green,
          brightness: Brightness.dark,
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
          child: ElevatedButton(
        child: const Text('Go to Counter Page'),
        onPressed: () {
          Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const CounterPage()));
        },
      )),
    );
  }
}

class CounterPage extends ConsumerWidget {
  const CounterPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<int> counter = ref.watch(counterProvider(10));
    // ref.listen<int>(counterProvider, (((previous, next) {
    //   if (next >= 5) {
    //     showDialog(
    //         context: context,
    //         builder: (context) {
    //           return AlertDialog(
    //             title: const Text('Warning'),
    //             content: const Text(
    //                 'Counter dangerously high. Consider resetting it.'),
    //             actions: [
    //               TextButton(
    //                   onPressed: () {
    //                     Navigator.of(context).pop();
    //                   },
    //                   child: const Text('OK'))
    //             ],
    //           );
    //         });
    //   }
    // })));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Counter'),
        actions: [
          IconButton(
              onPressed: () {
                ref.refresh(counterProvider);
              },
              icon: const Icon(Icons.refresh)),
        ],
      ),
      body: Center(
          child: Text(
        counter
            .when(
                data: (int data) => data,
                error: (Object e, _) => e,
                loading: () => 0)
            .toString(),
        style: Theme.of(context).textTheme.bodyMedium,
      )),
      // floatingActionButton: FloatingActionButton(
      //   child: const Icon(Icons.add),
      //   onPressed: () {
      //     ref.read(counterProvider.notifier).state++;
      //   },
      // ),
    );
  }
}
