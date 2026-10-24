import 'package:flutter/material.dart';

class AnimatedCounter extends ImplicitlyAnimatedWidget {
  final double value;
  final String suffix;
  final TextStyle? style;

  const AnimatedCounter({
    Key? key,
    required this.value,
    this.suffix = '',
    this.style,
    Duration duration = const Duration(milliseconds: 500),
  }) : super(key: key, duration: duration);

  @override
  _AnimatedCounterState createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends AnimatedWidgetBaseState<AnimatedCounter> {
  Tween<double>? _valueTween;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _valueTween = visitor(
      _valueTween,
      widget.value,
      (dynamic value) => Tween<double>(begin: value as double),
    ) as Tween<double>?;
  }

  @override
  Widget build(BuildContext context) {
    final val = _valueTween?.evaluate(animation) ?? 0.0;
    return Text(
      '${val.toStringAsFixed(1)}${widget.suffix}',
      style: widget.style,
    );
  }
}
