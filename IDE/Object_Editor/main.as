// ActionScript file
/*
	Development by Vadim A. Usoltsev, SE Group Ltd., Tomsk, Russia, 2007.
*/
import mx.events.MenuEvent;
import mx.events.CloseEvent;
import mx.controls.Alert;
import mx.collections.*;
import mx.containers.Panel;
import mx.effects.Fade;
import flash.system.fscommand;
import mx.core.UIComponent;
import mx.containers.ViewStack;
import flash.net.URLLoader;
import flash.net.URLRequest;
import mx.controls.TextArea;
import mx.containers.Canvas;

public const ident_1:int = 150;
public const ident_2:int = 200;
public const supLanguages:XMLList =
	<>
		<language label="EN" text="English"/>
		<language label="RU" text="Русский"/>
	</>;

[Bindable]
private var mainDataFile:XML;
[Bindable]
private var langStr:String = new String("RU");
[Bindable]		
private var menuBarCollection:XMLListCollection;
private var menubarXML:XMLList = new XMLList;
[Bindable]
private var attributesCollection:XMLListCollection;
private var previousAttr:int = -1;

/* Multilingual strings collections for each TextArea */
private var attrDnameCollector:Array = new Array();
private var attrErrmsgCollector:Array = new Array();
private var attrDescriptCollector:Array = new Array();

/* **** Start() is the main function, that is being executed as soon as form created **** */
public function start():void {
	/* langRefresh() creating the main menu and setting up some global variables. It also applying multilanguage support */
	langRefresh();
	createBasicAttr();
}

private function addNewAttribute():void {
	/* addNewAttribute() Adding new empty Attribute to the Attributes list */
	attributesCollection.addItem (
		<attribute label="New Attribute" name="New Attribute" defval="" regexp="" visined="0" extended="0" itype="">
			<dname></dname>
			<err></err>
			<descript></descript>
			<codeinterface></codeinterface>
		</attribute>
	);	
}

private function removeAttributeAlert():void {
	if (attrList.selectedIndex != -1) Alert.show("Do you want to proceed?", "Delete Attribute", 3, this, removeAttribute);
}

private function removeAttribute(event:CloseEvent):void {
	if (event.detail == Alert.YES) {
		attributesCollection.removeItemAt(attrList.selectedIndex);
		previousAttr = -1;
		panel1.visible = false;
	}
}

private function createBasicAttr():void {
	attributesCollection = new XMLListCollection();
	addNewAttribute();
}

private function attrFieldsWrite():void {
	var i:uint;
	var language:XML;
	
	if (previousAttr != -1) {
		with (attributesCollection[previousAttr]) {
			/* Writing basic simple properties */
			@name = attrName.text;
			@label = attrName.text;
			@defval = defValue.text;
			@regexp = regExpVld.text;
			@visined = Number(visinedChBox.selected);
			@extended = Number(extChBox.selected);
			@itype = attributeInterfaceType.selectedItem.data;

			/* Writing multilingual properties */
			i = 0;
			for each(language in supLanguages) {
				/* Display Name tabs */
				if (dname.lang.(@label == language.@label).toXMLString() == "")
					dname.appendChild(<lang label={language.@label} text={attrDnameCollector[i].text}/>);
				else
					dname.lang.(@label == language.@label).@text = attrDnameCollector[i].text;					
	
				/* Error Exp Validation Messages tabs */
				if (err.lang.(@label == language.@label).toXMLString() == "")
					err.appendChild(<lang label={language.@label} text={attrErrmsgCollector[i].text}/>);
				else
					err.lang.(@label == language.@label).@text = attrErrmsgCollector[i].text;					

				/* Attribute Description tabs */
				if (descript.lang.(@label == language.@label).toXMLString() == "")
					descript.appendChild(<lang label={language.@label} text={attrDescriptCollector[i].text}/>);
				else
					descript.lang.(@label == language.@label).@text = attrDescriptCollector[i].text;					
					
				i++;
			}
		}
	}
	
	trace(attributesCollection);
}

private function attrFieldsRefresh():void {
	/* Saving previous Attribute */
	attrFieldsWrite();
	
	/* Setting new Attribute as prevoius :) */
	previousAttr = attrList.selectedIndex;
	
	if (previousAttr != -1) {
		with (attributesCollection[previousAttr]) {
			/* Loading simple properties */
			attrName.text = @name;
			visinedChBox.selected = Number(@visined);
			extChBox.selected = Number(@extended);
	
			/* Loading multilingual properties */
			i = 0;
			for each(language in supLanguages) {
				/* Display Name tabs */
				attrDnameCollector[i].text = dname.lang.(@label == language.@label).@text;
	
				/* Error Exp Validation Messages tabs */
				attrErrmsgCollector[i].text = err.lang.(@label == language.@label).@text;

				/* Attribute Description tabs */
				attrDescriptCollector[i].text = descript.lang.(@label == language.@label).@text;					
					
				i++;
			}
		}
	}
	
	
	panel1.visible = true;
}

private function createAttrLangsTabs():void {
	var tab:Canvas;
	var textArea:TextArea;
	var i:uint;
	var language:XML;
		
	/* Display Name tabs */
	i = 0;
	for each(language in supLanguages) {
		tab = new Canvas();
		attrDnameCollector[i] = new TextArea();
		attrDnameCollector[i].height = 20;
		attrDnameCollector[i].percentWidth = 100;
		tab.label = language.@label;
		tab.addChild(attrDnameCollector[i]);
		dnameTabs.addChild(tab);
		i++;
	}

	/* Error Exp Validation Messages tabs */
	i = 0;
	for each(language in supLanguages) {
		tab = new Canvas();
		attrErrmsgCollector[i] = new TextArea();
		attrErrmsgCollector[i].height = 20;
		attrErrmsgCollector[i].percentWidth = 100;
		tab.label = language.@label;
		tab.addChild(attrErrmsgCollector[i]);
		errmsgTabs.addChild(tab);
		i++;
	}	

	/* Attribute Description tabs */
	i = 0;
	for each(language in supLanguages) {
		tab = new Canvas();
		attrDescriptCollector[i] = new TextArea();
		attrDescriptCollector[i].height = 60;
		attrDescriptCollector[i].percentWidth = 100;
		tab.label = language.@label;
		tab.addChild(attrDescriptCollector[i]);
		descriptTabs.addChild(tab);
		i++;
	}	
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
			<menuitem label={lng('lxml')} data="load"/>
			<menuitem type="separator" data=""/>
			<menuitem label={lng('close')} data="close"/>
		</menuitem>
		<menuitem label={lng('languages')} data="langs"></menuitem>
		<menuitem label={lng('help')} data="top">
			<menuitem label={lng('about')} data="about"/>
		</menuitem>
	</>;	

	/* Adding the list of avaliable _Interface_ languages from the source XML to the Languages main menu item */
	for each(var language:XML in langData.language) {
		menubarXML.(@data == "langs").appendChild(<menuitem type="radio" label={language.@label} data={'lng' + language.@id} />);
	}

	/* Flushing the ComboBoxes from the text in previous language */
	ctgrsComboBox.text = "";
	itypeComboBox.text = "";
	if (attributeInterfaceType != null) attributeInterfaceType.text = "";
	if (stdInterfaceType != null) stdInterfaceType.text = "";

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
	if (attributeInterfaceType.selectedItem.data == "Ext") {
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