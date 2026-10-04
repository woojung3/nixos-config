case "${1:-}" in
  lock) loginctl lock-session ;;
  suspend) systemctl suspend ;;
  logout) uwsm stop ;;
  reboot) systemctl reboot ;;
  poweroff) systemctl poweroff ;;
  *) printf 'Unknown power action\n' >&2; exit 1 ;;
esac
