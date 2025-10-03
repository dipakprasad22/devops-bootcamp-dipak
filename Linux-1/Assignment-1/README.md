# sysinfo — Comprehensive System Information Script

A portable, modular Bash script that collects a wide range of system information and produces a human‑readable report (or JSON). Designed to be safe (read‑only), self‑contained, and easy to run on Linux systems. Run as root to collect additional hardware/firmware details.

---

## Features
- Modular functions for categories: `host`, `os`, `kernel`, `cpu`, `memory`, `disks`, `mounts`, `network`, `services`, `processes`, `packages`, `docker`, `virt`, `security`, `hardware`, `modules`, `logs`, `checks`.
- Graceful detection of missing tools (skips sections if utilities are absent).
- Text output by default; optional `--json` output (requires `python3`).
- Optional output-to-file (`-o` / `--output`) and section selection (`--sections`).
- Safe: reads system state only; does not change system configuration.
- Easy to extend or source from other scripts.

---

## Requirements
- GNU Bash (or POSIX-compatible shell)
- Common Linux utilities (`lsblk`, `df`, `ip`/`ifconfig`, `ps`, etc.)
- `python3` only if you need JSON output (`--json`)
- Optional (for richer output): `dmidecode` (root), `lspci`, `lsusb`, `sensors`, `docker`/`podman`, `journalctl`, `nft`/`iptables`, `systemctl`, `virt-what`/`systemd-detect-virt`.

---

## Installation
1. Save the script as `sysinfo.sh` (copy/paste or download).
2. Make it executable:
   ```bash
   chmod +x sysinfo.sh
   ```
3. (Optional) Move to a directory in your `PATH`:
   ```bash
   sudo mv sysinfo.sh /usr/local/bin/sysinfo
   ```

---

## Usage

### Basic (text report to stdout)
```bash
./sysinfo.sh
# or if installed in PATH
sysinfo
```

### Select sections only
```bash
./sysinfo.sh --sections host,os,cpu,memory
```

Valid section names:
`host, os, kernel, users, cpu, memory, disks, mounts, network, services, processes, packages, docker, virt, security, hardware, modules, logs, checks, all`

### JSON output (requires `python3`)
```bash
./sysinfo.sh --json --output sysinfo.json
```

### Write text report to file
```bash
./sysinfo.sh --output /tmp/sysinfo.txt
```

### Run as root for additional hardware details
Some sections (e.g., `dmidecode`, `sensors`) require root privileges:
```bash
sudo ./sysinfo.sh --sections hardware,logs --output /tmp/hw-report.txt
```

---

## Examples

Generate a full report and save it:
```bash
./sysinfo.sh --output /tmp/full-sysinfo.txt
```

Generate a small JSON report with only network & processes:
```bash
./sysinfo.sh --sections network,processes --json --output /tmp/net-proc.json
```

Run regularly via cron (daily at 2am) and keep last 7 reports:
```cron
0 2 * * * /usr/local/bin/sysinfo --output /var/reports/sysinfo-$(date +\%F).txt && find /var/reports -type f -name 'sysinfo-*.txt' -mtime +7 -delete
```

---

## Troubleshooting & Notes
- **`--json` fails**: ensure `python3` is installed.
- **Missing commands**: install relevant packages (`lsblk`, `lspci`, `dmidecode`, etc.) to enrich the output.
- **Large output**: use `--sections` to limit output (logs are verbose).
- **Permissions**: non-root users will not see hardware/firmware details. Use `sudo` if needed.
- **Non-Linux systems**: script targets Linux; some utilities differ on BSD/macOS.

---

## Extending the script
- Add new `section_foo()` functions and map them in `run_section()` to expose them via `--sections`.
- Add `--quiet` mode, `--upload`, or HTML export for visual reports.
- Consider unit tests and `shellcheck` linting for quality.

---

## Security considerations
- The script only reads system state and does not modify configuration.
- Output can include sensitive information (installed packages, open ports, logs). Redact before sharing publicly.
- When automating report uploads, use secure transport and limit recipients.

---

## Contributing
- Bug reports, feature requests and pull requests are welcome.
- Keep functions modular and add tests where possible.
- Use `shellcheck` and small integration tests to validate changes.

---

## License
MIT License — see LICENSE file or include the license header in your repository.

---

## Author
Generated with assistance from ChatGPT (2025). Modify the content, year, and attribution as appropriate.
