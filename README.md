# 한입 리뷰 (맛집 후기 게시판)

웹서비스설계 JWT 게시판 과제입니다. (Vue + Spring Boot)

## 작성자와 서비스 소개

- 학번 / 이름: 202323035 / 홍나린
- 서비스 목적과 대상 사용자: 한입 리뷰는 먹어 본 식당과 메뉴에 대한 후기를 나누는 게시판입니다. 누구나 후기를 읽을 수 있고, 로그인한 사용자만 후기를 작성할 수 있습니다. 수정과 삭제는 작성자 본인만 할 수 있습니다. 맛집 정보를 찾는 사람과 자신의 경험을 기록하려는 사람을 대상으로 합니다.
- 선택한 기술: Vue + Spring Boot
- 주요 기능: 게시글 목록·상세 조회(비로그인 가능), 로그인(JWT 발급), 내 정보 조회, 게시글 등록, 작성자 본인의 수정·삭제, 토큰 만료와 로그아웃 안내

## 보고서와 테스트 증거

- [구현 보고서 PDF](docs/report.pdf)
- [테스트 증거](docs/evidence/) (API 시험 출력, 화면 캡처, 토큰 내용 확인, 빌드 기록)

## 프로젝트 구조

```text
.
├── README.md
├── .gitignore
├── frontend-vue/      # Vue 프론트 소스, package.json, package-lock.json
├── backend-spring/    # Spring Boot 백엔드 소스, pom.xml, Maven Wrapper
├── tools/
│   ├── check_api.py   # 자동 API 검사 도구(제공 파일)
│   └── manual/        # 증거를 남기는 시험 스크립트(curl)
└── docs/
    ├── report.pdf
    └── evidence/
```

## 실행 환경

| 항목 | 사용 버전 |
|---|---|
| 운영체제 | macOS 15.7.9 |
| 프론트 런타임 Node.js | v24.20.0, npm 11.19.0 (프로젝트 요구: Node.js 20.19 이상) |
| 백엔드 런타임 | OpenJDK 17.0.20.1 (프로젝트 설정: Java 17) |
| 프레임워크 | Vue 3.5.43, Vite 8.3.4, Spring Boot 3.5.16, JJWT 0.13.0 |
| 데이터 저장 | SQLite (sqlite-jdbc 3.51.3.0) |
| 시험에 사용한 브라우저 | Safari 26.6.1 |

## 설치와 실행

### 1 저장소 복제

```sh
git clone https://github.com/skfls0721/jwt-board-hanip-review.git
cd jwt-board-hanip-review
```

### 2 백엔드 준비와 실행

Spring은 `.env` 파일을 자동으로 읽지 않으므로 환경변수를 터미널에서 직접 설정합니다.

```sh
cd backend-spring
export JWT_SECRET=$(openssl rand -hex 32)
./mvnw spring-boot:run
```

- 환경설정 예시 파일: `backend-spring/env.example.txt`
- JWT_SECRET: 64자리 16진수 문자열입니다. 위 명령으로 새 키를 만들어 서버를 실행하는 터미널에 설정합니다. 값이 없거나 형식이 틀리거나 예시 키 그대로이면 서버가 시작되지 않습니다. 실제 키는 저장소에 넣지 않습니다.
- TOKEN_TTL: 기본값 90초입니다. 만료 시험은 `export TOKEN_TTL=3`을 설정한 뒤 서버를 다시 시작합니다.
- 백엔드 주소: http://127.0.0.1:8000
- 정상 실행 확인: `curl http://127.0.0.1:8000/api/health` 응답이 `{"status":"ok"}`입니다.
- 최초 실행에는 Maven 의존성을 받기 위해 인터넷이 필요합니다.
- 종료: 서버를 실행한 터미널에서 Ctrl+C
- Windows: `.\mvnw.cmd spring-boot:run`을 사용하고, PowerShell에서 `$env:JWT_SECRET`에 64자리 16진수를 직접 지정합니다. (Windows에서는 시험하지 않았습니다.)

### 3 프론트 빌드와 로컬 실행

백엔드를 켜 두고 새 터미널에서 실행합니다.

```sh
cd frontend-vue
npm ci
npm run build
npm run preview
```

