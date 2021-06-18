module.exports = async function (context, req) {
    context.log('JavaScript HTTP trigger function processed a request.');
    var responseMessage = "";

    // If no counter exists, insert it.
    if (context.bindings.inputDocument.length == 0) {
        context.bindings.outputDocument = JSON.stringify({
            id: "1",
            counter: 1
        });
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
                Item : {
                    counter : {
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
