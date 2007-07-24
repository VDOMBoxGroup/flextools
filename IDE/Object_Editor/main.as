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
import mx.containers.TabNavigator;

public const ident_1:int = 150;
public const ident_2:int = 200;
public const supLanguages:XML = 
	<root>
		<language label="" text=""/>
	</root>;

[Bindable]
private var mainDataFile:XML;
[Bindable]
private var langStr:String = new String("EN");
[Bindable]		
private var menuBarCollection:XMLListCollection;
private var menubarXML:XMLList = new XMLList;
[Bindable]
private var attributesCollection:XMLListCollection;
private var previousAttr:int = -1;
[Bindable]
private var objectXML:XML;
private var language:XML = new XML();  /* used in For Each cycles */
private var attribute:XML = new XML();  /* used in For Each cycles */
private var lang_id:int = 100;

/* Multilingual strings collections for each TextArea */
private var infoDnameCollector:Array = new Array();
private var infoDescriptCollector:Array = new Array();
private var attrDnameCollector:Array = new Array();
private var attrErrmsgCollector:Array = new Array();
private var attrDescriptCollector:Array = new Array();

public function start():void {
/* **** Start() is the main function, that is being executed as soon as form created **** */

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
		attributesPanel.visible = false;
	}
}

private function createBasicAttr():void {
	attributesCollection = new XMLListCollection();
	addNewAttribute();
}

