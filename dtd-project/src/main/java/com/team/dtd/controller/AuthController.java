package com.team.dtd.controller;

import com.team.dtd.dto.LoginRequestDto;
import com.team.dtd.dto.RegisterRequestDto;
import com.team.dtd.entity.User;
import com.team.dtd.jwt.TokenProvider;
import com.team.dtd.service.AuthService;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Optional;

@Slf4j
@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;
    private final TokenProvider tokenProvider;

    @PostMapping("/register")
    public ResponseEntity<String> register(@Valid @RequestBody RegisterRequestDto request) {
        authService.register(request);
        return ResponseEntity.ok("회원가입 성공");
    }

    @PostMapping("/login")
    public ResponseEntity<String> login(@Valid @RequestBody LoginRequestDto request, HttpServletResponse response) {
        User user = authService.authenticate(request);

        String accessToken = tokenProvider.createAccessToken(user.getUserid());
        String refreshToken = tokenProvider.createRefreshToken(user.getUserid());

        authService.updateRefreshToken(user.getIdx(), refreshToken);

        long accessAge = tokenProvider.getAccessTokenValidityInSeconds();
        long refreshAge = tokenProvider.getRefreshTokenValidityInSeconds();

        addCookie(response, "accessToken", accessToken, accessAge);
        addCookie(response, "refreshToken", refreshToken, refreshAge);

        return ResponseEntity.ok("로그인 성공");
    }

    @PostMapping("/reissue")
    public ResponseEntity<?> reissueAccessToken(
            @CookieValue(name = "refreshToken", required = false) String refreshToken,
            HttpServletResponse response) {

        if (refreshToken == null) {
            return new ResponseEntity<>("Refresh Token이 없습니다.", HttpStatus.UNAUTHORIZED);
        }

        if (!tokenProvider.validateToken(refreshToken)) {
            return new ResponseEntity<>("만료되거나 잘못된 Refresh Token입니다.", HttpStatus.UNAUTHORIZED);
        }

        Optional<User> userOptional = authService.findByRefreshToken(refreshToken);
        if (userOptional.isEmpty()) {
            return new ResponseEntity<>("DB에 없는 토큰입니다. 다시 로그인해주세요.", HttpStatus.UNAUTHORIZED);
        }

        User user = userOptional.get();

        String newAccessToken = tokenProvider.createAccessToken(user.getUserid());
        String newRefreshToken = tokenProvider.createRefreshToken(user.getUserid());

        authService.updateRefreshToken(user.getIdx(), newRefreshToken);

        long accessAge = tokenProvider.getAccessTokenValidityInSeconds();
        long refreshAge = tokenProvider.getRefreshTokenValidityInSeconds();

        addCookie(response, "accessToken", newAccessToken, accessAge);
        addCookie(response, "refreshToken", newRefreshToken, refreshAge);

        return ResponseEntity.ok("토큰 재발급 성공");
    }

    @PostMapping("/logout")
    public ResponseEntity<String> logout(
            @CookieValue(name = "refreshToken", required = false) String refreshToken,
            HttpServletResponse response) {

        if (refreshToken != null) {
            authService.deleteRefreshToken(refreshToken);
        }

        addCookie(response, "accessToken", "", 0);
        addCookie(response, "refreshToken", "", 0);

        return ResponseEntity.ok("로그아웃 성공");
    }

    private void addCookie(HttpServletResponse response, String name, String value, long maxAge) {
        String cookieHeader = String.format("%s=%s; Max-Age=%d; Path=/; HttpOnly; SameSite=Lax",
                name, value, maxAge);
        response.addHeader("Set-Cookie", cookieHeader);
    }
}