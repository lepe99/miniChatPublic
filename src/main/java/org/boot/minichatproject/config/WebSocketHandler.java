package org.boot.minichatproject.config;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.google.firebase.messaging.BatchResponse;
import com.google.firebase.messaging.FirebaseMessagingException;
import jakarta.annotation.PostConstruct;
import jakarta.annotation.PreDestroy;
import lombok.RequiredArgsConstructor;
import org.boot.minichatproject.service.FcmService;
import org.boot.minichatproject.util.Utils;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Component;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.server.ResponseStatusException;
import org.springframework.web.socket.CloseStatus;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketSession;
import org.springframework.web.socket.handler.TextWebSocketHandler;

import java.io.IOException;
import java.net.URI;
import java.time.Instant;
import java.util.*;
import java.util.concurrent.*;

@Component
@RequiredArgsConstructor
public class WebSocketHandler extends TextWebSocketHandler {
    // JSON 매핑을 위한 ObjectMapper
    private final ObjectMapper objectMapper;
    // 유틸리티 클래스
    private final Utils utils;
    // FcmService
    private final FcmService fcmService;
    
    // 동시성 문제 해결 위해 ConcurrentHashMap 사용
    // 웹소켓 세션을 저장할 set
    private List<WebSocketSession> sessions = new CopyOnWriteArrayList<>();
    // 세션과 사용자 정보를 매핑할 맵
    private Map<WebSocketSession, Map<String, String>> sessionInfo = new ConcurrentHashMap<>();
    
    // Heartbeat 및 Idle 타임아웃 관련 필드
    private final ScheduledExecutorService executorService = Executors.newSingleThreadScheduledExecutor();
    private final Map<WebSocketSession, Long> lastMessageTime = new ConcurrentHashMap<>();
    private static final long HEARTBEAT_INTERVAL_MS = 30000; // 30초마다 heartbeat
    private static final long IDLE_TIMEOUT_MS = 6000000; // 600초 (10분) 동안 메시지 없으면 연결 종료
    
    // 메세지 큐 사용위한 큐
    private final BlockingQueue<TextMessage> messageQueue = new LinkedBlockingQueue<>();
    
    // 메세지 큐 처리 스레드 시작
    @PostConstruct
    public void init() {
        Thread messageSender = new Thread(this::processMessageQueue);
        messageSender.start();
    }
    
    // 메시지 전송
    private void sendMessageToAll(String message) {
        messageQueue.add(new TextMessage(message));
    }
    
    // 메시지 큐 처리
    private void processMessageQueue() {
        while (true) {
            try {
                TextMessage message = messageQueue.take(); // 큐에서 메시지 가져오기 (blocking)
                // sessions에 대한 반복 동기화
                // 세션을 복사하여 사용 (CopyOnWriteArrayList의 장점 활용)
                for (WebSocketSession session : sessions) {
                    if (session.isOpen()) {
                        // synchronized 블록을 메시지 전송에만 적용
                        synchronized (session) {
                            if (session.isOpen()) { // 다시 한번 확인
                                try {
                                    session.sendMessage(message); // 메시지 전송
                                } catch (IOException e) {
                                    System.err.println("메시지 전송 중 에러 발생: " + session.getId() + ", " + e.getMessage());
                                    // 여기서 세션을 제거하면 ConcurrentModificationException 발생 가능성이 있음
                                    // 별도의 로직으로 처리하거나, 로깅 후 무시
                                }
                            }
                        }
                    }
                }
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
                // 스레드가 interrupt 되면 종료
                break;
            }
        }
    }
    
    @PreDestroy // 빈 소멸 전 호출
    public void onDestroy() {
        executorService.shutdownNow(); // executorService  강제 종료
    }
    
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
        
        lastMessageTime.put(session, Instant.now().toEpochMilli());
        
        // 주기적으로 heartbeat 전송
        executorService.scheduleAtFixedRate(() -> {
            try {
                if (session.isOpen()) {
                    synchronized (session) { // 세션 동기화
                        if (session.isOpen()) { // 다시 한번 확인
                            session.sendMessage(new TextMessage("ping")); // ping 메세지 전송
                        }
                    }
                }
            } catch (IOException e) {
                System.err.println("Heartbeat 전송 중 오류 발생: " + e.getMessage());
            }
        }, 0, HEARTBEAT_INTERVAL_MS, TimeUnit.MILLISECONDS);
        
