package net.vdombox.editors.parsers.vdomxml
{
	import flash.events.Event;

	import net.vdombox.editors.ScriptAreaComponent;
	import net.vdombox.editors.skins.ScriptEditorSkin;

	import spark.components.SkinnableContainer;

	public class XMLScriptEditor extends SkinnableContainer
	{
		public function XMLScriptEditor()
		{
			setStyle( "skinClass", net.vdombox.editors.skins.ScriptEditorSkin );
		}

		[SkinPart( required = "true" )]
		public var scriptAreaComponent : ScriptAreaComponent;

		private var controller : VdomXMLController;

		private var fileName : String;

		private var assistMenu : AssistMenuVdomXML;

		public function loadSource( source : String, filePath : String ) : void
		{
			scriptAreaComponent.text = source.replace( /(\n|\r\n)/g, '\r' );
			fileName = filePath;

			if ( controller )
				controller.sourceChanged( scriptAreaComponent.text, fileName );
		}

		override protected function partAdded( partName : String, instance : Object ) : void
		{
			super.partAdded( partName, instance );

			if ( instance == scriptAreaComponent )
				initiaize();
		}

		private function initiaize() : void
		{
			controller = new VdomXMLController( stage, scriptAreaComponent );

			controller.addEventListener( "status", controller_statusHandler, false, 0, true );

			assistMenu = new AssistMenuVdomXML( scriptAreaComponent, controller, stage, assistCompleteHandler );

			scriptAreaComponent.addEventListener( Event.CHANGE, changeHandler );
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
	}
}
