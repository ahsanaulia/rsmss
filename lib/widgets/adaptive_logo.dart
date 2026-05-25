import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';

class AdaptiveLogo extends StatelessWidget {
  final double height;
  final double? width;
  final BoxFit fit;

  final String imagePath;
  final String lottiePath;
  final Widget? fallback;

  const AdaptiveLogo({
    super.key,
    this.height = 120,
    this.width,
    this.fit = BoxFit.contain,
    this.imagePath = 'assets/images/logo.png',
    this.lottiePath = 'assets/images/logo.json',
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkLottieExists(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            height: height,
            width: width ?? height,
            child: const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFF01579B),
              ),
            ),
          );
        }

        final hasLottie = snapshot.data ?? false;

        if (hasLottie) {
          return FittedBox(
            fit: BoxFit
                .scaleDown, // ← Tidak akan memperbesar, hanya memperkecil jika perlu
            alignment: Alignment.center,
            child: SizedBox(
              width: width ?? height,
              height: height,
              child: Lottie.asset(lottiePath, repeat: true, animate: true),
            ),
          );
        }

        return Image.asset(
          imagePath,
          height: height,
          width: width,
          fit: fit,
          errorBuilder: (context, error, stackTrace) {
            return fallback ?? _buildDefaultLogo();
          },
        );
      },
    );
  }

  Future<bool> _checkLottieExists() async {
    try {
      await rootBundle.loadString(lottiePath);
      return true;
    } catch (e) {
      return false;
    }
  }

  Widget _buildDefaultLogo() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.medical_services,
          size: height * 0.7,
          color: const Color(0xFF01579B),
        ),
        const SizedBox(height: 4),
        Text(
          'HOIP',
          style: TextStyle(
            fontSize: height * 0.15,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF01579B),
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }
}
