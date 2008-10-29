package vdom.components.treeEditor
{
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.IOErrorEvent;
	import flash.events.KeyboardEvent;
	
	import mx.containers.Canvas;
	import mx.containers.HBox;
	import mx.containers.VBox;
	import mx.controls.Image;
	import mx.controls.Label;
	import mx.controls.TextArea;
	import mx.controls.TextInput;
	
	import vdom.controls.resourceBrowser.ResourceBrowserButton;
	import vdom.managers.DataManager;
	import vdom.managers.FileManager;
	
	public class Properties extends VBox
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
			
		public function Properties()
		{
			super();
			
			percentWidth = 100;
			
			setStyle("verticalGap", "5");
			setStyle("backgroundColor","0xAAAAAA");
			
			generateType();
			generateTitle();
			generateImage();
			generateDisription();
			__title.text = "Name of Container2";
			canvas.addChild(__title);
		}
		
		 
		 
		private var typeLabel:Label = new Label();
		private var typePicture:Image = new Image();
		private function generateType():void
		{
			var type:Canvas = new Canvas();
				type.percentWidth = 100;
			addChild(type);
			
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
		private var canvas:Canvas = new Canvas();
		private function generateTitle():void
		{
			
			addChild(canvas);
			
			var titleElasticGrey:Image = new Image(); 
				titleElasticGrey.source = elasticGrey; 
				titleElasticGrey.maintainAspectRatio = false;
				titleElasticGrey.scaleContent = true;
				titleElasticGrey.y = 1;
				titleElasticGrey.percentWidth = 100;
				titleElasticGrey.height = elasticHeight;
				canvas.addChild(titleElasticGrey);
				canvas.percentWidth = 100;
			
			var titleLabel:Label = new Label();
				titleLabel.text = "Title: ";
			canvas.addChild(titleLabel);
			
				__title.text = "Name of Container";
				__title.x = 40;
				__title.percentWidth = 100;
				__title.addEventListener(KeyboardEvent.KEY_UP, testHandler);
			
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
			addChild(disription);
			
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
			addChild(imageCn);
			
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
		
		private var treeElement:TreeElement;
		public function set target (treObj:TreeElement):void
		{
			this.treeElement = treObj;
			__title.text = treeElement.title;
			disriptionTextArea.text = treeElement.description;
			 typeLabel.text = treeElement.type;
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

	}
}