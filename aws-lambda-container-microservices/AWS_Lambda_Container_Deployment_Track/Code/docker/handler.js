const serverless = require('serverless-http');
const app = require('./appointment-service');
module.exports.handler = serverless(app);
