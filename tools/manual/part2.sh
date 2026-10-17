source "$(dirname "$0")/lib2.sh"
echo "실행 일시: $(date '+%Y-%m-%d %H:%M:%S')"
A=$(login_token alice); BOB=$(login_token bob)
P=$(new_post "$A" '{"title":"T09~T13 시험 글","content":"원문 유지 확인용 본문"}')
echo "시험 글 ID: $P (Alice 소유)"; echo
N0=$(count); echo "시험 전 글 개수: $N0"; echo

BAD=$(tamper "$A")
WHO="<TOKEN: 서명 첫 글자 변조>"
req "T09 변조 토큰 GET /me" GET /me "$BAD"
req "T09 변조 토큰 POST /posts" POST /posts "$BAD" '{"title":"변조 글","content":"생성되면 안 됨"}'
req "T09 변조 토큰 PUT /posts/$P" PUT /posts/$P "$BAD" '{"title":"변조로 수정","content":"수정되면 안 됨"}'
req "T09 변조 토큰 DELETE /posts/$P" DELETE /posts/$P "$BAD"
unset WHO
req "T09 변조 요청 뒤 원문 확인" GET /posts/$P
echo "T09 후 글 개수: $(count) (시험 전 ${N0}개와 같아야 함)"; echo

N1=$(count)
req "T12 Bob 등록 + authorId:1" POST /posts "$BOB" '{"title":"위조 시도","content":"작성자 위조","authorId":1}'
req "T12 Bob 등록 + userId:1" POST /posts "$BOB" '{"title":"위조 시도","content":"작성자 위조","userId":1}'
req "T12 Bob 등록 + id:1" POST /posts "$BOB" '{"title":"위조 시도","content":"작성자 위조","id":1}'
req "T12 Alice 본인 글 수정 + authorId:2" PUT /posts/$P "$A" '{"title":"x","content":"y","authorId":2}'
req "T12 위조 시도 뒤 원문 확인" GET /posts/$P
echo "T12 후 글 개수: $(count) (시도 전 ${N1}개와 같아야 함)"; echo

N2=$(count)
T101=$(python3 -c "print('a'*101)"); C5001=$(python3 -c "print('a'*5001)")
req "T13 등록: 빈 제목" POST /posts "$A" '{"title":"","content":"y"}'
req "T13 등록: 공백 본문" POST /posts "$A" '{"title":"x","content":"   "}'
req "T13 등록: 제목 101자" POST /posts "$A" "{\"title\":\"$T101\",\"content\":\"y\"}"
req "T13 등록: 내용 5001자" POST /posts "$A" "{\"title\":\"x\",\"content\":\"$C5001\"}"
echo "T13 등록 시도 후 글 개수: $(count) (시도 전 ${N2}개와 같아야 함)"; echo
req "T13 수정: 빈 제목" PUT /posts/$P "$A" '{"title":"","content":"y"}'
req "T13 수정: 공백 본문" PUT /posts/$P "$A" '{"title":"x","content":"   "}'
req "T13 수정: 제목 101자" PUT /posts/$P "$A" "{\"title\":\"$T101\",\"content\":\"y\"}"
req "T13 수정: 내용 5001자" PUT /posts/$P "$A" "{\"title\":\"x\",\"content\":\"$C5001\"}"
req "T13 수정 실패 뒤 원문 확인" GET /posts/$P
