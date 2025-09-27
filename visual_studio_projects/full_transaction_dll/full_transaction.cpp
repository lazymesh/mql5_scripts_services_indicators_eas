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
    } else {
        result = "Request failed";
    }

    WinHttpCloseHandle(hRequest);
    WinHttpCloseHandle(hConnect);
    WinHttpCloseHandle(hSession);

    return result;
}

// Wrappers
std::string get_item_impl(int item_id) {
    std::wstring path = L"/items/" + std::to_wstring(item_id) + L"?q=test";
    return http_request(L"GET", path);
}

std::string create_item_impl(const std::string& name, double price, bool in_stock) {
    std::wstring path = L"/items/";
    std::string body = "{\"name\":\"" + name + "\",\"price\":" +
                       std::to_string(price) +
                       ",\"in_stock\":" + (in_stock ? "true" : "false") + "}";
    return http_request(L"POST", path, body);
}

// Exported functions (for external use, e.g., MQL5)
extern "C" {

__declspec(dllexport) const char* get_item_dll(int item_id) {
    static std::string result;
    result = get_item_impl(item_id);
    return result.c_str();
}

__declspec(dllexport) const char* create_item_dll(const char* name, double price, bool in_stock) {
    static std::string result;
    result = create_item_impl(name, price, in_stock);
    return result.c_str();
}

}

// DllMain — called automatically when the DLL is loaded/unloaded
BOOL APIENTRY DllMain(HMODULE hModule, DWORD reason, LPVOID reserved) {
    switch (reason) {
    case DLL_PROCESS_ATTACH:
        // DLL loaded
        break;
    case DLL_PROCESS_DETACH:
        // DLL unloaded
        break;
    }
    return TRUE;
}
