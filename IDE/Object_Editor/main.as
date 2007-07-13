// ActionScript file
/*
	Development by Vadim A. Usoltsev, SE Group Ltd., Tomsk, Russia, 2007.
*/
import mx.events.MenuEvent;
import mx.controls.Alert;
import mx.collections.*;
import mx.containers.Panel;
import mx.effects.Fade;
import flash.system.fscommand;
import mx.core.UIComponent;
import mx.containers.ViewStack;
import flash.net.URLLoader;
import flash.net.URLRequest;

public const ident_1:int = 150;
public const ident_2:int = 200;

[Bindable]
private var mainDataFile:XML;
[Bindable]
private var langStr:String = new String("RU");
[Bindable]		
private var menuBarCollection:XMLListCollection;
private var menubarXML:XMLList = new XMLList;
[Bindable]
private var attributesCollection:XMLListCollection;
 
/* **** Start() is the main function, that is being executed as soon as form created **** */
public function start():void {
	/* langRefresh() creating the main menu and setting up some global variables. It also applying multilanguage support */
	langRefresh();
	createBasicAttr();
}

private function addNewAttribute():void {
	/* addNewAttribute() Adding new empty Attribute to the Attributes list */
	attributesCollection.addItem (
		<attribute label="New Attribute" name="" defval="" regexp="" visined="" extended="" itype="">
			<dname><lang label="" text=""/></dname>
			<err><lang label="" text=""/></err>
			<descript><lang label="" text=""/></descript>
			<codeinterface></codeinterface>
		</attribute>
	);	
}

private function createBasicAttr():void {
	attributesCollection = new XMLListCollection();
	addNewAttribute();
}

private function attrFieldsRefresh():void {
	attrName.text = attrList.selectedItem.@name;
}

private function attrFieldsApply():void {
	attrList.selectedItem.@name = attrName.text;
	attrList.selectedItem.@label = attrName.text;
	Alert.show("Attribute's fields were sucessfully updated", "Apply");
	trace(attributesCollection);
}

private function lng(label:String):String {
	/* lng() used only in case to have short representation of such long string :) */
	/* Used in menu creation function langRefresh() */
	return langData.language.(@id == langStr).sentence.(@label == label).toString();
}

private function langRefresh():void {
	/* Setting up new (in new language) main menu items */
	menubarXML = 
	<>
		<menuitem label={lng('file')} data="file">
			<menuitem label={lng('lxml')} data="load" />
			<menuitem type="separator" data=""/>
			<menuitem label={lng('close')} data="close" />
		</menuitem>
		<menuitem label={lng('languages')} data="langs">
		</menuitem>
		<menuitem label={lng('help')} data="top">
			<menuitem label={lng('about')} data="about" />
		</menuitem>
	</>;	

	/* Adding the list of avaliable languages from the source XML to the Languages main menu item */
	for each(var language:XML in langData.language) {
		menubarXML.(@data == "langs").appendChild(<menuitem type="radio" label={language.@label} data={'lng' + language.@id} />);
	}

//	desc.text = menubarXML.(@data == "langs");

	/* Flushing the ComboBoxes from the text in previous language */
	ctgrsComboBox.text = "";
	itypeComboBox.text = "";
	if (objectInterfaceType != null) objectInterfaceType.text = "";
	if (stdInterfaceType != null) objectInterfaceType.text = "";

	/* Creating the main menu */
	menuBarCollection = new XMLListCollection(menubarXML);
}

private function menuHandler(event:MenuEvent):void {
	/* menuHandler() process menu click events */
	if (event.item.@data == "close") {
		mainForm.visible = false;
		fscommand("quit", "true");
	}
	if (event.item.@data == "about") {
		Alert.show("V.D.O.M. Object IDE v2.0\n\nDeveloped by SE GROUP, 2007", "About");
	}
	
	if (event.item.@data.substr(0, 3) == "lng") {
		/* Process changing current language */
		langStr = event.item.@data.substr(3, 2);
		langRefresh();
	}
}

private function checkInterface():void {
	if (objectInterfaceType.selectedItem.data == "Ext") {
		codeButton.enabled = true;
		stdInterfaceType.enabled = false;
	} else {
		codeButton.enabled = false;
		stdInterfaceType.enabled = true;
	}
}

private function checkStdInterfaceType():void {
	if (stdInterfaceType.selectedItem.data == "ExternalEditor") {
		currentState = "editorParams";
	} else {
		currentState = "";
	}
}