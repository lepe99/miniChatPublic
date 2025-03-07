package org.boot.minichatproject.mapper;

import org.springframework.web.multipart.MultipartFile;

public interface NcpObjectStorageMapper {
    String uploadFile(String bucketName, String directoryPath, MultipartFile file);
    void deleteFile(String bucketName,String directoryPath,String fileName);
}
