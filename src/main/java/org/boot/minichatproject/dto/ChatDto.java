package org.boot.minichatproject.dto;

import lombok.Data;
import org.apache.ibatis.type.Alias;

import java.sql.Timestamp;

@Data
@Alias("ChatDto")
public class ChatDto {
    private int idx;
    private String nickname;
    private String message;
    private String profileImage;
    private Timestamp createdAt;
}
