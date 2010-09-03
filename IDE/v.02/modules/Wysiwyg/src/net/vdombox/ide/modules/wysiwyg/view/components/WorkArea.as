package net.vdombox.ide.modules.wysiwyg.view.components
{
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	import mx.core.ClassFactory;
	import mx.core.IFactory;
	import mx.core.IVisualElement;
	import mx.core.UIComponent;
	import mx.utils.UIDUtil;
	
	import net.vdombox.components.TabNavigator;
	import net.vdombox.components.tabNavigatorClasses.Tab;
	import net.vdombox.components.tabNavigatorClasses.TabBarButton;
	import net.vdombox.ide.common.interfaces.IVDOMObjectVO;
	import net.vdombox.ide.common.vo.ObjectVO;
	import net.vdombox.ide.common.vo.PageVO;
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

		public function get selectedEditor() : IEditor
		{
			var result : IEditor;
			var editor : *;

			var sTab : Tab = selectedTab;

			for ( editor in _editors )
			{
				if ( _editors[ editor ] == sTab )
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

			tab = _editors[ value ];

			if ( tab )
				selectedTab = tab;
		}

		public function getEditorByVO( vdomObjectVO : IVDOMObjectVO ) : IEditor
		{
			var result : IEditor;
			var editor : *;

			if ( !vdomObjectVO )
				return null;

			for ( editor in _editors )
			{
				if ( editor.vdomObjectVO && editor.vdomObjectVO.id == vdomObjectVO.id )
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

			var uid : String = UIDUtil.createUID();

			if ( vdomObjectVO is PageVO )
			{
				editor = new PageEditor();
				UIComponent( editor ).id = "pageEditor_" + uid
			}
			else if ( vdomObjectVO is ObjectVO )
			{
				editor = new ObjectEditor();
				UIComponent( editor ).id = "objectEditor_" + uid
			}

			editor.vdomObjectVO = vdomObjectVO;

			var tab : Tab = new Tab();

			tab.id = "tab_" + uid;
			tab.label = vdomObjectVO.name;

			addTab( tab );

			tab.addElement( editor as IVisualElement );

			if ( !_editors )
				_editors = new Dictionary( true );

			_editors[ editor ] = tab;

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
			dispatchEvent( new WorkAreaEvent( WorkAreaEvent.CHANGE ) );
		}
	}
}