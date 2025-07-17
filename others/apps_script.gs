function doPost(e) {
  try {
    // 1. Validate input
    if (!e || !e.postData || !e.postData.contents) {
      throw new Error("no Input data found");
    }

    // 2. Parse JSON safely
    const json = JSON.parse(e.postData.contents);
    if (!json.symbol) throw new Error("Missing 'symbol' in JSON");

    // 3. Get sheet (with error handling)
    const spreadsheet = SpreadsheetApp.getActiveSpreadsheet();
    const sheet = spreadsheet.getSheetByName("Sheet1");
    if (!sheet) {
      sheet = spreadsheet.insertSheet("Sheet1");
      sheet.appendRow(["Timestamp", "Symbol", "Bid", "Ask", "Volume"]); // Add headers
    }

    // 4. Append data
    sheet.appendRow([
      new Date(),
      json.symbol,
      json.ask,
      json.bid,
      json.volume
    ]);

    // 5. Return success
    return ContentService.createTextOutput(JSON.stringify({
      status: "success",
      message: "Data written to sheet"
    })).setMimeType(ContentService.MimeType.JSON);

  } catch (err) {
    // Log error to Stackdriver (visible in Apps Script dashboard)
    console.error("Error:", err.message);

    // Return error details
    return ContentService.createTextOutput(JSON.stringify({
      status: "errors",
      message: err.message + " original e " + JSON.stringify(e)
    })).setMimeType(ContentService.MimeType.JSON);
  }
}