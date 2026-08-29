// ignore_for_file: file_names, avoid_unnecessary_containers, avoid_print

import 'package:chat_app/database/database.dart';
import 'package:chat_app/models/chat_room_model.dart';
import 'package:chat_app/models/message_model.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:chat_app/pages/main_page.dart';
import 'package:chat_app/pages/other_user_info_page.dart';
import 'package:chat_app/pages/search_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';

class ChatRoomPage extends StatefulWidget {
  final UserModel targetUser;
  final ChatRoomModel chatroom;
  final UserModel userModel;
  final User firebaseUser;

  const ChatRoomPage({
    Key? key,
    required this.targetUser,
    required this.chatroom,
    required this.userModel,
    required this.firebaseUser,
  }) : super(key: key);

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  TextEditingController messageController = TextEditingController();
  final _myBox = Hive.box('mybox');
  BlockMessDataBase db = BlockMessDataBase();

  String? selectedMenu;
  bool isBlock = false;
  bool isBlocked = false;
  bool isSendingImage = false;

  @override
  void initState() {
    if (_myBox.get("BLOCK") == null) {
      db.createInitialData(widget.userModel.uid!, widget.targetUser.uid!);
    } else {
      db.loadData();
    }

    checkBlock();
    super.initState();
  }

  Future<void> sendMessage({String? imageUrl}) async {
    final msg = messageController.text.trim();
    final hasText = msg.isNotEmpty;
    final hasImage = imageUrl != null && imageUrl.isNotEmpty;

    if (!hasText && !hasImage) {
      debugPrint('ChatRoom debug -> bo qua gui vi khong co text hoac anh');
      return;
    }

    final newMessage = MessageModel(
      messageid: uuid.v1(),
      sender: widget.userModel.uid,
      createdon: DateTime.now().toIso8601String(),
      text: hasText ? msg : '',
      seen: false,
      imageUrl: imageUrl,
    );

    debugPrint(
        'ChatRoom debug -> bat dau gui messageId: ${newMessage.messageid}');
    debugPrint('ChatRoom debug -> hasText: $hasText, hasImage: $hasImage');

    await FirebaseFirestore.instance
        .collection("chatrooms")
        .doc(widget.chatroom.chatroomid)
        .collection("messages")
        .doc(newMessage.messageid)
        .set(newMessage.toMap());

    widget.chatroom.lastMessage = hasImage ? '[Hình ảnh]' : msg;

    await FirebaseFirestore.instance
        .collection("chatrooms")
        .doc(widget.chatroom.chatroomid)
        .set(widget.chatroom.toMap());

    messageController.clear();

    debugPrint('ChatRoom debug -> gui thanh cong, da clear input');
  }

