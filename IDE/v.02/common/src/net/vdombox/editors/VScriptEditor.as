package net.vdombox.editors
{
	import flash.events.Event;
	
	import net.vdombox.editors.parsers.vscript.AssistMenuVScript;
	import net.vdombox.editors.parsers.vscript.AutoCompleteCodeBlockVScript;
	import net.vdombox.editors.parsers.vscript.VScriptController;
	import net.vdombox.editors.skins.ScriptEditorSkin;
	import net.vdombox.ide.common.interfaces.IEventBaseVO;

	public class VScriptEditor extends BaseScriptEditor
	{
		public function VScriptEditor()
		{
			setStyle( "skinClass", net.vdombox.editors.skins.ScriptEditorSkin );
			
			addEventListener( Event.ADDED_TO_STAGE, addedToStageHadler, false, 0, true );
		}
		
		private var controller : VScriptController;
		private var fileName : String;
		private var autoCompleteCodeBlock : AutoCompleteCodeBlockVScript;
		
		public override function loadSource( source : String, filePath : String ) : void
		{
			scriptAreaComponent.text = source.replace( /(\n|\r\n)/g, '\r' );
			fileName = filePath;
			
			if ( controller )
				controller.sourceChanged( scriptAreaComponent.text, fileName );
		}
		
		protected override function initiaize() : void
		{
			controller = new VScriptController( stage, scriptAreaComponent, _actionVO );
			
			controller.addEventListener( "status", controller_statusHandler, false, 0, true );
			
			if ( assistMenu )
				assistMenu.clear();
			
			assistMenu = new AssistMenuVScript( scriptAreaComponent, controller, stage, assistCompleteHandler );
			
			autoCompleteCodeBlock = new AutoCompleteCodeBlockVScript( scriptAreaComponent, controller, assistMenu );
			
			addEventListener( Event.CHANGE, changeHandler );
			controller.sourceChanged( scriptAreaComponent.text, "zz" );
			
			scriptAreaComponent.controller = controller;
		}
		
		private function controller_statusHandler( event : Event ) : void
		{
			dispatchEvent( new Event( "status" ) );
		}
		
		private function changeHandler( event : Event ) : void
		{
			controller.sourceChanged( scriptAreaComponent.text, "zz" );
		}
		
		private function assistCompleteHandler() : void
		{
			controller.sourceChanged( scriptAreaComponent.text, "zz" );
		}
		
		public override function set actionVO( value : IEventBaseVO ) : void
		{
			_actionVO = value;
			controller.actionVO = value;
		}
	}
}