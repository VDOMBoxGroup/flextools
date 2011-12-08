package net.vdombox.powerpack.lib.extendedapi.controls 
{
	import net.vdombox.powerpack.lib.extendedapi.containers.SuperTabNavigator;
	import net.vdombox.powerpack.lib.extendedapi.controls.tabBarClasses.SuperTab;
	import net.vdombox.powerpack.lib.extendedapi.controls.tabBarClasses.SuperUIComponent;
	import net.vdombox.powerpack.lib.extendedapi.events.SuperTabEvent;
	import net.vdombox.powerpack.lib.extendedapi.events.TabReorderEvent;
	import net.vdombox.powerpack.lib.extendedapi.utils.Utils;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	import mx.collections.IList;
	import mx.containers.DividedBox;
	import mx.containers.HDividedBox;
	import mx.containers.VDividedBox;
	import mx.containers.ViewStack;
	import mx.controls.Button;
	import mx.controls.TabBar;
	import mx.core.Application;
	import mx.core.ClassFactory;
	import mx.core.Container;
	import mx.core.DragSource;
	import mx.core.IFlexDisplayObject;
	import mx.core.IUIComponent;
	import mx.core.UIComponent;
	import mx.core.mx_internal;
	import mx.events.DragEvent;
	import mx.managers.DragManager;
	import mx.managers.PopUpManager;

	
	/**
	 * Fired when a tab is dropped onto this SuperTabBar, which re-orders the tabs and updates the
	 * list of tabs.
	 */
	[Event(name="tabsReordered", type="net.vdombox.powerpack.lib.extendedapi.events.TabReorderEvent")]
	
	/**
	 * Fired when the close button of a tab is clicked. To stop the default action, which will remove the 
	 * child from the collection of children, call event.preventDefault() in your listener.
	 */
	[Event(name="tabClose", type="net.vdombox.powerpack.lib.extendedapi.events.SuperTabEvent")]
	
	/**
	 * Fired when the the label or icon of a child is updated and the tab gets updated to reflect
	 * the new icon or label. SuperTabNavigator listens for this to refresh the PopUpMenuButton data provider.
	 */
	[Event(name="tabUpdated", type="net.vdombox.powerpack.lib.extendedapi.events.SuperTabEvent")]
	
	
	[IconFile("SuperTabBar.png")]
	
	/**
	 *  The SuperTabBar control extends the TabBar control and adds drag and drop functionality
	 *  and closable tabs. 
	 *  <p>The SuperTabBar is used by the SuperTabNavigator component, or it can be used on its
	 *  own to independentaly control a ViewStack. SuperTabBar does not control scrolling of tabs.
	 *  Scrolling of tabs in the SuperTabNavigator is done by wrapping the SuperTabBar in a scrollable
	 *  canvas component.</p>
	 *
	 *  @mxml
	 *
	 *  <p>The <code>&lt;flexlib:SuperTabBar&gt;</code> tag inherits all of the tag attributes
	 *  of its superclass, and adds the following tag attributes:</p>
	 *
	 *  <pre>
	 *  &lt;flexlib:SuperTabBar
	 *    <b>Properties</b>
	 *    closePolicy="SuperTab.CLOSE_ROLLOVER|SuperTab.CLOSE_ALWAYS|SuperTab.CLOSE_SELECTED|SuperTab.CLOSE_NEVER"
	 *    dragEnabled="true"
	 *    dropEnabled="true"
	 * 
	 *    <b>Events</b>
	 *    tabsReorderEvent="<i>No default</i>"
	 *    &gt;
	 *    ...
	 *       <i>child tags</i>
	 *    ...
	 *  &lt;/flexlib:SuperTabBar&gt;
	 *  </pre>
	 *
	 *  @see flexlib.containers.SuperTabNavigator
	 * 	@see mx.controls.TabBar
	 */
	public class SuperTabBar extends TabBar{
		
		use namespace mx_internal;
		
		/**
		 * Event that is dispatched when the tabs are re-ordered in the SuperTabBar.
		 */
		public static const TABS_REORDERED:String = "tabsReordered";

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor
		 */
		public function SuperTabBar(){
			super();
			
			// we make sure that when we make new tabs they will be SuperTabs
			navItemFactory = new ClassFactory(getTabClass());
		}
		
	    //--------------------------------------------------------------------------
	    //
	    //  Variables
	    //
	    //--------------------------------------------------------------------------
	    				
		mx_internal var dragTabProxy:SuperUIComponent;
		
	    //--------------------------------------------------------------------------
	    //
	    //  Overridden properties
	    //
	    //--------------------------------------------------------------------------
	    
	    //--------------------------------------------------------------------------
	    //
	    //  Properties
	    //
	    //--------------------------------------------------------------------------		

	   	//----------------------------------
	    //  dragEnabled
	    //----------------------------------

	    /**
		 * @private
		 */
		private var _dragEnabled:Boolean = true;
		
		/**
		 * Boolean indicating if this SuperTabBar allows its tabs to be dragged.
		 * <p>If both dragEnabled and dropEnabled are true then the 
		 * SuperTabBar allows tabs to be reordered with drag and drop.</p>
		 */
		public function get dragEnabled():Boolean {
			return _dragEnabled;
		}
		/**
		 * @private
		 */
		public function set dragEnabled(value:Boolean):void {
			this._dragEnabled = value;
			
			for each (var child:SuperTab in getChildren()) {
		    	if(value) {
		    		addDragListeners(child);
		    	}
		    	else {
		    		removeDragListeners(child);
		    	}
		    }
		}

	   	//----------------------------------
	    //  dropEnabled
	    //----------------------------------
	    			    		
		/**
		 * @private
		 */
		private var _dropEnabled:Boolean = true;
		
		/**
		 * Boolean indicating if this SuperTabBar allows its tabs to be dropped onto it.
		 * <p>If both dragEnabled and dropEnabled are true then the 
		 * SuperTabBar allows tabs to be reordered with drag and drop.</p>
		 */
		public function get dropEnabled():Boolean {
			return _dropEnabled;
		}
		/**
		 * @private
		 */
		public function set dropEnabled(value:Boolean):void {
			this._dropEnabled = value;
			
		    for each (var child:SuperTab in getChildren()) {
		    	if(value) {
		    		addDropListeners(child);
		    	}
		    	else {
		    		removeDropListeners(child);
		    	}
		    }
		}
		
	   	//----------------------------------
	    //  closePolicy
	    //----------------------------------

		/**
		 * @private
		 */
		private var _closePolicy:String = SuperTab.CLOSE_ROLLOVER;
		
		/**
		 * The policy for when to show the close button for each tab.
		 * <p>This is a proxy property that sets each SuperTab's closePolicy setting to
		 * whatever is set here.</p>
		 * @see flexlib.controls.tabClasses.SuperTab
		 */
		public function get closePolicy():String {
			return _closePolicy;
		}
		/**
		 * @private
		 */
		public function set closePolicy(value:String):void {
			this._closePolicy = value;
			
	        for each (var child:SuperTab in getChildren()) {
				child.closePolicy = value;
	        }

			this.invalidateDisplayList();
		}
		
	   	//----------------------------------
	    //  closePolicy
	    //----------------------------------

		private var _editableTabLabels:Boolean=false;
		
		/**
		 * Boolean indicating if tab labels can be edited. If true, the user can double click on
		 * a tab label and edit the label.
		 */
		public function get editableTabLabels():Boolean {
			return _editableTabLabels;
		}
		/**
		 * @private
		 */
		public function set editableTabLabels(value:Boolean):void {
			this._editableTabLabels = value;
			
	        for each (var child:SuperTab in getChildren()) {
				child.doubleClickToEdit = value;
	        }
		}

	    //--------------------------------------------------------------------------
	    //
	    //  Overridden methods: TabBar
	    //
	    //--------------------------------------------------------------------------		

		/**
		 * @private
		 */
		override protected function createNavItem(
										label:String,
										icon:Class = null):IFlexDisplayObject{
											
			var tab:SuperTab = super.createNavItem(label,icon) as SuperTab;
			
			tab.closePolicy = this.closePolicy;
			tab.doubleClickToEdit = this.editableTabLabels;
			
			if(dragEnabled) {
				addDragListeners(tab);
			}
			
			if(dropEnabled) {
				addDropListeners(tab);
			}
			
			// We need to listen for the close event fired from each tab.
			tab.addEventListener(SuperTab.CLOSE_TAB_EVENT, onCloseTabClicked, false, 0, true);
			tab.addEventListener(SuperTabEvent.TAB_UPDATED, onTabUpdated);
			
			return tab;
		}

		override protected function updateNavItemLabel(index:int, label:String):void {
			super.updateNavItemLabel(index, label);
			
			//fix for issue # 77: http://code.google.com/p/flexlib/issues/detail?id=77
			if(dataProvider is SuperTabNavigator) {
				SuperTabNavigator(dataProvider).invalidateDisplayList();
			}
			
			dispatchEvent(new SuperTabEvent(SuperTabEvent.TAB_UPDATED, index));
		}
		
		override protected function updateNavItemIcon(index:int, icon:Class):void {
			super.updateNavItemIcon(index, icon);
			
			dispatchEvent(new SuperTabEvent(SuperTabEvent.TAB_UPDATED, index));
		}
		
	    //--------------------------------------------------------------------------
	    //
	    //  Methods
	    //
	    //--------------------------------------------------------------------------

		public function resetTabs():void {
			this.resetNavItems();
		}
		
		public function setClosePolicyForTab(index:int, value:String):void {
			if(this.numChildren >= index + 1) {
				(getChildAt(index) as SuperTab).closePolicy = value;
			}
		}
		
		public function getClosePolicyForTab(index:int):String {
			return (getChildAt(index) as SuperTab).closePolicy;
		}

		/**
		 * For extensibility, if you extend <code>SuperTabBar</code> with a custom tab bar implementation,
		 * you can override the <code>getTabClass</code> function to return the class for the tabs that should
		 * be used. The class that you return must extend <code>flexlib.controls.tabBarClasses.SuperTab</code>.
		 */
		protected function getTabClass():Class {
			return SuperTab;
		}

		/**
		 * @private
		 */
		private function addDragListeners(tab:SuperTab):void {
			tab.addEventListener(MouseEvent.MOUSE_DOWN, tryDrag, false, 0, true);
			tab.addEventListener(MouseEvent.MOUSE_UP, removeDrag, false, 0, true);
		}
		
		/**
		 * @private
		 */
		private function removeDragListeners(tab:SuperTab):void {
			tab.removeEventListener(MouseEvent.MOUSE_DOWN, tryDrag);
			tab.removeEventListener(MouseEvent.MOUSE_UP, removeDrag);
		}
		
		/**
		 * @private
		 */
		private function addDropListeners(tab:SuperTab):void {
			tab.addEventListener(DragEvent.DRAG_ENTER, tabDragEnter, false, 0, true);
			tab.addEventListener(DragEvent.DRAG_OVER, tabDragOver, false, 0, true);
			tab.addEventListener(DragEvent.DRAG_DROP, tabDragDrop, false, 0, true);
			tab.addEventListener(DragEvent.DRAG_EXIT, tabDragExit, false, 0, true);	
		}
		
		/**
		 * @private
		 */
		private function removeDropListeners(tab:SuperTab):void {
			tab.removeEventListener(DragEvent.DRAG_ENTER, tabDragEnter);
			tab.removeEventListener(DragEvent.DRAG_OVER, tabDragOver);
			tab.removeEventListener(DragEvent.DRAG_DROP, tabDragDrop);
			tab.removeEventListener(DragEvent.DRAG_EXIT, tabDragExit);	
		}

		private function processTabDrag (tab:SuperTab):void
		{
			PopUpManager.removePopUp(dragTabProxy);

			if(!DragManager.isDragging)
			{
				dragTabProxy = null;					
				return;
			}
				
			var tabBar:SuperTabBar=null;
			var tabNavigator:SuperTabNavigator=null;
			var container:Container=null;
			
			var object:* = tab;
			while(object && object.parent) {
				if(!(object.parent is DividedBox) && tabNavigator) {
					container = object;
					break;
				}

				object = object.parent;
				
				if(object is SuperTabBar && !tabBar) {
					tabBar = object;
				}
				else if(object is SuperTabNavigator && !tabNavigator) {
					tabNavigator = object;
				}
			}
							
			if(!container)
			{
				dragTabProxy = null;					
				return;
			}
			
			if (!dragTabProxy)
			{
				dragTabProxy = new SuperUIComponent();

				dragTabProxy.addEventListener(DragEvent.DRAG_ENTER, tabProxybDragEnter);
				dragTabProxy.addEventListener(DragEvent.DRAG_OVER, tabProxybDragOver);
				dragTabProxy.addEventListener(DragEvent.DRAG_DROP, tabProxybDragDrop);

				var shape:SuperUIComponent = new SuperUIComponent();
				dragTabProxy.addChildAt(shape, 0);
			}			
			
			var canvasOffset:int = 100;
			dragTabProxy.width = stage.width+canvasOffset*2;
			dragTabProxy.height = stage.height+canvasOffset*2;
			dragTabProxy.graphics.clear();
			dragTabProxy.graphics.beginFill(0, 0)
			dragTabProxy.graphics.drawRect(0,0,dragTabProxy.width, dragTabProxy.height);
			dragTabProxy.graphics.endFill();
				
			shape = dragTabProxy.getChildAt(0) as SuperUIComponent;
			shape.graphics.clear();			
			var thickness:int = 4;	
			shape.graphics.lineStyle(thickness, getStyle("themeColor"), 0.5);
			
			var subContainers:Array = [];
			var target:Container = null;
			var rect:Rectangle;
			var secRect:Rectangle;
			var data:Object = new Object();
			var divider:int = 2;

			if(container!=tabNavigator)
				recursiveFindContainers(subContainers, container);
			else
				subContainers.push(container);
			
			for each (var elm:Container in subContainers) {
				if(Utils.getVisibleExactRect(elm).contains(stage.mouseX, stage.mouseY))
					target = elm;
			}

			if(target) {
				if(target==tabNavigator && tabNavigator.numChildren==1) {
					rect = Utils.getVisibleExactRect(target);
					secRect = new Rectangle(rect.x, rect.y, rect.width, rect.height);
				} else {
					rect = Utils.getVisibleExactRect(target);
					secRect = new Rectangle(rect.x, rect.y, rect.width, rect.height);

					var offset:int = 15;
					var offsetTop:int = 5;
					
					if(target is SuperTabNavigator)
					{
						if(stage.mouseX<rect.x+offset)
							data.hPos = 'l'; 
						else if(stage.mouseX>rect.x+rect.width-offset)
							data.hPos = 'r';
								
						if(stage.mouseY<rect.y+offsetTop)				
							data.vPos = 't'; 
						else if(stage.mouseY>rect.y+rect.height-offset)
							data.vPos = 'b';
							
						if(data.vPos!='t' && (target as SuperTabNavigator).getSuperTabBar().hitTestPoint(stage.mouseX, stage.mouseY))
						{
							target = null;
						}
					}
					else									
					{
						divider = 4;
						
						if(stage.mouseX<rect.x+rect.width/2)
							data.hPos = 'l'; 
						else 
							data.hPos = 'r';
								
						if(stage.mouseY<rect.y+rect.height/2)				
							data.vPos = 't'; 
						else 
							data.vPos = 'b';
					}
					
					data.target = target;
				}			
			}
			else 
			{		
				target = container;
				rect = Utils.getVisibleExactRect(target);
				secRect = new Rectangle(rect.x, rect.y, rect.width, rect.height);
				
				divider = 4;
				
				if(stage.mouseX<=rect.x)
					data.hPos = 'l'; 
				else if(stage.mouseX>=rect.x+rect.width)
					data.hPos = 'r';
							
				if(stage.mouseY<=rect.y)				
					data.vPos = 't'; 
				else if(stage.mouseY>=rect.y+rect.height)
					data.vPos = 'b';
				
				if(!data.hPos && !data.vPos)
					target = null;
					
				data.target = target;
			}
			
			if(target)
			{
				switch(data.hPos) {
					case 'l':
						if(data.vPos) {							
							if((rect.x-stage.mouseX) < (data.vPos=='t' ? (rect.y-stage.mouseY) : (stage.mouseY-(rect.y+rect.height))))
								delete data.hPos;
							else
								delete data.vPos;
						}
						break;
					case 'r':
						if(data.vPos) {							
							if((stage.mouseX-(rect.x+rect.width)) < (data.vPos=='t' ? (rect.y-stage.mouseY) : (stage.mouseY-(rect.y+rect.height))))
								delete data.hPos;
							else
								delete data.vPos;
						}
						break;
				}

				if(data.vPos) {
					data.pos = data.vPos;
					delete data.vPos;
				} else {
					data.pos = data.hPos;
					delete data.hPos;
				}
				
				switch(data.pos) {
					case 't':
						secRect = new Rectangle(rect.x, rect.y, rect.width, rect.height/divider);
						break;
					case 'b':
						secRect = new Rectangle(rect.x, rect.y+(rect.height-rect.height/divider), rect.width, rect.height/divider);
						break;
					case 'l':
						secRect = new Rectangle(rect.x, rect.y, rect.width/divider, rect.height);
						break;
					case 'r':
						secRect = new Rectangle(rect.x+(rect.width-rect.width/divider), rect.y, rect.width/divider, rect.height);
						break;
				}
				
				data.divider = divider;
					
				dragTabProxy.data = data;
				shape.width = secRect.width;
				shape.height = secRect.height;
				shape.move(secRect.x+canvasOffset, secRect.y+canvasOffset);				
				shape.graphics.beginFill(getStyle("themeColor"), 0.1)
				shape.graphics.drawRect(thickness/2, thickness/2, secRect.width-thickness, secRect.height-thickness);
				shape.graphics.endFill();	
				
				PopUpManager.addPopUp(dragTabProxy, Sprite(Application.application));
				dragTabProxy.move(-canvasOffset, -canvasOffset);
			}
			
			if(DragManager.isDragging)
				callLater(processTabDrag, [tab]);
			else {
				PopUpManager.removePopUp(dragTabProxy);
				dragTabProxy = null;
			}	
		}

		private function recursiveFindContainers(containers:Array, target:Container):Boolean
		{
			if(!(target is Container) || !target.visible)
				return false;
			
			var existSubCont:Boolean = false;
			
			for each (var child:Object in target.getChildren()) {
				if(child is Container && Container(child).visible) {
					if(child is DividedBox){
						existSubCont = recursiveFindContainers(containers, child as Container);
					}
					else {
						containers.push(child);
						existSubCont = true;
					}
				}
			}
			
			if(!existSubCont && target) {
				containers.push(target);
				existSubCont = true;
			}
			
			return existSubCont;
		}
		
	    //--------------------------------------------------------------------------
	    //
	    //  Overridden event handlers: TabBar
	    //
	    //--------------------------------------------------------------------------	    
	    
	    //--------------------------------------------------------------------------
	    //
	    //  Event handlers
	    //
	    //--------------------------------------------------------------------------
		
		private function onTabUpdated(event:SuperTabEvent):void {
			var tab:SuperTab = event.currentTarget as SuperTab;
			var index:Number = this.getChildIndex(tab);
			
			var dpItem:Object;
			
			if(dataProvider is IList){
				dpItem = dataProvider.getItemAt(index);
			}
			else if(dataProvider is ViewStack){
				dpItem = dataProvider.getChildAt(index);
			}
			
			if(labelField) {
				dpItem[labelField] = tab.label;
			}
			else if(dpItem.hasOwnProperty('label')) {
				dpItem.label = tab.label;
			}
		}
		
		/**
		 * @private
		 */
		private function tryDrag(e:MouseEvent):void{
			e.target.addEventListener(MouseEvent.MOUSE_MOVE, doDrag);
		}
		
		/**
		 * @private
		 */
		private function removeDrag(e:MouseEvent):void{
			e.target.removeEventListener(MouseEvent.MOUSE_MOVE,doDrag);
		}
		
		/**
		 * @private
		 * 
		 * When a tab closes it dispatches a close event. This listener gets fired in response
		 * to that event. We remove the tab from the dataProvider. This might be as simple as removing
		 * the tab, but the dataProvider might be a ViewStack, which means we remove the entire child
		 * from the dataProvider (which removes it from the ViewStack).
		 */
		public function onCloseTabClicked(event:Event):void{
			
			var index:int = getChildIndex(DisplayObject(event.currentTarget));
			var len:int = -1;
			
			//we will dispatch a SuperTabEvent.TAB_CLOSE event. The only reason we are really doing
			//this is to allow a developer to listen for the event and call event.preventDefault(), which
			//will then stop the default action (remove the child)
			var tabCloseEvent:SuperTabEvent = new SuperTabEvent(SuperTabEvent.TAB_CLOSE, index, false, true);
			dispatchEvent(tabCloseEvent);
			
			if(!tabCloseEvent.isDefaultPrevented()) {
				if(dataProvider is IList){
					dataProvider.removeItemAt(index);
					len = IList(dataProvider).length;
				}
				else if(dataProvider is ViewStack){
					dataProvider.removeChildAt(index);
					len = ViewStack(dataProvider).numChildren;
				}
			}
			
			// recursively remove empty containers from stage
    		if(len==0)
    		{
    			var sourceNav:Object = this;
    			
    			while(!(sourceNav is SuperTabNavigator) && sourceNav.parent)
    				sourceNav = sourceNav.parent;	    			
    			
    			sourceNav.removeEmptyContainers();
    		}			
		}
		
		/**
		 * @private
		 */
		private function doDrag(event:MouseEvent):void {
			if(event.target is IUIComponent && 
				(IUIComponent(event.target) is SuperTab || 
					(IUIComponent(event.target).parent is SuperTab && 
						!(IUIComponent(event.target) is Button)))) {
				
				var tab:SuperTab;
				
				if(IUIComponent(event.target) is SuperTab) {
					tab = IUIComponent(event.target) as SuperTab;
				}
				
				if(IUIComponent(event.target).parent is SuperTab) {
					tab = IUIComponent(event.target).parent as SuperTab;
				}
				
				var ds:DragSource = new DragSource();
				ds.addData(event.currentTarget,'tabDrag');
				
				if(dataProvider is IList) {
					ds.addData(event.currentTarget,'listDP');	
				}
				
				if(dataProvider is ViewStack) {
					ds.addData(event.currentTarget,'stackDP');	
				}
				
				var bmapData:BitmapData = new BitmapData(tab.width, tab.height, true, 0x00000000);
				bmapData.draw(tab);
				var dragProxy:Bitmap = new Bitmap(bmapData); 
				
				var obj:UIComponent = new UIComponent();
				obj.addChild(dragProxy);
				
				event.target.removeEventListener(MouseEvent.MOUSE_MOVE, doDrag);
				
				DragManager.doDrag(IUIComponent(event.target),ds,event,obj);
				
				processTabDrag(tab);
			}					
		}
		
		private function tabProxybDragEnter(event:DragEvent):void {
			tabDragEnter(event);
		}
		
		private function tabProxybDragOver(event:DragEvent):void {
			if(event.dragSource.hasFormat('tabDrag') && event.currentTarget.data && event.currentTarget.data.target) {
				DragManager.showFeedback(DragManager.LINK);
			}			
		}
		
		private function tabProxybDragDrop(event:DragEvent):void {
			if(event.dragSource.hasFormat('tabDrag') && event.draggedItem != event.dragInitiator) {
			
				var dropData:Object = event.currentTarget.data;
				
				if(!dropData || !dropData.target)
					return;
					
				var dropTarget:Container = (dropData.target as Container);
				
				var dragTab:SuperTab = (event.dragInitiator as SuperTab);
				
				var parentBar:SuperTabBar;
				var parentNav:SuperTabNavigator;
				
				var object:* = event.dragInitiator;
				while(object && object.parent) {
					object = object.parent;
					
					if(object is SuperTab) {
						dragTab = object;
					}
					else if(object is SuperTabBar) {
						parentBar = object;
					}
					else if(object is SuperTabNavigator) {
						parentNav = object;
						break;
					}
				}

				var newBar:SuperTabBar;

				if(dropTarget is SuperTabNavigator && !dropData.pos)
				{
					newBar = (dropTarget as SuperTabNavigator).getSuperTabBar();
				}
				else
				{
					var parentContainer:Container = dropTarget.parent as Container;
					var index:int = parentContainer.getChildIndex(dropTarget);
					var size:Object = {width:dropTarget.getExplicitOrMeasuredWidth(), height:dropTarget.getExplicitOrMeasuredHeight()}; 
					var percentSize:Object = {width:dropTarget.percentWidth, height:dropTarget.percentHeight};
					
					parentContainer.removeChild(dropTarget);
					
					var newNav:SuperTabNavigator = parentNav.clone();					
					
					var box:DividedBox;
					switch(dropData.pos) {
						case 'l':
						case 'r':
							box = new HDividedBox();
							newNav.percentWidth = 100/dropData.divider; 
							dropTarget.percentWidth = 100-100/dropData.divider;
							newNav.percentHeight = dropTarget.percentHeight = 100;
							break;
						case 't':
						case 'b':
							box = new VDividedBox(); 
							newNav.percentHeight = 100/dropData.divider; 
							dropTarget.percentHeight = 100-100/dropData.divider;
							newNav.percentWidth = dropTarget.percentWidth = 100;
							break;
					}
					
					parentContainer.addChildAt(box, index);
					
					box.width = size.width;
					box.height = size.height;
										
					if(!isNaN(percentSize.width))
						box.percentWidth = percentSize.width 
					if(!isNaN(percentSize.height))
						box.percentHeight = percentSize.height;
					
					parentContainer.validateNow();

					box.validateNow();
								
					switch(dropData.pos) {
						case 'l':
						case 't':
							box.addChild(newNav);
							box.addChild(dropTarget);
							break;
						case 'r':
						case 'b':
							box.addChild(dropTarget);
							box.addChild(newNav);
							break;
					}
					
					box.validateNow();
					
					newBar = newNav.getSuperTabBar();		
				}
				
				if(newBar)
				{
					var oldIndex:Number = parentBar.getChildIndex(dragTab);
					var newIndex:Number = newBar.numChildren;
					var reorderEvent:TabReorderEvent = new TabReorderEvent(SuperTabBar.TABS_REORDERED, false, true, parentBar, oldIndex, newIndex)
					newBar.dispatchEvent(reorderEvent);
				}
			}			
		}
		
		/**
		 * @private
		 */
		private function tabDragEnter(event:DragEvent):void{
			
			if(event.dragSource.hasFormat('tabDrag') && event.draggedItem != event.dragInitiator){
				if(this.dataProvider is ViewStack) {
					if(event.dragSource.hasFormat("stackDP")) {
						DragManager.acceptDragDrop(IUIComponent(event.target));
					}	
				}
				else if(this.dataProvider is IList) {
					if(event.dragSource.hasFormat("listDP")) {
						DragManager.acceptDragDrop(IUIComponent(event.target));
					}
				}

			}
		}
		
		/**
		 * @private
		 */
		private function tabDragOver(event:DragEvent):void{
			// We should accept tabs dragged onto other tabs, but not a tab dragged onto itself
			if(event.dragSource.hasFormat('tabDrag') && event.dragInitiator != event.currentTarget){
				
				var dropTab:SuperTab = (event.currentTarget as SuperTab);
				var dropIndex:Number = this.getChildIndex(dropTab);
				
				// gap is going to be the indicatorOffset that will be used to place the indicator
				var gap:Number = 0;
				
				// We need to figure out if we're on the left half or right half of the
				// tab. This boolean tells us this so we know where to draw the indicator
				var left:Boolean = event.localX < dropTab.width/2;
				
				if((left && dropIndex > 0) 
					|| (dropIndex < this.numChildren - 1) ) {
					gap = this.getStyle("horizontalGap")/2;
				}
				
				gap = left ? -gap : dropTab.width + gap;
				
				dropTab.showIndicatorAt(gap);
				
				DragManager.showFeedback(DragManager.LINK);
			}
		}
		
		/**
		 * @private
		 */
		private function tabDragExit(event:DragEvent):void{
			var dropTab:SuperTab = (event.currentTarget as SuperTab);
			// turn off showing the indicator icon
			dropTab.showIndicator = false;			
		}
		
		/**
		 * @private
		 */
		private function tabDragDrop(event:DragEvent):void{
			if(event.dragSource.hasFormat('tabDrag') && event.draggedItem != event.dragInitiator){
			
				var dropTab:SuperTab = (event.currentTarget as SuperTab);
				var dragTab:SuperTab = (event.dragInitiator as SuperTab);
				
				var left:Boolean = event.localX < dropTab.width/2;
				
				//var parentNavigator:SuperTabNavigator;
				var parentBar:SuperTabBar;
				
				// Since we allow mouseChildren to enabled the close button we might
				// get drag and drop events fired from the children components (ie the label
				// or icon). So we need to find the SuperTab object, SuperTabBar, and the 
				// SuperTabNavigator object from wherever we might be down the chain of children.
				var object:* = event.dragInitiator;
				while(object && object.parent) {
					object = object.parent;
					
					if(object is SuperTab) {
						dragTab = object;
					}
					else if(object is SuperTabBar) {
						parentBar = object;
						break;
					}
					/*
					else if(object is SuperTabNavigator) {
						parentNavigator = object as SuperTabNavigator;
						break;
					}*/
				}
				
				// We've done the drop so no need to show the indicator anymore	
				dropTab.showIndicator = false;
				
				var oldIndex:Number = parentBar.getChildIndex(dragTab);
				
				var newIndex:Number = this.getChildIndex(dropTab);
				if(!left) {
					newIndex += 1;
				}
				
				this.dispatchEvent(new TabReorderEvent(SuperTabBar.TABS_REORDERED, false, true, parentBar, oldIndex, newIndex));
			}	
			
		}
		
	}
}