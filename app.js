var sqlite3 = require('sqlite3').verbose();
var fs = require('fs');

var file = process.env.HOME + '/Library/Messages/chat.db';

var util = require('util'),
    exec = require('child_process').exec,
    child;

var db = new sqlite3.Database(file);
var minrow = 0;
var processed = [];

var readArray = function(){
  var arr = fs.readFileSync('./processed.json').toString();
  processed = JSON.parse(arr);
  return processed[processed.length - 1];
}

var writeArray = function(id){
  processed.push(id);
  processed.sort();
  fs.writeFile('./processed.json', JSON.stringify(processed), 
    function (err) {
        
    }
  );
}

var fetchNew = function(){
  console.log('checking now');
  //check if the DB has been updated, if so get new images
  db = new sqlite3.Database(file);
  db.each("SELECT rowid, filename FROM attachment WHERE rowid > "+minrow,function(err,row){
    if(typeof row !== "undefined"){
      minrow = row.ROWID;

      image = row.filename;
      console.log(image);
      console.log('new minrow:',minrow);

      child = exec('bash bash/process-single.sh '+row.filename, 
        function (error, stdout, stderr) {      
          // one easy function to capture data/errors
          console.log('stdout: ' + stdout);
          console.log('stderr: ' + stderr);
          if (error === null){
            //if there was no error processing and adding to print queue, 
            //add to the array of processed images
            writeArray(row.ROWID);
          }
          
        }
      );
    }

  });
}

//if first time running, get current Max ID so we don't print any old photos
if(process.argv[2] == "first"){
  db.each("SELECT rowid FROM attachment WHERE rowid = (SELECT MAX(rowid)  FROM attachment)",function(err,row){
    minrow = row.ROWID;
    writeArray(row.ROWID);
  })
}else{
  minrow = readArray();
}


setInterval(fetchNew,5000);