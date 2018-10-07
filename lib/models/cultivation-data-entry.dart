
class CultivationDataEntry {

  final DateTime timestamp;
  int tones = 0;

  // constructor
  CultivationDataEntry(this.timestamp, this.tones);

  // named constructor
  CultivationDataEntry.onDateOf(this.timestamp);

  // overload the addition operator
  CultivationDataEntry operator+ (int tones) {
    this.tones += tones;
    return this;
  }

  // overload the substraction operator
  CultivationDataEntry operator- (int tones) {
    this.tones -= tones;
    return this;
  }
}
