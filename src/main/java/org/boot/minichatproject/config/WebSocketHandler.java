package org.boot.minichatproject.config;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.CloseStatus;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketSession;
import org.springframework.web.socket.handler.TextWebSocketHandler;

import java.io.IOException;
import java.net.URI;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;

@Component
public class WebSocketHandler extends TextWebSocketHandler {
    // 동시성 문제 해결 위해 ConcurrentHashMap 사용
    // 웹소켓 세션을 저장할 set
    private Set<WebSocketSession> sessions = Collections.newSetFromMap(new ConcurrentHashMap<>());
    // 세션과 사용자 정보를 매핑할 맵
    private Map<WebSocketSession, Map<String, String>> sessionInfo = new ConcurrentHashMap<>();
    // JSON 매핑을 위한 ObjectMapper
    private final ObjectMapper objectMapper = new ObjectMapper();
    
    // 웹소켓 연결이 열리고 사용이 준비될 때 호출
    @Override
    public void afterConnectionEstablished(WebSocketSession session) throws Exception {
        sessions.add(session);
        
        // url 파라미터로 전달된 사용자 정보 가져오기
        URI uri = session.getUri();
        if (uri != null) {
            // url 파싱 후 사용자 정보 가져오기
            String query = uri.getQuery();
            if (query != null) {
                String[] queryParams = query.split("&");
                Map<String, String> params = new HashMap<>();
                for (String param : queryParams) {
                    String[] keyValue = param.split("=", 2);
                    params.put(keyValue[0], keyValue[1]);
                }

                // 세션에 사용자 정보 저장
                Map<String, String> userInfo = new HashMap<>();
                userInfo.put("nickname", params.get("nickname"));
                userInfo.put("profileImage", params.get("profileImage"));
                sessionInfo.put(session, userInfo);
                
                // 접속 메시지 생성, 전송
                Map<String, Object> message = createMessage("enter", userInfo);
                sendMessageToAll(objectMapper.writeValueAsString(message));
            }
        }
        
        // 유저 리스트 전송
        sendUserList();
    }
    
    // 메세지 처리
    @Override
    protected void handleTextMessage(WebSocketSession session, TextMessage message) throws Exception {
        // getPayload(): 메시지 내용을 문자열로 반환
        Map<String, Object> messageMap = objectMapper.readValue(message.getPayload(), Map.class);
        Map<String, String> userInfo = sessionInfo.get(session);
        
        messageMap.put("nickname", userInfo.get("nickname"));
        messageMap.put("profileImage", userInfo.get("profileImage"));
        // 메시지 전송
        sendMessageToAll(objectMapper.writeValueAsString(messageMap));
    }
    
    // 웹소켓 연결이 닫힐 때 호출
    @Override
    public void afterConnectionClosed(WebSocketSession session, CloseStatus status) throws Exception {
        // 세션 정보 먼저 가져오기
        Map<String, String> userInfo = sessionInfo.get(session);
        
        // 세션 정보 삭제
        sessions.remove(session);
        sessionInfo.remove(session);
        
        // 종료 메시지 생성, 전송 (NullPointerException 방지)
        if (userInfo != null) {
            Map<String, Object> message = createMessage("leave", userInfo);
            sendMessageToAll(objectMapper.writeValueAsString(message));
        }
        
        // 유저 리스트 전송
        sendUserList();
    }
    
    // 메시지 전송
    private void sendMessageToAll(String message) throws IOException {
        for (WebSocketSession session : sessions) {
            session.sendMessage(new TextMessage(message));
        }
    }
    
    // 메시지 생성
    private Map<String, Object> createMessage(String type, Map<String, String> userInfo) {
        Map<String, Object> message = new HashMap<>();
        message.put("type", type);
        message.put("userInfo", userInfo);
        return message;
    }
    
    // 유저 리스트 생성
    private void sendUserList() throws IOException {
        // 사용자 정보를 리스트로 변환
        List<Map<String, String>> userList = new ArrayList<>();
        for (Map<String, String> userInfo : sessionInfo.values()) {
            userList.add(userInfo);
        }
        // message map 생성하여 전송
        Map<String, Object> message = new HashMap<>();
        message.put("type", "userList");
        message.put("userList", userList);
        sendMessageToAll(objectMapper.writeValueAsString(message));
    }
}
