// ActionScript file
/* Data Providers */

[Bindable] private var langsProvider:Array = []; // of { label:langStr }

private var attrsProvider:Array = [];

/**
 * Attribute property include following values:
 * 
 * attrsProvider:
 *  |
 *  |--[0]
 *  |   |--label = 'New Attribute' (attr Name)
 *  |   |--defValue = ''
 *  |   |--regExValidationStr = ''
 *  |   |--interfaceType = 0
 *  |   |--colorGroup = 1
 *  |   |--codeInterface = 'textfield' 
 *  |   |--visible = 1 
 *  |   |
 *  |   |--[attrDispName]
 *  |   |   |--languageField = str
 *  |   |   '--languageField = str
 *  |   |
 *  |   |--[regExValidationErrStr]
 *  |   |   |--languageField = str
 *  |   |   '--languageField = str
 *  |   |
 *  |   |--textFieldLength = 0
 *  |   |--objectListTypeId = ''
 *  |   |--numberMinValue = 0
 *  |   |--numberMaxValue = 0
 *  |   |--multiLineLength = 0
 *  |   |
 *  |   |--externalEditorTitle
 *  |   |   |--languageField = str
 *  |   |   '--languageField = str
 *  |   |
 *  |   |--externalEditorInfo = ''
 *  |   |
 *  |   |--[dropDownValues]
 *  |   |   |--0 = value
 *  .   |   |--1 = value
 *  .   |   '--2 = value
 *  .   |   ...
 *      |
 *      '--[dropDownStrings]
 *          '--[languageField]
 *              |--0 = str
 *              |--1 = str
 *              '--2 = str
 *              ...
 * 
 **/ 

private var resourcesProvider:Array = [];

/**
 * resourcesPrivoder has structure:
 * 
 * resourcesProvider:
 *  |
 *  |--[0]
 *  |   |--resourceid = GUID
 *  |   |--name = ''
 *  |   |--data = [] (base64 source)
 *  |   |--size = 0
 *  |   '--type = ''
 *  |
 *  ...
 * 
 **/

private var objDisplayName:Array = [];
private var objDescription:Array = [];

 