  Future<void> _pickAndSendImage() async {
    debugPrint('ChatRoom debug -> user tap icon anh');

    try {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);

      if (pickedFile == null) {
        debugPrint('ChatRoom debug -> user huy chon anh');
        return;
      }

      setState(() {
        isSendingImage = true;
      });

      final imageUrl = await _uploadChatImage(pickedFile);
      if (imageUrl == null || imageUrl.isEmpty) {
        debugPrint('ChatRoom debug -> upload anh that bai');
        return;
      }

      await sendMessage(imageUrl: imageUrl);
      debugPrint('ChatRoom debug -> da gui message anh: $imageUrl');
    } catch (e) {
      debugPrint('ChatRoom debug -> loi khi chon/gui anh: $e');
    } finally {
      if (mounted) {
        setState(() {
          isSendingImage = false;
        });
      }
    }
  }

  Future<String?> _uploadChatImage(XFile pickedFile) async {
    debugPrint('ChatRoom debug -> bat dau upload anh: ${pickedFile.name}');

    final bytes = await pickedFile.readAsBytes();
    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${pickedFile.name}';
    final ref = FirebaseStorage.instance
        .ref()
        .child('chat_images')
        .child(widget.chatroom.chatroomid.toString())
        .child(fileName);

    await ref.putData(bytes);
    final downloadUrl = await ref.getDownloadURL();

    debugPrint('ChatRoom debug -> upload xong, downloadUrl: $downloadUrl');
    return downloadUrl;
  }

  void addListBlock() {
    if (db.data.isEmpty) {
      db.data.add([widget.userModel.uid, widget.targetUser.uid, true]);
      return;
    }

    bool elementExists = false;

    for (int i = 0; i < db.data.length; i++) {
      if (widget.userModel.uid == db.data[i][0] &&
          widget.targetUser.uid == db.data[i][1]) {
        db.data[i][2] = true;
        elementExists = true;
        setState(() {});
        break;
      }
    }

    if (!elementExists) {
      db.data.add([widget.userModel.uid, widget.targetUser.uid, true]);
    }
  }

  void checkBlock() {
    bool newBlock = false;

    for (int i = 0; i < db.data.length; i++) {
      if (widget.userModel.uid != db.data[i][0] &&
          widget.targetUser.uid != db.data[i][1]) {
        isBlock = false;
        isBlocked = false;
        setState(() {});
      }
    }

    for (int i = 0; i < db.data.length; i++) {
      if (widget.userModel.uid == db.data[i][1] &&
          widget.targetUser.uid == db.data[i][0]) {
        isBlocked = db.data[i][2];
        newBlock = isBlocked;
        setState(() {});
      }
    }

    for (int i = 0; i < db.data.length; i++) {
      if (widget.userModel.uid == db.data[i][0] &&
          widget.targetUser.uid == db.data[i][1]) {
        isBlock = db.data[i][2];
        isBlocked = newBlock;
        setState(() {});
      }
    }

    print(isBlock);
  }

  Widget _buildUserInfoRow() {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: Colors.grey[300],
          backgroundImage:
              NetworkImage(widget.targetUser.profilepicture.toString()),
        ),
        const SizedBox(width: 10),
        Text(
          widget.targetUser.fullname.toString(),
          style: const TextStyle(color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildAppBarTitle() {
    if (isBlock) {
      return _buildUserInfoRow();
    }

    return Row(
      children: [
        Expanded(child: _buildUserInfoRow()),
        PopupMenuButton<String>(
          iconColor: Colors.white,
          initialValue: selectedMenu,
          onSelected: (item) {
            setState(() {
              selectedMenu = item;
            });
            print(selectedMenu);
          },
          itemBuilder: (context) => <PopupMenuEntry<String>>[
            PopupMenuItem(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OtherUserScreen(
                      targetUser: widget.targetUser,
                      userModel: widget.userModel,
                    ),
                  ),
                );
              },
              child: const Text("Thông tin người dùng"),
            ),
            PopupMenuItem(
              onTap: () {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _showSentImagesHistory();
                });
              },
              child: const Text("Ảnh đã gửi"),
            ),
            PopupMenuItem(
              onTap: () {
                addListBlock();
                checkBlock();
                db.updateDataBase();
              },
              child: const Text("Chặn tin nhắn"),
            ),
          ],
        ),
      ],
    );
  }

  void _showImagePreview(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.black,
          insetPadding: const EdgeInsets.all(12),
          child: InteractiveViewer(
            child: Image.network(imageUrl, fit: BoxFit.contain),
          ),
        );
      },
    );
  }

  void _showSentImagesHistory() {
    debugPrint('ChatRoom debug -> mo lich su anh da gui');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.75,
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Lịch sử ảnh đã gửi',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("chatrooms")
                      .doc(widget.chatroom.chatroomid)
                      .collection("messages")
                      .orderBy("createdon", descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.active) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return const Center(
                        child: Text('Không tải được lịch sử ảnh đã gửi'),
                      );
                    }

                    if (!snapshot.hasData) {
                      return const Center(
                        child: Text('Chưa có dữ liệu ảnh đã gửi'),
                      );
                    }

                    final dataSnapshot = snapshot.data as QuerySnapshot;
                    final imageMessages = dataSnapshot.docs
                        .map((doc) => MessageModel.fromMap(
                              doc.data() as Map<String, dynamic>,
                            ))
                        .where((message) =>
                            message.sender == widget.userModel.uid &&
                            message.imageUrl != null &&
                            message.imageUrl!.isNotEmpty)
                        .toList();

                    debugPrint(
                      'ChatRoom debug -> so anh da gui: ${imageMessages.length}',
                    );

                    if (imageMessages.isEmpty) {
                      return const Center(
                        child: Text(
                            'Bạn chưa gửi ảnh nào trong cuộc trò chuyện này'),
                      );
                    }

                    return GridView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: imageMessages.length,
                      itemBuilder: (context, index) {
                        final imageUrl = imageMessages[index].imageUrl!;

                        return GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                            _showImagePreview(imageUrl);
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[200],
                                  alignment: Alignment.center,
                                  child:
                                      const Icon(Icons.broken_image_outlined),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMessageBubble(MessageModel currentMesage) {
    final isCurrentUserMessage = currentMesage.sender == widget.userModel.uid;
    final hasImage =
        currentMesage.imageUrl != null && currentMesage.imageUrl!.isNotEmpty;
    final hasText =
        currentMesage.text != null && currentMesage.text!.trim().isNotEmpty;

    return Row(
      mainAxisAlignment: isCurrentUserMessage
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.7,
          ),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isCurrentUserMessage ? Colors.blueAccent : Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (hasImage)
                  GestureDetector(
                    onTap: () {
                      _showImagePreview(currentMesage.imageUrl!);
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        currentMesage.imageUrl!,
                        width: 220,
                        height: 220,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                if (hasImage && hasText) const SizedBox(height: 8),
                if (hasText)
                  Text(
                    currentMesage.text.toString(),
                    style: TextStyle(
                      color: isCurrentUserMessage ? Colors.white : Colors.black,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMessages() {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("chatrooms")
              .doc(widget.chatroom.chatroomid)
              .collection("messages")
              .orderBy("createdon", descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.active) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return const Center(
                child: Text(
                  'Không thể kết nối vui lòng kiểm tra kết nối internet',
                ),
              );
            }

            if (!snapshot.hasData) {
              return const Center(
                child: Text("Hãy gửi lời chào đến bạn mới"),
              );
            }

            final dataSnapshot = snapshot.data as QuerySnapshot;

            return ListView.builder(
              reverse: true,
              itemCount: dataSnapshot.docs.length,
              itemBuilder: (context, index) {
                final currentMesage = MessageModel.fromMap(
                  dataSnapshot.docs[index].data() as Map<String, dynamic>,
                );

                return _buildMessageBubble(currentMesage);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildUnblockText() {
    return RichText(
      text: TextSpan(
        children: [
          const TextSpan(
            text: "Bạn đã chặn người dùng này. ",
            style: TextStyle(color: Colors.black),
          ),
          TextSpan(
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                for (int i = 0; i < db.data.length; i++) {
                  if (widget.userModel.uid == db.data[i][0] &&
                      widget.targetUser.uid == db.data[i][1]) {
                    db.data[i][2] = false;
                    setState(() {});
                    break;
                  }
                }

                checkBlock();
                db.updateDataBase();
              },
            text: "Bỏ chặn",
            style: const TextStyle(color: Colors.blue),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      child: Row(
        children: [
          Flexible(
            child: TextField(
              controller: messageController,
              maxLines: null,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: "Tin nhắn ",
              ),
            ),
          ),
          if (isSendingImage)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            IconButton(
              onPressed: _pickAndSendImage,
              icon: Icon(
                Icons.image_outlined,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          IconButton(
            onPressed: () async {
              await sendMessage();
            },
            icon: Icon(
              Icons.send,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomArea() {
    if (isBlock) {
      return _buildUnblockText();
    }

    if (isBlocked) {
      return const Text("Bạn đã bị người dùng này chặn tin nhắn");
    }

    return _buildMessageInput();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent.shade700,
        automaticallyImplyLeading: true,
        leadingWidth: 25,
        titleSpacing: 0,
        leading: IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          icon: const Icon(
            Icons.arrow_back_ios_sharp,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return MainPage(
                userModel: widget.userModel,
                firebaseUser: widget.firebaseUser,
              );
            }));
          },
        ),
        title: _buildAppBarTitle(),
      ),
      body: SafeArea(
        child: Container(
          color: const Color(0xFFF1F4F8),
          child: Column(
            children: [
              _buildMessages(),
              _buildBottomArea(),
            ],
          ),
        ),
      ),
    );
  }
}
