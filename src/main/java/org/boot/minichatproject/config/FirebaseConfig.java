package org.boot.minichatproject.config;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.io.ClassPathResource;

import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;

@Configuration
public class FirebaseConfig {
    
    @Bean
    public FirebaseApp firebaseApp() throws IOException {
        // ClassPathResource를 사용하여 클래스패스에서 리소스 로드
        ClassPathResource serviceAccount = new ClassPathResource("firebase/minichat-d6f16-firebase-adminsdk-fbsvc-3630a1908d.json");
        
        // InputStream으로 열기
        try (InputStream inputStream = serviceAccount.getInputStream()) {
            FirebaseOptions options = new FirebaseOptions.Builder()
                    .setCredentials(GoogleCredentials.fromStream(inputStream))
                    .build();
            
            return FirebaseApp.initializeApp(options);
        }
    }
}