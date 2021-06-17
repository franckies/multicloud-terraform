module.exports = async function (context, req) {
    context.log('JavaScript HTTP trigger function processed a request.');

    const counter = (req.query.counter || (req.body && req.body.counter));
    const responseMessage = counter
        ? "Hello, " + counter + ". This HTTP triggered function executed successfully."
        : "This HTTP triggered function executed successfully. Pass a counter in the query string or in the request body for a personalized response.";

    if (counter) {
        context.bindings.outputDocument = JSON.stringify({
            // create a random ID
            id: "1",
            counter: parseInt(counter)+1
        });
    }

    context.res = {
        // status: 200, /* Defaults to 200 */
        body: responseMessage
    };
}