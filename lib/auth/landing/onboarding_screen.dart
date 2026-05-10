import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:SynFin/utils/routes/route_constants.dart';
// import 'package:SynFin/screens/login/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late PageController _pageController;
  int _pageIndex = 0;

  @override
  void initState() {
    _pageController = PageController(initialPage: 0);
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  itemCount: onBoardData.length,
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _pageIndex = index;
                    });
                  },
                  itemBuilder: (context, index) => OnboardContent(
                    image: onBoardData[index].image,
                    title: onBoardData[index].title,
                    description: onBoardData[index].description,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: List.generate(
                      onBoardData.length,
                      (index) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: DotIndicator(isActive: index == _pageIndex),
                      ),
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 56,
                    width: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_pageIndex == onBoardData.length - 1) {
                          context.goNamed(RouteConstants.login);

                          // Navigator.pushReplacement(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (context) => const LoginScreen(),
                          //   ),
                          // );
                        } else {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOutQuint,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(0),
                      ),
                      child: Icon(
                        _pageIndex == onBoardData.length - 1
                            ? Icons.check
                            : Icons.arrow_forward,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DotIndicator extends StatelessWidget {
  const DotIndicator({this.isActive = false, super.key});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 8,
      width: isActive ? 24 : 8,
      decoration: BoxDecoration(
        color: isActive
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.primary.withValues(alpha: .2),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class OnBoard {
  final String image;
  final String title;
  final String description;

  OnBoard({
    required this.image,
    required this.title,
    required this.description,
  });
}

final List<OnBoard> onBoardData = [
  OnBoard(
    image: 'assets/images/onboarding.png',
    title: 'Welcome to Cura Docs',
    description:
        'Your health is our priority. Let us help you take care of it.',
  ),
  OnBoard(
    image: 'assets/images/onboarding2.png',
    title: 'Your personal health record maintainer',
    description: 'Access your health records anytime, anywhere.',
  ),
  OnBoard(
    image: 'assets/images/onboarding3.png',
    title: 'Your personal appointment tracker',
    description: 'Never miss an appointment again.',
  ),
];

class OnboardContent extends StatelessWidget {
  const OnboardContent({
    required this.image,
    required this.title,
    required this.description,
    super.key,
  });

  final String image, title, description;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(),
        Image.asset(image, height: 320, fit: BoxFit.contain),
        const Spacer(),
        Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
            fontSize: 24,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          description,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall!.copyWith(
            color: Colors.grey.shade600,
            height: 1.5,
          ),
        ),
        const Spacer(),
      ],
    );
  }
}
