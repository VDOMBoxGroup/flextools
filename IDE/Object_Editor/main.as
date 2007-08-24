// ActionScript file
/** 
 * Development by Vadim A. Usoltsev, SE Group Ltd., Tomsk, Russia, 2007.
**/

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
import mx.charts.chartClasses.RenderData;
import mx.core.Container;
import flash.events.KeyboardEvent;
import com.connection.soap.Soap;
import com.connection.soap.SoapEvent;
import flash.events.Event;
import mx.controls.Image;
import mx.states.AddChild;
import mx.formatters.SwitchSymbolFormatter;

public const ident_1:int = 150;
public const ident_2:int = 200;

/* XML with Object Supported languages */
public var supLanguages:XML = 
	<root>
		<language id="" label=""/>
	</root>;

[Bindable]
private var mainDataFile:XML;
[Bindable]
private var langStr:String = new String("EN"); /* Set default Interface language */
[Bindable]		
private var menuBarCollection:XMLListCollection;
private var menubarXML:XMLList = new XMLList;
[Bindable]
private var attributesCollection:XMLListCollection;
private var currentAttr:int = 0;
[Bindable]
private var objectXML:XML;
private var language:XML = new XML();  /* used in For Each cycles */
private var attribute:XML = new XML();  /* used in For Each cycles */
private var lang_id:int = 100;
private var attrEditorStrCount:int = 1;

private var SOAP:Soap;

/* Multilingual strings collections for each TextArea */
private var infoDnameCollector:Array = new Array();
private var infoDescriptCollector:Array = new Array();
private var attrDnameCollector:Array = new Array();
private var attrErrmsgCollector:Array = new Array();
private var attrDescriptCollector:Array = new Array();

/* Loaded images */
[Bindable]
private var iconImage:Image = new Image();
[Bindable]
private var editorIconImage:Image = new Image();
[Bindable]
private var structureIconImage:Image = new Image();

public function start():void {
	/* **** Start() is the main function, that is being executed as soon as form created **** */

	langRefresh();
	createBasicAttr();
	initSoap();
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
	if (attrList.selectedIndex != -1)
		/* Alert.show("Do you want to proceed?", "Delete Attribute", 3, this, removeAttribute); */
		Alert.show(langData.language.(@id == langStr).sentence.(@id == 'a65'), langData.language.(@id == langStr).sentence.(@id == 'a66'), 3, this, removeAttribute);
}

private function removeAttribute(event:CloseEvent):void {
	if (event.detail == Alert.YES) {
		attributesCollection.removeItemAt(attrList.selectedIndex);
		currentAttr = -1;
		attributesPanel.visible = false;
	}
}

private function createBasicAttr():void {
	attributesCollection = new XMLListCollection();
	addNewAttribute();
}


