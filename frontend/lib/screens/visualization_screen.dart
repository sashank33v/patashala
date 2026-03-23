import 'package:flutter/material.dart';

import '../api_service.dart';
import '../widgets/chemistry_visualizations.dart';
import '../widgets/mensuration_visualizations.dart';
import '../widgets/neon_ui.dart';
import '../widgets/physics_visualizations.dart';
import '../widgets/trig_visualizations.dart';
import 'quiz_screen.dart';

class _TopicLearningContent {
  final List<String> notes;
  final List<String> quickQuestions;
  final Map<String, String> keywordResponses;

  const _TopicLearningContent({
    required this.notes,
    required this.quickQuestions,
    required this.keywordResponses,
  });
}

class VisualizationScreen extends StatefulWidget {
  final int userId;
  final Map<String, dynamic> topic;

  const VisualizationScreen(
      {super.key, required this.userId, required this.topic});

  @override
  State<VisualizationScreen> createState() => _VisualizationScreenState();
}

class _VisualizationScreenState extends State<VisualizationScreen> {
  bool completed = false;

  @override
  Widget build(BuildContext context) {
    final id = widget.topic['id'].toString();
    final content = _contentForTopic(id);

    return Scaffold(
      appBar: AppBar(
          title: Text(widget.topic['title']?.toString() ?? 'Visualization')),
      body: MeshBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.topic['title']?.toString() ?? '',
                          style: const TextStyle(
                              fontSize: 23, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 6),
                      Text(
                          widget.topic['description']?.toString() ??
                              'Interactive explorer',
                          style: const TextStyle(color: NeonPalette.subtext)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final wide = constraints.maxWidth > 980;
                    final viBoard = GlassCard(
                      child: _buildVisualizationHub(id),
                    );
                    final noteBoard = GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _NotesPanel(
                            topicTitle:
                                widget.topic['title']?.toString() ?? 'Topic',
                            notes: content.notes,
                          ),
                          const SizedBox(height: 14),
                          _StudyChatPanel(
                            topicTitle:
                                widget.topic['title']?.toString() ?? 'Topic',
                            content: content,
                          ),
                        ],
                      ),
                    );

