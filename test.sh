#!/bin/bash -e
# Boots a built root in iSH's emulator and checks the shell it ships.
#
# Usage: ./test.sh out/appstore-apk.tar.gz <ish build dir>
# The build dir is where `meson setup build && ninja -C build ish tools/fakefsify` put its output.
# MAX_STARTUP_MS caps how long an interactive zsh may take to start, measured above /bin/true.

root_tar=$(cd "$(dirname "$1")" && pwd)/$(basename "$1")
ish_build=$(cd "$2" && pwd)
max_startup_ms=${MAX_STARTUP_MS:-1500}

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
LC_ALL=en_US.UTF-8 "$ish_build/tools/fakefsify" "$root_tar" "$work/root"

failures=0
fail() {
    echo "FAIL: $*"
    failures=$((failures + 1))
}

# Runs a command as the app does, logged in as root, on a pseudo-terminal like the app's,
# typing the optional second argument into it.
in_root() {
    printf "${2:-}" | script -q /dev/null "$ish_build/ish" -f "$work/root" /bin/su -l root -c "$1" 2>&1 | tr -d '\r'
}

now_ms() {
    python3 -c 'import time; print(int(time.monotonic() * 1000))'
}

now_first_start() {
    local start end
    start=$(now_ms)
    in_root 'zsh -i -c exit' > /dev/null
    end=$(now_ms)
    echo $((end - start))
}

# Median of five runs, minus the emulator's own start-up.
measure() {
    local runs=()
    for _ in 1 2 3 4 5; do
        local start end
        start=$(now_ms)
        in_root "$1" > /dev/null
        end=$(now_ms)
        runs+=($((end - start)))
    done
    printf '%s\n' "${runs[@]}" | sort -n | sed -n 3p
}

# The very first start, on a root fresh from the archive, is what a new user waits through.
first_start=$(now_first_start)
baseline=$(measure 'true')
first_start=$((first_start - baseline))
echo "first interactive zsh starts in ${first_start} ms"
[ "$first_start" -le "$max_startup_ms" ] || fail "the first interactive zsh takes ${first_start} ms, over ${max_startup_ms} ms"

shell=$("$ish_build/ish" -f "$work/root" /bin/sh -c 'grep ^root: /etc/passwd | cut -d: -f7')
[ "$shell" = /bin/zsh ] || fail "root's shell is '$shell', not /bin/zsh"

output=$(in_root 'zsh -i -c "echo theme=\$ZSH_THEME; (( \$+functions[p10k] )) && echo p10k=loaded"')
echo "$output" | grep -q 'theme=powerlevel10k/powerlevel10k' || fail "oh-my-zsh isn't using powerlevel10k: $output"
echo "$output" | grep -q 'p10k=loaded' || fail "p10k isn't loaded: $output"
if echo "$output" | grep -qiE 'error|not found|warning|configuration wizard|insecure'; then
    fail "interactive zsh complained: $output"
fi

# Every new session opens with a small PhantOS banner, the size of a few lines of text: block
# letters were unreadable on an iPhone. Every line fits 40 columns.
for cols in 40 80; do
    # Compared as shown on screen, without the colour codes between the ghost and the name.
    output=$(in_root "stty cols $cols rows 30; exec zsh -i" 'exit\n' | sed $'s/\x1b\\[[0-9;]*m//g')
    echo "$output" | grep -q '▄███▄  PhantOS' || fail "no PhantOS banner at $cols columns: $output"
    echo "$output" | grep -qE '██████╗|█▀█ █ █ ▄▀█' && fail "block letters came back at $cols columns: $output"
done
# Like fastfetch, the banner tells where you are, read without starting a process.
banner=$(in_root 'stty cols 40 rows 30; exec zsh -i' 'exit\n' | sed 's/\x1b\[[0-9;]*m//g' | grep -E '▄███▄|█▀█▀█|▀ ▀ ▀|apk add')
echo "$banner" | grep -q 'root@' || fail "the banner doesn't say who you are: $banner"
echo "$banner" | grep -q 'Alpine 3\.' || fail "the banner doesn't name the system: $banner"
echo "$banner" | grep -q 'zsh 5\.' || fail "the banner doesn't name the shell: $banner"
echo "$banner" | grep -qE 'up [0-9]+ (min|h|d)' || fail "the banner doesn't show uptime: $banner"
echo "$banner" | grep -qE '[0-9]+ packages' || fail "the banner doesn't count packages: $banner"
while IFS= read -r line; do
    [ "${#line}" -le 40 ] || fail "banner line wider than 40 columns: '$line'"
done <<< "$banner"
# The very first session starts before the app knows the screen's size, at 80 columns. zsh's mark
# for a line without a newline ("#" for root) then lands mid-screen on an iPhone; it stays unset.
# Unset, zsh falls back to its built-in mark, so it must be set, and empty.
output=$(in_root 'zsh -i -c "print -r -- eol-mark=\${+PROMPT_EOL_MARK}:\${#PROMPT_EOL_MARK}"')
echo "$output" | grep -q 'eol-mark=1:0' || fail "PROMPT_EOL_MARK isn't set to empty: $output"

# Commands run through zsh -c are scripts, not sessions.
output=$(in_root 'zsh -i -c true')
echo "$output" | grep -q '██' && fail "a zsh -c command printed the banner: $output"
# The banner replaces Alpine's welcome, which login prints from /etc/motd.
"$ish_build/ish" -f "$work/root" /bin/cat /etc/motd | grep -q 'Welcome to Alpine' && fail "Alpine's welcome is still in /etc/motd"

# The prompt shows the branch inside a repository. Ghostty-style shells live in git checkouts.
output=$(in_root 'mkdir -p /tmp/repo && cd /tmp/repo && git init -q -b phantos-branch && exec zsh -i' 'exit\n')
echo "$output" | grep -q 'phantos-branch' || fail "the prompt doesn't show the git branch: $output"
if echo "$output" | grep -qiE 'error|failed'; then
    fail "the prompt in a repository complained: $output"
fi


startup=$(( $(measure 'zsh -i -c exit') - baseline ))
echo "interactive zsh starts in ${startup} ms (emulator baseline ${baseline} ms)"
[ "$startup" -le "$max_startup_ms" ] || fail "interactive zsh takes ${startup} ms, over ${max_startup_ms} ms"

if [ "$failures" -gt 0 ]; then
    echo "$failures check(s) failed"
    exit 1
fi
echo "all checks passed"
