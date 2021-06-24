module.exports = async function (context, req) {
    try {

        context.log('JavaScript HTTP trigger function processed a request.');
        var responseMessage = "";
        // Read aws api gateway url and set multicloud variable as a consequence.
        var multicloud = process.env["aws_api"] == "" ? false : true;
        // If no counter exists, insert it.
        if (context.bindings.inputDocument.length == 0) {
            context.bindings.outputDocument = JSON.stringify({
                id: "1",
                counter: 1
            });

            // If multicloud is enable then sync aws dynamo db
            if (multicloud) {
                doPostRequest(1);
            }

            responseMessage = JSON.stringify({
                message: "1"
            });
            return
        }
        // If counter already exists than handle request

        const counter = (req.query.counter || (req.body && req.body.counter));
        var inCounter = context.bindings.inputDocument[0].counter;

        // Handle POST request 
        if (counter) {
            context.bindings.outputDocument = JSON.stringify({
                id: "1",
                counter: (parseInt(counter) + 1).toString() // Here we could enforce sequential counting by using inCounter+1
            });
            responseMessage = JSON.stringify({
                message: (parseInt(counter) + 1).toString()
            });

            // If multicloud is enable then sync aws dynamo db
            if (multicloud && req.body.sender != 'aws') {
                doPostRequest(parseInt(counter));
            }

            context.res = {
                // status: 200, /* Defaults to 200 */
                body: responseMessage
            };
            return;
        }
        // Handle GET request
        else {
            // Set response message to be compatible with AWS one.
            responseMessage = JSON.stringify({
                message: {
                    Item: {
                        counter: {
                            N: (inCounter).toString()
                        }
                    }
                }
            });
            context.res = {
                // status: 200, /* Defaults to 200 */
                body: responseMessage
            };
            return;
        }
    }
    catch (err) {
        console.log(err)
    }
}

const doPostRequest = (counter) => {
    const https = require('https')

    const data = JSON.stringify({
        counter: counter,
        sender: 'azure'
    })
    var aws_host = process.env["aws_api"].split("/");
    const options = {
        hostname: aws_host[2],
        port: 443,
        path: '/' + aws_host[3] + '/counter-app-resource',
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'Content-Length': data.length
        }
    }

    const request = https.request(options, res => {
        console.log(`statusCode: ${res.statusCode}`)

        res.on('data', d => {
            process.stdout.write(d)
        })
    })

    request.on('error', error => {
        console.error(error)
    })

    request.write(data)
    request.end()
}