
package vdom.components.eventEditor
{
	import flash.events.Event;
	
	import mx.containers.Canvas;
	import mx.controls.HRule;
	import mx.controls.Image;
	import mx.controls.Label;
	import mx.controls.TextInput;
	import mx.controls.VRule;
	import mx.events.ValidationResultEvent;
	import mx.validators.RegExpValidator;

	public class AdvansedLayer extends Canvas
	{
		[Embed(source='/assets/treeEditor/treeEditor.swf', symbol='delete')]
		[Bindable]
		public var delet:Class;
		
		private var typeName:String;
		private var inputText:TextInput = new TextInput();
		private var _scriptName:String;
		
		public function AdvansedLayer(inXMK:XML, typeName:String)
		{
			super();
			
			this.typeName = typeName;
			_scriptName = inXMK.@ScriptName;
			_data = inXMK.@DefaultValue
			
			var img:Image = new Image();
				img.source = delet;
				img.x = 3;
				img.y = 2;
			addChild(img);

			var vRule:VRule = new VRule();
				vRule.x = 25;
				vRule.percentHeight = 100;
			addChild(vRule);
			
			
			var label:Label = new Label();
				label.text = _scriptName + ": ";
				label.width = 75;
				label.x = vRule.x;
				label.setStyle('textAlign', 'right')
			//	label.setStyle("fontWeight", 'bold');
			addChild(label);		
		
			
		//	var inputText:TextInput = new TextInput();
				
				inputText.text = _data;
				inputText.width = 65;
				inputText.height = 18;
				inputText.x = 100;
				inputText.setStyle("fontSize", '8');
				inputText.setStyle("fontWeight", 'bold');
				inputText.setStyle("textAlign", 'center');

			addChild(inputText);
				
			
			var hRule:HRule = new HRule();
				hRule.y = 17;
				hRule.percentWidth = 100;
			addChild(hRule);
			
			var regExpValidator:RegExpValidator = new RegExpValidator();
				regExpValidator.source = inputText;
				regExpValidator.property = 'text';
				regExpValidator.expression = "[0-9]+"
				regExpValidator.trigger = inputText;
				regExpValidator.addEventListener(ValidationResultEvent.VALID, validHandler);
				regExpValidator.noMatchError =getLanguagePhraseId(inXMK.@Help);
				regExpValidator.triggerEvent = Event.CHANGE;
		}
		
		
		private function getLanguagePhraseId(phrase:String):String 
		{
			var phraseRE:RegExp = /#Lang\((\w+)\)/;
			var phraseID:String = phrase.match(phraseRE)[1];
			
			return resourceManager.getString(typeName, phraseID);
		}
		
		private var _data:String = '';
		private function validHandler(vdEvt:ValidationResultEvent):void
		{
			if (vdEvt.type == ValidationResultEvent.VALID)
	           	_data = inputText.text;
	           	
		}

		public function get xmlData():XML
		{
			var outXML:XML = new XML("<Parameter>" + _data+ "</Parameter>");
			outXML.@ScriptName = _scriptName;
			return outXML;
		}
		
		public function set value(str:String):void
		{
			_data = str;
			inputText.text = str;
		}
		
		public function get scriptName():String
		{
			return _scriptName;
		}

	
	}
}