package view
{
	import flash.events.Event;

	import parsers.python.Controller;

	import spark.components.SkinnableContainer;

	import view.skins.ScriptEditorSkin;

	public class ScriptEditor extends SkinnableContainer
	{
		public function ScriptEditor()
		{
			setStyle( "skinClass", ScriptEditorSkin );

			addEventListener( Event.ADDED_TO_STAGE, addedToStageHadler, false, 0, true );
		}

		[SkinPart( required="true" )]
		public var scriptAreaComponent : ScriptAreaComponent;

		private var controller : Controller;
		private var fileName : String;
		private var assistMenu : AssistMenu;

		public function loadSource( source : String, filePath : String ) : void
		{
			scriptAreaComponent.text = source.replace( /(\n|\r\n)/g, '\r' );
			fileName = filePath;

			if ( controller )
				controller.sourceChanged( scriptAreaComponent.text, fileName );
		}

		private function initiaize() : void
		{
			controller = new Controller( stage, scriptAreaComponent );

			controller.addEventListener( "status", controller_statusHandler, false, 0, true );

			assistMenu = new AssistMenu( scriptAreaComponent, controller, stage, assistCompleteHandler );

			addEventListener( Event.CHANGE, changeHandler );
			controller.sourceChanged( scriptAreaComponent.text, "zz" );
		}

		private function addedToStageHadler( event : Event ) : void
		{
			if ( scriptAreaComponent )
				initiaize();
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
	}
}