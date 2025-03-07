package org.boot.minichatproject.controller;

import lombok.RequiredArgsConstructor;
import org.boot.minichatproject.dto.ChatDto;
import org.boot.minichatproject.service.ChatService;
import org.boot.minichatproject.service.NcpObjectStorageService;
import org.boot.minichatproject.util.Utils;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

@Controller
@RequiredArgsConstructor
public class ChatController {
    
    private final ChatService chatService;
    private final Utils utils;
    private final NcpObjectStorageService ncpObjectStorageService;
    
    // 버킷 이름
    private final String bucketName = "minichat-image";
    
    
    @GetMapping("/")
    public String chat(Model model) {
        // 채팅 목록 조회하여 모델에 적재
        List<ChatDto> chatList = chatService.selectChatList();
        model.addAttribute("chatList", chatList);
        
        // object storage 활용 위한 url 정보
        model.addAttribute("objectStorageUrl", "https://kr.object.ncloudstorage.com/" + bucketName);
        model.addAttribute("imageOptimizerFrontUrl", "https://wcd92rhi8921.edge.naverncp.com/BNdZj87Ujg");
        model.addAttribute("imageOptimizerBackUrl", "?type=w&w=200&ttype=jpg");
        return "chat";
    }
    
    @PostMapping("/insert")
    @ResponseBody
    public String insert(@RequestParam String message, @SessionAttribute String nickname,
                         @SessionAttribute String profileImage, @RequestParam("chatImage") MultipartFile chatImage) {
        // 채팅 등록
        ChatDto chatDto = new ChatDto();
        // 닉네임, 프로필사진은 세션에서 가져옴
        chatDto.setNickname(nickname);
        chatDto.setProfileImage(profileImage);
        // 메시지는 이스케이프 처리
        String escapedMessage = utils.escapeHtml(message);
        chatDto.setMessage(escapedMessage);
        
        String chatImageName = null;
        // 이미지 파일이 있으면 object storage에 업로드
        if (!chatImage.isEmpty()) {
            chatImageName = ncpObjectStorageService.uploadFile(bucketName, "images", chatImage);
            chatDto.setChatImage(chatImageName);
        }
        
        // db insert
        chatService.addChat(chatDto);
        
        // 채팅 이미지 파일명 반환
        return chatImageName;
    }
}
