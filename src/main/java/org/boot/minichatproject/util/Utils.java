package org.boot.minichatproject.util;

import org.springframework.stereotype.Component;
import org.springframework.web.util.HtmlUtils;

@Component
public class Utils {
    
    public String escapeHtml(String message) {
        return HtmlUtils.htmlEscape(message); // HTML 태그를 이스케이프 처리
    }
    
}
