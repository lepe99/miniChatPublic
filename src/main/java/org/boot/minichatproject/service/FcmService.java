package org.boot.minichatproject.service;

import com.google.firebase.FirebaseApp;
import com.google.firebase.messaging.*;
import lombok.RequiredArgsConstructor;
import org.boot.minichatproject.mapper.FcmMapper;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class FcmService {
    
    private final FirebaseApp firebaseApp;
    private final FcmMapper fcmMapper;
    
    // 여러 사용자에게 푸시 알림 보내기
    public BatchResponse sendMulticastWebPush(List<String> tokens, String title, String body, String icon)
            throws FirebaseMessagingException {
        
        // MulticastMessage 사용
        MulticastMessage message = MulticastMessage.builder()
                .setWebpushConfig(WebpushConfig.builder()
                        .setNotification(WebpushNotification.builder()
                                .setTitle(title)
                                .setBody(body)
                                .setIcon(icon)
                                .build())
                        .build())
                .addAllTokens(tokens) // 모든 토큰 한번에 추가
                .build();
        
        // sendMulticast 메서드 사용
        BatchResponse response = FirebaseMessaging.getInstance(firebaseApp).sendMulticast(message);
        
        // 응답 처리
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