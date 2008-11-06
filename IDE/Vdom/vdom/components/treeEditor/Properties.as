package vdom.components.treeEditor
{
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.IOErrorEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	
	import mx.containers.Canvas;
	import mx.containers.ControlBar;
	import mx.containers.HBox;
	import mx.containers.VBox;
	import mx.controls.Button;
	import mx.controls.Image;
	import mx.controls.Label;
	import mx.controls.TextInput;
	
	import vdom.containers.ClosablePanel;
	import vdom.controls.multiLine.MultiLine;
	import vdom.controls.resourceBrowser.ResourceBrowserButton;
	import vdom.events.DataManagerEvent;
	import vdom.events.TreeEditorEvent;
	import vdom.managers.DataManager;
	import vdom.managers.FileManager;
	
	public class Properties extends ClosablePanel
	{
		[Embed(source='/assets/treeEditor/selected_back_ground.png')]
		[Bindable]
		public var elasticGrey:Class;
		
		[Embed(source='/assets/treeEditor/treeEditor.swf', symbol='cube')]
		[Bindable]
		private var defaultPicture:Class;
		
		private var elasticHeight:int = 21;
		private var elasticWidht:int = 65;
		
		private var fileManager:FileManager = FileManager.getInstance();
		private var dataManager:DataManager = DataManager.getInstance();
		private var mainVB:VBox;
			
		public function Properties()
		{
			super();
			
			title = "            Properties";
			percentWidth = 100;
			
			setStyle("backgroundColor","0xFFFFFF");
			setStyle("borderThicknessLeft", "0");
  			setStyle("borderThicknessRight", "0");

			
			mainVB = new VBox();
				mainVB.setStyle("verticalGap", "0");
				mainVB.setStyle("borderThickness", "0"); 
				mainVB.percentWidth = 100;
			addChild(mainVB);
			
			generateType();
			
			generateTitle();
			
			generateDisription();
			
			generateImage();
			
			generateControlBar();
			
		}
		
		 
		 
		private var typeLabel:Label = new Label();
		private var typePicture:Image = new Image();
		private function generateType():void
		{
			var type:Canvas = new Canvas();
				type.setStyle("backgroundColor","#7c7c7c");
				type.percentWidth = 100;
			mainVB.addChild(type);
			
//			var typeElasticGrey:Image = new Image();
//				typeElasticGrey.source = elasticGrey; 
//				typeElasticGrey.maintainAspectRatio = false;
//				typeElasticGrey.scaleContent = true;
//				typeElasticGrey.percentWidth = 100;
//				typeElasticGrey.height = elasticHeight;

			
			
			var hBox:HBox = new HBox();
				hBox.setStyle("align", "center");
//			type.addChild(hBox);
			
			
				typePicture.x = 3;	
				typePicture.source = defaultPicture; 
				typePicture.maintainAspectRatio = false;
				typePicture.scaleContent = true;
				typePicture.width = 20;
				typePicture.height = 20;
//			hBox.addChild(typePicture);
			
			
				typeLabel.text = "HTML Container";
//				typeLabel.setStyle('fontWeight', "bold");
				typeLabel.setStyle("color", "#FFFFFF");
				typeLabel.setStyle('textAlign', 'center');
				typeLabel.setStyle('fontSize', "10");
//				typeLabel.x = 25;
				typeLabel.percentWidth = 100;
			type.addChild(typeLabel);
		}
		
		private var __title:TextInput = new TextInput();
		private function generateTitle():void
		{
			var canvas:Canvas = new Canvas();
				canvas.percentWidth = 100;
			mainVB.addChild(canvas);
			
			var titleElasticGrey:Image = new Image(); 
				titleElasticGrey.source = elasticGrey; 
				titleElasticGrey.maintainAspectRatio = false;
				titleElasticGrey.scaleContent = true;
				titleElasticGrey.y = 1;
				titleElasticGrey.width= elasticWidht;
				titleElasticGrey.height = elasticHeight;
				canvas.addChild(titleElasticGrey);
				
			
			var titleLabel:Label = new Label();
				titleLabel.text = "Title:";
				titleLabel.width = elasticWidht;
				titleLabel.setStyle("textAlign", "right");
			canvas.addChild(titleLabel);
			
				__title.text = "Name of Container";
				__title.x = elasticWidht;
				__title.percentWidth = 100;
//				__title.setStyle("textAlign", "right"); 

				__title.addEventListener(KeyboardEvent.KEY_DOWN, testHandler);
			canvas.addChild(__title);
		}
		
		private function testHandler(kEvt:KeyboardEvent):void
		{
			kEvt.stopImmediatePropagation();
		}
		
		private var disriptionLabel:Label = new Label();
//		private var disriptionTextArea:TextArea = new TextArea();
		private var multLine:MultiLine = new MultiLine();
		private function generateDisription():void
		{
			var disription:Canvas = new Canvas();
				disription.percentWidth = 100;
			mainVB.addChild(disription);
			
			var disriptionElasticGrey:Image = new Image();
				disriptionElasticGrey.source = elasticGrey; 
				disriptionElasticGrey.maintainAspectRatio = false;
				disriptionElasticGrey.scaleContent = true;
				disriptionElasticGrey.width= elasticWidht;
				disriptionElasticGrey.height = elasticHeight;
				disription.addChild(disriptionElasticGrey);

				disriptionLabel.text = "Disription:";
				disriptionLabel.width = elasticWidht;
				disriptionLabel.setStyle("textAlign", "right");
			disription.addChild(disriptionLabel);

			
				multLine.percentWidth = 100;
				multLine.x = elasticWidht;
				multLine.value = "Deskri";
			disription.addChild(multLine);			
			
//				disriptionTextArea.percentWidth = 100;
//				disriptionTextArea.height = 70;
//				disriptionTextArea.y = 20;
//			disription.addChild(disriptionTextArea);
		}
		
		private var resourseBrowser:ResourceBrowserButton = new ResourceBrowserButton();
		private function generateImage():void
		{
			var imageCn:Canvas = new Canvas();
				imageCn.percentWidth = 100;
			mainVB.addChild(imageCn);
			
			var imageElasticGrey:Image = new Image();
				imageElasticGrey.source = elasticGrey; 
				imageElasticGrey.maintainAspectRatio = false;
				imageElasticGrey.scaleContent = true;
				imageElasticGrey.width= elasticWidht;
				imageElasticGrey.y = 1;
				imageElasticGrey.height = elasticHeight;
			imageCn.addChild(imageElasticGrey);
			
//			var image:Image = new Image();
//				image.x = 3;	
//				image.source = defaultPicture; 
//				image.maintainAspectRatio = false;
//				image.scaleContent = true;
//				image.width = 20;
//				image.height = 20;
//			imageCn.addChild(image);
			
			var label:Label = new Label();
				label.text = "Image:";
				label.width = elasticWidht;
				label.setStyle("textAlign", "right");
			imageCn.addChild(label);
			
				resourseBrowser.x = elasticWidht;
				resourseBrowser.percentWidth = 100;
			imageCn.addChild(resourseBrowser);
			
		}
		private function generateControlBar():void
		{
			var btHeit:int = 16;
			var btWidht:int = 58;
			var canv:Canvas = new Canvas();
				canv.percentWidth = 100;
			addChild(canv);
			
			var contPan:ControlBar = new ControlBar();
//				contPan.setStyle("horizontalAlign", "center");
				canv.addChild(contPan);
				
				
			var btSave:Button = new Button();
				btSave.height = btHeit;
				btSave.setStyle("cornerRadius", "0");
				btSave.label = "Save";
//				btSave.width = btWidht;
			btSave.addEventListener(MouseEvent.CLICK, saveProperties); 
			contPan.addChild(btSave);
			
			var btSetStart:Button = new Button();
				btSetStart.height = btHeit;
				btSetStart.setStyle("cornerRadius", "0");
				btSetStart.label = "Start";
//				btSetStart.x = btSave.getStyle("w;
				btSetStart.addEventListener(MouseEvent.CLICK, changeStartPage); 
			contPan.addChild(btSetStart);
			
			var btDelete:Button = new Button();
				btDelete.height = btHeit;
				btDelete.setStyle("cornerRadius", "0");
				btDelete.label = "Delete";
				btDelete.setStyle("right", "0");
//				btDelete.width = btWidht;
				btDelete.addEventListener(MouseEvent.CLICK, deleteElement); 
			canv.addChild(btDelete);
			
		}
		
		private var treeElement:TreeElement = new TreeElement();
		public function set target (treObj:TreeElement):void
		{
			if (!treObj)
				return;
				
			treObj.current = true;
			
			if (treeElement)
				treeElement.current = false;
				
			if(treeElement.ID != treObj.ID)
			{ 
				treeElement = treObj;
				dataManager.changeCurrentPage(treObj.ID);
			}

			resourseBrowser.value =  "#Res(" + treeElement.resourceID + ")"; 
			multLine.value = treeElement.description;
			typeLabel.text = treeElement.type;
			 
			if(treeElement.title == "")
			{
				__title.text = treeElement.type;
				saveProperties(new MouseEvent(MouseEvent.CLICK));
			}else
			{
				__title.text = treeElement.title;
			}
			 fileManager.loadResource(dataManager.currentApplicationId,  treeElement.typeID, this, 'typeResourse');
			 
		}
		
		private var resourceId:String;
		private var dictionary:Array = new Array(); // of loader
		public function set typeResourse(value:Object):void
		{
			var loader:Loader = new Loader();
			
			resourceId = value.resourceID;
			
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, completeHandler, false, 0, true);
			loader.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR, completeHandler );
			loader.loadBytes(value.data);
			
			
			if(dictionary[value.resourceID]) {
				
				dictionary[value.resourceID].source = loader;
			}
		}
		
		private function completeHandler(event:Event):void {
			
			if(event.type == IOErrorEvent.IO_ERROR)
				return;
			if(event && event.target && event.target is LoaderInfo) {
				displayLoader(event.target.loader as Loader);
			}
		}
		
		private function displayLoader( loader:Loader ):void
		 {
			typePicture.source = loader
		}

		public function get target ():TreeElement
		{
			return treeElement;
		}
		
		private const regResource:RegExp = /^#Res\(([-a-zA-Z0-9]*)\)/;
		private function saveProperties(msEvt:MouseEvent):void
		{
			if(dataManager.currentPageId != treeElement.ID )
			{
				dataManager.addEventListener(DataManagerEvent.PAGE_CHANGED, changePagesHandler);
				dataManager.changeCurrentPage(treeElement.ID);	
			}else
			{
				if(dataManager.currentObjectId != treeElement.ID)
				{
					dataManager.addEventListener(DataManagerEvent.OBJECT_CHANGED, changeObjectHandler);
					dataManager.changeCurrentObject(treeElement.ID);
				}else
				{
					
					changeAttributes();
				}
			}
			
			if(resourseBrowser.value == "")
			{
				treeElement.resourceID = "";
				
				dispatchEvent(new TreeEditorEvent(TreeEditorEvent.SAVE_TO_SERVER));
				
				return;
			}			
				
			var resID:String = resourseBrowser.value.match(regResource)[1];
			if(treeElement.resourceID != resID)
			{
				treeElement.resourceID = resID;
				
				fileManager.loadResource(dataManager.currentApplicationId, treeElement.resourceID, treeElement);
					
				dispatchEvent(new TreeEditorEvent(TreeEditorEvent.SAVE_TO_SERVER));
			}
		}
		
		
		private function changePagesHandler(dmEvt:DataManagerEvent):void
		{
			dataManager.removeEventListener(DataManagerEvent.PAGE_CHANGED, changePagesHandler);
			
			dataManager.addEventListener(DataManagerEvent.OBJECT_CHANGED, changeObjectHandler);
			dataManager.changeCurrentObject(treeElement.ID);
		}
		
		private function changeObjectHandler(dmEvt:DataManagerEvent):void
		{
			dataManager.removeEventListener(DataManagerEvent.OBJECT_CHANGED, changeObjectHandler);
			
			changeAttributes();
		}
		
		private function changeAttributes():void
		{
			dataManager.addEventListener(DataManagerEvent.UPDATE_ATTRIBUTES_COMPLETE, updateAttributeCompleteHandler);
			
			var str:String = 
			 	'<Attributes>' + 
			 		' <Attribute Name="description">' + multLine.value +'</Attribute>'+
			 		' <Attribute Name="title">' + __title.text + '</Attribute>' + 
			 	' </Attributes>';
			var xml:XML = XML(str)	
			dataManager.currentObject.Attributes = xml;
//			trace('2) '+dataManager.currentObject.Attributes);   
			
			dataManager.updateAttributes();
//			trace('changeAttributes');
		}
		
		private function updateAttributeCompleteHandler(dmEvt:DataManagerEvent):void
		{
			dataManager.removeEventListener(DataManagerEvent.UPDATE_ATTRIBUTES_COMPLETE, updateAttributeCompleteHandler);
			trace('updateAttributeCompleted');
			treeElement.description = multLine.value;
			treeElement.title = __title.text;
		}
		
		private function changeStartPage(msEvt:MouseEvent):void
		{
			dispatchEvent(new TreeEditorEvent(TreeEditorEvent.CHANGE_START_PAGE, treeElement.ID));
		}
		
		private function deleteElement(msEvt:MouseEvent):void
		{
			dispatchEvent(new TreeEditorEvent(TreeEditorEvent.DELETE, treeElement.ID));	
		}

	}
}