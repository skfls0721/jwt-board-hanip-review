source "$(dirname "$0")/lib2.sh"
echo "실행 일시: $(date '+%Y-%m-%d %H:%M:%S')"
A=$(login_token alice); BOB=$(login_token bob)
P=$(new_post "$A" '{"title":"T14~T17 시험 글","content":"Alice 소유, 원문 유지 확인용"}')
echo "시험 글 ID: $P (Alice 소유)"; echo
NONE=999999

req "T14 없는 글 조회" GET /posts/$NONE
req "T14 없는 글 수정 (정상 토큰)" PUT /posts/$NONE "$A" '{"title":"x","content":"y"}'
req "T14 없는 글 삭제 (정상 토큰)" DELETE /posts/$NONE "$A"
req "T14 잘못된 ID 조회: abc" GET /posts/abc
req "T14 잘못된 ID 조회: 0" GET /posts/0
req "T14 잘못된 ID 조회: -1" GET /posts/-1
req "T14 잘못된 ID 조회: 1.5" GET /posts/1.5
req "T14 잘못된 ID 수정: abc (정상 토큰)" PUT /posts/abc "$A" '{"title":"x","content":"y"}'
req "T14 잘못된 ID 삭제: abc (정상 토큰)" DELETE /posts/abc "$A"

echo "===== 오류 조건이 겹칠 때 ====="; echo
req "겹침 1: 토큰 없이 없는 글 수정" PUT /posts/$NONE "" '{"title":"x","content":"y"}'
req "겹침 2: 정상 토큰으로 같은 없는 글 수정" PUT /posts/$NONE "$A" '{"title":"x","content":"y"}'
req "겹침 3: Bob이 Alice 글에 공백 제목" PUT /posts/$P "$BOB" '{"title":"   ","content":"y"}'
req "겹침 4: Alice가 자기 글에 공백 제목" PUT /posts/$P "$A" '{"title":"   ","content":"y"}'
req "겹침 5: 공백 제목 시도 뒤 원문 확인" GET /posts/$P

echo "===== T17 ====="; echo
req "T17 토큰 없이 수정" PUT /posts/$P "" '{"title":"x","content":"y"}'
req "T17 토큰 없이 삭제" DELETE /posts/$P
req "T17 무토큰 시도 뒤 원문 확인" GET /posts/$P
req "T17 Bob 글 등록" POST /posts "$BOB" '{"title":"Bob의 글","content":"Bob이 작성"}'
BP=$(latest_id)
req "T17 Bob 본인 글 수정" PUT /posts/$BP "$BOB" '{"title":"Bob의 글(수정)","content":"Bob이 수정"}'
req "T17 Bob 본인 글 삭제" DELETE /posts/$BP "$BOB"
req "T17 Bob 글 삭제 후 조회" GET /posts/$BP
req "T17 Alice 글은 그대로" GET /posts/$P
