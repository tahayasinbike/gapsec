import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gapsec/state/play_story_view_state/play_story_view_state.dart';
import 'package:gapsec/stories/games_storage/gravehurst.dart';
import 'package:gapsec/utils/app_font.dart';
import 'package:gapsec/widgets/alert_widgets/alert_widgets.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:gapsec/stories/games_storage/games_storage.dart';
import 'package:gapsec/cache/model/new_game_model/newgame_model.dart';
import 'package:gapsec/cache/service/database_service.dart';
import 'package:gapsec/utils/constants.dart';
import 'package:video_player/video_player.dart';

class ChatView extends StatefulWidget {
  final TextType selectedTextType;
  final String story;
  final List selectedRepo;

  const ChatView({
    super.key,
    required this.selectedTextType,
    required this.story,
    required this.selectedRepo,
  });

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final PlayStoryViewState vm = PlayStoryViewState();
  final _databaseService = DatabaseService();
  bool _isTyping = false;
  //Ekranı güncellemek için short fonk.
  void _updateScreen() {
    setState(() {});
  }

  Future<void> _selectedStoryUpdate({required TextType type}) async {
    await _databaseService.selectedStoryUpdate(type: type);
    _updateScreen();
  }

  Future<void> _selectedStoryAddItem(
      {required String eklencekText, required TextType type}) async {
    await _databaseService.selectedStoryAdd(
        eklenicekMetin: eklencekText, type: type);
    _updateScreen();
  }

