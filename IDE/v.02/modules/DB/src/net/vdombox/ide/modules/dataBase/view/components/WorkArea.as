package net.vdombox.ide.modules.dataBase.view.components
{
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	import mx.events.FlexEvent;
	import mx.graphics.SolidColor;
	import mx.utils.ObjectUtil;
	
	import net.vdombox.components.tabNavigatorClasses.Tab;
	import net.vdombox.components.tabNavigatorClasses.TabNavigator;
	import net.vdombox.ide.common.events.WorkAreaEvent;
	import net.vdombox.ide.common.model.vo.ObjectVO;
	import net.vdombox.ide.common.model.vo.PageVO;
	import net.vdombox.ide.modules.dataBase.interfaces.IEditor;
	
	import spark.primitives.Rect;

	public class WorkArea extends net.vdombox.components.tabNavigatorClasses.TabNavigator
	{
		private var _editors : Dictionary;
		
		public function WorkArea()
		{
			addEventListener( "selectedTabChanged", selectedTabChangedHandler );
			addEventListener( "tabAdded", numTabChangedHandler );
			addEventListener( "tabRemoved", numTabChangedHandler );
		}
		
		public function openEditor( objectVO : Object ) : IEditor
		{
			var editor : DataTable = new DataTable();
			editor.percentHeight = 100;
			editor.percentWidth = 100;
			editor.objectVO = objectVO;
			
			var tab : Tab = new Tab();
			tab.id = objectVO.id;
			tab.label = objectVO.name;
			
			addTab( tab );
			
			tab.addElement( editor );
			
			if ( !_editors )
				_editors = new Dictionary( true );
			
			_editors[ editor ] = tab;
			
			selectedEditor = editor;
			
			return editor;
		}
		
		public function closeEditor( objectVO : Object ) : IEditor
		{
			var result : IEditor;
			var tab : Tab;
			
			result = getEditorByVO( objectVO );
			
			if ( result )
				delete _editors[ result ];
			
			return result;
		}
		
		public function closeTab( objectVO : Object ) : IEditor
		{
			var result : IEditor;
			var tab : Tab;
			
			result = getEditorByVO( objectVO );
			
			if ( result )
			{
				removeTab( _editors[ result ] );
			}
			
			return result;
		}
		
		public function closeAllEditors() : void
		{
			//			затычка нада разобраться в чем дело
			if (tabBar.dataProvider == null )
				return 
			
			var tab : Tab;
			
			_editors = null;
			while ( tabBar.dataProvider.length  > 0 ) 
			{
				tab = tabBar.dataProvider.getItemAt( 0 ) as Tab;
				removeTab( tab );
			}			
		}
		
		public function getEditorByVO( objectVO : Object ) : IEditor
		{
			var result : IEditor;
			var editor : *;
			
			if ( !objectVO )
				return null;
			
			for ( editor in _editors )
			{ 
				if ( editor.objectVO && editor.objectVO.id == objectVO.id )
				{
					result = editor;
					break;
				}
			}
			
			return result;
		}
		
		public function get selectedEditor() : IEditor
		{
			var result : IEditor;
			var editor : *;
			
			for ( editor in _editors )
			{
				if ( _editors[ editor ] == selectedTab )
				{
					result = editor as IEditor;
					break;
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
		
		
		private function numTabChangedHandler( event : Event ) : void
		{
			if( tabBar.dataProvider && tabBar.dataProvider.length == 0 )
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
		
	}
}