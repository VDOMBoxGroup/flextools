package vdom.components.editor.containers {

import flash.display.DisplayObject;
import flash.events.FocusEvent;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;

import mx.collections.IViewCursor;
import mx.collections.Sort;
import mx.collections.SortField;
import mx.collections.XMLListCollection;
import mx.containers.ControlBar;
import mx.containers.Grid;
import mx.containers.GridItem;
import mx.containers.GridRow;
import mx.controls.Button;
import mx.controls.ComboBox;
import mx.controls.NumericStepper;
import mx.controls.Text;
import mx.controls.TextInput;
import mx.controls.ToolTip;
import mx.core.ClassFactory;
import mx.core.EdgeMetrics;
import mx.core.IUIComponent;
import mx.events.ValidationResultEvent;
import mx.skins.Border;
import mx.validators.RegExpValidator;

import vdom.Languages;
import flash.events.Event;

public class AttributesPanel extends ClosablePanel {
		
	[Bindable] public var help:String;
	
	
	private var acceptButton:Button;
	private var cancelButton:Button;
	
	private var attributesGrid:Grid;
	
	private var attributeRow:ClassFactory;
	private var attributeItemLabel:ClassFactory;
	private var attributeItemValue:ClassFactory;
	private var attributeLabel:ClassFactory;
	
	private var applyButton:Button;
	
	/* private var _type:XML; */
	private var _typeID:String;
	private var _collection:XMLListCollection;
	private var objectDescription:XML;
	
	private var fieldsArray:Array;
	private var languages:Languages;
	
	private var _isValid:Boolean;
	private var _objectChanged:Boolean;
	private var _objectName:String;
	
	private var _acceptLabel:String;
	private var _cancelLabel:String;
	
	private var _pageLink:XMLList;
	private var _objectList:XMLList;
	
	private var cursor:IViewCursor;
	
	private var invalidElementsCount:uint;
	
	private var attributesVisible:Boolean;
	private var old_attributesVisible:Boolean;
	
	public function AttributesPanel() {
		
		super();
		help = null;
		_typeID = null;
		languages = Languages.getInstance();
		//this.addEventListener(KeyboardEvent.KEY_UP, enterHandler);
		horizontalScrollPolicy = 'off';
		verticalScrollPolicy = 'off';
		ToolTip.maxWidth = 120;
		
		_isValid = true;
		
		invalidElementsCount = 0;
		attributesVisible = old_attributesVisible = false;
	}
	
	public function get acceptLabel():String {
		
		return _acceptLabel;
	}
	
	public function set acceptLabel(newLabel:String):void {
		
		acceptButton.label = _acceptLabel = newLabel;
	}
	
	public function get cancelLabel():String {
		
		return _acceptLabel;
	}
	
	public function set cancelLabel(newLabel:String):void {
		
		cancelButton.label = _cancelLabel = newLabel;
	}
	
	public function get dataProvider():XML {
		
		return XML(_collection);
	}
	
	public function set dataProvider(new_objectDescription:XML):void {
		
		if (new_objectDescription is XML) {
			
			objectDescription = new_objectDescription;
			
			_objectName = objectDescription.@Name;
			
			if(objectDescription.ObjectList)
				_objectList = objectDescription.ObjectList.*;
				
			if(objectDescription.PageLink)
				_pageLink = objectDescription.PageLink.*;
			
			var xl:XMLList = new XMLList();
			xl += objectDescription.Attributes.Attribute;
			_collection = new XMLListCollection(xl);
			
			var sortA:Sort = new Sort();
			sortA.fields = [new SortField("@Name", false, true)];
			_collection.sort = sortA;
			_collection.refresh();
			
			cursor = _collection.createCursor();
			
			//_type = objectDescription.Type[0];
			
			attributesVisible = true;
			
		} else {
			
			_collection = null;
			//_type = null;
			attributesVisible = false;
		}
		
		_objectChanged = true;
		invalidateDisplayList();
		invalidateProperties();
	}
	
	override public function createComponentsFromDescriptors(recurse:Boolean = true):void {
		
		var tmpControlBar:ControlBar;
		 	
		if (numChildren != 0) {
			
			var lastChild:IUIComponent = IUIComponent(getChildAt(numChildren - 1));
			
			if (lastChild is ControlBar)
				tmpControlBar = ControlBar(lastChild);
				
			else {
				
				tmpControlBar = new ControlBar();
				addChild(tmpControlBar);
			}
				
				
		} else {
			
			tmpControlBar = new ControlBar();
			addChild(tmpControlBar);
		}
		
		super.createComponentsFromDescriptors()
	}
	
	override protected function createChildren():void {
		
		super.createChildren();
		
		/*if(!controlBar) {
			
			controlBar = new ControlBar()
			//controlBar.height = 40;
		} */
		/* if(!controlBar) {
			
			//rawChildren.addChild(new ControlBar());
			//controlBar = new ControlBar();
			
		} */
			
		
		if (!acceptButton) {
			
			acceptButton = new Button();
			
			acceptButton.setStyle("upSkin", getStyle('buttonSkin'));
			acceptButton.setStyle("downSkin", getStyle('buttonSkin'));
			acceptButton.setStyle("overSkin", getStyle('buttonSkin'));
			acceptButton.setStyle("disabledSkin", getStyle('buttonSkin'));
			
			acceptButton.height = 15;
			//acceptButton.visible = false;
			
			acceptButton.enabled = enabled;
			//acceptButton.styleName = controlBar;	
			
			acceptButton.addEventListener(MouseEvent.CLICK, acceptButton_clickHandler);
		   	ControlBar(controlBar).addChild(acceptButton);
		   	
			acceptButton.owner = ControlBar(controlBar);
		}
		
		if (!cancelButton) {
			
			cancelButton = new Button();
			
			cancelButton.setStyle("upSkin", getStyle('buttonSkin'));
			cancelButton.setStyle("downSkin", getStyle('buttonSkin'));
			cancelButton.setStyle("overSkin", getStyle('buttonSkin'));
			cancelButton.setStyle("disabledSkin", getStyle('buttonSkin'));
			
			cancelButton.height = 15;
			//cancelButton.visible = false;
			
			cancelButton.enabled = enabled;
			//cancelButton.styleName = controlBar;	
			
			cancelButton.addEventListener(MouseEvent.CLICK, chancelButton_clickHandler);
		   	ControlBar(controlBar).addChild(cancelButton);
		   	
			cancelButton.owner = ControlBar(controlBar);
		}
		
		if (!attributesGrid) {
			attributesGrid = new Grid();
			attributesGrid.visible = false;
			attributesGrid.percentWidth = 100;
			attributesGrid.setStyle('horizontalGap', 0);
			attributesGrid.setStyle('verticalGap', 0);
			attributesGrid.setStyle('backgroundColor', '#ffffff');
			addChild(attributesGrid);
		}
		if (!attributeRow) {
			
			attributeRow = new ClassFactory(GridRow);
			attributeRow.properties = {
				percentWidth:100
			};
		}
		if (!attributeItemLabel) {
			
			attributeItemLabel = new ClassFactory(GridItem);
		}
		if (!attributeItemValue) {
			
			attributeItemValue = new ClassFactory(GridItem);
			attributeItemValue.properties = {
				percentWidth:100
			};
		}
		if (!attributeLabel) {
			
			attributeLabel = new ClassFactory(Text);
			attributeLabel.properties = {
				selectable:false,
				width:70
			};
		}
		/* if (!applyButton) {
			applyButton = new Button();
			applyButton.visible = false;
			applyButton.label = 'Save';
			applyButton.enabled = false;
			//addChild(applyButton);
		} */
	}
	
	override protected function updateDisplayList(unscaledWidth:Number, 
												unscaledHeight:Number):void {
		
		super.updateDisplayList(unscaledWidth, unscaledHeight);
		
		if(attributesVisible != old_attributesVisible) {
			
			
			attributesGrid.visible = attributesVisible;			
			controlBar.visible = attributesVisible;
			acceptButton.visible = attributesVisible;
			cancelButton.visible = attributesVisible;
			
			/* if(!attributesVisible) {
				
				var attributeGridW:Number = attributesGrid.getExplicitOrMeasuredWidth();
				var controlBarW:Number = controlBar.getExplicitOrMeasuredWidth();
				
				attributesGrid.height = 0;
				controlBar.height = 0;
				
			} else {
				
				attributesGrid.height = NaN;
				controlBar.height = NaN;
			} */
			
			old_attributesVisible = attributesVisible;
		}
	}
	
	override protected function layoutChrome(unscaledWidth:Number, unscaledHeight:Number):void {
		
		 super.layoutChrome(unscaledWidth, unscaledHeight);
		 
		 var bm:EdgeMetrics = ControlBar(controlBar).viewMetricsAndPadding
		 
		 if(controlBar) {
		 	
		 	if(acceptButton) {
		 		
		 		acceptButton.move(bm.left, bm.top);
		 	}
		 	
		 	if(cancelButton) {
		 		
		 		cancelButton.move(
		 			controlBar.width - 
		 			cancelButton.width - bm.right,
		 			bm.top);
		 	}
		 }
	}
	
	private function showControlBar(show:Boolean):void {
		
		controlBar.visible = show;
		
		var n:int = ControlBar(controlBar).numChildren;
		for (var i:int = 0; i < n; i++) {
			
			var child:DisplayObject = ControlBar(controlBar).getChildAt(i);
			child.visible = show;
		}
	}   
	/* override protected function layoutChrome(unscaledWidth:Number, unscaledHeight:Number):void {
		
		super.layoutChrome(unscaledWidth, unscaledHeight);
		
		var bm:EdgeMetrics = borderMetrics;
		
		acceptButton.setActualSize(
			acceptButton.getExplicitOrMeasuredWidth(),
			acceptButton.getExplicitOrMeasuredHeight()
		);

		acceptButton.move(
			unscaledWidth - bm.right - 10 -
			acceptButton.getExplicitOrMeasuredWidth(),
			unscaledHeight - acceptButton.getExplicitOrMeasuredHeight() / 2 
		);
	} */
	
	/* private function applyChanges(event:Event):void {

		for (var attrName:String in fieldsArray) {
			if(!cursor.findFirst({'@Name':attrName}))
				continue;
			var currentElement:Object = cursor.current;
			currentElement.*[0] = fieldsArray[attrName][0][fieldsArray[attrName][1]];
		}
		dispatchEvent(new Event('propsChanged'));
	} */
	
	private function createAttributes():void {
		
		attributesGrid.removeAllChildren();
		fieldsArray = [];
		
		var codeInterface:Object = new Object();
		
		var valueContainer:*;
		var valueType:String;
		var color:String = '';
		
		valueContainer = new TextInput();
		valueContainer.text = _objectName;
		valueType = 'text';
		fieldsArray['Name'] = [valueContainer, valueType];
		color = '#c2c2c2';
		insertAttribute('Name', valueContainer, color);
		
		var attributes:XMLList = objectDescription.Type.Attributes.Attribute;
		
		for each(var attributeDescription:XML in attributes) {
			
			if(attributeDescription.Visible == 0)
				return;
				
			cursor.findFirst({'@Name':attributeDescription.Name})
			
			var currentAttribute:Object = cursor.current;
			
			var label:String = languages.getLanguagePhrase(_typeID, attributeDescription.DisplayName);
			
			var codeInterfaceRE:RegExp = /^(\w*)\((.*)\)/;
			
			var matches:Array = attributeDescription.CodeInterface.match(codeInterfaceRE);
			
			codeInterface['type'] = matches[1].toLowerCase();
			codeInterface['value'] = matches[2];
			
			switch(codeInterface['type']) {
				case 'number':
				
					valueContainer = new NumericStepper();
					valueType = 'value';
					
					valueContainer.maxChars = codeInterface['value'];
					valueContainer.minimum = 0;
					valueContainer.maximum = Math.pow(10, codeInterface['value']) - 1;
					
					valueContainer.value = currentAttribute;
				break;
					
				case 'textfield':
				
					valueContainer = new TextInput();
					valueType = 'text';
					
					valueContainer.maxChars = codeInterface['value'];
					
					valueContainer.text = currentAttribute;
				break;
					
				case 'dropdown':
					
					valueContainer = new ComboBox();
					valueType = 'value';
					
					var comboBoxData:Array = new Array();
					var codeInterfaceValueRE:RegExp = /\((#Lang\(.*?\))\|(.*?)\)/g;
					
					var listValues:Array = codeInterfaceValueRE.exec(codeInterface['value']);
					while (listValues != null) {
					    var comboBoxLabel:String = languages.getLanguagePhrase(_typeID, listValues[1]);
					    comboBoxData.push({label:comboBoxLabel, data:listValues[2]});
					    listValues = codeInterfaceValueRE.exec(codeInterface['value']);
					}
					
					valueContainer.dataProvider = comboBoxData;
				break;
				
				case 'file':
				case 'color':
				break;
				case 'pageLink':
					
					valueContainer = new ComboBox();
					valueType = 'value';
					
					valueContainer.dataProvider = _objectList;
				break;
				
				case 'objectlist':
				case 'linkedbase':
				case 'externaleditor':
				
				default:
					valueContainer = new TextInput();
					valueType = 'text';
					
					valueContainer.text = currentAttribute;
			}
			
			valueContainer.percentWidth = 100;
			//valueContainer.minWidth = 0;
			
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
			
			fieldsArray[currentAttribute.@Name] = [valueContainer, valueType];
			
			insertAttribute(label, valueContainer, color)
		}
	}
	
	private function insertAttribute(label:String, element:*, color:String):void {
		
		var attrRow:GridRow = attributeRow.newInstance();
		var attrItemLabel:GridItem = attributeItemLabel.newInstance();
		var attrItemValue:GridItem = attributeItemValue.newInstance();
		var attrLabel:Text = attributeLabel.newInstance();
		
		
		
		attrLabel.text = label;
		
		attrLabel.setStyle('textAlign', 'right');
		attrLabel.height = 21;
		
		attrItemLabel.addChild(attrLabel);
		
		attrItemLabel.setStyle('backgroundColor', color);
		attrItemLabel.setStyle('paddingTop', 3);
		attrItemLabel.setStyle('paddingBottom', 3);
		attrItemLabel.setStyle('paddingRight', 3);
		attrItemLabel.setStyle('color', '#ffffff');
		attrItemLabel.setStyle('fontWeight', 'bold');
		
		attrItemValue.addChild(element);
		attrItemValue.setStyle('verticalAlign', 'middle');
		attrItemValue.setStyle('paddingLeft', 3);
		element.width = 110;
		element.height = 21;
		
		
		//attrRow.setStyle('backgroundColor', '#00ff00');
		attrRow.addChild(attrItemLabel);
		attrRow.addChild(attrItemValue);
		
		attributesGrid.addChild(attrRow);
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
				languages.getLanguagePhrase(_typeID, errorMsg);
		
	}
	
	
	
	override protected function commitProperties():void {
		
		if(_objectChanged) {
			
			var titleValue:String = 'OBJECT PROPERTIES';
			
			if (_collection is XMLListCollection) {
				
				_typeID = objectDescription.Type.Information.ID;
				titleValue += ': ' + objectDescription.Type.Information.Name;
				
				createAttributes();
				
				//showControlBar(true);
				
				//applyButton.addEventListener(MouseEvent.CLICK, applyChanges);
				
				attributesGrid.visible = true;
				
				//applyButton.visible = true;
				_isValid = true;
				
			} else {
				
				//applyButton.removeEventListener(MouseEvent.CLICK, applyChanges);
				//applyButton.visible = false;
				attributesGrid.visible = false;
				//showControlBar(false);
				attributesGrid.removeAllChildren();
				_isValid = false;
			}
			
			title = titleValue;
			help = '';
			invalidElementsCount = 0;
			
			_objectChanged = false;
		}
		
		//if(_isValid)
			//applyButton.enabled = true;
		//else
			//applyButton.enabled = false;
			
		super.commitProperties();
		invalidateDisplayList();
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
	
	private function acceptButton_clickHandler(event:MouseEvent):void {
		
		for (var attrName:String in fieldsArray) {
			if(!cursor.findFirst({'@Name':attrName}))
				continue;
			var currentElement:Object = cursor.current;
			currentElement.*[0] = fieldsArray[attrName][0][fieldsArray[attrName][1]];
		}
		dispatchEvent(new Event('propsChanged'));
	}
	
	private function chancelButton_clickHandler(event:MouseEvent):void {
		
		_objectChanged = true;
		invalidateProperties();
	}
	
	private function focusInEventHandler(event:FocusEvent):void {
		
		var phraseID:String = event.currentTarget.data['helpPhraseID'];
		help = languages.getLanguagePhrase(_typeID, phraseID);
	}
	
	private function focusOutEventHandler(event:FocusEvent):void {
		
		help = null;
	}
	
	private function enterHandler(event:KeyboardEvent):void {
		
		//if(event.keyCode == 13) applyChanges(event);
	}
}
}