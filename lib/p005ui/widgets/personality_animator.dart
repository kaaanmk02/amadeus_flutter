import 'package:flutter/material.dart';

class PersonalityAnimator extends StatefulWidget {
  const PersonalityAnimator({
    required this.child,
    required this.animation,
    super.key,
  });

  final Widget child;
  final PersonalityAnimation animation;

  @override
  State<PersonalityAnimator> createState() => _PersonalityAnimatorState();
}

class _PersonalityAnimatorState extends State<PersonalityAnimator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _rotation;
  late Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.animation.duration, vsync: this);
    _scale = Tween<double>(begin: 1, end: widget.animation.scale).animate(_controller);
    _rotation = Tween<double>(begin: 0, end: widget.animation.rotation).animate(_controller);
    _offset = Tween<Offset>(begin: Offset.zero, end: widget.animation.offset).animate(_controller);
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant PersonalityAnimator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animation != widget.animation) {
      _controller.duration = widget.animation.duration;
      _scale = Tween<double>(begin: _scale.value, end: widget.animation.scale).animate(_controller);
      _rotation = Tween<double>(begin: _rotation.value, end: widget.animation.rotation).animate(_controller);
      _offset = Tween<Offset>(begin: _offset.value, end: widget.animation.offset).animate(_controller);
      _controller.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotation.value,
          child: Transform.translate(
            offset: _offset.value,
            child: Transform.scale(
              scale: _scale.value,
              child: child,
            ),
          ),
        );
      },
      child: widget.child,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
