package org.boot.minichatproject.service;

import com.google.firebase.FirebaseApp;
import com.google.firebase.messaging.*;
import lombok.RequiredArgsConstructor;
import org.boot.minichatproject.mapper.FcmMapper;
import org.springframework.beans.factory.annotation.Autowired;
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
        
        MulticastMessage message = MulticastMessage.builder()
                .setWebpushConfig(WebpushConfig.builder()
                        .setNotification(new WebpushNotification(title, body, icon))
                        .build())
                .addAllTokens(tokens)
                .build();
        
        BatchResponse response = FirebaseMessaging.getInstance(firebaseApp).sendMulticast(message);
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