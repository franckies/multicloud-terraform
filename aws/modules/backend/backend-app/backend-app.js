var AWS = require('aws-sdk');
const https = require('https');
var ddb = new AWS.DynamoDB({ apiVersion: '2012-08-10' });

exports.handler = async (event) => {
	try {
		var multicloud = process.env["azure_api"] == "" ? false : true;

		// Handle GET request
		if (!event.body) {
			var params = {
				TableName: 'counter-app-table',
				Key: {
					id: { N: "1" } //read first element in the collection
				}

			};

			var data;

			try {
				data = await ddb.getItem(params).promise();
				console.log("Item read successfully:", data);
			} catch (err) {
				console.log("Error: ", err);
				data = err;
			}


			var response = {
				'statusCode': 200,
				headers: {
					"Content-Type": 'application/json',
					//"Access-Control-Allow-Headers" : "application/json",
					"Access-Control-Allow-Origin": "*",
					"Access-Control-Allow-Methods": "OPTIONS,POST,GET"
				},
				'body': JSON.stringify({
					message: data
				})
			};
		}
		//Handle POST request
		else {
			//Parse POST body
			var obj = JSON.parse(event.body);

			//Take number to insert into DB
			var counter_str = obj.counter;

			//Application logic
			var counter_num = parseInt(counter_str) + 1;
			counter_str = counter_num.toString()

			//Format DB input
			var params = {
				TableName: 'counter-app-table',
				Item: {
					id: { N: "1" },
					counter: { N: counter_str }
				}

			};

			var data;
			var msg;

			//Insert into DB
			try {
				data = await ddb.putItem(params).promise();
				console.log("Item entered successfully:", data);
				msg = 'Item entered successfully';
			} catch (err) {
				console.log("Error: ", err);
				msg = err;
			}


			// If multicloud is enable then sync aws azure cosmos db
			if (multicloud && obj.sender != 'azure') {
				await doPostRequest(counter_num-1) 
				.then(result => console.log(`Status code: ${result}`))
				.catch(err => console.error(`Error doing the request for the event: ${JSON.stringify(event)} => ${err}`));
			}
			var response = {
				'statusCode': 200,
				headers: {
					"Content-Type": 'application/json',
					//"Access-Control-Allow-Headers" : "application/json",
					"Access-Control-Allow-Origin": "*",
					"Access-Control-Allow-Methods": "OPTIONS,POST,GET"
				},
				'body': JSON.stringify({
					message: counter_str
				})
			};
		}
	} catch (err) {
		console.log(err);
		return err;
	}
	return response;
};


const doPostRequest = (counter) => {

	const data = JSON.stringify({
		counter: counter,
		sender: 'aws'
	})
	var azure_host = process.env["azure_api"].split("/");

	return new Promise((resolve, reject) => {
		const options = {
			hostname: azure_host[2],
			port: 443,
			path: '/' + azure_host[3],
			method: 'POST',
			headers: {
				'Content-Type': 'application/json',
				'Content-Length': data.length
			}
	  };
	  
	  //create the request object with the callback with the result
	  const req = https.request(options, (res) => {
		resolve(JSON.stringify(res.statusCode));
	  });
  
	  // handle the possible errors
	  req.on('error', (e) => {
		reject(e.message);
	  });
	  
	  //do the request
	  req.write(data);
  
	  //finish the request
	  req.end();
	});
  };