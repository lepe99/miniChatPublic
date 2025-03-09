package org.boot.minichatproject.service;

import com.google.firebase.FirebaseApp;
import com.google.firebase.messaging.*;
import lombok.RequiredArgsConstructor;
import org.boot.minichatproject.mapper.FcmMapper;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class FcmService {
    
    private final FirebaseApp firebaseApp;
    private final FcmMapper fcmMapper;
    
    // 여러 사용자에게 푸시 알림 보내기
    public BatchResponse sendMulticastWebPush(List<String> tokens, String title, String body, String icon)
            throws FirebaseMessagingException {
        
        // 1. Message 리스트 생성 (빌더 패턴 사용)
        List<Message> messages = tokens.stream()
                .map(token -> Message.builder()
                        .setWebpushConfig(WebpushConfig.builder()
                                .setNotification(WebpushNotification.builder()
                                        .setTitle(title)
                                        .setBody(body)
                                        .setIcon(icon)
                                        .build())
                                .build())
                        .setToken(token)
                        .build())
                .collect(Collectors.toList());
        
        // 2. sendAll()을 사용하여 메시지 전송
        BatchResponse response = FirebaseMessaging.getInstance(firebaseApp).sendAll(messages);
        
        // 3. 응답 처리 (성공/실패 로그)
        if (response.getFailureCount() > 0) {
            List<SendResponse> responses = response.getResponses();
            for (int i = 0; i < responses.size(); i++) {
                if (!responses.get(i).isSuccessful()) {
                    System.err.println(
                            "Failed to send message to token: " + tokens.get(i) +
                                    ". Error: " + responses.get(i).getException().getMessage()
                    );
                }
            }
        }
        return response;
    }
    
    // db 토큰 삽입
    public void insertToken(String token) {
        fcmMapper.insertToken(token);
    }
    
    // db 토큰 삭제
    public void deleteToken(String token) {
        fcmMapper.deleteToken(token);
    }
    
    // db 토큰 조회
    public List<String> selectTokens() {
        return fcmMapper.selectTokens();
    }
}