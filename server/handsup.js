'use string';
const   JOIN_SESSION = 'join',
        ANSWER = 'answer',
        QUESTION = 'question',
        TERMINATE_SESSION = 'terminate',
        LEAVE_SESSION = 'leave',
        UNIQUE_CODE = 'unique',
        DATABASE_NAME = 'HandsUp',
        REPLY = 'reply';

let {
    getUniqueID,
    makeClass,
    isActive,
    addDialogItem
} = require('./classesManager.js');

/**
 * This is the listner to 'getcode' event where the professor 
 * requests a unique code for a class, and makes a class in the database
 * itedtified by the unique code.
 * @param {Object} data an object that holds data about a new class.
 * @param {String} data.className this is the class name. 
 */
function uniqueCodeListner({className})
{
    // get the unique code
    let uniqueCode = getUniqueID();
    console.log(`Got a unique code ${uniqueCode}`);
    this.emit(REPLY, {
        message:`Unique code created sucessfully ${uniqueCode}`,
        code : uniqueCode
    });
    makeClass(className, uniqueCode);
}

/**
 * This should terminate the session in the database, and desconnect all
 * all the student connected to the server.
 * Then, start the process to send the session digest.
 * @param {Object} data 
 * @param {String} data.code the code for the class to be terminated.
 */
function terminateSessionListner({code})
{

}

/**
 * This method will add an answer to the collection of questions and answers
 * in the data base.
 * @param {Object} data 
 * @param {String} data.code the code of the class to add the answer to.String
 * @param {String} data.answer the answer to be added to the class
 */
function answerListner({code, answer})
{
    if(isActive(code))
        addDialogItem(code, `Answer: ${answer}`);
    else 
        console.log(`class with ${code} does not exist.`);
}

/**
 * This is the handler for any question events. adds the question to the databse
 * to the class specified by the code.
 * @param {Object} data
 * @param {String} data.code
 * @param {String} data.question
 */
function questionListner({code, question})
{

}

/**
 * handles leavesession events sent by a student. it will disconnect the socket for that student.
 * @param {Object} data 
 * @param {String} data.code the code of the class that the student is disconnecting from.
 * @param {string} data.id the id of the studen who is trying to disconnect.
 */
function leaveSessionListner({code})
{

}

/**
 * Handles the event of a new student joining the class session.
 * It addes the new student to the current list of students.
 * @param {Object} data 
 */
function joinListner(data)
{

}

module.exports = {
    joinListner : joinListner,
    leaveSessionListner : leaveSessionListner,
    questionListner : questionListner,
    answerListner : answerListner,
    terminateSessionListner : terminateSessionListner,
    uniqueCodeListner : uniqueCodeListner,
    JOIN_SESSION : JOIN_SESSION,
    ANSWER : ANSWER,
    QUESTION : QUESTION,
    TERMINATE_SESSION : TERMINATE_SESSION,
    LEAVE_SESSION : LEAVE_SESSION,
    UNIQUE_CODE : UNIQUE_CODE,
    DATABASE_NAME : DATABASE_NAME
};
