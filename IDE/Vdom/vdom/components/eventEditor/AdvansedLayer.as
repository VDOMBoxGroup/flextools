
package vdom.components.eventEditor
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.containers.Canvas;
	import mx.controls.HRule;
	import mx.controls.Image;
	import mx.controls.Label;
	import mx.controls.TextInput;
	import mx.controls.VRule;
	import mx.validators.RegExpValidator;

	public class AdvansedLayer extends Canvas
	{
		[Embed(source='/assets/treeEditor/treeEditor.swf', symbol='delete')]
		[Bindable]
		public var delet:Class;
		
		private var typeName:String;
		
		public function AdvansedLayer(inXMK:XML, typeName:String)
		{
			super();
			
			this.typeName = typeName;
			
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
				label.text = inXMK.@ScriptName + ": ";
				label.width = 75;
				label.x = vRule.x;
				label.setStyle('textAlign', 'right')
			//	label.setStyle("fontWeight", 'bold');
			addChild(label);		
			/*
			var vRule2:VRule = new VRule();
				vRule2.x = 130;
				vRule2.percentHeight = 100;
			addChild(vRule2);
			/*
			var label2:Label = new Label();
				label2.text = inXMK.@DefaultValue;
				label2.width = 45;
				label2.x = vRule2.x;
				label2.setStyle('textAlign', 'center');
			addChild(label2);
			label2.addEventListener(MouseEvent.CLICK, labelClickHandler);
			*/
			
			var inputText:TextInput = new TextInput();
				inputText.text = inXMK.@DefaultValue;
				inputText.width = 65;
				inputText.height = 18;
				inputText.x = 100;
				//inputText.y = -1;
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
				regExpValidator.noMatchError =getLanguagePhraseId(inXMK.@Help);
				regExpValidator.triggerEvent = Event.CHANGE;
		}
		
		
		private function getLanguagePhraseId(phrase:String):String 
		{
			var phraseRE:RegExp = /#Lang\((\w+)\)/;
			var phraseID:String = phrase.match(phraseRE)[1];
			
			return resourceManager.getString(typeName, phraseID);
		}

		//private 
		private function labelClickHandler(msEvt:MouseEvent):void
		{
			//inputText.visible = true;
		}
	}
}