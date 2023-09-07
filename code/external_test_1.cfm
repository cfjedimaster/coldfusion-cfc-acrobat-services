<!---
This is the first test template that will see if I can get external support working well. It's
going to require Amazon S3 support.
--->

<cfscript>
system = createObject('java', 'java.lang.System');
	
awsCred = {
	vendorName:'AWS',
	region:'us-east-1',
	secretAccessKey:system.getProperty('SECRET_ACCESS_KEY'),
	accessKeyId:system.getProperty('ACCESS_KEY_ID')
};

s3Conf = {
	serviceName:'S3'
};
s3Service = getCloudService(awsCred, s3Conf);

bucket = s3Service.bucket('acrobatservices');

readUrl = bucket.generateGetPresignedUrl({
	key:'PlanetaryScienceDecadalSurvey.pdf',
	duration:'1h'
}).url;

writeUrl = bucket.generatePutPresignedUrl({
	key:'output_from_cf.docx',
	duration:'1h'
}).url;

writeOutput("We've generated a read URL for our input PDF (#readUrl#) and a writable URL (#writeUrl#) to store the result.");

/*
New shape for assets is a structure that must include input and output
*/
asset = {
	input: readUrl, 
	output: writeUrl
};

asService = new acrobatservices(clientId=application.CLIENT_ID, clientSecret=application.CLIENT_SECRET);

pollLocation = asService.createExportJob(asset);

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

writeOutput('<p>It is done, check the output location for the result. Have a nice day.');
</cfscript>