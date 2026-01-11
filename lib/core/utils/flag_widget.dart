import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// High-quality flag widget with SVG support
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
    final svgData = _flagSvgData[countryCode.toUpperCase()];

    if (svgData != null) {
      return SvgPicture.string(
        svgData,
        width: size * 1.5,
        height: size,
        fit: BoxFit.contain,
      );
    }

    // Fallback to emoji
    final emoji = _flagEmojis[countryCode.toUpperCase()] ?? '🏳️';
    return Text(emoji, style: TextStyle(fontSize: size));
  }

  // Country code to emoji mapping
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

  // SVG data for flags (simple geometric flags that render well)
  static const Map<String, String> _flagSvgData = {
    // Japan - simple red circle on white
    'JP': '''<svg viewBox="0 0 900 600" xmlns="http://www.w3.org/2000/svg">
      <rect fill="#fff" width="900" height="600"/>
      <circle fill="#bc002d" cx="450" cy="300" r="180"/>
    </svg>''',

    // France - tricolor
    'FR': '''<svg viewBox="0 0 900 600" xmlns="http://www.w3.org/2000/svg">
      <rect fill="#002395" width="300" height="600"/>
      <rect fill="#fff" x="300" width="300" height="600"/>
      <rect fill="#ed2939" x="600" width="300" height="600"/>
    </svg>''',

    // Germany - tricolor horizontal
    'DE': '''<svg viewBox="0 0 900 600" xmlns="http://www.w3.org/2000/svg">
      <rect fill="#000" width="900" height="200"/>
      <rect fill="#dd0000" y="200" width="900" height="200"/>
      <rect fill="#ffcc00" y="400" width="900" height="200"/>
    </svg>''',

    // Italy - tricolor
    'IT': '''<svg viewBox="0 0 900 600" xmlns="http://www.w3.org/2000/svg">
      <rect fill="#009246" width="300" height="600"/>
      <rect fill="#fff" x="300" width="300" height="600"/>
      <rect fill="#ce2b37" x="600" width="300" height="600"/>
    </svg>''',

    // Ireland - tricolor
    'IE': '''<svg viewBox="0 0 900 600" xmlns="http://www.w3.org/2000/svg">
      <rect fill="#169b62" width="300" height="600"/>
      <rect fill="#fff" x="300" width="300" height="600"/>
      <rect fill="#ff883e" x="600" width="300" height="600"/>
    </svg>''',

    // Poland - bicolor
    'PL': '''<svg viewBox="0 0 900 600" xmlns="http://www.w3.org/2000/svg">
      <rect fill="#fff" width="900" height="300"/>
      <rect fill="#dc143c" y="300" width="900" height="300"/>
    </svg>''',

    // Ukraine - bicolor
    'UA': '''<svg viewBox="0 0 900 600" xmlns="http://www.w3.org/2000/svg">
      <rect fill="#005bbb" width="900" height="300"/>
      <rect fill="#ffd500" y="300" width="900" height="300"/>
    </svg>''',

    // Indonesia - bicolor
    'ID': '''<svg viewBox="0 0 900 600" xmlns="http://www.w3.org/2000/svg">
      <rect fill="#ff0000" width="900" height="300"/>
      <rect fill="#fff" y="300" width="900" height="300"/>
    </svg>''',

    // Bangladesh - red circle on green
    'BD': '''<svg viewBox="0 0 900 600" xmlns="http://www.w3.org/2000/svg">
      <rect fill="#006a4e" width="900" height="600"/>
      <circle fill="#f42a41" cx="400" cy="300" r="180"/>
    </svg>''',

    // Switzerland - white cross on red
    'CH': '''<svg viewBox="0 0 900 600" xmlns="http://www.w3.org/2000/svg">
      <rect fill="#ff0000" width="900" height="600"/>
      <rect fill="#fff" x="375" y="150" width="150" height="300"/>
      <rect fill="#fff" x="300" y="225" width="300" height="150"/>
    </svg>''',

    // Sweden - yellow cross on blue
    'SE': '''<svg viewBox="0 0 900 600" xmlns="http://www.w3.org/2000/svg">
      <rect fill="#006aa7" width="900" height="600"/>
      <rect fill="#fecc00" x="250" width="100" height="600"/>
      <rect fill="#fecc00" y="250" width="900" height="100"/>
    </svg>''',

    // Greece - stripes with cross
    'GR': '''<svg viewBox="0 0 900 600" xmlns="http://www.w3.org/2000/svg">
      <rect fill="#0d5eaf" width="900" height="600"/>
      <rect fill="#fff" y="67" width="900" height="67"/>
      <rect fill="#fff" y="200" width="900" height="67"/>
      <rect fill="#fff" y="333" width="900" height="67"/>
      <rect fill="#fff" y="467" width="900" height="67"/>
      <rect fill="#0d5eaf" width="333" height="333"/>
      <rect fill="#fff" x="133" width="67" height="333"/>
      <rect fill="#fff" y="133" width="333" height="67"/>
    </svg>''',

    // Thailand - horizontal stripes
    'TH': '''<svg viewBox="0 0 900 600" xmlns="http://www.w3.org/2000/svg">
      <rect fill="#a51931" width="900" height="600"/>
      <rect fill="#f4f5f8" y="100" width="900" height="400"/>
      <rect fill="#2d2a4a" y="200" width="900" height="200"/>
    </svg>''',

    // Nigeria - vertical tricolor
    'NG': '''<svg viewBox="0 0 900 600" xmlns="http://www.w3.org/2000/svg">
      <rect fill="#008751" width="300" height="600"/>
      <rect fill="#fff" x="300" width="300" height="600"/>
      <rect fill="#008751" x="600" width="300" height="600"/>
    </svg>''',

    // Peru - vertical tricolor
    'PE': '''<svg viewBox="0 0 900 600" xmlns="http://www.w3.org/2000/svg">
      <rect fill="#d91023" width="300" height="600"/>
      <rect fill="#fff" x="300" width="300" height="600"/>
      <rect fill="#d91023" x="600" width="300" height="600"/>
    </svg>''',

    // Chile - flag with star
    'CL': '''<svg viewBox="0 0 900 600" xmlns="http://www.w3.org/2000/svg">
      <rect fill="#fff" width="900" height="300"/>
      <rect fill="#d52b1e" y="300" width="900" height="300"/>
      <rect fill="#0039a6" width="300" height="300"/>
      <polygon fill="#fff" points="150,75 165,120 215,120 175,150 190,195 150,165 110,195 125,150 85,120 135,120"/>
    </svg>''',

    // Turkey - crescent and star on red
    'TR': '''<svg viewBox="0 0 900 600" xmlns="http://www.w3.org/2000/svg">
      <rect fill="#e30a17" width="900" height="600"/>
      <circle fill="#fff" cx="350" cy="300" r="160"/>
      <circle fill="#e30a17" cx="390" cy="300" r="130"/>
      <polygon fill="#fff" points="555,300 495,330 515,270 475,240 540,240"/>
    </svg>''',

    // Vietnam - star on red
    'VN': '''<svg viewBox="0 0 900 600" xmlns="http://www.w3.org/2000/svg">
      <rect fill="#da251d" width="900" height="600"/>
      <polygon fill="#ffff00" points="450,120 490,240 620,240 515,320 555,440 450,360 345,440 385,320 280,240 410,240"/>
    </svg>''',
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
