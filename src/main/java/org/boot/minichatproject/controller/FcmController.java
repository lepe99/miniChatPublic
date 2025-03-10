package org.boot.minichatproject.controller;

import lombok.RequiredArgsConstructor;
import org.boot.minichatproject.service.FcmService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
@RequestMapping("/fcm")
public class FcmController {
    
    private final FcmService fcmService;
    
    // 토큰 db 삽입
    @PostMapping("/saveToken")
    public ResponseEntity<String> saveToken(@RequestParam String token) {
        fcmService.insertToken(token);
        return new ResponseEntity<>("토큰 저장 성공", HttpStatus.OK);
    }
    
    // 토큰 db 삭제
    @PostMapping("/deleteToken")
    public ResponseEntity<String> deleteToken(@RequestParam String token) {
        fcmService.deleteToken(token);
        return new ResponseEntity<>("토큰 삭제 성공", HttpStatus.OK);
    }
    
}
