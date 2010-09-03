package net.vdombox.ide.modules.wysiwyg.view.components
{
	import flash.events.Event;
	
	import mx.binding.utils.ChangeWatcher;
	import mx.events.FlexEvent;
	import mx.events.StateChangeEvent;
	
	import net.vdombox.editors.XMLScriptEditor;
	import net.vdombox.ide.common.interfaces.IVDOMObjectVO;
	import net.vdombox.ide.modules.wysiwyg.events.EditorEvent;
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

			addEventListener( FlexEvent.CREATION_COMPLETE, createionCompleteHandler, false, 0, true );
		}

		[SkinPart( required="true" )]
		public var renderer : IRenderer;

		[SkinPart( required="true" )]
		public var xmlScriptEditor : XMLScriptEditor;

		private var _vdomObjectVO : IVDOMObjectVO;

		private var _xml : String;
		
		public function get vdomObjectVO() : IVDOMObjectVO
		{
			return _vdomObjectVO;
		}

		public function set vdomObjectVO( value : IVDOMObjectVO ) : void
		{
			_vdomObjectVO = value;
		}

		public function get xml() : String
		{
			return xmlScriptEditor ? xmlScriptEditor.scriptAreaComponent.text : _xml;
		}
		
		public function set xml( value : String ) : void
		{
			_xml = value;
			
			if( xmlScriptEditor )
				xmlScriptEditor.scriptAreaComponent.text = value;
		}
		
		override protected function partAdded( partName : String, instance : Object ) : void
		{
			super.partAdded( partName, instance );

			if( instance == xmlScriptEditor )
			{
				xmlScriptEditor.scriptAreaComponent.text = _xml;
			}
			
			var event : SkinPartEvent = new SkinPartEvent( SkinPartEvent.PART_ADDED );
			event.partName = partName;
			event.instance = instance;
			dispatchEvent( event );
		}

		private function addHandlers() : void
		{
			addEventListener( Event.REMOVED_FROM_STAGE, removedFromStageHandler, false, 0, true );

			skin.addEventListener( StateChangeEvent.CURRENT_STATE_CHANGE, changeStateHandler, false, 0, true );
		}

		private function removeHandlers() : void
		{
			removeEventListener( Event.REMOVED_FROM_STAGE, removedFromStageHandler );

			skin.removeEventListener( StateChangeEvent.CURRENT_STATE_CHANGE, changeStateHandler );
		}

		private function dispatchStateEvent() : void
		{
			if ( skin.currentState.substr( 0, 7 ) == "wysiwyg" )
				dispatchEvent( new EditorEvent( EditorEvent.WYSIWYG_OPENED ) )
			else if ( skin.currentState.substr( 0, 3 ) == "xml" )
				dispatchEvent( new EditorEvent( EditorEvent.XML_EDITOR_OPENED ) )
		}

		private function createionCompleteHandler( event : FlexEvent ) : void
		{
			removeEventListener( FlexEvent.CREATION_COMPLETE, createionCompleteHandler );

			addHandlers();

			dispatchEvent( new EditorEvent( EditorEvent.CREATED ) );

			dispatchStateEvent();
		}

		private function removedFromStageHandler( event : Event ) : void
		{
			removeHandlers();
		}

		private function changeStateHandler( event : StateChangeEvent ) : void
		{
			dispatchStateEvent();
		}
	}
}