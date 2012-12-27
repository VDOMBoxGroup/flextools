package net.vdombox.ide.modules.wysiwyg.view.components.toolbars.richTextToolbarClasses
{
	import flash.display.NativeWindowSystemChrome;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	import mx.events.FlexEvent;
	
	import net.vdombox.utils.WindowManager;
	
	import spark.components.TextArea;
	import spark.components.Window;

	public class CodeEditorWindow extends Window
	{
		public function CodeEditorWindow()
		{
			systemChrome = NativeWindowSystemChrome.NONE;
			transparent = true;
			
			width = 500;
			height = 400;
			
			minWidth = 500;
			minHeight = 400;
			
			this.setFocus();			
			
			addEventListener(FlexEvent.CREATION_COMPLETE, addHandlers);
			addEventListener( Event.CLOSE, closeWithoutSave );
		}		
		public static const EVENT_CODE_CHANGED : String = "codeChanged";
		
		[Bindable]
		public var codeText : String
		
		[SkinPart( required = "true" )]
		public var _code : TextArea;
		
		override public function stylesInitialized() : void
		{
			super.stylesInitialized();
			this.setStyle( "skinClass", CodeEditorWindowSkin );
		}
		
		public function set code( value : String ) : void
		{
			codeText = value;
		}
		
		public function get code() : String
		{
			return _code.text;
		}
		
		public function closeWithSave() : void
		{
			this.dispatchEvent(new Event(EVENT_CODE_CHANGED));
			
			closeHandler();
		}
		
		public function closeWithoutSave( event : Event = null ) : void
		{
			closeHandler();
		}
		
		private function closeHandler():void
		{
			removeHandlers();
			
			removeEventListener( Event.CLOSE, closeWithoutSave );
			WindowManager.getInstance().removeWindow(this);
		}
		
		private function addHandlers(event : FlexEvent) : void
		{
			removeEventListener(FlexEvent.CREATION_COMPLETE, addHandlers );
			
			addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		}
		
		private function removeHandlers() : void
		{
			removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		}
		
		private function onKeyDown(keyEvent : KeyboardEvent):void
		{
			switch(keyEvent.keyCode)
			{
				case Keyboard.ESCAPE:
				{
					keyEvent.stopImmediatePropagation();
					
					closeWithoutSave();
					break;
				}
			}
			
		}
	}
}