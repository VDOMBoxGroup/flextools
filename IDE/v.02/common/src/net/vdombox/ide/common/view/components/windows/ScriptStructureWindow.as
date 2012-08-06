package net.vdombox.ide.common.view.components.windows
{
	import flash.display.NativeWindowSystemChrome;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	import mx.controls.Tree;
	
	import net.vdombox.ide.common.events.ItemRendererEvent;
	import net.vdombox.ide.common.events.PopUpWindowEvent;
	import net.vdombox.ide.common.view.components.itemrenderers.ScriptStructureTreeItemRenderer;
	import net.vdombox.ide.common.view.skins.windows.ScriptStructureWindowSkin;
	
	import ro.victordramba.util.HashMap;
	
	import spark.components.Window;

	public class ScriptStructureWindow extends Window
	{
		[SkinPart( required="true" )]
		public var structureTree : Tree;
		
		public var structure : HashMap;
		
		public function ScriptStructureWindow()
		{
			super();
			
			systemChrome	= NativeWindowSystemChrome.NONE;
			transparent 	= true;
			
			width = 400;
			height = 650;
			
			minWidth = 400;
			minHeight = 300;
			
			this.setFocus();
			
			addEventListener( KeyboardEvent.KEY_DOWN, keyDownEnterEscHandler, true, 0 , true );
		}
		
		override public function stylesInitialized():void {
			super.stylesInitialized();
			this.setStyle( "skinClass", ScriptStructureWindowSkin );
		}
		
		public function addHandlers() : void
		{
			structureTree.addEventListener(ItemRendererEvent.DOUBLE_CLICK, doubleClickHandler, true, 0, false );
		}
		
		private function doubleClickHandler( event : ItemRendererEvent ) : void
		{
			var selectedElement : XML = ( event.target as ScriptStructureTreeItemRenderer ).data as XML;
			var detail : Object = { pos : selectedElement.@pos, len : selectedElement.@len };
			ok_close_window( detail );
		}
		
		private function keyDownEnterEscHandler( event : KeyboardEvent ) : void
		{
			if ( event.keyCode == Keyboard.ENTER )
				ok_close_window();
			else if ( event.keyCode == Keyboard.ESCAPE )
				no_close_window();
		}
		
		public function ok_close_window( detail : Object = null ) : void
		{
			dispatchEvent( new PopUpWindowEvent( PopUpWindowEvent.APPLY, null, "", detail ) );
		}
		
		public function no_close_window(event: KeyboardEvent = null ) : void
		{
			dispatchEvent( new PopUpWindowEvent( PopUpWindowEvent.CANCEL ) );
		}
	}
}