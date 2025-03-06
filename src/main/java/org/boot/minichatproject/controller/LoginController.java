package org.boot.minichatproject.controller;

import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import org.boot.minichatproject.dto.KakaoUserInfo;
import org.boot.minichatproject.service.LoginService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import java.util.HashMap;
import java.util.Map;

@Controller
@RequiredArgsConstructor
public class LoginController {
    
    private final LoginService loginService;
    
    // 엑세스 토큰 받아서 로그인 처리
    @PostMapping("/login/kakao")
    @ResponseBody
    public ResponseEntity<?> kakaoLogin(@RequestParam String accessToken, HttpSession session) {
        
        // 서비스에서 userInfo 획득
        KakaoUserInfo userInfo = loginService.getUserInfo(accessToken);
        
        // 예외 처리
        if (userInfo == null) {
            // 로그인 실패 응답
            Map<String, Object> response = new HashMap<>();
            response.put("success", false);
            response.put("message", "사용자 정보 로드 실패");
            // ResponseEntity: HTTP 응답을 포함하는 클래스
            // .status(HttpStatus.UNAUTHORIZED): HTTP 상태 코드 401 (인증 실패)
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(response);
        }
        
        // 세션에 사용자 정보 저장
        session.setAttribute("nickname", userInfo.getNickname());
        session.setAttribute("profileImage", userInfo.getProfileImage());
        session.setAttribute("isLogin", true);
        
        
        // 로그인 성공 응답
        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("message", "로그인 성공");
        return ResponseEntity.ok(response); // 200 OK
    }
    
    // 로그아웃 처리
    @GetMapping("/logout")
    public String logout(HttpSession session) {
        // 세션 초기화
        session.invalidate();
        return "redirect:/login"; // 메인 페이지로 리다이렉트
    }
    
    @GetMapping("/login")
    public String login(Model model) {
        model.addAttribute("kakaoJavascriptKey", loginService.getKakaoJavascriptKey());
        return "login";
    }
}
