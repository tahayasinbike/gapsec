import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:gapsec/cache/model/new_game_model/newgame_model.dart';
import 'package:gapsec/cache/service/database_service.dart';
import 'package:gapsec/state/shop_state/shop_state.dart';
import 'package:gapsec/state/stories_state/stories_state.dart';
import 'package:gapsec/stories/model/story_model.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:gapsec/utils/constants.dart';
import 'package:carousel_slider/carousel_slider.dart';

class StoriesView extends StatefulWidget {
  const StoriesView({super.key});

  @override
  _StoriesViewState createState() => _StoriesViewState();
}

class _StoriesViewState extends State<StoriesView>
    with TickerProviderStateMixin {
  final StoriesState vm = StoriesState();
  late CarouselSliderController carouselController;
  late TextTheme textTheme;
  final _databaseService = DatabaseService();
  int iconSelectedIndex = 0;
  bool itsFree = true;
  String selectedTitle = murder.name;
  String selectedDescription = murder.description;
  int activeIndex = 0;
  int price = 0;
  Map<String, VideoPlayerController> videoControllers = {};
  Map<String, VideoPlayerController> audioControllers = {};

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    carouselController = CarouselSliderController();
    // İlk videoyu oynatmak için post-frame callback ekleniyor
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _playInitialVideo();
    });
  }

  // Tüm hikayeler için video ve ses kontrolcülerini başlatır
  void _initializeControllers() {
    for (var story in games().historiesGames) {
      String videoPath =
          "assets/videos/${story.name.toLowerCase().replaceAll(" ", "_")}.mp4";
      String audioPath =
          "assets/sounds/${story.name.toLowerCase().replaceAll(" ", "_")}.mp3";

      videoControllers[story.name] = VideoPlayerController.asset(videoPath)
        ..initialize().then((_) {
          videoControllers[story.name]!.setLooping(true);
          if (mounted) setState(() {});
        });

      audioControllers[story.name] = VideoPlayerController.asset(audioPath)
        ..initialize().then((_) {
          audioControllers[story.name]!.setLooping(true);
          if (mounted) setState(() {});
        });
    }
  }

  // İlk hikayenin videosunu ve sesini oynatır
  void _playInitialVideo() {
    if (games().historiesGames.isNotEmpty) {
      var firstStory = games().historiesGames[0];
      videoControllers[firstStory.name]?.play();
      audioControllers[firstStory.name]?.play();
    }
  }

  Future<void> _addTokens(int amount) async {
    await _databaseService.addTokens(amount);
    setState(() {});
  }

  Future<void> updateIndex(int index, String title, String description) async {
    await DatabaseService().updateDefaultValues();
    setState(() {
      iconSelectedIndex = index;
      selectedTitle = title;
      selectedDescription = description;
      switch (iconSelectedIndex) {
        case 0:
          setState(() {
            itsFree = !murder.isLock;
          });
          break;
        case 1:
          setState(() {
            itsFree = !dontLookBack.isLock;
          });
          break;
        case 2:
          itsFree = !lostLucy.isLock;
          setState(() {});
          break;
        case 3:
          itsFree = !nightGame.isLock;
          setState(() {});
          break;
        case 4:
          itsFree = !runKaity.isLock;
          setState(() {});
          break;
        case 5:
          itsFree = !smile.isLock;
          setState(() {});
          break;
        case 6:
          itsFree = !behind.isLock;
          setState(() {});
          break;
        case 7:
          itsFree = !lucky.isLock;
          setState(() {});
        default:
      }
    });
  }

  @override
  void didChangeDependencies() {
    textTheme = Theme.of(context).textTheme;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    for (var controller in videoControllers.values) {
      controller.dispose();
    }
    for (var controller in audioControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> showOkAlertDialogWidget(
      BuildContext context, String message) async {
    final result = await showOkAlertDialog(
      context: context,
      title: 'Yetersiz bakiye :( ',
      message: message,
      okLabel: 'OK',
    );
    if (result == OkCancelResult.ok) {
      print("Yetersiz bakiye onaylandı");
    }
  }

  Future<void> showOkCancelAlert(BuildContext context, int storyPrice) async {
    final result = await showOkCancelAlertDialog(
      context: context,
      title: 'Hikaye Kilidi Aç',
      message: '$price Mystoken ile alınsın mı?',
      okLabel: 'Evet',
      cancelLabel: 'Hayır',
    );

    if (result == OkCancelResult.ok) {
      switch (storyPrice) {
        case 80:
          if (ShopState().amount >= 80) {
            buySteps(
                minusAmount: -80,
                type: TextType.dontLookBackType,
                storyIsLock: dontLookBack.isLock);
          } else {
            showOkAlertDialogWidget(context, "Marketten Mystoken al");
          }
          break;
        case 120:
          if (ShopState().amount >= 120) {
            buySteps(
                minusAmount: -120,
                type: TextType.lostLucyType,
                storyIsLock: lostLucy.isLock);
          } else {
            showOkAlertDialogWidget(context, "Marketten Mystoken al");
          }
          break;
        case 100:
          if (ShopState().amount >= 100) {
            buySteps(
                minusAmount: -100,
                type: TextType.nightGameType,
                storyIsLock: nightGame.isLock);
          } else {
            showOkAlertDialogWidget(context, "Marketten Mystoken al");
          }
          break;
        case 110:
          if (ShopState().amount >= 110) {
            buySteps(
                minusAmount: -110,
                type: TextType.runKaityType,
                storyIsLock: runKaity.isLock);
          } else {
            showOkAlertDialogWidget(context, "Marketten Mystoken al");
          }
          break;
        case 150:
          if (ShopState().amount >= 150) {
            buySteps(
                minusAmount: -150,
                type: TextType.smileType,
                storyIsLock: smile.isLock);
          } else {
            showOkAlertDialogWidget(context, "Marketten Mystoken al");
          }
          break;
        case 180:
          if (ShopState().amount >= 180) {
            buySteps(
                minusAmount: -180,
                type: TextType.behindType,
                storyIsLock: behind.isLock);
          } else {
            showOkAlertDialogWidget(context, "Marketten Mystoken al");
          }
          break;
        case 300:
          if (ShopState().amount >= 300) {
            buySteps(
                minusAmount: -300,
                type: TextType.luckyType,
                storyIsLock: lucky.isLock);
          } else {
            showOkAlertDialogWidget(context, "Marketten Mystoken al");
          }
          break;
        default:
      }
    }
  }

  void buySteps(
      {required int minusAmount,
      required TextType type,
      required bool storyIsLock}) {
    _addTokens(minusAmount).then(
      (value) async => await _databaseService
          .changeDefaultValue(type: type, newValue: false)
          .then(
        (value) {
          setState(() {
            itsFree = storyIsLock;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Config().init(context);
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.black, Color(0xFF3D0000)],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: _buildStoryCarousel(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => vm.goBack(context: context),
          ),
          Text(
            "STORIES",
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              fontFamily: 'HorrorFont',
              letterSpacing: 2,
              shadows: [
                Shadow(
                  blurRadius: 5.0,
                  color: Colors.red.withOpacity(0.5),
                  offset: const Offset(0, 3),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.amber, width: 1),
            ),
            child: Row(
              children: [
                Text(
                  "${ShopState().amount}",
                  style: const TextStyle(
                    color: Colors.amber,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 5),
                Image.asset(ConstantPaths.tokenImagePath,
                    height: 24, width: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoryCarousel() {
    return Column(
      children: [
        CarouselSlider.builder(
          itemCount: games().historiesGames.length,
          options: CarouselOptions(
            height: MediaQuery.of(context).size.height * 0.70,
            enlargeCenterPage: true,
            onPageChanged: (index, reason) {
              setState(() {
                activeIndex = index;
                updateIndex(index, games().historiesGames[index].name,
                    games().historiesGames[index].description);

                // Tüm video ve sesleri durdur ve sıfırla
                for (var controller in videoControllers.values) {
                  controller.pause();
                  controller.seekTo(Duration.zero);
                }
                for (var controller in audioControllers.values) {
                  controller.pause();
                  controller.seekTo(Duration.zero);
                }

                // Yeni video ve sesi oynat
                var currentStory = games().historiesGames[index];
                videoControllers[currentStory.name]?.play();
                audioControllers[currentStory.name]?.play();
              });
            },
          ),
          itemBuilder: (context, index, realIndex) {
            return _buildStoryCard(games().historiesGames[index]);
          },
        ),
        const SizedBox(height: 20),
        buildIndicator(),
      ],
    );
  }

  Widget _buildStoryCard(StoryModel story) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red[800]!, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.3),
            blurRadius: 15.0,
            spreadRadius: 2.0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          children: [
            // Video arka planı
            if (videoControllers[story.name] != null &&
                videoControllers[story.name]!.value.isInitialized)
              SizedBox.expand(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: videoControllers[story.name]!.value.size.width,
                    height: videoControllers[story.name]!.value.size.height,
                    child: VideoPlayer(videoControllers[story.name]!),
                  ),
                ),
              )
            else
              const Center(child: CircularProgressIndicator()),
            // Hikaye içeriği
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      story.name,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'HorrorFont',
                        letterSpacing: 1.5,
                        shadows: [
                          Shadow(
                            blurRadius: 3.0,
                            color: Colors.red.withOpacity(0.6),
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          story.description,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    story.isLock
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton(
                                onPressed: () =>
                                    showOkCancelAlert(context, story.price),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green[700],
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: const Text('Satın Al',
                                    style: TextStyle(fontSize: 16)),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(20),
                                  border:
                                      Border.all(color: Colors.amber, width: 1),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      '${story.price}',
                                      style: const TextStyle(
                                        color: Colors.amber,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Image.asset(ConstantPaths.tokenImagePath,
                                        height: 24, width: 24),
                                  ],
                                ),
                              ),
                            ],
                          )
                        : ElevatedButton(
                            onPressed: () {
                              // Hikayeye başlama işlemi
                              print("Starting story: ${story.name}");
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red[800],
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text('Hikayeye Başla',
                                style: TextStyle(fontSize: 16)),
                          ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildIndicator() {
    return AnimatedSmoothIndicator(
      activeIndex: activeIndex,
      count: games().historiesGames.length,
      effect: CustomizableEffect(
        spacing: 8,
        dotDecoration: DotDecoration(
          width: 10,
          height: 10,
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
        ),
        activeDotDecoration: DotDecoration(
          width: 20,
          height: 10,
          color: Colors.red,
          borderRadius: BorderRadius.circular(5),
        ),
      ),
    );
  }
}
