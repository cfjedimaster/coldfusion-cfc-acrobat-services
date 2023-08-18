<!---
An example of the Protect PDF API: https://developer.adobe.com/document-services/docs/overview/pdf-services-api/howtos/protect-pdf/
--->

<cfscript>
docpath = expandPath('../sourcefiles/adobe_security_thing.pdf');

asService = new acrobatservices(clientId=application.CLIENT_ID, clientSecret=application.CLIENT_SECRET);

asset = asService.createAsset(docpath);
writeoutput('<p>Uploaded asset id is #asset#</p>');

// First example, just add a password
pollLocation = asService.createProtectJob(assetID=asset, userPassword="meow", encryptionAlgorithm="AES_256");
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

pdfpath = expandPath('../output/pdf_that_needs_password.pdf');
asService.downloadAsset(job.asset, pdfpath);
	
writeoutput('<p>Done with first example, now locking down printing.');
cfflush();

// This should block printing, copying content, and more
pollLocation = asService.createProtectJob(assetID=asset, ownerPassword="meow", encryptionAlgorithm="AES_256", permissions=['EDIT_ANNOTATIONS']);
writeoutput('<p>Location to poll is #pollLocation#</p>');

done = false;
while(!done) {
	job = asService.getJob(pollLocation);
	writedump(var=job, label="Latest job status");

	if(job.status == 'in progress') {
		sleep(2 * 1000);
	} else done = true;

}

pdfpath = expandPath('../output/pdf_that_needs_password2.pdf');
asService.downloadAsset(job.asset, pdfpath);


</cfscript>

