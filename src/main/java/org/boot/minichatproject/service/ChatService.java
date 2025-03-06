package org.boot.minichatproject.service;

import lombok.RequiredArgsConstructor;
import org.boot.minichatproject.dto.ChatDto;
import org.boot.minichatproject.mapper.ChatMapper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class ChatService {
    
    private final ChatMapper chatMapper;
    
    // 채팅 목록 조회 (최근 100개)
    public List<ChatDto> selectChatList() {
        return chatMapper.selectChatList();
    }
    
    // 채팅 등록
    // 하나의 트랜잭션으로 처리
    @Transactional
    public void addChat(ChatDto chatDto) {
        chatMapper.insertChat(chatDto);
        int chatCount = chatMapper.selectChatCount();
        // 채팅이 100개 이상이면 가장 오래된 채팅 삭제
        if (chatCount > 100) {
            chatMapper.deleteFirstChat();
        }
    }
}
