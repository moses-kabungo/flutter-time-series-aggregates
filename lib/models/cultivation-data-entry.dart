
class CultivationDataEntry {

  final DateTime timestamp;
  int tones;

  // constructor
  CultivationDataEntry(this.timestamp, this.tones);

  // named constructor
  CultivationDataEntry.on(this.timestamp, { int tones = 0 }):
    this.tones = tones;

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
