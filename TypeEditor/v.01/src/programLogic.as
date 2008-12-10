// ActionScript file
import flash.events.Event;
import flash.filesystem.File;


private const newXMLDocument:XML = 
	<Type>
	    <Information>
	        <Name />
	        <DisplayName />
	        <XMLScriptName />
	        <Description />
	        <ClassName />
	        <ID />
	        <Icon />
	        <EditorIcon />
	        <StructureIcon />
	        <Moveable />
	        <Resizable />
	        <Container />
	        <Category />
	        <Dynamic />
	        <Version />
	        <InterfaceType />
	        <OptimizationPriority />
	        <WCAG />
	        <Containers />
	        <Languages />
	        <RenderType />
	        <RemoteMethods />
	        <Handlers />
	    </Information>
	    <Attributes />
	    <Languages />
	    <Resources />
	    <WCAG />
	    <SourceCode />
	    <Libraries />
	</Type>;

private const newAttribute:XML =
    <Attribute>
        <Name />
        <DisplayName />
        <DefaultValue />
        <RegularExpressionValidation />
        <ErrorValidationMessage />
        <Visible />
        <Help />
        <InterfaceType />
        <CodeInterface />
        <Colorgroup />
    </Attribute>;


private var xmlFile:File;
private var xmlFilter:FileFilter = new FileFilter("Vdom Object Type (*.xml)", "*.xml");
private var xmlDocument:XML = new XML(); 

private function loadXmlDocument():void
{
	xmlFile = new File();

	xmlFile.addEventListener(Event.SELECT, xmlFileSelected);
	try {
		xmlFile.browseForOpen("Choose VDOM Object Type Document", [xmlFilter]);
	}
	catch (err:Error) {
		xmlFile.removeEventListener(Event.SELECT, xmlFileSelected);
		return;
	}
}

private function xmlFileSelected(e:Event):void
{
	xmlFile.removeEventListener(Event.SELECT, xmlFileSelected);
	try {
		if (xmlFile && !xmlFile.isDirectory) {
			var srcBytes:ByteArray = new ByteArray();
			var srcStream:FileStream = new FileStream();
			
			try {
				srcStream.open(xmlFile, FileMode.READ);
				
				if (srcStream.bytesAvailable == 0) {
					Alert.show("File is empty", "Could not open document!");
					return; 
				}
				
				srcStream.readBytes(srcBytes, 0, srcStream.bytesAvailable);
				srcStream.close();
				
				xmlDocument = new XML(srcBytes);
			}
			catch (err:Error) {
				Alert.show('Could not open file!', 'IO Error');
				return;
			}
		}
	}
	catch (err:Error) { 
		return;
	}
	
	if (xmlDocument)
		parseXmlDocument();
}


private function parseXmlDocument():void {
	try {
		__objName.text = xmlDocument.Information.Name;	}
	catch (err:Error) {
		__objName.text = '';  }
	
	try {
		__objNameInXML.text = xmlDocument.Information.XMLScriptName;  }
	catch (err:Error) {
		__objNameInXML.text = '';  }
		
}