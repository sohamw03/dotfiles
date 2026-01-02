#!/usr/bin/env bash

# 1. CPU: User + System usage (Your logic)
cpu=$(top -b -n 1 | grep "Cpu(s)" | awk '{print $2 + $4}')

# 2. RAM: Used / Total GB (Precise 0.00)
ram=$(free -k | awk '/Mem:/ {printf "%.2f / %.2f GB", $3/1024/1024, $2/1024/1024}')

# 3. GPU: Check for nvidia-smi
if command -v nvidia-smi &> /dev/null; then
    gpu=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits)
else
    gpu="0"
fi

# 4. Disk: Used / Total GB (Precise 0.00) for root
disk=$(df -k / | awk 'NR==2 {printf "%.2f / %.2f GB", $3/1024/1024, $2/1024/1024}')

# Output JSON
# Double backslashes \\n are required for Waybar to render newlines
printf '{"text":"󰍛", "tooltip":"CPU: %s%%\\nRAM: %s\\nGPU: %s%%\\nDisk: %s"}\n' "$cpu" "$ram" "$gpu" "$disk"
