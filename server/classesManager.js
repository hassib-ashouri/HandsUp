'use strict';
// load the function to grab the db instance from the server.
const getDb = require('./server.js').getDb;
const assert = require('assert');
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
    let code;
    do{
        code = Math.random().toString(36).substr(2,6);
    } while(Object.keys(classes).includes(code))

    return code.toString();
}

/**
 * Create a unique class in the database and adds the class 
 * to the local map of the server.
 * @param {String} className 
 * @param {String} code the unique code to identify the class.
 */
function makeClass(className, code)
{
    let db = getDb();
    if(!db) throw "Database is not connected";
    // add the code to the local map
    classes[code] = className;
    classesMap.set(code, {className: className, listeners: {}});
    //add the class to the database.
    db.createCollection(code);
    console.log(`A new collection has been created for ${className}`);
}

/**
 * Adds a question or an answer to the dialog of a specific class.
 * @param {String} code the code of the class to add the item to.
 * @param {String} item a question or an answer to be added to the dialog happining in class.
 */
function addDialogItem(code, item)
{
    let db = getDb();
    if(!db) throw "Database is not connected";
    
    // TODO look into adding a call back to handle any error.
    db.collection(code).insertOne({dialog: item});
    // log the event.
    console.log(`Dialog is added to ${code}: ${item}`);
}

/**
 * checks is a class with a specific code is active.
 * @param {String} code the code associated with a class
 */
function isActive(code)
{
    assert.ok(code,"Code to look for is unintialized.");
    return Object.keys(classes).includes(code);
}

module.exports = {
    getUniqueID : getUniqueID,
    makeClass : makeClass,
    isActive : isActive,
    addDialogItem : addDialogItem,
}