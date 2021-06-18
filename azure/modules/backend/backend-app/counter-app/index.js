module.exports = async function (context, req) {
    context.log('JavaScript HTTP trigger function processed a request.');

    const counter = (req.query.counter || (req.body && req.body.counter));
    const responseMessage = "";

    // Handle POST request
    if (counter) {
        context.bindings.outputDocument = JSON.stringify({
            // create a random ID
            id: "1",
            counter: parseInt(counter) + 1
        });
        responseMessage = "{message: " + (parseInt(counter)+1).toString() + "}";
    }
    // Handle GET request
    else {
    }

    context.res = {
        // status: 200, /* Defaults to 200 */
        body: responseMessage
    };
}