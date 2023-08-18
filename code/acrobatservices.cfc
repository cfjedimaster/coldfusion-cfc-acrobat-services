component accessors="true" {

	property name="clientId" type="string";
	property name="clientSecret" type="string";

	variables.REST_API = "https://pdf-services.adobe.io/";

	function init(clientId, clientSecret) {
		variables.clientId = arguments.clientId;
		variables.clientSecret = arguments.clientSecret;

		/*
		I'm going to cache my access token for 23 hours using CF's cache stuff, but want to ensure
		I don't conflict with any other instance of this CFC. So our cache key will be based on my
		name + a UUID
		*/
		variables.cacheKey = 'acrobatservices_#createUUID()#';

		return this;
	}

	/*
	I wrap the api calls, but just the job ones for now. May revisit.
	*/
	private function apiWrapper(endpoint, body) {
		var token = getAccessToken();
		var result = '';
		var response = '';

		cfhttp(url=REST_API & arguments.endpoint, method='post', result='result') {
			cfhttpparam(type='header', name='Authorization', value='Bearer #token#'); 
			cfhttpparam(type='header', name='x-api-key', value=variables.clientId); 
			cfhttpparam(type='header', name='Content-Type', value='application/json'); 
			cfhttpparam(type='body', value=serializeJSON(arguments.body));
		};

		if(result.responseheader.status_code == 201) return result.responseheader.location;
		else {
			response = deserializeJSON(result.filecontent);
			throw(message='Error response from server: ' & response.error.message);
		}
	}

	public function getAccessToken() {
		//if(structKeyExists(variables, 'accessToken')) return variables.accessToken;
		var existingToken = cacheGet(variables.cacheKey);
		if(!isNull(existingToken)) return existingToken;

		var imsUrl = 'https://ims-na1.adobelogin.com/ims/token/v2?client_id=#variables.clientId#&client_secret=#variables.clientSecret#&grant_type=client_credentials&scope=openid,AdobeID,read_organizations';
		var result = '';
		
		cfhttp(url=imsUrl, method='post', result='result') {
			cfhttpparam(type='body', value='');
		};

		result = deserializeJSON(result.fileContent);
		cachePut(cacheKey, result.access_token, createTimeSpan(0,23,0,0));
		return result.access_token;
	}

	/*
	I wrap the logic of creating and uploading an asset path
	*/
	public function createAsset(path) {
		var result = '';
		var token = getAccessToken();
		var mimeType = fileGetMimeType(arguments.path);

		var body = {
			"mediaType": mimeType
		};
		body = serializeJSON(body);

		cfhttp(url=REST_API & '/assets', method='post', result='result') {
			cfhttpparam(type='header', name='Authorization', value='Bearer #token#'); 
			cfhttpparam(type='header', name='x-api-key', value=variables.clientId); 
			cfhttpparam(type='header', name='Content-Type', value='application/json'); 
			cfhttpparam(type='body', value=body);
		}
		var assetInfo = deserializeJSON(result.fileContent);

		cfhttp(url=assetInfo.uploadUri, method='put', result='result') {
			cfhttpparam(type='body', value=fileReadBinary(arguments.path));
			cfhttpparam(type='header', name='Content-Type', value=mimeType); 
		}

		if(result.responseheader.status_code == 200) return assetInfo.assetID;
		else throw('Unknown error');
	}

	public function downloadAsset(assetOb, path) {
		var result = "";
		var dir = getDirectoryFromPath(arguments.path);
		var filename = getFileFromPath(arguments.path);
		cfhttp(method="get", url=arguments.assetOb.downloadUri, getasbinary=true, result="result", path=dir, file=filename);
	}

	public function createAutoTagJob(assetID, shiftHeadings=false, generateReport=false) {

		var body = {
			"assetID":arguments.assetID,
			"shiftHeadings":arguments.shiftHeadings, 
			"generateReport":arguments.generateReport
		};

		return apiWrapper('/operation/autotag', body);
	}

	public function createCombineJob(required array assets) {

		/*
		So the combine API lets you pass an array of assets where each asset may have a property called
		'pageRanges' which is an array of objects with start and end values. I think for now we will just
		take in the user input - may add validation later.

		Nope, need to rewrite the input. Leaving these comments here as I think I may need to come back to it later.
		*/
		var body = {
			"assets": []
		};

		arguments.assets.each(b => {
			if(isSimpleValue(b)) body["assets"].append({ "assetID": b });
			else {
				var newA = {
					"assetID":b.assetID, 
					"pageRanges":[]
				};
				b.pageRanges.each(p => {
					newA.pageRanges.append({
						"start":p.start, 
						"end":p.end
					})
				});
				body["assets"].append(newA);
			}
		});

		return apiWrapper('/operation/combinepdf', body);
	}

	public function createConvertJob(assetID, documentLanguage="en-US") {

		var body = {
			"assetID":arguments.assetID,
			"documentLanguage":arguments.documentLanguage
		};

		return apiWrapper('/operation/createpdf', body);
	}

	public function createConvertHTMLJob(assetID="", inputUrl="", json="", includeHeaderFooter=false, pageLayout={}) {

		/*
		This one is a bit more complex as asset can be blank and inputUrl can be passed.
		*/
		var body = {};

		if(assetID != "") body["assetID"] = arguments.assetID;
		else if(inputUrl != "") body["inputUrl"] = arguments.inputUrl;
		else throw("Either assetID or inputUrl must be passed.");

		if(arguments.json != "") body["json"] = arguments.json;
		body["includeHeaderFooter"] = arguments.includeHeaderFooter;
		if(!structIsEmpty(arguments.pageLayout)) body["pageLayout"] = arguments.pageLayout;

		return apiWrapper('/operation/htmltopdf', body);
	}

	public function createDocGenJob(assetID, data, fragments={}, outputformat="pdf") {

		var body = {
			"assetID":arguments.assetID,
			"outputFormat":arguments.outputformat, 
			"jsonDataForMerge":arguments.data,
			"fragments":arguments.fragments
		};

		return apiWrapper('/operation/documentgeneration', body);
	}

	public function createExportJob(assetID, targetFormat, ocrLang="en-US") {

		var body = {
			"assetID":arguments.assetID,
			"targetFormat":arguments.targetFormat,
			"ocrLang":arguments.ocrLang
		};

		return apiWrapper('/operation/exportpdf', body);
	}

	public function createExtractJob(assetID, getCharBounds=false, includeStyling=false, elementsToExtract=["text"], tableOutputFormat="xlsx", renditionsToExtract=[]) {

		var body = {
			"assetID":arguments.assetID,
			"getCharBounds":arguments.getCharBounds, 
			"includeStyling":arguments.includeStyling,
			"elementsToExtract":arguments.elementsToExtract, 
			"tableOutputFormat":arguments.tableOutputFormat,
			"renditionsToExtract":arguments.renditionsToExtract
		};

		return apiWrapper('/operation/extractpdf', body);
	}

	public function createOCRJob(assetID, ocrLang="en-US", ocrType="searchable_image") {

		var body = {
			"assetID":arguments.assetID,
			"ocrLang":arguments.ocrLang,
			"ocrType":arguments.ocrType
		};

		return apiWrapper('/operation/ocr', body);
	}

	public function createProtectJob(assetID, ownerPassword="", userPassword="", encryptionAlgorithm, contentToEncrypt="ALL_CONTENT", permissions = []) {

		if(arguments.ownerPassword == "" and arguments.userPassword == "") {
			cfthrow(message="You must pass either ownerPassword or userPassword.");
		}

		var body = {
			"assetID":arguments.assetID
		};

		if(arguments.ownerPassword != "") {
			body["passwordProtection"] = { "ownerPassword": arguments.ownerPassword };
		} else {
			body["passwordProtection"] = { "userPassword": arguments.userPassword };
		}

		body["encryptionAlgorithm"] = arguments.encryptionAlgorithm;
		body["contentToEncrypt"] = arguments.contentToEncrypt;
		if(!arrayIsEmpty(arguments.permissions)) body["permissions"] = arguments.permissions;
		return apiWrapper('/operation/protectpdf', body);
	}

	public function getJob(jobUrl) {
		var token = getAccessToken();
		var result = '';

		cfhttp(url=jobUrl, method='get', result='result') {
			cfhttpparam(type='header', name='Authorization', value='Bearer #token#'); 
			cfhttpparam(type='header', name='x-api-key', value=variables.clientId); 
		};

		result = deserializeJSON(result.fileContent);
		return result;
	}	

}