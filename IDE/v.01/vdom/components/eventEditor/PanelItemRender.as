package vdom.components.eventEditor
{
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;

	import mx.containers.HBox;
	import mx.controls.Image;
	import mx.controls.Label;

	import vdom.managers.DataManager;
	import vdom.managers.FileManager;

	public class PanelItemRender extends HBox
	{
		private var _icon : Image = new Image();
		private var _label : Label = new Label();

		[ Embed( source='/assets/scriptEditor/vbscript.png' ) ]
		[ Bindable ]
		public var vscript : Class;

		public function PanelItemRender()
		{
			super();
//			super.width = 200;	
//			super.data
//			setStyle("horizontalScrollPolicy", "off");
			_icon.source = vscript;
			addChild( _icon );
//			_label.setStyle("horizontalScrollPolicy", "off");
//			_label.width = parent.width;
			addChild( _label );
		}

		override public function set data( value : Object ) : void
		{
			_label.width = parent.width - 50;

			_label.text = value.label;

			fileManager.loadResource( dataManager.currentApplicationId, value.iconResID,
									  this, "resourceImg" );
			super.data = value;

		}

		private var fileManager : FileManager = FileManager.getInstance();
		private var dataManager : DataManager = DataManager.getInstance();

		public function set resource( data : Object ) : void
		{
//			_label.text = data.label;

			super.data = data;
		}

		private var loader : Loader;

		public function set resourceImg( data : Object ) : void
		{
			if ( data && data.data == null )
				return ;

			loader = new Loader();

			loader.contentLoaderInfo.addEventListener( Event.COMPLETE, loadComplete );
			loader.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR, loadError );

//			var loaderContextInfo:LoaderContext = new LoaderContext();
//			loaderContextInfo.allowLoadBytesCodeExecution = true;

			try
			{
				loader.loadBytes( data.data );
			}
			catch ( error : Error )
			{
			}
		}

		private function loadError( evt : IOErrorEvent ) : void
		{

			loader.contentLoaderInfo.removeEventListener( Event.COMPLETE, loadComplete );
			loader.contentLoaderInfo.removeEventListener( IOErrorEvent.IO_ERROR,
														  loadError );

//			image.source = defaultPicture;
		}

		private function loadComplete( evt : Event ) : void
		{
			loader.contentLoaderInfo.removeEventListener( Event.COMPLETE, loadComplete );
			loader.contentLoaderInfo.removeEventListener( IOErrorEvent.IO_ERROR,
														  loadError );

			_icon.source = loader.content;
			if ( loader.width > 20 )
			{
				_icon.width = 18;
				_icon.height = 18;
			}
		}
	}
}