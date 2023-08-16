<!---
An example of the Document Generation API: https://developer.adobe.com/document-services/apis/doc-generation/
--->

<!---
Note that while an array of structs is used, a query would be just fine too:
<cfquery name="prospectives" datasource="demo">
select id, firstName, lastName, position, salary, state from prospectives
</cfquery>
--->
<cfset prospectives = [
	{ "id": 1, "firstName": "Raymond", "lastName": "Camden", "position": "Nobody Important", "salary": 100000, "state":"Louisiana" }, 
	{ "id": 2, "firstName": "Lindy", "lastName": "Camden", "position": "Queen", "salary": 900000, "state":"Louisiana" }, 
	{ "id": 3, "firstName": "Jacob", "lastName": "Camden", "position": "Philosopher", "salary": 1200000, "state":"Washington" }	
]>

<cfscript>
docpath = expandPath('../sourcefiles/offer.docx');

asService = new acrobatservices(clientId=application.CLIENT_ID, clientSecret=application.CLIENT_SECRET);

asset = asService.createAsset(docpath);
writeoutput('<p>Uploaded asset id is #asset#</p>');

for(person in prospectives) {

	/*
	Case matters for Document Generation, so let's 'reshape' person
	*/
	personOb = {
		"firstName": person.firstName, 
		"lastName": person.lastName, 
		"position": person.position,
		"salary": person.salary, 
		"state": person.state
	}
	
	pollLocation = asService.createDocGenJob(asset, personOb);
	writeoutput('<p>Location to poll is #pollLocation#</p>');

	done = false;
	while(!done) {
		job = asService.getJob(pollLocation);
		writedump(var=job, label="Latest job status");

		if(job.status == 'in progress') {
			sleep(2 * 1000);
		} else done = true;

	}

	// assume good
	pdfpath = expandPath('../output/result#person.id#.pdf');
	asService.downloadAsset(job.asset, pdfpath);
	
}

writeoutput('<p>All done!');
</cfscript>

