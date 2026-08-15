import '../models/models.dart';

/// Market quotes still need an API key, so these stay fixed for now.
class Sample {
  Sample._();

  static const tickers = <Ticker>[
    Ticker('SPY', 0.42),
    Ticker('QQQ', 0.61),
    Ticker('BTC', -1.84),
  ];
}
