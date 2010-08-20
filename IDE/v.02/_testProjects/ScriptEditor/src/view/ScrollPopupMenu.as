package view
{
	import flash.events.*;
	import flash.filters.DropShadowFilter;

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
	}
}