package vdom.components.edition.containers {

import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;

import mx.collections.ArrayCollection;
import mx.collections.IViewCursor;
import mx.collections.Sort;
import mx.collections.SortField;
import mx.collections.XMLListCollection;
import mx.containers.ControlBar;
import mx.containers.Grid;
import mx.containers.GridItem;
import mx.containers.GridRow;
import mx.controls.Alert;
import mx.controls.Button;
import mx.controls.ComboBox;
import mx.controls.Spacer;
import mx.controls.Text;
import mx.controls.TextInput;
import mx.controls.ToolTip;
import mx.core.ClassFactory;
import mx.core.IUIComponent;
import mx.core.UIComponent;
import mx.events.CloseEvent;
import mx.events.ValidationResultEvent;
import mx.utils.StringUtil;

import vdom.containers.ClosablePanel;
import vdom.controls.NumberField;
import vdom.controls.colorPicker.ColorPicker;
import vdom.controls.externalEditionorButton.ExternalEditionorButton;
import vdom.controls.multiline.Multiline;
import vdom.controls.resourceBrowser.ResourceBrowserButton;
import vdom.events.AttributesPanelEvent;
import vdom.managers.DataManager;
import vdom.managers.LanguageManager;
import vdom.validators.AttributeValidator;

public class AttributesPanel extends ClosablePanel {
		
	[Bindable] public var help : String;
	
	private var languageManager : LanguageManager;
	
	private var dataManager : DataManager = DataManager.getInstance();
	
	private var acceptButton : Button;
	private var deleteButton : Button;
	private var buttonSpacer : Spacer;
	
	
	private var attributesGrid : Grid;
	
	private var attributeRow : ClassFactory;
	private var attributeItemLabel : ClassFactory;
	private var attributeItemValue : ClassFactory;
	private var attributeLabel : ClassFactory;
	
	private var typeName : String;
	private var _collection : XMLListCollection;
	private var objectDescription : XML;
	
	private var fieldsArray : Array;
	
	private var _isValid : Boolean;
	private var _objectChanged : Boolean;
	private var objectID : String;
	private var objectName : String;
	private var attributesVisible : Boolean;
	
	private var _acceptLabel : String;
	private var _cancelLabel : String;
	
	private var _pageLink : XMLList;
	private var _objectList : XMLList;
	
	private var cursor : IViewCursor;
	private var typeTitle : UIComponent;
	private var invalidElements : Object = {};
	
	
	private var old_attributesVisible : Boolean;
	
	public function AttributesPanel() {
		
		super();
		help = null;
		typeName = null;

		horizontalScrollPolicy = "off";
		//verticalScrollPolicy = "off";
		ToolTip.maxWidth = 120;
		
		_isValid = true;
		
		attributesVisible = old_attributesVisible = false;
		languageManager = LanguageManager.getInstance();
	}
	
	public function get acceptLabel() : String {
		
		return _acceptLabel;
	}
	
	public function set acceptLabel( newLabel : String ) : void {
		
		acceptButton.label = _acceptLabel = newLabel;
	}
	
	public function get deleteLabel() : String {
		
		return _acceptLabel;
	}
	
	public function set deleteLabel( newLabel : String ) : void {
		
		deleteButton.label = _cancelLabel = newLabel;
	}
	
	public function set dataProvider( new_objectDescription : XML ) : void {
		
		if ( new_objectDescription is XML ) {
			
			objectDescription = new_objectDescription;
			
			invalidElements = {};
			invalidElements["_currentCount"] = 0;
			
			objectID = objectDescription.@ID;
			objectName = objectDescription.@Name;
			
			if( objectDescription.Objectlist )
				_objectList = objectDescription.Objectlist.*;
				
			if( objectDescription.Pagelink )
				_pageLink = objectDescription.Pagelink.*;
			
			var xl : XMLList = new XMLList();
			xl += objectDescription.Attributes.Attribute;
			_collection = new XMLListCollection( xl );
			
			var sortA : Sort = new Sort();
			sortA.fields = [new SortField( "@Name", false, true )];
			_collection.sort = sortA;
			_collection.refresh();
			
			cursor = _collection.createCursor();
			
			attributesVisible = true;
			
		} else {
			
			_collection = null;
			attributesVisible = false;
		}
		
		_objectChanged = true;
		
		invalidateProperties();
	}
	
	override public function createComponentsFromDescriptors( recurse : Boolean = true ) : void {
		
		var tmpControlBar : ControlBar;
		 	
		if ( numChildren != 0 ) {
			
			var lastChild : IUIComponent = IUIComponent( getChildAt( numChildren - 1 ));
			
			if ( lastChild is ControlBar )
				tmpControlBar = ControlBar( lastChild );
				
			else {
				
				tmpControlBar = new ControlBar();
				addChild( tmpControlBar );
			}

		} else {
			
			tmpControlBar = new ControlBar();
			addChild( tmpControlBar );
		}
		
		super.createComponentsFromDescriptors()
	}
	
	override protected function createChildren() : void {
		
		super.createChildren();
		
		if( !typeTitle ) {
			
			typeTitle = new UIComponent();
			typeTitle.visible = false;
			
			rawChildren.addChild( typeTitle );
		}
		
		if ( !acceptButton ) {
			
			acceptButton = new Button();
			
			acceptButton.setStyle( "cornerRadius", 0 );
			
			acceptButton.height = 15;
			acceptButton.enabled = enabled;	
			acceptButton.visible = false;
			
			acceptButton.addEventListener( MouseEvent.CLICK, acceptButton_clickHandler );
		   	ControlBar( controlBar ).addChild( acceptButton );
		   	
			acceptButton.owner = ControlBar( controlBar );
		}
		
		if( !buttonSpacer ) {
			
			buttonSpacer = new Spacer();
		
			buttonSpacer.percentWidth = 100;
		
		   	ControlBar( controlBar ).addChild( buttonSpacer );
		   	
			buttonSpacer.owner = ControlBar( controlBar );
		}
		
		if ( !deleteButton ) {
			
			deleteButton = new Button();
			deleteButton.setStyle( "cornerRadius", 0 );
			
			deleteButton.height = 15;
			deleteButton.enabled = enabled;
			deleteButton.visible = false;
			
			deleteButton.addEventListener( MouseEvent.CLICK, deleteButton_clickHandler );
		   	ControlBar( controlBar ).addChild( deleteButton );
		   	
			deleteButton.owner = ControlBar( controlBar );
		}
		
		if ( !attributesGrid ) {
			attributesGrid = new Grid();
			attributesGrid.visible = false;
			attributesGrid.percentWidth = 100;
			attributesGrid.setStyle( "horizontalGap", 0 );
			attributesGrid.setStyle( "verticalGap", 0 );
			attributesGrid.setStyle( "backgroundColor", "#ffffff" );
			addChild( attributesGrid );
		}
		if ( !attributeRow ) {
			
			attributeRow = new ClassFactory( GridRow );
			attributeRow.properties = {
				percentWidth : 100
			};
		}
		if ( !attributeItemLabel ) {
			
			attributeItemLabel = new ClassFactory( GridItem );
			attributeItemLabel.properties = {
				percentWidth : 100
			};
		}
		if ( !attributeItemValue ) {
			
			attributeItemValue = new ClassFactory( GridItem );
			attributeItemValue.properties = {
				percentWidth : 100
			};
		}
		if ( !attributeLabel ) {
			
			attributeLabel = new ClassFactory( Text );
			attributeLabel.properties = {
				selectable : false,
				minWidth : 70,
				percentWidth : 100
			};
		}
	}
	
	override protected function updateDisplayList( unscaledWidth : Number, 
												unscaledHeight : Number ) : void {
		
		super.updateDisplayList( unscaledWidth, unscaledHeight );
		
		if( attributesVisible != old_attributesVisible ) {
			
			attributesGrid.visible = attributesVisible;			
			controlBar.visible = attributesVisible;
			acceptButton.visible = attributesVisible;
	
			old_attributesVisible = attributesVisible;
		}
		
		if( objectDescription && objectDescription.Type.Information.Container == 3 )
			deleteButton.visible = false;
		else
			deleteButton.visible = attributesVisible;
	}
	
	override protected function commitProperties() : void {
		
		if( _objectChanged )
		{
//			var titleValue : String = "OBJECT PROPERTIES";
			var objectName : String;
			
			if ( _collection is XMLListCollection )
			{	
				typeName = objectDescription.Type.Information.Name;
				objectName = objectDescription.Type.Information.Name;
				
				createAttributes();
				
				attributesGrid.visible = true;
				_isValid = true;
				
			}
			else
			{
				attributesGrid.visible = false;
				attributesGrid.removeAllChildren();
				_isValid = false;
			}
			
//			title = titleValue;
			status = objectName;
			help = "";
//			invalidElementsCount = 0;
			
			_objectChanged = false;
			
			invalidateDisplayList();
		}
		
		if( _isValid )
			acceptButton.enabled = true;
		else
			acceptButton.enabled = true; //FIXME<---- Error!
		
		super.commitProperties();
	}
	
	override protected function layoutChrome( unscaledWidth : Number, unscaledHeight : Number ) : void {
		
		 super.layoutChrome( unscaledWidth, unscaledHeight );
		 
		// var bm : EdgeMetrics = ControlBar( controlBar ).viewMetricsAndPadding
		 
		/*  if( controlBar ) {
		 	
		 	if( acceptButton ) {
		 		
		 		acceptButton.move( bm.left, bm.top );
		 	}
		 	
		 	var cbw : Number = controlBar.width;
		 	var dbw : Number = deleteButton.width;
		 	var bbr : Number = bm.right;
		 	var bbt : Number = bm.top;
		 	var ax : Number = controlBar.width - deleteButton.width - bm.right;
		 	
		 	if( deleteButton ) {
		 		
		 		deleteButton.move(
		 			unscaledWidth - 
		 			deleteButton.width - bm.right,
		 			bm.top );
		 	}
		 }
		  */
		 titleTextField.move( 8, 2 );
		 
		 collapseButton.move( collapseButton.x, 4 );
		
		 statusTextField.setActualSize( unscaledWidth, statusTextField.textHeight );
		 statusTextField.move( 0, titleTextField.y + titleTextField.textHeight + 6 );
		 setStyle( "headerHeight", statusTextField.y + statusTextField.textHeight + 2 );
	}
	
	private function showControlBar( show : Boolean ) : void {
		
		controlBar.visible = show;
		
		var n : int = ControlBar( controlBar ).numChildren;
		for ( var i : int = 0; i < n; i++ ) {
			
			var child : DisplayObject = ControlBar( controlBar ).getChildAt( i );
			child.visible = show;
		}
	}
	
	private function createAttributes() : void {
		
		attributesGrid.removeAllChildren();
			
		fieldsArray = [];
		
		var codeInterface : Object = new Object();
		
		var valueContainer : *;
		var valueType : String;
		var color : String = "";
		
		valueContainer = new TextInput();
		TextInput( valueContainer ).editionable = false;
		valueContainer.setStyle( "borderStyle", "none" );
		valueContainer.setStyle( "backgroundAlpha", .0 );
		valueContainer.text = objectID;
		valueType = "text";
		fieldsArray["ID"] = [ valueContainer, valueType ];
		color = getColorByGroup( 1 );
		
		insertAttribute(
			"ID",
			valueContainer,
			color
		);
		
		valueContainer = new TextInput();
		valueContainer.text = objectName;
		valueType = "text";
		fieldsArray["Name"] = [ valueContainer, valueType ];
		
		color = getColorByGroup( 1 );			
		
		insertAttribute(
			resourceManager.getString( "Edition","attributes_name" ),
			valueContainer,
			color
		);
		
		var attributes : XMLList = objectDescription.Type.Attributes.Attribute;
		
		for each( var attributeXMLDescription : XML in attributes ) {
			
			if( attributeXMLDescription.Visible == 0 )
				continue;
				
			cursor.findFirst( {"@Name" : attributeXMLDescription.Name} )
			
			var currentAttribute : Object = cursor.current;
			
			var displayName : String = attributeXMLDescription.DisplayName.toString();
			
			var label : String = getLanguagePhraseId( displayName );
			
			var codeInterfaceRE : RegExp = /^(\w*)\((.*)\)/;
			
			var matches : Array = attributeXMLDescription.CodeInterface.match( codeInterfaceRE );
			
			codeInterface["type"] = matches[1].toLowerCase();
			codeInterface["value"] = matches[2];
			
			color = getColorByGroup( attributeXMLDescription.Colorgroup );
			
			switch( codeInterface["type"] )
			{
				case "number" : 
				{
					valueContainer = new NumberField();
					valueType = "value";
					
					var valArr : Array = codeInterface["value"].split( "," );
					
					if( valArr.length == 2 )
					{
						var minVal : Number = Number( StringUtil.trim( valArr[0] ));
						var maxVal : Number = Number( StringUtil.trim( valArr[1] ));
																	
						valueContainer.minimum = minVal;
						valueContainer.maximum = maxVal;
					}
					
					valueContainer.value = currentAttribute;
					break;
				}
					
				case "textfield" : 
				{
				
					valueContainer = new TextInput();
					valueType = "text";
					
					valueContainer.maxChars = codeInterface["value"];
					
					valueContainer.text = currentAttribute;
					break;
				}
				
				case "multiline" : 
				{
					valueContainer = new Multiline();
					valueType = "value";
					
					valueContainer.value = currentAttribute;
					valueContainer.title = label;
					break;
				}
				
				case "file" : 
				{
					valueContainer = new ResourceBrowserButton();
					valueType = "value";
					
					valueContainer.value = currentAttribute;
					break;
				}
				
				case "color" : 
				{
				
					valueContainer = new ColorPicker();	
					valueType = "color";
					
					valueContainer.color = currentAttribute;
					break;
				}
				
				case "dropdown" : 
				{
					valueContainer = new ComboBox();
					valueType = "value";
					
					var comboBoxData : ArrayCollection = new ArrayCollection();
					var codeInterfaceValueRE : RegExp = /\((#Lang\(.*?\))\|(.*?)\)/g;
					
					var listValues : Array = [];
					var selectedItem : Object = {};
					
					while ( listValues = codeInterfaceValueRE.exec( codeInterface[ "value" ] ) ) {
						
						var comboBoxLabel : String = getLanguagePhraseId( listValues[ 1 ] );
						
						var listItem : Object = { label : comboBoxLabel, data : listValues[ 2 ] };
						
						comboBoxData.addItem( { label : comboBoxLabel, data : listValues[ 2 ] } );
						if( currentAttribute == listValues[2] )
							selectedItem = comboBoxData[ comboBoxData.length - 1 ];
					} 
					
					comboBoxData.sort = new Sort();
					comboBoxData.sort.fields = [ new SortField( "label", true ) ];
					comboBoxData.refresh();
					
					valueContainer.dataProvider = comboBoxData;
					valueContainer.selectedItem = selectedItem;
					break;
				}
				
				case "pagelink" : 
				{
					valueContainer = new ComboBox();
					valueType = "value";
					
					var pagelinkData : ArrayCollection = new ArrayCollection();
					
					var listValues1 : XML;
					var selectedItem1 : Object = {};
					var count : uint = 0;
					for each ( listValues1 in _pageLink ) {
						
						var listItem1 : Object = { label : listValues1.@Name.toString(), data : listValues1.@ID.toString() }
						
						pagelinkData.addItem( listItem1 );
						if( currentAttribute.toString() == listValues1.@ID.toString() )
							selectedItem1 = listItem1;
						count++
					} 
					
					pagelinkData.sort = new Sort();
					pagelinkData.sort.fields = [ new SortField( "label", true ) ];
					pagelinkData.refresh();
					
					valueContainer.dataProvider = pagelinkData;
					valueContainer.selectedItem = selectedItem1;
					
					break;
				}
				
				case "objectlist" : 
				{
					valueContainer = new ComboBox();
					valueType = "value";
					
					var pagelinkData1 : ArrayCollection = new ArrayCollection();
					
					var listValues2 : XML;
					var selectedItem2 : Object = {};
					var count2 : uint = 0;
					for each ( listValues2 in _objectList ) {
						
						var listItem2 : Object = {label : listValues2.@Name, data : listValues2.@ID}
						
						pagelinkData1.addItem( listItem2 );
						if( currentAttribute == listValues2.@ID )
							selectedItem2 = listItem2;
						
						count++
					}
					
					pagelinkData1.sort = new Sort();
					pagelinkData1.sort.fields = [ new SortField( "label", true ) ];
					pagelinkData1.refresh();
					
					valueContainer.dataProvider = pagelinkData1;
					valueContainer.selectedItem = selectedItem2;
					break;
				}
				
				case "externaleditionor" : 
				{
					var resId : String = String( codeInterface["value"] ).split( "," )[1];
					
					valueContainer = new ExternalEditionorButton(
						dataManager.currentApplicationId, 
						objectDescription.@ID,
						resId );  
					
					valueContainer.minWidth = 110;
					valueContainer.percentWidth = 100;
					valueContainer.height = 21;
					valueContainer.title = label;
					
					valueType = "value";
					break
				}
				
				default : 
				{
					valueContainer = new TextInput();
					valueType = "text";
					
					valueContainer.text = currentAttribute;
				}
			}
			
			valueContainer.percentWidth = 100;
			
			valueContainer.data = {
				"elementName" : attributeXMLDescription.Name[0].toString(),
				"helpPhraseID" : attributeXMLDescription.Help[0].toString(),
				"valid" :  false
			};
			
			valueContainer.addEventListener( FocusEvent.FOCUS_IN, focusInEventHandler );
			valueContainer.addEventListener( FocusEvent.FOCUS_OUT, focusOutEventHandler );
			
			fieldsArray[currentAttribute.@Name] = [valueContainer, valueType];
			
			invalidElements[attributeXMLDescription.Name[0].toString()] = "Add";
			invalidElements["_currentCount"] += 1;
				
			insertAttribute( label, valueContainer, color );
			
			addValidator(
				valueContainer, 
				valueType, 
				attributeXMLDescription.RegularExpressionValidation,
				attributeXMLDescription.ErrorValidationMessage
			);
		}
	}
	
	private function getColorByGroup( groupNumber : uint ) : String
	{
		var colorGroup : String = "";
		
		switch( groupNumber ) {
			
			case 1 : 
				colorGroup = "#777777";
			break
				
			case 2 : 
				colorGroup = "#00B000";
			break
			
			case 3 : 
				colorGroup = "#B00000";
			break
			
			case 4 : 
				colorGroup = "#8080ff";
			break
			
			default : 
				colorGroup = "#777777";
		}
		
		return colorGroup;
	}
	
	private function insertAttribute( label : String, element : *, color : String ) : void {
		
		var attrRow : GridRow = attributeRow.newInstance();
		var attrItemLabel : GridItem = attributeItemLabel.newInstance();
		var attrItemValue : GridItem = attributeItemValue.newInstance();
		var attrLabel : Text = attributeLabel.newInstance();
		
		attrLabel.text = label;
		
		attrLabel.setStyle( "textAlign", "right" );
		
		attrItemLabel.addChild( attrLabel );
		
		attrItemLabel.setStyle( "backgroundColor", color );
		attrItemLabel.setStyle( "paddingTop", 3 );
		attrItemLabel.setStyle( "paddingBottom", 3 );
		attrItemLabel.setStyle( "paddingRight", 3 );
		attrItemLabel.setStyle( "color", "#ffffff" );
		attrItemLabel.setStyle( "fontWeight", "bold" );
		
		attrItemValue.addChild( element );
		attrItemValue.setStyle( "verticalAlign", "middle" );
		attrItemValue.setStyle( "fontFamily", "Tahoma" );
		attrItemValue.setStyle( "paddingLeft", 3 );

		element.minWidth = 110;
		element.percentWidth = 100;
		element.height = 21;
		
		attrRow.addChild( attrItemLabel );
		attrRow.addChild( attrItemValue );
		
		attributesGrid.addChild( attrRow );
	}
	
	private function addValidator( valueContainer : Object, valueType : String, regExp : String, errorMsg : String ) : void {
		
		//if ( regExp == "" )
			//return;
		
		var validator : AttributeValidator = new AttributeValidator();
		
		validator.required = false;
		
		validator.addEventListener( ValidationResultEvent.INVALID, validateHandler );
		validator.addEventListener( ValidationResultEvent.VALID, validateHandler );
		
		validator.source = valueContainer;
		validator.property = valueType;
		validator.expression = regExp;
		
		validator.noMatchError = validator.requiredFieldError = getLanguagePhraseId( errorMsg );
		
		validator.validate();
//		validator.requiredFieldError = "";
//		languages.getLanguagePhrase( _typeID, errorMsg );
		
	}
	
	private function getLanguagePhraseId( phrase : String ) : String {
		
		var phraseRE : RegExp = /#Lang\((\w+)\)/;
		var phraseID : String = phrase.match( phraseRE )[ 1 ];
		
		return resourceManager.getString( typeName, phraseID );
	}
	
	private function validateHandler( event : ValidationResultEvent ) : void {
		
		var element : Object = event.currentTarget.source.data;
		var oldValid : Boolean = _isValid;
		
		if ( event.type == ValidationResultEvent.VALID && invalidElements.hasOwnProperty( element["elementName"] ))
		{
			delete invalidElements[element["elementName"]];
			
			if( invalidElements["_currentCount"] > 0 )
				invalidElements["_currentCount"] -=1;
			
//			element["valid"] = true;
//			invalidElementsCount--;
//			UIComponent( event.currentTarget.source ).setFocus();
		}
		else if( event.type == ValidationResultEvent.INVALID && !invalidElements.hasOwnProperty( element["elementName"] ))
		{
			invalidElements[element["elementName"]] = "here";
			
			invalidElements["_currentCount"] +=1;
//			element["valid"] = false;
//			invalidElementsCount++;
//			UIComponent( event.currentTarget.source ).setFocus();
		}
		
		if( invalidElements["_currentCount"] > 0 ) 
			_isValid = false;
		else 
			_isValid = true;
		
		if( oldValid !== _isValid )
			invalidateProperties();
	}
	
	private function acceptButton_clickHandler( event : MouseEvent ) : void
	{
		var objectChanged : Boolean = false;
		
		if( objectDescription.@Name != fieldsArray[ "Name" ][ 0 ][ fieldsArray[ "Name" ][ 1 ] ] )
		{
			objectDescription.@Name = fieldsArray[ "Name" ][ 0 ][ fieldsArray["Name" ][ 1 ] ];
			objectChanged = true;
		}
	
		for ( var attrName : String in fieldsArray ) {
			if( !cursor.findFirst( {"@Name" : attrName} ))
				continue;
			var currentElement : Object = cursor.current;
			
			var value : String = null;
				
			if( fieldsArray[attrName][0] is ComboBox )
			{
				if( fieldsArray[attrName][0].selectedItem )
					value = fieldsArray[attrName][0].selectedItem["data"];
				else
					value = "";
			}
			else if ( fieldsArray[attrName][0] is ExternalEditionorButton )
			{
				if( fieldsArray[ attrName ][ 0 ][ fieldsArray[ attrName ][ 1 ] ] == "modified" )
				{
					fieldsArray[ attrName ][ 0 ][ fieldsArray[ attrName ][ 1 ] ] = ""; //FIXME Dirty dirty hack!!!!!!
					objectChanged = true;
				}
			}
			else
			{
				value = fieldsArray[attrName][0][fieldsArray[attrName][1]];
			}
				
			if( value != null && currentElement != value ) {
				
				objectChanged = true;
				
				var xmlCharRegExp : RegExp = /[<>&"]+/;
			
				if( value.search( xmlCharRegExp ) != -1 )
				{	
					var name : String = currentElement.@Name;
					var parent : XML = currentElement.parent();
					value = value.replace(/\]\]>/g, "]]]]"+"><![CDATA[>" );
					value = "<Attribute Name=\""+ name +"\"><![CDATA[" + value + "]" + "]></Attribute>"
					delete parent.Attribute.(@Name == name)[0];
					parent.appendChild( new XML( value ) );
					currentElement.*[0] = value;
				}
				else
				{
					currentElement.*[0] = value;
				}
			}
		}
		if( objectChanged )
			dispatchEvent( new Event( "propsChanged" ));
	}
	
	private function deleteButton_clickHandler( event : MouseEvent ) : void {
		
		Alert.show( "Delete?", "Delete", Alert.YES | Alert.NO, null, closeButtonAlertHandler, null, Alert.NO );
	}
	
	private function closeButtonAlertHandler( event : CloseEvent ) : void {
		
		if( event.detail == Alert.NO )
			return;
		
		if( event.detail == Alert.YES )
			var ee : AttributesPanelEvent = new AttributesPanelEvent( AttributesPanelEvent.DELETE_OBJECT )
			ee.objectId = objectDescription.@ID;
			dispatchEvent( ee );
	}
	
	private function focusInEventHandler( event : FocusEvent ) : void {
		
		var phraseID : String = event.currentTarget.data["helpPhraseID"];
		help = getLanguagePhraseId( phraseID );
	}
	
	private function focusOutEventHandler( event : FocusEvent ) : void {
		
		help = null;
	}
	
	private function enterHandler( event : KeyboardEvent ) : void {
		
		//if( event.keyCode == 13 ) applyChanges( event );
	}
}
}