- 최종 확인 주소: http://127.0.0.1:4173
- 개발 중 실행: `npm run dev`, http://127.0.0.1:5173
- API 연결: 브라우저가 `/api`로 요청하면 Vite 프록시가 http://127.0.0.1:8000 백엔드로 전달합니다. 백엔드 포트를 바꾸면 `frontend-vue/vite.config.js`의 프록시 주소도 함께 바꿉니다.
- 종료: 프론트와 백엔드를 실행한 각 터미널에서 Ctrl+C
- 코드 변경 후: 프론트는 `npm run build`를 다시 실행하고, 백엔드는 다시 시작합니다.

### 4 테스트 계정과 DB

| 사용자 | 이메일 | 실습용 비밀번호 |
|---|---|---|
| Alice | alice@class.test | Classroom!2026 |
| Bob | bob@class.test | Classroom!2026 |

- SQLite 파일: `backend-spring/data/board.sqlite`. 파일과 `data` 폴더가 없으면 서버 시작 시 자동으로 만들어집니다.
- DB 초기화: 서버를 종료한 뒤 `backend-spring/data/board.sqlite`를 삭제하고 다시 시작합니다.
- 서버 재시작 후 데이터 유지: 글을 작성한 뒤 서버 프로세스를 종료하고 다시 실행했을 때 글 목록 전체가 그대로임을 확인했습니다.

위 계정은 과제 전용 테스트 계정입니다.

## 구현 완료 범위

| 기능 | 완료 여부 | 주요 파일 또는 함수 |
|---|---|---|
| 공개 목록과 상세 | 완료 | `BoardController.list/get`, `PostStore`, 프론트 `App.vue` (제공 코드 유지) |
| 로그인과 JWT 발급 | 완료 | `BoardController.login`, `Users.verify`(제공 코드), `AuthService.issueToken`, 프론트 `api.js login` |
| JWT 검증과 내 정보 조회 | 완료 | `AuthService.currentUserId`, `BoardController.me` |
| 글 작성과 작성자 저장 | 완료 | `BoardController.create` (제공 코드), 작성자는 `currentUserId`로 서버가 결정 |
| 본인 글 수정·삭제 | 완료 | `AuthService.assertOwner`, `BoardController.update/delete`(제공 코드), 프론트 `api.js canEdit` |
| 토큰 만료와 로그아웃 | 완료 | `Errors.api`(401 헤더, 제공 코드), `api.js request/clearSession`, `App.vue logout` |
| 입력 오류와 권한 오류 처리 | 완료 | `BoardController.fields/postId`, `Errors` (제공 코드) |

### 알려진 문제와 미완성 기능

- 로그인할 때 입력 폼이 초기화되지 않아, 사용자를 바꿔 로그인하면 이전 사용자가 열어 둔 수정 폼이 남습니다. 그 폼으로 저장해도 서버가 403으로 거부해 데이터에는 영향이 없습니다.
- 프론트 서버는 켜져 있고 백엔드만 꺼진 경우, 화면에 "요청 처리에 실패했습니다. (HTTP 502)"처럼 일반적인 안내가 표시됩니다.
- 명세에 없는 경로(미등록 경로 등)의 응답은 Spring 기본 응답 그대로입니다. 지정한 API 경로는 모두 공통 JSON 형식을 따릅니다.
- 로그아웃은 이 탭의 토큰을 지울 뿐, 이미 복사된 토큰을 서버에서 무효화하지 않습니다.

## 테스트 방법과 결과 요약

시험은 2026-10-16~17에 직접 실행했습니다.

