# ColdFusion CFC for Adobe Acrobat Services

This is a simple ColdFusion wrapper for [Adobe Acrobat Services](https://developer.adobe.com/document-services/homepage). This CFC requires credentials (specifically new OAuth server to server credentials) that you can get here: <https://acrobatservices.adobe.com/dc-integration-creation-app-cdn/main.html> Note that while Acrobat Services is a commercial service, there is a free tier that lets you generate 500 transactions per month.

You can find the CFC in the [code](/code) folder along with demo files. Note that the `Application.cfc` file looks for `CLIENT_ID` and `CLIENT_SECRET` in the local environment. For my testing I used a `.env` file loaded via [CommandBox dotenv](https://www.forgebox.io/view/commandbox-dotenv).

Currently the list of supported endpoints is slim, but I'm hoping to add more over time. As always, PRs are welcome.

For documentation on individual method arguments, check the [REST API documentation](https://developer.adobe.com/document-services/docs/apis/). While my code will have matching arguments, some are enums and will be listed the docs.

## Supported APIs

* [Auto-Tag PDF](https://developer.adobe.com/document-services/docs/overview/pdf-accessibility-auto-tag-api/) - demo may be found in `code/autotag_pdf.cfm`

* [Combine PDF](https://developer.adobe.com/document-services/docs/overview/pdf-services-api/howtos/combine-pdf/) - demo may be found in `code/combine_pdfs.cfm`

* [Compress PDF](https://developer.adobe.com/document-services/docs/overview/pdf-services-api/howtos/compress-pdf/) - demo may be found in `code/compress_pdf.cfm`

* [Create PDF](https://developer.adobe.com/document-services/docs/overview/pdf-services-api/howtos/create-pdf/) - demo may be found in `code/convert_to_pdf.cfm`

* [Create PDF from HTML](https://developer.adobe.com/document-services/docs/overview/pdf-services-api/howtos/create-pdf/#create-a-pdf-from-static-html) - demo may be found in `code/html_to_pdf.cfm`

* [Document Generation](https://developer.adobe.com/document-services/apis/doc-generation/) - demo may be found in `code/documentgeneration.cfm`

* [Export PDF](https://developer.adobe.com/document-services/docs/overview/pdf-services-api/howtos/export-pdf/) - demo may be found in `code/export_pdf.cfm`

* [Extract PDF](https://developer.adobe.com/document-services/docs/overview/pdf-extract-api/) - demo may be found in `code/extract_pdf.cfm`

* [OCR PDF](https://developer.adobe.com/document-services/docs/overview/pdf-services-api/howtos/ocr-pdf/) - demo may be found in `code/ocr_pdf.cfm`

* [Protect PDF](https://developer.adobe.com/document-services/docs/overview/pdf-services-api/howtos/protect-pdf/) - demo may be found in `code/protect_pdf.cfm`

## External Storage

In August of 2023, Adobe added 'external' file support to many of the APIs. This supports S3, Dropbox, Azure, and Sharepoint. It is not currently supported for a few of the APIs, but works in most. I've modified the core CFC to 'auto' 
detect when this is in use and built one demo, `code/external_test_1.cfm`. To use, create an asset structure like so:

```json
{
	"input":"readable url generated from S3, Dropbox, etc", 
	"output":"writable url generated from ..."
}
```

The CFC should automatically see this and handle it. Note the end result from the job will not have a location header as it's supplied by your input asset.

## ColdFusion Requirements

* Caching package.
* For the external support demo, the S3 package is required, but again, this is just the demo.

## History

| Date | Change |
|------|-----------|
| 09/07/2023 | Added initial support for external files |
| 08/18/2023 | Added Compressed, added cfflush to most demos |
| 08/18/2023 | Added Create from HTML, Protect PDF, Combine PDF |
| 08/16/2023 | Added Auto-Tag, Extract |
| 08/16/2023 | Updated access token caching strategy, added export and OCR, added apiWraper for job calls. |
| 08/16/2023 | Created the repository |
