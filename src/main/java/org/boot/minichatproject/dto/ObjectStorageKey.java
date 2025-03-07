package org.boot.minichatproject.dto;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Configuration;

@Configuration
@ConfigurationProperties(prefix = "ncp")
@Data
public class ObjectStorageKey {
    private String accessKey;
    private String secretKey;
    private String regionName;
    private String endPoint;
}