private function attrFieldsWrite():void {
/* attrFieldsWrite() writes the data from Attribute Form Fields to the XML in memory */

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
			/* Removed with new XML specification *
			@extended = Number(extChBox.selected);
			*/
			@itype = attributeInterfaceType.selectedItem.data;

			/* Writing multilingual properties */
			i = 0;
			for each(language in supLanguages.language) {
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
}

private function attrFieldsWriteNRefresh():void {
	/* Saving previous Attribute */
	attrFieldsWrite();
	
	/* Setting new Attribute as prevoius :) */
	previousAttr = attrList.selectedIndex;
	
	attrFieldsRefresh();
}

private function attrFieldsRefresh():void {	
/* attrFieldsRefresh() fills in Attribite properties fields with Attribute information from XML in memory */

	if (previousAttr != -1) {
		with (attributesCollection[previousAttr]) {
			/* Loading simple properties */
			attrName.text = @name;
			defValue.text = @defval;
			regExpVld.text = @regexp;
			visinedChBox.selected = Number(@visined);
			
			/* Removed with new XML specification *
			extChBox.selected = Number(@extended);
			*/
			
			if (@itype == "Std") attributeInterfaceType.selectedIndex = 0;
			if (@itype == "Ext") attributeInterfaceType.selectedIndex = 1;
	
			/* Loading multilingual properties */
			i = 0;
			for each(language in supLanguages.language) {
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
	
	if (attributesPanel != null) attributesPanel.visible = true;
}

private function createLangsTabsAt(viewForm:Object, Collector:Array, txtHeight:int):void {
	var tab:Canvas;
	var textArea:TextArea;
	var i:uint;
	var language:XML;
	if (viewForm != null) {
		i = 0;
		for each(language in supLanguages.language) {
			tab = new Canvas();
			Collector[i] = new TextArea();
			Collector[i].height = txtHeight;
			Collector[i].percentWidth = 100;
			tab.label = language.@label;
			tab.addChild(Collector[i]);
			viewForm.addChild(tab);
			i++;
		}
	}
}

private function createInformationLangsTabs():void {
/* createInformationLangsTabs() creates the language labels (tabs) for each multilingual string on the Information tab */

	/* Display Name tabs */
	createLangsTabsAt(infoDnameTabs, infoDnameCollector, 20);
	
	/* Attribute Description tabs */
	createLangsTabsAt(infoDescriptTabs, infoDescriptCollector, 60);
}

private function createAttrLangsTabs():void {
/* createAttrLangsTabs() creates the language labels (tabs) for each multilingual string on the Attributes properties tab */

	/* Display Name tabs */
	createLangsTabsAt(attrDnameTabs, attrDnameCollector, 20);

	/* Error Exp Validation Messages tabs */
	createLangsTabsAt(attrErrmsgTabs, attrErrmsgCollector, 20);

	/* Attribute Description tabs */
	createLangsTabsAt(attrDescriptTabs, attrDescriptCollector, 60);
}

private function lng(label:String):String {
/* lng() used only in case to have short representation of such long string :) */
/* Used in menu creation function langRefresh() */

	return langData.language.(@id == langStr).sentence.(@label == label).toString();
}

private function langRefresh():void {
/* langRefresh() creating the main menu and setting up some global variables. It also applying multilanguage support */

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
	if (ctgrsComboBox != null) ctgrsComboBox.selectedItem = ctgrsComboBox.selectedItem;
	if (itypeComboBox != null) itypeComboBox.selectedItem = itypeComboBox.selectedItem;
	if (attributeInterfaceType != null) attributeInterfaceType.selectedItem = attributeInterfaceType.selectedItem;
	if (stdInterfaceType != null) stdInterfaceType.selectedItem = stdInterfaceType.selectedItem;

	/* Creating the main menu */
	menuBarCollection = new XMLListCollection(menubarXML);
}

private function removeTabsAt(tn:TabNavigator):void {
	if (tn != null) {
		tn.removeAllChildren();
	}
}

private function addSupLanguage():void {
	if (addLanguageComboBox.selectedItem != null) {
		if (supLanguages.language.(@label == addLanguageComboBox.selectedItem.@label).toXMLString() != "") {
			Alert.show("Sorry, you have already have the same one", "Adding language");
		} else {
			/* Saving current state of the Object XML (to store already typed language data */
			buildObjectXML();

			supLanguages.appendChild(<language label={addLanguageComboBox.selectedItem.@label} text={addLanguageComboBox.selectedItem.@text}/>);
			currentState = "";

			/* Refreshing supported Languages TextArea Field */
			supLangsTextArea.text = "";
			for each(var language:XML in supLanguages.language) {
				supLangsTextArea.text += language.@label + " ";
			}

			/* Refreshing multilingual fields, creating(removing) addidation tabs */
			removeTabsAt(infoDnameTabs);
			removeTabsAt(infoDescriptTabs);			
			removeTabsAt(attrDnameTabs);			
			removeTabsAt(attrErrmsgTabs);
			removeTabsAt(attrDescriptTabs);

			infoDnameCollector = new Array();
			infoDescriptCollector = new Array();
			attrDnameCollector = new Array();
			attrErrmsgCollector = new Array();
			attrDescriptCollector = new Array();

			createInformationLangsTabs();
			createAttrLangsTabs();

			/* Restoring multilingual data from the Object XML in memory */
			var i:int = 0;
			for each(language in supLanguages.language) {
				infoDnameCollector[i].text = objectXML.Languages.Language.(@Code == language.@label).Sentence.(@ID == "1");
				infoDescriptCollector[i].text = objectXML.Languages.Language.(@Code == language.@label).Sentence.(@ID == "2");
				i++;
			}
			attrFieldsRefresh();
		}
	}
}

private function removeSupLanguage():void {
	
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

private function checkForLanguageSelection():void {
	if (nativeLanguageComboBox.selectedItem != null) {
		supLanguages.language.@label = nativeLanguageComboBox.selectedItem.@label;
		supLanguages.language.@text = nativeLanguageComboBox.selectedItem.@text;
		vs.selectedChild = mainView;
	}
}

private function buildObjectXML():void {
	/* set Basic XML Structure */
	objectXML = new XML(
		<Type>
			<Information></Information>
			<Attributes></Attributes>
			<Languages></Languages>
			<Resources></Resources>
			<WYSIWYG></WYSIWYG>
			<WCAG></WCAG>
			<SourceCode></SourceCode>
			<Libraries></Libraries>
		</Type>
		);

	/* add details to the Object Type XML */
	
	/* adding data from the Information tab */
	objectXML.Information.appendChild(<Name>{onameTextArea.text}</Name>);
	objectXML.Information.appendChild(<Moveable>{Number(mvChkBox.selected)}</Moveable>);
	objectXML.Information.appendChild(<Dynamic>{Number(dynamicChkBox.selected)}</Dynamic>);
	objectXML.Information.appendChild(<Category>{ctgrsComboBox.selectedItem.data}</Category>);
	objectXML.Information.appendChild(<InterfaceType>{itypeComboBox.selectedItem.data}</InterfaceType>);
	objectXML.Information.appendChild(<OptimizationPriority>{itypeComboBox.selectedItem.data}</OptimizationPriority>);
	objectXML.Information.appendChild(<Containers>{containersTextArea.text}</Containers>);
	objectXML.Information.appendChild(<Languages>{supLangsTextArea.text}</Languages>);
	
	/* adding multilingual data */
	
	/* DisplayName field */
	objectXML.Information.appendChild(<DisplayName LangData="1">#Lang(1)</DisplayName>);
	/* Description field */
	objectXML.Information.appendChild(<Description LangData="2">#Lang(2)</Description>);

	/* Adding multilingual part of object XML */

	var i:int = 0;
	for each(language in supLanguages.language) {
		if (objectXML.Languages.Language.(@Code == language.@label).toXMLString() == "")
			objectXML.Languages.appendChild(<Language Code={language.@label}></Language>);

		objectXML.Languages.Language.(@Code == language.@label).appendChild(<Sentence ID="1">{infoDnameCollector[i].text}</Sentence>);					
		objectXML.Languages.Language.(@Code == language.@label).appendChild(<Sentence ID="2">{infoDescriptCollector[i].text}</Sentence>);					

		lang_id = 100;
		for each(attribute in attributesCollection) {
			if (objectXML.Attributes.Attribute.(Name == attribute.@name).toXMLString() == "") {
			var tmpAttribute:XML = 
				<Attribute>
					<Name>{attribute.@name}</Name>
					<DisplayName LangData={lang_id}>#Lang({lang_id})</DisplayName>
					<DefaultValue>{attribute.@defval}</DefaultValue>
					<RegularExpressionValidation>{attribute.@regexp}</RegularExpressionValidation>
					<ErrorValidationMessage LangData={lang_id + 1}>#Lang({lang_id + 1})</ErrorValidationMessage>
					<Visible>{attribute.@visined}</Visible>
					<Description LangData={lang_id + 2}>#Lang({lang_id + 2})</Description>	
					<InterfaceType>{attribute.@itype}</InterfaceType>
					<CodeInterface>{attribute.codeinterface.toString()}</CodeInterface>
				</Attribute>;
				
			objectXML.Attributes.appendChild(tmpAttribute);
			}
			
			objectXML.Languages.Language.(@Code == language.@label).appendChild (
				<Sentence ID={tmpAttribute.DisplayName.@LangData}>
					{attribute.dname.lang.(@label == language.@label).@text}
				</Sentence>
			);
			objectXML.Languages.Language.(@Code == language.@label).appendChild (
				<Sentence ID={tmpAttribute.ErrorValidationMessage.@LangData}>
					{attribute.err.lang.(@label == language.@label).@text}
				</Sentence>
			);
			objectXML.Languages.Language.(@Code == language.@label).appendChild (
				<Sentence ID={tmpAttribute.Description.@LangData}>
					{attribute.descript.lang.(@label == language.@label).@text}
				</Sentence>
			);
			
			lang_id += 3;
		}
		i++;
	}
	
	/* Show object XML in TextArea on the Target XML tab */	
	if (targetXMLTextArea != null) targetXMLTextArea.text = objectXML.toXMLString();
}