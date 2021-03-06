
package vdom.components.eventEditor
{
	import flash.events.MouseEvent;
	
	import mx.containers.Canvas;
	import mx.controls.HRule;
	import mx.controls.Image;
	import mx.controls.Label;
	import mx.controls.TextInput;
	import mx.controls.VRule;
	import mx.core.UIComponent;
	import mx.events.ValidationResultEvent;
	import mx.validators.RegExpValidator;
	
	import vdom.controls.multiline.MultilineWindow;
	import vdom.events.MultilineWindowEvent;
	import vdom.managers.PopUpWindowManager;

	public class AdvansedLayer extends Canvas
	{
		[Embed(source='/assets/eventEditor/eventEditor.swf', symbol='advansedLayer')]
		[Bindable]
		public var advansedLayer:Class;
		
		private var typeName:String;
		private var inputText:TextInput = new TextInput();
		private var _scriptName:String;
		
		public function AdvansedLayer(inXML:XML, typeName:String)
		{
			super();
			
			this.typeName = typeName;
			
		//	this.height = 40;
			
			_scriptName = inXML.@ScriptName;
			_data = inXML.@DefaultValue
			
			var img:Image = new Image();
				img.source = advansedLayer;
				img.x = 3;
				img.y = 2;
				img.width = 13;
				img.height = 13;
			addChild(img);

			var vRule:VRule = new VRule();
				vRule.x = 20;
				vRule.percentHeight = 100;
			addChild(vRule);
			
			
			var label:Label = new Label();
				label.text = _scriptName + ": ";
				label.width = 80;
				label.x = vRule.x;
				label.setStyle('textAlign', 'right')
			//	label.setStyle("fontWeight", 'bold');
			addChild(label);		
		
			
		//	var inputText:TextInput = new TextInput();
				
				inputText.text = _data;
				inputText.width = 64;
				inputText.height = 18;
				inputText.x = 100;
				inputText.setStyle("borderColor", "#DDDDDD");
				inputText.setStyle("borderStyle", "solid");
				inputText.setStyle("fontSize", '8');
				inputText.setStyle("fontWeight", 'bold');
				inputText.setStyle("textAlign", 'center');
				inputText.doubleClickEnabled = true;
				inputText.addEventListener(MouseEvent.DOUBLE_CLICK, showMultilineWindow);

			addChild(inputText);
				
			
			var hRule:HRule = new HRule();
				hRule.y = 19;
				hRule.percentWidth = 100;
			addChild(hRule);
			
			var regExpValidator:RegExpValidator = new RegExpValidator();
				regExpValidator.source = inputText;
				regExpValidator.property = 'text';
				
				regExpValidator.flags = "ms";
//				regExpValidator.flags  RegExp
				regExpValidator.expression = inXML.@RegularExpressionValidation;// "[0-9]+";
				regExpValidator.trigger = inputText;
				regExpValidator.addEventListener(ValidationResultEvent.VALID, validHandler);
				regExpValidator.noMatchError =getLanguagePhraseId(inXML.@Help);
				regExpValidator.triggerEvent = 'textChanged';
		}
		
		private function showMultilineWindow(msEvt:MouseEvent):void
		{
			var popUpWindowManager : PopUpWindowManager = PopUpWindowManager.getInstance();
			var multilineWindow : MultilineWindow = new MultilineWindow();
			multilineWindow.minWidth = 800;
			multilineWindow.minHeight = 600;
			multilineWindow.percentWidth = 100;
			multilineWindow.percentHeight = 100;
			
			multilineWindow.attributeValue = inputText.text;
			
			multilineWindow.addEventListener( "apply", multilineWindow_applyHandler,
								 false, 0, true );
			
			popUpWindowManager.addPopUp( multilineWindow, "Title", this, true );
		}
		
		private function multilineWindow_applyHandler( event:MultilineWindowEvent ):void
		{
			inputText.text = event.value;
			var currentTarget : Object = event.currentTarget;
			if ( currentTarget is MultilineWindow )
			{
				UIComponent( currentTarget ).removeEventListener( "apply",
																  multilineWindow_applyHandler,
																  false );
			}

			var popUpWindowManager : PopUpWindowManager = PopUpWindowManager.getInstance();
			popUpWindowManager.removePopUp( event.currentTarget );
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
			var outXML:XML = new XML("<Parameter/>");
			outXML.@ScriptName = _scriptName;
			outXML.appendChild(XML('<![CDATA[' +_data + ']'+']>'));
			
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