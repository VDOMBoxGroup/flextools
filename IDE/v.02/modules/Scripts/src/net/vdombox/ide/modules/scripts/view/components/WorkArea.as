package net.vdombox.ide.modules.scripts.view.components
{
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	import mx.containers.ViewStack;
	
	import net.vdombox.ide.common.events.WorkAreaEvent;
	import net.vdombox.ide.common.model._vo.ServerActionVO;
	import net.vdombox.ide.common.view.components.tabnavigator.Tab;
	import net.vdombox.ide.common.view.components.tabnavigator.TabNavigator;

	public class WorkArea extends ViewStack
	{
		
		private var _editors : Dictionary;
		
		private var _selectedEditor : ScriptEditor;
		
		public function WorkArea()
		{
		}
		
		private function scriptEditorName( actionVO : Object ) : String
		{
			if ( actionVO is ServerActionVO )
				return actionVO.name + actionVO.containerID;
			else
				return actionVO.name;
		}
		
		public function openEditor( objectVO : Object, actionVO : Object ) : ScriptEditor
		{
			var editor : ScriptEditor = new ScriptEditor();
			editor.percentHeight = 100;
			editor.percentWidth = 100;
			
			addChild( editor );
			selectedEditor = editor;
			
			editor.actionVO = actionVO;
			editor.objectVO = objectVO;
			
			editor.id = scriptEditorName( actionVO );
			
			
			
			if ( !_editors )
				_editors = new Dictionary( true );
			
			_editors[ editor ] = editor;
			
			
			
			return editor;
		}
		
		public function closeEditor( actionVO : Object ) : ScriptEditor
		{
			var result : ScriptEditor;
			var tab : Tab;
			
			result = getEditorByVO( actionVO );
			
			if ( result )
			{
				delete _editors[ result ];
				removeChild( result );
			}
			
			return result;
		}
		
		public function getEditorByVO( actionVO : Object ) : ScriptEditor
		{
			var result : ScriptEditor;
			var editor : *;
			
			if ( !actionVO )
				return null;
			
			if ( actionVO is ServerActionVO )
			{
				for ( editor in _editors )
				{ 
					if ( editor.actionVO is ServerActionVO && editor.actionVO.id == actionVO.id )
					{
						result = editor;
						break;
					}
				}
			}
			else 
			{
				for ( editor in _editors )
				{ 
					if ( !(editor.actionVO is ServerActionVO) && editor.actionVO.name == actionVO.name )
					{
						result = editor;
						break;
					}
				}
			}
			
			return result;
		}
		
		public function closeAllEditors() : void
		{
			/*//			затычка нада разобраться в чем дело
			if (tabBar.dataProvider == null )
				return 
			
			var tab : Tab;
			while ( tabBar.dataProvider.length  > 0 ) 
			{
				tab = tabBar.dataProvider.getItemAt( 0 ) as Tab;
				removeTab( tab );
			}		*/	
		}
		
		public function get selectedEditor() : ScriptEditor
		{
			return _selectedEditor;
		}
		
		public function set selectedEditor( value : ScriptEditor ) : void
		{
			if ( !value )
				return;
			
			_selectedEditor = value;
			selectedChild = value;
			
		}
	}
}