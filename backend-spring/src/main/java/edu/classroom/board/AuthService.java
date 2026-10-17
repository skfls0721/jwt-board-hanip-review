
package edu.classroom.board;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.ExpiredJwtException;
import io.jsonwebtoken.JwtException;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import jakarta.servlet.http.HttpServletRequest;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.time.Instant;
import java.util.Date;
import java.util.HexFormat;
import java.util.Map;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import javax.crypto.SecretKey;

@Service
public class AuthService {

  private final Users users;
  private final SecretKey key;
  private final String issuer;
  private final String audience;
  private final long ttl;

  public AuthService(
          Users users,
          @Value("${app.jwt.secret}") String secret,
          @Value("${app.jwt.issuer}") String issuer,
          @Value("${app.jwt.audience}") String audience,
          @Value("${app.jwt.ttl}") long ttl) {

    this.users = users;
    this.issuer = issuer;
    this.audience = audience;
    this.ttl = ttl;

    if (secret == null
            || !secret.matches("[0-9a-fA-F]{64}")
            || secret.equalsIgnoreCase(
            "REPLACE_WITH_RANDOM_64_HEX_CHARACTERS")) {
      throw new IllegalStateException(
              "JWT_SECRET은 32바이트를 나타내는 64자리 16진수여야 합니다.");
    }

    if (issuer == null || issuer.isBlank()
            || audience == null || audience.isBlank()
            || ttl <= 0) {
      throw new IllegalStateException("JWT 설정을 확인하세요.");
    }

    byte[] secretBytes = HexFormat.of().parseHex(secret);
    this.key = Keys.hmacShaKeyFor(secretBytes);
  }

  // BE-01: HS256 JWT 발급
  public String issueToken(Users.PublicUser user) {
    Instant now = Instant.now();

    return Jwts.builder()
            .subject(Long.toString(user.id()))
            .issuer(issuer)
            .audience().add(audience).and()
            .issuedAt(Date.from(now))
            .expiration(Date.from(now.plusSeconds(ttl)))
            .signWith(key, Jwts.SIG.HS256)
            .compact();
  }

  // BE-02: Bearer 토큰 추출 및 검증
  public long currentUserId(HttpServletRequest request) {
    String header = request.getHeader("Authorization");

    if (header == null
            || !header.matches("(?i)^Bearer\\s+\\S+$")) {
      throw new ApiError(
              401, "TOKEN_REQUIRED", "유효한 Bearer 토큰이 필요합니다.");
    }

    String token = header.replaceFirst("(?i)^Bearer\\s+", "");

    try {
      var jws = Jwts.parser()
              .verifyWith(key)
              .build()
              .parseSignedClaims(token);

      if (!"HS256".equals(jws.getHeader().getAlgorithm())) {
        throw new ApiError(
                401, "INVALID_TOKEN", "지원하지 않는 JWT 알고리즘입니다.");
      }

      Claims claims = jws.getPayload();

      if (claims.getExpiration() == null
              || claims.getIssuer() == null
              || !issuer.equals(claims.getIssuer())
              || !validAudience(claims)
              || claims.getSubject() == null
              || !claims.getSubject().matches("[1-9][0-9]*")) {
        throw new ApiError(
                401, "INVALID_TOKEN", "JWT 클레임이 올바르지 않습니다.");
      }

      long userId;

      try {
        userId = Long.parseLong(claims.getSubject());
      } catch (NumberFormatException e) {
        throw new ApiError(
                401, "INVALID_TOKEN", "사용자 ID가 올바르지 않습니다.");
      }

      if (users.find(userId) == null) {
        throw new ApiError(
                401, "INVALID_TOKEN", "존재하지 않는 사용자입니다.");
      }

      return userId;

    } catch (ExpiredJwtException e) {
      throw new ApiError(
              401, "TOKEN_EXPIRED", "JWT가 만료되었습니다.");
    } catch (JwtException | IllegalArgumentException e) {
      throw new ApiError(
              401, "INVALID_TOKEN", "JWT 검증에 실패했습니다.");
    }
  }

  private boolean validAudience(Claims claims) {
    Object aud = claims.get("aud");

    if (aud instanceof String value) {
      return audience.equals(value);
    }

    if (aud instanceof Iterable<?> values) {
      for (Object value : values) {
        if (audience.equals(value)) {
          return true;
        }
      }
    }

    return false;
  }

  // BE-03: 게시글 작성자 권한 확인
  public void assertOwner(long userId, long authorId) {
    if (userId != authorId) {
      throw new ApiError(
              403, "FORBIDDEN", "게시글 작성자만 수정하거나 삭제할 수 있습니다.");
    }
  }
}
