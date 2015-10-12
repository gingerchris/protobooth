var gulp = require('gulp');
var gm = require('gulp-gm');
var sqlite3 = require('sqlite3').verbose();

var file = 'db/chat.db';

var db = new sqlite3.Database(file);

//at app launch, find current newest message
var minrow = 0;

db.each("SELECT rowid FROM attachment WHERE rowid = (SELECT MAX(rowid)  FROM attachment)",function(err,row){
  minrow = row.ROWID;
  console.log(minrow);
});

function process(event){
  //messages DB has been updated - retrieve any new images and process them
  db = new sqlite3.Database(file);
  db.each("SELECT rowid, filename FROM attachment WHERE rowid > "+minrow,function(err,row){
    minrow = row.ROWID;

    image = row.filename;
    console.log(image);
  });
}

gulp.task('default', function () {
  gulp.watch(file, process);
});