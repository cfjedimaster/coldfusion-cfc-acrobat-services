<!---
An example of the Autotag PDF API: https://developer.adobe.com/document-services/docs/overview/pdf-accessibility-auto-tag-api/
--->

<cfscript>
docpath = expandPath('../sourcefiles/adobe_security_thing.pdf');

asService = new acrobatservices(clientId=application.CLIENT_ID, clientSecret=application.CLIENT_SECRET);

asset = asService.createAsset(docpath);
writeoutput('<p>Uploaded asset id is #asset#</p>');


pollLocation = asService.createAutoTagJob(assetID=asset, generateReport=true);
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
Unlike other demos, this API can return either just the tagged pdf or a report. 
The job result will have a "tagged-pdf" key always that can be passed to downloadAsset
If reports are wanted, it will be in 'report'.
*/

pdfpath = expandPath('../output/pdf_that_is_now_tagged.pdf');
asService.downloadAsset(job['tagged-pdf'], pdfpath);

reportpath = expandPath('../output/pdf_that_is_now_tagged.xlsx');
asService.downloadAsset(job.report, reportpath);

writeoutput('<p>All done!');
</cfscript>

