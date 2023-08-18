<!---
An example of the Combine PDF API: https://developer.adobe.com/document-services/docs/overview/pdf-services-api/howtos/combine-pdf/
--->

<cfscript>
docpath1 = expandPath('../sourcefiles/cats.pdf');
docpath2 = expandPath('../sourcefiles/adobe_security_thing.pdf');

asService = new acrobatservices(clientId=application.CLIENT_ID, clientSecret=application.CLIENT_SECRET);

asset1 = asService.createAsset(docpath1);
writeoutput('<p>Uploaded asset 1 id is #asset1#</p>');

asset2 = asService.createAsset(docpath2);
writeoutput('<p>Uploaded asset 2 id is #asset2#</p>');


pollLocation = asService.createCombineJob([ asset1, asset2 ]);
writeoutput('<p>Location to poll is #pollLocation#</p>');

done = false;
while(!done) {
	job = asService.getJob(pollLocation);
	writedump(var=job, label="Latest job status");

	if(job.status == 'in progress') {
		sleep(2 * 1000);
	} else done = true;

}

pdfpath = expandPath('../output/combined.pdf');
asService.downloadAsset(job.asset, pdfpath);
	
writeoutput('<p>All done with first example. Now building the second.'); cfflush();

// Now let's do a page range for one
pollLocation = asService.createCombineJob([ { assetID:asset1, pageRanges:[ { start: 4, end: 6}] } , asset2 ]);
writeoutput('<p>Location to poll is #pollLocation#</p>');

done = false;
while(!done) {
	job = asService.getJob(pollLocation);
	writedump(var=job, label="Latest job status");

	if(job.status == 'in progress') {
		sleep(2 * 1000);
	} else done = true;

}

pdfpath = expandPath('../output/combined2.pdf');
asService.downloadAsset(job.asset, pdfpath);
</cfscript>

