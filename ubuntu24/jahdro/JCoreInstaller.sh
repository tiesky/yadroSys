#!/usr/bin/env bash
set -euo pipefail

cdn_root='https://raw.githubusercontent.com/tiesky/yadroSys/master'
sdk_major='8'

usage() {
    echo 'Usage: sudo bash JCoreInstaller.sh <port> | uninstall <port>' >&2
    exit 2
}

if [[ $EUID -ne 0 ]]; then
    echo 'Run this installer as root (sudo).' >&2
    exit 1
fi

if [[ $# -eq 1 ]]; then
    action='install'
    port=$1
elif [[ $# -eq 2 && $1 == 'uninstall' ]]; then
    action='uninstall'
    port=$2
else
    usage
fi

[[ $port =~ ^[0-9]+$ ]] || usage
(( 10#$port >= 1 && 10#$port <= 65535 )) || usage
port=$((10#$port))

instance_dir="/var/lib/www.scanmedia.net/GpsCarControl/Server/Port_${port}"
watchdog_dir="/opt/jcore-watchdog/Port_${port}"
watchdog_file="${watchdog_dir}/JCoreWatchdog"
unit_name="JCoreWatchdog${port}.service"
unit_file="/etc/systemd/system/${unit_name}"
user_name="usrjcore${port}"

if [[ $action == 'uninstall' ]]; then
    if [[ -f $unit_file ]]; then
        systemctl disable --now "$unit_name"
        rm -f -- "$unit_file"
        systemctl daemon-reload
    fi
    rm -f -- "$watchdog_file"
    rmdir -- "$watchdog_dir" 2>/dev/null || true
    echo "Removed ${unit_name}. JCore data and ${user_name} were retained."
    exit 0
fi

source /etc/os-release
if [[ ${ID:-} != 'ubuntu' || ${VERSION_ID:-} != '24.04' ]]; then
    echo 'Ubuntu 24.04 is required.' >&2
    exit 1
fi

case "$(uname -m)" in
    x86_64) architecture='amd64' ;;
    aarch64) architecture='arm64' ;;
    *) echo 'Only AMD64 and ARM64 are supported.' >&2; exit 1 ;;
esac

if ! command -v dotnet >/dev/null 2>&1 ||
   ! dotnet --list-sdks | grep -q "^${sdk_major}\\."; then
    apt-get update
    apt-get install -y "dotnet-sdk-${sdk_major}.0"
fi

if ! command -v curl >/dev/null 2>&1; then
    apt-get update
    apt-get install -y curl
fi

mkdir -p -- "$watchdog_dir"
temporary=$(mktemp "${watchdog_dir}/.JCoreWatchdog.XXXXXXXX")
trap 'rm -f -- "$temporary"' EXIT
curl --fail --location --show-error --silent --retry 3 \
    "${cdn_root}/ubuntu24/${architecture}/jahdro/JCoreWatchdog" \
    --output "$temporary"
chmod 0755 "$temporary"

if ! id -u "$user_name" >/dev/null 2>&1; then
    useradd --system --user-group --home-dir "$instance_dir" \
        --shell /usr/sbin/nologin "$user_name"
fi
group_name=$(id -gn "$user_name")
mkdir -p -- "$instance_dir"
chown -R -- "${user_name}:${group_name}" "$instance_dir"
chmod 0700 "$instance_dir"

if [[ -f $unit_file ]]; then
    systemctl stop "$unit_name"
fi
mv -f -- "$temporary" "$watchdog_file"
chown root:root "$watchdog_file"
chmod 0755 "$watchdog_file"

capabilities=''
if (( port < 1024 )); then
    capabilities=$'AmbientCapabilities=CAP_NET_BIND_SERVICE\nCapabilityBoundingSet=CAP_NET_BIND_SERVICE'
fi

cat > "$unit_file" <<UNIT
[Unit]
Description=JCore watchdog for port ${port}
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
User=${user_name}
Group=${group_name}
WorkingDirectory=${instance_dir}
ExecStart=${watchdog_file} ${port}
Restart=always
RestartSec=60
KillMode=control-group
TimeoutStopSec=30
PrivateTmp=yes
${capabilities}

[Install]
WantedBy=multi-user.target
UNIT

chmod 0644 "$unit_file"
systemctl daemon-reload
systemctl enable --now "$unit_name"
echo "Installed ${unit_name}. Use: journalctl -u ${unit_name} -f"
