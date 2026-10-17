# frontend-vue (Vue 프론트)

한입 리뷰의 화면입니다. 전체 설치·실행 순서와 테스트 결과는 저장소 루트의 `README.md`를 따르세요.

## 실행

Node.js 20.19 이상이 필요합니다. 먼저 백엔드를 http://127.0.0.1:8000 에서 실행한 뒤, 이 폴더에서 실행합니다.

```sh
npm ci
npm run build
npm run preview
```

브라우저에서 http://127.0.0.1:4173 에 접속합니다. 빌드한 `dist/`를 로컬 HTTP 서버로 제공하며, 파일을 직접 더블클릭해서 열지 않습니다. 코드를 수정했다면 `npm run build`를 다시 실행합니다.

개발 중에는 `npm run dev`(http://127.0.0.1:5173)를 사용할 수 있습니다. 4173번과 5173번은 한 번에 하나만 켭니다.

## API 연결

브라우저의 `/api` 요청은 Vite 프록시가 백엔드로 전달합니다. 백엔드 포트를 바꾸면 `vite.config.js`의 `server.proxy`와 `preview.proxy`를 함께 수정합니다.

## 구성

| 파일 | 역할 |
|---|---|
| `src/api.js` | 토큰 보관(메모리), `Authorization` 헤더, 상태 코드별 오류 안내, 로그인, 작성자 비교(`canEdit`) |
| `src/App.vue` | 화면(로그인, 글 목록·상세, 작성·수정·삭제), 오류·만료 안내 |
| `vite.config.js` | 개발·미리보기 서버 포트와 `/api` 프록시 |

토큰은 `localStorage`나 `sessionStorage`가 아니라 메모리에만 저장하므로, 새로고침하면 로그인 상태가 해제됩니다.
