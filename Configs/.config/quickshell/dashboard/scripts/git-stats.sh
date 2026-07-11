#!/usr/bin/env bash
CACHE="$HOME/.config/quickshell/dashboard/cache/git-stats.json"
LOCK="$HOME/.config/quickshell/dashboard/cache/.git-stats.lock"
REPOS_CACHE="$HOME/.config/quickshell/dashboard/cache/repos.txt"

if [ -f "$CACHE" ] && [ "$(find "$CACHE" -mmin -5 2>/dev/null)" ]; then
  cat "$CACHE"
  exit 0
fi

[ -f "$LOCK" ] && { cat "$CACHE" 2>/dev/null || echo '{"error":"locked"}'; exit 0; }
touch "$LOCK"

if [ ! -f "$REPOS_CACHE" ] || [ ! "$(find "$REPOS_CACHE" -mmin -60 2>/dev/null)" ]; then
  find "$HOME" -name ".git" -maxdepth 4 -type d 2>/dev/null | sed 's|/\.git$||' > "$REPOS_CACHE"
fi

repos=()
while IFS= read -r r; do [ -n "$r" ] && repos+=("$r"); done < "$REPOS_CACHE"
rc=${#repos[@]}

TODAY=$(date +%Y-%m-%d)
WEEK=$(date -d '7 days ago' +%Y-%m-%d)
MONTH=$(date -d '30 days ago' +%Y-%m-%d)
YEAR=$(date -d '365 days ago' +%Y-%m-%d)

total=0; ctoday=0; cweek=0; cmonth=0; cyear=0

for repo in "${repos[@]}"; do
  t=$(git -C "$repo" rev-list --count HEAD 2>/dev/null || echo 0)
  total=$((total + t))
  d=$(git -C "$repo" rev-list --count HEAD --after="$TODAY" 2>/dev/null || echo 0)
  ctoday=$((ctoday + d))
  w=$(git -C "$repo" rev-list --count HEAD --after="$WEEK" 2>/dev/null || echo 0)
  cweek=$((cweek + w))
  m=$(git -C "$repo" rev-list --count HEAD --after="$MONTH" 2>/dev/null || echo 0)
  cmonth=$((cmonth + m))
  y=$(git -C "$repo" rev-list --count HEAD --after="$YEAR" 2>/dev/null || echo 0)
  cyear=$((cyear + y))
done

ext_to_lang=(
  "js:JavaScript" "ts:TypeScript" "tsx:TypeScript" "jsx:JavaScript"
  "py:Python" "rs:Rust" "go:Go" "java:Java" "kt:Kotlin" "sc:Scala"
  "c:C" "h:C" "cpp:C++" "hpp:C++" "cc:C++" "cxx:C++"
  "cs:C#" "rb:Ruby" "php:PHP" "swift:Swift" "r:R"
  "lua:Lua" "sh:Shell" "bash:Shell" "zsh:Shell" "fish:Shell"
  "pl:Perl" "hs:Haskell" "elm:Elm" "clj:Clojure"
  "dart:Dart" "ex:Elixir" "erl:Erlang"
  "vue:Vue" "svelte:Svelte" "qml:QML"
  "css:CSS" "scss:SCSS" "less:Less" "html:HTML"
  "sql:SQL" "yaml:YAML" "yml:YAML" "json:JSON" "toml:TOML"
  "md:Markdown" "tex:LaTeX"
  "cmake:CMake" "mk:Makefile" "Makefile:Makefile"
  "dockerfile:Dockerfile" "Dockerfile:Dockerfile"
)

declare -A lang_names
for m in "${ext_to_lang[@]}"; do
  ext="${m%%:*}"
  name="${m##*:}"
  lang_names["$ext"]="$name"
done

declare -A lang_agg
for repo in "${repos[@]}"; do
  while IFS= read -r f; do
    ext="${f##*.}"; [[ -z "$ext" || "$ext" == "$f" || "$ext" == */* ]] && continue
    name="${lang_names[$ext]}"
    [ -n "$name" ] && lang_agg["$name"]=$((lang_agg["$name"] + 1))
  done < <(find "$repo" -type f -not -path '*/.git/*' -not -path '*/node_modules/*' 2>/dev/null)
done

total_files=0
for count in "${lang_agg[@]}"; do total_files=$((total_files + count)); done

lang_json=""
for name in "${!lang_agg[@]}"; do
  count=${lang_agg[$name]}
  [ "$total_files" -eq 0 ] && pct=0 || pct=$((count * 100 / total_files))
  [ -n "$lang_json" ] && lang_json+=","
  lang_json+="\"$name\":$count"
done

declare -A day_commits
for repo in "${repos[@]}"; do
  while IFS=$'\t' read -r date_str; do
    [ -z "$date_str" ] && continue
    day="${date_str%% *}"
    day_commits["$day"]=$((day_commits["$day"] + 1))
  done < <(git -C "$repo" log --all --format="%ai" --after="$YEAR" 2>/dev/null)
done

streak=0; longest=0; cur=0; max_day=0; max_date=""
for d in "${!day_commits[@]}"; do
  c=${day_commits[$d]}
  [ "$c" -gt "$max_day" ] && { max_day=$c; max_date=$d; }
done

for ((i=0; i<365; i++)); do
  d=$(date -d "-$i days" +%Y-%m-%d)
  [ "${day_commits[$d]:-0}" -gt 0 ] && cur=$((cur + 1)) || break
done
streak=$cur; cur=0
for ((i=0; i<365; i++)); do
  d=$(date -d "-$i days" +%Y-%m-%d)
  [ "${day_commits[$d]:-0}" -gt 0 ] && cur=$((cur + 1)) || { [ "$cur" -gt "$longest" ] && longest=$cur; cur=0; }
done
[ "$cur" -gt "$longest" ] && longest=$cur

hours_json=$({
  for repo in "${repos[@]}"; do
    git -C "$repo" log --all --format="%ad" --date="format:%H" --after="$YEAR" 2>/dev/null
  done
} | awk '
{
  count[$1]++
}
END {
  out = ""
  for (i = 0; i < 24; i++) {
    h = sprintf("%02d", i)
    c = count[h] + 0
    if (out != "") out = out ","
    out = out c
  }
  print out
}')

cat > "$CACHE" <<EOF
{"repos":$rc,"total":$total,"today":$ctoday,"week":$cweek,"month":$cmonth,"year":$cyear,"streak":$streak,"longest":$longest,"max_day":$max_day,"max_date":"$max_date","languages":{$lang_json},"hours":[$hours_json]}
EOF

rm -f "$LOCK"
cat "$CACHE"
