'use strict';
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
    QUESTION
} = require('./handsup');


const server = require('http').createServer();
const io = require('socket.io')(server);
const MongoClient = require('mongodb').MongoClient;
const client = new MongoClient('mongodb://localhost:27071');


io.on('connection', socket => {
    console.log("New socket connection");
    // bind the events to thier listeners.
    socket.on(JOIN_SESSION, joinListner);
    socket.on(LEAVE_SESSION, leaveSessionListner);
    socket.on(UNIQUE_CODE, uniqueCodeListner);
    socket.on(TERMINATE_SESSION, terminateSessionListner);
    socket.on(ANSWER, answerListner);
    socket.on(QUESTION, questionListner);
});

server.listen(4000, () => console.log(`listening on port ${server.address().port}`));

// export the database client to be used my the classesmangaer.
export {client};