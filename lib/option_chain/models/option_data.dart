class OptionData {
  double strike;
  int callOi;
  double callPremium;
  int putOi;
  double putPremium;
  double delta;
  double gamma;
  double vega;
  double theta;
  double iv;

  OptionData({
    required this.strike,
    required this.callOi,
    required this.callPremium,
    required this.putOi,
    required this.putPremium,
    this.delta = 0.0,
    this.gamma = 0.0,
    this.vega = 0.0,
    this.theta = 0.0,
    this.iv = 0.0
  });

  factory OptionData.fromJson(Map<String, dynamic> json) => OptionData(
        strike: (json['strike'] as num).toDouble(),
        callOi: json['callOi'] as int,
        callPremium: (json['callPremium'] as num).toDouble(),
        putOi: json['putOi'] as int,
        putPremium: (json['putPremium'] as num).toDouble(),
        delta: (json['delta'] as num?)?.toDouble() ?? 0.0,
        gamma: (json['gamma'] as num?)?.toDouble() ?? 0.0,
        vega: (json['vega'] as num?)?.toDouble() ?? 0.0,
        theta: (json['theta'] as num?)?.toDouble() ?? 0.0,
        iv: (json['iv'] as num?)?.toDouble() ?? 0.0,
      );

  Map<String, dynamic> toJson() => {
        'strike': strike,
        'callOi': callOi,
        'callPremium': callPremium,
        'putOi': putOi,
        'putPremium': putPremium,
        'delta': delta,
        'gamma': gamma,
        'vega': vega,
        'theta': theta,
        'iv': iv,
      };
}

enum OptionChainVisibility {
  call('Only Call'),
  put('Only Put'),
  both('Both');

  final String name;
  const OptionChainVisibility(this.name);
}
