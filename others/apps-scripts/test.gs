function myFunction() {
  const data = {
    postData : JSON.stringify({
      symbol: "EURUSD",
      bid: 1.34321,
      ask : 1.23243,
      volume: 30
    })
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
