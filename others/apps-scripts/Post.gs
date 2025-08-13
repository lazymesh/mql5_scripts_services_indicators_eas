function doPost(e) {
  try {
    // Validate input
    if (!e || !e.postData || !e.postData.contents) {
      throw new Error("no Input data found");
    }

    // Parse JSON safely
    const json = JSON.parse(e.postData.contents);
    const sheetName = json.sheetName || "Sheet1";

    // Get sheet (with error handling)
    const spreadsheet = SpreadsheetApp.getActiveSpreadsheet();
    var sheet = spreadsheet.getSheetByName(sheetName);
    if (!sheet) {
      sheet = spreadsheet.insertSheet(sheetName);
    }
    
    // formatting data to be written in sheet
    var terminalInfo = json.data.split("#;#");
    var insertingData = [];
    for(var i = 0; i < terminalInfo.length; i++) {
      insertingData.push(terminalInfo[i].split("#:#"))
    }
    var startRow = 1;
    var startColumn = 1;
    var numRows = insertingData.length;
    var numColumns = insertingData[0].length;
    var range = sheet.getRange(startRow, startColumn, numRows, numColumns);

    // Overwrite the rows with the new data
    range.setValues(insertingData);


    // Return success
    return ContentService.createTextOutput(JSON.stringify({
      status: "success",
      message: "Data written to sheet"
    })).setMimeType(ContentService.MimeType.JSON);

  } catch (err) {
    // Return error details
    return ContentService.createTextOutput(JSON.stringify({
      status: "error",
      message: err.message
    })).setMimeType(ContentService.MimeType.JSON);
  }
}