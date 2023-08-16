component accessors="true" {

	property name="clientId" type="string";
	property name="clientSecret" type="string";

	variables.REST_API = "https://pdf-services.adobe.io/";

	function init(clientId, clientSecret) {
		variables.clientId = arguments.clientId;
		variables.clientSecret = arguments.clientSecret;
		return this;
	}

	public function getAccessToken() {
		if(structKeyExists(variables, 'accessToken')) return variables.accessToken;
		var imsUrl = 'https://ims-na1.adobelogin.com/ims/token/v2?client_id=#variables.clientId#&client_secret=#variables.clientSecret#&grant_type=client_credentials&scope=openid,AdobeID,read_organizations';
		var result = '';
		
		cfhttp(url=imsUrl, method='post', result='result') {
			cfhttpparam(type='body', value='');
		};

		result = deserializeJSON(result.fileContent);
		variables.accessToken = result.access_token;
		return variables.accessToken;
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
		var token = getAccessToken();
		var result = '';
		var response = '';

		var body = {
			"assetID":arguments.assetID,
			"documentLanguage":arguments.documentLanguage
		};

		cfhttp(url=REST_API & '/operation/createpdf', method='post', result='result') {
			cfhttpparam(type='header', name='Authorization', value='Bearer #token#'); 
			cfhttpparam(type='header', name='x-api-key', value=variables.clientId); 
			cfhttpparam(type='header', name='Content-Type', value='application/json'); 
			cfhttpparam(type='body', value=serializeJSON(body));
		};

		if(result.responseheader.status_code == 201) return result.responseheader.location;
		else {
			response = deserializeJSON(result.filecontent);
			throw(message='Error response from server: ' & response.error.message);
		}

	}
	public function createDocGenJob(assetID, data, fragments={}, outputformat="pdf") {
		var token = getAccessToken();
		var result = '';

		var body = {
			"assetID":arguments.assetID,
			"outputFormat":arguments.outputformat, 
			"jsonDataForMerge":arguments.data,
			"fragments":arguments.fragments
		};

		cfhttp(url=REST_API & '/operation/documentgeneration', method='post', result='result') {
			cfhttpparam(type='header', name='Authorization', value='Bearer #token#'); 
			cfhttpparam(type='header', name='x-api-key', value=variables.clientId); 
			cfhttpparam(type='header', name='Content-Type', value='application/json'); 
			cfhttpparam(type='body', value=serializeJSON(body));
		};

		if(result.responseheader.status_code == 201) return result.responseheader.location;
		else {
			response = deserializeJSON(result.filecontent);
			throw(message='Error response from server: ' & response.error.message);
		}

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