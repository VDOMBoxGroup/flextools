/*
   Class SelectFormItemMediator wrapper from SelectFormItemMediator
 */
package net.vdombox.object_editor.view.mediators
{	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.collections.ArrayCollection;
	import mx.events.FlexEvent;
	
	import net.vdombox.object_editor.model.proxy.componentsProxy.LanguagesProxy;
	import net.vdombox.object_editor.model.vo.ObjectTypeVO;
	import net.vdombox.object_editor.view.essence.SelectFormItem;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.facade.Facade;
	import org.puremvc.as3.patterns.mediator.Mediator;

	public class SelectFormItemMediator extends Mediator implements IMediator
	{
		public static const NAME			:String = "SelectFormItemMediator";				
		public static const CHOSE_WORD		:String = "choseWord";
		private var objectTypeVO:ObjectTypeVO;

		public function SelectFormItemMediator( viewComponent:Object, objTypeVO:ObjectTypeVO ) 
		{			
			super( NAME+objTypeVO.id, viewComponent );
			this.objectTypeVO = objTypeVO;
			view.fselectComboBox.addEventListener( MouseEvent.CLICK, openListWords );
			//view.addEventListener( FlexEvent.CREATION_COMPLETE, showInformation );
			
		}
		
		
		public function openListWords( event:MouseEvent ) : void
		{			
			var langsProxy:LanguagesProxy = facade.retrieveProxy(LanguagesProxy.NAME) as LanguagesProxy;
						
			view.fselectComboBox.addEventListener( Event.CHANGE, acloseHandler);
						
			var arrCol:ArrayCollection = langsProxy.getWordsOnCarentLocal(objectTypeVO.languages);
			view.fselectComboBox.dataProvider = arrCol;	
			
			function acloseHandler(event:Event):void
			{
				var wordCode:Object = event.target.wordCode;					
				if(wordCode == null)return;					
				view.fname.text = langsProxy.getWord(objectTypeVO.languages,wordCode["ID"]);	
				objectTypeVO.displayName = wordCode["name"];
			}				
		}

		/*override public function listNotificationInterests():Array 
		{			
			return [ ApplicationFacade.OBJECT_COMPLIT, ApplicationFacade.OBJECT_EXIST ];
		}

		override public function handleNotification( note:INotification ):void 
		{
			switch ( note.getName() ) 
			{				
				case ApplicationFacade.OBJECT_COMPLIT:
					newObjectView(note.getBody() as ObjectTypeVO);
					break;	

				case ApplicationFacade.OBJECT_EXIST:
					var toSelectedOjectName:String = note.getBody() as String;
					view.tabNavigator.selectedChild = view.tabNavigator.getChildByName( toSelectedOjectName) as ObjectView;
					break;	
			}
		}*/

		protected function get view():SelectFormItem
		{
			return viewComponent as SelectFormItem
		}
	}
}