- 자동 검사: 백엔드를 켠 뒤 저장소 루트에서 `python3 tools/check_api.py --mode final`을 실행했고 40개 항목이 통과했습니다. `--expiry` 자동 만료 검사는 실행하지 않았고 만료는 수동으로 확인했습니다.
- T01~T17: 모두 직접 실행해 PASS를 확인했습니다. 결과표는 보고서 4절, 원본 출력은 `docs/evidence/api-manual-part1~5.txt`입니다.
- Alice/Bob 권한 구분: Bob의 토큰으로 Alice 글을 수정·삭제하면 403 FORBIDDEN이고 글이 그대로임을 확인했습니다.
- 토큰 없음·변조·만료: 각각 401 TOKEN_REQUIRED, INVALID_TOKEN, TOKEN_EXPIRED이고 모두 `WWW-Authenticate: Bearer` 헤더가 있음을 확인했습니다(만료는 `TOKEN_TTL=3`으로 재시작해 확인).
- JWT 조작 시험: 본인의 로컬 시험용 키로 서명한 토큰의 알고리즘, iss, aud, exp, sub를 바꿔 `GET /api/me`와 `PUT /api/posts/{id}`로 시험했고 모두 401로 거부됐습니다(`docs/evidence/api-manual-part5.txt`).
- JWT_SECRET 거부 시험: 키를 설정하지 않은 경우(예시 키가 기본값), 예시 키 그대로, 빈 값, 16진수 63자리의 네 경우 모두 서버가 시작되지 않고 오류 메시지가 출력됨을 확인했습니다(`docs/evidence/api-key-rejection.txt`).
- 화면 시험: 로그인 표시, 글 작성(201), 타인 글의 버튼 숨김, 만료·로그아웃·새로고침, 400·403·404 안내, 서버가 꺼진 경우의 안내를 Safari 개발자 도구와 함께 확인했습니다(`docs/evidence/*.png`).
- 시험 스크립트(`tools/manual/*.sh`, 저장소 루트에서 `bash`로 실행, macOS에서 시험, curl·python3·lsof 필요):
  - `part1.sh`~`part3.sh`: 백엔드를 기본 설정으로 실행한 상태에서 실행
  - `t15_before.sh`를 실행한 뒤 서버를 `TOKEN_TTL=3`으로 재시작하고 `part4.sh`를 실행(재시작 후 데이터 유지와 만료 확인)
  - `part5.sh`: `openssl rand -hex 32 > /tmp/jwt_test_secret.txt`로 시험용 키를 만들고 `export JWT_SECRET=$(cat /tmp/jwt_test_secret.txt)`로 서버를 실행한 상태에서 실행, 시험 뒤 키 파일 삭제

## 핵심 구현 설명

로그인하면 `AuthService.issueToken`이 HS256 JWT를 발급하고, 프론트(`api.js`)는 토큰을 메모리에만 보관해 요청마다 `Authorization: Bearer` 헤더로 보냅니다. 서버는 `AuthService.currentUserId`에서 서명·만료·발급자·대상·sub를 검증하고 실제 계정이 있는지 확인한 뒤 검증된 사용자 ID만 처리에 넘깁니다. 수정·삭제 때는 `assertOwner`가 글의 작성자 ID와 현재 사용자 ID를 비교합니다. 상세 설명은 보고서 3절에 있습니다.

## AI 활용 요약과 참고 자료

- AI 사용 여부: 사용
- 도구와 사용 범위:
  - Codex(OpenAI): `AuthService.java`의 생성자(키·설정 검증)와 `validAudience`, `vite.config.js`는 제안 후 반영, `api.js`의 `getErrorMessage`와 `canEdit`은 초안 후 직접 수정했습니다.
  - Claude(Anthropic): 과제 조건 대조 점검, `api.js` `request`의 연결 실패·JSON 파싱 실패 처리와 `App.vue`의 404 처리·로그아웃 폼 초기화·비로그인 안내 제안 반영, 시험 스크립트(`tools/manual`) 작성, 백엔드·프론트 폴더 README 재작성, 루트 README와 보고서 초안 작성
- 직접 검증한 내용: 반영 후 직접 빌드하고 서버를 실행해 curl과 화면으로 확인했습니다. 401·403·404 응답, 토큰 변조·만료, 삭제 204, 서버 재시작 후 데이터 유지, 로그아웃과 새로고침, 400 안내, `JWT_SECRET` 거부를 확인했습니다.
- 수업 자료 참고: 6·7주차 강의 자료(서버 키 설정, `AuthService` 생성자), 6주차 28쪽(토큰 발급), 6주차 35~40쪽·7주차 50·53쪽(토큰 검증), 7주차 65쪽(작성자 비교), 6주차 31·32·47쪽(프론트 토큰 보관·헤더·401 처리)
- 상세 활용 기록: 보고서 5절 (`docs/report.pdf`)
- 참고한 자료: 수업 6주차(JWT 로그인), 7주차(JWT 접근 제어와 Swagger) 강의 자료, 과제 제공 템플릿과 `docs/02_API명세.md`
