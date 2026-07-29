#!/bin/bash
# Keeps the trust material in sync so it can never drift from the real script:
#  · docs/install.sh.sha256   (checksum users can verify before running)
#  · README "read the installer" block (the actual script, inline)
#  · docs/data/trust.json     (checksum + pinned tag for the site)
set -e
REPO="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO"

SUM=$(shasum -a 256 docs/install.sh | awk '{print $1}')
VER=$(cat VERSION)
printf '%s  install.sh\n' "$SUM" > docs/install.sh.sha256

python3 - "$SUM" "$VER" <<'PY'
import json, os, re, sys
sum_, ver = sys.argv[1], sys.argv[2]
script = open("docs/install.sh").read()

readme = open("README.md").read()
block = f"""<!-- INSTALLER:START -->
<details>
<summary><b>Read the installer before you run it</b> (recommended — it is {len(script.splitlines())} lines, no obfuscation)</summary>

```bash
{script.rstrip()}
```

</details>

**Verify it instead of trusting us:**

```bash
curl -fsSLO https://himanshu007-creator.github.io/sketchetc/install.sh
shasum -a 256 install.sh    # expect {sum_}
less install.sh             # read it
bash install.sh
```

**Pin to a release** (immutable — this exact commit, forever):

```bash
curl -fsSL https://raw.githubusercontent.com/himanshu007-creator/sketchetc/v{ver}/docs/install.sh -o install.sh
shasum -a 256 install.sh && bash install.sh
```
<!-- INSTALLER:END -->"""

if "<!-- INSTALLER:START -->" in readme:
    readme = re.sub(r"<!-- INSTALLER:START -->.*?<!-- INSTALLER:END -->", block, readme, flags=re.S)
else:
    readme = readme.replace("Re-running the same command upgrades in place.",
                            block + "\n\nRe-running the same command upgrades in place.")
open("README.md", "w").write(readme)

os.makedirs("docs/data", exist_ok=True)
json.dump({"sha256": sum_, "version": ver, "lines": len(script.splitlines())},
          open("docs/data/trust.json", "w"), indent=1)
print(f"trust synced · sha256 {sum_[:16]}… · {len(script.splitlines())} lines · pinned v{ver}")
PY