private function attrFieldsWrite():void {
	/* attrFieldsWrite() writes the data from Attribute Form Fields to the XML in memory */

	var i:uint = 0;
	
	if (currentAttr != -1) {
		with (attributesCollection[currentAttr]) {
			/* Writing basic simple properties */
			@name = attrName.text;
			@label = attrName.text;
			@defval = defValue.text;
			@regexp = regExpVld.text;
			@visined = Number(visinedChBox.selected);
			@itype = attributeInterfaceType.selectedItem.data;
			/** Removed with new XML specification *
			@extended = Number(extChBox.selected);
			*/
			
			if (@itype.toString() == "Std") {
				var selectedData:String = stdInterfaceType.selectedItem.data.toString();
				switch (selectedData) {
					case "ExternalEditor":
						codeinterface = selectedData + "(" + extEditorParam1.text + "," + extEditorParam2.text + ")";
						break;
					case "TextField":
						if (textFieldParam1 != null) {
							codeinterface = selectedData + "(" + textFieldParam1.text + ")";
						} else {
							codeinterface = selectedData + "()";							
						}
						break;						
					default:
						codeinterface = selectedData;
						break;
				}
			} else {
				if (attrCodeEditorTextArea != null)
					codeinterface = attrCodeEditorTextArea.text;
				else
					codeinterface = "";
			}

			/* Writing multilingual properties */
			i = 0;
			for each(language in supLanguages.language) {
				/* Display Name tabs */
				if (dname.lang.(@id == language.@id).toXMLString() == "")
					dname.appendChild(<lang id={language.@id} text={attrDnameCollector[i].text}/>);
				else
					dname.lang.(@id == language.@id).@text = attrDnameCollector[i].text;					
	
				/* Error Exp Validation Messages tabs */
				if (err.lang.(@id == language.@id).toXMLString() == "")
					err.appendChild(<lang id={language.@id} text={attrErrmsgCollector[i].text}/>);
				else
					err.lang.(@id == language.@id).@text = attrErrmsgCollector[i].text;					

				/* Attribute Description tabs */
				if (descript.lang.(@id == language.@id).toXMLString() == "")
					descript.appendChild(<lang id={language.@id} text={attrDescriptCollector[i].text}/>);
				else
					descript.lang.(@id == language.@id).@text = attrDescriptCollector[i].text;					
					
				i++;
			}
		}
	}
}

private function attrFieldsWriteNRefresh():void {
	/* Saving previous Attribute */
	attrFieldsWrite();
	
	/* Setting new Attribute as prevoius :-) */
	currentAttr = attrList.selectedIndex;
	
	/* Refreshing now current Attribute :-) */
	attrFieldsRefresh();
}

private function attrFieldsRefresh():void {	
	/* attrFieldsRefresh() fills in Attribite properties fields with Attribute information from XML in memory */

	if (currentAttr != -1 && attributesPanel != null) {
		if (attributesPanel != null) attributesPanel.visible = true;
		if (attributePropVS != null) attributePropVS.selectedChild = attributesPanel;
		if (attrCodeInterfacePanel != null) attrCodeInterfacePanel.visible = false;

		with (attributesCollection[currentAttr]) {
			/* Loading simple properties */
			attrName.text = @name;
			defValue.text = @defval;
			regExpVld.text = @regexp;
			visinedChBox.selected = Boolean(Number(@visined));
			
			/** Removed with new XML specification *
			extChBox.selected = Number(@extended);
			*/

			/* Set up Interface Type ComboBox */
			switch (@itype.toString()) {
				case "0":	attributeInterfaceType.selectedIndex = 0; break;
				case "1":
					attributeInterfaceType.selectedIndex = 1;
					if (attrCodeEditorTextArea != null)
						attrCodeEditorTextArea.text = attributesCollection[currentAttr].codeinterface;
					break;
			}

			/* Set up Standart Interface Type ComboBox */
			if (@itype.toString() == "0" && stdInterfaceType != null) {
				var stdInterfaceTypeRegexp:RegExp = /([a-zA-Z0-9]+)\([a-zA-Z0-9,]*\)/;
				var interfaceString:String = new String();
				if (codeinterface.toString().match(stdInterfaceTypeRegexp) != null) {
					interfaceString = codeinterface.toString().match(stdInterfaceTypeRegexp)[1];
				} else {
					interfaceString = codeinterface.toString();					
				}

				switch (interfaceString) {
					case "TextField":		stdInterfaceType.selectedIndex = 0; break;
					case "DropDown":		stdInterfaceType.selectedIndex = 1; break;
					case "File":			stdInterfaceType.selectedIndex = 2; break;
					case "Color":			stdInterfaceType.selectedIndex = 3; break;
					case "PageLink":		stdInterfaceType.selectedIndex = 4; break;
					case "ObjectList":		stdInterfaceType.selectedIndex = 5; break;
					case "LinkedBase":		stdInterfaceType.selectedIndex = 6; break;
					case "ExternalEditor":	stdInterfaceType.selectedIndex = 7; break;
				}
			} else {
				stdInterfaceType.selectedIndex = 0;
				stdInterfaceType.text = "";
			}
			
			/* Loading multilingual properties */
			i = 0;
			for each(language in supLanguages.language) {
				/* Display Name tabs */
				attrDnameCollector[i].text = dname.lang.(@id == language.@id).@text;
	
				/* Error Exp Validation Messages tabs */
				attrErrmsgCollector[i].text = err.lang.(@id == language.@id).@text;

				/* Attribute Description tabs */
				attrDescriptCollector[i].text = descript.lang.(@id == language.@id).@text;					
					
				i++;
			}
		}
		
		checkCodeInterface();
	} else {
		if (attributesPanel != null) attributesPanel.visible = false;
	}
}	

