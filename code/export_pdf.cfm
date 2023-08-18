<!---
An example of the Export PDF API: https://developer.adobe.com/document-services/docs/overview/pdf-services-api/howtos/export-pdf/
--->

<cfscript>
docpath = expandPath('../sourcefiles/adobe_security_thing.pdf');

asService = new acrobatservices(clientId=application.CLIENT_ID, clientSecret=application.CLIENT_SECRET);

asset = asService.createAsset(docpath);
writeoutput('<p>Uploaded asset id is #asset#</p>');


pollLocation = asService.createExportJob(asset, 'docx');
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

wordpath = expandPath('../output/adobe_security_thing.docx');
asService.downloadAsset(job.asset, wordpath);
	

writeoutput('<p>All done!');
</cfscript>

