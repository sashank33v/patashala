class QuizBank {
  static List<Map<String, dynamic>> questionsForTopic(String topicId) {
    final bank = <String, List<Map<String, dynamic>>>{
      'trig-right-triangle': [
        {'q': 'A right triangle has one angle of?', 'options': ['90°', '45°', '30°'], 'a': 0},
        {'q': 'Opposite side is opposite to?', 'options': ['Selected angle', 'Right angle only', 'Longest side'], 'a': 0},
        {'q': 'If angle gets bigger, opposite side usually?', 'options': ['Increases', 'Decreases', 'Same always'], 'a': 0},
      ],
      'trig-sine-cosine': [
        {'q': 'Sine and cosine values are shown on?', 'options': ['Graph', 'Map', 'Calendar'], 'a': 0},
        {'q': 'Cosine is linked to which axis on unit circle?', 'options': ['x-axis', 'y-axis', 'z-axis'], 'a': 0},
        {'q': 'Sine and cosine help describe?', 'options': ['Rotation and triangles', 'Spelling', 'Mass'], 'a': 0},
      ],
      'trig-angle-rotation': [
        {'q': 'Positive rotation in math is usually?', 'options': ['Anti-clockwise', 'Clockwise', 'Random'], 'a': 0},
        {'q': '0° starts on which side?', 'options': ['Positive x-axis', 'Top of circle', 'Left side'], 'a': 0},
        {'q': '360° means?', 'options': ['One full turn', 'Half turn', 'No turn'], 'a': 0},
      ],
      'trig-shadow-length': [
        {'q': 'When sun is high, shadow is usually?', 'options': ['Shorter', 'Longer', 'Unchanged'], 'a': 0},
        {'q': 'Shadow forms because light travels?', 'options': ['In straight lines', 'In circles', 'In zigzags'], 'a': 0},
        {'q': 'If object height increases, shadow can?', 'options': ['Increase', 'Disappear', 'Become negative'], 'a': 0},
      ],
      'mens-rectangle-area': [
        {'q': 'Area of rectangle is?', 'options': ['Length x Width', 'Length + Width', '2 x Width'], 'a': 0},
        {'q': 'Area unit is usually?', 'options': ['Square units', 'Units', 'Degrees'], 'a': 0},
        {'q': 'If width doubles, area?', 'options': ['Doubles', 'Halves', 'No change'], 'a': 0},
      ],
      'mens-square-area': [
        {'q': 'All sides of a square are?', 'options': ['Equal', 'Different', 'Curved'], 'a': 0},
        {'q': 'Area of square is?', 'options': ['Side x Side', '4 x Side', 'Side + Side'], 'a': 0},
        {'q': 'Perimeter of square is?', 'options': ['4 x Side', '2 x Side', 'Side²'], 'a': 0},
      ],
      'mens-perimeter': [
        {'q': 'Perimeter means?', 'options': ['Total boundary', 'Inside space', 'Volume'], 'a': 0},
        {'q': 'Rectangle perimeter is?', 'options': ['2 x (L + W)', 'L x W', 'L + W'], 'a': 0},
        {'q': 'Perimeter unit is?', 'options': ['Units', 'Square units', 'Cubic units'], 'a': 0},
      ],
      'mens-grid-area': [
        {'q': 'Grid method helps by?', 'options': ['Counting squares', 'Guessing colors', 'Ignoring size'], 'a': 0},
        {'q': 'Two half squares are about?', 'options': ['One full square', 'Two full squares', 'Zero'], 'a': 0},
        {'q': 'Area by grid is measured in?', 'options': ['Square units', 'Degrees', 'Seconds'], 'a': 0},
      ],
    };

    return bank[topicId] ??
        [
          {'q': 'Learning is best with?', 'options': ['Practice', 'Skipping', 'Guessing'], 'a': 0},
          {'q': 'Visual tools help with?', 'options': ['Understanding', 'Confusion only', 'Nothing'], 'a': 0},
          {'q': 'Try simulation again to?', 'options': ['Learn deeper', 'Waste time', 'Forget'], 'a': 0},
        ];
  }
}
