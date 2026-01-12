import 'package:videocalling/core/config/app_imports.dart';

class PatientChatListController extends GetxController {
  var ds;
  RxString myUid = "".obs;

  RxList<ChatListDetails> chatListDetails = <ChatListDetails>[].obs;
  List<ChatListDetails> chatListDetailsPA = [];

  getChatListData() {
    ds = FirebaseDatabase.instance
        .ref()
        .child(myUid.value)
        .onValue
        .listen((event) {
      chatListDetailsPA.clear();
      final snapshotValue = event.snapshot.value as Map;

      if (snapshotValue['chatlist'] != null) {
        final Map<dynamic, dynamic> chatListMap =
            Map<dynamic, dynamic>.from(snapshotValue['chatlist']);

        chatListMap.forEach((key, values) {
          if (values['last_msg'] != null) {
            chatListDetailsPA.add(ChatListDetails(
              channelId: values['channelId'],
              message: values['last_msg'],
              messageCount: values['messageCount'],
              time: DateTime.parse(values['time'].toString()).toString(),
              type: int.parse(values['type'].toString()),
              userUid: key,
              userName: values['userName'] ?? 'Unknown Doctor',
            ));
          }
        });
      }

      if (chatListDetailsPA.length > 1) {
        chatListDetailsPA.sort((a, b) => b.time.compareTo(a.time));
      }
      chatListDetails.clear();
      chatListDetails.addAll(chatListDetailsPA);
      st.value = true;
    });
  }

  RxBool st = false.obs;
  RxBool loginCheckUser = false.obs;

  String messageTiming(DateTime dateTime) {
    if (DateTime.now().difference(dateTime).inDays == 0) {
      return "${dateTime.toLocal().hour.toString().padLeft(2, "0")} : ${dateTime.toLocal().minute.toString().padLeft(2, "0")}";
    } else if (DateTime.now().difference(dateTime).inDays == 1) {
      return 'chat_time_yesterday'.tr;
    } else {
      return 'chat_time_day_ago'.trParams({
        'day': DateTime.now().difference(dateTime).inDays.toString(),
      });
    }
  }

  typeToWidget(int type, String msg, int count) {
    // For file types (1 = image/file, 2 = video/file), check the extension
    if (type == 1 || type == 2) {
      // Parse URL to get the path without query parameters
      String pathWithoutQuery = msg;
      if (msg.contains('?')) {
        pathWithoutQuery = msg.split('?').first;
      }
      String ext = pathWithoutQuery.split('.').last.toLowerCase();
      
      // Handle PDF files
      if (ext == 'pdf') {
        return Row(
          children: [
            const Icon(Icons.picture_as_pdf, size: 15, color: Colors.red),
            const SizedBox(width: 5),
            Text(
              'PDF',
              style: TextStyle(
                fontSize: 13,
                fontFamily: AppFontStyleTextStrings.regular,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        );
      }
      // Handle Word documents
      else if (ext == 'doc' || ext == 'docx') {
        return Row(
          children: [
            const Icon(Icons.description, size: 15, color: Colors.blue),
            const SizedBox(width: 5),
            Text(
              'document_str'.tr,
              style: TextStyle(
                fontSize: 13,
                fontFamily: AppFontStyleTextStrings.regular,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        );
      }
      // Handle videos
      else if (ext == 'mp4' || ext == 'mov' || ext == 'avi') {
        return Row(
          children: [
            Icon(Icons.videocam, size: 15, color: AppColors.themeColor3),
            const SizedBox(width: 5),
            Text(
              'video_str'.tr,
              style: TextStyle(
                fontFamily: AppFontStyleTextStrings.regular,
                fontSize: 13,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        );
      }
      // Handle images (default for type 1)
      else {
        return Row(
          children: [
            Icon(Icons.photo, size: 15, color: AppColors.themeColor3),
            const SizedBox(width: 5),
            Text(
              'photo_str'.tr,
              style: TextStyle(
                fontSize: 13,
                fontFamily: AppFontStyleTextStrings.regular,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        );
      }
    } else {
      return Text(
        msg,
        style: TextStyle(
          fontFamily: count > 0
              ? AppFontStyleTextStrings.bold
              : AppFontStyleTextStrings.regular,
          color: count > 0 ? AppColors.GREEN : AppColors.greyShade6,
        ),
        overflow: TextOverflow.ellipsis,
      );
    }
  }

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    myUid.value =
        StorageService.readData(key: LocalStorageKeys.userIdWithAscii) ?? "";
    loginCheckUser.value =
        StorageService.readData(key: LocalStorageKeys.isLoggedIn) ?? false;
    if (myUid.value.isNotEmpty) {
      getChatListData();
    }
  }
}
