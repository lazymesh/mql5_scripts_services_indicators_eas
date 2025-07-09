#include <Windows.h>
BOOL APIENTRY DllMain(HMODULE hModule, DWORD reason, LPVOID lpReserved) {
    return TRUE;
}
extern "C" __declspec(dllexport) int Test() { return 42; }