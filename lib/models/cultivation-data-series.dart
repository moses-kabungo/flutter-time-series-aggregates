
class CultivationDataSeries {

  final DateTime timestamp;
  int tones;

  // constructor
  CultivationDataSeries(this.timestamp, this.tones);

  // named constructor
  CultivationDataSeries.entryAt(this.timestamp, { int tones = 0 }):
    this.tones = tones;

  // overload the addition operator
  CultivationDataSeries operator+ (int tones) {
    this.tones += tones;
    return this;
  }

  // overload the substraction operator
  CultivationDataSeries operator- (int tones) {
    this.tones -= tones;
    return this;
  }
}
