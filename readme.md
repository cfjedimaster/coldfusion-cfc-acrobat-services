# ColdFusion CFC for Adobe Acrobat Services

This is a simple ColdFusion wrapper for [Adobe Acrobat Services](https://developer.adobe.com/document-services/homepage). This CFC requires credentials (specifically new OAuth server to server credentials) that you can get here: <https://acrobatservices.adobe.com/dc-integration-creation-app-cdn/main.html> Note that while Acrobat Services is a commercial service, there is a free tier that lets you generate 500 transactions per month.

You can find the CFC in the [code](/code) folder along with demo files. Note that the `Application.cfc` file looks for `CLIENT_ID` and `CLIENT_SECRET` in the local environment. For my testing I used a `.env` file loaded via [CommandBox dotenv](https://www.forgebox.io/view/commandbox-dotenv).

Currently the list of supported endpoints is slim, but I'm hoping to add more over time. As always, PRs are welcome.

## Supported APIs

* [Document Generation](https://developer.adobe.com/document-services/apis/doc-generation/) - demo may be found in `code/documentgeneration.cfm`
* [Create PDF](https://developer.adobe.com/document-services/docs/overview/pdf-services-api/howtos/create-pdf/) - demo may be found in `code/convert_to_pdf.cfm`

## History

08/16/2033: Created the repository.