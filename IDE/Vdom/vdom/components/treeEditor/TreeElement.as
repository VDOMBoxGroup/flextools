package vdom.components.treeEditor
{
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.FileFilter;
	import flash.utils.ByteArray;
	
	import mx.containers.Canvas;
	import mx.controls.Button;
	import mx.controls.Image;
	import mx.controls.Label;
	import mx.controls.TextArea;
	import mx.controls.TextInput;
	import mx.core.Application;
	import mx.utils.Base64Encoder;
	
	import vdom.connection.Proxy;
	import vdom.connection.soap.Soap;
	import vdom.connection.soap.SoapEvent;
	import vdom.events.TreeEditorEvent;
	
	public class TreeElement extends Canvas
	{
		private var btLine:Button;
		private var btDelete:Button;
		private var btLessen:Button; 
		private var txt:Label;
		private var textArea:TextArea;
		public var _ID:String;
//		private var rect:Canvas = new Canvas();
		private var min:Boolean = false;
		public var drag:Boolean = true;
		private var image:Image;
		private var imgBackGround:Image;
		private var imgPlus:Image;
		private var imgheader:Image;
		private var cnvUpLayer	:Canvas = new Canvas();
		private var cnvDownLayer:Canvas = new Canvas();		
		private var txtInp:TextInput;
		private var _type:Label;
		private var publicData:Object = Application.application.publicData;
		private var soap:Soap = Soap.getInstance();
		
		
		private  var _resourceID:String = '';
		
		[Embed(source='/assets/treeEditor/treeEditor.swf', symbol='defaultPicture')]
		[Bindable]
		public var defaultPicture:Class;
		
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
		
		
		
		public function TreeElement()
		{
			super();

			initUpBody();
			initDownBody(); 
			
			isRedraw = true;
			this.buttonMode = true;
			addEventListener(MouseEvent.CLICK, endFormatinfHandler)
		}
		
		
		private function initUpBody():void
		{
			imgheader = new Image();
			imgheader.source = header;
			
			txt = new Label();
			txt.setStyle('color', '#ffffff');
			txt.setStyle('fontWeight', "bold"); 
			txt.setStyle('textAlign', 'center');
			
			txt.y = 20;
			txt.width =  240;
			txt.buttonMode = true;
			txt.doubleClickEnabled = true;
			txt.addEventListener(MouseEvent.DOUBLE_CLICK, txtDoubleClickHandler)
			
			var imgLine:Image = new Image();
			imgLine.source = line;
			imgLine.y = 2;
			imgLine.x = 20;	
			imgLine.addEventListener(MouseEvent.CLICK, lineClickHandler);
			
			var imgDelete:Image = new Image();
			imgDelete.source = delet;
			imgDelete.y = 2;
			imgDelete.x = 40;	
			imgDelete.addEventListener(MouseEvent.CLICK, deleteClickHandler);
			
			imgPlus = new Image();
			imgPlus.source = plus;
			imgPlus.y = 2;
			imgPlus.x = 4;	
			imgPlus.addEventListener(MouseEvent.CLICK, plusClickHandler);	
			
			txtInp = new TextInput();
			txtInp.setStyle('borderColor', '#000000');
			txtInp.setStyle('fontWeight', "bold"); 
			txtInp.setStyle('textAlign', 'center');
			txtInp.y = 20;
			txtInp.width =  240;
			txtInp.visible = false;
			
			cnvUpLayer.addChild(imgheader);
			cnvUpLayer.addChild(txt);
			cnvUpLayer.addChild(imgPlus);
			cnvUpLayer.addChild(txtInp);
			cnvUpLayer.addChild(imgLine);
			cnvUpLayer.addChild(imgDelete);
			
			addChild(cnvUpLayer);
			
		}
		
		private function initDownBody():void
		{
			imgBackGround = new Image();
			imgBackGround.source = backGround;
			imgBackGround.y = 27;
			cnvDownLayer.addChild(imgBackGround);
			
			textArea = new TextArea();
			textArea.setStyle('fontWeight', "bold"); 
			textArea.x = 115; // btButton.width;
			textArea.y = 35  //txt.height;
			textArea.editable = false;
			textArea.focusEnabled = true;
			textArea.text = 'press double click for edit this text';
			textArea.width =  125;
			textArea.height = 75;
			textArea.doubleClickEnabled = true;
			textArea.addEventListener(MouseEvent.DOUBLE_CLICK, textAreaDoubleClickHandler);
			cnvDownLayer.addChild(textArea);
			
			image = new Image();
			image.source = defaultPicture;
			image.x = 10;
			image.y = 35;
			image.maintainAspectRatio = true;
			image.scaleContent = true;
			image.height = 100;
			image.width = 95;
			image.doubleClickEnabled = true;
			image.addEventListener(MouseEvent.DOUBLE_CLICK, imageDoubleClickHandler);
			cnvDownLayer.addChild(image);
			
			
			
			cnvDownLayer.y = 15;
			
			
			_type = new Label();
			_type.text = 'text  ';
			_type.y = 120;
			_type.x = 120;
			_type.width =  100;
			_type.setStyle('fontSize', "8");
			_type.setStyle('fontWeight', "bold"); 
			cnvDownLayer.addChild(_type);
			
			
		}
		
		private var isRedraw:Boolean;
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
			
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			if (isRedraw) {
				dispatchEvent(new TreeEditorEvent(TreeEditorEvent.REDRAW, _ID));
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
			//safeChange();
			
			if(txtInp.visible)
			{
				txtInp.removeEventListener(MouseEvent.CLICK, txtInpClickHandler);
				
				txt.text = txtInp.text;
				txtInp.visible = false;
				safeChange();
			//	trace('1')
			}
			
			if(textArea.editable  )
			{
				textArea.removeEventListener(MouseEvent.CLICK, textAreaClickHandler);
				textArea.editable = false;
				textArea.selectable = false;
				textArea.setStyle('fontWeight', "bold");
				safeChange();
			//	trace('2');	
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
		
		private var source:File;
		private function imageDoubleClickHandler(msEvt:MouseEvent):void
		{
			if (source == null) { source = new File(); }
				source.addEventListener(Event.SELECT, sourceSelectHandler);
				source.browseForOpen("Choose file to compress", [ new FileFilter("Images", "*.jpg;*.jpeg;*.gif;*.png")]);
		}
		
		
		private function sourceSelectHandler(event:Event):void
		{
			if (source != null && !source.isDirectory )
			{
				var srcBytes:ByteArray   = new ByteArray();
				var srcStream:FileStream = new FileStream();
				
				srcStream.open(source, FileMode.READ);
				srcStream.readBytes(srcBytes, 0, srcStream.bytesAvailable);
				srcStream.close();

				image.source = srcBytes;
				var byArr:ByteArray = new ByteArray();
				byArr.writeBytes(srcBytes);
				byArr.compress();

				var bs64Encdr:Base64Encoder = new Base64Encoder();
				bs64Encdr.encodeBytes(byArr);
			//	trace(bs64Encdr.toString());
				//послать
			//	source.type; //.png
			//	source.name; //name.png
				setResource(source.type, source.name, bs64Encdr.toString());
			}
		}

		public function set sourseImg(obj:Object):void
		{
			image.source = obj;
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
	
		
		override public function set name(names:String):void
		{
			txt.text = names;
		//	ID = names;
		}
		
		/****      ID         ****/
		
		public function set ID(names:String):void
		{
			//txt.text = names;
			_ID = names;
		}
		
		public function get ID():String
		{
			//txt.text = names;
			return _ID;
		}
		
		private function set current(data:Boolean):void
		{
		/*	if (data)
				drawRect();
			else 
				rect.graphics.clear();*/
		}

		
		/****      resourceID         ****/
		
		public function set resourceID(names:String):void
		{
			//txt.text = names;
			_resourceID = names;
		}
		
		public function get resourceID():String
		{
			//txt.text = names;
			trace(name +" : "+_resourceID);
			return  _resourceID;
		}
		
		
		/****      state         ****/
		
		public function set state(names:String):void
		{
			//txt.text = names;
		//	trace('names: ' +names);
			if(names == 'true')	changeState(true)
				else changeState(false);
		}
		
		public function get state():String
		{
			//txt.text = names;
			//return '++++';
		//	trace(contains(cnvDownLayer) + ' ! '+min.toString())
			return  min.toString();
		}
		
		/*
		
		private function dispStartDrag(evt:MouseEvent):void
		{
			dispatchEvent(new TreeEditorEvent(TreeEditorEvent.START_DRAG, _ID));
		}
		 
		 */
		 /****      description         ****/
		 
		 public function set description(names:String):void
		{
			textArea.text = names;
		}
		
		public function get description():String
		{
			return  textArea.text;
		}
		
		
		
		/****      type         ****/
		
		 public function set type(names:String):void
		{
			_type.text = names;
		}
		
		public function get type():String
		{
			return  _type.text;
		}
		private function safeChange():void
		{
			/***  
			 * 
			 * надо будет через дата мэнаджер переделать
			 * 
			 * */
			 var str:String = 
			 	'<Attributes>' + 
			 		' <Attribute Name="description">' + textArea.text+'</Attribute>'+
			 		' <Attribute Name="title">' + txt.text + '</Attribute>' + 
			 	' </Attributes>'
			 var xmlToSend:XML = XML(str);
			
		//	 trace(xmlToSend.toString());
			
			var proxy:Proxy = Proxy.getInstance();
			proxy.setAttributes( publicData.applicationId, _ID,xmlToSend); 
		}
		
		public function get select():Boolean
		{
			return txtInp.visible || textArea.editable;
		} 
		
		public function unSelect():void
		{
			endFormatinfHandler(new MouseEvent(MouseEvent.CLICK));
			//trace('el: '+name);
			//trace(': ' + dataManager.objectDescription);
		}
		/* 
		private function draawRect():void
		{
		//	rect.graphics.lineStyle(1, 1, 1, false, LineScaleMode.NONE, CapsStyle.SQUARE, JointStyle.MITER);
		//	rect.graphics.drawRect(0, 0, this.width, this.height);
		}
		*/
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
	 	trace(restype+' : '+resname+' : '+resdata);
	 	
	 
	 	soap.setResource(publicData.applicationId,	_resourceID, 
	 												restype, 
	 												resname, 
	 												resdata );
		soap.addEventListener(SoapEvent.SET_RESOURCE_OK, setResourceOkHandler);
	 	soap.addEventListener(SoapEvent.SET_RESOURCE_ERROR, setResourceErrorHandler);
	 	
	 }
	
	 private function setResourceOkHandler(spEvt:SoapEvent):void
	 {
	 	
	 	var rez:XML = spEvt.result;
	 	
	 	
	 	_resourceID = rez.Resource.@id;
	 	trace('setResourceOkHandler: ' + _resourceID);
	 	soap.removeEventListener(SoapEvent.SET_RESOURCE_OK, setResourceOkHandler);
	 	soap.removeEventListener(SoapEvent.SET_RESOURCE_ERROR, setResourceErrorHandler);
	 }
	 
	 private function setResourceErrorHandler(spEvt:SoapEvent):void
	 {
	 	trace('setResourceErrorHandler: ' + spEvt);
	 	image.source = defaultPicture;
	 	
	 	soap.removeEventListener(SoapEvent.SET_RESOURCE_OK, setResourceOkHandler);
	 	soap.removeEventListener(SoapEvent.SET_RESOURCE_ERROR, setResourceErrorHandler);
	 }
	 
	}
}