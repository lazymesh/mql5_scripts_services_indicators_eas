function doGet(e) {
  console.log(JSON.stringify(e));
  const spreadsheet = SpreadsheetApp.getActiveSpreadsheet();
  const sheet = spreadsheet.getSheetByName("Sheet1");
  var lastRow = sheet.getRange(sheet.getLastRow(), 1, 1, sheet.getLastColumn()).getValues();
  console.log("last row ", lastRow);
  return lastRow;
  return ContentService.createTextOutput(JSON.stringify({
      status: "data",
      message: lastRow
    })).setMimeType(ContentService.MimeType.JSON);
}
