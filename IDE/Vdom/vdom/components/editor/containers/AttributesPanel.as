package vdom.components.editor.containers {

import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import mx.containers.Grid;
import mx.containers.GridRow;
import mx.containers.GridItem;
import mx.controls.Button;
import mx.controls.Label;
import mx.controls.NumericStepper;
import mx.controls.TextInput;
import mx.collections.XMLListCollection;

public class AttributesPanel extends ClosablePanel
{
	[Bindable]
	public var help:String;
	
	private var attributesGrid:Grid;
	private var applyButton:Button;
	private var collection:XMLListCollection;
	private var fieldsArray:Array;
	
	public function AttributesPanel() {
		
		super();
		help = null;
		this.addEventListener(KeyboardEvent.KEY_UP, enterHandler);
	}
	
	public function set dataProvider(prop:XML):void {
		
		if(prop == null) {	
			applyButton.removeEventListener(MouseEvent.CLICK, applyChanges);
			title = 'Attributes';
			applyButton.visible = false;
			attributesGrid.visible = false;
			attributesGrid.removeAllChildren();
			return
		};
		//trace(prop);
		title = 'Attributes: '+prop.Type.Information.Name;
		help = '';
		var xl:XMLList = new XMLList();
        xl += prop.Attributes.Attribute;
        collection = new XMLListCollection(xl);

        createChild();
             
        applyButton.addEventListener(MouseEvent.CLICK, applyChanges);
        attributesGrid.visible = true;
		applyButton.visible = true;
		invalidateDisplayList();
	}
	
	public function get dataProvider():XML {
		
		return XML(collection);
	}
	
	private function applyChanges(event:Event):void {

		for (var i:uint = 0; i < collection.length; i++) {
			collection[i].Value = fieldsArray[i][0][fieldsArray[i][1]];
		}
		dispatchEvent(new Event('propsChanged'));
	}
	
	private function createChild():void {
		
		attributesGrid.removeAllChildren();
		fieldsArray = [];
		
		var codeInterface:Object = new Object();
		
		var attrRow:GridRow;
		var attrLabelItem:GridItem;
		var attrFieldItem:GridItem;
		var attrLabel:Label;
		
		for (var i:uint = 0; i < collection.length; i++) {
			
			attrRow = new GridRow();
			attrRow.percentWidth = 100;
			
			attrLabelItem = new GridItem();
			attrLabel = new Label();
			attrLabel.percentWidth = 100;
			attrLabel.setStyle('textAlign', 'right');
			attrLabel.text = collection[i].Name;		
			attrLabelItem.addChild(attrLabel);
			
			attrFieldItem = new GridItem();
			attrFieldItem.percentWidth = 100;
			
			var typeRE:RegExp = /(\w+)\((\d*)\)/;
			codeInterface['type'] = collection[i].CodeInterface.match(typeRE)[1].toLowerCase();
			codeInterface['length'] = collection[i].CodeInterface.match(typeRE)[2];
			
			switch(codeInterface['type']) {
				case 'number':
					var ns:NumericStepper = new NumericStepper();
					//attrField.name = collection[i].Name;
					ns.addEventListener(FocusEvent.FOCUS_IN, focusInEventHandler);
					ns.addEventListener(FocusEvent.FOCUS_OUT, focusOutEventHandler);
					ns.maxChars = codeInterface['length'];
					ns.minimum = 0;
					ns.maximum = Math.pow(10, codeInterface['length']) - 1;
					ns.percentWidth = 100;
					ns.value = collection[i].Value.toString();
					ns.name = i.toString();
					//ns.data = collection[i];
					//attrField.data = collection[i].Value;
					fieldsArray[i] = [ns, 'value'];
					attrFieldItem.addChild(ns);
					break;
					
				case 'textfield':
					var ti:TextInput = new TextInput();
					//attrField.name = collection[i].Name;
					ti.addEventListener(FocusEvent.FOCUS_IN, focusInEventHandler);
					ti.maxChars = codeInterface['length'];
					ti.percentWidth = 100;
					ti.name = i.toString();
					ti.text = collection[i].Value.toString();
					//attrField.data = collection[i].Value;
					fieldsArray[i] = [ti, 'text'];
					attrFieldItem.addChild(ti);
					break;
				case 'dropdown':
				case 'file':
				case 'color':
				case 'pageLink':
				case 'objectlist':
				case 'linkedbase':
				case 'externaleditor':
				default:
					var tw:TextInput = new TextInput();
					//attrField.name = collection[i].Name;
					tw.addEventListener(FocusEvent.FOCUS_IN, focusInEventHandler);
					tw.addEventListener(FocusEvent.FOCUS_OUT, focusOutEventHandler);
					tw.maxChars = codeInterface['length'];
					tw.percentWidth = 100;
					tw.name = i.toString();
					tw.text = collection[i].Attribute.Value.toString();
					//attrField.data = collection[i].Value;
					fieldsArray[i] = [tw, 'text'];
					attrFieldItem.addChild(tw);
				
			} 

			attrRow.addChild(attrLabelItem);
			attrRow.addChild(attrFieldItem);
			
			attributesGrid.addChild(attrRow);
		}
		var zzz:String = 'asdasdasdasdasdsa';
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
			addChild(applyButton);
		}
	}
	
	private function focusInEventHandler(event:FocusEvent):void {
		
		help = collection[event.currentTarget.name].Help;
	}
	
	private function focusOutEventHandler(event:FocusEvent):void {
		
		help = null;
	}
	
	private function enterHandler(event:KeyboardEvent):void {
		
		if(event.keyCode == 13) applyChanges(event);
	}
}
}