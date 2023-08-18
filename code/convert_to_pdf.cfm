<!---
An example of the Create PDF API: https://developer.adobe.com/document-services/docs/overview/pdf-services-api/howtos/create-pdf/
--->

<cfscript>
docpath = expandPath('../sourcefiles/cats.docx');

asService = new acrobatservices(clientId=application.CLIENT_ID, clientSecret=application.CLIENT_SECRET);

asset = asService.createAsset(docpath);
writeoutput('<p>Uploaded asset id is #asset#</p>');


pollLocation = asService.createConvertJob(asset);
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

pdfpath = expandPath('../output/cats.pdf');
asService.downloadAsset(job.asset, pdfpath);
	

writeoutput('<p>All done!');
</cfscript>

