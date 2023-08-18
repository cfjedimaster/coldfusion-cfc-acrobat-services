<!---
An example of the Extract PDF API: https://developer.adobe.com/document-services/docs/overview/pdf-extract-api/
--->

<cfscript>
docpath = expandPath('../sourcefiles/adobe_security_thing.pdf');

asService = new acrobatservices(clientId=application.CLIENT_ID, clientSecret=application.CLIENT_SECRET);

asset = asService.createAsset(docpath);
writeoutput('<p>Uploaded asset id is #asset#</p>');


pollLocation = asService.createExtractJob(assetID=asset);
writeoutput('<p>Location to poll is #pollLocation#</p>');

done = false;
while(!done) {
	job = asService.getJob(pollLocation);
	writedump(var=job, label="Latest job status");
	cfflush();

	if(job.status == 'in progress') {
		sleep(2 * 1000);
	} else done = true;

}

/*
Unlike others, this API will always return two assets, content (just the JSON) and resource (the zip of stuff)
You could use CF's zip stuff to work with it.
*/


// So for this we'll save the JSON....
jsonpath = expandPath('../output/extract.json');
asService.downloadAsset(job.content, jsonpath);

// And also demo using cfhttp to get it, obviously don't do this if you've already downloaded
cfhttp(url=job.content.downloadUri, result="jsonRequest");
jsonResult = deserializeJSON(jsonRequest.filecontent);

// lets demo showing the headers
headers = jsonResult.elements.reduce((value, element) => {
	if(element.Path.find('H1')) value.append(element.Text);
	return value;
}, []);

writeDump(var=headers,label='Headers from PDF');

writeoutput('<p>All done!');
</cfscript>

