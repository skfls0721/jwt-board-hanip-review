# backend-spring (Spring Boot 백엔드)

한입 리뷰의 API 서버입니다. 전체 설치·실행 순서와 테스트 결과는 저장소 루트의 `README.md`를 따르세요.

## 실행

JDK 17 이상이 필요합니다(`java -version`으로 확인). 이 폴더에서 실행하며, 첫 실행에는 Maven 의존성을 받기 위해 인터넷이 필요합니다.

```sh
export JWT_SECRET=$(openssl rand -hex 32)
./mvnw spring-boot:run
```

- 주소: http://127.0.0.1:8000 , 확인: `curl http://127.0.0.1:8000/api/health` → `{"status":"ok"}`
- Spring은 `.env` 파일을 자동으로 읽지 않으므로 `env.example.txt`를 참고해 환경변수를 터미널에서 설정합니다.
- `JWT_SECRET`: 64자리 16진수. 값이 없거나 형식이 틀리거나 예시 키이면 서버가 시작되지 않습니다. 실제 키는 저장소에 넣지 않습니다.
- 선택 설정: `TOKEN_TTL`(기본 90초), `JWT_ISSUER`, `JWT_AUDIENCE`, `PORT`(기본 8000), `DB_FILE`(기본 `data/board.sqlite`)
- 실행 권한 오류가 나면 `chmod +x mvnw`를 한 번 실행합니다.

## 구성

| 파일 | 역할 |
|---|---|
| `AuthService.java` | JWT 발급, 토큰 검증, 작성자 권한 확인 |
| `BoardController.java` | API 라우트(제공 코드, 상태 확인 응답만 수정) |
| `PostStore.java` | SQLite 게시글 저장·조회(제공 코드) |
| `Users.java` | 테스트 계정과 비밀번호 검증(제공 코드) |
| `Errors.java`, `ApiError.java` | 공통 JSON 오류 응답과 401 헤더(제공 코드) |
| `DatabaseConfig.java`, `schema.sql` | DB 폴더·파일·테이블 자동 생성(제공 코드) |

## 데이터베이스

DB는 `data/board.sqlite`이며 폴더와 파일, `posts` 테이블은 서버를 처음 실행할 때 자동으로 만들어집니다. 초기화하려면 서버를 종료한 뒤 이 파일을 삭제하고 다시 실행합니다(기존 글이 모두 지워집니다). 이 파일은 저장소에 포함하지 않습니다.
