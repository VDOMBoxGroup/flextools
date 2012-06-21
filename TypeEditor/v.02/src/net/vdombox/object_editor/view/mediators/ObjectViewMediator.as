/*
	Class ObjectViewMediator add tabs: Informarion, Events, etc; 
							 add mediators for tabs. 
	Wrapper over the ObjectView.mxml.
*/
package net.vdombox.object_editor.view.mediators
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.SecurityErrorEvent;
	import flash.filesystem.File;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.utils.ByteArray;
	
	import mx.controls.Alert;
	import mx.events.CloseEvent;
	import mx.managers.PopUpManager;
	import mx.utils.Base64Encoder;
	import mx.utils.ObjectProxy;
	
	import net.vdombox.object_editor.event.PopupEvent;
	import net.vdombox.object_editor.model.Item;
	import net.vdombox.object_editor.model.POSTUploadBuilder;
	import net.vdombox.object_editor.model.proxy.ConnectToServerProxy;
	import net.vdombox.object_editor.model.proxy.FileProxy;
	import net.vdombox.object_editor.model.proxy.ObjectsProxy;
	import net.vdombox.object_editor.model.proxy.componentsProxy.ObjectTypeProxy;
	import net.vdombox.object_editor.model.vo.ConnectInfoVO;
	import net.vdombox.object_editor.model.vo.ObjectTypeVO;
	import net.vdombox.object_editor.view.ObjectView;
	import net.vdombox.object_editor.view.ObjectsAccordion;
	import net.vdombox.object_editor.view.essence.Actions;
	import net.vdombox.object_editor.view.essence.Attributes;
	import net.vdombox.object_editor.view.essence.Events;
	import net.vdombox.object_editor.view.essence.Information;
	import net.vdombox.object_editor.view.essence.Languages;
	import net.vdombox.object_editor.view.essence.Libraries;
	import net.vdombox.object_editor.view.essence.Resourses;
	import net.vdombox.object_editor.view.essence.SourceCode;
	import net.vdombox.object_editor.view.popups.ConnectToServerWindow;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;

	public class ObjectViewMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "ObjectViewMediator";

		public static const OBJECT_TYPE_CHAGED:			String = "objectTypeChanged";
		public static const OBJECT_TYPE_VIEW_REMOVED:	String = "objectTypeViewRemoved";
		public static const OBJECT_TYPE_VIEW_SAVED:		String = "objectTypeViewSaved";
		public static const CLOSE_OBJECT_TYPE_VIEW:		String = "closeObjectTypeView";

		private var objectTypeVO:ObjectTypeVO;
		private var _changed : Boolean = false;
		private var connectToServerProxy : ConnectToServerProxy;

		public function ObjectViewMediator( viewComponent:Object, objTypeVO:ObjectTypeVO ) 
		{	
			super( NAME+objTypeVO.id, viewComponent );		
			this.objectTypeVO = objTypeVO;

			// for selected necessary tab
			view.name = objTypeVO.filePath;

			var actions:Actions  		= new Actions();
			var atributes:Attributes  	= new Attributes();
			var event:Events  			= new Events;
			var information:Information = new Information();
			var languages:Languages  	= new Languages();
			var libraries:Libraries  	= new Libraries();
			var resourses:Resourses  	= new Resourses();
			var sourceCode:SourceCode	= new SourceCode();


			view.tabNavigator.addChild(information);
			view.tabNavigator.addChild(atributes);
			view.tabNavigator.addChild(languages);
			view.tabNavigator.addChild(resourses);
			view.tabNavigator.addChild(sourceCode);
			view.tabNavigator.addChild(actions);
			view.tabNavigator.addChild(event);
			view.tabNavigator.addChild(libraries);


			facade.registerMediator( new InformationMediator( information, objTypeVO ) );
			facade.registerMediator( new ActionMediator  	( actions,	   objTypeVO ) );
			facade.registerMediator( new AttributeMediator  ( atributes,   objTypeVO ) );
			facade.registerMediator( new EventMediator   	( event,	   objTypeVO ) );
			facade.registerMediator( new LanguagesMediator 	( languages,   objTypeVO ) );
			facade.registerMediator( new LibrariesMediator 	( libraries,   objTypeVO ) );
			facade.registerMediator( new SourceCodeMediatior( sourceCode,  objTypeVO ) );
			facade.registerMediator( new ResourcesMediator 	( resourses,   objTypeVO ) );

			view.saveObjectTypeButton.addEventListener  ( MouseEvent.CLICK, saveObjectType );
			view.saveAsObjectTypeButton.addEventListener( MouseEvent.CLICK, saveAsObjectType );
			view.connectObjectTypeToServerButton.addEventListener( MouseEvent.CLICK, connectToServer );
			view.loadObjectTypeToServerButton.addEventListener( MouseEvent.CLICK, loadObjectType );
			view.restartButton.addEventListener			( MouseEvent.CLICK, restartObjectType );

			view.validateNow();
			view.addEventListener(OBJECT_TYPE_VIEW_REMOVED, objectTypeViewRemoved);
		}
		
		override public function onRegister() : void
		{
			connectToServerProxy = facade.retrieveProxy( ConnectToServerProxy.NAME ) as ConnectToServerProxy;
		}

		private function saveObjectType(event:MouseEvent):void
		{
			facade.sendNotification( ApplicationFacade.SAVE_OBJECT_TYPE, objectTypeVO );
		}

		private function saveAsObjectType(event:MouseEvent):void
		{
			facade.sendNotification( ApplicationFacade.SAVE_AS_OBJECT_TYPE, objectTypeVO );
		}
		
		private function connectToServer( event : MouseEvent ) : void
		{
			var connectInformation : ConnectInfoVO = connectToServerProxy.connectInformation;
			
			var popup:ConnectToServerWindow = new ConnectToServerWindow;
			popup.InitializeValue( connectInformation );
			popup.addEventListener(PopupEvent.APPLY, applyHandler);
			
			PopUpManager.addPopUp(popup, view, true);
			PopUpManager.centerPopUp( popup );
			
			function applyHandler(event:PopupEvent):void
			{
				var connectInformation : ConnectInfoVO = popup.connectInformation;
				
				connectToServerProxy.connectInformation = connectInformation;
				
				sendNotification( ApplicationFacade.CONNECT_TO_SERVER, connectInformation );
			}
		}
		
		private function loadObjectType( event : MouseEvent ) : void
		{
			
			sendNotification( ApplicationFacade.UPLOAD_TYPE_TO_SERVER, objectTypeVO );
		}

		private function restartObjectType(event:MouseEvent):void
		{
			var objsProxy:ObjectsProxy = facade.retrieveProxy(ObjectsProxy.NAME) as ObjectsProxy;
			var file:File   = new File();
			file.nativePath = objectTypeVO.filePath;
			var item:Item   = objsProxy.getItem(file);
			var selectTab:int = view.tabNavigator.selectedIndex;
			objectTypeViewRemoved();
			
			var viewInd:int = view.parent.getChildIndex(view);
			facade.sendNotification( CLOSE_OBJECT_TYPE_VIEW, {objView:view, objVO:objectTypeVO} );
			
			facade.sendNotification( ApplicationFacade.RESTART_OBJECT, {	"ObjTypeVO"		:objectTypeVO, 
																						"MediatorName"	:NAME + objectTypeVO.id, 
																						"Item"			:item, 
																						"ViewInd"		:viewInd, 
																						"SelectTab"		:selectTab} );
		}

		private function objectTypeViewRemoved(event:Event=null):void
		{
			var objTypeProxy:ObjectTypeProxy = facade.retrieveProxy(ObjectTypeProxy.NAME) as ObjectTypeProxy;
			objTypeProxy.removeVO(objectTypeVO);
			
			removeChildMediators();
			removeEventListeners();
			
			facade.removeMediator(NAME+objectTypeVO.id)			
		}
		
		private function removeChildMediators():void
		{
			facade.removeMediator( "InformationMediator" + objectTypeVO.id );
			facade.removeMediator( "ActionMediator" 	 + objectTypeVO.id );
			facade.removeMediator( "AttributeMediator"   + objectTypeVO.id );
			facade.removeMediator( "EventMediator" 		 + objectTypeVO.id );			
			facade.removeMediator( "LanguagesMediator" 	 + objectTypeVO.id );
			facade.removeMediator( "LibrariesMediator"	 + objectTypeVO.id );
			facade.removeMediator( "SourceCodeMediatior" + objectTypeVO.id );
			facade.removeMediator( "ResourcesMediator"	 + objectTypeVO.id );					
		}	
		
		private function removeEventListeners():void
		{
			view.saveObjectTypeButton.removeEventListener	( MouseEvent.CLICK, saveObjectType );
			view.saveAsObjectTypeButton.removeEventListener	( MouseEvent.CLICK, saveAsObjectType );
			view.connectObjectTypeToServerButton.removeEventListener( MouseEvent.CLICK, connectToServer );
			view.loadObjectTypeToServerButton.removeEventListener( MouseEvent.CLICK, loadObjectType );
			view.restartButton.removeEventListener			( MouseEvent.CLICK, restartObjectType );	
			view.removeEventListener						( OBJECT_TYPE_VIEW_REMOVED, objectTypeViewRemoved );
		}

		private function set changed(value: Boolean):void
		{
			_changed = value;
			if (value)
			{
				view.label = objectTypeVO.name + "*";
				view.isEnabled = true;
			}
			else
			{
				view.label = objectTypeVO.name
				view.isEnabled = false;	
			}
		}

		private function get changed():Boolean
		{
			return _changed ;
		}
		
		override public function listNotificationInterests():Array 
		{		
			var interests : Array = super.listNotificationInterests();
			
			interests.push( ApplicationFacade.SERVER_LOGIN_OK );
			interests.push( OBJECT_TYPE_CHAGED );
			interests.push( OBJECT_TYPE_VIEW_SAVED );
			
			return interests;
		}
		
		override public function handleNotification( note:INotification ):void 
		{
			switch ( note.getName() ) 
			{				
				case OBJECT_TYPE_CHAGED:
				{
					if (objectTypeVO == note.getBody() )
						changed = true;
					break;		
				}
					
				case OBJECT_TYPE_VIEW_SAVED:
				{
					if (objectTypeVO == note.getBody())
						changed = false;
					break;
				}
					
				case ApplicationFacade.SERVER_LOGIN_OK :
				{
					view.loadObjectTypeToServerButton.enabled = true;
					
					break;
				}
			}
		}

		protected function get view():ObjectView
		{
			return viewComponent as ObjectView;
		}

		private var objectTypeProxy:ObjectTypeProxy;
	}
}

