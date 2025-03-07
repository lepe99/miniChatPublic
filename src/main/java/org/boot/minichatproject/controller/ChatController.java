package org.boot.minichatproject.controller;

import lombok.RequiredArgsConstructor;
import org.boot.minichatproject.dto.ChatDto;
import org.boot.minichatproject.service.ChatService;
import org.boot.minichatproject.util.Utils;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Controller
@RequiredArgsConstructor
public class ChatController {
    
    private final ChatService chatService;
    private final Utils utils;
    
    @GetMapping("/")
    public String chat(Model model) {
        // 채팅 목록 조회하여 모델에 적재
        List<ChatDto> chatList = chatService.selectChatList();
        model.addAttribute("chatList", chatList);
        return "chat";
    }
    
    @PostMapping("/insert")
    @ResponseBody
    public String insert(@RequestParam String content, @SessionAttribute String nickname,
                         @SessionAttribute String profileImage) {
        // 채팅 등록
        ChatDto chatDto = new ChatDto();
        // 닉네임, 프로필사진은 세션에서 가져옴
        chatDto.setNickname(nickname);
        chatDto.setProfileImage(profileImage);
        // 메시지는 이스케이프 처리
        String escapedContents = utils.escapeHtml(content);
        chatDto.setMessage(escapedContents);
        chatService.addChat(chatDto);
        
        return "success";
    }
}
