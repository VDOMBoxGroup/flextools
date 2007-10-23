package vdom.components.editor.containers {

import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;

import mx.collections.ArrayCollection;
import mx.collections.XMLListCollection;
import mx.containers.Grid;
import mx.containers.GridItem;
import mx.containers.GridRow;
import mx.controls.Button;
import mx.controls.ComboBox;
import mx.controls.Label;
import mx.controls.NumericStepper;
import mx.controls.Text;
import mx.controls.TextInput;
import mx.controls.ToolTip;
import mx.events.ValidationResultEvent;
import mx.managers.ToolTipManager;
import mx.validators.NumberValidator;
import mx.validators.RegExpValidator;
import mx.validators.Validator;

import vdom.Languages;
import mx.events.FlexEvent;

//use namespace mx_internal;

public class AttributesPanel extends ClosablePanel
{
	[Bindable]
	public var help:String;
	
	private var attributesGrid:Grid;
	private var applyButton:Button;
	
	private var _type:XML;
	private var _typeID:String;
	private var _collection:XMLListCollection;
	
	private var fieldsArray:Array;
	private var languages:Languages;
	
	private var _isValid:Boolean;
	private var _objectChanged:Boolean;
	
	private var invalidElementsCount:uint;
	
	public function AttributesPanel() {
		
		super();
		help = null;
		_typeID = null;
		languages = Languages.getInstance();
		this.addEventListener(KeyboardEvent.KEY_UP, enterHandler);
		horizontalScrollPolicy = 'off';
		verticalScrollPolicy = 'off';
		ToolTip.maxWidth = 120;
		
		_isValid = true;
		
		invalidElementsCount = 0;
	}
	
	public function get dataProvider():XML {
		
		return XML(_collection);
	}
	
	public function set dataProvider(objectDescription:XML):void {
		
		if (objectDescription is XML) {
			
			var xl:XMLList = new XMLList();
			xl += objectDescription.Attributes.Attribute;
			_collection = new XMLListCollection(xl);
			
			_type = objectDescription.Type[0];
			
		} else {
			
			_collection = null;
			_type = null;
		}
		
		_objectChanged = true;
		invalidateProperties();
	}
	
	
	
	private function applyChanges(event:Event):void {

		for (var i:String in fieldsArray) {
			_collection[i] = fieldsArray[i][0][fieldsArray[i][1]];
		}
		dispatchEvent(new Event('propsChanged'));
	}
	
	private function createAttributes():void {
		
		attributesGrid.removeAllChildren();
		fieldsArray = [];
		
		var codeInterface:Object = new Object();
		
		var attrRow:GridRow;
		var attrLabelItem:GridItem;
		var attrValueItem:GridItem;
		
		var attrLabel:Text;
		
		for (var i:uint = 0; i < _collection.length; i++) {
			
			var attributeDescription:XML = _type.Attributes.Attribute.(Name == _collection[i].@Name)[0]
			
			if (attributeDescription == null) continue;
			
			attrRow = new GridRow();
			attrRow.percentWidth = 100;
				
			attrLabelItem = new GridItem();
			attrLabel = new Text();
			attrLabel.width = 70;
			attrLabel.setStyle('textAlign', 'right');
			
			attrLabel.selectable = false;
			attrLabel.text = getLanguagePhrase(_typeID, attributeDescription.DisplayName);	
			attrLabelItem.addChild(attrLabel);
			
			attrValueItem = new GridItem();
			attrValueItem.percentWidth = 100;
			
			var codeInterfaceRE:RegExp = /^(\w*)\((.*)\)/;
			
			var matches:Array = attributeDescription.CodeInterface.match(codeInterfaceRE);
			
			codeInterface['type'] = matches[1].toLowerCase();
			codeInterface['value'] = matches[2];
			
			var valueContainer:*;
			var valueType:String;
			
			switch(codeInterface['type']) {
				case 'number':
					valueContainer = new NumericStepper();
					valueType = 'value';
					
					valueContainer.maxChars = codeInterface['value'];
					valueContainer.minimum = 0;
					valueContainer.maximum = Math.pow(10, codeInterface['value']) - 1;
					
					valueContainer.value = _collection[i];
				break;
					
				case 'textfield':
				
					valueContainer = new TextInput();
					valueType = 'text';
					
					
					
					valueContainer.maxChars = codeInterface['value'];
					
					valueContainer.text = _collection[i];
				break;
					
				case 'dropdown':
					valueContainer = new ComboBox();
					valueType = 'value';
					var comboBoxData:Array = new Array();
					var codeInterfaceValueRE:RegExp = /\((#Lang\(.*?\))\|(.*?)\)/g;
					
					var listValues:Array = codeInterfaceValueRE.exec(codeInterface['value']);
					while (listValues != null) {
					    var comboBoxLabel:String = getLanguagePhrase(_typeID, listValues[1]);
					    comboBoxData.push({label:comboBoxLabel, data:listValues[2]});
					    listValues = codeInterfaceValueRE.exec(codeInterface['value']);
					}
					valueContainer.dataProvider = comboBoxData;
				break;
				
				case 'file':
				case 'color':
				case 'pageLink':
				case 'objectlist':
				case 'linkedbase':
				case 'externaleditor':
				
				default:
					valueContainer = new TextInput();
					valueType = 'text';
					
					valueContainer.text = _collection[i];
			}
			
			valueContainer.percentWidth = 100;
			valueContainer.minWidth = 0;
			valueContainer.data = {
				'elementName':attributeDescription.Name,
				'helpPhraseID':attributeDescription.Help,
				'valid': true
			};
			
			addValidator(
				valueContainer, 
				valueType, 
				attributeDescription.RegularExpressionValidation, 
				attributeDescription.ErrorValidationMessage
			);
			
			valueContainer.addEventListener(FocusEvent.FOCUS_IN, focusInEventHandler);
			valueContainer.addEventListener(FocusEvent.FOCUS_OUT, focusOutEventHandler);
			
			attrValueItem.addChild(valueContainer);
			
			fieldsArray[i] = [valueContainer, valueType];
			
			attrRow.addChild(attrLabelItem);
			attrRow.addChild(attrValueItem);
			
			attributesGrid.addChild(attrRow);
		}
	}
	
	private function getLanguagePhrase(typeID:String, phraseID:String):String {
		
		var phraseRE:RegExp = /#Lang\((\w+)\)/;
		phraseID = phraseID.match(phraseRE)[1];
		var languageID:String = typeID + '-' + phraseID;
		
		return languages.language.(@ID == languageID)[0];
	}
	
	private function addValidator(valueContainer:Object, valueType:String, regExp:String, errorMsg:String):void {
		
		if (regExp == '') return;
		var validator:RegExpValidator = new RegExpValidator();
		
		validator.addEventListener(ValidationResultEvent.INVALID, validateHandler);
		validator.addEventListener(ValidationResultEvent.VALID, validateHandler);
		
		validator.source = valueContainer;
		validator.property = valueType;
		validator.expression = '^'+regExp+'$';
		validator.noMatchError = 
			validator.requiredFieldError = 
				getLanguagePhrase(_typeID, errorMsg);
		
	}
	
	override protected function createChildren():void {
		
		super.createChildren();
		
		if (!attributesGrid) {
			attributesGrid = new Grid();
			attributesGrid.visible = false;
			attributesGrid.percentWidth = 100;
			addChild(attributesGrid);
		}
		if (!applyButton) {
			applyButton = new Button();
			applyButton.visible = false;
			applyButton.label = 'Save';
			applyButton.enabled = false;
			addChild(applyButton);
		}
	}
	
	override protected function commitProperties():void {
		
		if(_objectChanged) {
			
			var titleValue:String = 'Attributes';
			
			if (_collection is XMLListCollection) {
				
				_typeID = _type.Information.ID;
				titleValue += ': ' + _type.Information.Name;
				
				createAttributes();
				
				applyButton.addEventListener(MouseEvent.CLICK, applyChanges);
				attributesGrid.visible = true;
				applyButton.visible = true;
				_isValid = true;
				
			} else {
				
				applyButton.removeEventListener(MouseEvent.CLICK, applyChanges);
				applyButton.visible = false;
				attributesGrid.visible = false;
				attributesGrid.removeAllChildren();
				_isValid = false;
			}
			
			title = titleValue;
			help = '';
			invalidElementsCount = 0;
			
			_objectChanged = false;
		}
		
		if(_isValid)
			applyButton.enabled = true;
		else
			applyButton.enabled = false;
			
		super.commitProperties();	
	}
	
	private function validateHandler(event:ValidationResultEvent):void {
		
		var element:Object = event.currentTarget.source.data;
		var oldValid:Boolean = _isValid;
		
		if (event.type == ValidationResultEvent.VALID && element['valid'] == false) {
			element['valid'] = true;
			invalidElementsCount--;
		} else if(event.type == ValidationResultEvent.INVALID && element['valid'] == true) {
			element['valid'] = false;
			invalidElementsCount++;
		}
		
		if(invalidElementsCount > 0) _isValid = false;
			else _isValid = true;
		
		if(oldValid !== _isValid) invalidateProperties();
	}
	
	private function focusInEventHandler(event:FocusEvent):void {
		
		var phraseID:String = event.currentTarget.data['helpPhraseID'];
		help = getLanguagePhrase(_typeID, phraseID);
	}
	
	private function focusOutEventHandler(event:FocusEvent):void {
		
		help = null;
	}
	
	private function enterHandler(event:KeyboardEvent):void {
		
		//if(event.keyCode == 13) applyChanges(event);
	}
}
}