import 'package:flutter/material.dart';

class LoginButtonAnimated extends StatelessWidget {
  AnimationController controller;
  Animation<double> largura;
  Animation<double> altura;
  Animation<double> radius;
  Animation<double> opacidade;

  final void Function() login;

  LoginButtonAnimated({super.key, required this.controller, required this.login})
      : largura = Tween<double>(
          begin: 0,
          end: 500,
        ).animate(
          CurvedAnimation(
            parent: controller,
            curve: const Interval(0.0, 0.5),
          ),
        ),
        altura = Tween<double>(
          begin: 0,
          end: 50,
        ).animate(
          CurvedAnimation(
            parent: controller,
            curve: const Interval(0.5, 0.7),
          ),
        ),
        radius = Tween<double>(
          begin: 0,
          end: 20,
        ).animate(
          CurvedAnimation(
            parent: controller,
            curve: const Interval(0.6, 1.0),
          ),
        ),
        opacidade = Tween<double>(
          begin: 0,
          end: 1,
        ).animate(
          CurvedAnimation(
            parent: controller,
            curve: const Interval(0.6, 0.8),
          ),
        );

  Widget _buildAnimation(BuildContext context, Widget? widget) {
    return InkWell(
      onTap: () {},
      child: InkWell(
        onTap: login,
        child: Container(
          width: largura.value,
          height: altura.value,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius.value),
            gradient: const LinearGradient(
              colors: [
                Color.fromRGBO(57, 54, 244, 1),
                Color.fromRGBO(57, 54, 244, 1),
              ],
            ),
          ),
          child: Center(
            child: FadeTransition(
              opacity: opacidade,
              child: const Text(
                "Login",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: _buildAnimation,
    );
  }
}
