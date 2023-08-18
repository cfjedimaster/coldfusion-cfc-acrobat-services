<!---
An example of the Create PDF from HTML API: https://developer.adobe.com/document-services/docs/overview/pdf-services-api/howtos/create-pdf/#create-a-pdf-from-static-html
--->

<cfscript>
docpath = expandPath('../sourcefiles/input.html');

asService = new acrobatservices(clientId=application.CLIENT_ID, clientSecret=application.CLIENT_SECRET);

asset = asService.createAsset(docpath);
writeoutput('<p>Uploaded asset id is #asset#</p>');


pollLocation = asService.createConvertHTMLJob(asset);
writeoutput('<p>Location to poll is #pollLocation#</p>');

done = false;
while(!done) {
	job = asService.getJob(pollLocation);
	writedump(var=job, label="Latest job status");

	if(job.status == 'in progress') {
		sleep(2 * 1000);
	} else done = true;

}

pdfpath = expandPath('../output/fromhtml1.pdf');
asService.downloadAsset(job.asset, pdfpath);

writeoutput('<p>Done, now trying a Url example.</p>');
cfflush();

// Now try input URL
pollLocation = asService.createConvertHTMLJob(inputUrl = 'https://www.google.com');

done = false;
while(!done) {
	job = asService.getJob(pollLocation);
	writedump(var=job, label="Latest job status");

	if(job.status == 'in progress') {
		sleep(2 * 1000);
	} else done = true;

}

pdfpath = expandPath('../output/fromhtml2.pdf');
asService.downloadAsset(job.asset, pdfpath);

writeoutput('<p>All done!');
</cfscript>

