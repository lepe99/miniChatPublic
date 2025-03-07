package org.boot.minichatproject.mapper;

import org.apache.ibatis.annotations.Mapper;
import org.boot.minichatproject.dto.ChatDto;

import java.util.List;

@Mapper
public interface ChatMapper {
    
    // 채팅 목록 조회 (최근 100개)
    List<ChatDto> selectChatList();
    
    // 채팅 등록
    void insertChat(ChatDto chatDto);
    
    // 채팅 갯수 조회
    int selectChatCount();
    
    // 채팅 이미지 불러오기 (제일 오래된 1개)
    String selectFirstChatImage();
    
    // 채팅 삭제 (제일 오래된 1개)
    void deleteFirstChat();
    
}
