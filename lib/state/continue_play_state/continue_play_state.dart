import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import 'package:video_player/video_player.dart';
part 'continue_play_state.g.dart';

class ContinuePlayState = _ContinuePlayStateBase with _$ContinuePlayState;

abstract class _ContinuePlayStateBase with Store {
  @observable
  late VideoPlayerController mp3controller;

  @observable
  late Map<String, dynamic> left = {}; // tek olan map

  @observable
  late Map<String, dynamic> right = {}; //çift olan map

  @observable
  late List<Map<String, dynamic>> selectedList = [];

  @observable
  bool textCompleted = true;

  @observable
  bool isEnable = true;

  @observable
  int attempt = 0;

  @observable
  int storyMapId = 0;

  @observable
  late List repo = [];

  @observable
  String selectedTexts = "";

  @observable
  late ScrollController scrollController;

  @action
  void updateStoryMapId(int newId) {
    storyMapId = newId;
  }

  @action
  void scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @action
  //istediğimiz id ye sahip mapi getirir
  Map<String, dynamic>? getMapWithId(List<Map<String, dynamic>> list, int id) {
    return list.firstWhere((element) => element["id"] == id);
  }

  @action
  //answer mapini getiren tek için fonksiyon
  Map<String, dynamic>? assignToOdd(List<Map<String, dynamic>> list, int id) {
    var item = getMapWithId(list, id);
    if (item != null) {
      var answers = item['answers'] as List<Map<String, dynamic>>;

      // Eğer her iki aId de aynı ise solda tek olmasını istediğimiz için ilk elemanı döndürdüm
      if (answers[0]['aId'] == answers[1]['aId']) {
        return answers[0];
      }
      if (answers[0]['aId'] % 2 == 0 && answers[1]['aId'] % 2 == 0) {
        return answers[0];
      } else if (answers[0]['aId'] % 2 != 0 && answers[1]['aId'] % 2 != 0) {
        return answers[0];
      }

      // aId tek olanı seçiyoruz
      return answers.firstWhere((answer) => answer['aId'] % 2 != 0);
    }
    return null;
  }

  @action
  //Answer mapi sağ için
  Map<String, dynamic>? assignToEven(List<Map<String, dynamic>> list, int id) {
    var item = getMapWithId(list, id);
    if (item != null) {
      var answers = item['answers'] as List<Map<String, dynamic>>;

      // Eğer her iki aId de aynı ise sağdaki çift olmasını istediğimiz için ilk elemanı döndürdüm
      if (answers[0]['aId'] == answers[1]['aId']) {
        return answers[1];
      }
      if (answers[0]['aId'] % 2 == 0 && answers[1]['aId'] % 2 == 0) {
        return answers[1];
      } else if (answers[0]['aId'] % 2 != 0 && answers[1]['aId'] % 2 != 0) {
        return answers[1];
      }
      // aId çift olanı seçiyoruz
      return answers.firstWhere((answer) => answer['aId'] % 2 == 0);
    }
    return null;
  }
}