  @override
  void initState() {
    vm.mp3controller =
        VideoPlayerController.asset(ConstantPaths.murderBackgroundMusicPath)
          ..initialize().then((_) {
            vm.mp3controller.setLooping(true);

            vm.mp3controller.value.isPlaying
                ? vm.mp3controller.pause()
                : vm.mp3controller.play();
          });
    vm.scrollController = ScrollController();
    Future.delayed(const Duration(seconds: 3), () {
      vm.textCompleted = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        switch (widget.selectedTextType) {
          case TextType.murderType:
            vm.selectedList = murderDetail;

            await _selectedStoryAddItem(
                eklencekText:
                    vm.getMapWithId(vm.selectedList, vm.storyMapId)!["history"],
                type: TextType.murderType);
            vm.left = vm.assignToOdd(vm.selectedList, vm.storyMapId)!;
            vm.right = vm.assignToEven(vm.selectedList, vm.storyMapId)!;
            await _selectedStoryUpdate(type: TextType.murderType);
            vm.repo = _databaseService.murderRepo;
            break;
          case TextType.gravehurstType:
            vm.selectedList = gravehurstDetail;

            await _selectedStoryAddItem(
                eklencekText:
                    vm.getMapWithId(vm.selectedList, vm.storyMapId)!["history"],
                type: TextType.gravehurstType);
            vm.left = vm.assignToOdd(vm.selectedList, vm.storyMapId)!;
            vm.right = vm.assignToEven(vm.selectedList, vm.storyMapId)!;
            await _selectedStoryUpdate(type: TextType.gravehurstType);
            vm.repo = _databaseService.gravehurstRepo;
            break;
          default:
        }
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    vm.mp3controller.dispose();
    vm.scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Config().init(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      vm.scrollToBottom();
    });
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.cancel_outlined, color: Colors.green),
        ),
        title: Text(
          widget.story,
          style: AppFonts.storyTitleInGameTextStyle,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                ),
                child: ListView.builder(
                  controller: vm.scrollController,
                  itemCount: vm.repo.length,
                  itemBuilder: (context, index) {
                    final NewGame newGame = vm.repo[index];
                    switch (widget.selectedTextType) {
                      case TextType.murderType:
                        vm.selectedTexts = newGame.murderTexts.toString();
                        break;
                      case TextType.gravehurstType:
                        vm.selectedTexts = newGame.gravehurstTexts.toString();
                        break;
                      default:
                    }
                    return Padding(
                      padding: EdgeInsets.only(
                        left: index.isEven ? 10 : 50,
                        right: index.isEven ? 50 : 10,
                        bottom: 16,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: index.isEven
                              ? Colors.green.withOpacity(0.2)
                              : Colors.grey.withOpacity(0.2),
                          borderRadius: index.isEven
                              ? const BorderRadiusDirectional.only(
                                  bottomEnd: Radius.circular(10),
                                  topEnd: Radius.circular(10),
                                  topStart: Radius.circular(10))
                              : const BorderRadiusDirectional.only(
                                  bottomStart: Radius.circular(10),
                                  topEnd: Radius.circular(10),
                                  topStart: Radius.circular(10)),
                          border: Border.all(color: Colors.green, width: 1),
                        ),
                        child: index == vm.repo.length - 1 && _isTyping
                            ? Stack(children: [
                                Text(vm.selectedTexts.tr(),
                                    style: const TextStyle(
                                        color: Colors.transparent,
                                        fontSize: 14)),
                                AnimatedTextKit(
                                  animatedTexts: [
                                    TypewriterAnimatedText(
                                      vm.selectedTexts.tr(),
                                      textStyle: const TextStyle(
                                          color: Colors.green, fontSize: 14),
                                      speed: const Duration(milliseconds: 50),
                                    ),
                                  ],
                                  totalRepeatCount: 1,
                                  onFinished: () {
                                    setState(() {
                                      _isTyping = false;
                                      vm.textCompleted = true;
                                    });
                                  },
                                ),
                              ])
                            : Text(
                                vm.selectedTexts.tr(),
                                style: const TextStyle(
                                    color: Colors.green, fontSize: 14),
                              ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          // Choices area
          if (vm.textCompleted && !_isTyping)
            SafeArea(
              child: Container(
                color: Colors.black.withOpacity(0.7),
                child: Column(
                  children: [
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 8.0, right: 8, bottom: 8),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          foregroundColor: Colors.green,
                          backgroundColor: Colors.green.withOpacity(0.2),
                          side: const BorderSide(color: Colors.green),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 12, bottom: 12),
                          child: Text(vm.assignToOdd(
                              vm.selectedList, vm.storyMapId)!["title"]),
                        ),
                        onPressed: () async {
                          await _handleChoice(vm.left);
                        },
                      ),
                    ),
                    Container(
                      child: Text(
                        ConstantTexts.ChooseYourAnswer.tr(),
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 8.0, right: 8, top: 8),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          foregroundColor: Colors.green,
                          backgroundColor: Colors.green.withOpacity(0.2),
                          side: const BorderSide(color: Colors.green),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 12, bottom: 12),
                          child: Text(vm.assignToEven(
                              vm.selectedList, vm.storyMapId)!["title"]),
                        ),
                        onPressed: () async {
                          await _handleChoice(vm.right);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

          if (!vm.textCompleted || _isTyping)
            SafeArea(
              child: Container(
                color: Colors.black.withOpacity(0.7),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: LoadingIndicator(
                        indicatorType: Indicator.ballPulse,
                        colors: [Colors.green],
                        strokeWidth: 2,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      ConstantTexts.waitingForMessage.tr(),
                      style: AppFonts.waitingForMessageTextStyle,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _handleChoice(Map<String, dynamic> choice) async {
    setState(() {
      vm.textCompleted = false;
      _isTyping = false;
    });

    vm.isEnable = false;
    await _selectedStoryAddItem(
      eklencekText: choice["title"],
      type: widget.selectedTextType,
    );
    vm.updateStoryMapId(choice["aId"]);

    await _selectedStoryUpdate(type: widget.selectedTextType);
    vm.repo = widget.selectedTextType == TextType.murderType
        ? _databaseService.murderRepo
        : _databaseService.gravehurstRepo;
    vm.scrollToBottom();

    await Future.delayed(const Duration(seconds: 1));

    vm.left = vm.assignToOdd(vm.selectedList, vm.storyMapId)!;
    vm.right = vm.assignToEven(vm.selectedList, vm.storyMapId)!;
    await _selectedStoryAddItem(
      eklencekText: vm.getMapWithId(vm.selectedList, vm.storyMapId)!["history"],
      type: widget.selectedTextType,
    );
    await _selectedStoryUpdate(type: widget.selectedTextType);
    vm.repo = widget.selectedTextType == TextType.murderType
        ? _databaseService.murderRepo
        : _databaseService.gravehurstRepo;

    setState(() {
      _isTyping = true;
    });

    vm.scrollToBottom();

    if (vm.storyMapId >= 900) {
      AlertWidgets().showOkAlert(
          context,
          ConstantTexts.you_have_reached_the_end.tr(),
          ConstantTexts.GapsecEnds.tr(),
          ConstantTexts.okay.tr(),
          () {});
      vm.isEnable = false;
    }
  }
}
