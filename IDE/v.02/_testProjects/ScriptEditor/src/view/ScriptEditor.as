package view
{
	import flash.events.Event;
	
	import pyparser.Controller;
	
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

		private function initiaize() : void
		{
			controller = new Controller( stage, scriptAreaComponent );

			controller.addEventListener( "status", controller_statusHandler, false, 0, true );

//			assistMenu = new AssistMenu( this, ctrl, stage, onAssistComplete );

			addEventListener( Event.CHANGE, changeHandler );
		}
		
		private function addedToStageHadler( event : Event ) : void
		{
			if( scriptAreaComponent )
				initiaize();
		}
		
		private function controller_statusHandler( event : Event ) : void
		{
			dispatchEvent( new Event( "status" ) );
		}
		
		private function changeHandler ( event : Event ) : void
		{
			controller.sourceChanged(scriptAreaComponent.text, "zz");
		}
	}
}