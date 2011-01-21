package net.vdombox.object_editor.view.mediators
{
	import flash.events.Event;
	import flash.events.MouseEvent;

	import flexlib.controls.tabBarClasses.SuperTab;

	import mx.controls.Alert;
	import mx.events.ChildExistenceChangedEvent;

	import net.vdombox.object_editor.model.proxy.componentsProxy.ObjectTypeProxy;
	import net.vdombox.object_editor.model.vo.ObjectTypeVO;
	import net.vdombox.object_editor.view.ObjectView;
	import net.vdombox.object_editor.view.essence.Actions;
	import net.vdombox.object_editor.view.essence.Attributes;
	import net.vdombox.object_editor.view.essence.Events;
	import net.vdombox.object_editor.view.essence.Information;
	import net.vdombox.object_editor.view.essence.Languages;
	import net.vdombox.object_editor.view.essence.Libraries;
	import net.vdombox.object_editor.view.essence.Resourses;
	import net.vdombox.object_editor.view.essence.SourceCode;

	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;

	public class ObjectViewMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "ObjectViewMediator";

		public static const OBJECT_TYPE_CHAGED:String = "objectTypeChanged";
		public static const OBJECT_TYPE_VIEW_REMOVED:String = "objectTypeViewRemoved";
		public static const OBJECT_TYPE_VIEW_SAVED:String = "objectTypeViewSaved";

		private var objectTypeVO:ObjectTypeVO;
		private var _changed : Boolean = false;

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

			view.validateNow();

			view.addEventListener(OBJECT_TYPE_VIEW_REMOVED, objectTypeViewRemoved);
		}

		private function saveObjectType(event:MouseEvent):void
		{
			facade.sendNotification( ApplicationFacade.SAVE_OBJECT_TYPE, objectTypeVO );
		}

		private function saveAsObjectType(event:MouseEvent):void
		{
			facade.sendNotification( ApplicationFacade.SAVE_AS_OBJECT_TYPE, objectTypeVO );
		}


		private function closeObjectType(event:Event):void
		{
			changed = false;
			Alert.show(objectTypeVO.name, "Closed");

//			facade.sendNotification( ApplicationFacade.SAVE_AS_OBJECT_TYPE, objectTypeVO );
		}


		override public function listNotificationInterests():Array 
		{			
			return [ OBJECT_TYPE_CHAGED, OBJECT_TYPE_VIEW_SAVED ];
		}

		override public function handleNotification( note:INotification ):void 
		{
			switch ( note.getName() ) 
			{				
				case OBJECT_TYPE_CHAGED:
					if (objectTypeVO == note.getBody() )
						changed = true;
					break;		

				case OBJECT_TYPE_VIEW_SAVED:
					if (objectTypeVO == note.getBody() )
						changed = false;
					break;	
			}
		}

		private function  objectTypeViewRemoved(event  : Event):void
		{
			var objTypeProxy : ObjectTypeProxy= facade.retrieveProxy(ObjectTypeProxy.NAME) as ObjectTypeProxy;
			objTypeProxy.removeVO(objectTypeVO);

			facade.removeMediator(NAME+objectTypeVO.id)
		}


		private function set changed(value: Boolean):void
		{
			_changed = value;
			if(value)
				view.label = objectTypeVO.name + "*";
			else
				view.label = objectTypeVO.name
		}

		private function get changed():Boolean
		{
			return _changed ;
		}


		protected function get view():ObjectView
		{
			return viewComponent as ObjectView;
		}

		private var objectTypeProxy:ObjectTypeProxy;
	}
}

