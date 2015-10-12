// use: node printFile.js [filePath printerName]
var printer = require("printer"),
    filename = process.argv[2] || __filename;


printer.printFile({filename:filename,
  printer: process.env[3], // printer name, if missing then will print to default printer
  success:function(jobID){
    console.log("sent to printer with ID: "+jobID);
  },
  error:function(err){
    console.log(err);
  }
});