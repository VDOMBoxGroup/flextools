package net.vdombox.ide.modules.wysiwyg.view.components.windows
{
	import flash.display.Loader;
	import flash.events.Event;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	
	import mx.binding.utils.BindingUtils;
	import mx.events.FlexEvent;
	import mx.managers.PopUpManager;
	
	import net.vdombox.ide.common.interfaces.IExternalManager;
	import net.vdombox.ide.common.vo.ResourceVO;
	import net.vdombox.ide.modules.wysiwyg.events.ExternalEditorWindowEvent;
	import net.vdombox.ide.modules.wysiwyg.view.skins.ExternalEditorWindowSkin;
	
	import spark.components.Window;
	import spark.core.SpriteVisualElement;

	public class ExternalEditorWindow extends Window
	{
		[Bindable]
		private var _resourceVO : ResourceVO;
		private var _applicationID : String;
		private var _objectID : String;
		
		private var _value : String;
		private var loader : Loader;
		private var _externalManager : IExternalManager;
		private var externalEditor : Object;
		
		[SkinPart( required="true" )]
		public var placer : SpriteVisualElement;
		
		public function ExternalEditorWindow()
		{
			super();
			
			width = 640;
			height = 480;
			
			addHandlers();
			
		}
		
		override public function stylesInitialized():void {
			super.stylesInitialized();
			this.setStyle( "skinClass", ExternalEditorWindowSkin );
		}
		
		private function addHandlers() : void
		{
			addEventListener( FlexEvent.CREATION_COMPLETE, creationCompleteHandler );
			addEventListener( Event.CLOSE, closeWindowHandler );
		}
		
		private function closeWindowHandler( event : Event ) : void
		{
			dispatchEvent( new ExternalEditorWindowEvent( ExternalEditorWindowEvent.CLOSE ));
		}
		
		public function get value() : String
		{
			return externalEditor ?  externalEditor[ "value" ] : "";
		}
		
		public function set value( value : String ) : void
		{
			_value = value;
		}
		
		public function set externalManager( value : IExternalManager ) : void
		{
			_externalManager = value;
		}
		
		public function set resourceVO( value : ResourceVO ) : void
		{
			_resourceVO = value;
		}
		
		public function set applicationID( value : String ) : void
		{
			_applicationID = value;
		}
		
		public function set objectID( value : String ) : void
		{
			_objectID = value;
		}
		
		override protected function measure() : void
		{
			super.measure();
		}
		
		private function creationCompleteHandler(event : Event ) : void
		{
			removeEventListener( FlexEvent.CREATION_COMPLETE, creationCompleteHandler );
			if ( !_resourceVO.data || _resourceVO.data.length == 0 )
				BindingUtils.bindSetter( addExternalEditor, _resourceVO, "data", false, true  );
			else
				addExternalEditor();
			
		}
		
		private function addExternalEditor( object : Object = null ) : void
		{
			if ( !_resourceVO.data )
				return;
			
			if ( !loader )
				loader = new Loader();
			
			loader.contentLoaderInfo.addEventListener( Event.COMPLETE, loader_completeHandler );
			
			var loaderContext : LoaderContext = new LoaderContext();
			loaderContext.applicationDomain = new ApplicationDomain();
			loaderContext["allowLoadBytesCodeExecution"] = true;
			
			loader.loadBytes( _resourceVO.data, loaderContext );
		}
		
		private function loader_completeHandler( event : Event ) : void
		{
			loader.removeEventListener( Event.COMPLETE, loader_completeHandler );
			
			event.currentTarget.content.addEventListener( FlexEvent.APPLICATION_COMPLETE, applicationCompleteHandler );
			
			placer.addChild( loader.content );
		}
		
		private function applicationCompleteHandler( event : Event ) : void
		{
			var d : * = "";
			
			placer.width = Object( loader.content ).application.width;
			placer.height = Object( loader.content ).application.height;
			
			//PopUpManager.centerPopUp( this );
			
			externalEditor = event.target.application;
			//					externalEditor.addEventListener( CloseEvent.CLOSE, externalEditor_closeHandler );
			externalEditor[ "externalManager" ] = _externalManager;
			externalEditor[ "value" ] = _value;
			//					try
			//					{
			//						externalEditor[ "externalManager" ] = _externalManager;
			//						externalEditor[ "value" ] = _value;
			//					}
			//					catch ( err : Error )
			//					{
			//////						/* error002 */
			//////						Alert.show( "External editor returned an error. Could not execute a command.",
			//////							"External Editor Error! (002)" );
			//					}
		}
		
		//			private function externalEditor_closeHandler(event:Event):void
		//			{
		//				
		//			}
	}
}