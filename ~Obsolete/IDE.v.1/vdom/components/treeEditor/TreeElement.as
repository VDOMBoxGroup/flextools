package vdom.components.treeEditor
{
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.events.IOErrorEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.system.LoaderContext;
	import flash.utils.Timer;
	
	import mx.containers.Canvas;
	import mx.controls.Button;
	import mx.controls.Image;
	import mx.controls.Label;
	import mx.controls.Text;
	
	import vdom.events.DataManagerEvent;
	import vdom.events.TreeEditorEvent;
	import vdom.managers.DataManager;
	import vdom.managers.FileManager;
	
	public class TreeElement extends Canvas
	{
		private var btLine:Button;
		private var btDelete:Button;
		private var btLessen:Button; 
		private var txt:Label;
		private var textArea:Text;
		private var _ID:String;
//		private var rect:Canvas = new Canvas();
		private var min:Boolean = false;
		public var drag:Boolean = true;
		private var image:Image;
		private var imgBackGround:Image;
		private var imgPlus:Image;
		private var imgMenu:Image;
		private var imgheader:Image;
		private var imgSelected:Image;
		private var imgDelete:Image;
		private var imgType:Image;
		private var imgLine:Image;
		private var imgStart:Image;
		private var cnvUpLayer	:Canvas = new Canvas();
		private var cnvDownLayer:Canvas = new Canvas();		
//		private var txtInp:TextInput;
		private var _type:Label;
//		private var soap:Soap = Soap.getInstance();
		private var dataManager:DataManager;
		private var _ratio:Number = 0.8;
//		private var _description:Label;
		
		
		
		private  var _resourceID:String = '';
		
	//	[Embed(source='/assets/treeEditor/treeEditor.swf', symbol='defaultPicture')]
	//	[Bindable]
	//	public var defaultPicture:Class;
	
		[Embed(source='/assets/treeEditor/treeEditor.swf', symbol='cube')]
				[Bindable]
		private var defaultPicture:Class;
	
//		[Embed(source='/assets/treeEditor/treeEditor.swf', symbol='backGround')]
		[Embed(source='/assets/treeEditor/test/content.png')]
		[Bindable]
		public var backGround:Class;
		
//		[Embed(source='/assets/treeEditor/treeEditor.swf', symbol='header')]
		[Embed(source='/assets/treeEditor/test/header.png')]
		[Bindable]
		public var header:Class;
		
		[Embed(source='/assets/treeEditor/treeEditor.swf', symbol='plus')]
		[Bindable]
		public var plus:Class;
		
		[Embed(source='/assets/treeEditor/treeEditor.swf', symbol='minus')]
		[Bindable]
		public var minus:Class;
		
		[Embed(source='/assets/treeEditor/treeEditor.swf', symbol='line')]
		[Bindable]
		public var line:Class;
		
		[Embed(source='/assets/treeEditor/treeEditor.swf', symbol='delete')]
		[Bindable]
		public var delet:Class;
		
		[Embed(source='/assets/treeEditor/treeEditor.swf', symbol='menu')]
		[Bindable]
		public var menu:Class;
		
		[Embed(source='/assets/treeEditor/treeEditor.swf', symbol='start_page')]
		[Bindable]
		public var start_page:Class; 
		
//		[Embed(source='/assets/treeEditor/treeEditor.swf', symbol='selected')]
		[Embed(source='/assets/treeEditor/test/header_selected.png')]
		[Bindable]
		public var _selected_header:Class; 
		
		[Embed(source='/assets/treeEditor/test/content_selected.png')]
		[Bindable]
		public var _selected_content:Class; 
		
		[Embed(source='/assets/treeEditor/treeEditor.swf', symbol='bt_start_page')]
		[Bindable]
		public var bt_start_page:Class; 
		
		[Embed(source='/assets/treeEditor/test/header_home.png')]
		[Bindable]
		public var header_home:Class; 
		
		[Embed(source='/assets/treeEditor/test/header_home_selected.png')]
		[Bindable]
		public var header_home_selected:Class; 
		
		
		
		
		public function TreeElement(str:String ='')
		{
			super();
//			var bt:Button = new Button();
//			addChild(bt);
			
//			super.cacheAsBitmap = true;
		//	clipContent = false;
			cnvUpLayer.clipContent = false;
			
			dataManager = DataManager.getInstance();
			
			initUpBody();
			initDownBody(); 
			updateRatio();
			
			isRedraw = true;
		//	buttonMode = true;
			
			addEventListener(MouseEvent.CLICK, endFormatinfHandler);
		}
		
		
		
		private var isRedraw:Boolean;
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
			
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			if (isRedraw) {
				
				dispatchEvent(new TreeEditorEvent(TreeEditorEvent.REDRAW_LINES, _ID));
				isRedraw = false;
			}
		}
		
		
		
		
		private function plusClickHandler(msEvt:MouseEvent):void
		{
			if(!_availabled)
				return;
//			min = !min
			changeState(!min);
			dispatchEvent(new TreeEditorEvent(TreeEditorEvent.NEED_TO_SAVE));
//			dispatchEvent(new TreeEditorEvent(TreeEditorEvent.SAVE_TO_SERVER));
		}
		
		private function startPageClickHandler(msEvt:MouseEvent):void
		{
			if(!_availabled)
				return;
//			selected = true;
			dispatchEvent(new TreeEditorEvent(TreeEditorEvent.CHANGE_START_PAGE, _ID));
		}
		
		
		private function txtDoubleClickHandler(msEvt:MouseEvent):void
		{
			msEvt.stopImmediatePropagation();
			changeState(!min);
			dispatchEvent(new TreeEditorEvent(TreeEditorEvent.NEED_TO_SAVE));
//			txtInp.visible = true;
//			txtInp.text  = txt.text;
//			txtInp.setFocus();
//			txtInp.setSelection(0, 100);
//			txtInp.addEventListener(KeyboardEvent.KEY_UP, txtInpKeyUpHandler);
//			txtInp.addEventListener(MouseEvent.CLICK, txtInpClickHandler);
		}
		
		private function txtInpKeyUpHandler(kbEvt:KeyboardEvent):void
		{
//			if(kbEvt.keyCode == 13)
//			{
//				txtInp.removeEventListener(KeyboardEvent.KEY_UP, txtInpKeyUpHandler);
//				txtInp.removeEventListener(MouseEvent.CLICK, txtInpClickHandler);
//				
//				txt.text = txtInp.text;
//				txtInp.visible = false;
//				saveChange()
//			}
		}
		
		private function txtInpClickHandler(msEvt:MouseEvent):void
		{
				msEvt.stopImmediatePropagation();
		}
	/*	
		private function textAreaDoubleClickHandler(msEvt:MouseEvent):void
		{
			if(!_availabled)
				return;
//				
			textArea.editable = false;
			textArea.selectable = false;
//			textArea.focusEnabled = true;
//			textArea.setFocus();
//			textArea.setStyle('fontWeight', "normal"); 
			textArea.addEventListener(MouseEvent.CLICK, textAreaClickHandler);
		}
		*/
		private function textAreaClickHandler(msEvt:MouseEvent):void
		{
			msEvt.stopImmediatePropagation();
		}
		
		private function endFormatinfHandler(msEvt:MouseEvent):void
		{
//			if(txtInp.visible)
//			{
//				txtInp.removeEventListener(MouseEvent.CLICK, txtInpClickHandler);
//				
//				txt.text = txtInp.text;
//				txtInp.visible = false;
//				saveChange();
//			}
//			
//			if(textArea.editable  )
//			{
//				textArea.removeEventListener(MouseEvent.CLICK, textAreaClickHandler);
//				textArea.editable = false;
//				textArea.selectable = false;
//				textArea.setStyle('fontWeight', "bold");
//				saveChange();
//			}
		}
		
		
		private function lineClickHandler(msEvt:MouseEvent):void
		{
			msEvt.stopPropagation();
			if(!_availabled)
				return;
				
			dispatchEvent(new TreeEditorEvent(TreeEditorEvent.START_DRAW_LINE, _ID));
		}
		
		private function deleteClickHandler(msEvt:MouseEvent):void
		{
			if(!_availabled)
				return;
				
			dispatchEvent(new TreeEditorEvent(TreeEditorEvent.DELETE, _ID));	
		}
		
	
		
		
		/****
		 * 
		 * 			resource Browser Launcher
		 * 
		 * 
		 * */
	/*
		private function imageDoubleClickHandler(msEvt:MouseEvent):void 
		{
//			trace('image0');
			if(!_availabled)
				return;
				
//			trace('image1');	
			var rbWnd:ResourceBrowser = ResourceBrowser(PopUpManager.createPopUp(this, ResourceBrowser, true));
			rbWnd.selectedItemID = _resourceID;
			rbWnd.addEventListener(ResourceBrowserEvent.RESOURCE_SELECTED, resourseSelectedHandler);
			
			
		}
		*/
		private var fileManager:FileManager = FileManager.getInstance();
		/*
		private function resourseSelectedHandler(rbEvt:ResourceBrowserEvent):void 
		{
			
				_resourceID = rbEvt.resourceID;
				fileManager.loadResource(dataManager.currentApplicationId,  _resourceID, this);
				
				dispatchEvent(new TreeEditorEvent(TreeEditorEvent.SAVE_TO_SERVER));
		}	
		*/
		private var loader:Loader;
		public function set resource(data:Object):void
		{
			loader = new Loader();
			
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadComplete);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, loadError);
			
			var loaderContextInfo:LoaderContext = new LoaderContext();
			loaderContextInfo.allowLoadBytesCodeExecution = true;
			
            loader.loadBytes(data.data, loaderContextInfo);
		}
		
		
		private function loadError(evt:IOErrorEvent):void 
		{
   			
   			loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, loadComplete);
			loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, loadError);
            
