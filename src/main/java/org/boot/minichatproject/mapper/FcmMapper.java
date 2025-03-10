package org.boot.minichatproject.mapper;

import org.apache.ibatis.annotations.Mapper;

import java.util.List;

@Mapper
public interface FcmMapper {
    // FCM 토큰 저장
    void insertToken(String token);
    
    // FCM 토큰 삭제
    void deleteToken(String token);
    
    // FCM 토큰 조회
    List<String> selectTokens();

}
