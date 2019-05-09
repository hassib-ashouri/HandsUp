'use string';
const   JOIN_SESSION = 'join',
        DIALOG = 'dialog'
        TERMINATE_SESSION = 'terminate',
        LEAVE_SESSION = 'leave',
        UNIQUE_CODE = 'unique',
        DATABASE_NAME = 'HandsUp',
        REPLY = 'reply',
        CODE = 'code',
        JOIN_CONFIRMATION = 'join confirmed';

let {
    getUniqueID,
    makeClass,
    isActive,
    addDialogItem,
    addStudent,
    getEmails,
    getDialog,
    deleteClassWith,
    ERR_CLASS_DOES_NOT_EXIST,
} = require('./classesManager.js');
const nodemailer = require('nodemailer');
var transporter = nodemailer.createTransport({
    service: 'gmail',
    auth: {
      user: 'hassib291@gmail.com',
      pass: '159357258'
    }
  });

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
    this.emit(CODE, {code: uniqueCode});
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
    let emails = getEmails(code);
    let dialogPromise = getDialog(code);
    console.log(`Professor terminated session with code ${code}.\nIt has ${emails.length} emails`);
    if(emails.length > 0)
    {
        dialogPromise.then( dialogArr => {
            let dialog = dialogArr.reduce((acc, {dialog}) => acc += dialog + '\n', '');
            console.log(`DEBUGGING: dialog as a string ${dialog}`)
            var mailOptions = {
                from: 'hassib291@gmail.com',
                to: emails.toString(),
                subject: 'Sending Email using Node.js',
                text: dialog
            };
            
            transporter.sendMail(mailOptions, function(error, info){
                if (error) {
                    console.log(error);
                } else {
                    console.log('Email sent: ' + info.response);
                }
            });
        });
    }
    deleteClassWith(code);
    console.log(`deleted class with code ${code}`);
}

/**
 * This method will add an answer to the collection of questions and answers
 * in the data base.
 * @param {Object} data 
 * @param {String} data.code the code of the class to add the answer to.String
 * @param {String} data.dialog the answer or question to be added to the class
 */
function dialogListner({code, dialog})
{
    if(isActive(code))
        addDialogItem(code, `Dialog: ${dialog}`);
    else 
        console.log(`class with ${code} does not exist.`);
}

/**
 * handles leavesession events sent by a student. it will disconnect the socket for that student.
 * @param {Object} data 
 * @param {String} data.code the code of the class that the student is disconnecting from.
 * @param {string} data.id the id of the studen who is trying to disconnect.
 */
function leaveSessionListner({code})
{
    console.log(`Student left class with code ${code}`);
}

/**
 * Handles the event of a new student joining the class session.
 * It addes the new student to the current list of students.
 * @param {Object} data 
 * @param {String} data.code the code of the class to join.
 * @param {String} data.email the email of the student joining the class.Object
 */
function joinListner(data)
{
    // TODO consider handeling undefined input at this level vs lower level.
    try
    {
        addStudent(data.code, data.email, this);
        console.log("added to class", data.code, data.email);
        this.emit(REPLY, {message: `Student ${data.email} was added to class ${data.code}`});
        this.emit(JOIN_CONFIRMATION, {didJoin: true});
    }
    catch(e)
    {
        if(e == ERR_CLASS_DOES_NOT_EXIST)
        {
            console.log(`Class with code ${data.code} does not exist.`);
            this.emit(JOIN_CONFIRMATION, {didJoin: false})
        }
    }
    finally
    {
        console.log(`there is a problem with adding student ${data.email} to class with code ${data.code}`)
    }
}

module.exports = {
    joinListner : joinListner,
    leaveSessionListner : leaveSessionListner,
    dialogListner : dialogListner,
    terminateSessionListner : terminateSessionListner,
    uniqueCodeListner : uniqueCodeListner,
    JOIN_SESSION : JOIN_SESSION,
    DIALOG: DIALOG,
    TERMINATE_SESSION : TERMINATE_SESSION,
    LEAVE_SESSION : LEAVE_SESSION,
    UNIQUE_CODE : UNIQUE_CODE,
    DATABASE_NAME : DATABASE_NAME,
    JOIN_CONFIRMATION: JOIN_CONFIRMATION,
};
