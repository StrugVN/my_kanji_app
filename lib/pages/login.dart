import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:my_kanji_app/data/shared.dart';
import 'package:my_kanji_app/data/app_data.dart';
import 'package:my_kanji_app/data/userdata.dart';
import 'package:my_kanji_app/pages/home.dart';
import 'package:my_kanji_app/service/api.dart';
import 'package:my_kanji_app/utility/login_animated.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _animacaoBlur;
  Animation<double>? _animacaoFade;
  Animation<double>? _animacaoSize;

  final apiInput = TextEditingController();
  final AppData appData = AppData();
  late bool obscure;
  late bool _notValid;
  late String _errorMessage;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _animacaoBlur = Tween<double>(
      begin: 50,
      end: 0,
    ).animate(
      CurvedAnimation(
        parent: _controller!,
        curve: Curves.ease,
      ),
    );

    _animacaoFade = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _controller!,
        curve: Curves.easeInOutQuint,
      ),
    );

    _animacaoSize = Tween<double>(
      begin: 0,
      end: 500,
    ).animate(
      CurvedAnimation(
        parent: _controller!,
        curve: Curves.decelerate,
      ),
    );

    _controller?.forward();

    obscure = false;
    _notValid = false;
    _errorMessage = "";
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // timeDilation = 8;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            children: [
              AnimatedBuilder(
                animation: _animacaoBlur!,
                builder: (context, widget) {
                  return Container(
                    height: MediaQuery.of(context).size.height * 0.7,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("assets/images/login_bg.png"),
                        fit: BoxFit.fill,
                      ),
                    ),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: _animacaoBlur!.value,
                        sigmaY: _animacaoBlur!.value,
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            left: 10,
                            top: 20,
                            child: FadeTransition(
                              opacity: _animacaoFade!,
                              child: Image.asset("assets/images/text2.png"),
                            ),
                          ),
                          Positioned(
                            top: 25,
                            left: 50,
                            child: FadeTransition(
                              opacity: _animacaoFade!,
                              child: Image.asset("assets/images/text1.png"),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.only(left: 40, right: 40, top: 20),
                child: Column(
                  children: [
                    AnimatedBuilder(
                      animation: _animacaoSize!,
                      builder: (context, widget) {
                        return Container(
                          width: _animacaoSize?.value,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.grey,
                                blurRadius: 80,
                                spreadRadius: 1,
                              )
                            ],
                          ),
                          child: Container(
                            padding: const EdgeInsets.only(left: 8, right: 8),
                            child: TextField(
                              onChanged: (String str) {
                                if (str == "") {
                                  setState(() {
                                    _notValid = false;
                                  });
                                }
                              },
                              controller: apiInput,
                              obscureText: !obscure,
                              decoration: InputDecoration(
                                hoverColor: null,
                                errorText: _notValid ? "Invalid API key" : null,
                                prefixIcon: const Icon(Icons.key),
                                border: _notValid
                                    ? const OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.red),
                                      )
                                    : InputBorder.none,
                                hintText: ' Wanikani API key',
                                hintStyle: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    // Based on passwordVisible state choose the icon
                                    obscure
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: Theme.of(context).primaryColorDark,
                                  ),
                                  onPressed: () {
                                    // Update the state i.e. toogle the state of passwordVisible variable
                                    setState(() {
                                      obscure = !obscure;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    LoginButtonAnimated(
                      controller: _controller!,
                      login: login,
                    ),
                    const SizedBox(height: 10),
                    FadeTransition(
                      opacity: _animacaoFade!,
                      child: const Text(
                        "I don't use Wanikani",
                        style: TextStyle(
                          color: Color.fromRGBO(173, 192, 249, 1),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  login() async {
    // Do stuff
    showLoaderDialog(context, "Signing in...");

    apiInput.text = "1dce059b-8e56-49e4-b759-445d8104c0bf";

    final response = await getUser(apiInput.text);

    var body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200) {
      appData.apiKey = "Bearer ${apiInput.text}";

      appData.userData =
          UserData.fromJson(jsonDecode(response.body) as Map<String, dynamic>);

      appData.dataIsLoaded = false;

      Navigator.pop(context, true); // Pop loading

      // Load data
      showLoaderDialog(context, "Loading data");
      await appData.loadData();

      Navigator.pop(context, true); // Pop loading
      //

      Navigator.push(context, toHome());
      
    } else {
      setState(() {
        _notValid = true;

        _errorMessage = body["error"];
      });
      Navigator.pop(context);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(response.body)));
    }
  }
}

Route toHome() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => const Home(),
    transitionDuration: const Duration(milliseconds: 1100),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(0.0, 10.0);
      const end = Offset.zero;
      const curve = Curves.ease;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
    settings: const RouteSettings(name: "homePage"),
  );
}
