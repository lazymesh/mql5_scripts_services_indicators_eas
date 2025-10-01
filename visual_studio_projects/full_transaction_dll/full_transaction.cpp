// dllmain.cpp : Defines the entry point for the DLL application.
#include <windows.h>
#include <winhttp.h>
#include <string>
#include <iostream>
#include <fstream>
#include <locale>
#include <codecvt>

#pragma comment(lib, "winhttp.lib")

void logToFile(const std::string& message) {
    std::ofstream file("C:\\Users\\rawnm\\Documents\\simple.log", std::ios::app);
    if (file.is_open()) {
        file << " - " << message << std::endl;
        file.close();
    }
}

std::wstring string_to_wstring(const std::string& str) {
    std::wstring_convert<std::codecvt_utf8<wchar_t>> converter;
    return converter.from_bytes(str);
}

std::string wstring_to_string(const std::wstring& wstr) {
    std::wstring_convert<std::codecvt_utf8<wchar_t>> converter;
    return converter.to_bytes(wstr);
}

// Helper: perform request
std::string http_request(const std::wstring& method,
    const std::wstring& path,
    const std::wstring& body = L"") {
    std::string result;
    HINTERNET hSession = WinHttpOpen(L"FastAPI Client/1.0",
        WINHTTP_ACCESS_TYPE_DEFAULT_PROXY,
        WINHTTP_NO_PROXY_NAME,
        WINHTTP_NO_PROXY_BYPASS, 0);

    if (!hSession) return "Failed to open session";

    HINTERNET hConnect = WinHttpConnect(hSession, L"127.0.0.1", 8000, 0);
    if (!hConnect) {
        WinHttpCloseHandle(hSession);
        return "Failed to connect";
    }

    HINTERNET hRequest = WinHttpOpenRequest(hConnect, method.c_str(), path.c_str(),
        NULL, WINHTTP_NO_REFERER,
        WINHTTP_DEFAULT_ACCEPT_TYPES,
        0);

    if (!hRequest) {
        WinHttpCloseHandle(hConnect);
        WinHttpCloseHandle(hSession);
        return "Failed to open request";
    }

    BOOL bResults = WinHttpSendRequest(hRequest,
        L"Content-Type: application/json\r\n",
        -1L,
        (LPVOID)wstring_to_string(body).c_str(),
        (DWORD)body.size(),
        (DWORD)body.size(),
        0);

    if (bResults) bResults = WinHttpReceiveResponse(hRequest, NULL);

    if (bResults) {
        DWORD dwSize = 0;
        do {
            DWORD dwDownloaded = 0;
            if (!WinHttpQueryDataAvailable(hRequest, &dwSize)) break;
            if (!dwSize) break;

            std::string buffer;
            buffer.resize(dwSize);

            if (!WinHttpReadData(hRequest, &buffer[0], dwSize, &dwDownloaded))
                break;

            result.append(buffer.c_str(), dwDownloaded);

        } while (dwSize > 0);
    }
    else {
        result = "Request failed";
    }

    WinHttpCloseHandle(hRequest);
    WinHttpCloseHandle(hConnect);
    WinHttpCloseHandle(hSession);

    return result;
}

// Wrappers
std::string get_item(int item_id) {
    std::wstring path = L"/items/" + std::to_wstring(item_id) + L"?q=test";
    return http_request(L"GET", path);
}

std::string create_item(wchar_t* transactionDetail) {
    std::wstring path = L"/webhook/test";
    std::wstring body = transactionDetail;
    return http_request(L"POST", path, body);
}

// Exported functions (for external use, e.g., MQL5)
extern "C" {

    __declspec(dllexport) bool __stdcall get_latest_dll(wchar_t* outputBuffer, int bufferSize, int item_id)
    {
        try
        {
            static std::wstring result;
            result = string_to_wstring(get_item(item_id));

            // Ensure we don't overflow the buffer
            if (result.length() + 1 > (size_t)bufferSize)
            {
                return false; // Buffer too small
            }

            // Copy string to buffer (MQL expects ANSI null-terminated string)
            wcsncpy_s(outputBuffer, bufferSize, result.c_str(), _TRUNCATE);
            return true;
        }
        catch (...)
        {
            return false;
        }
    }

    __declspec(dllexport) bool __stdcall create_item_dll(wchar_t* transactionDetail) {
        static std::string result;
        result = create_item(transactionDetail);
        if (result.find("success") != std::string::npos) {
            return true;
        }
        return false;
    }

}

// DllMain — called automatically when the DLL is loaded/unloaded

BOOL APIENTRY DllMain(HMODULE hModule,
    DWORD  ul_reason_for_call,
    LPVOID lpReserved
)
{
    switch (ul_reason_for_call)
    {
    case DLL_PROCESS_ATTACH:
    case DLL_THREAD_ATTACH:
    case DLL_THREAD_DETACH:
    case DLL_PROCESS_DETACH:
        break;
    }
    return TRUE;
}

