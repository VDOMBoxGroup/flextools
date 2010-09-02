package net.vdombox.ide.modules.wysiwyg.view.components
{
	import flash.events.Event;
	
	import net.vdombox.editors.XMLScriptEditor;
	import net.vdombox.ide.common.interfaces.IVDOMObjectVO;
	import net.vdombox.ide.modules.wysiwyg.events.SkinPartEvent;
	import net.vdombox.ide.modules.wysiwyg.interfaces.IEditor;
	import net.vdombox.ide.modules.wysiwyg.interfaces.IRenderer;
	import net.vdombox.ide.modules.wysiwyg.view.skins.ObjectEditorSkin;
	
	import spark.components.supportClasses.SkinnableComponent;

	public class ObjectEditor extends SkinnableComponent implements IEditor
	{
		public function ObjectEditor()
		{
			setStyle( "skinClass", ObjectEditorSkin );

			percentWidth = 100;
			percentHeight = 100;

			addEventListener( Event.ADDED_TO_STAGE, addedToStageHandler, false, 0, true );
		}

		[SkinPart( required="true" )]
		public var renderer : IRenderer;

		[SkinPart( required="true" )]
		public var xmlScriptEditor : XMLScriptEditor;

		private var _vdomObjectVO : IVDOMObjectVO;
		
		public function get vdomObjectVO() : IVDOMObjectVO
		{
			return _vdomObjectVO;
		}
		
		public function set vdomObjectVO( value : IVDOMObjectVO ) : void
		{
			_vdomObjectVO = value;
		}
		
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