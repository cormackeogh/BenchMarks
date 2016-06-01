
var rcUtilsSrv = require('./rcUtilsSrv');

var ReadPreference = require('mongodb').ReadPreference;

console.log('Module:SessionMobile - Calling GetDB() ' + 'line='+ __line + "  Function='" +__function);
var db;
require('./DataAccessAdapter').GetDB(function(dblocal) {
    db=dblocal;
});

var rsa = require('./ReportScriptAthletes');
var read_preference = {readPreference: ReadPreference.PRIMARY};
var writeOptions =  { w: 1, safe: true};
var writeConcern = {w:1};
var bypass=false;


exports.benchmarkService = function (req, res) {

    //console.log(req.body);
    var upData = req.body;

    console.log("Start Bnechmark function");

    var command = upData.cmd;
    var ret = {};

    switch (command)
    {
        case "Insert" :
            var table = upData.table;
            var key = upData.key;
            var values = upData.values;
            var b = new Buffer(values, 'base64')
            var valuesAsString = b.toString();
            var newDoc = JSON.parse(valuesAsString);
            newDoc._id = key;

            db.collection(table, function (err, collection) {
                collection.insert(newDoc,writeOptions, function (err, result) {
                    if (err) {
                        console.log('Error: ' + err);
                        ret.writeResult= 'Error';
                        ret.err =  err;
                        ret.returnCode=-3;   // Error Returned from database

                        res.send(ret);
                        //res.jsonp(200, ret);
                        console.log('An error has occurred ' + err);
                    } else {
                        ret.writeResult =  'Success';
                        ret.keyID =  key;
                        res.send(ret);
                        //res.jsonp(200, ret);
                    }
                });
            });


            break;
        case "Delete" :

            var table = upData.table;
            var key = upData.key;

            db.collection(table, function (err, collection) {
                collection.delete({"_id":key}, function (err, result) {
                    if (err) {
                        console.log('Error: ' + err);
                        ret.writeResult= 'Error';
                        ret.err =  err;
                        ret.returnCode=-3;   // Error Returned from database

                        res.send(ret);
                        //res.jsonp(200, ret);
                        console.log('An error has occurred ' + err);
                    } else {
                        ret.writeResult =  'Success';
                        ret.keyID =  key;
                        res.send(ret);
                        //res.jsonp(200, ret);
                    }
                });
            });



            break;
        case "Update":
            var table = upData.table;
            var key = upData.key;
            var values = upData.values;
            var b = new Buffer(values, 'base64')
            var valuesAsString = b.toString();
            var newDoc = JSON.parse(valuesAsString);
            newDoc._id = key;
            console.log('Update Call');

            if(bypass){
                console.log('Bypass MongDB');
                ret.writeResult = 'Success Bypass';
                ret.keyID = key;
                res.send(ret);
            }
            else {
                db.collection(table, function (err, collection) {
                    collection.update(
                        {
                            '_id': key
                        },
                        newDoc,
                        writeConcern,
                        function (err, result) {

                            if (err) {
                                console.log('Update Error: ' + err);
                                ret.writeResult = 'Error';
                                ret.err = err;
                                ret.returnCode = -3;   // Error Returned from database
                                res.send(ret);
                                //res.jsonp(200, ret);

                            } else {
                                console.log('Update Success');
                                ret.writeResult = 'Success';
                                ret.keyID = key;
                                res.send(ret);
                                //res.jsonp(200, ret);
                            }
                        });
                });
            }
            break;
        case "Scan" :
            break;
        case "Read":
            var table = upData.table;
            var key = upData.key;
            console.log('Read Call');
            if(bypass){
                console.log('Bypass MongDB');
                ret.writeResult = 'Success Bypass';
                ret.keyID = key;
                res.send(ret);
            }
            else {
                db.collection(table, function (err, collection) {
                    collection.find(
                        {
                            '_id': key
                        }, read_preference
                    ).toArray(function (err, items) {

                        if ( (items!=null) &&  items.length > 0) {
                            console.log('Read Success');
                            res.send(items);
                        }
                        else {
                            console.log('Read data not found');
                            res.send("No Data");
                            //res.jsonp(200, ret);
                        }
                        if (err)
                            console.log('Read  Error: ' + err);
                    });


                });

            }
            break;
    }
};


