enum TrendDetection {
  none('No Detection'),
  sma50('SMA 50'),
  sma50sma200('SMA 50 & 200');

  final String name;
  const TrendDetection(this.name);
}
