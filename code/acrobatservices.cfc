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

	public function createConvertJob(assetID, documentLanguage="en-US") {

		var body = {
			"assetID":arguments.assetID,
			"documentLanguage":arguments.documentLanguage
		};

		return apiWrapper('/operation/createpdf', body);

	}

	public function createExportJob(assetID, targetFormat, ocrLang="en-US") {

		var body = {
			"assetID":arguments.assetID,
			"targetFormat":arguments.targetFormat,
			"ocrLang":arguments.ocrLang
		};

		return apiWrapper('/operation/exportpdf', body);

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