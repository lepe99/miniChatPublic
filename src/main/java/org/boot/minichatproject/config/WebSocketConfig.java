package org.boot.minichatproject.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.socket.config.annotation.EnableWebSocket;
import org.springframework.web.socket.config.annotation.WebSocketConfigurer;
import org.springframework.web.socket.config.annotation.WebSocketHandlerRegistry;
import org.springframework.web.socket.server.support.HttpSessionHandshakeInterceptor;

@Configuration
@EnableWebSocket // 웹소켓 활성화
public class WebSocketConfig implements WebSocketConfigurer {
    
    private final WebSocketHandler webSocketHandler;
    
    // 생성자 주입
    public WebSocketConfig(WebSocketHandler webSocketHandler) {
        this.webSocketHandler = webSocketHandler;
    }
    
    // 웹소켓 핸들러 등록
    @Override
    public void registerWebSocketHandlers(WebSocketHandlerRegistry registry) {
        // /chat 경로로 접속하면 WebSocketHandler가 동작, setAllowedOrigins("*")로 모든 도메인에서 접속 가능
        registry.addHandler(webSocketHandler, "/chat") // 웹소켓 핸들러 등록
                .setAllowedOrigins("*"); // 모든 도메인에서 접속 가능
    }
    
}
