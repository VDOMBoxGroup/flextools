package net.vdombox.object_editor.view.mediators
{
	import flash.events.MouseEvent;

	import net.vdombox.object_editor.model.proxy.componentsProxy.ObjectTypeProxy;
	import net.vdombox.object_editor.model.vo.ObjectTypeVO;
	import net.vdombox.object_editor.view.ObjectView;
	import net.vdombox.object_editor.view.essence.Information;
	import net.vdombox.object_editor.view.essence.SourceCode;

	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;

	public class ObjectViewMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "ObjectViewMediator";

		public static const OBJECT_TYPE_CHAGED:String = "objectTypeChanged";
//		public static const OK:String = "ok";
		private var objectTypeVO:ObjectTypeVO;

		public function ObjectViewMediator( viewComponent:Object, objTypeVO:ObjectTypeVO ) 
		{	
			super( NAME+objTypeVO.id, viewComponent );		
			this.objectTypeVO = objTypeVO;

			// for selected necessary tab
			objectView.name = objTypeVO.id;


			var information:Information  = new Information();
			objectView.tabNavigator.addChild(information);

			var sourceCode:SourceCode  = new SourceCode();
			objectView.tabNavigator.addChild(sourceCode);

			facade.registerMediator( new InformationMediator( information, objTypeVO ) );
			facade.registerMediator( new SourceCodeMediatior( sourceCode,  objTypeVO ) );


			objectView.saveObjectTypeButton.addEventListener( MouseEvent.CLICK, saveObjectType );
			trace("ObjectViewMediator constructor");
			objectView.validateNow();
		}

		private function saveObjectType(event:MouseEvent):void
		{
			facade.sendNotification( ApplicationFacade.SAVE_OBJECT_TYPE, objectTypeVO ); 
		}

		override public function listNotificationInterests():Array 
		{			
			return [ OBJECT_TYPE_CHAGED ];
		}

		override public function handleNotification( note:INotification ):void 
		{
			switch ( note.getName() ) 
			{				
				case OBJECT_TYPE_CHAGED:
					if (objectTypeVO == note.getBody() )
						objectView.label = objectTypeVO.name + "*"
//					compliteInformation();
					break;				
			}
		}

		protected function get objectView():ObjectView
		{
			return viewComponent as ObjectView;
		}

		private var objectTypeProxy:ObjectTypeProxy;
	}
}

