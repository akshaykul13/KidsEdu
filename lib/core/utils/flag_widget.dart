import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// High-quality flag widget using flagcdn.com with offline caching
class FlagWidget extends StatelessWidget {
  final String countryCode;
  final double size;

  const FlagWidget({
    super.key,
    required this.countryCode,
    this.size = 80,
  });

  @override
  Widget build(BuildContext context) {
    final code = countryCode.toLowerCase();
    // Use w320 for good quality on most devices
    final flagUrl = 'https://flagcdn.com/w320/$code.png';
    final emoji = _flagEmojis[countryCode.toUpperCase()] ?? '🏳️';

    return CachedNetworkImage(
      imageUrl: flagUrl,
      width: size * 1.5,
      height: size,
      fit: BoxFit.contain,
      placeholder: (context, url) => _buildPlaceholder(emoji),
      errorWidget: (context, url, error) => _buildFallback(emoji),
    );
  }

  Widget _buildPlaceholder(String emoji) {
    return SizedBox(
      width: size * 1.5,
      height: size,
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.grey.shade400,
          ),
        ),
      ),
    );
  }

  Widget _buildFallback(String emoji) {
    return SizedBox(
      width: size * 1.5,
      height: size,
      child: Center(
        child: Text(emoji, style: TextStyle(fontSize: size * 0.8)),
      ),
    );
  }

  // Country code to emoji mapping for fallback
  static const Map<String, String> _flagEmojis = {
    'US': '🇺🇸', 'GB': '🇬🇧', 'CA': '🇨🇦', 'FR': '🇫🇷', 'DE': '🇩🇪',
    'IT': '🇮🇹', 'ES': '🇪🇸', 'JP': '🇯🇵', 'CN': '🇨🇳', 'IN': '🇮🇳',
    'BR': '🇧🇷', 'AU': '🇦🇺', 'MX': '🇲🇽', 'KR': '🇰🇷', 'RU': '🇷🇺',
    'PK': '🇵🇰', 'BD': '🇧🇩', 'IL': '🇮🇱', 'VN': '🇻🇳', 'AR': '🇦🇷',
    'PT': '🇵🇹', 'CH': '🇨🇭', 'JM': '🇯🇲', 'UA': '🇺🇦', 'PL': '🇵🇱',
    'ID': '🇮🇩', 'IE': '🇮🇪', 'TR': '🇹🇷', 'GR': '🇬🇷', 'SE': '🇸🇪',
    'NZ': '🇳🇿', 'ZA': '🇿🇦', 'EG': '🇪🇬', 'NG': '🇳🇬', 'TH': '🇹🇭',
    'KE': '🇰🇪', 'CL': '🇨🇱', 'PE': '🇵🇪', 'CU': '🇨🇺',
  };
}

/// Country data with codes for flag lookup
class CountryData {
  final String name;
  final String code;

  const CountryData(this.name, this.code);

  // All countries with their codes
  static const List<CountryData> all = [
    CountryData('United States', 'US'),
    CountryData('United Kingdom', 'GB'),
    CountryData('Canada', 'CA'),
    CountryData('France', 'FR'),
    CountryData('Germany', 'DE'),
    CountryData('Italy', 'IT'),
    CountryData('Spain', 'ES'),
    CountryData('Japan', 'JP'),
    CountryData('China', 'CN'),
    CountryData('India', 'IN'),
    CountryData('Brazil', 'BR'),
    CountryData('Australia', 'AU'),
    CountryData('Mexico', 'MX'),
    CountryData('South Korea', 'KR'),
    CountryData('Russia', 'RU'),
    CountryData('Pakistan', 'PK'),
    CountryData('Bangladesh', 'BD'),
    CountryData('Israel', 'IL'),
    CountryData('Vietnam', 'VN'),
    CountryData('Argentina', 'AR'),
    CountryData('Portugal', 'PT'),
    CountryData('Switzerland', 'CH'),
    CountryData('Jamaica', 'JM'),
    CountryData('Ukraine', 'UA'),
    CountryData('Poland', 'PL'),
    CountryData('Indonesia', 'ID'),
    CountryData('Ireland', 'IE'),
    CountryData('Turkey', 'TR'),
    CountryData('Greece', 'GR'),
    CountryData('Sweden', 'SE'),
    CountryData('New Zealand', 'NZ'),
    CountryData('South Africa', 'ZA'),
    CountryData('Egypt', 'EG'),
    CountryData('Nigeria', 'NG'),
    CountryData('Thailand', 'TH'),
    CountryData('Kenya', 'KE'),
    CountryData('Chile', 'CL'),
    CountryData('Peru', 'PE'),
    CountryData('Cuba', 'CU'),
  ];
}
