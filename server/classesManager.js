'use strict';

const {db, DATABASE_NAME} = require('./server');
/**
 * a map of the unique codes of classes to their name.
 * The purpose is for fast lookup of class codes, and to save the 
 * sockets of connected students.
 */
const classesMap = new Map();
/**
 * A map of the code and the class names.
 * This should be used for fast lookup of codes.
 */
const classes = {};


/**
 * Gets a unique code for a new class, and 
 * checks it against the existing classes.
 * @return {string} unique code for the new class.
 */
function getUniqueID()
{
    do{
        let code = Math.random().toString(36).substr(2,6);
    } while(Object.keys(classes).includes(code))

    return code;
}

/**
 * Create a unique class in the database and adds the class 
 * to the local map of the server.
 * @param {String} className 
 * @param {String} code the unique code to identify the class.
 */
function makeClass(className, code)
{
    // add the code to the local map
    classesMap.set(code, {className: className, sockets: []});
    //add the class to the database.
    db.createCollection(code).then();
    console.log(`A new collection has been created for ${className}`);
}

/**
 * Adds a question or an answer to the dialog of a specific class.
 * @param {String} code the code of the class to add the item to.
 * @param {String} item a question or an answer to be added to the dialog happining in class.
 */
function addDialogItem(code, item)
{
    if(!db) throw "Database is not connected";
    // check if a class with specific code exists.
    if(!Object.keys(classes).includes(code))
        throw `The code ${code} does not exist in current active classes.`;
    
    const particularCollection = db.collection(code);
    // add the item to the database.
    // TODO look into adding a call back to handle any error.
    particularCollection.insertOne({dialog: item});
}