package vdom.components.eventEditor 
{
	import flash.display.Loader;
	import flash.events.MouseEvent;
	
	import mx.containers.Canvas;
	import mx.containers.VBox;
	import mx.controls.Button;
	import mx.controls.Image;
	import mx.controls.Label;
	import mx.controls.TextArea;
	import mx.controls.TextInput;
	import mx.controls.VRule;
	import mx.utils.UIDUtil;
	
	import vdom.events.TreeEditorEvent;
	import vdom.managers.DataManager;
	import vdom.managers.FileManager;
	
	

	public class EventEditorAction extends Canvas
	{
		[Embed(source='/assets/eventEditor/eventEditor.swf', symbol='header_action')]
		[Bindable]
		public var header:Class;
		
		[Embed(source='/assets/eventEditor/eventEditor.swf', symbol='plus')]
		[Bindable]
		public var plus:Class;
		
		[Embed(source='/assets/eventEditor/eventEditor.swf', symbol='minus')]
		[Bindable]
		public var minus:Class;
		
		[Embed(source='/assets/eventEditor/eventEditor.swf', symbol='line')]
		[Bindable]
		public var line:Class;
		
		[Embed(source='/assets/eventEditor/eventEditor.swf', symbol='delete')]
		[Bindable]
		public var delet:Class;
		
		[Embed(source='/assets/eventEditor/eventEditor.swf', symbol='menu')]
		[Bindable]
		public var menu:Class;
		
		[Embed(source='/assets/eventEditor/actions.png')]
		[Bindable]
		public var action:Class;
		
	
		private var btLine:Button;
		private var btDelete:Button;
		private var btLessen:Button; 
		private var txt:Label;
		private var textArea:TextArea;
		private var _ID:String;
//		private var rect:Canvas = new Canvas();
		private var min:Boolean = true;
		public var drag:Boolean = true;
		private var image:Image;
		private var imgBackGround:Image;
		private var imgPlus:Image;
		private var imgMenu:Image;
		private var imgheader:Image;
		private var imgDelete:Image;
		private var imgType:Image;
//		private var imgLine:Image;
		private var cnvUpLayer	:Canvas = new Canvas();
		private var cnvDownLayer:Canvas = new Canvas();		
		private var txtInp:TextInput;
		private var _type:Label;
		private var dataManager:DataManager;
		private var _ratio:Number = 0.7;
	
		
		public function EventEditorAction(data:Object, containerID:String)
		{
//			trace('containerID: '+containerID);
			super();
			dataManager = DataManager.getInstance();
	
			_ID = UIDUtil.createUID();
			cnvUpLayer.clipContent = false;
			
			//dataManager = DataManager.getInstance();
			
			initUpBody();
			initDownBody(data, containerID);
			
			updateRatio();
			
			isRedraw = true;
			// set x, y
			
			if (data.@Top[0])
			{
				this.y = data.@Top;
				this.x = data.@Left;
				_ID  = data.@ID;
				changeState(data.@State =="true");
				setValue(data);
			}
		}
		
		private var isRedraw:Boolean;
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void 
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			if (isRedraw) 
			{
				dispatchEvent(new TreeEditorEvent(TreeEditorEvent.REDRAW_LINES, _ID));
				isRedraw = false;
			}
		}
		
		
		
		
		private function plusClickHandler(msEvt:MouseEvent):void
		{
			min = !min
			changeState(min)
		}
		
		private function lineClickHandler(msEvt:MouseEvent):void
		{
		//	trace('Я нажата');
			dispatchEvent(new TreeEditorEvent(TreeEditorEvent.START_DRAW_LINE, _ID));
		}
		
		private function deleteClickHandler(msEvt:MouseEvent):void
		{
		//	parent.removeChild(this);
			dispatchEvent(new TreeEditorEvent(TreeEditorEvent.DELETE, _ID));	
		}
		
	
		
		
		/****
		 * 
		 * 			resource Browser Launcher
		 * 
		 * 
		 * */
				
			// при нажатии кнопки свернуть
		private function changeState(blHide:Boolean):void
		{
			if (!blHide)
			{
				if(contains(cnvDownLayer))	
					removeChild(cnvDownLayer);
				
				imgPlus.source = plus;
				txt.text = _name +' : '+_methodName ;
			}else
			{
				if(!contains(cnvDownLayer))	
					addChild(cnvDownLayer);
				imgPlus.source = minus;
				txt.text = resourceManager.getString('Event','action');
			}	

			min = blHide;
//			trace(min.toString())
			isRedraw = true;
			
		}
		
		private function btLessenOut(muEvt:MouseEvent):void
		{
			this.drag = true;	
		}
	
		
	 
	 private function startDragHandler(msEvt:MouseEvent):void
	 {
	 	if( txtInp.visible == false)
	 	{
	 		dispatchEvent(new TreeEditorEvent(TreeEditorEvent.START_REDRAW_LINES, _ID));
//	 		startDrag();
	 	}
	 		
	 }
	  private function stopDragHandler(msEvt:MouseEvent):void
	 {
	  	stopDrag();
	  	dispatchEvent(new TreeEditorEvent(TreeEditorEvent.STOP_REDRAW_LINES, _ID));	
	 }

		

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
			txt.text = resourceManager.getString('Event','action');
			//txt.addEventListener(MouseEvent.DOUBLE_CLICK, txtDoubleClickHandler)
			
			imgMenu = new Image();
			imgMenu.source = menu;
			imgMenu.maintainAspectRatio = false;
			imgMenu.scaleContent = true;
			
		/*	
			imgLine = new Image();
			imgLine.source = line;
			imgLine.buttonMode = true;
			
			imgLine.addEventListener(MouseEvent.CLICK, lineClickHandler);
			*/
			imgDelete = new Image();
			imgDelete.source = delet; 
			imgDelete.buttonMode = true;
			
			imgDelete.addEventListener(MouseEvent.CLICK, deleteClickHandler);
			
			imgPlus = new Image();
			imgPlus.source = minus;
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
//			cnvUpLayer.addChild(imgLine);
			cnvUpLayer.addChild(imgDelete);
			
			cnvUpLayer.addEventListener(MouseEvent.MOUSE_DOWN, startDragHandler);
//			cnvUpLayer.addEventListener(MouseEvent.MOUSE_UP, stopDragHandler)
			addChild(cnvUpLayer);
			
		}
		
		private var _name:String;
		private var scriptNamesArray:Array = []; /* of advansedLayer*/
		private var objectName:SimpleLayer;
		private function initDownBody(data:Object, containerID:String):void
		{
			cnvDownLayer.setStyle('backgroundColor',"0xffffff" );
			addChild(cnvDownLayer);
			
			var vBox:VBox = new VBox();
				vBox.x = 3;
				vBox.setStyle('verticalGap', 0);
				cnvDownLayer.addChild(vBox);
				
			var leftVRule:VRule =new VRule(); 
				leftVRule.percentHeight = 100;
			cnvDownLayer.addChild(leftVRule);   
			
			var rightVRule:VRule =new VRule();   
	//			rightVRule.x = 100;
				rightVRule.setStyle('right', 0);
				rightVRule.percentHeight = 100;
			cnvDownLayer.addChild(rightVRule);  
			
		/*	 data = "<Event label='' ObjSrcID='' parentType='' />"
			*/
			data = data as XML;
			
			
			var object:XML = dataManager.getObject(data.@ObjTgtID);
			objectName = new SimpleLayer(object.@Name);
			vBox.addChild(objectName);
			
			var type_TEMP:String = dataManager.getTypeByObjectId(data.@ObjTgtID).toXMLString();
			var type:XML = new XML(type_TEMP);
			
			var objectEvent:SimpleLayer = new SimpleLayer(data.@MethodName);
			objectEvent.source = action;
			vBox.addChild(objectEvent);
			
			
			var fileManager:FileManager = FileManager.getInstance();
			var  regResource:RegExp = /^#Res\(([-a-zA-Z0-9]*)\)/;
			var _value:String =  type.Information.StructureIcon;
			var matchResult:Array = _value.match(regResource);
			var resID:String = matchResult[1];
			fileManager.loadResource(dataManager.currentApplicationId,  resID, this);
			
			_name = object.@Name;
			_objTgtID 	= data.@ObjTgtID;
	//		_eventType  = data.@label;
			_methodName = data.@MethodName;
			 					
			var curContainerTypeID:String = dataManager.getTypeByObjectId(dataManager.currentPageId).Information.ID.toString();			 					
			var parametrs:* = type.E2vdom.Actions.Container.(@ID == curContainerTypeID)[0];
			parametrs = parametrs.Action.(@MethodName == data.@MethodName).Parameters[0]; 
			///
			for each(var child:XML in parametrs.children())
			{
				var parametr:AdvansedLayer = new AdvansedLayer(child, type.Information.Name.toString());
				scriptNamesArray[parametr.scriptName + "_"] = parametr;
				vBox.addChild(parametr);
			}
			
		//	vBox.addChild(y);
		//	type = new XML(dataManager.getTypeByObjectId(data.@ObjSrcID).toXMLString());
		}
		
		private function setValue(obj:Object):void
		{
			obj = obj as XML;
			for each(var child:XML in  obj.children())
			{
				if(scriptNamesArray[child.@ScriptName + "_"])
					scriptNamesArray[child.@ScriptName + "_"].value = child;
			}
		}

		private function updateRatio():void
		{	
			imgheader.width = 243 * _ratio;
			imgheader.height = 30 * _ratio;
			
			imgMenu.width = 36 * _ratio;
			imgMenu.height = 14 * _ratio;

			txt.y = 2 * _ratio;
			txt.width =  240 * _ratio;
			
			
			//imgDelete 
			imgDelete.y = -12 * _ratio;
			imgDelete.x = 20 * _ratio;	
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
			
			cnvDownLayer.y = 30 * _ratio;
			cnvDownLayer.width = 243 * _ratio;
			
			isRedraw = true;
		}
		
		public function get ID():String
		{
			return _ID;
		}
		
		
		private var _objTgtID:String;
		
		public function get ObjTgtID():String
		{
			return _objTgtID;
		}
		
	
		private var _methodName:String;
		
		public function get MethodName():String
		{
			return _methodName;
		}
		
		public function get State():String
		{
//			trace('return: '+min.toString());
			return min.toString();
		}
		
		public function get parametrs():XMLList
		{
			var outXMLList:XMLList = new XMLList();
			
			for(var par:String in scriptNamesArray)
			{
				trace(scriptNamesArray[par].xmlData.toXMLString);
				outXMLList += scriptNamesArray[par].xmlData;
			}
			
			return outXMLList;
		}
		
		private var loader:Loader = new Loader();
		public function set resource(data:Object):void
		{
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadComplete);
			
			loader.loadBytes(data.data);
			//image.source = data.data;
		}
		
		
		private function loadComplete(evt:Event):void 
		{
   			loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, loadComplete);		
   			//image.width = loader.width;
   			//image.height = loader.height;
   			objectName.source = loader.content;
   		}
	}
}
