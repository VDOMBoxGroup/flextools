/* license section

Flash MiniBuilder is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

Flash MiniBuilder is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Flash MiniBuilder.  If not, see <http://www.gnu.org/licenses/>.


Author: Victor Dramba
2009
*/

package ro.minibuilder.main.editor
{
	import flash.events.*;
	import flash.filters.DropShadowFilter;
	
	import org.aswing.*;
	import org.aswing.border.LineBorder;

	/**
	 * Simple one level floating menu
	 */
	public class ScrollPopupMenu extends JList
	{
		protected var popup:JPopup;
		protected var owner:Object;
		
		
		public function ScrollPopupMenu()
		{
			setSelectionMode(SINGLE_SELECTION);
			
			popup = new JPopup;
			//popup.doubleClickEnabled = true;
			
			setForeground(new ASColor(0));
			
			popup.setBorder(new LineBorder(null, new ASColor(0, .6), 1, 0));
			var sp:JScrollPane = new JScrollPane;
			sp.append(this);
			popup.append(sp);
			
			popup.filters = [new DropShadowFilter(2, 45, 0, .3, 6, 6)];
			
			setUI(new PopupUI);
			
			addEventListener(FocusEvent.FOCUS_OUT, function(e:FocusEvent):void {
				dispose();
			});
		}
		
		
		public function dispose():void
		{
			if (popup.isShowing())
				popup.dispose();
		}
		
		override public function setListData(ld:Array):void
		{
			super.setListData(ld);
			updateSize();
			(getUI() as PopupUI).resetIndex();
		}
		
		private function updateSize():void
		{
			popup.setSizeWH(200, 2+getCellFactory().getCellHeight() * Math.min(8, getModel().getSize()));
			popup.revalidate();
		}
		
		public function show(owner:Object, x:int, y:int):void
		{
			this.owner = owner;
			updateSize();
			popup.setLocationXY(x, y);
			popup.show();
			(getUI() as PopupUI).resetIndex();
		}
		
		override public function setY(y:int):void
		{
			popup.setY(y);
		}
		
		override public function getY():int
		{
			return popup.getY();
		}
	}
}



import org.aswing.Component;
import org.aswing.plaf.basic.BasicListUI;
import org.aswing.geom.IntRectangle;

class PopupUI extends BasicListUI
{
	public function PopupUI()
	{
		super();
	}
	
    override protected function paintCellFocus(cellComponent:Component):void
    {
    	
    }
    
    public function resetIndex():void
    {
    	paintFocusedIndex = -1;
    }
}