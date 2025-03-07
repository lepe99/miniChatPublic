package org.boot.minichatproject.config;

import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.socket.config.annotation.EnableWebSocket;
import org.springframework.web.socket.config.annotation.WebSocketConfigurer;
import org.springframework.web.socket.config.annotation.WebSocketHandlerRegistry;
import org.springframework.web.socket.server.support.HttpSessionHandshakeInterceptor;

import java.util.Collections;
import java.util.Set;

@Configuration
@EnableWebSocket // 웹소켓 활성화
@RequiredArgsConstructor
public class WebSocketConfig implements WebSocketConfigurer {
    
    private final WebSocketHandler webSocketHandler;
    
    // 웹소켓 핸들러 등록
    @Override
    public void registerWebSocketHandlers(WebSocketHandlerRegistry registry) {
        // /chat 경로로 접속하면 WebSocketHandler가 동작, setAllowedOrigins("*")로 모든 도메인에서 접속 가능
        registry.addHandler(webSocketHandler, "/chat") // 웹소켓 핸들러 등록
                .setAllowedOrigins("*"); // 모든 도메인에서 접속 가능
    }
    
}
