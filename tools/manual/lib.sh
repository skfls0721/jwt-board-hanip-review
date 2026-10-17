B=http://127.0.0.1:8000/api
mask(){ sed -E 's/eyJ[A-Za-z0-9_.-]+/<TOKEN>/g'; }
login_token(){ curl -s -X POST $B/auth/login -H 'Content-Type: application/json' -d '{"email":"'$1'@class.test","password":"Classroom!2026"}' | python3 -c "import sys,json; print(json.load(sys.stdin)['accessToken'])"; }
latest_id(){ curl -s $B/posts | python3 -c "import sys,json; print(json.load(sys.stdin)[0]['id'])"; }
new_post(){ curl -s -X POST $B/posts -H "Authorization: Bearer $1" -H 'Content-Type: application/json' -d "$2" | python3 -c "import sys,json; print(json.load(sys.stdin)['id'])"; }
req(){
  label="$1"; method="$2"; path="$3"; tok="$4"; body="$5"
  if [ -n "$tok" ]; then who="<TOKEN>"; else who="없음"; fi
  echo "### $label"
  echo "요청: $method $path | 토큰: $who | 본문: ${body:-없음}"
  set -- -s -i -X "$method" "$B$path"
  [ -n "$tok" ] && set -- "$@" -H "Authorization: Bearer $tok"
  [ -n "$body" ] && set -- "$@" -H 'Content-Type: application/json' -d "$body"
  curl "$@" | tr -d '\r' | grep -Ev '^(Date|Transfer-Encoding|Connection|Keep-Alive):' | mask
  echo; echo
}
