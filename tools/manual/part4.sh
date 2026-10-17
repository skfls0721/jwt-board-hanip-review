source "$(dirname "$0")/lib2.sh"
D="$(cd "$(dirname "$0")/../../docs/evidence" && pwd)"
echo "실행 일시: $(date '+%Y-%m-%d %H:%M:%S')"

echo "===== T15 재시작 후 확인 ====="
echo "재시작 후 서버 PID: $(lsof -ti tcp:8000 -sTCP:LISTEN)"
T=$(latest_id)
curl -s $B/posts | python3 -m json.tool > $D/t15-posts-after.json
if diff -q $D/t15-posts-before.json $D/t15-posts-after.json >/dev/null; then echo "재시작 전후 글 목록(제목·작성자·내용·시각 포함) 동일: 일치"; else echo "차이 있음:"; diff $D/t15-posts-before.json $D/t15-posts-after.json; fi
echo "재시작 후 글 개수: $(count)"
req "T15 재시작 후 조회: 재시작 전에 쓴 글" GET /posts/$T
echo

echo "===== T10 토큰 만료 (TOKEN_TTL=3) ====="
req "T10 TTL 확인: 로그인 응답의 expiresIn" POST /auth/login "" '{"email":"alice@class.test","password":"Classroom!2026"}'
A=$(login_token alice); BOB=$(login_token bob)
P=$(new_post "$A" '{"title":"T10 만료 시험 글","content":"만료 토큰으로 바뀌면 안 됨"}')
echo "시험 글 ID: $P (Alice 소유)"
N0=$(count); echo "만료 시험 전 글 개수: ${N0}"
echo "토큰 발급 후 6초 대기"; echo; sleep 6
WHO="<TOKEN: 발급 6초 후, 만료됨>"
req "T10 만료 토큰 GET /me" GET /me "$A"
req "T10 만료 토큰 POST /posts" POST /posts "$A" '{"title":"만료 글","content":"생성되면 안 됨"}'
req "T10 만료 토큰 PUT /posts/$P" PUT /posts/$P "$A" '{"title":"만료로 수정","content":"수정되면 안 됨"}'
req "T10 만료 토큰 DELETE /posts/$P" DELETE /posts/$P "$A"
req "T10 Bob의 만료 토큰으로 Alice 글 수정" PUT /posts/$P "$BOB" '{"title":"x","content":"y"}'
unset WHO
req "T10 만료 요청 뒤 원문 확인" GET /posts/$P
echo "만료 시험 후 글 개수: $(count) (시험 전 ${N0}개와 같아야 함)"
