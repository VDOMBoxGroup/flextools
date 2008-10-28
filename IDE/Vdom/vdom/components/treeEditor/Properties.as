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
		
		
		
		
		
		public function Properties()
		{
			super();
			
			percentWidth = 100;
			
			setStyle("verticalGap", "1");
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
			
			var hBox:HBox = new HBox();
//				hBox.
			type.addChild(hBox);
			
			var typeElasticGrey:Image = new Image();
				typeElasticGrey.source = elasticGrey; 
				typeElasticGrey.maintainAspectRatio = false;
				typeElasticGrey.scaleContent = true;
				typeElasticGrey.percentWidth = 100;
			type.addChild(typeElasticGrey);
			
			
			
				typeLabel.text = "HTML Container";
				typeLabel.setStyle('fontWeight', "bold"); 
				typeLabel.setStyle('textAlign', 'center');
				typeLabel.x = 25;
				typeLabel.percentWidth = 100;
			type.addChild(typeLabel);
			
			var typePicture:Image = new Image();
				typePicture.x = 3;	
				typePicture.source = defaultPicture; 
				typePicture.maintainAspectRatio = false;
				typePicture.scaleContent = true;
				typePicture.width = 20;
				typePicture.height = 20;
			type.addChild(typePicture);
		}
		
		private var titleTextIput:TextInput = new TextInput();

		private function generateTitle():void
		{
			var title:Canvas = new Canvas();
			addChild(title);
			
			var titleElasticGrey:Image = new Image(); 
				titleElasticGrey.source = elasticGrey; 
				titleElasticGrey.maintainAspectRatio = false;
				titleElasticGrey.scaleContent = true;
				titleElasticGrey.percentWidth = 100;
				title.addChild(titleElasticGrey);
				title.percentWidth = 100;
			
			var titleLabel:Label = new Label();
				titleLabel.text = "Title: ";
			title.addChild(titleLabel);
			
				titleTextIput.text = "Name of Container";
				titleTextIput.x = 40;
				titleTextIput.percentWidth = 100;
			title.addChild(titleTextIput);
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

	}
}