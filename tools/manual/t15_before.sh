source "$(dirname "$0")/lib2.sh"
D="$(cd "$(dirname "$0")/../../docs/evidence" && pwd)"
echo "실행 일시: $(date '+%Y-%m-%d %H:%M:%S')"
A=$(login_token alice)
req "T15 재시작 전: Alice 글 등록" POST /posts "$A" '{"title":"T15 재시작 확인 글","content":"서버를 껐다 켜도 남아야 합니다."}'
curl -s $B/posts | python3 -m json.tool > $D/t15-posts-before.json
echo "재시작 전 글 개수: $(count)"
echo "재시작 전 서버 PID: $(lsof -ti tcp:8000 -sTCP:LISTEN)"
