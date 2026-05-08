import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../auth/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> onboardingData = [
    {
      "title": "Discover Your\nFavorite Vocaloid Music",
      "subtitle": "Enjoy thousands of Hatsune Miku, GUMI, MEIKO, and all your favorite Vocaloid songs.",
      "image": "assets/images/onboarding_1.png" // Pastikan gambar ini ada di folder
    },
    {
      "title": "Real-Time Lyrics\nAs the Music Plays",
      "subtitle": "Follow every word with perfectly synchronized lyrics display.",
      "image": "assets/images/onboarding_2.png"
    },
    {
      "title": "Create Playlists\nThat Match Your Mood",
      "subtitle": "Organize your favorite songs in personal playlists you can share with friends.",
      "image": "assets/images/onboarding_3.png"
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (value) => setState(() => _currentPage = value),
                itemCount: onboardingData.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Ganti bagian kode gambar sebelumnya dengan kode di bawah ini:
                        Center(
                          child: AspectRatio(
                            aspectRatio: 1 / 1, // Mengatur rasio 1:1 agar bentuknya kotak sempurna
                            child: Container(
                              decoration: BoxDecoration(
                                // borderRadius dihapus agar sudutnya menjadi lancip/tajam sesuai desain
                                image: DecorationImage(
                                  image: AssetImage(onboardingData[index]["image"]!),
                                  fit: BoxFit.cover, // Memastikan gambar memenuhi area kotak tanpa terdistorsi
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        Text(
                          onboardingData[index]["title"]!,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textWhite),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          onboardingData[index]["subtitle"]!,
                          style: const TextStyle(fontSize: 14, color: AppColors.textGrey, height: 1.5),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 40.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: List.generate(onboardingData.length, (index) => buildDot(index: index)),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity, height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      onPressed: () {
                        if (_currentPage == onboardingData.length - 1) {
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                        } else {
                          _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
                        }
                      },
                      child: Text(
                        _currentPage == onboardingData.length - 1 ? "Get Started" : "Next",
                        style: const TextStyle(color: AppColors.background, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDot({required int index}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(right: 8),
      height: 8,
      width: _currentPage == index ? 24 : 8,
      decoration: BoxDecoration(
        color: _currentPage == index ? AppColors.primary : AppColors.textGrey.withOpacity(0.5),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}