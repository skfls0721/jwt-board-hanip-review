source "$(dirname "$0")/lib2.sh"
export SECRET_FILE=/tmp/jwt_test_secret.txt
M="python3 $(dirname "$0")/mktoken.py"
PASS=0; FAIL=0

probe(){
  label="$1"; exp="$2"; method="$3"; path="$4"; auth="$5"; body="$6"
  args=(-s -o /tmp/probe_body -D /tmp/probe_head -w "%{http_code}" -X "$method" "$B$path")
  [ -n "$auth" ] && args+=(-H "Authorization: $auth")
  [ -n "$body" ] && args+=(-H 'Content-Type: application/json' -d "$body")
  st=$(curl "${args[@]}")
  code=$(python3 -c "import json;print(json.load(open('/tmp/probe_body')).get('code','-'))" 2>/dev/null || echo "-")
  www=$(grep -i '^www-authenticate' /tmp/probe_head | tr -d '\r' | cut -d: -f2- | xargs)
  if [ "$st $code" = "$exp" ] || { [ "$exp" = "200" ] && [ "$st" = "200" ]; }; then r=PASS; PASS=$((PASS+1)); else r=FAIL; FAIL=$((FAIL+1)); fi
  printf '%s %-46s %-4s 실제: HTTP %s code=%s WWW-Authenticate=%s | 기대: %s\n' "$r" "$label" "$method" "$st" "$code" "${www:--}" "$exp"
}
both(){
  probe "$1" "$2" GET /me "$3"
  probe "$1" "$2" PUT /posts/$P "$3" '{"title":"x","content":"y"}'
}

echo "실행 일시: $(date '+%Y-%m-%d %H:%M:%S')"
A=$(login_token alice)
P=$(new_post "$A" '{"title":"T09 추가 시험 글","content":"원문 유지 확인용"}')
N0=$(count)
echo "시험 글 ID: $P, 시험 전 글 개수: ${N0}"; echo

echo "--- 대조군: 시험용 키로 직접 만든 정상 토큰 ---"
probe "정상 토큰(직접 생성)" "200" GET /me "Bearer $($M valid)"
echo; echo "--- Authorization 헤더 형식 ---"
both "Basic 방식 헤더" "401 TOKEN_REQUIRED" "Basic dXNlcjpwYXNz"
both "Bearer만 있고 토큰 없음" "401 TOKEN_REQUIRED" "Bearer"
both "Bearer 뒤 토큰 2개" "401 TOKEN_REQUIRED" "Bearer abc def"
both "JWT 모양이 아닌 문자열" "401 INVALID_TOKEN" "Bearer not.a.jwt"
echo; echo "--- 알고리즘 ---"
both "HS512로 서명" "401 INVALID_TOKEN" "Bearer $($M alg_hs512)"
both "alg none(서명 없음)" "401 INVALID_TOKEN" "Bearer $($M alg_none)"
echo; echo "--- 클레임 (서명은 올바름) ---"
both "iss 불일치" "401 INVALID_TOKEN" "Bearer $($M iss_wrong)"
both "aud 불일치" "401 INVALID_TOKEN" "Bearer $($M aud_wrong)"
both "iss 누락" "401 INVALID_TOKEN" "Bearer $($M iss_missing)"
both "exp 누락" "401 INVALID_TOKEN" "Bearer $($M exp_missing)"
both "sub 누락" "401 INVALID_TOKEN" "Bearer $($M sub_missing)"
echo; echo "--- sub 값 ---"
both "sub=999 (없는 사용자)" "401 INVALID_TOKEN" "Bearer $($M sub_nouser)"
both "sub=abc (문자)" "401 INVALID_TOKEN" "Bearer $($M sub_text)"
both "sub=01 (앞에 0)" "401 INVALID_TOKEN" "Bearer $($M sub_leading_zero)"
both "sub=1 (문자열이 아닌 숫자)" "401 INVALID_TOKEN" "Bearer $($M sub_number)"

echo; echo "--- 시험 뒤 데이터 확인 ---"
req "원문 확인" GET /posts/$P
echo "시험 후 글 개수: $(count) (시험 전 ${N0}개와 같아야 함)"
echo "결과 합계: PASS ${PASS}, FAIL ${FAIL}"
