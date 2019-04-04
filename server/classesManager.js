'use strict';

const classesMap = new Map();
const classes = [];

function getUniqueID()
{
    do{
        let code = Math.random().toString(36).substr(2,6);
    } while(classesMap.keys().includes(code))

    return code;
}

function makeClass(className, code)
{

}