import "gains.dart";

abstract class BrokerOperation {
  Gain toGain();
}

abstract class BrokerOperations {
  int get length;
  Iterable<Gain> toGains();
}
