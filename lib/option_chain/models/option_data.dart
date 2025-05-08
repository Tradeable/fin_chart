class OptionData {
  double strike;
  int callOi;
  double callPremium;
  int putOi;
  double putPremium;
  double callDelta;
  double callGamma;
  double callVega;
  double callTheta;
  double callIV;
  double putDelta;
  double putGamma;
  double putVega;
  double putTheta;
  double putIV;

  OptionData(
      {required this.strike,
      required this.callOi,
      required this.callPremium,
      required this.putOi,
      required this.putPremium,
      this.callDelta = 0.0,
      this.callGamma = 0.0,
      this.callVega = 0.0,
      this.callTheta = 0.0,
      this.callIV = 0.0,
      this.putDelta = 0.0,
      this.putGamma = 0.0,
      this.putVega = 0.0,
      this.putTheta = 0.0,
      this.putIV = 0.0});

  factory OptionData.fromJson(Map<String, dynamic> json) => OptionData(
      strike: (json['strike'] as num).toDouble(),
      callOi: json['callOi'] as int,
      callPremium: (json['callPremium'] as num).toDouble(),
      putOi: json['putOi'] as int,
      putPremium: (json['putPremium'] as num).toDouble(),
      callDelta: (json['callDelta'] as num?)?.toDouble() ?? 0.0,
      callGamma: (json['callGamma'] as num?)?.toDouble() ?? 0.0,
      callVega: (json['callVega'] as num?)?.toDouble() ?? 0.0,
      callTheta: (json['callTheta'] as num?)?.toDouble() ?? 0.0,
      callIV: (json['callIV'] as num?)?.toDouble() ?? 0.0,
      putDelta: (json['putDelta'] as num?)?.toDouble() ?? 0.0,
      putGamma: (json['putGamma'] as num?)?.toDouble() ?? 0.0,
      putVega: (json['putVega'] as num?)?.toDouble() ?? 0.0,
      putTheta: (json['putTheta'] as num?)?.toDouble() ?? 0.0,
      putIV: (json['putIV'] as num?)?.toDouble() ?? 0.0);

  Map<String, dynamic> toJson() => {
        'strike': strike,
        'callOi': callOi,
        'callPremium': callPremium,
        'putOi': putOi,
        'putPremium': putPremium,
        'callDelta': callDelta,
        'callGamma': callGamma,
        'callVega': callVega,
        'callTheta': callTheta,
        'callIV': callIV,
        'putDelta': putDelta,
        'putGamma': putGamma,
        'putVega': putVega,
        'putTheta': putTheta,
        'putIV': putIV
      };
}

enum OptionChainVisibility {
  call('Only Call'),
  put('Only Put'),
  both('Both');

  final String name;

  const OptionChainVisibility(this.name);
}
