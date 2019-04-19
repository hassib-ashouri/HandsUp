'use strict';
// export the database db connection to be used my the classesmangaer.
/**
 * the vriable holding the reference to that database 'HandsUp'
 * @type {Db}
 */
let db;
module.exports = {
    getDb : () => db,
};
const {
    answerListner,
    questionListner,
    uniqueCodeListner,
    joinListner,
    leaveSessionListner,
    terminateSessionListner,
    JOIN_SESSION,
    LEAVE_SESSION,
    UNIQUE_CODE,
    TERMINATE_SESSION,
    ANSWER,
    QUESTION,
    DATABASE_NAME
} = require('./handsup');


const server = require('http').createServer();
const io = require('socket.io')(server);
const MongoClient = require('mongodb').MongoClient;
const client = new MongoClient('mongodb://localhost:27017',{useNewUrlParser: true});


io.on('connection', socket => {
    console.log(`New socket connection ${socket.id}`);
    // bind the events to thier listeners.
    socket.on(JOIN_SESSION, joinListner);
    socket.on(LEAVE_SESSION, leaveSessionListner);
    socket.on(UNIQUE_CODE, uniqueCodeListner);
    socket.on(TERMINATE_SESSION, terminateSessionListner);
    socket.on(ANSWER, answerListner);
    socket.on(QUESTION, questionListner);
});


// connect to the database then start the server.
client.connect((err, client) => {
    if(err) throw err;
    db = client.db(DATABASE_NAME);
    if(db) console.log('connected to database');
    server.listen(4000, () => console.log(`listening on port ${server.address().port}`));
});
