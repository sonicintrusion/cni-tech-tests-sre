const app_name = "hello-world"
// the corret region should be pulled at deploy time rather than hardcoded
const aws_region = 'ap-southeast-2'

const express = require('express')
const app = express()
const router = express.Router()

var winston = require('winston'),
    WinstonCloudWatch = require('winston-cloudwatch');

// date used to rotate log streams - per day
let date = new Date().toISOString().split('T')[0];

// log to both console and cloudwatch logs
winston.loggers.add('awslogs', {
    transports: [
      new winston.transports.Console({
        json: true,
        colorize: true,
        level: 'info'
      }),
      new WinstonCloudWatch({
        logGroupName: '/app/' + app_name,
        logStreamName: app_name + '-' + date,
        awsRegion: aws_region
      })
    ]
});

var logit = winston.loggers.get('awslogs');
logit.info('Info message in log');
logit.error('ERROR logged to console and cloudwatch logs');

// this function can be used to pass in errors that will be logged out to both console and logs
function logerror(err,req,res,next) {
  logit.error(err)
  next()
}

// this function can be used to pass in all logging information
function logall(req,res,next) {
  logit.info(req.url)
  next()
}

router.get('/', (req, res) => {
    res.send('Hello World')
})

app.use('/', router)

const port = process.env.PORT || 3000
app.listen(port, () => {
    console.log(`Server started. Listening on port: ${port}`)
})