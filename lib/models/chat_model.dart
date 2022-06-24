import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:pegasus_medical_1808/services/navigation_service.dart';
import 'package:pegasus_medical_1808/shared/global_config.dart';
import 'package:pegasus_medical_1808/utils/database_helper.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../locator.dart';
import '../shared/global_config.dart';
import '../shared/global_functions.dart';
import '../utils/database_helper.dart';
import './authentication_model.dart';
import '../shared/strings.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import 'authentication_model.dart';
import 'package:pegasus_medical_1808/models/users_model.dart';




class ChatModel extends ChangeNotifier {

  DatabaseHelper _databaseHelper = DatabaseHelper();
  AuthenticationModel authenticationModel = AuthenticationModel();
  final NavigationService _navigationService = locator<NavigationService>();
  ChatModel(this.authenticationModel);

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  List<Map<String, dynamic>> _transferReports = [];
  String _selTransferReportId;
  final dateFormatDay = DateFormat("dd-MM-yyyy");

  List<Map<String, dynamic>> get allTransferReports {
    return List.from(_transferReports);
  }
  int get selectedTransferReportIndex {
    return _transferReports.indexWhere((Map<String, dynamic> transferReport) {
      return transferReport[Strings.documentId] == _selTransferReportId;
    });
  }
  String get selectedTransferReportId {
    return _selTransferReportId;
  }

