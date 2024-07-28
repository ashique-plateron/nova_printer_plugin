import 'dart:async';
import 'dart:collection';

class PrinterQueue {
  final Queue<Function> _input = Queue();

  final int maxConcurrentTasks = 1;
  int runningTasks = 0;

  static final PrinterQueue _queue = PrinterQueue._internal();

  factory PrinterQueue() => _queue;

  PrinterQueue._internal() : super();

  void addToQueue(Function value) {
    _input.add(value);
    _startExecution();
  }

  void addAllToQueue(Iterable<Function> iterable) {
    _input.addAll(iterable);
    _startExecution();
  }

  Future<void> _startExecution() async {
    if (runningTasks == maxConcurrentTasks || _input.isEmpty) {
      return;
    }

    while (_input.isNotEmpty && runningTasks < maxConcurrentTasks) {
      runningTasks++;
      await _input.removeFirst().call();
      runningTasks--;
    }
  }
}