private function checkStdInterfaceType():void {
	var selectedData:String = stdInterfaceType.selectedItem.data.toString();
	var stdInterfaceTypeRegexp:RegExp = new RegExp();
	
	switch (selectedData) {
		case "ExternalEditor":
			currentState = "editorParams";			
			stdInterfaceTypeRegexp = /ExternalEditor\(([a-zA-Z0-9]*)\,([a-zA-Z0-9]*)\)/;
			if (attributesCollection[currentAttr].codeinterface.match(stdInterfaceTypeRegexp) != null) {
				extEditorParam1.text = attributesCollection[currentAttr].codeinterface.match(stdInterfaceTypeRegexp)[1];
				extEditorParam2.text = attributesCollection[currentAttr].codeinterface.match(stdInterfaceTypeRegexp)[2];					
			} else {
				extEditorParam1.text = "";
				extEditorParam2.text = "";
			}
			break;
		case "TextField":
			currentState = "textFieldParams";
			stdInterfaceTypeRegexp = /TextField\(([0-9]*)\)/;
			if (attributesCollection[currentAttr].codeinterface.match(stdInterfaceTypeRegexp) != null) {
				textFieldParam1.text = attributesCollection[currentAttr].codeinterface.match(stdInterfaceTypeRegexp)[1];					
			} else {
				textFieldParam1.text = "";
			}
			break;
		case "DropDown":
			currentState = "dropDownMenuParams";
			stdInterfaceTypeRegexp = /DropDown\(([a-zA-Z0-9]*)\)/;
/*
			if (attributesCollection[currentAttr].codeinterface.match(stdInterfaceTypeRegexp) != null) {
				textFieldParam1.text = attributesCollection[currentAttr].codeinterface.match(stdInterfaceTypeRegexp)[1];					
			} else {
				textFieldParam1.text = "";
			}
*/
			break;
		default: currentState = ""; break;
	}
}

