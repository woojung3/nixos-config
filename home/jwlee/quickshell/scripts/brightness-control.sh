# Shared by the popup and hardware keys. Never set below 5% of raw maximum.
maximum="$(brightnessctl max)"
current="$(brightnessctl get)"
minimum=$(( (maximum * 5 + 99) / 100 ))
percent=$(( (current * 100 + maximum / 2) / maximum ))
case "${1:-}" in
  get) printf '%s\n' "$percent"; exit 0 ;;
  up) target=$((percent + 5)) ;;
  down) target=$((percent - 5)) ;;
  set)
    [[ "${2:-}" =~ ^[0-9]{1,3}$ ]] || exit 1
    target=$((10#$2))
    ;;
  *) exit 1 ;;
esac
(( target < 5 )) && target=5
(( target > 100 )) && target=100
raw=$(( (maximum * target + 50) / 100 ))
(( raw < minimum )) && raw=$minimum
brightnessctl set "$raw" > /dev/null
