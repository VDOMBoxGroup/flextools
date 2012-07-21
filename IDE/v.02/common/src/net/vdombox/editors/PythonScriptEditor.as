package net.vdombox.editors
{
	import flash.events.Event;
	
	import net.vdombox.editors.parsers.python.AssistMenuPython;
	import net.vdombox.editors.parsers.python.PythonController;
	import net.vdombox.editors.parsers.vdomxml.AssistMenuVdomXML;
	import net.vdombox.editors.skins.ScriptEditorSkin;
	import net.vdombox.ide.common.interfaces.IEventBaseVO;

	public class PythonScriptEditor extends BaseScriptEditor
	{
		public function PythonScriptEditor()
		{
			super();
			addEventListener( Event.ADDED_TO_STAGE, addedToStageHadler, false, 0, true );
		}

		private var controller : PythonController;
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
			/*if ( controller )
				return;*/
			
			controller = new PythonController( stage, scriptAreaComponent, _actionVO );

			controller.addEventListener( "status", controller_statusHandler, false, 0, true );
			
			if ( assistMenu )
				assistMenu.clear();

			assistMenu = new AssistMenuPython( scriptAreaComponent, controller, stage, assistCompleteHandler );

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
			controller.actionVO = _actionVO;
		}
	}
}