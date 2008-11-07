package vdom.components.treeEditor
{
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	
	import mx.containers.HBox;
	import mx.containers.VBox;
	import mx.controls.Image;
	import mx.controls.Label;
	
	import vdom.managers.DataManager;
	import vdom.managers.FileManager;
	

	public class TypeContainerRander extends HBox
	{
		[Embed(source='/assets/treeEditor/treeEditor.swf', symbol='cube')]
					[Bindable]
		private var cube:Class;
				
		private var img:Image = new Image();
		private var _label:Label = new Label();
		private var _description:Label = new Label();		
		public function TypeContainerRander()
		{
			super();
//			var bt:Button = new Button();
//			addChild(bt);
//			setStyle("backgroundColor", "#71FFFF");
//			super.x = true;
			
			
			height = 70;
			setStyle("paddingLeft", "30");
			
//				img.width = 50;
//				img.height = 50;
//				img.source = cube; 
//				img.s
			addChild(img);

			var vBox:VBox = new VBox();
			addChild(vBox);
			
			_label.setStyle('fontWeight', "bold");
			_label.setStyle('fontSize', "14");
			_label.setStyle("color","#636363");
			vBox.addChild(_label);
			
			_description.setStyle("color","#636363")
			vBox.addChild(_description);
			
			addEventListener(Event.ACTIVATE, handler);
						
//			percentWidth = 100;
//			height = 50;
		}
		
		private function handler(evt:Event):void
		{
			trace("     **Handler**");
		}
		
		private var _typeID:String;
		public function set typeID(value:String):void
	    {
	    	_typeID = value;
	    }
		
		public function get typeID():String
	    {
	    	return _typeID;
	    }
	    
	    private var dataManager:DataManager = DataManager.getInstance();
	    private var fileManager:FileManager = FileManager.getInstance();
		override public function set data(value:Object):void
	    {
	    	super.data = value;
	    	if(value)
	    	{
		    	_label.text = value.label;
		    	_description.text = value.description;
		    	fileManager.loadResource(dataManager.currentApplicationId,  value.iconResID, this);
		    }
	    }
	    
	    
	    private var loader:Loader;
		public function set resource(data:Object):void
		{
			loader = new Loader();
			
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadComplete);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, loadError);
			
//			var loaderContextInfo:LoaderContext = new LoaderContext();
//			loaderContextInfo.allowLoadBytesCodeExecution = true;
			
            loader.loadBytes(data.data);
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
   			
   			img.source = loader.content;
   		}
   		
   		public function set select(bool:Boolean):void
   		{
   			trace(bool);
   		}
		/*
		override public function get data(value:Object):Object
	    {
	    	return 
	    	
	    }
	    */
	}
	
	
	
}