                    if (!wide) {
                      return Column(
                        children: [
                          viBoard,
                          const SizedBox(height: 10),
                          noteBoard,
                        ],
                      );
                    }
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 3, child: viBoard),
                        const SizedBox(width: 12),
                        Expanded(flex: 2, child: noteBoard),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: NeonButton(
                        onTap: () async {
                          if (!id.contains('tangent') &&
                              !id.contains('interference')) {
                            await ApiService.postProgress(
                                userId: widget.userId,
                                topic: id,
                                completed: true);
                          }
                          if (!mounted) return;
                          setState(() => completed = true);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(completed ? Icons.check_circle : Icons.flag,
                                size: 18),
                            const SizedBox(width: 8),
                            Text(completed ? 'Completed' : 'Mark Complete'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: NeonButton(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => QuizScreen(
                                  userId: widget.userId, topic: widget.topic)),
                        ),
                        child: const Center(child: Text('Mini Quiz')),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVisualizationHub(String id) {
    if (id == 'chem-reaction-kinetics') {
      return const ReactionKineticsVisualizer();
    }
    if (id == 'chem-equilibrium') {
      return const EquilibriumVisualizer();
    }
    if (id == 'chem-molarity-lab') {
      return const MolarityLabVisualizer();
    }
    if (id == 'chem-spectroscopy') {
      return const SpectroscopyVisualizer();
    }
    if (id == 'phy-electric-field') {
      return const ElectricFieldVisualizer();
    }
    if (id == 'phy-magnetism') {
      return const MagneticFieldVisualizer();
    }
    if (id == 'phy-projectile-motion') {
      return const ProjectileVisualizer();
    }
    if (id == 'phy-wave-motion') {
      return const InterferenceVisualizer();
    }
    if (id.startsWith('mens-')) {
      return MensurationVisualizationHub(topicId: id);
    }
    return TrigVisualizationHub(topicId: id);
  }

  _TopicLearningContent _contentForTopic(String topicId) {
    switch (topicId) {
      case 'trig-right-triangle':
        return const _TopicLearningContent(
          notes: [
            'A right triangle always has one angle equal to 90°.',
            'The hypotenuse is the side opposite the 90° angle.',
            'The hypotenuse is always the longest side in the triangle.',
            'The opposite side is the side across from the chosen angle.',
            'The adjacent side is the side next to the chosen angle.',
            'If the angle gets bigger, the opposite side usually gets longer.',
            'If the angle gets bigger, the adjacent side usually gets shorter.',
            'Sine = opposite / hypotenuse.',
            'Cosine = adjacent / hypotenuse.',
            'Tangent = opposite / adjacent.',
          ],
          quickQuestions: [
            'What is the hypotenuse?',
            'How do I find the opposite side?',
            'What happens when the angle increases?',
          ],
          keywordResponses: {
            'hypotenuse':
                'The hypotenuse is the longest side. It is always opposite the 90° angle.',
            'opposite':
                'The opposite side is the side directly across from the angle you are focusing on.',
            'adjacent':
                'The adjacent side is next to the selected angle, but it is not the hypotenuse.',
            'formula':
                'Use sine = opposite/hypotenuse, cosine = adjacent/hypotenuse, and tangent = opposite/adjacent.',
            'angle':
                'When the angle grows, the opposite side grows and the adjacent side usually becomes smaller.',
          },
        );
      case 'trig-sine-cosine':
        return const _TopicLearningContent(
          notes: [
            'Sine shows the vertical position of a point on the unit circle.',
            'Cosine shows the horizontal position of a point on the unit circle.',
            'A unit circle has radius 1.',
            'At 0°, cosine is 1 and sine is 0.',
            'At 90°, cosine is 0 and sine is 1.',
            'At 180°, cosine is -1 and sine is 0.',
            'At 270°, cosine is 0 and sine is -1.',
            'The sine graph rises and falls smoothly.',
            'The cosine graph also changes smoothly and repeats in cycles.',
            'Both sine and cosine repeat every 360°.',
          ],
          quickQuestions: [
            'What does sine mean here?',
            'What does cosine mean here?',
            'Why do the graphs repeat?',
          ],
          keywordResponses: {
            'sine':
                'Sine tells you how high or low the rotating point is on the unit circle.',
            'cosine':
                'Cosine tells you how far left or right the rotating point is on the unit circle.',
            'graph':
                'The graph repeats because circular motion repeats after one full turn.',
            'repeat':
                'Sine and cosine repeat every 360° because the point returns to the same place on the circle.',
            'unit circle':
                'The unit circle is a circle with radius 1, which makes sine and cosine easy to read.',
          },
        );
      case 'trig-angle-rotation':
        return const _TopicLearningContent(
          notes: [
            'An angle shows how far a line has turned from its starting point.',
            'Positive rotation usually moves anti-clockwise.',
            '0° starts on the positive x-axis.',
            '90° points straight up.',
            '180° points to the left.',
            '270° points down.',
            '360° is one full turn back to the start.',
            'The final point on the circle changes as the angle changes.',
            'The quadrant tells you the sign of sine and cosine.',
            'Rotation helps connect geometry, graphs, and trigonometric values.',
          ],
          quickQuestions: [
            'What is a full rotation?',
            'Why do quadrants matter?',
            'Where does rotation start?',
          ],
          keywordResponses: {
            'quadrant':
                'Quadrants matter because sine, cosine, and tangent can change sign in different regions of the circle.',
            'full rotation':
                'A full rotation is 360°. After that, the line comes back to its starting direction.',
            'start':
                'Rotation starts from the positive x-axis at 0°.',
            'sin':
                'Sine changes with the vertical position of the rotating point.',
            'cos':
                'Cosine changes with the horizontal position of the rotating point.',
          },
        );
      case 'trig-shadow-length':
        return const _TopicLearningContent(
          notes: [
            'A shadow forms when light is blocked by an object.',
            'When the sun is low, the shadow becomes longer.',
            'When the sun is high, the shadow becomes shorter.',
            'A taller object usually makes a longer shadow.',
            'The object, its shadow, and the sun ray form a triangle.',
            'That triangle can be studied using trigonometry.',
            'Tangent connects angle, height, and shadow length.',
            'Formula: tan(theta) = height / shadow.',
            'So shadow = height / tan(theta).',
            'This idea is useful in real life for measuring heights indirectly.',
          ],
          quickQuestions: [
            'Why does the shadow get shorter?',
            'What formula is used here?',
            'How does object height affect shadow?',
          ],
          keywordResponses: {
            'formula':
                'Use tan(theta) = height/shadow. Rearranged, shadow = height / tan(theta).',
            'shorter':
                'The shadow gets shorter when the sun angle increases because the sunlight is coming from a steeper direction.',
            'height':
                'If the object height increases and the sun angle stays the same, the shadow becomes longer.',
            'triangle':
                'The object and the shadow make a right triangle, which is why trigonometry works here.',
            'sun':
                'A higher sun means steeper rays and a shorter shadow.',
          },
        );
      case 'mens-rectangle-area':
        return const _TopicLearningContent(
          notes: [
            'A rectangle has opposite sides equal.',
            'A rectangle has four right angles.',
            'Length tells how long the shape is.',
            'Width tells how wide the shape is.',
            'Area means the space inside the shape.',
            'Area of a rectangle = length x width.',
            'If length increases, area increases.',
            'If width increases, area also increases.',
            'A grid helps you count square units easily.',
            'Perimeter is different from area because perimeter measures only the boundary.',
          ],
          quickQuestions: [
            'What is the area formula?',
            'What is the difference between area and perimeter?',
            'Why is the grid useful?',
          ],
          keywordResponses: {
            'area':
                'Area means the amount of space inside the rectangle. Use length x width.',
            'perimeter':
                'Perimeter is the total boundary around the rectangle, not the inside space.',
            'grid':
                'The grid breaks the rectangle into square units so the area is easier to count.',
            'length':
                'Length is the longer horizontal measure in this activity.',
            'width':
                'Width is the vertical measure paired with the length.',
          },
        );
      case 'mens-square-area':
        return const _TopicLearningContent(
          notes: [
            'A square has four equal sides.',
            'A square has four right angles.',
            'Because all sides are equal, one side can describe the whole shape.',
            'Area means the space inside the square.',
            'Area of a square = side x side.',
            'This can also be written as side squared.',
            'If the side becomes bigger, area grows quickly.',
            'Perimeter of a square = 4 x side.',
            'Area and perimeter are different measurements.',
            'A grid helps you see why side x side gives the total area.',
          ],
          quickQuestions: [
            'Why is the formula side x side?',
            'What is square perimeter?',
            'How is area different from perimeter?',
          ],
          keywordResponses: {
            'formula':
                'The formula is side x side because both the length and width are the same in a square.',
            'perimeter':
                'Perimeter of a square is 4 x side because all four edges are equal.',
            'area':
                'Area is the inside space. For a square, multiply one side by itself.',
            'equal':
                'All sides are equal in a square, which makes it a special rectangle.',
            'grid':
                'The grid shows rows and columns with the same count, so side x side makes sense visually.',
          },
        );
      case 'mens-perimeter':
        return const _TopicLearningContent(
          notes: [
            'Perimeter means the total distance around a shape.',
            'It measures the outside boundary only.',
            'Perimeter is measured in normal units, not square units.',
            'For a rectangle, add all four sides.',
            'Rectangle perimeter = 2 x (length + width).',
            'For a square, all sides are equal.',
            'Square perimeter = 4 x side.',
            'If any side becomes longer, perimeter increases.',
            'Area and perimeter are not the same thing.',
            'Tracing the shape boundary is a good way to understand perimeter.',
          ],
          quickQuestions: [
            'What does perimeter mean?',
            'What is the rectangle formula?',
            'What is the square formula?',
          ],
          keywordResponses: {
            'perimeter':
                'Perimeter is the total distance around the outside of the shape.',
            'rectangle':
                'For rectangles, opposite sides are equal, so 2 x (length + width) gives the full boundary.',
            'square':
                'For squares, all sides match, so perimeter is 4 x side.',
            'units':
                'Perimeter uses units like cm or m, not square units.',
            'area':
                'Area measures inside space. Perimeter measures the outside edge.',
          },
        );
      case 'mens-grid-area':
        return const _TopicLearningContent(
          notes: [
            'Grid area means finding area by counting squares on a grid.',
            'A full square counts as 1 square unit.',
            'Two half squares together count as 1 full square.',
            'This method is useful for irregular shapes.',
            'First count all full squares.',
            'Then count the half squares.',
            'Divide the number of half squares by 2.',
            'Add full squares and half-square pairs together.',
            'The final answer is an estimated area in square units.',
            'This method helps when formulas are not easy to use directly.',
          ],
          quickQuestions: [
            'How do half squares work?',
            'Why is this method useful?',
            'What is the final formula?',
          ],
          keywordResponses: {
            'half':
                'Two half squares make about one full square, so half squares are added in pairs.',
            'formula':
                'Use area = full squares + half squares / 2.',
            'irregular':
                'This method is useful for irregular shapes because exact formulas may be harder to apply.',
            'square units':
                'The answer is in square units because area measures surface, not length.',
            'count':
                'Count full squares first, then combine the half squares.',
          },
        );
      case 'phy-projectile-motion':
        return const _TopicLearningContent(
          notes: [
            'Projectile motion happens when an object is thrown into the air.',
            'The object moves forward and also moves up and down.',
            'Gravity always pulls the object downward.',
            'Because of gravity, the path becomes curved.',
            'That curved path is called a parabola.',
            'Launch angle changes the shape of the path.',
            'Launch speed changes the range and height.',
            'A higher speed usually makes the object travel farther.',
            'Too small or too large an angle can reduce the range.',
            'Projectile motion combines horizontal motion and vertical motion.',
          ],
          quickQuestions: [
            'Why is the path curved?',
            'How does speed change the motion?',
            'What does launch angle do?',
          ],
          keywordResponses: {
            'gravity':
                'Gravity pulls the object downward all the time, which bends the path.',
            'curved':
                'The path is curved because forward motion continues while gravity pulls downward.',
            'speed':
                'More launch speed usually gives more height and more range.',
            'angle':
                'The launch angle changes both the height and the distance traveled.',
            'parabola':
                'A projectile usually follows a parabolic path when air resistance is ignored.',
          },
        );
      case 'phy-wave-motion':
        return const _TopicLearningContent(
          notes: [
            'A wave carries energy from one place to another.',
            'A wave has crests and troughs.',
            'Amplitude shows how tall the wave is.',
            'Frequency tells how often waves repeat.',
            'Higher frequency means more waves in the same time.',
            'Wavelength is the distance between matching points on waves.',
            'If frequency increases, wavelength often becomes shorter.',
            'When two waves meet, they interfere.',
            'Constructive interference makes bigger waves.',
            'Destructive interference makes smaller waves.',
          ],
          quickQuestions: [
            'What is amplitude?',
            'What is interference?',
            'How are frequency and wavelength related?',
          ],
          keywordResponses: {
            'amplitude':
                'Amplitude is the height of the wave from its middle line to a crest or trough.',
            'interference':
                'Interference happens when two waves meet and combine.',
            'constructive':
                'Constructive interference happens when waves add together and make a larger result.',
            'destructive':
                'Destructive interference happens when waves cancel part of each other.',
            'frequency':
                'Frequency tells how many wave cycles happen in a given time.',
          },
        );
      case 'phy-electric-field':
        return const _TopicLearningContent(
          notes: [
            'An electric field is the region where a charge feels force.',
            'Positive and negative charges create electric fields.',
            'Field lines help show the direction of the force.',
            'Field lines move away from positive charges.',
            'Field lines move toward negative charges.',
            'A test positive charge follows the field direction.',
            'Closer to a charge, the field is stronger.',
            'Stronger fields are shown by denser field lines.',
            'Moving the charges changes the whole field pattern.',
            'Electric fields help explain attraction and repulsion.',
          ],
          quickQuestions: [
            'What is an electric field?',
            'Why do field lines curve?',
            'How do I tell where the field is stronger?',
          ],
          keywordResponses: {
            'electric field':
                'An electric field is the area around a charge where another charge feels force.',
            'positive':
                'Field lines leave positive charges and point outward.',
            'negative':
                'Field lines move toward negative charges.',
            'stronger':
                'The field is stronger where field lines are packed more closely together.',
            'force':
                'A charge placed in the electric field will experience a push or pull.',
          },
        );
      case 'chem-reaction-kinetics':
        return const _TopicLearningContent(
          notes: [
            'Reaction kinetics studies how fast a reaction happens.',
            'Some reactions are slow and some are fast.',
            'Concentration affects reaction speed.',
            'More concentration usually means more particle collisions.',
            'Temperature also affects reaction speed.',
            'Higher temperature usually makes particles move faster.',
            'Faster particles collide more often and with more energy.',
            'More successful collisions increase the reaction rate.',
            'A rate change does not always mean the amount of product is different at the end.',
            'Kinetics helps explain real lab behavior and industrial processes.',
          ],
          quickQuestions: [
            'What changes reaction speed?',
            'Why does temperature matter?',
            'Why does concentration matter?',
          ],
          keywordResponses: {
            'temperature':
                'Higher temperature usually speeds up the reaction because particles move faster and collide more effectively.',
            'concentration':
                'Higher concentration means more particles are available to collide, which usually increases the rate.',
            'collision':
                'Reactions need particles to collide in the right way and with enough energy.',
            'rate':
                'Reaction rate tells how quickly reactants turn into products.',
            'fast':
                'A reaction becomes faster when the conditions create more successful collisions.',
          },
        );
      case 'chem-equilibrium':
        return const _TopicLearningContent(
          notes: [
            'Chemical equilibrium happens when forward and backward reactions balance.',
            'At equilibrium, both reactions still continue.',
            'The amounts may stay constant even though reactions continue.',
            'A change in conditions is called a stress.',
            'Stress can come from temperature, pressure, or concentration.',
            'Le Chatelier principle predicts how the system responds.',
            'The system shifts to reduce the stress applied to it.',
            'Adding more reactant can push the system toward products.',
            'Changing temperature can change which side is favored.',
            'Equilibrium is dynamic, not static.',
          ],
          quickQuestions: [
            'What is equilibrium?',
            'What does Le Chatelier mean?',
            'Why does the system shift?',
          ],
          keywordResponses: {
            'equilibrium':
                'Equilibrium means the forward and backward reactions happen at equal rates.',
            'shift':
                'The system shifts to oppose the change and reduce the stress.',
            'le chatelier':
                'Le Chatelier principle says an equilibrium system responds in a way that reduces the applied stress.',
            'temperature':
                'Temperature changes can strongly affect which side of equilibrium is favored.',
            'concentration':
                'Adding or removing reactants or products can move the equilibrium position.',
          },
        );
      case 'chem-molarity-lab':
        return const _TopicLearningContent(
          notes: [
            'Molarity tells how concentrated a solution is.',
            'It compares moles of solute with liters of solution.',
            'Formula: molarity = moles / volume.',
            'A higher molarity means a stronger concentration.',
            'A lower molarity means a more dilute solution.',
            'If you add more solute, molarity increases.',
            'If you add more solvent, molarity decreases.',
            'Volume matters because the same solute amount can be spread differently.',
            'Lab solutions must often be prepared at a precise molarity.',
            'This idea is important in chemistry experiments and medicine.',
          ],
          quickQuestions: [
            'What is molarity?',
            'What is the formula?',
            'How does dilution change molarity?',
          ],
          keywordResponses: {
            'molarity':
                'Molarity is the number of moles of solute in one liter of solution.',
            'formula':
                'Use molarity = moles / volume in liters.',
            'dilution':
                'Dilution lowers molarity because the same solute is spread through a larger volume.',
            'solute':
                'The solute is the substance being dissolved in the solution.',
            'volume':
                'Volume matters because concentration depends on how much space the solution takes up.',
          },
        );
      case 'chem-spectroscopy':
        return const _TopicLearningContent(
          notes: [
            'Spectroscopy studies light from substances.',
            'Different substances can produce different light patterns.',
            'Wavelength tells the color of visible light.',
            'Shorter wavelengths are toward violet.',
            'Longer wavelengths are toward red.',
            'Intensity tells how strong the light signal is.',
            'Bright lines mean stronger emission at that wavelength.',
            'A spectrum can help identify a substance.',
            'Atoms emit light when electrons change energy levels.',
            'Spectroscopy is widely used in labs, astronomy, and materials testing.',
          ],
          quickQuestions: [
            'What is wavelength?',
            'What does intensity mean?',
            'Why is spectroscopy useful?',
          ],
          keywordResponses: {
            'wavelength':
                'Wavelength tells you the position of the color in the spectrum.',
            'intensity':
                'Intensity shows how strong or bright the signal is.',
            'spectrum':
                'A spectrum is the pattern of light emitted or absorbed by a substance.',
            'color':
                'Different wavelengths correspond to different visible colors.',
            'electrons':
                'Electrons can emit light when they move between energy levels.',
          },
        );
      case 'phy-magnetism':
        return const _TopicLearningContent(
          notes: [
            'A magnetic field is the region where magnetic force can act.',
            'Electric current can create a magnetic field.',
            'Around a straight current-carrying wire, the field forms circles.',
            'The direction of the field depends on current direction.',
            'A compass can show the field direction.',
            'A stronger current creates a stronger magnetic field.',
            'Field lines help us picture the field pattern.',
            'Closer to the wire, the field is stronger.',
            'Magnetism and electricity are closely connected.',
            'This idea is important in motors, generators, and electromagnets.',
          ],
          quickQuestions: [
            'How does current create magnetism?',
            'Why are the field lines circular?',
            'What changes field strength?',
          ],
          keywordResponses: {
            'current':
                'Electric current creates a magnetic field around the conductor.',
            'circular':
                'The field lines are circular around a straight wire because of how the magnetic field forms around moving charges.',
            'stronger':
                'A larger current usually creates a stronger magnetic field.',
            'compass':
                'A compass aligns with the magnetic field direction.',
            'field':
                'The magnetic field is strongest near the conductor and weaker farther away.',
          },
        );
      default:
        return const _TopicLearningContent(
          notes: [
            'Start by moving one control at a time.',
            'Notice which part of the visual changes first.',
            'Try small changes before big changes.',
            'Look for patterns that repeat.',
            'Connect the picture with the numbers shown.',
            'Ask what increases, decreases, or stays the same.',
            'Use the notes to guide your observation.',
            'Repeat the activity with different values.',
            'Check your understanding with the quiz.',
            'Learning becomes stronger when you observe and explain the change yourself.',
          ],
          quickQuestions: [
            'What should I observe first?',
            'How do I use the controls better?',
            'How can I study this topic quickly?',
          ],
          keywordResponses: {
            'observe':
                'Start by changing one control and watching one visual change. This makes the pattern easier to notice.',
            'controls':
                'Use one control at a time first, then combine changes after you understand each effect.',
            'study':
                'Read the notes, test the visual with small changes, then try the quiz to confirm your understanding.',
            'pattern':
                'Look for what grows, shrinks, repeats, rotates, or changes sign.',
            'quiz':
                'Use the quiz after you can explain the visual change in your own words.',
          },
        );
    }
  }
}

class _NotesPanel extends StatelessWidget {
  final String topicTitle;
  final List<String> notes;

  const _NotesPanel({required this.topicTitle, required this.notes});

  @override
  Widget build(BuildContext context) {
    final titleColor = AdaptiveColors.text(context);
    final subtextColor = AdaptiveColors.subtext(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Reading Notes',
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.w900, color: titleColor)),
        const SizedBox(height: 6),
        Text(topicTitle,
            style: TextStyle(color: subtextColor, fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        ...notes.asMap().entries.map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white10
                            : const Color(0x220F172A),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Text('${e.key + 1}',
                          style: TextStyle(
                              fontSize: 12,
                              color: titleColor,
                              fontWeight: FontWeight.w800)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                        child: Text(e.value,
                            style:
                                TextStyle(color: subtextColor, height: 1.35))),
                  ],
                ),
              ),
            ),
      ],
    );
  }
}

