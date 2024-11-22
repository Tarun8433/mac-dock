import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:mac_dock/colors.dart';

void main() {
  runApp(const MaterialApp(
    home: MyHomePage(),
  ));
}

class NavItemController extends GetxController {
  final RxInt _selectedIndex = 0.obs;
  int get selectedIndex => _selectedIndex.value;
  void setSelectedIndex(int index) => _selectedIndex.value = index;

  final RxList<Map<String, dynamic>> _navItems = [
    {
      'icon': "assets/icons/deadpool.svg",
      'label': 'Home',
      'page': const Center(
          child: Text('Home Page', style: TextStyle(fontSize: 24))),
    },
    {
      'icon': "assets/icons/hulk.svg",
      'label': 'Search',
      'page': const Center(
          child: Text('Search Page', style: TextStyle(fontSize: 24))),
    },
    {
      'icon': "assets/icons/iron-man.svg",
      'label': 'Settings',
      'page': const Center(
          child: Text('Settings Page', style: TextStyle(fontSize: 24))),
    },
    {
      'icon': "assets/icons/spider-man.svg",
      'label': 'Calendar',
      'page': const Center(
          child: Text('Calendar Page', style: TextStyle(fontSize: 24))),
    },
    {
      'icon': "assets/icons/thor.svg",
      'label': 'Expand',
      'page': const Center(
          child: Text('Expand Page', style: TextStyle(fontSize: 24))),
    },
  ].obs;

  final RxDouble _animationValue = 1.0.obs;
  double get animationValue => _animationValue.value;
  void setAnimationValue(double value) => _animationValue.value = value;

  final RxList<double> _iconSpaces = <double>[].obs;
  List<double> get iconSpaces => _iconSpaces;
  void setIconSpaces(List<double> spaces) => _iconSpaces.value = spaces;

  final Rx<int?> _draggingIndex = Rx<int?>(null);
  int? get draggingIndex => _draggingIndex.value;
  void setDraggingIndex(int? index) => _draggingIndex.value = index;

  final Rx<Map<String, dynamic>?> _draggingItem =
      Rx<Map<String, dynamic>?>(null);
  Map<String, dynamic>? get draggingItem => _draggingItem.value;
  void setDraggingItem(Map<String, dynamic>? item) =>
      _draggingItem.value = item;

  final Rx<Offset?> _localPosition = Rx<Offset?>(null);
  Offset? get localPosition => _localPosition.value;
  void setLocalPosition(Offset? position) => _localPosition.value = position;

  List<Map<String, dynamic>> get navItems => _navItems;

  void initializeIconSpaces() {
    _iconSpaces.value = List.filled(_navItems.length, 1.0);
  }

  void updateNavItemOrder(int newIndex, Map<String, dynamic> item) {
    _navItems.insert(newIndex, item);
    resetDragState();
  }

  void resetDragState() {
    _draggingIndex.value = null;
    _draggingItem.value = null;
    _localPosition.value = null;
    _iconSpaces.value = List.filled(_navItems.length, 1.0);
  }

  void updateIconSpaces(double totalWidth) {
    if (_localPosition.value == null) return; // Ensure there's a valid position

    double itemWidth = totalWidth / _navItems.length;
    _iconSpaces.value = List.generate(_navItems.length, (i) {
      double distance = (_localPosition.value!.dx - (i * itemWidth)).abs();
      return distance < itemWidth ? 0.5 : 1.0;
    });
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  late NavItemController _controller;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(NavItemController());
    _controller.initializeIconSpaces();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _animation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    )..addListener(() {
        _controller.setAnimationValue(_animation.value);
      });
  }

  @override
  void dispose() {
    _animationController.dispose();
    Get.delete<NavItemController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main content
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(color: AppColors.primaryO),
            child: Obx(
              () => _controller.navItems[_controller.selectedIndex
                  .clamp(0, _controller.navItems.length - 1)]['page'],
            ),
          ),

          ClipRRect(
            borderRadius: BorderRadius.circular(0), // Rounded corners
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // Blur effect
              child: Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3), // Subtle border
                    width: 1.5,
                  ),
                ),
                child: const SafeArea(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: Text('Dynamic Drag & Drop Nav Bar',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.white,
                            )),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Floating glass morphism container
          Padding(
            padding: const EdgeInsets.all(20),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100), // Rounded corners
                child: BackdropFilter(
                  filter:
                      ImageFilter.blur(sigmaX: 10, sigmaY: 10), // Blur effect
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white
                          .withOpacity(0.1), // Semi-transparent white
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3), // Subtle border
                        width: 1.5,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Stack(
                          children: [
                            // Navigation items
                            Obx(() => Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: List.generate(
                                    _controller.navItems.length,
                                    (index) => _buildDraggableNavItem(
                                        index, constraints),
                                  ),
                                )),
                            // Drag feedback
                            Obx(() => _controller.draggingItem != null &&
                                    _controller.localPosition != null
                                ? Positioned(
                                    left: _controller.localPosition!.dx - 30,
                                    top: _controller.localPosition!.dy - 30,
                                    child: _buildDragFeedback(
                                        index: _controller.draggingIndex ?? 0),
                                  )
                                : const SizedBox.shrink()),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDraggableNavItem(int index, BoxConstraints constraints) {
    return Obx(() => Expanded(
          flex: (_controller.iconSpaces[index] * _animation.value).round(),
          child: GestureDetector(
            onTap: () => _controller.setSelectedIndex(index),
            child: Draggable<Map<String, dynamic>>(
              data: _controller.navItems[index],
              feedback: _buildDragFeedback(index: index),
              childWhenDragging: Opacity(
                opacity: 0.3,
                child: _buildNavItemContent(index),
              ),
              onDragStarted: () {
                _controller.setDraggingIndex(index);
                _controller
                    .setDraggingItem(_controller.navItems.removeAt(index));
                _animationController.forward();
              },
              onDragUpdate: (details) {
                _controller.setLocalPosition(details.localPosition);
                _controller.updateIconSpaces(MediaQuery.of(context).size.width);
              },
              onDraggableCanceled: (velocity, offset) {
                double itemWidth =
                    constraints.maxWidth / _controller.navItems.length;
                int newIndex = (offset.dx / itemWidth)
                    .round()
                    .clamp(0, _controller.navItems.length - 1);

                _controller.updateNavItemOrder(
                    newIndex, _controller.draggingItem!);
                _animationController.reverse();
              },
              child: _buildNavItemContent(index),
            ),
          ),
        ));
  }

  Widget _buildNavItemContent(int index) {
    return Obx(() => Container(
          margin: EdgeInsets.symmetric(
            horizontal: 5,
            vertical: _controller.draggingIndex == index
                ? 0
                : 10, // Lift dragged icon
          ),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
          ),
          child: SvgPicture.asset(
            _controller.navItems[index]['icon'],
            height: _controller.draggingIndex == null
                ? 24 // Default size
                : (_controller.draggingIndex == index
                    ? 36 // Larger size for dragged icon
                    : 30), // Slightly larger for others
          ),
        ));
  }

  Widget _buildDragFeedback({required int index}) {
    // Ensure we access only valid index
    int safeIndex =
        (index >= 0 && index < _controller.navItems.length) ? index : 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
      ),
      child:
          SvgPicture.asset(_controller.navItems[safeIndex]['icon'], height: 50),
    );
  }
}
