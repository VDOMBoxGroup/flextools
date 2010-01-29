package net.vdombox.ide.modules.tree.view.components
{
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.IOErrorEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	
	import mx.containers.Canvas;
	import mx.containers.HBox;
	import mx.containers.VBox;
	import mx.controls.Button;
	import mx.controls.Image;
	import mx.controls.Label;
	import mx.controls.TextInput;
	
	import spark.components.Panel;

	public class Propertiesaa extends Panel
	{

		[Embed( source='assets/treeEditor/selected_back_ground.png' )]
		[Bindable]
		public var elasticGrey : Class;

		[Embed( source='assets/treeEditor/treeEditor.swf', symbol='cube' )]
		[Bindable]
		private var defaultPicture : Class;

		private var elasticHeight : int = 21;

		private var elasticWidht : int = 75;

//		private var fileManager : FileManager = FileManager.getInstance();

//		private var dataManager : DataManager = DataManager.getInstance();

		private var mainVB : VBox;

		public function Propertiesaa()
		{
			super();

			title = resourceManager.getString( 'Tree_General', 'properties_panel_title' );

//			setStyle( "backgroundColor", "0xFFFFFF" );
//			setStyle( "borderThicknessLeft", "0" );
//			setStyle( "borderThicknessRight", "0" );


			mainVB = new VBox();
			mainVB.setStyle( "verticalGap", "0" );
			mainVB.setStyle( "borderThickness", "0" );
			mainVB.percentWidth = 100;
			addElement( mainVB );

			generateType();

			generateTitle();

			generateDisription();

			generateImage();

			generateControlBar();

		}

		private var typeLabel : Label = new Label();

		private var typePicture : Image = new Image();

		private function generateType() : void
		{
			var type : Canvas = new Canvas();
			type.setStyle( "backgroundColor", "#7c7c7c" );
			type.percentWidth = 100;
			mainVB.addElement( type );

//			var typeElasticGrey:Image = new Image();
//				typeElasticGrey.source = elasticGrey; 
//				typeElasticGrey.maintainAspectRatio = false;
//				typeElasticGrey.scaleContent = true;
//				typeElasticGrey.percentWidth = 100;
//				typeElasticGrey.height = elasticHeight;



			var hBox : HBox = new HBox();
			hBox.setStyle( "align", "center" );
//			type.addElement(hBox);


			typePicture.x = 3;
			typePicture.source = defaultPicture;
			typePicture.maintainAspectRatio = false;
			typePicture.scaleContent = true;
			typePicture.width = 20;
			typePicture.height = 20;
//			hBox.addElement(typePicture);


			typeLabel.text = "HTML Container";
//				typeLabel.setStyle('fontWeight', "bold");
			typeLabel.setStyle( "color", "#FFFFFF" );
			typeLabel.setStyle( 'textAlign', 'center' );
			typeLabel.setStyle( 'fontSize', "10" );
//				typeLabel.x = 25;
			typeLabel.percentWidth = 100;
			type.addElement( typeLabel );
		}

		private var __title : TextInput = new TextInput();

		private function generateTitle() : void
		{
			var canvas : Canvas = new Canvas();
			canvas.percentWidth = 100;
			mainVB.addElement( canvas );

			var titleElasticGrey : Image = new Image();
			titleElasticGrey.source = elasticGrey;
			titleElasticGrey.maintainAspectRatio = false;
			titleElasticGrey.scaleContent = true;
			titleElasticGrey.y = 1;
			titleElasticGrey.width = elasticWidht;
			titleElasticGrey.height = elasticHeight;
			canvas.addElement( titleElasticGrey );


			var titleLabel : Label = new Label();
			titleLabel.text = resourceManager.getString( 'Tree', 'title' ) + ":";
			titleLabel.width = elasticWidht;
			titleLabel.setStyle( "textAlign", "right" );
			canvas.addElement( titleLabel );

			__title.text = resourceManager.getString( 'Tree', 'name' );
			__title.x = elasticWidht;
			__title.percentWidth = 100;
//				__title.setStyle("textAlign", "right"); 

			__title.addEventListener( KeyboardEvent.KEY_DOWN, testHandler );
			canvas.addElement( __title );
		}

		private function testHandler( kEvt : KeyboardEvent ) : void
		{
			kEvt.stopImmediatePropagation();
		}

		private var disriptionLabel : Label = new Label();

//		private var disriptionTextArea:TextArea = new TextArea();
//		private var multLine : Multiline = new Multiline();

		private function generateDisription() : void
		{
			var disription : Canvas = new Canvas();
			disription.percentWidth = 100;
			mainVB.addElement( disription );

			var disriptionElasticGrey : Image = new Image();
			disriptionElasticGrey.source = elasticGrey;
			disriptionElasticGrey.maintainAspectRatio = false;
			disriptionElasticGrey.scaleContent = true;
			disriptionElasticGrey.width = elasticWidht;
			disriptionElasticGrey.height = elasticHeight;
			disription.addElement( disriptionElasticGrey );

			disriptionLabel.text = resourceManager.getString( 'Tree', 'description' ) + ":";
			disriptionLabel.width = elasticWidht;
			disriptionLabel.setStyle( "textAlign", "right" );
			disription.addElement( disriptionLabel );


//			multLine.percentWidth = 100;
//			multLine.x = elasticWidht;
//			multLine.value = "Deskri";
//			disription.addElement( multLine );

//				disriptionTextArea.percentWidth = 100;
//				disriptionTextArea.height = 70;
//				disriptionTextArea.y = 20;
//			disription.addElement(disriptionTextArea);
		}

//		private var resourseBrowser : ResourceBrowserButton = new ResourceBrowserButton();

		private function generateImage() : void
		{
			var imageCn : Canvas = new Canvas();
			imageCn.percentWidth = 100;
			mainVB.addElement( imageCn );

			var imageElasticGrey : Image = new Image();
			imageElasticGrey.source = elasticGrey;
			imageElasticGrey.maintainAspectRatio = false;
			imageElasticGrey.scaleContent = true;
			imageElasticGrey.width = elasticWidht;
			imageElasticGrey.y = 1;
			imageElasticGrey.height = elasticHeight;
			imageCn.addElement( imageElasticGrey );

//			var image:Image = new Image();
//				image.x = 3;	
//				image.source = defaultPicture; 
//				image.maintainAspectRatio = false;
//				image.scaleContent = true;
//				image.width = 20;
//				image.height = 20;
//			imageCn.addElement(image);

			var label : Label = new Label();
			label.text = resourceManager.getString( 'Tree', 'image' ) + ":";
			label.width = elasticWidht;
			label.setStyle( "textAlign", "right" );
			imageCn.addElement( label );

//			resourseBrowser.x = elasticWidht;
//			resourseBrowser.percentWidth = 100;
//			imageCn.addElement( resourseBrowser );

		}

		private function generateControlBar() : void
		{
			var btHeit : int = 16;
			var btWidht : int = 58;
//			var contPan : ControlBar = new ControlBar();
//				contPan.setStyle("horizontalAlign", "center");
			
//			addElement( contPan );

			
			var ctrlBarContent: Array = [];

			var btSave : Button = new Button();
			btSave.height = btHeit;
			btSave.setStyle( "cornerRadius", "0" );
			btSave.label = "Save";
//				btSave.width = btWidht;
			btSave.addEventListener( MouseEvent.CLICK, saveProperties );
			ctrlBarContent.push( btSave );

//			var vBox : VBox = new VBox();
//			vBox.percentWidth = 100;
//			vBox.setStyle( "horizontalAlign", "center" );
//			ctrlBarContent.push( vBox );

			var btSetStart : Button = new Button();
			btSetStart.height = btHeit;
			btSetStart.setStyle( "cornerRadius", "0" );
			btSetStart.label = resourceManager.getString( 'Tree', 'start' );
//				btSetStart.x = btSave.getStyle("w;
			btSetStart.addEventListener( MouseEvent.CLICK, changeStartPage );
			ctrlBarContent.push( btSetStart );

			var btDelete : Button = new Button();
			btDelete.height = btHeit;
			btDelete.setStyle( "cornerRadius", "0" );
			btDelete.label = resourceManager.getString( 'Tree', 'delete' );
			btDelete.setStyle( "right", "0" );
//				btDelete.width = btWidht;
			btDelete.addEventListener( MouseEvent.CLICK, deleteElement );
			ctrlBarContent.push( btDelete );
			
			controlBarContent = ctrlBarContent;

		}

		private var treeElement : TreeElement = new TreeElement();

		public function set target( treObj : TreeElement ) : void
		{
			if ( !treObj )
				return;


			if ( treeElement )
				treeElement.current = false;

			if ( treeElement.ID != treObj.ID )
			{
//				dataManager.changeCurrentPage( treObj.ID );
			}

			treeElement = treObj;

			treObj.current = true;


//			resourseBrowser.value = "#Res(" + treeElement.resourceID + ")";
//			multLine.value = treeElement.description;
			typeLabel.text = treeElement.type;

			if ( treeElement.title == "" )
			{
				__title.text = treeElement.type;
				saveProperties( new MouseEvent( MouseEvent.CLICK ) );
			}
			else
			{
				__title.text = treeElement.title;
			}
//			fileManager.loadResource( dataManager.currentApplicationId, treeElement.typeID, this, 'typeResourse' );

		}

		private var resourceId : String;

		private var dictionary : Array = new Array(); // of loader

		public function set typeResourse( value : Object ) : void
		{
			var loader : Loader = new Loader();

			resourceId = value.resourceID;

			loader.contentLoaderInfo.addEventListener( Event.COMPLETE, completeHandler, false, 0, true );
			loader.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR, completeHandler );
			loader.loadBytes( value.data );


			if ( dictionary[ value.resourceID ] )
			{

				dictionary[ value.resourceID ].source = loader;
			}
		}

		private function completeHandler( event : Event ) : void
		{

			if ( event.type == IOErrorEvent.IO_ERROR )
				return;
			if ( event && event.target && event.target is LoaderInfo )
			{
				displayLoader( event.target.loader as Loader );
			}
		}

		private function displayLoader( loader : Loader ) : void
		{
			typePicture.source = loader
		}

		public function get target() : TreeElement
		{
			return treeElement;
		}

		private const regResource : RegExp = /^#Res\(([-a-zA-Z0-9]*)\)/;

		private function saveProperties( msEvt : MouseEvent ) : void
		{
//			if ( dataManager.currentPageId != treeElement.ID )
//			{
//				dataManager.addEventListener( DataManagerEvent.PAGE_CHANGED, changePagesHandler );
//				dataManager.changeCurrentPage( treeElement.ID );
//			}
//			else
//			{
//				if ( dataManager.currentObjectId != treeElement.ID )
//				{
//					dataManager.addEventListener( DataManagerEvent.OBJECT_CHANGED, changeObjectHandler );
//					dataManager.changeCurrentObject( treeElement.ID );
//				}
//				else
//				{
//
//					changeAttributes();
//				}
//			}
//
//			if ( resourseBrowser.value == "" )
//			{
//				treeElement.resourceID = "";
//
//				dispatchEvent( new TreeEditorEvent( TreeEditorEvent.SAVE_TO_SERVER ) );
//
//				return;
//			}
//
//			var resID : String = resourseBrowser.value.match( regResource )[ 1 ];
//			if ( treeElement.resourceID != resID )
//			{
//				treeElement.resourceID = resID;
//
//				fileManager.loadResource( dataManager.currentApplicationId, treeElement.resourceID, treeElement );
//
//				dispatchEvent( new TreeEditorEvent( TreeEditorEvent.SAVE_TO_SERVER ) );
//			}
		}


//		private function changePagesHandler( dmEvt : DataManagerEvent ) : void
//		{
//			dataManager.removeEventListener( DataManagerEvent.PAGE_CHANGED, changePagesHandler );
//
//			dataManager.addEventListener( DataManagerEvent.OBJECT_CHANGED, changeObjectHandler );
//			dataManager.changeCurrentObject( treeElement.ID );
//		}

//		private function changeObjectHandler( dmEvt : DataManagerEvent ) : void
//		{
//			dataManager.removeEventListener( DataManagerEvent.OBJECT_CHANGED, changeObjectHandler );
//
//			changeAttributes();
//		}

		private function changeAttributes() : void
		{
//			dataManager.addEventListener( DataManagerEvent.UPDATE_ATTRIBUTES_COMPLETE, updateAttributeCompleteHandler );
//
//			var str : String = '<Attributes>' + ' <Attribute Name="description">' + multLine.value + '</Attribute>' + ' <Attribute Name="title">' + __title.text + '</Attribute>' + ' </Attributes>';
//			var xml : XML = XML( str )
//			dataManager.currentObject.Attributes = xml;
////			trace('2) '+dataManager.currentObject.Attributes);   
//
//			dataManager.updateAttributes();
//			trace('changeAttributes');
		}

//		private function updateAttributeCompleteHandler( dmEvt : DataManagerEvent ) : void
//		{
//			dataManager.removeEventListener( DataManagerEvent.UPDATE_ATTRIBUTES_COMPLETE, updateAttributeCompleteHandler );
//			trace( 'updateAttributeCompleted' );
//			treeElement.description = multLine.value;
//			treeElement.title = __title.text;
//		}

		private function changeStartPage( msEvt : MouseEvent ) : void
		{
//			dispatchEvent( new TreeEditorEvent( TreeEditorEvent.CHANGE_START_PAGE, treeElement.ID ) );
		}

		private function deleteElement( msEvt : MouseEvent ) : void
		{
//			dispatchEvent( new TreeEditorEvent( TreeEditorEvent.DELETE, treeElement.ID ) );
		}

	}
}