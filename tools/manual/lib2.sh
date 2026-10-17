source "$(dirname "$0")/lib.sh"
req(){
  label="$1"; method="$2"; path="$3"; tok="$4"; body="$5"
  if [ -n "$tok" ]; then who="${WHO:-<TOKEN>}"; else who="없음"; fi
  shown="${body:-없음}"
  if [ ${#shown} -gt 100 ]; then shown="${shown:0:100}...(본문 총 ${#body}자)"; fi
  echo "### $label"
  echo "요청: $method $path | 토큰: $who | 본문: $shown"
  set -- -s -i -X "$method" "$B$path"
  [ -n "$tok" ] && set -- "$@" -H "Authorization: Bearer $tok"
  [ -n "$body" ] && set -- "$@" -H 'Content-Type: application/json' -d "$body"
  curl "$@" | tr -d '\r' | grep -Ev '^(Date|Transfer-Encoding|Connection|Keep-Alive):' | mask
  echo; echo
}
count(){ curl -s $B/posts | python3 -c "import sys,json; print(len(json.load(sys.stdin)))"; }
tamper(){ python3 - "$1" <<'PY'
import sys
h,p,s=sys.argv[1].split('.')
s=('B' if s[0]=='A' else 'A')+s[1:]
print('.'.join([h,p,s]))
PY
}
