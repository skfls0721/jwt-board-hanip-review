source "$(dirname "$0")/lib.sh"
echo "실행 일시: $(date '+%Y-%m-%d %H:%M:%S')"
A=$(login_token alice); BOB=$(login_token bob)

req "T02 Alice 로그인" POST /auth/login "" '{"email":"alice@class.test","password":"Classroom!2026"}'
req "T02 Bob 로그인" POST /auth/login "" '{"email":"bob@class.test","password":"Classroom!2026"}'
req "T03 잘못된 비밀번호" POST /auth/login "" '{"email":"alice@class.test","password":"wrong-password"}'
req "T03 없는 이메일" POST /auth/login "" '{"email":"nobody@class.test","password":"Classroom!2026"}'
req "T04 토큰 없이 /me" GET /me
req "T04 토큰 없이 글 등록" POST /posts "" '{"title":"x","content":"y"}'
req "T05 Alice 글 등록" POST /posts "$A" '{"title":"증거용 글","content":"Alice가 쓴 글입니다."}'
P=$(latest_id)
req "T05 /me (Alice 토큰)" GET /me "$A"
req "T05 등록된 글의 authorId 확인" GET /posts/$P
req "T01 토큰 없이 목록 조회" GET /posts
req "T01 토큰 없이 상세 조회" GET /posts/$P
req "T06 Alice 본인 글 수정" PUT /posts/$P "$A" '{"title":"증거용 글(수정)","content":"Alice가 수정했습니다."}'
P2=$(new_post "$A" '{"title":"삭제용 글","content":"곧 삭제됩니다."}')
req "T06 Alice 본인 글 삭제(204)" DELETE /posts/$P2 "$A"
req "T06 삭제 후 조회(404)" GET /posts/$P2
req "T07 Bob이 Alice 글 수정" PUT /posts/$P "$BOB" '{"title":"Bob이 바꾼 제목","content":"Bob이 바꾼 내용"}'
req "T07 수정 시도 후 원문 확인" GET /posts/$P
req "T08 Bob이 Alice 글 삭제" DELETE /posts/$P "$BOB"
req "T08 삭제 시도 후 글 유지 확인" GET /posts/$P
echo "공통 시험 글 ID: $P (Alice 글, 다음 스크립트에서 계속 사용)"
