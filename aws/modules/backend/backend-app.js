var AWS = require('aws-sdk');
var ddb = new AWS.DynamoDB({ apiVersion: '2012-08-10' });

exports.handler = async (event) => {
	try {
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