package com.team.dtd.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "users")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor
@Builder
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long idx;

    @Column(nullable = false, unique = true, length = 50)
    private String userid;

    @Column(nullable = false, unique = true, length = 50)
    private String username;

    @Column(nullable = false)
    private String pwd;

    private LocalDate birth;

    @Column(columnDefinition = "INT DEFAULT 0")
    @Builder.Default
    private int gold = 0;

    @Column(columnDefinition = "INT DEFAULT 0")
    @Builder.Default
    private int diamond = 0;

    @Column(length = 500)
    private String refreshToken;

    @CreationTimestamp
    @Column(updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    private LocalDateTime lastLogin;

    // ⭐️ [추가된 메서드] 리프레시 토큰 업데이트 (로그인 시 호출됨)
    public void updateRefreshToken(String refreshToken) {
        this.refreshToken = refreshToken;
    }
}