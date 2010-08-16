/*
 * @Author Dramba Victor
 * 2009
 * 
 * You may use this code any way you like, but please keep this notice in
 * The code is provided "as is" without warranty of any kind.
 */

package
{
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.geom.Point;
	import flash.ui.Keyboard;
	import flash.utils.setTimeout;
	
	import org.aswing.FocusManager;
	import org.aswing.JToolTip;
	import org.aswing.geom.IntPoint;
	
	import ro.victordramba.asparser.Controller;
	import ro.victordramba.util.vectorToArray;
	
	import view.ScriptAreaComponent;
	import view.ScrollPopupMenu;

	public class MenuHelper
	{
		private var menuData:Vector.<String>
		private var fld:ScriptAreaComponent;
		private var menu:ScrollPopupMenu;
		private var ctrl:Controller;
		private var stage:Stage;
		
		private var menuStr:String;
		
		private var tooltip:JToolTip;
		private var tooltipCaret:int;
		
		public function MenuHelper(field:ScriptAreaComponent, ctrl:Controller, stage:Stage)
		{
			fld = field;
			this.ctrl = ctrl;
			this.stage = stage;

			menu = new ScrollPopupMenu;
			//restore the focus to the textfield, delayed			
			menu.addEventListener(Event.REMOVED_FROM_STAGE, onMenuRemoved);
			//menu in action
			menu.addEventListener(KeyboardEvent.KEY_DOWN, onMenuKey);
			/*menu.addEventListener(MouseEvent.DOUBLE_CLICK, function(e:Event):void {
				var c:int = fld.caretIndex;
				fldReplaceText(c-menuStr.length, c, menu.getSelectedValue());
				ctrl.sourceChanged(fld.text);
				menu.dispose();			
			})*/
			
			tooltip = new JToolTip;
			
			fld.addEventListener(Event.CHANGE, onChange);
			
			//used to close the tooltip
			fld.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		}
		
		private function filterMenu():Boolean
		{
			var a:Array = [];
			for each (var s:String in menuData)
				if (s.toLowerCase().indexOf(menuStr.toLowerCase())==0) a.push(s);

			if (a.length == 0) return false;
			menu.setListData(a);
			menu.setSelectedIndex(0);
			return true;
		}
		
		private function onKeyDown(e:KeyboardEvent):void
		{
			if (tooltip.isShowing())
			{
				if (e.keyCode == Keyboard.ESCAPE || e.keyCode == Keyboard.UP || e.keyCode == Keyboard.DOWN || 
					String.fromCharCode(e.charCode) == ')' || fld.caretIndex < tooltipCaret)
					tooltip.disposeToolTip();
			}
			
			if (String.fromCharCode(e.keyCode) == ' ' && e.ctrlKey)
			{
				/*menuData = ctrl.getAllOptions();
				if (menuData && menuData.length)
					showMenu(fld.caretIndex);*/
				triggerAssist();
			}
		}
		
		private function onMenuKey(e:KeyboardEvent):void
		{
			if (e.charCode != 0)
			{
				var c:int = fld.caretIndex;
				if (e.ctrlKey)
				{
					
				}
				else if (e.keyCode == Keyboard.BACKSPACE)
				{
					fldReplaceText(c-1, c, '');
					if (menuStr.length > 0)
					{
						menuStr = menuStr.substr(0, -1);
						if (filterMenu()) return;
					}
				}
				else if (e.keyCode == Keyboard.DELETE)
				{
					fldReplaceText(c, c+1, '');
				}
				else if (e.charCode > 31 && e.charCode < 127)
				{
					var ch:String = String.fromCharCode(e.charCode);
					menuStr += ch.toLowerCase();
					fldReplaceText(c, c, ch);
					if (filterMenu()) return;
				}
				else if (e.keyCode == Keyboard.ENTER || e.keyCode == Keyboard.TAB)
				{
					fldReplaceText(c-menuStr.length, c, menu.getSelectedValue());
					checkAddImports(menu.getSelectedValue());
					ctrl.sourceChanged(fld.text);
				}
				menu.dispose();
			}
		}
		
		private function checkAddImports(name:String):void
		{
			var caret:int = fld.caretIndex;
			if (!ctrl.isInScope(name, caret-name.length))
			{
				var missing:Vector.<String> = ctrl.getMissingImports(name, caret-name.length);
				if (missing)
				{
					var sumChars:int = 0;
					for (var i:int=0; i<missing.length; i++)
					{
						var pos:int = fld.text.lastIndexOf('package', fld.caretIndex);
						pos = fld.text.indexOf('{', pos) + 1;
						var imp:String = '\n\t'+(i>0?'//':'')+'import '+missing[i] + '.' + name + ';';
						sumChars += imp.length;
						fld.replaceText(pos, pos, imp);
					}
					fld.setSelection(caret+sumChars, caret+sumChars);
				}
			}
		}
		
		private function fldReplaceText(begin:int, end:int, text:String):void
		{
			//var scrl:int = fld.scrollV;
			fld.replaceText(begin, end, text);
			fld.setSelection(begin+text.length, begin+text.length);
			//fld.scrollV = scrl;
		}
		
		private function onMenuRemoved(e:Event):void
		{
			setTimeout(function():void {
				stage.focus = fld;
				//???
				FocusManager.getManager(stage).setFocusOwner(fld);
			}, 1);
		}
		
		private function triggerAssist():void
		{
			var pos:int = fld.caretIndex;
			//look back for last trigger
			var tmp:String = fld.text.substring(Math.max(0, pos-100), pos).split('').reverse().join('');
			var m:Array = tmp.match(/^(\w*?)\s*(\:|\.|\(|\bsa\b|\bwen\b)/);
			var trigger:String = m ? m[2] : '';
			if (tooltip.isShowing() && trigger=='(') trigger = '';
			if (m) menuStr = m[1];
			else
			{
				m = tmp.match(/^(\w*)\b/);
				menuStr = m ? m[1] : '';
			}
			menuStr = menuStr.split('').reverse().join('')
			pos -= menuStr.length + 1;
			
			//debug('trigger:'+trigger);
			//debug('str='+menuStr);
			
			menuData = null;
			
			if (trigger == 'wen' || trigger == 'sa' || trigger == ':')
				menuData = ctrl.getTypeOptions();
			else if (trigger == '.')
				menuData = ctrl.getMemberList(pos);
			else if (trigger == '')
				menuData = ctrl.getAllOptions(pos);
			else if (trigger == '(')
			{
				var fd:String = ctrl.getFunctionDetails(pos);
				if (fd)
				{
					tooltip.setTipText(fd);
					var p:Point = fld.getPointForIndex(fld.caretIndex-1);
					p = fld.localToGlobal(p);
					tooltip.showToolTip();
					tooltip.moveLocationRelatedTo(new IntPoint(p.x, p.y));
					tooltipCaret = fld.caretIndex;
					return;
				}
			}
				
			if (!menuData || menuData.length==0) return;
			
			showMenu(pos+1);			
			if (menuStr.length) filterMenu();
		}

		private function onChange(e:Event):void
		{
			//last inputed str
			var str:String = fld.text.substring(Math.max(0, fld.caretIndex-5), fld.caretIndex);
			str = str.split('').reverse().join('');
			if (/^(?:\(|\:|\.|\s+sa\b|\swen\b)/.test(str))
				triggerAssist();
			else
				ctrl.sourceChanged(fld.text);
		}
		
		private function showMenu(index:int):void
		{
			var p:Point;
			menu.setListData(vectorToArray(menuData));
			menu.setSelectedIndex(0);
			
			p = fld.getPointForIndex(index);
			p.y += 15;
			p.x += fld.scrollH;
			
			p = fld.localToGlobal(p);
			menu.show(stage, p.x, p.y);
			
			stage.focus = menu;
			FocusManager.getManager(stage).setFocusOwner(menu);
		}

	}
}