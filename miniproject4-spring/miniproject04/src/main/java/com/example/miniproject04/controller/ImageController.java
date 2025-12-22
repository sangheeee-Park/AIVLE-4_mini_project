package com.example.miniproject04.controller;

import com.example.miniproject04.Entity.GeneratedImage;
import com.example.miniproject04.service.ImageService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.web.servlet.support.ServletUriComponentsBuilder;
import java.util.Map;
import java.net.InetAddress;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/v1/image")
@CrossOrigin(origins = "*")
public class ImageController {

    private final ImageService imageService;

    //private final String BASE_URL = "http://localhost:8080"; // ⭐ 이미지 절대경로 prefix
    // 서버 ip로 base url
   /* private String getBaseUrl(HttpServletRequest request) {
        return ServletUriComponentsBuilder.fromRequestUri(request)
                .replacePath(null)
                .replaceQuery(null)
                .build()
                .toUriString();
    }
    */

    private String getBaseUrl() {
        try {
            String ip = InetAddress.getLocalHost().getHostAddress();
            int port = 8080; // 서버 포트 (고정)

            return "http://" + ip + ":" + port;
        } catch (Exception e) {
            throw new RuntimeException("서버 IP 조회 실패", e);
        }
    }


    /** =======================================================
     * 1) 이미지 생성
     * ======================================================= */
    @PostMapping
    public ResponseEntity<?> createImage(@RequestBody Map<String, Object> req) {

        try {
            String tempUrl = (String) req.get("image_url");
            Long bookId = Long.valueOf(req.get("book_id").toString());

            // 상대 URL 받음 → "/images/파일명.png"
            String savedUrl = imageService.createImage(tempUrl, bookId);

            // ⭐ 절대 URL로 변환
            //String fullUrl = BASE_URL + savedUrl;
            //String fullUrl = getBaseUrl(request) + savedUrl;
            String fullUrl = getBaseUrl() + savedUrl;

            return ResponseEntity.ok(
                    Map.of(
                            "status", "success",
                            "image_url", fullUrl
                    )
            );

        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(404).body(
                    Map.of("status", "error", "message", e.getMessage())
            );
        }
    }

    /** =======================================================
     * 2) 이미지 조회
     * ======================================================= */
    @PostMapping("/check")
    public ResponseEntity<?> getImage(@RequestBody Map<String, Object> req) {

        try {
            Long bookId = Long.valueOf(req.get("book_id").toString());
            GeneratedImage img = imageService.getImage(bookId);

            // ⭐ 절대 URL 생성
            //String fullUrl = getBaseUrl(request) + img.getImageUrl();
            String fullUrl = getBaseUrl() + img.getImageUrl();

            return ResponseEntity.ok(
                    Map.of(
                            "power", "이용자",
                            "image_url", fullUrl
                    )
            );

        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(404).body(
                    Map.of("status", "error", "message", e.getMessage())
            );
        }
    }

    /** =======================================================
     * 3) 이미지 수정
     * ======================================================= */
    @PutMapping("/put")
    public ResponseEntity<?> updateImage(@RequestBody Map<String, Object> req) {

        try {
            Long bookId = Long.valueOf(req.get("book_id").toString());
            Long userId = Long.valueOf(req.get("user_id").toString());
            String tempUrl = (String) req.get("image_url");

            // 상대 URL 받음
            String updatedUrl = imageService.updateImage(bookId, tempUrl, userId);

            // ⭐ 절대 URL 변환
            //String fullUrl = getBaseUrl(request) + updatedUrl;
            String fullUrl = getBaseUrl() + updatedUrl;

            return ResponseEntity.ok(
                    Map.of(
                            "status", "success",
                            "image_url", fullUrl
                    )
            );

        } catch (IllegalArgumentException e) {

            if (e.getMessage().equals("권한 없음")) {
                return ResponseEntity.status(403).body(
                        Map.of("status", "error", "message", e.getMessage())
                );
            }

            return ResponseEntity.status(404).body(
                    Map.of("status", "error", "message", e.getMessage())
            );
        }
    }
}
