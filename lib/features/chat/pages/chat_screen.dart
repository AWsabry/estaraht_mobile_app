import 'package:videocalling/core/config/app_imports.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  ChatController chatController = Get.put(ChatController());

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    chatController.seenRefListner.cancel();
    chatController.checkSeenRefListner.cancel();
    chatController.keyboardSubscription.cancel();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // TODO: implement didChangeAppLifecycleState
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      chatController.markAsSeen();
      chatController.checkSeenStatus();
    } else {
      chatController.seenRefListner.cancel();
      chatController.checkSeenRefListner.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: chatController.onBackPress,
      child: Scaffold(
        backgroundColor: AppColors.WHITE,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            'chat'.tr,
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: AppFontStyleTextStrings.medium,
            ),
          ),
          centerTitle: false,
          leading: IconButton(
            padding: const EdgeInsets.only(left: 8, right: 30),
            icon: const Icon(Icons.arrow_back, color: Colors.black, size: 20),
            onPressed: () => Get.back(),
          ),
          titleSpacing: 0,
        ),
        body: Obx(
          () => chatController.requestStatus.value == 0
              ? const Center(child: CircularProgressIndicator(strokeWidth: 1.5))
              : Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      flex: 1,
                      child: StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection("Chats")
                            .doc(chatController.channelId.value)
                            .collection("All Chat")
                            .orderBy("time", descending: true)
                            .limit(chatController.perPage.value)
                            .snapshots(),
                        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.hasData &&
                              snapshot.data!.docs.isNotEmpty) {
                            return Container(
                              child: ListView.builder(
                                controller: chatController.lvScrollCtrl,
                                reverse: true,
                                itemCount: snapshot.data!.docs.length,
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  if (index == snapshot.data!.docs.length) {
                                    if (snapshot.connectionState ==
                                            ConnectionState.waiting &&
                                        snapshot.data!.docs.length > 20) {
                                      return Container();
                                    } else if (snapshot.connectionState ==
                                            ConnectionState.active &&
                                        snapshot.data!.docs.length > 20) {
                                      chatController.isLoading.value = true;
                                      Timer(const Duration(seconds: 3), () {
                                        setState(() {
                                          chatController.isLoading.value =
                                              chatController
                                                      .showLoadingIndicator
                                                      .value =
                                                  false;
                                        });
                                      });
                                      return chatController.isLoading.value
                                          ? Container(
                                              margin: const EdgeInsets.all(30),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    valueColor:
                                                        AlwaysStoppedAnimation(
                                                          AppColors.grey,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          : Container();
                                    } else if (snapshot.data!.docs.length >
                                        20) {
                                      return Container(
                                        margin: const EdgeInsets.all(0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation(
                                                    AppColors.grey,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      );
                                    } else {
                                      return Container();
                                    }
                                  } else if (index <
                                      snapshot.data!.docs.length) {
                                    chatController.lastMessageUid.value =
                                        snapshot.data!.docs[index]['uid'];

                                    int k = snapshot.data!.docs.length > index
                                        ? index + 1
                                        : snapshot.data!.docs.length - 1;

                                    int daysDifferenceForTitle = DateTime.now()
                                        .difference(
                                          DateTime.parse(
                                            "${snapshot.data!.docs[index]['time']}Z",
                                          ).toLocal(),
                                        )
                                        .inDays;
                                    if (index ==
                                        snapshot.data!.docs.length - 1) {
                                      chatController.showDate.value = true;
                                    } else {
                                      DateTime currentDate = DateTime.parse(
                                        "${snapshot.data!.docs[index]['time']}",
                                      );
                                      DateTime nextDate = DateTime.parse(
                                        "${snapshot.data!.docs[index + 1]['time']}",
                                      );
                                      if (currentDate.year != nextDate.year ||
                                          currentDate.month != nextDate.month ||
                                          currentDate.day != nextDate.day) {
                                        chatController.showDate.value = true;
                                      } else {
                                        chatController.showDate.value = false;
                                      }
                                    }

                                    String text = daysDifferenceForTitle == 0
                                        ? "chat_title_today".tr
                                        : daysDifferenceForTitle == 1
                                        ? "chat_title_yesterday".tr
                                        : "${DateTime.now().add(Duration(days: -daysDifferenceForTitle)).day - 1}  ${chatController.monthsList[DateTime.now().add(Duration(days: -daysDifferenceForTitle)).month - 1]}, ${DateTime.now().add(Duration(days: -daysDifferenceForTitle)).year}";

                                    return Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                        15,
                                        0.5,
                                        15,
                                        1,
                                      ),
                                      child: Column(
                                        children: [
                                          Visibility(
                                            visible:
                                                chatController.showDate.value,
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Divider(
                                                    height: 10,
                                                    thickness: 0.5,
                                                    color: AppColors.greyShade6,
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                Visibility(
                                                  visible: chatController
                                                      .showDate
                                                      .value,
                                                  child:
                                                      AppTextWidgets.regularText(
                                                        text: text,
                                                        color: AppColors.grey,
                                                        size: 12,
                                                      ),
                                                ),
                                                const SizedBox(width: 10),
                                                Expanded(
                                                  child: Divider(
                                                    height: 30,
                                                    thickness: 0.5,
                                                    color: AppColors.greyShade6,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                snapshot
                                                        .data!
                                                        .docs[index]['uid'] ==
                                                    chatController.myUid.value
                                                ? MainAxisAlignment.end
                                                : MainAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  k >=
                                                          snapshot
                                                              .data!
                                                              .docs
                                                              .length
                                                      ? Padding(
                                                          padding:
                                                              const EdgeInsets.fromLTRB(
                                                                0,
                                                                5,
                                                                0,
                                                                0,
                                                              ),
                                                          child: AppTextWidgets.regularText(
                                                            text:
                                                                DateFormat(
                                                                  'hh:mm a',
                                                                ).format(
                                                                  DateTime.parse(
                                                                    snapshot
                                                                        .data!
                                                                        .docs[index]['time']
                                                                        .toString(),
                                                                  ),
                                                                ),
                                                            color:
                                                                AppColors.grey,
                                                            size: 10,
                                                          ),
                                                        )
                                                      : chatController
                                                                    .lastMessageUid
                                                                    .value ==
                                                                snapshot
                                                                    .data!
                                                                    .docs[index +
                                                                    1]['uid'] &&
                                                            (DateTime.parse(
                                                                          snapshot
                                                                              .data!
                                                                              .docs[index]['time']
                                                                              .toString(),
                                                                        )
                                                                        .add(
                                                                          DateTime.now()
                                                                              .timeZoneOffset,
                                                                        )
                                                                        .minute -
                                                                    DateTime.parse(
                                                                          snapshot
                                                                              .data!
                                                                              .docs[index +
                                                                                  1]['time']
                                                                              .toString(),
                                                                        )
                                                                        .add(
                                                                          DateTime.now()
                                                                              .timeZoneOffset,
                                                                        )
                                                                        .minute) ==
                                                                0
                                                      ? Container()
                                                      : Padding(
                                                          padding:
                                                              const EdgeInsets.fromLTRB(
                                                                0,
                                                                5,
                                                                0,
                                                                0,
                                                              ),
                                                          child: AppTextWidgets.regularText(
                                                            text:
                                                                DateFormat(
                                                                  'hh:mm a',
                                                                ).format(
                                                                  DateTime.parse(
                                                                    snapshot
                                                                        .data!
                                                                        .docs[index]['time']
                                                                        .toString(),
                                                                  ),
                                                                ),
                                                            color:
                                                                AppColors.grey,
                                                            size: 10,
                                                          ),
                                                        ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                snapshot
                                                        .data!
                                                        .docs[index]['uid'] ==
                                                    chatController.myUid.value
                                                ? CrossAxisAlignment.end
                                                : CrossAxisAlignment.start,
                                            children: [
                                              if (snapshot.data!.docs[index]['uid'] != chatController.myUid.value)
                                                Padding(
                                                  padding: const EdgeInsets.only(left: 8, bottom: 4),
                                                  child: Text(
                                                    chatController.userName,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: AppColors.grey,
                                                      fontFamily: AppFontStyleTextStrings.medium,
                                                    ),
                                                  ),
                                                ),
                                              Row(
                                                mainAxisAlignment:
                                                    snapshot
                                                            .data!
                                                            .docs[index]['uid'] ==
                                                        chatController.myUid.value
                                                    ? MainAxisAlignment.end
                                                    : MainAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    constraints: BoxConstraints(
                                                      maxWidth:
                                                          MediaQuery.of(
                                                            context,
                                                          ).size.width -
                                                          120,
                                                    ),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      k >=
                                                          snapshot
                                                              .data!
                                                              .docs
                                                              .length
                                                      ? BorderRadius.circular(
                                                          10,
                                                        )
                                                      : BorderRadius.only(
                                                          topRight:
                                                              snapshot
                                                                      .data!
                                                                      .docs[index]['uid'] ==
                                                                  chatController
                                                                      .myUid
                                                                      .value
                                                              ? chatController.lastMessageUid.value ==
                                                                            snapshot.data!.docs[k]['uid'] &&
                                                                        (DateTime.parse(
                                                                                  snapshot.data!.docs[index]['time'].toString(),
                                                                                ).toLocal().minute -
                                                                                DateTime.parse(
                                                                                  snapshot.data!.docs[index]['time'].toString(),
                                                                                ).toLocal().minute) ==
                                                                            0
                                                                    ? const Radius.circular(
                                                                        5,
                                                                      )
                                                                    : const Radius.circular(0)
                                                              : const Radius.circular(
                                                                  15,
                                                                ),
                                                          bottomRight:
                                                              snapshot
                                                                      .data!
                                                                      .docs[index]['uid'] ==
                                                                  chatController
                                                                      .myUid
                                                                      .value
                                                              ? const Radius.circular(
                                                                  5,
                                                                )
                                                              : const Radius.circular(
                                                                  10,
                                                                ),
                                                          bottomLeft:
                                                              snapshot
                                                                      .data!
                                                                      .docs[index]['uid'] ==
                                                                  chatController
                                                                      .myUid
                                                                      .value
                                                              ? const Radius.circular(
                                                                  10,
                                                                )
                                                              : const Radius.circular(
                                                                  5,
                                                                ),
                                                          topLeft:
                                                              snapshot
                                                                      .data!
                                                                      .docs[index]['uid'] !=
                                                                  chatController
                                                                      .myUid
                                                                      .value
                                                              ? chatController.lastMessageUid.value ==
                                                                            snapshot.data!.docs[k]['uid'] &&
                                                                        (DateTime.parse(
                                                                                  snapshot.data!.docs[index]['time'].toString(),
                                                                                ).toLocal().minute -
                                                                                DateTime.parse(
                                                                                  snapshot.data!.docs[index]['time'].toString(),
                                                                                ).toLocal().minute) ==
                                                                            0
                                                                    ? const Radius.circular(
                                                                        5,
                                                                      )
                                                                    : const Radius.circular(0)
                                                              : const Radius.circular(
                                                                  15,
                                                                ),
                                                        ),
                                                  color:
                                                      snapshot
                                                              .data!
                                                              .docs[index]['uid'] ==
                                                          chatController
                                                              .myUid
                                                              .value
                                                      ? Theme.of(context)
                                                            .primaryColor
                                                            .withOpacity(0.8)
                                                      : AppColors
                                                            .LIGHT_GREY_SCREEN_BACKGROUND,
                                                  gradient:
                                                      snapshot
                                                              .data!
                                                              .docs[index]['uid'] ==
                                                          chatController
                                                              .myUid
                                                              .value
                                                      ? const LinearGradient(
                                                          colors: [
                                                            AppColors.color1,
                                                            AppColors.color1,
                                                          ],
                                                          stops: [0.3, 1],
                                                          begin: Alignment
                                                              .centerLeft,
                                                          end: Alignment
                                                              .centerRight,
                                                        )
                                                      : null,
                                                ),
                                                padding:
                                                    snapshot
                                                            .data!
                                                            .docs[index]['type'] ==
                                                        "text"
                                                    ? const EdgeInsets.all(10)
                                                    : const EdgeInsets.all(4),
                                                child: InkWell(
                                                  onLongPress: () {
                                                    if (snapshot
                                                                .data!
                                                                .docs[index]['type'] !=
                                                            "task" &&
                                                        snapshot
                                                                .data!
                                                                .docs[index]['uid'] ==
                                                            chatController
                                                                .myUid
                                                                .value) {
                                                      unSendMessageDialog(
                                                        onTap: () =>
                                                            chatController
                                                                .unSendMessage(
                                                                  snapshot
                                                                      .data!
                                                                      .docs[index]
                                                                      .id,
                                                                  index,
                                                                  snapshot
                                                                      .data!
                                                                      .docs
                                                                      .length,
                                                                  snapshot,
                                                                ),
                                                      );
                                                    }
                                                  },
                                                  child: chatController
                                                      .typeToWidget(
                                                        message: snapshot
                                                            .data!
                                                            .docs[index]['msg'],
                                                        type: snapshot
                                                            .data!
                                                            .docs[index]['type'],
                                                        uid: snapshot
                                                            .data!
                                                            .docs[index]['uid'],
                                                      ),
                                                ),
                                              ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  } else {
                                    return const LinearProgressIndicator();
                                  }
                                },
                              ),
                            );
                          } else if (snapshot.hasData &&
                              snapshot.data!.docs.isEmpty) {
                            Future.delayed(const Duration(seconds: 1), () {
                              chatController.isFirstMessage.value = true;
                            });
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AppTextWidgets.blackText(
                                  text: "first_conversation_title2".tr,
                                  color: AppColors.BLACK,
                                  size: 25,
                                ),
                                const SizedBox(height: 5),
                                AppTextWidgets.blackText(
                                  text: "first_conversation_title".tr,
                                  color: AppColors.LIGHT_GREY_TEXT,
                                  size: 13,
                                ),
                                const SizedBox(height: 25),
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: AppColors.greyShade1,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: AppTextWidgets.blackText(
                                      text: "first_conversation_title1".tr,
                                      color: Theme.of(context).primaryColor,
                                      size: 17,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          } else {
                            return Container();
                          }
                        },
                      ),
                    ),
                    chatController.isSeenStatusExist.value
                        ? Padding(
                            padding: const EdgeInsets.fromLTRB(10, 5, 15, 0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                AppTextWidgets.blackText(
                                  text: "seen_str".tr,
                                  color: AppColors.GREY,
                                  size: 10,
                                ),
                              ],
                            ),
                          )
                        : Container(),
                    chatController.isFileUploading.value
                        ? Container(
                            color: AppColors.greyShade1,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    // ignore: sort_child_properties_last
                                    child: Image.memory(
                                      chatController.fileThumbnail!,
                                      height: 30,
                                      width: 30,
                                      fit: BoxFit.cover,
                                    ),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        AppTextWidgets.semiBoldTextWithColor(
                                          text: 'send_file'.tr,
                                          color: AppColors.themeColor3,
                                        ),
                                        const SizedBox(height: 5),
                                        LinearProgressIndicator(
                                          minHeight: 2,
                                          value: chatController
                                              .uploadingProgress
                                              .value,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Icon(
                                    Icons.cancel,
                                    color: AppColors.themeColor3,
                                  ),
                                ],
                              ),
                            ),
                          )
                        : Container(),
                    chatController.statusToWidget(
                      chatController.requestStatus.value,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class UploadItem {
  final String? id;
  final String? tag;
  final MediaType? type;
  final int progress;
  final UploadTaskStatus status;

  UploadItem({
    this.id,
    this.tag,
    this.type,
    this.progress = 0,
    this.status = UploadTaskStatus.undefined,
  });

  UploadItem copyWith({UploadTaskStatus? status, int? progress}) => UploadItem(
    id: id,
    tag: tag,
    type: type,
    status: status ?? this.status,
    progress: progress ?? this.progress,
  );

  bool isCompleted() =>
      status == UploadTaskStatus.canceled ||
      status == UploadTaskStatus.complete ||
      status == UploadTaskStatus.failed;
}

enum MediaType { Image, Video }
