// The module 'vscode' contains the VS Code extensibility API
// Import the module and reference it with the alias vscode in your code below
const vscode = require('vscode');
var fs = require('fs');
var GameBoyAdvance = require('gbajs');

// This method is called when your extension is activated
// Your extension is activated the very first time the command is executed

class GBAEditorProvider {
	constructor(context) {
		this._context = context;

	}

	async openCustomDocument(uri, openContext, token) {
		return { uri }
		// You can return a custom document here
	}

	async resolveCustomEditor(document, webviewPanel, token) {
		// Setup initial content for the webview
		webviewPanel.webview.options = {
			enableScripts: true,
		};
		webviewPanel.webview.html = `<html><canvas id="screen" width="240" height="160" background-color="red"></canvas>Hello<p>${document.uri}</p></html>`


		var gba = new GameBoyAdvance();

		var canvas = webviewPanel.webview.getElementById('screen');
		gba.setCanvas(canvas);

		gba.logLevel = gba.LOG_ERROR;

		let biosURI = webviewPanel.webview.asWebviewUri(vscode.Uri.joinPath(this._context.extensionUri, 'node_modules', 'gbajs', 'resources', 'bios.bin'));
		const data = fs.readFileSync(biosURI.fsPath, { responseType: 'blob' });
		const buffer = Buffer.from(data);
		gba.setBios(buffer);

		gba.setCanvasMemory();

		gba.runStable();

		// gba.loadRomFromFile(document.uri, function (err, result) {
		// 	if (err) {
		// 		console.error('loadRom failed:', err);
		// 		process.exit(1);
		// 	}
		// 	gba.runStable();
		// });

		// var idx = 0;
		// setInterval(function () {
		// 	var keypad = gba.keypad;
		// 	keypad.press(keypad.A);

	}

}

/**
 * @param {vscode.ExtensionContext} context
 */
function activate(context) {

	// Use the console to output diagnostic information (console.log) and errors (console.error)
	// This line of code will only be executed once when your extension is activated
	console.log('Congratulations, your extension "ultimate-homebrew-gba-tools" is now active!');

	// The command has been defined in the package.json file
	// Now provide the implementation of the command with  registerCommand
	// The commandId parameter must match the command field in package.json
	const disposable = vscode.commands.registerCommand('ultimate-homebrew-gba-tools.helloWorld', function () {
		// The code you place here will be executed every time your command is executed

		// Display a message box to the user
		vscode.window.showInformationMessage('Hello World from ultimate-homebrew-gba-tools!');
	});

	context.subscriptions.push(disposable);

	vscode.window.registerCustomEditorProvider('ultimate-homebrew-gba-tools.editor', new GBAEditorProvider(context));

}

// This method is called when your extension is deactivated
function deactivate() { }

module.exports = {
	activate,
	deactivate
}