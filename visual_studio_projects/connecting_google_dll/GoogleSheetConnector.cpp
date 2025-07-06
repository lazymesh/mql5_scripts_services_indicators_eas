#include <windows.h>
#include <string>
#include <curl/curl.h>
#include <nlohmann/json.hpp>

using json = nlohmann::json;

// Callback for libcurl to write response data
static size_t WriteCallback(void* contents, size_t size, size_t nmemb, std::string* output) {
    size_t total_size = size * nmemb;
    output->append((char*)contents, total_size);
    return total_size;
}

// Function to get OAuth2 access token (exported for MQL5)
extern "C" __declspec(dllexport) const char* GetGoogleAccessToken(
    const char* client_id,
    const char* client_secret,
    const char* refresh_token)
{
    static std::string access_token; // Persistent storage
    CURL* curl = curl_easy_init();
    std::string response;
    
    if (curl) {
        std::string post_data = 
            "client_id=" + std::string(client_id) +
            "&client_secret=" + std::string(client_secret) +
            "&refresh_token=" + std::string(refresh_token) +
            "&grant_type=refresh_token";

        curl_easy_setopt(curl, CURLOPT_URL, "https://oauth2.googleapis.com/token");
        curl_easy_setopt(curl, CURLOPT_POSTFIELDS, post_data.c_str());
        curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, WriteCallback);
        curl_easy_setopt(curl, CURLOPT_WRITEDATA, &response);
        
        if (curl_easy_perform(curl) == CURLE_OK) {
            auto json_response = json::parse(response);
            access_token = json_response["access_token"].get<std::string>();
        }
        
        curl_easy_cleanup(curl);
    }
    
    return access_token.c_str();
}

// Function to write trading data to Google Sheets
extern "C" __declspec(dllexport) bool WriteTradeDataToSheet(
    const char* access_token,
    const char* spreadsheet_id,
    const char* sheet_range,
    const char* symbol,
    double bid,
    double ask,
    long volume)
{
    CURL* curl = curl_easy_init();
    std::string response;
    
    if (curl) {
        // Prepare JSON payload
        json payload;
        payload["values"] = json::array({
            json::array({
                TimeToString(time(nullptr)), // Current timestamp
                symbol,
                std::to_string(bid),
                std::to_string(ask),
                std::to_string(volume)
            })
        });

        std::string url = std::string("https://sheets.googleapis.com/v4/spreadsheets/") + 
                         spreadsheet_id + 
                         "/values/" + 
                         sheet_range + 
                         ":append?valueInputOption=USER_ENTERED";

        struct curl_slist* headers = nullptr;
        headers = curl_slist_append(headers, ("Authorization: Bearer " + std::string(access_token)).c_str());
        headers = curl_slist_append(headers, "Content-Type: application/json");

        curl_easy_setopt(curl, CURLOPT_URL, url.c_str());
        curl_easy_setopt(curl, CURLOPT_HTTPHEADER, headers);
        curl_easy_setopt(curl, CURLOPT_POSTFIELDS, payload.dump().c_str());
        curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, WriteCallback);
        curl_easy_setopt(curl, CURLOPT_WRITEDATA, &response);

        CURLcode result = curl_easy_perform(curl);
        curl_slist_free_all(headers);
        curl_easy_cleanup(curl);

        return result == CURLE_OK;
    }
    return false;
}

// Standard DLL entry point
BOOL APIENTRY DllMain(HMODULE hModule, DWORD reason, LPVOID reserved) {
    if (reason == DLL_PROCESS_ATTACH) {
        curl_global_init(CURL_GLOBAL_ALL);
    }
    else if (reason == DLL_PROCESS_DETACH) {
        curl_global_cleanup();
    }
    return TRUE;
}