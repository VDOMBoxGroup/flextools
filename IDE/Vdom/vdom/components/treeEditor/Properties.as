package vdom.components.treeEditor
{
	import mx.containers.Canvas;
	import mx.containers.HBox;
	import mx.containers.VBox;
	import mx.controls.Image;
	import mx.controls.Label;
	import mx.controls.TextArea;
	import mx.controls.TextInput;
	
	import vdom.controls.resourceBrowser.ResourceBrowserButton;
	
	public class Properties extends VBox
	{
		[Embed(source='/assets/treeEditor/selected_back_ground.png')]
		[Bindable]
		public var elasticGrey:Class;
		
		[Embed(source='/assets/treeEditor/treeEditor.swf', symbol='cube')]
		[Bindable]
		private var defaultPicture:Class;
		
		private var elasticHeight:int = 21;
			
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
		}
		
		 
		 
		private var typeLabel:Label = new Label();
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
			
			var typePicture:Image = new Image();
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
		
		private var title:TextInput = new TextInput();

		private function generateTitle():void
		{
			var canvas:Canvas = new Canvas();
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
			
				title.text = "Name of Container";
				title.x = 40;
				title.percentWidth = 100;
			canvas.addChild(title);
		}
		
		
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

			var disriptionLabel:Label = new Label();
				disriptionLabel.text = "Disription: ";
			disription.addChild(disriptionLabel);
			
			var disriptionTextArea:TextArea = new TextArea();
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
			treeElement = treObj;
			title.text = treeElement.title
			title.validateNow();
		}
		
		
		public function get target ():TreeElement
		{
			return treeElement;
		}

	}
}