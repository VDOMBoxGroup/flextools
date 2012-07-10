package net.vdombox.editors
{
	import flash.events.Event;
	
	import net.vdombox.editors.parsers.vscript.AssistMenuVScript;
	import net.vdombox.editors.parsers.vscript.Controller;
	import net.vdombox.editors.skins.ScriptEditorSkin;
	import net.vdombox.ide.common.interfaces.IEventBaseVO;

	public class VScriptEditor extends BaseScriptEditor
	{
		public function VScriptEditor()
		{
			setStyle( "skinClass", net.vdombox.editors.skins.ScriptEditorSkin );
			
			addEventListener( Event.ADDED_TO_STAGE, addedToStageHadler, false, 0, true );
		}
		
		private var controller : Controller;
		private var fileName : String;
		
		public override function loadSource( source : String, filePath : String ) : void
		{
			scriptAreaComponent.text = source.replace( /(\n|\r\n)/g, '\r' );
			fileName = filePath;
			
			if ( controller )
				controller.sourceChanged( scriptAreaComponent.text, fileName );
		}
		
		protected override function initiaize() : void
		{
			controller = new Controller( stage, scriptAreaComponent );
			
			controller.addEventListener( "status", controller_statusHandler, false, 0, true );
			
			assistMenu = new AssistMenuVScript( scriptAreaComponent, controller, stage, assistCompleteHandler );
			
			addEventListener( Event.CHANGE, changeHandler );
			controller.sourceChanged( scriptAreaComponent.text, "zz" );
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
		
		public override function set hashLibraryArray( hashLibraries : HashLibraryArray ) : void
		{
			controller.hashLibraryArray = hashLibraries;
		}
		
		public override function set actionVO( actionVO : IEventBaseVO ) : void
		{
			controller.actionVO = actionVO;
		}
	}
}