//            image.source = defaultPicture;
   		}
		
		private function loadComplete(evt:Event):void 
		{
			loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, loadComplete);
			loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, loadError);
   			
   			image.source = loader.content;
   		}
				
			// при нажатии кнопки свернуть
		private function changeState(blHide:Boolean):void
		{
			if(min == blHide)
				return;
				
			if (!blHide){
				if(contains(cnvDownLayer))	removeChild(cnvDownLayer);
				imgPlus.source = plus;
			}else{
				addChild(cnvDownLayer);
				imgPlus.source = minus;
			}	
			min = blHide;
			isRedraw = true;
			
			
		}
		
		private function btLessenOut(muEvt:MouseEvent):void
		{
			this.drag = true;	
		}
	
		
		private function saveChange():void
		{
//			dataManager.addEventListener(DataManagerEvent.PAGE_CHANGED, changePagesHandler);
//			dataManager.changeCurrentPage(_ID);
		}
	/*	
		private function changePagesHandler(dmEvt:DataManagerEvent):void
		{
			dataManager.removeEventListener(DataManagerEvent.PAGE_CHANGED, changePagesHandler);
			
			dataManager.addEventListener(DataManagerEvent.OBJECT_CHANGED, changeObjectHandler);
			
			dataManager.changeCurrentObject(_ID);
		}
	/*	
		private function changeObjectHandler(dmEvt:DataManagerEvent):void
		{
			dataManager.removeEventListener(DataManagerEvent.OBJECT_CHANGED, changeObjectHandler);
			
			dataManager.addEventListener(DataManagerEvent.UPDATE_ATTRIBUTES_COMPLETE, updateAttributeCompleteHandler);
			
			var str:String = 
			 	'<Attributes>' + 
			 		' <Attribute Name="description">' + textArea.text+'</Attribute>'+
			 		' <Attribute Name="title">' + txt.text + '</Attribute>' + 
			 	' </Attributes>';
			var xml:XML = XML(str)	
			dataManager.currentObject.Attributes = xml;
//			trace('2) '+dataManager.currentObject.Attributes);   
			
			dataManager.updateAttributes();
//			trace('changeAttributes');
		}
		*/
		private function updateAttributeCompleteHandler(dmEvt:DataManagerEvent):void
		{
			dataManager.removeEventListener(DataManagerEvent.UPDATE_ATTRIBUTES_COMPLETE, updateAttributeCompleteHandler);
//			trace('updateAttributeCompleted')
		}
		

	 
	 private function startDragHandler(msEvt:MouseEvent):void
	 {
	 	if(!_availabled)
				return;
				
//	 	if( txtInp.visible == false)
//	 	{
	 		dispatchEvent(new TreeEditorEvent(TreeEditorEvent.START_REDRAW_LINES, _ID));
	 		//startDrag();
//	 	}
	 		
	 }
	  private function stopDragHandler(msEvt:MouseEvent):void
	 {
	  	stopDrag();
	  	dispatchEvent(new TreeEditorEvent(TreeEditorEvent.STOP_REDRAW_LINES, _ID));	
	 }

		 public function set title(names:String):void
		{
			txt.text = names;
//			txtInp.text = txt.text;
		}
		
		public function get title():String
		{
			return  txt.text;
		}
		
		/*     ID         */
		
		public function set ID(names:String):void
		{
			_ID = names;
		}
		
		public function get ID():String
		{
			return _ID;
		}
		
		private var _curPage:Boolean
		public function set current(data:Boolean):void
		{
			_curPage = data;
			
			if(_curPage)
			{	
				if(_startPager)
					imgheader.source = header_home_selected;
				else
					imgheader.source = _selected_header;
				imgBackGround.source = _selected_content
			
			}else
			{	
				if(_startPager)
					imgheader.source = header_home;
				else
					imgheader.source = header;
				
				imgBackGround.source = backGround;	
			}
		}
		
		private var _startPager:Boolean;
		public function set selected(data:Boolean):void
		{
			_startPager = data;
			
			
			if(_curPage)
			{	
				if(_startPager)
					imgheader.source = header_home_selected;
				else
					imgheader.source = _selected_header;
			}else
			{	
				if(_startPager)
					imgheader.source = header_home;
				else
					imgheader.source = header;
			}
//			trace('prassed');
		}

		
		/*      resourceID         */
		
		public function set resourceID(names:String):void
		{
			_resourceID = names;
			if (_resourceID == "")
				 image.source = defaultPicture;
		}
		
		public function get resourceID():String
		{
			//txt.text = names;
			return  _resourceID;
		}
		
		
		/*      state         */
		
		public function set state(names:String):void
		{
			//txt.text = names;
		//	trace('names: ' +names);
//			if(names == 'true')	changeState(true)
//				else changeState(false);
				
			changeState(names == 'true');
		}
		
		public function get state():String
		{
			return  min.toString();
		}
		
		/*
		
		private function dispStartDrag(evt:MouseEvent):void
		{
			dispatchEvent(new TreeEditorEvent(TreeEditorEvent.START_DRAG, _ID));
		}
		 
		 */
		 /*       description         */
		 
		 public function set description(names:String):void
		{
			if(names =='')
				textArea.text = resourceManager.getString('Tree','no_description');
			else
				textArea.text = resourceManager.getString('Tree','description')+":\n";
			
			if(names.length > 50)
			{
				textArea.text += names.slice(0,50) + "...";
				textArea.toolTip = names;
			}else
			{
				textArea.text += names;
				textArea.toolTip = '';
			}
		}
		
		public function get description():String
		{
			return  textArea.text;
		}
		
		
		
			/*      type      */
		
		 public function set type(names:String):void
		{
			_type.text = names;
		}
		
		public function get type():String
		{
			return  _type.text;
		}
		
		/*      type ID resourse     */
		
		private var _resID:String;
		public function set typeID(resID:String):void
		{
			_resID = resID;
			fileManager.loadResource(dataManager.currentApplicationId,  _resID, this, 'typeResourse');
		}
		
		public function get typeID():String
		{
			return _resID;
		}
		/*
		public function set state(bl:Boolean):void
		{
			changeState(bl);
		}
		*/
	/*	
		public function set typeResourse(data:Object):void
		{
			imgType.source = data.data;
		}
		*/
		private var loaderTypeRes:Loader = new Loader();
		public function set typeResourse(data:Object):void
		{
			loaderTypeRes.contentLoaderInfo.addEventListener(Event.COMPLETE, loaderTypeResComplete);
			
			loaderTypeRes.loadBytes(data.data);
			//image.source = data.data;
		}
		
		
		private function loaderTypeResComplete(evt:Event):void 
		{
   			loaderTypeRes.contentLoaderInfo.removeEventListener(Event.COMPLETE, loaderTypeResComplete);		
   			//image.width = loader.width;
   			//image.height = loader.height;
   			imgType.source = loaderTypeRes.content;
   		}
		
		
		
		/*      select      */
		
		public function get select():Boolean
		{
			return false;
//			return txtInp.visible || textArea.editable;
		} 
		
		public function unSelect():void
		{
			endFormatinfHandler(new MouseEvent(MouseEvent.CLICK));
		}
		
		/*      availabled      */
		
		private var _availabled:Boolean = true;
		public function set availabled(bl:Boolean):void
		{
//			trace('availabled'+ bl)
			_availabled = bl;
		}
		
		/*      sourseImg      */
		
		public function set sourseImg(obj:Bitmap):void
		{
			image.source = obj;
		}
		
		private var _xTo:Number = -1;
		public function set xTo(num:Number):void
		{
			_xTo = num;
			
		}
		
		private var _yTo:Number = -1;
		public function set yTo(num:Number):void
		{
			_yTo = num;
			
		}			
		
		private var delayTimer:Timer;
		public function play():void
		{
			var delay:Number = 1000;
			var repeatCount:int = 10;
			delayTimer = new Timer(0, repeatCount);
			delayTimer.addEventListener(TimerEvent.TIMER, timerHandler);
			
			dXtoX = (_xTo - this.x) / repeatCount;
			dYtoY = (_yTo - this.y) / repeatCount;
			
			delayTimer.start();

		}		
		
		private var dXtoX:Number = 0;
		private var dYtoY:Number = 0;
		private function timerHandler(tmEvt:TimerEvent):void
		{
			this.x = this.x + dXtoX;
			this.y = this.y + dYtoY;
//			trace('timerHandler: '+ this.x);
//			parent).validateDisplayList();
			
		}		
		/*
		public function set resource(obj:Object):void
		{
			image.source = obj.data;
		}
		*/
		private function initUpBody():void
		{
			imgheader = new Image();
			imgheader.source = header;
			
			imgSelected = new Image();
			imgSelected.source = _selected_header;
			
			
			
			//imgheader.maintainAspectRatio = true;
			//imgheader.scaleContent = true;
			
			txt = new Label();
			txt.setStyle('color', '#ffffff');
			txt.setStyle('fontWeight', "bold"); 
//			txt.setStyle('textAlign', 'center');
//			txt.setStyle('textAlign', 'right');
			
			txt.buttonMode = true;
			txt.doubleClickEnabled = true;
			txt.addEventListener(MouseEvent.DOUBLE_CLICK, txtDoubleClickHandler)
			
			imgMenu = new Image();
			imgMenu.source = menu;
			
			
			imgLine = new Image();
			imgLine.source = line;
			imgLine.buttonMode = true;
			imgLine.toolTip = resourceManager.getString('Tree','create_line');//----
			
			imgLine.addEventListener(MouseEvent.CLICK, lineClickHandler);
			
			imgDelete = new Image();
			imgDelete.source = delet; 
			imgDelete.buttonMode = true;
			imgDelete.toolTip = resourceManager.getString('Tree','delete'); //---
			
			imgDelete.addEventListener(MouseEvent.CLICK, deleteClickHandler);
			
			imgPlus = new Image();
			imgPlus.source = plus;
			imgPlus.buttonMode = true;
			imgPlus.toolTip = resourceManager.getString('Tree','min_max');
				
			imgPlus.addEventListener(MouseEvent.CLICK, plusClickHandler);	
			
			
			imgStart = new Image();
			imgStart.source = bt_start_page;
			imgStart.buttonMode = true;
			imgStart.toolTip = resourceManager.getString('Tree','set_start_page');
				
			imgStart.addEventListener(MouseEvent.CLICK, startPageClickHandler);	
			
			imgType = new Image();
			imgType.maintainAspectRatio = true;
			imgType.scaleContent = true;
			
			
			
//			txtInp = new TextInput();
//			txtInp.setStyle('borderColor', '#000000');
//			txtInp.setStyle('fontWeight', "bold"); 
//			txtInp.setStyle('textAlign', 'center');
//			
//			txtInp.visible = false;
			
			cnvUpLayer.addChild(imgMenu);
			cnvUpLayer.addChild(imgPlus);
			cnvUpLayer.addChild(imgStart);
//			cnvUpLayer.addChild(txtInp);
			cnvUpLayer.addChild(imgLine);
			cnvUpLayer.addChild(imgDelete);
			cnvUpLayer.addChild(imgheader);
			cnvUpLayer.addChild(txt);
			cnvUpLayer.addChild(imgType);
			
			cnvUpLayer.addEventListener(MouseEvent.MOUSE_DOWN, startDragHandler);
			cnvUpLayer.addEventListener(MouseEvent.MOUSE_UP, stopDragHandler)
			addChild(cnvUpLayer);
			
			
		}
		
		private function initDownBody():void
		{
			imgBackGround = new Image();
			imgBackGround.maintainAspectRatio = true;
			imgBackGround.scaleContent = true;
			
			imgBackGround.source = backGround;
			
			cnvDownLayer.addChild(imgBackGround);
			
//			_description = new Label();
//			cnvDownLayer.addChild(_description);
			
			textArea = new Text();
			textArea.setStyle('fontWeight', "bold");
//			textArea.
			
			
//			textArea.validateDisplayList();
			
//			textArea.editable = false;
			textArea.focusEnabled = false;
			textArea.selectable = false;
//			textArea.text = 'press double click for edit this text';
			
//			textArea.doubleClickEnabled = false;
//			textArea.addEventListener(MouseEvent.DOUBLE_CLICK, textAreaDoubleClickHandler);
			cnvDownLayer.addChild(textArea);
			
			image = new Image();
			image.source = defaultPicture;
			
			image.maintainAspectRatio = true;
			image.scaleContent = true;
			
			image.doubleClickEnabled = true;
//			image.addEventListener(MouseEvent.CLICK, imageDoubleClickHandler);
			cnvDownLayer.addChild(image);
			
			
			
			_type = new Label();
			_type.text = 'text  ';
			
			_type.setStyle('fontWeight', "bold"); 
			cnvDownLayer.addChild(_type);
		}
		

		private function updateRatio():void
		{	
//			imgheader.width = 243 * _ratio;
//			imgheader.height = 30 * _ratio;
			
			imgSelected.width = 243 * _ratio;
			imgSelected.height = 30 * _ratio;
			
			imgMenu.x = 4;
			imgMenu.y = 5 * _ratio;
			imgMenu.width = 76 * _ratio;
			imgMenu.height = 14 * _ratio;
			
			txt.x = 30;
			txt.y = 12 * _ratio;
			txt.width =  210 * _ratio;
			
			 
			imgLine.y = -7 * _ratio; 
			imgLine.x = 25 * _ratio;	
			imgLine.width = 10 * _ratio;
			imgLine.height = 10 * _ratio;
			
			//imgDelete 
			imgDelete.y = -7 * _ratio;
			imgDelete.x = 45 * _ratio;	
			imgDelete.width = 10 * _ratio;
			imgDelete.height = 10 * _ratio;
			
			 
			imgPlus.y = -7 * _ratio;
			imgPlus.x = 9 * _ratio;
			imgPlus.width = 10 * _ratio;
			imgPlus.height = 10 * _ratio;
			
			
			imgStart.y = -7 * _ratio;
			imgStart.x = 65 * _ratio;
			imgStart.width = 10 * _ratio;
			imgStart.height = 10 * _ratio;
			
			
			imgType.x = _ratio * 5;
			imgType.y = _ratio * 5;
			imgType.height = _ratio * 30; 
			imgType.width = _ratio * 30;
			
		//	txtInp 
//			txtInp.y = 2 * _ratio;
//			txtInp.width =  240 * _ratio;
			
			
		//	cnvUpLayer
			//-----------------------------------
			cnvDownLayer.y = 1 * _ratio;
			
			
			imgBackGround.y = 32 * _ratio;
			imgBackGround.x = -4;
//			imgBackGround.width = 243 * _ratio;
//			imgBackGround.height = 115 * _ratio;
			
			
			image.x = 10 * _ratio;
			image.y = 40 * _ratio;
			image.height = 100 * _ratio;
			image.width = 95 * _ratio;
			
			
//			_description.x = 115 * _ratio; // btButton.width;
//			_description.y = 35 * _ratio;
//			_description.width =  135 * _ratio;
//			
			textArea.x = 115 * _ratio; // btButton.width;
			textArea.y = 42 * _ratio;  //txt.height;
			textArea.width =  135 * _ratio;
			textArea.height = 73 * _ratio;
			
//			textArea.setStyle('widt', "105"); 
//			textArea.setStyle('height', "65"); 
//			textArea.validateDisplayList();
			
			_type.y = 115 * _ratio;
			_type.x = 140 * _ratio;
			_type.width =  100 * _ratio;
			_type.setStyle('fontSize', "8");
		}
		
		 override public function set y(value:Number):void
    {
    	 
        if (super.y == value)
            return;

        super.y = value;
        
        if( !isRedraw && value != 0)
        	dispatchEvent(new TreeEditorEvent(TreeEditorEvent.NEED_TO_SAVE));

    }
	 
	}
}