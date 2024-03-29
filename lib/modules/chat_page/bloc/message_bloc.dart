import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc_firebase_2/common/constants/app_constants.dart';
import 'package:flutter_bloc_firebase_2/modules/chat_member_page/models/room.dart';
import 'package:flutter_bloc_firebase_2/modules/chat_member_page/models/roomArge.dart';
import 'package:flutter_bloc_firebase_2/modules/chat_page/models/message.dart';
import 'package:flutter_bloc_firebase_2/modules/chat_page/repositories/impl/message_repo_impl.dart';

part 'message_event.dart';
part 'message_state.dart';

class MessageBloc extends Bloc<MessageEvent, MessageState> {
  final MessageRepositoyImpl messageRepositoyImpl;
  final CollectionReference _messageCollection =
      FirebaseFirestore.instance.collection('messages');

  MessageBloc({required this.messageRepositoyImpl, required RoomArgs roomArgs})
      : super(MessageState(chatId: roomArgs.chatRoomId)) {
    _messageCollection.snapshots().listen((QuerySnapshot querySnapshot) {
      add(FetchMesageEvent());
    });
    on<FetchMesageEvent>(_onFetchMesageEvent);
    on<SendMessageEvent>(_onSentMessageEvent);
    on<MessageEvent>((event, emit) {});
  }

  Future<void> _onFetchMesageEvent(
    FetchMesageEvent event,
    Emitter<MessageState> emit,
  ) async {
    emit(state.copyWith(
      status: StateStatus.loading,
    ));

    final Either<String, List<Message>> result =
        await messageRepositoyImpl.getAllMessages(state.chatId);
    // print(result);
    result.fold(
        (left) => emit(state.copyWith(
              status: StateStatus.failure,
              messagesList: <Message>[],
            )), (List<Message> right) {
      List<Message> newMessages = right
          .where((newMessage) => !state.messagesList
              .any((existingMessage) => newMessage.id == existingMessage.id))
          .toList();
      // print(newMessages.length);
      // List<Message> messageSort = List.from(state.messagesList)
      //   ..addAll(newMessages);
      // messageSort.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      emit(state.copyWith(
        status: StateStatus.success,
        messagesList: List.from(state.messagesList)..addAll(newMessages),
      ));
    });
  }

  Future<void> _onSentMessageEvent(
    SendMessageEvent event,
    Emitter<MessageState> emit,
  ) async {
    await messageRepositoyImpl.sendMessage(
      event.message,
      event.uId,
      state.chatId,
    );
  }
}