class _StudyChatPanel extends StatefulWidget {
  final String topicTitle;
  final _TopicLearningContent content;

  const _StudyChatPanel({
    required this.topicTitle,
    required this.content,
  });

  @override
  State<_StudyChatPanel> createState() => _StudyChatPanelState();
}

class _StudyChatPanelState extends State<_StudyChatPanel> {
  final TextEditingController _controller = TextEditingController();
  late final List<_ChatMessage> _messages;

  @override
  void initState() {
    super.initState();
    _messages = [
      _ChatMessage(
        text:
            'I am your study helper for ${widget.topicTitle}. Ask a short question, or tap a quick question below.',
        isUser: false,
      ),
    ];
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _sendQuestion(String text) {
    final question = text.trim();
    if (question.isEmpty) return;

    setState(() {
      _messages.add(_ChatMessage(text: question, isUser: true));
      _messages.add(
        _ChatMessage(
          text: _buildReply(question),
          isUser: false,
        ),
      );
      _controller.clear();
    });
  }

  String _buildReply(String question) {
    final lower = question.toLowerCase();
    for (final entry in widget.content.keywordResponses.entries) {
      if (lower.contains(entry.key)) {
        return entry.value;
      }
    }

    if (lower.contains('summary') || lower.contains('explain')) {
      return widget.content.notes.take(3).join(' ');
    }

    if (lower.contains('formula')) {
      return widget.content.notes
          .where((note) =>
              note.contains('=') ||
              note.toLowerCase().contains('formula') ||
              note.toLowerCase().contains('use '))
          .take(2)
          .join(' ');
    }

    return 'Start with this idea: ${widget.content.notes.first} Then remember: ${widget.content.notes[1]}';
  }

  @override
  Widget build(BuildContext context) {
    final titleColor = AdaptiveColors.text(context);
    final subtextColor = AdaptiveColors.subtext(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AI Study Chat',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: titleColor,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Ask simple questions for quick topic help.',
          style: TextStyle(color: subtextColor, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.content.quickQuestions
              .map(
                (question) => ActionChip(
                  backgroundColor:
                      isDark ? Colors.white10 : const Color(0x140F172A),
                  label: Text(question),
                  onPressed: () => _sendQuestion(question),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 180, maxHeight: 280),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: isDark ? Colors.white.withOpacity(0.04) : Colors.white,
            border: Border.all(
              color: isDark ? Colors.white10 : const Color(0x220F172A),
            ),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: _messages.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final message = _messages[index];
              final bubbleColor = message.isUser
                  ? NeonPalette.cyan.withOpacity(isDark ? 0.20 : 0.14)
                  : (isDark ? Colors.white10 : const Color(0xFFF3F4F6));
              return Align(
                alignment: message.isUser
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 320),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: bubbleColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    message.text,
                    style: TextStyle(
                      color: message.isUser ? titleColor : subtextColor,
                      height: 1.35,
                      fontWeight:
                          message.isUser ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                onSubmitted: _sendQuestion,
                decoration: const InputDecoration(
                  hintText: 'Ask a question about this topic',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: () => _sendQuestion(_controller.text),
              icon: const Icon(Icons.send_rounded),
            ),
          ],
        ),
      ],
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isUser;

  const _ChatMessage({
    required this.text,
    required this.isUser,
  });
}