private function createLangsTabsAt(viewForm:Object, Collector:Array, txtHeight:int):void {
	/*
		createLangsTabsAt creates tabs at container _viewForm_ (usually it's an empty TabNavigator)
		with Languages labels and puts into created child TextArea (it's height sets as _txtHeight_).
		_Collector_ will contain references to all TextAreas.
	*/
	
	var tab:Canvas;
	var textArea:TextArea;
	var i:uint;
	var language:XML; /* Just in case instead of global */
	
	if (viewForm != null) {
		i = 0;
		for each(language in supLanguages.language) {
			tab = new Canvas();
			Collector[i] = new TextArea();
			Collector[i].height = txtHeight;
			Collector[i].percentWidth = 100;
			tab.label = language.@id;
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
	/* langRefresh() creating the main menu and setting up some global variables. It also applying multilanguage Interface support */

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
	for each(language in langData.language) {
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

private function rebuildInterface():void {
	/* Refreshing supported Languages TextArea Field */
	supLangsTextArea.text = "";
	for each(language in supLanguages.language) {
		supLangsTextArea.text += language.@id + ", ";
	}
	supLangsTextArea.text = supLangsTextArea.text.substr(0, supLangsTextArea.text.length - 2);

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
	var dnameLangID:String = getRefID(objectXML.Information.DisplayName);
	var descriptLangID:String = getRefID(objectXML.Information.Description);
	var i:int = 0;
	for each(language in supLanguages.language) {
		infoDnameCollector[i].text = objectXML.Languages.Language.(@Code == language.@id).Sentence.(@ID == dnameLangID);
		infoDescriptCollector[i].text = objectXML.Languages.Language.(@Code == language.@id).Sentence.(@ID == descriptLangID);
		i++;
	}
	attrFieldsRefresh();
}

private function addSupLanguage():void {
	if (addLanguageComboBox.selectedItem != null) {
		if (supLanguages.language.(@id == addLanguageComboBox.selectedItem.@id).toXMLString() != "") {
			/* Alert.show("Sorry, you have already have the same one", "Adding language"); */
			Alert.show(langData.language.(@id == langStr).sentence.(@id == 'a67'), langData.language.(@id == langStr).sentence.(@id == 'a68'));
		} else {
			/* Saving current state of the Object XML (to store already typed language data */
			buildObjectXML();

			supLanguages.appendChild(<language id={addLanguageComboBox.selectedItem.@id} label={addLanguageComboBox.selectedItem.@label}/>);

			/* Rebuilding programm interface */
			currentState = "";
			rebuildInterface();
		}
	}
}

private function removeSupLanguage():void {
	if (remLanguageComboBox.selectedItem != null) {
		if (supLanguages.children().length() == 1) {
			Alert.show(langData.language.(@id == langStr).sentence.(@id == 'a69'), langData.language.(@id == langStr).sentence.(@id == 'a70'));
		} else {
			/* Saving current state of the Object XML (to store already typed language data) */
			buildObjectXML();
			
			/* Deleting selected language from the supported laguages list */
			var i:int;
			
			for (i = 0; i < supLanguages.children().length(); i++) {
				if (supLanguages.language[i].@label == remLanguageComboBox.selectedItem.@label) {
					delete supLanguages.language[i];				
				}
			}

			/* Rebuilding programm interface */
			currentState = "";
			rebuildInterface();			
		}
	}
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

private function checkCodeInterface():void {
	if (attributeInterfaceType != null) {
		if (attributeInterfaceType.selectedItem.data == "Ext") {
			codeButton.enabled = true;
			stdInterfaceType.enabled = false;
		} else {
			codeButton.enabled = false;
			stdInterfaceType.enabled = true;
			checkStdInterfaceType();
		}
	}
}

private function checkForLanguageSelection():void {
	if (nativeLanguageComboBox.selectedItem != null) {
		supLanguages.language.@id = nativeLanguageComboBox.selectedItem.@id;
		supLanguages.language.@label = nativeLanguageComboBox.selectedItem.@label;
		vs.selectedChild = mainView;
	}
}

private function getRefID(refStr:String):String {
	var refRegExp:RegExp = /^#[a-zA-Z]+\(([0-9]*)\)/;

	if (refStr.match(refRegExp) != null) {
		return refStr.match(refRegExp)[1];
	} else {
		return "";
	}
	
/*
	var left:int;
	var right:int;
	
	for (var i:int = 0; i < refStr.length; i++) {
		switch (refStr.charCodeAt(i)) {
			case 40: left = i; break;
			case 41: right = i; break;
		}
	}
	return refStr.substring(left + 1, right);
*/
}
 
private function buildObjectXML():void {
	/* set Basic XML Structure */
	objectXML = new XML(
		<Type>
			<Information>
				<Name/>
				<Moveable/>
				<Dynamic/>
				<Container/>
				<Version/>
				<Icon/>
				<StructureIcon/>
				<EditorIcon/>
				<Category/>
				<ID/>
				<InterfaceType/>
				<OptimizationPriority/>
				<Containers/>
				<Languages/>
			</Information>
			<Attributes/>
			<Languages/>
			<Resources/>
			<WYSIWYG/>
			<WCAG/>
			<SourceCode/>
			<Libraries/>
		</Type>
		);

	/* add details to the Object Type XML */
	
	/* adding data from the Information tab */
	with (objectXML.Information) {
		Name = onameTextArea.text;
		Moveable  = Number(mvChkBox.selected);
		Dynamic = Number(dynamicChkBox.selected);
		Category = ctgrsComboBox.selectedItem.data;
		InterfaceType = itypeComboBox.selectedItem.data;
		OptimizationPriority = opriorTextArea.text;
		Containers = containersTextArea.text;
		Languages = supLangsTextArea.text;
		Version = versionTextArea.text;
		ID = idTextArea.text;
	}
	objectXML.Information.Container = Number(containerChkBox.selected);
	
	/* adding multilingual data */
	
	/* DisplayName field */
	objectXML.Information.appendChild(<DisplayName>#Lang(1)</DisplayName>);
	/* Description field */
	objectXML.Information.appendChild(<Description>#Lang(2)</Description>);

	/* Adding multilingual part of object XML */
	var i:int = 0;
	for each(language in supLanguages.language) {
		if (objectXML.Languages.Language.(@Code == language.@id).toXMLString() == "")
			objectXML.Languages.appendChild(<Language Code={language.@id}/>);

		objectXML.Languages.Language.(@Code == language.@id).appendChild(<Sentence ID="1">{infoDnameCollector[i].text}</Sentence>);
		objectXML.Languages.Language.(@Code == language.@id).appendChild(<Sentence ID="2">{infoDescriptCollector[i].text}</Sentence>);
		i++;
	}

	lang_id = 100;
	for each (attribute in attributesCollection) {
		if (objectXML.Attributes.Attribute.(Name == attribute.@name).toXMLString() == "") {
			var tmpAttribute:XML = 
				<Attribute>
					<Name>{attribute.@name}</Name>
					<DisplayName>#Lang({lang_id})</DisplayName>
					<DefaultValue>{attribute.@defval}</DefaultValue>
					<RegularExpressionValidation>{attribute.@regexp}</RegularExpressionValidation>
					<ErrorValidationMessage>#Lang({lang_id + 1})</ErrorValidationMessage>
					<Visible>{attribute.@visined}</Visible>
					<Description>#Lang({lang_id + 2})</Description>	
					<InterfaceType>{attribute.@itype}</InterfaceType>
					<CodeInterface>{attribute.codeinterface.toString()}</CodeInterface>
				</Attribute>;
				
			objectXML.Attributes.appendChild(tmpAttribute);
			
			language = null;
			for each(language in supLanguages.language) {
				if (objectXML.Languages.Language.(@Code == language.@id).toXMLString() == "")
					objectXML.Languages.appendChild(<Language Code={language.@id}/>);

				objectXML.Languages.Language.(@Code == language.@id).appendChild (
					<Sentence ID={getRefID(tmpAttribute.DisplayName)}>
						{attribute.dname.lang.(@id == language.@id).@text}
					</Sentence>
				);
				objectXML.Languages.Language.(@Code == language.@id).appendChild (
					<Sentence ID={getRefID(tmpAttribute.ErrorValidationMessage)}>
						{attribute.err.lang.(@id == language.@id).@text}
					</Sentence>
				);
				objectXML.Languages.Language.(@Code == language.@id).appendChild (
					<Sentence ID={getRefID(tmpAttribute.Description)}>
						{attribute.descript.lang.(@id == language.@id).@text}
					</Sentence>
				);
			}
	
			lang_id += 3;
		}	
	}

	/* Show object XML in TextArea on the Target XML tab */	
	if (targetXMLTextArea != null) targetXMLTextArea.text = objectXML.toXMLString();
}

private function loadObjectXML():void {
	objectXML = new XML(sourceXMLTextArea.text);

	/* Set Basic properties */
	with (objectXML.Information) {
		onameTextArea.text = Name;
		mvChkBox.selected = Boolean(Number(Moveable));
		dynamicChkBox.selected = Boolean(Number(Dynamic));
		opriorTextArea.text = OptimizationPriority;
		containersTextArea.text = Containers;
		idTextArea.text = ID;
		versionTextArea.text = Version;
	}
	containerChkBox.selected = Boolean(Number(objectXML.Information.Container));
	
	/* Fill in Categories ComboBox */
	switch (String(objectXML.Information.Category)) {
		case "standart":	ctgrsComboBox.selectedIndex = 0; break;
		case "advanced":	ctgrsComboBox.selectedIndex = 1; break;
		case "usual":		ctgrsComboBox.selectedIndex = 2; break;
		case "portal":		ctgrsComboBox.selectedIndex = 3; break;
	}
	
	/* Interface Type ComboBox */
	itypeComboBox.selectedIndex = Number(objectXML.Information.InterfaceType) - 1;
	
	/* Parsing supported languages field */
	var lngs_str:String = objectXML.Information.Languages; /* Get string data from the Object Type XML */
	var index:int = -1;
	while ((index = lngs_str.search(" ")) != -1) {
		lngs_str = lngs_str.substring(0, index) + lngs_str.substr(index + 1);
	}
	var lngs_array:Array = lngs_str.split(","); /* Parse string into array of langs labels(codes) */
	
	supLanguages = new XML(<root/>); /* Creating empty supported languages XML */
	for each(var lng:String in lngs_array) {
		/* Add supported language and get its real name from the langsSource XML */
		supLanguages.appendChild(<language id={lng} label={langsSource.language.(@id == lng).@text}/>);
	}
	
	/* Loading attributes records */
	attributesCollection = new XMLListCollection();

	currentAttr = -1;
	for each(attribute in objectXML.Attributes.Attribute) {
		addNewAttribute();
		currentAttr++;

		with (attributesCollection[currentAttr]) {
			/* Writing basic simple properties */
			@name = attribute.Name;
			@label = attribute.Name;
			@defval = attribute.DefaultValue;
			@regexp = attribute.RegularExpressionValidation;
			@visined = attribute.Visible;
			@itype = attribute.InterfaceType;
			codeinterface = attribute.CodeInterface.toString();
			
			var dnameLangID:String = getRefID(attribute.DisplayName);
			var errLangID:String = getRefID(attribute.ErrorValidationMessage);
			var descriptLangID:String = getRefID(attribute.Description);

			/* Writing multilingual properties */
			for each(language in supLanguages.language) {
				var lngID:String = language.@id;
				/* Display Name tabs */
				dname.appendChild(<lang id={language.@id} label={objectXML.Languages.Language.(@Code == lngID).Sentence.(@ID == dnameLangID)}/>);

				/* Error Exp Validation Messages tabs */
				err.appendChild(<lang id={language.@id} label={objectXML.Languages.Language.(@Code == lngID).Sentence.(@ID == errLangID)}/>);

				/* Attribute Description tabs */
				descript.appendChild(<lang id={language.@id} label={objectXML.Languages.Language.(@Code == lngID).Sentence.(@ID == descriptLangID)}/>);
			}
		}
	}
	
	if (attributesCollection.length != 0)
		currentAttr = 0
	else
		currentAttr = -1;
		
	rebuildInterface();
}

/* -------------- Soap Connections -------------- */
private function initSoap():void {
	SOAP = Soap.getInstance();
	SOAP.init('http://192.168.0.23:82/vdom.wsdl');
	SOAP.login('123','777');
}

/* Validators for Icon */
private function processIconData(event:Event):void {
	SOAP.sendEcho("icon", browseButton1, processIconImage, restoreIconImage);
	iconImageBox.source = waitingImage.source;
}

private function processIconImage(event:Event):void {
	iconImage.source = SOAP.getEchoResult("icon").source;
	iconImageBox.source = iconImage.source;
}

private function restoreIconImage(event:Event):void {
	iconImageBox.source = iconImage.source;	
}

/* Validators for Editor Icon */
private function processEditorIconData(event:Event):void {
	SOAP.sendEcho("editorIcon", browseButton2, processEditorIconImage, restoreEditorIconImage);
	editorIconImageBox.source = waitingImage.source;
}

private function processEditorIconImage(event:Event):void {
	editorIconImage.source = SOAP.getEchoResult("editorIcon").source;
	editorIconImageBox.source = editorIconImage.source;
}

private function restoreEditorIconImage(event:Event):void {
	editorIconImageBox.source = editorIconImage.source;	
}

/* Valiators for Structure Icon */
private function processStructureIconData(event:Event):void {
	SOAP.sendEcho("structureIcon", browseButton3, processStructureIconImage, restoreStructureIconImage);
	structureIconImageBox.source = waitingImage.source;
}

private function processStructureIconImage(event:Event):void {
	structureIconImage.source = SOAP.getEchoResult("structureIcon").source;
	structureIconImageBox.source = structureIconImage.source;
}

private function restoreStructureIconImage(event:Event):void {
	structureIconImageBox.source = structureIconImage.source;	
}
/* -------------- END Soap Connections -------------- */

/* -------------- CODE EDITOR Functions and Procedures -------------- */
private function keyValidator(key:KeyboardEvent):void {
	var ta:TextArea = attrCodeEditorTextArea;

	/* <tab> key validation */
	if (key.charCode == 9) {
		ta.text = ta.text.substring(0, ta.selectionBeginIndex) + String.fromCharCode(9) + ta.text.substring(ta.selectionBeginIndex);
		ta.setSelection(ta.selectionBeginIndex + 1, ta.selectionBeginIndex + 1);
	}
	
	/* Draw srings numbers */
	var na:TextArea = attrCodeEditorNumbersArea;
	var strNumber:int = ta.verticalScrollPosition + 1;

	na.htmlText = "";
	var xPosition:int = 1;
	var currentPosition:int = 0;
	while (currentPosition < ta.selectionBeginIndex) {
		if (ta.text.charCodeAt(currentPosition) == 13)
			xPosition++;
		
		currentPosition++;
	}

	for (var i:int = 0; i < ta.height / 12; i++) {
		switch (key.keyCode) {
			case 13:
			case 40:
				if (strNumber == xPosition + 1)
					na.htmlText += "<b><font color='#000000'>" + strNumber.toString() + "</font></b><br>";
				else
					na.htmlText += strNumber.toString() + "<br>";
				break;
			case 38:
				if (strNumber == xPosition - 1)
					na.htmlText += "<b><font color='#000000'>" + strNumber.toString() + "</font></b><br>";
				else
					na.htmlText += strNumber.toString() + "<br>";
				break;
			default:
				if (strNumber == xPosition)
					na.htmlText += "<b><font color='#000000'>" + strNumber.toString() + "</font></b><br>";
				else
					na.htmlText += strNumber.toString() + "<br>";
		}
		strNumber++;
	}
	
}

private function justDrawNumbers():void {  /*  :-)  */
	var ta:TextArea = attrCodeEditorTextArea;
	var na:TextArea = attrCodeEditorNumbersArea;
	var strNumber:int = ta.verticalScrollPosition + 1;

	na.htmlText = "";
	var xPosition:int = 1;
	var currentPosition:int = 0;
	while (currentPosition < ta.selectionBeginIndex) {
		if (ta.text.charCodeAt(currentPosition) == 13)
			xPosition++;
		
		currentPosition++;
	}

	for (var i:int = 0; i < ta.height / 12; i++) {
		if (strNumber == xPosition)
			na.htmlText += "<b><font color='#000000'>" + strNumber.toString() + "</font></b><br>";
		else
			na.htmlText += strNumber.toString() + "<br>";
		strNumber++;
	}
}

private function checkTextAreaFocus():void {
	if (attrCodeInterfacePanel.visible == true)
		attrCodeEditorTextArea.setFocus();	
}
/* ------------ END CODE EDITOR Functions and Procedures ------------ */
