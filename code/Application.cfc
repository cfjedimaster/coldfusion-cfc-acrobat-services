component {

	this.name = 'aas_demo';

	this.serialization = {
		preserveCaseForStructKey: true
	};

	void function onApplicationStart() {

		var system = createObject('java', 'java.lang.System');
		application.CLIENT_ID = system.getProperty('CLIENT_ID');
		application.CLIENT_SECRET = system.getProperty('CLIENT_SECRET');
	
	}
}