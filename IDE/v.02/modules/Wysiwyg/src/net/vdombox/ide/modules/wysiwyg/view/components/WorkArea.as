package net.vdombox.ide.modules.wysiwyg.view.components
{
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.utils.Dictionary;
	
	import mx.binding.utils.BindingUtils;
	import mx.collections.ArrayList;
	import mx.core.ClassFactory;
	import mx.core.IFactory;
	import mx.core.IVisualElement;
	import mx.core.UIComponent;
	import mx.utils.UIDUtil;
	
	import net.vdombox.ide.common.interfaces.IVDOMObjectVO;
	import net.vdombox.ide.common.model._vo.ObjectVO;
	import net.vdombox.ide.common.model._vo.PageVO;
	import net.vdombox.ide.common.view.components.tabnavigator.Tab;
	import net.vdombox.ide.common.view.components.tabnavigator.TabBarButton;
	import net.vdombox.ide.common.view.components.tabnavigator.TabNavigator;
	import net.vdombox.ide.modules.wysiwyg.events.EditorEvent;
	import net.vdombox.ide.modules.wysiwyg.events.WorkAreaEvent;
	import net.vdombox.ide.modules.wysiwyg.interfaces.IEditor;

	public class WorkArea extends TabNavigator
	{
		public function WorkArea()
		{
			addEventListener( "selectedTabChanged", selectedTabChangedHandler );
			addEventListener( "tabAdded", numTabChangedHandler );
			addEventListener( "tabRemoved", numTabChangedHandler );
		}

		private var _editors : Dictionary;

		public function get editors():Dictionary
		{
			return _editors;
		}

		public function set editors(value:Dictionary):void
		{
			_editors = value;
		}

		public function get selectedEditor() : IEditor
		{
			var result : IEditor;
			var editor : *;

			var sTab : Tab = selectedTab;

			for ( editor in editors )
			{
				if ( editors[ editor ] == sTab )
				{
					result = editor as IEditor;
				}
			}

			return result;
		}

		public function set selectedEditor( value : IEditor ) : void
		{
			if ( !value )
				return;

			var tab : Tab;

			tab = editors[ value ];

			if ( tab )
 				selectedTab = tab;
		}

		public function getEditorByVO( vdomObjectVO : IVDOMObjectVO ) : IEditor
		{
			var result : IEditor;
			var editor : *;

			if ( !vdomObjectVO )
				return null;

			for ( editor in editors )
			{ 
				if ( editor.editorVO.vdomObjectVO && editor.editorVO.vdomObjectVO.id == vdomObjectVO.id )
				{
					result = editor;
					break;
				}
			}

			return result;
		}

		public function openEditor( vdomObjectVO : IVDOMObjectVO ) : IEditor
		{
			var editor : IEditor = getEditorByVO( vdomObjectVO );
			if ( editor )
				return editor;
			editor = new VdomObjectEditor();
			editor.editorVO.vdomObjectVO = vdomObjectVO;
			
//			
//			if ( vdomObjectVO is PageVO )
//			{
//				editor = new PageEditor();
//				UIComponent( editor ).id = "pageEditor_" + uid
//			}
//			else if ( vdomObjectVO is ObjectVO )
//			{
//				editor = new _ObjectEditor();
//				UIComponent( editor ).id = "objectEditor_" + uid
//			}
			
			var tab : Tab = new Tab();
			tab.label = vdomObjectVO.name;
			
			IEventDispatcher( editor ).addEventListener( EditorEvent.VDOM_OBJECT_VO_CHANGED, editor_objectChangedHandler, false, 0, true );
			
			addTab( tab );
			
			tab.addElement( editor as IVisualElement );
			
//			tab.id = "tab_" + uid;
			
			if ( !editors )
				editors = new Dictionary( true );

			editors[ editor ] = tab;
			
			selectedEditor = editor;
			return editor;
		}

		public function closeEditor( vdomObjectVO : IVDOMObjectVO ) : IEditor
		{
			var result : IEditor;
			var tab : Tab;

			result = getEditorByVO( vdomObjectVO );

			if ( result )
			{
				tab = _editors[ result ];
				removeTab( tab );

				delete _editors[ result ];
			}

			return result;
		}

		public function closeAllEditors() : void
		{
			//			затычка нада разобраться в чем дело
			if (tabBar.dataProvider == null )
				return 
			
			var tab : Tab;
			while ( tabBar.dataProvider.length  > 0 ) 
			{
				tab = tabBar.dataProvider.getItemAt( 0 ) as Tab;
				removeTab( tab );
			}			
		}
		
		private function numTabChangedHandler( event : Event ) : void
		{
			if( !tabBar.dataProvider || tabBar.dataProvider.length == 0 )
				return;
			
			var tab0 : Tab = tabBar.dataProvider.getItemAt( 0 ) as Tab;
			var tab1 : Tab
			
			if( tabBar.dataProvider.length == 1 )
			{
				tab0.closable = false;
			}
			else if( tabBar.dataProvider.length == 2 )
			{
				tab0.closable = true;
				
				tab1 = tabBar.dataProvider.getItemAt( 1 ) as Tab;
				if( tab1 )
					tab1.closable = true;
			}
		}

		private function selectedTabChangedHandler( event : Event ) : void
		{
			// CHANGE
			dispatchEvent( new WorkAreaEvent( WorkAreaEvent.CHANGE ) );
		}
		
		private function editor_objectChangedHandler( event : EditorEvent ) : void
		{
			
		}
	}
}