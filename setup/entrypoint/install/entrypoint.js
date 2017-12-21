const { spawn, spawnSync } = require('child_process')
const path = require('path')
const moduleSystem = require('module')
const filesystem = require('fs');

// // add root path (app base path) to the resolved module paths.
// // Define server base path. Hackish way to make sure the path is always consistent. Base path in Nodejs is where the closest parent node_modules is located to the initiated js script.
// process.env.NODE_PATH = `${process.env.NODE_PATH || ''}:${nodeModuleFolderPath}`.replace(/(^\:+)/, '')
// console.log(`• Node additional module resolution paths: ${process.env.NODE_PATH}`)
// moduleSystem._initPaths()  

// Run app
require('./app.js')


