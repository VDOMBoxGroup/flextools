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
	import mx.controls.TextArea;
	import mx.controls.TextInput;
	
	import vdom.containers.ClosablePanel;
	import vdom.controls.resourceBrowser.ResourceBrowserButton;
	import vdom.events.DataManagerEvent;
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
		private var fileManager:FileManager = FileManager.getInstance();
		private var dataManager:DataManager = DataManager.getInstance();
		private var mainVB:VBox;
			
		public function Properties()
		{
			super();
			
			title = "Properties";
			percentWidth = 100;
			setStyle("backgroundColor","0xAAAAAA");
			
			mainVB = new VBox();
				mainVB.setStyle("verticalGap", "2");
				mainVB.percentWidth = 100;
			addChild(mainVB);
			
			generateType();
			generateTitle();
			generateImage();
			generateDisription();
			
			generateControlBar();
			
		}
		
		 
		 
		private var typeLabel:Label = new Label();
		private var typePicture:Image = new Image();
		private function generateType():void
		{
			var type:Canvas = new Canvas();
				type.percentWidth = 100;
			mainVB.addChild(type);
			
			var typeElasticGrey:Image = new Image();
				typeElasticGrey.source = elasticGrey; 
				typeElasticGrey.maintainAspectRatio = false;
				typeElasticGrey.scaleContent = true;
				typeElasticGrey.percentWidth = 100;
				typeElasticGrey.height = elasticHeight;
			type.addChild(typeElasticGrey);
			
			
			var hBox:HBox = new HBox();
				hBox.setStyle("align", "center");
			type.addChild(hBox);
			
			
				typePicture.x = 3;	
				typePicture.source = defaultPicture; 
				typePicture.maintainAspectRatio = false;
				typePicture.scaleContent = true;
				typePicture.width = 20;
				typePicture.height = 20;
			hBox.addChild(typePicture);
			
			
				typeLabel.text = "HTML Container";
				typeLabel.setStyle('fontWeight', "bold"); 
//				typeLabel.setStyle('textAlign', 'center');
				typeLabel.x = 25;
				typeLabel.percentWidth = 100;
			hBox.addChild(typeLabel);
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
				titleElasticGrey.percentWidth = 100;
				titleElasticGrey.height = elasticHeight;
				canvas.addChild(titleElasticGrey);
				
			
			var titleLabel:Label = new Label();
				titleLabel.text = "Title: ";
			canvas.addChild(titleLabel);
			
				__title.text = "Name of Container";
				__title.x = 40;
				__title.percentWidth = 100;
				__title.addEventListener(KeyboardEvent.KEY_UP, testHandler);
			canvas.addChild(__title);
		}
		
		private function testHandler(kEvt:KeyboardEvent):void
		{
			
		}
		
		private var disriptionLabel:Label = new Label();
		private var disriptionTextArea:TextArea = new TextArea();
		private function generateDisription():void
		{
			var disription:Canvas = new Canvas();
				disription.percentWidth = 100;
			mainVB.addChild(disription);
			
			var disriptionElasticGrey:Image = new Image();
				disriptionElasticGrey.source = elasticGrey; 
				disriptionElasticGrey.maintainAspectRatio = false;
				disriptionElasticGrey.scaleContent = true;
				disriptionElasticGrey.percentWidth = 100;
				disriptionElasticGrey.height = elasticHeight;
				disription.addChild(disriptionElasticGrey);

				disriptionLabel.text = "Disription: ";
			disription.addChild(disriptionLabel);
			
			
				disriptionTextArea.percentWidth = 100;
				disriptionTextArea.height = 70;
				disriptionTextArea.y = 20;
			disription.addChild(disriptionTextArea);
		}
		
		private function generateImage():void
		{
			var imageCn:Canvas = new Canvas();
				imageCn.percentWidth = 100;
			mainVB.addChild(imageCn);
			
			var imageElasticGrey:Image = new Image();
				imageElasticGrey.source = elasticGrey; 
				imageElasticGrey.maintainAspectRatio = false;
				imageElasticGrey.scaleContent = true;
				imageElasticGrey.percentWidth = 100;
				imageElasticGrey.y = 1;
				imageElasticGrey.height = elasticHeight;
			imageCn.addChild(imageElasticGrey);
			
			var image:Image = new Image();
				image.x = 3;	
				image.source = defaultPicture; 
				image.maintainAspectRatio = false;
				image.scaleContent = true;
				image.width = 20;
				image.height = 20;
			imageCn.addChild(image);
			
			var rbr:ResourceBrowserButton = new ResourceBrowserButton();
				rbr.x = 40;
				rbr.percentWidth = 100;
			imageCn.addChild(rbr);
			
		}
		private function generateControlBar():void
		{
			var btHeit:int = 16;
			
			var contPan:ControlBar = new ControlBar();
				addChild(contPan);
				
			var btSave:Button = new Button();
				btSave.height = btHeit;
				btSave.setStyle("cornerRadius", "0");
				btSave.label = "Save";
			btSave.addEventListener(MouseEvent.CLICK, saveProperties); 
			contPan.addChild(btSave);
			
			var btSetStart:Button = new Button();
				btSetStart.height = btHeit;
				btSetStart.setStyle("cornerRadius", "0");
				btSetStart.label = "Start";
			contPan.addChild(btSetStart);
			
			var btDelete:Button = new Button();
				btDelete.height = btHeit;
				btDelete.setStyle("cornerRadius", "0");
				btDelete.label = "Delete";
			contPan.addChild(btDelete);
		}
		
		private var treeElement:TreeElement = new TreeElement();
		public function set target (treObj:TreeElement):void
		{
			if( treeElement != null && treObj != null && treeElement.ID != treObj.ID)
			{ 
				treeElement.current = false;
				treeElement = treObj;
				treeElement.current = true;
				
				dataManager.changeCurrentPage(treObj.ID);
				
				__title.text = treeElement.title;
				disriptionTextArea.text = treeElement.description;
				 typeLabel.text = treeElement.type;
				 fileManager.loadResource(dataManager.currentApplicationId,  treeElement.typeID, this, 'typeResourse');
			} 
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
		
		private function saveProperties(msEvt:MouseEvent):void
		{
						
		}
		private function saveChange():void
		{
			dataManager.addEventListener(DataManagerEvent.PAGE_CHANGED, changePagesHandler);
//			dataManager.changeCurrentPage(_ID);
		}
		
		private function changePagesHandler(dmEvt:DataManagerEvent):void
		{
			dataManager.removeEventListener(DataManagerEvent.PAGE_CHANGED, changePagesHandler);
			
			dataManager.addEventListener(DataManagerEvent.OBJECT_CHANGED, changeObjectHandler);
			
//			dataManager.changeCurrentObject(_ID);
		}
		
		private function changeObjectHandler(dmEvt:DataManagerEvent):void
		{
			dataManager.removeEventListener(DataManagerEvent.OBJECT_CHANGED, changeObjectHandler);
			
			dataManager.addEventListener(DataManagerEvent.UPDATE_ATTRIBUTES_COMPLETE, updateAttributeCompleteHandler);
			
			var str:String = 
			 	'<Attributes>' + 
//			 		' <Attribute Name="description">' + textArea.text+'</Attribute>'+
//			 		' <Attribute Name="title">' + txt.text + '</Attribute>' + 
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
//			trace('updateAttributeCompleted')
		}

	}
}