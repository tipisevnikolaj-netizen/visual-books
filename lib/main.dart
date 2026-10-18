import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Scene {
  final String image;
  final String text;

  const Scene({required this.image, required this.text});
}

const List<Scene> scenes = [
  Scene(
    image: 'assets/scene_1.jpg',
    text: 'Весна пришла внезапно: за одну ночь сошёл снег, и в воздухе запахло талой землёй и первой зеленью.',
  ),
  Scene(
    image: 'assets/scene_2.jpg',
    text: 'К полудню небо потемнело, и на дорогу упали первые тяжёлые капли. Дождь пошёл стеной, смывая остатки зимы.',
  ),
  Scene(
    image: 'assets/scene_3.jpg',
    text: 'Герой укрылся под старым дубом и долго смотрел, как с ветвей стекает вода. Впервые за много дней ему было спокойно.',
  ),
];

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  runApp(const ReaderApp());
}

class ReaderApp extends StatelessWidget {
  const ReaderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ReaderScreen(),
    );
  }
}

// Круглая полупрозрачная кнопка (используем для «Назад» и для стрелок)
class RoundButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const RoundButton({super.key, required this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: onPressed == null ? 0.3 : 1.0,
      child: Container(
        width: 44,
        height: 44,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0x73000000),
        ),
        child: IconButton(
          padding: EdgeInsets.zero,
          icon: Icon(icon, color: Colors.white, size: 20),
          onPressed: onPressed,
        ),
      ),
    );
  }
}

// Главный экран: PageView + кнопка «Назад» + стрелки по бокам
class ReaderScreen extends StatefulWidget {
  const ReaderScreen({super.key});

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isFirst = _currentPage == 0;
    final isLast = _currentPage == scenes.length - 1;

    return Scaffold(
      backgroundColor: const Color(0xFF0B0D12),
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.horizontal,
            itemCount: scenes.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return ScenePage(scene: scenes[index]);
            },
          ),

          // Кнопка «Назад»
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 16, top: 8),
              child: RoundButton(
                icon: Icons.arrow_back_ios_new,
                onPressed: () => Navigator.maybePop(context),
              ),
            ),
          ),

          // Стрелка влево
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: RoundButton(
                icon: Icons.chevron_left,
                onPressed: isFirst ? null : () => _goToPage(_currentPage - 1),
              ),
            ),
          ),

          // Стрелка вправо
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: RoundButton(
                icon: Icons.chevron_right,
                onPressed: isLast ? null : () => _goToPage(_currentPage + 1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Одна страница-сцена: своя картинка, свой текст, своя анимация
class ScenePage extends StatefulWidget {
  final Scene scene;

  const ScenePage({super.key, required this.scene});

  @override
  State<ScenePage> createState() => _ScenePageState();
}

class _ScenePageState extends State<ScenePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat(reverse: true);

    _scale = Tween<double>(begin: 1.0, end: 1.18).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Stack(
      children: [
        SizedBox.expand(
          child: ScaleTransition(
            scale: _scale,
            child: Image.asset(
              widget.scene.image,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF1B1F2E),
                      Color(0xFF3A2B3A),
                      Color(0xFF7A4A35),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            padding: EdgeInsets.fromLTRB(24, 28, 24, 32 + bottomInset),
            decoration: const BoxDecoration(
              color: Color(0x99000000),
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Text(
              widget.scene.text,
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'Georgia',
                fontFamilyFallback: ['serif'],
                fontSize: 20,
                height: 1.6,
              ),
            ),
          ),
        ),
      ],
    );
  }
}