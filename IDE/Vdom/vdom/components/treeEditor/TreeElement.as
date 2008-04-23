package vdom.components.treeEditor
{
	import flash.display.Bitmap;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.net.ObjectEncoding;
	
	import mx.containers.Canvas;
	import mx.controls.Button;
	import mx.controls.Image;
	import mx.controls.Label;
	import mx.controls.TextArea;
	import mx.controls.TextInput;
	import mx.managers.PopUpManager;
	
	import vdom.connection.soap.Soap;
	import vdom.connection.soap.SoapEvent;
	import vdom.controls.resourceBrowser.ResourceBrowser;
	import vdom.events.DataManagerEvent;
	import vdom.events.ResourceBrowserEvent;
	import vdom.events.TreeEditorEvent;
	import vdom.managers.DataManager;
	import vdom.managers.FileManager;
	
	public class TreeElement extends Canvas
	{
		private var btLine:Button;
		private var btDelete:Button;
		private var btLessen:Button; 
		private var txt:Label;
		private var textArea:TextArea;
		private var _ID:String;
//		private var rect:Canvas = new Canvas();
		private var min:Boolean = false;
		public var drag:Boolean = true;
		private var image:Image;
		private var imgBackGround:Image;
		private var imgPlus:Image;
		private var imgMenu:Image;
		private var imgheader:Image;
		private var imgDelete:Image;
		private var imgType:Image;
		private var imgLine:Image;
		private var cnvUpLayer	:Canvas = new Canvas();
		private var cnvDownLayer:Canvas = new Canvas();		
		private var txtInp:TextInput;
		private var _type:Label;
		private var soap:Soap = Soap.getInstance();
		private var dataManager:DataManager;
		private var _ratio:Number = 0.8;
		
		
		
		private  var _resourceID:String = '';
		
	//	[Embed(source='/assets/treeEditor/treeEditor.swf', symbol='defaultPicture')]
	//	[Bindable]
	//	public var defaultPicture:Class;
	
		[Embed(source='/assets/treeEditor/treeEditor.swf', symbol='cube')]
				[Bindable]
		private var defaultPicture:Class;
	
		[Embed(source='/assets/treeEditor/treeEditor.swf', symbol='backGround')]
		[Bindable]
		public var backGround:Class;
		
		[Embed(source='/assets/treeEditor/treeEditor.swf', symbol='header')]
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
		
		[Embed(source='/assets/treeEditor/treeEditor.swf', symbol='selected')]
		[Bindable]
		public var selected:Class; 
		
		
		
		public function TreeElement()
		{
			super();
			
		//	clipContent = false;
			cnvUpLayer.clipContent = false;
			
			dataManager = DataManager.getInstance();
			
			initUpBody();
			initDownBody(); 
			updateRatio();
			
			isRedraw = true;
		//	buttonMode = true;
			
			addEventListener(MouseEvent.CLICK, endFormatinfHandler)
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
			min = !min
			changeState(min)
		}
		
		
		
		private function txtDoubleClickHandler(msEvt:MouseEvent):void
		{
			txtInp.visible = true;
			txtInp.text  = txt.text;
			txtInp.setFocus();
			txtInp.setSelection(0, 100);
			txtInp.addEventListener(KeyboardEvent.KEY_UP, txtInpKeyUpHandler);
			txtInp.addEventListener(MouseEvent.CLICK, txtInpClickHandler);
		}
		
		private function txtInpKeyUpHandler(kbEvt:KeyboardEvent):void
		{
			if(kbEvt.keyCode == 13)
			{
				txtInp.removeEventListener(KeyboardEvent.KEY_UP, txtInpKeyUpHandler);
				txtInp.removeEventListener(MouseEvent.CLICK, txtInpClickHandler);
				
				txt.text = txtInp.text;
				txtInp.visible = false;
				saveChange()
			}
		}
		
		private function txtInpClickHandler(msEvt:MouseEvent):void
		{
				msEvt.stopImmediatePropagation();
		}
		
		private function textAreaDoubleClickHandler(msEvt:MouseEvent):void
		{
			
			textArea.editable = true;
			textArea.selectable = true;
			textArea.focusEnabled = true;
			textArea.setFocus();
			textArea.setStyle('fontWeight', "normal"); 
			textArea.addEventListener(MouseEvent.CLICK, textAreaClickHandler);
		}
		
		private function textAreaClickHandler(msEvt:MouseEvent):void
		{
			msEvt.stopImmediatePropagation();
		}
		
		private function endFormatinfHandler(msEvt:MouseEvent):void
		{
			
			
			if(txtInp.visible)
			{
				txtInp.removeEventListener(MouseEvent.CLICK, txtInpClickHandler);
				
				txt.text = txtInp.text;
				txtInp.visible = false;
				saveChange();
			}
			
			if(textArea.editable  )
			{
				textArea.removeEventListener(MouseEvent.CLICK, textAreaClickHandler);
				textArea.editable = false;
				textArea.selectable = false;
				textArea.setStyle('fontWeight', "bold");
				saveChange();
			}
		}
		
		
		private function lineClickHandler(msEvt:MouseEvent):void
		{
		//	trace('Я нажата');
			dispatchEvent(new TreeEditorEvent(TreeEditorEvent.START_DRAW_LINE, _ID));
		}
		
		private function deleteClickHandler(msEvt:MouseEvent):void
		{
			dispatchEvent(new TreeEditorEvent(TreeEditorEvent.DELETE, _ID));	
		}
		
	
		
		
		/****
		 * 
		 * 			resource Browser Launcher
		 * 
		 * 
		 * */
		private function imageDoubleClickHandler(msEvt:MouseEvent):void 
		{
			var rbWnd:ResourceBrowser = ResourceBrowser(PopUpManager.createPopUp(this, ResourceBrowser, true));
			rbWnd.selectedItemID = _resourceID;
			rbWnd.addEventListener(ResourceBrowserEvent.RESOURCE_SELECTED, resourseSelectedHandler);
		}
		
		private var fileManager:FileManager = FileManager.getInstance();
		private function resourseSelectedHandler(rbEvt:ResourceBrowserEvent):void 
		{
				_resourceID = rbEvt.resourceID;
				fileManager.loadResource(dataManager.currentApplicationId,  _resourceID, this);
		}	
		
		public function set resource(data:Object):void
		{
				image.source = data.data;
		}
				
			// при нажатии кнопки свернуть
		private function changeState(blHide:Boolean):void
		{
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
			dataManager.addEventListener(DataManagerEvent.CURRENT_PAGE_CHANGED, changeAttributes);
			dataManager.changeCurrentPage(_ID);
			 
		}
		
		private function changeAttributes(dmEvt:DataManagerEvent):void
		{
			dataManager.removeEventListener(DataManagerEvent.CURRENT_PAGE_CHANGED, changeAttributes);
			
			dataManager.addEventListener(DataManagerEvent.UPDATE_ATTRIBUTES_COMPLETE, updateAttributeCompleteHandler);
			
			trace('1) '+dataManager.currentObject.Attributes);
			
			//dataManager.currentObject.Attributes.Attribute.(@Name ==  "description")[0] = textArea.text;
			//dataManager.currentObject.Attributes.Attribute.(@Name ==  "title")[0] = txt.text;
			
			var str:String = 
			 	'<Attributes>' + 
			 		' <Attribute Name="description">' + textArea.text+'</Attribute>'+
			 		' <Attribute Name="title">' + txt.text + '</Attribute>' + 
			 	' </Attributes>';
			var xml:XML = XML(str)	
			dataManager.currentObject.Attributes = xml;
			trace('2) '+dataManager.currentObject.Attributes);   
			
			dataManager.updateAttributes();
			trace('changeAttributes');
		}
		
		private function updateAttributeCompleteHandler(dmEvt:DataManagerEvent):void
		{
			dataManager.removeEventListener(DataManagerEvent.UPDATE_ATTRIBUTES_COMPLETE, updateAttributeCompleteHandler);
			trace('updateAttributeCompleted')
		}
		
		
	/***
	 * 
	 * 
	 * 			set application resource
	 * 		needed in change for  Orions script
	 * 
	 * 
	 * */
	 private function setResource(restype:String, resname:String, resdata:String):void
	 {
	 	trace('restype: '+ restype);
	 	soap.setResource(dataManager.currentApplicationId,	 
	 												restype, 
	 												resname, 
	 												resdata );
		soap.addEventListener(SoapEvent.SET_RESOURCE_OK , setResourceOkHandler);
	 	soap.addEventListener(SoapEvent.SET_RESOURCE_ERROR, setResourceErrorHandler);
	 	
	 }
	
	 private function setResourceOkHandler(spEvt:SoapEvent):void
	 {
	 	soap.removeEventListener(SoapEvent.SET_RESOURCE_OK, setResourceOkHandler);
	 	soap.removeEventListener(SoapEvent.SET_RESOURCE_ERROR, setResourceErrorHandler);
	 	
	 	var rez:XML = spEvt.result;
	 	_resourceID = rez.Resource.@id;
	 }
	 
	 private function setResourceErrorHandler(spEvt:SoapEvent):void
	 {
	 	trace('ERROR set resourse')
	 	image.source = defaultPicture;
	 	
	 	soap.removeEventListener(SoapEvent.SET_RESOURCE_OK, setResourceOkHandler);
	 	soap.removeEventListener(SoapEvent.SET_RESOURCE_ERROR, setResourceErrorHandler);
	 }
	 
	 private function startDragHandler(msEvt:MouseEvent):void
	 {
	 	if( txtInp.visible == false)
	 	{
	 		dispatchEvent(new TreeEditorEvent(TreeEditorEvent.START_REDRAW_LINES, _ID));
	 		startDrag();
	 	}
	 		
	 }
	  private function stopDragHandler(msEvt:MouseEvent):void
	 {
	  	stopDrag();
	  	dispatchEvent(new TreeEditorEvent(TreeEditorEvent.STOP_REDRAW_LINES, _ID));	
	 }

		override public function set name(names:String):void
		{
			txt.text = names;
			txtInp.text = txt.text;
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
		
		public function set current(data:Boolean):void
		{
			if(data)imgheader.source = selected;
				else imgheader.source = header
			
		}

		
		/*      resourceID         */
		
		public function set resourceID(names:String):void
		{
			_resourceID = names;
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
			if(names == 'true')	changeState(true)
				else changeState(false);
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
			textArea.text = names;
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
		
		 public function set typeID(resID:String):void
		{
			fileManager.loadResource(dataManager.currentApplicationId,  resID, this, 'typeResourse');
		}
		
		public function set typeResourse(data:Object):void
		{
			imgType.source = data.data;
		}
		
		/*      select      */
		
		public function get select():Boolean
		{
			return txtInp.visible || textArea.editable;
		} 
		
		public function unSelect():void
		{
			endFormatinfHandler(new MouseEvent(MouseEvent.CLICK));
		}
		
		/*      sourseImg      */
		
		public function set sourseImg(obj:Bitmap):void
		{
			image.source = obj;
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
			
			
			//imgheader.maintainAspectRatio = true;
			//imgheader.scaleContent = true;
			
			txt = new Label();
			txt.setStyle('color', '#ffffff');
			txt.setStyle('fontWeight', "bold"); 
			txt.setStyle('textAlign', 'center');
			
			
			txt.buttonMode = true;
			txt.doubleClickEnabled = true;
			txt.addEventListener(MouseEvent.DOUBLE_CLICK, txtDoubleClickHandler)
			
			imgMenu = new Image();
			imgMenu.source = menu;
			
			
			imgLine = new Image();
			imgLine.source = line;
			imgLine.buttonMode = true;
			
			imgLine.addEventListener(MouseEvent.CLICK, lineClickHandler);
			
			imgDelete = new Image();
			imgDelete.source = delet; 
			imgDelete.buttonMode = true;
			
			imgDelete.addEventListener(MouseEvent.CLICK, deleteClickHandler);
			
			imgPlus = new Image();
			imgPlus.source = plus;
			imgPlus.buttonMode = true;
				
			imgPlus.addEventListener(MouseEvent.CLICK, plusClickHandler);	
			
			txtInp = new TextInput();
			txtInp.setStyle('borderColor', '#000000');
			txtInp.setStyle('fontWeight', "bold"); 
			txtInp.setStyle('textAlign', 'center');
			
			txtInp.visible = false;
			
			cnvUpLayer.addChild(imgheader);
			cnvUpLayer.addChild(imgMenu);
			cnvUpLayer.addChild(txt);
			cnvUpLayer.addChild(imgPlus);
			cnvUpLayer.addChild(txtInp);
			cnvUpLayer.addChild(imgLine);
			cnvUpLayer.addChild(imgDelete);
			
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
			
			textArea = new TextArea();
			textArea.setStyle('fontWeight', "bold"); 
			
			textArea.editable = false;
			textArea.focusEnabled = true;
			textArea.text = 'press double click for edit this text';
			
			textArea.doubleClickEnabled = true;
			textArea.addEventListener(MouseEvent.DOUBLE_CLICK, textAreaDoubleClickHandler);
			cnvDownLayer.addChild(textArea);
			
			image = new Image();
			image.source = defaultPicture;
			
			image.maintainAspectRatio = true;
			image.scaleContent = true;
			
			image.doubleClickEnabled = true;
			image.addEventListener(MouseEvent.CLICK, imageDoubleClickHandler);
			cnvDownLayer.addChild(image);
			
			imgType = new Image();
			imgType.maintainAspectRatio = true;
			imgType.scaleContent = true;
			cnvDownLayer.addChild(imgType);
			
			_type = new Label();
			_type.text = 'text  ';
			
			_type.setStyle('fontWeight', "bold"); 
			cnvDownLayer.addChild(_type);
		}
		

		private function updateRatio():void
		{	
			imgheader.width = 243 * _ratio;
			imgheader.height = 30 * _ratio;
			
			imgMenu.width = 56 * _ratio;
			imgMenu.height = 14 * _ratio;

			txt.y = 2 * _ratio;
			txt.width =  240 * _ratio;
			
			 
			imgLine.y = -12 * _ratio; 
			imgLine.x = 20 * _ratio;	
			imgLine.width = 10 * _ratio;
			imgLine.height = 10 * _ratio;
			
			//imgDelete 
			imgDelete.y = -12 * _ratio;
			imgDelete.x = 40 * _ratio;	
			imgDelete.width = 10 * _ratio;
			imgDelete.height = 10 * _ratio;
			
			 
			imgPlus.y = -12 * _ratio;
			imgPlus.x = 4 * _ratio;
			imgPlus.width = 10 * _ratio;
			imgPlus.height = 10 * _ratio;
			
		//	txtInp 
			txtInp.y = 2 * _ratio;
			txtInp.width =  240 * _ratio;
			
		//	cnvUpLayer
			//-----------------------------------
			cnvDownLayer.y = 1 * _ratio;
			
			imgBackGround.y = 27 * _ratio;
			imgBackGround.width = 243 * _ratio;
			imgBackGround.height = 115 * _ratio;
			
			textArea.x = 115 * _ratio; // btButton.width;
			textArea.y = 35 * _ratio;  //txt.height;
			
			image.x = 10 * _ratio;
			image.y = 35 * _ratio;
			image.height = 100 * _ratio;
			image.width = 95 * _ratio;
			
			imgType.x = _ratio * 217;
			imgType.y = _ratio * 118;
			imgType.height = _ratio * 20; 
			imgType.width = _ratio * 20;
			
			
			textArea.width =  125 * _ratio;
			textArea.height = 75 * _ratio;
			
			_type.y = 120 * _ratio;
			_type.x = 120 * _ratio;
			_type.width =  100 * _ratio;
			_type.setStyle('fontSize', "8");
			
		}
		
	 
	}
}