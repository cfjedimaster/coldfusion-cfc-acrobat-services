<!---
An example of the OCR PDF API: https://developer.adobe.com/document-services/docs/overview/pdf-services-api/howtos/ocr-pdf/
--->

<cfscript>
docpath = expandPath('../sourcefiles/pdf_that_needs_ocr.pdf');

asService = new acrobatservices(clientId=application.CLIENT_ID, clientSecret=application.CLIENT_SECRET);

asset = asService.createAsset(docpath);
writeoutput('<p>Uploaded asset id is #asset#</p>');


pollLocation = asService.createOCRJob(asset);
writeoutput('<p>Location to poll is #pollLocation#</p>');

done = false;
while(!done) {
	job = asService.getJob(pollLocation);
	writedump(var=job, label="Latest job status");

	if(job.status == 'in progress') {
		sleep(2 * 1000);
	} else done = true;

}

pdfpath = expandPath('../output/pdf_that_is_now_ocr.pdf');
asService.downloadAsset(job.asset, pdfpath);
	
writeoutput('<p>All done!');
</cfscript>

