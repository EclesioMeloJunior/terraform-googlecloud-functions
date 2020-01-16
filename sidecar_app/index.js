const { Storage } = require("@google-cloud/storage");

async function app() {
	const storage = new Storage();

	const [files] = await storage.bucket(process.env.BUCKET).getFiles();

	files.forEach(file => console.log(file.name))
}

exports.app = app;
