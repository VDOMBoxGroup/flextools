package net.vdombox.ide.modules.wysiwyg.view.components
{
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.system.System;
	import flash.utils.Dictionary;

	import mx.core.IVisualElement;

	import net.vdombox.ide.common.interfaces.IVDOMObjectVO;
	import net.vdombox.ide.common.view.components.tabnavigator.Tab;
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

		private var editors : Dictionary;

		/*
		   public function get editors():Dictionary
		   {
		   return _editors;
		   }

		   public function set editors(value:Dictionary):void
		   {
		   _editors = value;
		   }
		 */

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

		public function removeEditor( vdomObjectVO : IVDOMObjectVO ) : IEditor
		{
			var result : IEditor = getEditorByVO( vdomObjectVO );

			if ( result )
				delete editors[ result ];

			return result;
		}

		public function closeEditor( vdomObjectVO : IVDOMObjectVO, forcibly : Boolean = true ) : IEditor
		{
			var result : IEditor = getEditorByVO( vdomObjectVO );

			if ( !forcibly && tabBar.dataProvider.length <= 1 )
				return result;

			if ( result )
			{
				var tab : Tab = editors[ result ];
				removeTab( tab );

				delete editors[ result ];

				dispatchEvent( new Event( "selectedTabChanged" ) );
			}

			return result;
		}

		public function closeAllEditors() : void
		{
			//			затычка нада разобраться в чем дело
			if ( tabBar.dataProvider == null )
				return;

			var tab : Tab;
			var editor : IEditor;

			while ( tabBar.dataProvider.length > 0 )
			{
				tab = tabBar.dataProvider.getItemAt( 0 ) as Tab;
				editor = tab.getElementAt( 0 ) as IEditor;
				removeTab( tab );

				delete editors[ editor ];
			}

			editors = null;

			System.gc();
		}

		private function numTabChangedHandler( event : Event ) : void
		{
			if ( !tabBar.dataProvider || tabBar.dataProvider.length == 0 )
				return;

			var tab0 : Tab = tabBar.dataProvider.getItemAt( 0 ) as Tab;
			var tab1 : Tab;

			if ( tabBar.dataProvider.length == 1 )
			{
				tab0.closable = false;
			}
			else if ( tabBar.dataProvider.length == 2 )
			{
				tab0.closable = true;

				tab1 = tabBar.dataProvider.getItemAt( 1 ) as Tab;
				if ( tab1 )
					tab1.closable = true;
			}
		}

		private function selectedTabChangedHandler( event : Event ) : void
		{
			dispatchEvent( new WorkAreaEvent( WorkAreaEvent.CHANGE ) );
		}

		private function editor_objectChangedHandler( event : EditorEvent ) : void
		{

		}
	}
}
