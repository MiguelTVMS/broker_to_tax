import "gains.dart";

abstract class BrokerOperation {
  Gain toGain();
}

abstract class BrokerOperations {
  Gains toGains();
}
