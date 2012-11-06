package net.vdombox.editors.parsers.base
{
	import flash.events.Event;
	
	import net.vdombox.editors.ScriptAreaComponent;
	import net.vdombox.editors.skins.ScriptEditorSkin;
	import net.vdombox.ide.common.interfaces.IEventBaseVO;
	
	import spark.components.SkinnableContainer;

	public class BaseScriptEditor extends SkinnableContainer
	{
		[SkinPart( required="true" )]
		public var scriptAreaComponent : ScriptAreaComponent;
		
		protected var assistMenu : AssistMenu;
		protected var _actionVO : Object;
		protected var _controller : Controller;
		
		public function BaseScriptEditor()
		{
			setStyle( "skinClass", net.vdombox.editors.skins.ScriptEditorSkin );
		}
		
		public function loadSource( source : String, filePath : String ) : void
		{
			
		}
		
		public function set actionVO( actionVO : Object ) : void
		{
		}
		
		public function get controller( ) : Controller
		{
			return _controller;
		}
		
		public function addedToStageHadler( event : Event ) : void
		{			
			if ( scriptAreaComponent )
				initiaize();
		}
		
		protected function initiaize() : void
		{
			
		}
		
		public function set autoShowAutoComplete( value : Boolean ) : void
		{
			assistMenu.autoShowAutoComplete = value;
		}
	}
}