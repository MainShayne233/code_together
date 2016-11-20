
export default callback => {
	var MongoClient = require('mongodb').MongoClient
	var URL = process.env.MONGO_URI
	if (!URL) {
		console.log("MONGO_URI env not specified")
		console.log("Running, but not connected to db.")
		callback()
	} else if (URL.substring(0,10) !== 'mongodb://') {
		console.log("Improper MONGO_URI")
		console.log("Must be in form of: mongodb://{hostname}:{port}/{dbname}")
		console.log("Running, but not connected to db.")
		callback()
	} else {
		MongoClient.connect(URL, function(err, db) {
		  if (err) {
				console.log("Issue trying to connect to db with specified MONGO_URI", err)
				console.log("Runniong, but not connected to db.")
				callback()
			} else {
				console.log("Successfully connected to db.")
				callback(db);
			}
		})
	}
}
