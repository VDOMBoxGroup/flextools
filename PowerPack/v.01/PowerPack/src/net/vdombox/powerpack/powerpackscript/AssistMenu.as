package net.vdombox.powerpack.powerpackscript
{
	import __AS3__.vec.Vector;
	
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.ui.ContextMenu;
	import flash.ui.Keyboard;
	import flash.utils.setTimeout;
	
	import mx.controls.List;
	import mx.core.IUITextField;
	import mx.core.UIComponent;
	import mx.managers.FocusManager;
	
	import net.vdombox.powerpack.graph.Node;
	import net.vdombox.powerpack.lib.player.graph.NodeCategory;

	
	public class AssistMenu extends EventDispatcher
	{
		private var menuData:Array
		
		private var fld		: IUITextField;
		private var node	: Node;
		private var menu	: PopupAssistMenu;
		
		private var onComplete	: Function;
		private var stage		: Stage;
		
		private var menuPrevWord:String = "";
		
		public function AssistMenu(node:Node, stage:Stage, onComplete:Function)
		{
			this.node = node;
			fld = node.nodeTextArea.field;
			
			this.onComplete = onComplete;
			this.stage = stage;

			menu = new PopupAssistMenu();
			menu.doubleClickEnabled = true;
			
			fld.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		}
		
		private function filterMenu () : Boolean
		{
			var a:Array = [];
			
			for each (var obj : Object in menuData)
			{
				var s : String = obj["data"];
				
				if ( s.toLowerCase().indexOf(menuPrevWord.toLowerCase()) == 0 ) 
					a.push(obj);
			}

			if (a.length == 0) 
				return false;
			
			menu.listData = a;
			
			rePositionMenu();
			
			return true;
		}
		
		private function onMenuDoubleClick (event : MouseEvent) : void
		{
			if (event.target is IUITextField)
			{
				fldReplaceText(caretIndex-menuPrevWord.length, caretIndex, menuSelectedValue);
				
				menu.dispose();
			}
		}
		
		private function onKeyDown(e:KeyboardEvent):void
		{
			if (String.fromCharCode(e.keyCode) == ' ' && e.ctrlKey)
			{
				e.preventDefault();
				
				triggerAssist();
			}
		}
		
		private function onMenuKey(e:KeyboardEvent):void
		{
			//menu in action
			
			if (e.charCode != 0)
			{
				if (e.ctrlKey)
				{
					
				}
				else if (e.keyCode == Keyboard.ESCAPE)
				{
					menu.list.selectedItem = null;
				}
				else if (e.keyCode == Keyboard.BACKSPACE)
				{
					fldReplaceText(caretIndex-1, caretIndex, '');
					
					if (menuPrevWord.length > 0)
					{
						menuPrevWord = menuPrevWord.substr(0, -1);
						if (filterMenu()) 
							return;
					}
				}
				else if (e.keyCode == Keyboard.DELETE)
				{
					fldReplaceText(caretIndex, caretIndex+1, '');
				}
				else if (e.charCode > 31 && e.charCode < 127)
				{
					var ch:String = String.fromCharCode(e.charCode);
					menuPrevWord += ch.toLowerCase();
					caretIndex ++;
					
					fldReplaceText(caretIndex, caretIndex, ch);
					
					if ( filterMenu() ) 
						return;
				}
				else if (e.keyCode == Keyboard.ENTER || e.keyCode == Keyboard.TAB)
				{
					fldReplaceText(caretIndex-menuPrevWord.length, caretIndex, menuSelectedValue);
				}
				
				menu.dispose();
			}
		}
		
		
		public var newCursorPosition : int = -1;
		private function fldReplaceText(begin:int, end:int, text:String):void
		{
			fld.replaceText(begin, end, text);
			
			newCursorPosition = begin+text.length;
		}
		
		private static const TRIGGER_TYPE_SUBGRAPH			: String = "triggerTypeSubgraph";
		private static const TRIGGER_TYPE_VARIABLE			: String = "triggerTypeVariable";
		private static const TRIGGER_TYPE_FUNCTION			: String = "triggerTypeFunction";
		private static const TRIGGER_TYPE_WHOLE_FUNCTION	: String = "triggerTypeWholeFunction";
		private static const TRIGGER_TYPE_NONE				: String = "triggerTypeNone";
		
		private var wholeQuote : String;
		
		private function get trigerType () : String
		{
			var regexpTrigFunction		: RegExp = /^[ ]*\[/;
			var regexpTrigWholeFunction	: RegExp = /^['|\"][ ]+dohteMelohw[ ]*\[/;
			var regexpWord				: RegExp = /^(\w*)\b/;
			var regexpTrigVar			: RegExp = /^\$/;
			var regexpTrigSubgraph		: RegExp = /^[ ]+bus[ ]*\[/;
			
			var sourceText		: String = fld.text;
			var prevText		: String = sourceText.substring(0, caretIndex).split('').reverse().join('');
			
			if (prevText.search(regexpWord) == 0)
			{
				menuPrevWord = prevText.match(regexpWord)[0];
				menuPrevWord = menuPrevWord.split('').reverse().join('');
				
				prevText = prevText.substr(menuPrevWord.length);
			}
			
			if (node.category == NodeCategory.SUBGRAPH && prevText.length == 0 ||
				node.category != NodeCategory.SUBGRAPH && prevText.search(regexpTrigSubgraph) == 0)
				return TRIGGER_TYPE_SUBGRAPH;
			
			if (node.category == NodeCategory.SUBGRAPH)
				return TRIGGER_TYPE_NONE;
			
			if (prevText.search(regexpTrigVar) == 0)
				return TRIGGER_TYPE_VARIABLE;
			
			if (prevText.search(regexpTrigFunction) == 0)
				return TRIGGER_TYPE_FUNCTION;
			
			if (prevText.search(regexpTrigWholeFunction) == 0)
			{
				wholeQuote = prevText.charAt(0);
				return TRIGGER_TYPE_WHOLE_FUNCTION;
			}
			
			return TRIGGER_TYPE_NONE;
		}
		
		private var caretIndex : int;
		
		public function triggerAssist() : void
		{
			caretIndex = fld.selectionBeginIndex;
			
			menuData = null;
			menuPrevWord = "";
			newCursorPosition = caretIndex;
			
			switch (trigerType)
			{
				case TRIGGER_TYPE_SUBGRAPH:
				{
					menuData = AssistMenuContentController.allGraphs;
					break;
				}
				case TRIGGER_TYPE_VARIABLE:
				{
					menuData = AssistMenuContentController.allVariables;
					break;
				}
				case TRIGGER_TYPE_FUNCTION:
				{
					menuData = AssistMenuContentController.allFunctions;
					break;
				}
				case TRIGGER_TYPE_WHOLE_FUNCTION:
				{
					menuData = AssistMenuContentController.wholeMethodFunctions;
					break;
				}
			}
				
			if (!menuData || menuData.length==0) 
				return;
			
			showMenu(caretIndex);
		}

		private var menuRefY:int;
		
		private function showMenu(index:int):void
		{
			var p:Point;
			menu.listData = menuData;
			
			p = node.nodeTextArea.getPointForIndex(index);
			
			p.x += fld.scrollH;
			
			p = node.localToGlobal(p);
			menuRefY = p.y;
			
			menu.show(node, p.x, 0);
			menu.title = menuTitle;
				
			stage.addEventListener( MouseEvent.MOUSE_DOWN, stage_mouseDownHandler, false, 0, true );
			
			menu.addEventListener(KeyboardEvent.KEY_DOWN, onMenuKey);
			menu.addEventListener(Event.REMOVED_FROM_STAGE, menuRemovedFromStageHandler);
			menu.addEventListener(MouseEvent.DOUBLE_CLICK, onMenuDoubleClick);
			
			stage.focus = menu.list;
			
			rePositionMenu();
			
			if (menuPrevWord)
				filterMenu();
		}
		
		private function get menuTitle () : String
		{
			switch(trigerType)
			{
				case TRIGGER_TYPE_SUBGRAPH:
				{
					return PopupAssistMenu.TITLE_GRAPHS;
				}
				case TRIGGER_TYPE_FUNCTION:
				{
					return PopupAssistMenu.TITLE_FUNCTIONS;
				}
				case TRIGGER_TYPE_WHOLE_FUNCTION:
				{
					return PopupAssistMenu.TITLE_WHOLE_FUNCTIONS;
				}
				case TRIGGER_TYPE_VARIABLE:
				{
					return PopupAssistMenu.TITLE_VARIABLES;
				}
			}
			
			return "";
		}
		
		private function menuRemovedFromStageHandler (event : Event) : void
		{
			stage.removeEventListener( MouseEvent.MOUSE_DOWN, stage_mouseDownHandler, false );
			
			menu.removeEventListener(KeyboardEvent.KEY_DOWN, onMenuKey);
			menu.removeEventListener(Event.REMOVED_FROM_STAGE, menuRemovedFromStageHandler);
			menu.removeEventListener(MouseEvent.DOUBLE_CLICK, onMenuDoubleClick);
			
			menuPrevWord = "";
			
			onComplete();
		}
		
		private function get menuSelectedValue () : String
		{
			var selectedValue : String = menu.getSelectedValue();
			
			if (selectedValue)
			{
				if (trigerType == TRIGGER_TYPE_FUNCTION || trigerType == TRIGGER_TYPE_VARIABLE)
					selectedValue += " ";
				else if (trigerType == TRIGGER_TYPE_WHOLE_FUNCTION)
					selectedValue += wholeQuote + " ";
					
			}
			
			return selectedValue;
		}
		
		private function stage_mouseDownHandler( event : MouseEvent ) : void
		{
			if (event.target is IUITextField)
			{
				// TODO: show tooltip
				return;
			}
			
			// TODO: remove tooltip
			
			var parent : UIComponent = event.target as UIComponent;
			var isMenu : Boolean;
			
			while ( parent )
			{
				if ( parent == menu )
				{
					isMenu = true;
					break;
				}
				
				parent = parent.parent as UIComponent;
			}
			
			if ( !isMenu )
			{
				stage.removeEventListener( MouseEvent.MOUSE_DOWN, stage_mouseDownHandler, false );
				menu.dispose();
			}
		}

		
		public function vectorToArray(v:Object):Array
		{
			var a : Array = new Array( v.length );
			
			for (var i:int=0; i<v.length; i++)
				a[i] = v[i];
			
			return a;
		}
		
		private function rePositionMenu():void
		{
			var menuH:int = 8;
			
			if ( menuRefY + 15 + menuH > fld.height )
				menu.y = menuRefY - menuH - 2;
			else
				menu.y = menuRefY + 15;
		}

	}
}