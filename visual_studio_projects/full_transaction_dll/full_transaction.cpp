// dllmain.cpp : Defines the entry point for the DLL application.
#include <windows.h>
#include <winhttp.h>
#include <string>

#pragma comment(lib, "winhttp.lib")

// Helper: perform request
std::string http_request(const std::wstring& method,
    const std::wstring& path,
    const std::string& body = "") {
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
        (LPVOID)body.c_str(),
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

std::string create_item(const std::string& transactionDetail) {
    std::wstring path = L"/webhook/test";
    std::string body = transactionDetail;
    return http_request(L"POST", path, body);
}

// Exported functions (for external use, e.g., MQL5)
extern "C" {

    __declspec(dllexport) bool __stdcall GetStringData(char* outputBuffer, int bufferSize, int item_id)
    {
        try
        {
            static std::string result;
            result = get_item(item_id);
            std::string rtnResult = "result.c_str()"; // Your actual data

            // Ensure we don't overflow the buffer
            if (rtnResult.length() + 1 > (size_t)bufferSize)
            {
                return false; // Buffer too small
            }

            // Copy string to buffer (MQL expects ANSI null-terminated string)
            strcpy_s(outputBuffer, bufferSize, rtnResult.c_str());
            printf("Buffer content: %s\n", outputBuffer);
            return true;
        }
        catch (...)
        {
            return false;
        }
    }

    __declspec(dllexport) const char* get_item_dll(int item_id) {
        static std::string result;
        result = get_item(item_id);
        //return result.c_str();
        result = "testing";
        return result.c_str();
    }

    __declspec(dllexport) const char* create_item_dll(const char* transactionDetail) {
        static std::string result;
        result = create_item(transactionDetail);
        return result.c_str();
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

