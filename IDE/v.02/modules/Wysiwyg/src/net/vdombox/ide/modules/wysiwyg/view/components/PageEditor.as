package net.vdombox.ide.modules.wysiwyg.view.components
{
	import flash.events.Event;

	import net.vdombox.editors.XMLScriptEditor;
	import net.vdombox.ide.modules.wysiwyg.events.SkinPartEvent;
	import net.vdombox.ide.modules.wysiwyg.view.skins.PageEditorSkin;

	import spark.components.supportClasses.SkinnableComponent;

	[SkinState("wysiwyg")] 
	[SkinState("wysiwygDisabled")]
	[SkinState("xml")] 
	[SkinState("xmlDisabled")]
	
	public class PageEditor extends SkinnableComponent
	{
		public function PageEditor()
		{
			setStyle( "skinClass", PageEditorSkin );

			percentWidth = 100;
			percentHeight = 100;

			addEventListener( Event.ADDED_TO_STAGE, addedToStageHandler, false, 0, true );
		}

		[SkinPart( required="true" )]
		public var pageRenderer : PageRenderer;

		[SkinPart( required="true" )]
		public var xmlScriptEditor : XMLScriptEditor;

		override protected function partAdded( partName : String, instance : Object ) : void
		{
			super.partAdded( partName, instance );
			
			var event : SkinPartEvent = new SkinPartEvent( SkinPartEvent.PART_ADDED );
			event.partName = partName;
			event.instance = instance;
			dispatchEvent( event );
		}

		private function addHandlers() : void
		{

		}

		private function removeHandlers() : void
		{

		}

		private function addedToStageHandler( event : Event ) : void
		{
			addEventListener( Event.REMOVED_FROM_STAGE, removedFromStageHandler, false, 0, true );

			addHandlers();
		}

		private function removedFromStageHandler( event : Event ) : void
		{
			removeEventListener( Event.ADDED_TO_STAGE, addedToStageHandler );
			removeEventListener( Event.REMOVED_FROM_STAGE, removedFromStageHandler );

			removeHandlers();
		}
	}
}