        // 주기적으로 연결 상태 확인 및 idle 타임아웃 체크
        // 10초마다 체크
        executorService.scheduleAtFixedRate(this::checkIdleSessions, 0, 10, TimeUnit.SECONDS);
        
        // 유저 리스트 전송
        sendUserList();
    }
    
    // 메세지 처리
    @Override
    protected void handleTextMessage(WebSocketSession session, TextMessage message) throws Exception {
        // 클라이언트로부터 "pong" 메시지가 오면 heartbeat 응답 간주
        if ("pong".equals(message.getPayload())) {
            return;
        }
        
        // lastMessageTime 업데이트, 동기화
        lastMessageTime.put(session, Instant.now().toEpochMilli());
        
        // getPayload(): 메시지 내용을 문자열로 반환
        Map<String, Object> messageMap = objectMapper.readValue(message.getPayload(), Map.class);
        
        // content 키의 값을 이스케이프 처리
        String content = utils.escapeHtml((String) messageMap.get("content"));
        messageMap.put("content", content);
        
        // 메시지 전송
        sendMessageToAll(objectMapper.writeValueAsString(messageMap));
    }
    
    // 웹소켓 연결이 닫힐 때 호출
    @Override
    public void afterConnectionClosed(WebSocketSession session, CloseStatus status) throws Exception {
        // 세션 정보 먼저 가져오기
        Map<String, String> userInfo;
        // 세션 정보 삭제
        userInfo = sessionInfo.remove(session);
        sessions.remove(session);
        lastMessageTime.remove(session); // 타임아웃 관련 정보도 같이 제거
        
        
        // 종료 메시지 생성, 전송 (NullPointerException 방지)
        if (userInfo != null) {
            Map<String, Object> message = createMessage("leave", userInfo);
            sendMessageToAll(objectMapper.writeValueAsString(message));
        }
        
        // 유저 리스트 전송
        sendUserList();
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

        userList.addAll(sessionInfo.values());
        
        // message map 생성하여 전송
        Map<String, Object> message = new HashMap<>();
        message.put("type", "userList");
        message.put("userList", userList);
        sendMessageToAll(objectMapper.writeValueAsString(message));
    }
    
    // idle 세션 체크
    private void checkIdleSessions() {
        long now = Instant.now().toEpochMilli();
        
        // sessions를 돌면서 idle 체크
        for (WebSocketSession session : sessions) {
            Long lastTime = lastMessageTime.get(session);
            
            if (lastTime == null) {
                continue;
            }
            if (now - lastTime > IDLE_TIMEOUT_MS) {
                try {
                    if (session.isOpen()) {
                        // 세션 동기화
                        synchronized (session) {
                            if (session.isOpen()) {
                                session.close(CloseStatus.SESSION_NOT_RELIABLE);
                            }
                        }
                        
                    }
                    
                } catch (IOException e) {
                    System.err.println("세션 종료 중 오류 발생: " + e.getMessage());
                }
            }
        }
    }
    
    // 여러 사용자에게 푸시 알림 보내기
    public void sendMulticastWebPush(@RequestBody Map<String, Object> messageMap) {
        try {
            List<String> tokens = fcmService.selectTokens();
            String nickname = (String) messageMap.get("nickname");
            String content = (String) messageMap.get("content");
            String profileImage = (String) messageMap.get("profileImage");
            
            // 푸시 알림 내용 설정
            String title = "502 : " + nickname;
            String body;
            if (content.length() > 20) {
                body = content.substring(0, 20) + "...";
            } else if (content.length() == 0) {
                body = "사진";
            } else {
                body = content;
            }
            String icon = profileImage;
            
            BatchResponse response = fcmService.sendMulticastWebPush(tokens, title, body, icon);
            
            // 성공/실패 결과 처리 (예시)
            String result = String.format("Successfully sent %d messages. Failed to send %d messages.",
                    response.getSuccessCount(), response.getFailureCount());
            System.out.println(result);
            
        } catch (FirebaseMessagingException e) {
            System.out.println("Error sending multicast web push: " + e.getMessage());
        } catch (ClassCastException e) { // 입력값 타입 오류
            System.out.println("Invalid input format." + e.getMessage());
        } catch(Exception e){
            System.out.println("UnExpected Error" + e.getMessage());
        }
    }
}
