function myFunction() {
  const data = {
    postData : {
      contents: JSON.stringify({
        sheetName: "Terminal_Info",
        symbol: "EURUSD",
        bid: 1.34321,
        ask : 1.23243,
        volume: 30
      })
    }
  };
  const posted = doPost(data);
}

function terminal_info() {
  const data = {
    postData : {
      contents: JSON.stringify({
        sheetName: "Terminal_Info",
        data: "build number: \t%d\n" +
      "trade server connected: \t%s\n" +
      "DLLs are allowed: \t%s\n" + 
      "trading enabled: \t%s\n" +
      "email enabled: \t%s\n" + 
      "ftp enabled: \t%s\n" +
      "max bars allowed in chart: \t%d\n" +
      "code page language: \t%s\n" +
      "cpu cores used: \t%d\n" +
      "physical memory: \t%d MB\n" +
      "memory available: \t%d MB\n" +
      "memory used: \t%d MB\n" +
      "memory total: \t%d MB\n" +
      "system is x64: \t%s\n" +
      "OpenCl version: \t%s\n" +
      "free disk space: \t%d MB\n" +
      "terminal language: \t%s\n" +
      "common data folder of all terminals, installed on the computer: \tC\\users\\crossover\\AppData\\Roaming\\MetaQuotes\\Terminal\\Common\n" +
      "data folder of the terminal: \t%s\n" +
      "folder of the client terminal: \t%s\n" +
      "company name of the terminal: \t%s\n" +
      "name of the terminal: \t%s"
      })
    }
  };
  const posted = doPost(data);
}

function testGet() {
  const data = {
    postData : JSON.stringify({
      symbol: "EURUSD",
      bid: 1.34321,
      ask : 1.23243,
      volume: 30
    })
  };
  var result = doGet(data);
  console.log("result ", JSON.stringify(result));
}
