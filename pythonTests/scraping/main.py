import scrape_investing as si
import scrape_xe as xe

headers = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
}

if __name__ == "__main__":
    #scrape from investing.com
    scrape1 = si.Scrape_Investing(headers)
    # forex_data = scrape1.scrape_investing_forex()
    # print(forex_data.head())
    
    forex_data = scrape1.scrape_forex_with_playwright()
    print(forex_data.head())

    # scrape form xe
    scrape2 = xe.Scrape_XE(headers)
    xe_data = scrape2.scrape_xe_forex()
    print(xe_data.head())