  Map<String, dynamic> get selectedTransferReport {
    if (_selTransferReportId == null) {
      return null;
    }
    return _transferReports.firstWhere((Map<String, dynamic> transferReport) {
      return transferReport[Strings.documentId] == _selTransferReportId;
    });
  }
  void selectTransferReport(String transferReportId) {
    _selTransferReportId = transferReportId;
    if (transferReportId != null) {
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> addConversation(User selectedUser) async {

    bool success = false;
    String refId;

    bool hasDataConnection = await GlobalFunctions.hasDataConnection();


    if(hasDataConnection) {
      bool isTokenExpired = GlobalFunctions.isTokenExpired();
      bool authenticated = true;

      if (isTokenExpired)
        authenticated = await authenticationModel.reAuthenticate();

      if (authenticated) {

        try {

          bool groupExists = false;

          if(user.groups != null && user.groups.isNotEmpty){

            for(String group in user.groups){

              DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance.collection('chat_groups').doc(group).get().timeout(Duration(seconds: 60));

              List<dynamic> memberIdsDynamic = documentSnapshot.get('member_ids');
              List<String> memberIdsString = memberIdsDynamic.map((value) => value as String).toList();

              if(memberIdsString.length == 2){

                bool matchCurrentUser;
                bool matchSelectedUser;

                memberIdsString.forEach((element) {
                  if(element == user.uid) matchCurrentUser = true;
                  if(element == selectedUser.uid) matchSelectedUser = true;
                });

                if(matchSelectedUser == true && matchCurrentUser == true){
                  groupExists = true;
                  refId = documentSnapshot.id;
                  success = true;
                }

              }
            }
          }


          if(!groupExists){
            DocumentReference ref = await FirebaseFirestore.instance.collection('chat_groups').add({
              'created_at': Timestamp.now().millisecondsSinceEpoch,
              'created_by_name': user.name,
              'created_by_id': user.uid,
              'member_names': [user.name, selectedUser.name],
              'member_ids': [user.uid, selectedUser.uid],
              'modified_at': Timestamp.now().millisecondsSinceEpoch,
              'name': 'Chat',
              'type': 1,
              'recent_message': {
                'name': user.name,
                'uid': user.uid,
                'value': 'New Chat Started!',
                user.uid: true,
                selectedUser.uid: false,
                'timestamp': Timestamp.now().millisecondsSinceEpoch,
              },
            }).timeout(Duration(seconds: 60));

            //await FirebaseFirestore.instance.collection('chat_groups').doc(ref.id).update({'doc_id': ref.id});


            DocumentSnapshot selectedUserSnapShot = await FirebaseFirestore.instance.collection('users').doc(selectedUser.uid).get().timeout(Duration(seconds: 60));

            Map<String, dynamic> userSnapshotMap = selectedUserSnapShot.data() as Map<String, dynamic>;
            dynamic selectedUserCurrentGroups;
            List<String> selectedUserCurrentGroupsListString = [];

            if(userSnapshotMap.containsKey('groups')){
              selectedUserCurrentGroups = selectedUserSnapShot.get(Strings.groups);

            }

            if(selectedUserCurrentGroups != null){
              List<dynamic> selectedUserCurrentGroupsListDynamic = selectedUserSnapShot.get(Strings.groups);
              selectedUserCurrentGroupsListString = selectedUserCurrentGroupsListDynamic.map((value) => value as String).toList();
              selectedUserCurrentGroupsListString.add(ref.id);

            } else {
              selectedUserCurrentGroupsListString = [ref.id];
            }


            DocumentSnapshot currentUserSnapShot = await FirebaseFirestore.instance.collection('users').doc(user.uid).get().timeout(Duration(seconds: 60));

            Map<String, dynamic> currentUserSnapshotMap = currentUserSnapShot.data() as Map<String, dynamic>;
            dynamic currentUserCurrentGroups;
            List<String> currentUserCurrentGroupsListString = [];

            if(currentUserSnapshotMap.containsKey('groups')){
              currentUserCurrentGroups = currentUserSnapShot.get(Strings.groups);
            }


            if(currentUserCurrentGroups != null){
              List<dynamic> currentUserCurrentGroupsListDynamic = currentUserSnapShot.get(Strings.groups);
              currentUserCurrentGroupsListString = currentUserCurrentGroupsListDynamic.map((value) => value as String).toList();
              currentUserCurrentGroupsListString.add(ref.id);

            } else {
              currentUserCurrentGroupsListString = [ref.id];
            }

            FirebaseFirestore.instance.collection('users').doc(user.uid).update(
                {'groups' : currentUserCurrentGroupsListString}).timeout(Duration(seconds: 60));
            FirebaseFirestore.instance.collection('users').doc(selectedUser.uid).update(
                {'groups' : selectedUserCurrentGroupsListString}).timeout(Duration(seconds: 60));

            user.groups = currentUserCurrentGroupsListString;
            sharedPreferences.setString(Strings.groups, jsonEncode(currentUserCurrentGroupsListString));
            authenticationModel.notifyListeners();

            success = true;
            refId = ref.id;


              GlobalFunctions.sendPushNotification(
                  selectedUser.uid, 'New Conversation',
                  user.name + ' has started a conversation with you');


          }










        } on TimeoutException catch (_) {
          // A timeout occurred.
          GlobalFunctions.showToast('Network Timeout, unable to start chat');

        } catch (e) {
          print(e);

        }

      }
    } else {
      GlobalFunctions.showToast('No Data Connection, unable to start chat');
    }
    return {'success' : success, 'refId' : refId};
  }


  Future<Map<String, dynamic>> addGroup(List<Map<String, dynamic>> participants, String chatName) async {

    bool success = false;
    String refId;

    bool hasDataConnection = await GlobalFunctions.hasDataConnection();


    if(hasDataConnection) {
      bool isTokenExpired = GlobalFunctions.isTokenExpired();
      bool authenticated = true;

      if (isTokenExpired)
        authenticated = await authenticationModel.reAuthenticate();

      if (authenticated) {

        List<String> memberIds = [user.uid];
        List<String> memberIdsWithoutUser = [];

        for(Map<String, dynamic> participant in participants){
          memberIds.add(participant['id']);
          if(participant['id'] != user.uid) memberIdsWithoutUser.add(participant['id']);
        }

        List<String> memberNames = [user.name];

        for(Map<String, dynamic> participant in participants){
          memberNames.add(participant['name']);
        }


        try {

            DocumentReference ref = await FirebaseFirestore.instance.collection('chat_groups').add({
              'created_at': Timestamp.now().millisecondsSinceEpoch,
              'created_by_name': user.name,
              'created_by_id': user.uid,
              'member_names': memberNames,
              'member_ids': memberIds,
              'modified_at': Timestamp.now().millisecondsSinceEpoch,
              'name': chatName,
              'type': 2,
              'group_picture': null,
              'recent_message': {
                'name': user.name,
                'uid': user.uid,
                'value': 'New Group Created!',
                user.uid: true,
                for(String memberId in memberIdsWithoutUser) memberId : false,
                'timestamp': Timestamp.now().millisecondsSinceEpoch,
              },
            }).timeout(Duration(seconds: 60));


            for(String memberId in memberIdsWithoutUser){
              GlobalFunctions.sendPushNotification(
                  memberId, 'Added to new Group',
                  user.name + ' has added you to a group');
            }

            //await FirebaseFirestore.instance.collection('chat_groups').doc(ref.id).update({'doc_id': ref.id});



            for(Map<String, dynamic> participant in participants){

              if(participant['id'] != user.uid){
                DocumentSnapshot selectedUserSnapShot = await FirebaseFirestore.instance.collection('users').doc(participant['id']).get().timeout(Duration(seconds: 60));

                Map<String, dynamic> userSnapshotMap = selectedUserSnapShot.data() as Map<String, dynamic>;
                dynamic selectedUserCurrentGroups;
                List<String> selectedUserCurrentGroupsListString = [];

                if(userSnapshotMap.containsKey('groups')){
                  selectedUserCurrentGroups = selectedUserSnapShot.get(Strings.groups);

                }

                if(selectedUserCurrentGroups != null){
                  List<dynamic> selectedUserCurrentGroupsListDynamic = selectedUserSnapShot.get(Strings.groups);
                  selectedUserCurrentGroupsListString = selectedUserCurrentGroupsListDynamic.map((value) => value as String).toList();
                  selectedUserCurrentGroupsListString.add(ref.id);

                } else {
                  selectedUserCurrentGroupsListString = [ref.id];
                }

                FirebaseFirestore.instance.collection('users').doc(participant['id']).update(
                    {'groups' : selectedUserCurrentGroupsListString}).timeout(Duration(seconds: 60));
              }

            }



            DocumentSnapshot currentUserSnapShot = await FirebaseFirestore.instance.collection('users').doc(user.uid).get().timeout(Duration(seconds: 60));


            Map<String, dynamic> currentUserSnapshotMap = currentUserSnapShot.data() as Map<String, dynamic>;
            dynamic currentUserCurrentGroups;
            List<String> currentUserCurrentGroupsListString = [];

            if(currentUserSnapshotMap.containsKey('groups')){
              currentUserCurrentGroups = currentUserSnapShot.get(Strings.groups);
            }

            if(currentUserCurrentGroups != null){
              List<dynamic> currentUserCurrentGroupsListDynamic = currentUserSnapShot.get(Strings.groups);
              currentUserCurrentGroupsListString = currentUserCurrentGroupsListDynamic.map((value) => value as String).toList();
              currentUserCurrentGroupsListString.add(ref.id);

            } else {
              currentUserCurrentGroupsListString = [ref.id];
            }

            FirebaseFirestore.instance.collection('users').doc(user.uid).update(
                {'groups' : currentUserCurrentGroupsListString}).timeout(Duration(seconds: 60));




            user.groups = currentUserCurrentGroupsListString;
            sharedPreferences.setString(Strings.groups, jsonEncode(currentUserCurrentGroupsListString));
            authenticationModel.notifyListeners();

            success = true;
            refId = ref.id;



        } on TimeoutException catch (_) {
          // A timeout occurred.
          GlobalFunctions.showToast('Network Timeout, unable to create group');

        } catch (e) {
          print(e);

        }

      }
    } else {
      GlobalFunctions.showToast('No Data Connection, unable to start chat');
    }
    return {'success' : success, 'refId' : refId, 'group_picture': null};
  }


  Future<void> addMessage(String value, String groupId, String replyMessageImage, String replyMessage, String replyMessageId, String replyAuthor, bool isReply, [File image, Uint8List imageWeb]) async {

    bool hasDataConnection = await GlobalFunctions.hasDataConnection();
    String imageUrl;


    if(hasDataConnection) {
      bool isTokenExpired = GlobalFunctions.isTokenExpired();
      bool authenticated = true;

      if (isTokenExpired)
        authenticated = await authenticationModel.reAuthenticate();

      if (authenticated) {

      try {

        DocumentReference ref = await FirebaseFirestore.instance.collection('chat_messages').doc(groupId).collection('messages').add({
          'author': user.name,
          'author_id': user.uid,
          'timestamp': Timestamp.now().millisecondsSinceEpoch,
          'value': value,
          'reply_message_image': replyMessageImage,
          'reply_message_id': replyMessageId,
          'reply_message': replyMessage,
          'reply_author': replyAuthor,
          'is_reply': isReply,
          'image': null,
        }).timeout(Duration(seconds: 60));


        if(image != null || imageWeb != null){

          Reference storageRef =
          FirebaseStorage.instance.ref().child('messagePictures/' + '${ref.id}/' + '${ref.id}.jpg');

          if(kIsWeb){
            storageRef = FirebaseStorage.instance.ref().child(firebaseStorageBucket + '/messagePictures/' + '${ref.id}/' + '${ref.id}.jpg');
          }


          UploadTask uploadTask;

          if(kIsWeb){
            uploadTask = storageRef.putData(
              imageWeb,
              SettableMetadata(
                contentType: 'image/jpg',
              ),
            );
          } else {
            uploadTask = storageRef.putFile(
              image,
              SettableMetadata(
                contentType: 'image/jpg',
              ),
            );
          }

          final TaskSnapshot downloadUrl =
          (await uploadTask);

          imageUrl = (await downloadUrl.ref.getDownloadURL());

          await FirebaseFirestore.instance.collection('chat_messages').doc(groupId).collection('messages').doc(ref.id).update({
            'author': user.name,
            'author_id': user.uid,
            'timestamp': Timestamp.now().millisecondsSinceEpoch,
            'value': value,
            'reply_message_image': replyMessageImage,
            'reply_message_id': replyMessageId,
            'reply_message': replyMessage,
            'reply_author': replyAuthor,
            'is_reply': isReply,
            'image': imageUrl,
          }).timeout(Duration(seconds: 60));

        }

        DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('chat_groups').doc(groupId).get().timeout(Duration(seconds: 60));
        List<dynamic> memberIdsDynamic = snapshot.get('member_ids');
        List<String> memberIds = memberIdsDynamic.map((value) => value as String).toList();
        List<String> otherMembers = [];
        for(String memberId in memberIds){
          if(memberId != user.uid) otherMembers.add(memberId);
        }
        
        await FirebaseFirestore.instance.collection('chat_groups').doc(groupId).update(
            {
              'modified_at': Timestamp.now().millisecondsSinceEpoch,
              'recent_message': {
              'name': user.name,
                'uid': user.uid,
              'id': ref.id,
              'value': value,
                user.uid: true,
                'image': imageUrl,
                for(String otherMember in otherMembers) otherMember: false,
                'timestamp': Timestamp.now().millisecondsSinceEpoch,
            }}).timeout(Duration(seconds: 60));

        String sendString = value;

        if(imageUrl!= null) sendString = 'Image';

        for(String otherMember in otherMembers){
          GlobalFunctions.sendPushNotification(
              otherMember, 'New message',
              '${user.name}' + ': ' + value);
        }

      } on TimeoutException catch (_) {
    // A timeout occurred.
    GlobalFunctions.showToast('Network Timeout, unable to send Message');

    } catch (e) {
    print(e);

    }


      }
    } else {
      GlobalFunctions.showToast('No Data Connection, unable to send message');
    }
  }

  Future<void> deleteMessage(String docId, String groupId, String image) async {

    bool hasDataConnection = await GlobalFunctions.hasDataConnection();


    if(hasDataConnection) {
      bool isTokenExpired = GlobalFunctions.isTokenExpired();
      bool authenticated = true;

      if (isTokenExpired)
        authenticated = await authenticationModel.reAuthenticate();

      if (authenticated) {

        try {

          await FirebaseFirestore.instance.collection('chat_messages').doc(groupId).collection('messages').doc(docId).delete().timeout(Duration(seconds: 60));

          DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('chat_groups').doc(groupId).get().timeout(Duration(seconds: 60));

          String lastGroupMessageId = snapshot.get('recent_message')['id'];
          List<dynamic> memberIdsDynamic = snapshot.get('member_ids');
          List<String> memberIds = memberIdsDynamic.map((value) => value as String).toList();
          List<String> otherMembers = [];
          for(String memberId in memberIds){
            if(memberId != user.uid) otherMembers.add(memberId);
          }

          if(lastGroupMessageId == docId){
            await FirebaseFirestore.instance.collection('chat_groups').doc(groupId).update(
                {
                  'modified_at': Timestamp.now().millisecondsSinceEpoch,
                  'recent_message': {
                  'name': user.name,
                    'uid': user.uid,
                  'id': '0',
                  'value': 'Message deleted',
                    user.uid: true,
                    for(String otherMember in otherMembers) otherMember: false,
                    'timestamp': Timestamp.now().millisecondsSinceEpoch,
                }}).timeout(Duration(seconds: 60));
          }

          if(image != null){

            Reference storageRef =
            FirebaseStorage.instance.ref().child('messagePictures/' + '$docId/' + '$docId.jpg');

            if(kIsWeb){
              storageRef = FirebaseStorage.instance.ref().child(firebaseStorageBucket + '/messagePictures/' + '$docId/' + '$docId.jpg');
            }

            await storageRef.delete();

          }

        } on TimeoutException catch (_) {
          // A timeout occurred.
          GlobalFunctions.showToast('Network Timeout, unable to delete Message');

        } catch (e) {
          print(e);

        }

      }
    } else {
      GlobalFunctions.showToast('No Data Connection, unable to delete message');
    }
  }
}


