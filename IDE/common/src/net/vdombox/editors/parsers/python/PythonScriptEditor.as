package net.vdombox.editors.parsers.python
{
	import flash.events.Event;

	import net.vdombox.editors.parsers.base.BaseScriptEditor;
	import net.vdombox.ide.common.interfaces.IEventBaseVO;

	public class PythonScriptEditor extends BaseScriptEditor
	{
		public function PythonScriptEditor()
		{
			super();
			//addEventListener( Event.ADDED_TO_STAGE, addedToStageHadler, false, 0, true );
		}

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
			/*
			   if ( controller )
			   return;
			 */

			_controller = new PythonController( stage, scriptAreaComponent, _actionVO );

			controller.addEventListener( "status", controller_statusHandler, false, 0, true );

			if ( assistMenu )
				assistMenu.clear();

			assistMenu = new AssistMenuPython( scriptAreaComponent, controller as PythonController, stage, assistCompleteHandler );

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

		public override function set actionVO( value : Object ) : void
		{
			_actionVO = value;
			controller.actionVO = _actionVO;
		}
	}
}
