package org.boot.minichatproject.service;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import lombok.Getter;
import lombok.RequiredArgsConstructor;
import org.boot.minichatproject.dto.KakaoUserInfo;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

@Service
@RequiredArgsConstructor
public class LoginService {
    
    @Getter
    @Value("${kakao.restapi.key}")
    private String kakaoRestApiKey;
    
    @Getter
    @Value("${kakao.javascript.key}")
    private String kakaoJavascriptKey;
    
    
    private final RestTemplate restTemplate = new RestTemplate();
    private final Gson gson;
    
    public KakaoUserInfo getUserInfo(String accessToken) {
        // Kakao API 호출 위해 헤더 설정
        HttpHeaders headers = new HttpHeaders(); // 헤더 객체 생성
        
        // Authorization 헤더에 Bearer token 설정
        // Bearer token: 서버에 접근할 때 토큰을 함께 보내는 방식
        headers.set("Authorization", "Bearer " + accessToken);
        // Content-type: 요청에 포함된 데이터의 타입을 알려주는 헤더
        headers.set("Content-type", "application/x-www-form-urlencoded;charset=utf-8");
        
        // HttpEntity 객체 생성 (HTTP 요청 또는 응답을 나타내는 인터페이스)
        HttpEntity<String> requestEntity = new HttpEntity<>(headers);
        
        // Kakao API 호출
        ResponseEntity<String> response; // 응답 객체 생성
        try {
            response = restTemplate.exchange(
                    "https://kapi.kakao.com/v2/user/me", // 요청 URL
                    HttpMethod.GET, // 요청 방식
                    requestEntity, // 요청 헤더
                    String.class // 응답 데이터 타입
            );
        } catch (Exception e) {
            System.err.println("Kakao API 호출 오류: " + e.getMessage());
            return null;
        }
        
        // 응답 데이터를 KakaoUserInfo 객체로 변환
        if (response.getStatusCode() == HttpStatus.OK) {
            // json 응답을 파싱
            JsonObject jsonObject =  JsonParser.parseString(response.getBody()).getAsJsonObject();
            JsonObject properties = jsonObject.getAsJsonObject("properties");
            
            // 파싱한 값으로 객체 반환
            String nickname = properties.get("nickname").getAsString();
            // 썸네일 이미지 URL로 설정 (thumbnail_image) , 부하 감소 위해
            String profileImage = properties.get("thumbnail_image").getAsString();
            return new KakaoUserInfo(nickname, profileImage);
        } else {
            System.err.println("Kakao API 응답 오류: " + response.getStatusCode());
            return null;
        }
    }
    
}
