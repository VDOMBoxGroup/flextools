/**
  * Class ApplicationMediator register all Mediators
 **/
package net.vdombox.object_editor.view.mediators
{
	import flash.events.Event;
	import flash.net.SharedObject;
	
	import mx.events.ChildExistenceChangedEvent;
	import mx.managers.PopUpManager;
	
	import net.vdombox.object_editor.model.ErrorLogger;
	import net.vdombox.object_editor.model.vo.ObjectTypeVO;
	import net.vdombox.object_editor.view.ObjectView;
	import net.vdombox.object_editor.view.essence.ErrorLog;
	import net.vdombox.object_editor.view.mediators.ObjectsAccordionMediator;
	import net.vdombox.object_editor.view.popups.ProgressPopUp;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.facade.Facade;
	import org.puremvc.as3.patterns.mediator.Mediator;

	public class ApplicationMediator extends Mediator implements IMediator
	{
		public static const NAME					:String = "ApplicationMediator";
		public static const END_PROGRESS			:String	= "endProgress";
		public static const LOAD_INFORMATION		:String = "LoadInformation";		
		public static const OBJECT_COMPLIT			:String	= "objectComplit";
		public static const OBJECT_ALREADY_OPEN		:String	= "objectAlreadyOpen";		
		public static const RUN_PROGRESS			:String	= "runProgress";		
		public static const REMOVE_ALL_OBJECT		:String	= "removeAllObjects";
		public static const REOPEN_TAB				:String	= "reopenTab";

		public function ApplicationMediator( viewComponent:Object ) 
		{			
			super( NAME, viewComponent );	
			init();
		}
		
		public function complit( ):void 
		{			
			facade.registerMediator( new OpenMediator				( view.openButton ) ); 
			facade.registerMediator( new CreateObjectMediator		( view.newObjectButton ) );
			facade.registerMediator( new DeleteObjectMediatror		( view.delObjectButton ) );
			facade.registerMediator( new ObjectsAccordionMediator	( view.objAccordion ) );
			
			var erLog:ErrorLog = new ErrorLog();
			view.tabNavigator.addChild(erLog);
//			var obj:= view.tabNavigator.getChildAt(0) as ErrorLogger;
//			obj.buttonMode = false;
			facade.registerMediator( new ErrorLogMediator( erLog ) );
			
			view.tabNavigator.addEventListener(ChildExistenceChangedEvent.CHILD_REMOVE, objViewRemoved);
		}

		private function init():void
		{
			gotoLastPosition();
			view.nativeWindow.addEventListener( Event.CLOSING, saveAppPosition );			
		}		
		
		private function saveAppPosition(e:Event = null):void
		{
			var so:SharedObject = SharedObject.getLocal("directoryPath");
			
			so.data.windowPosition_x	= view.nativeWindow.x;
			so.data.windowPosition_y 	= view.nativeWindow.y;
			so.data.windowWidth			= view.width;
			so.data.windowHeight		= view.height;					
		}
		
		private function gotoLastPosition():void
		{
			var so:SharedObject = SharedObject.getLocal("directoryPath");
			
			if (so.data.windowPosition_x && 
				so.data.windowPosition_y &&
				so.data.windowWidth 	 &&
				so.data.windowHeight)
			{				
				view.nativeWindow.x	= so.data.windowPosition_x;
				view.nativeWindow.y = so.data.windowPosition_y;
				view.width 			= so.data.windowWidth;
				view.height			= so.data.windowHeight;
			}
		}		
		
		public function newObjectView( objTypeVO:ObjectTypeVO ) : void
		{	
			var objView:ObjectView = new ObjectView();
			objView.label = objTypeVO.name;					
			objView.name  = objTypeVO.name;

			view.tabNavigator.addChild(objView);
			facade.registerMediator( new ObjectViewMediator( objView, objTypeVO ) );	

			view.tabNavigator.selectedChild = objView;
			view.validateNow();
		}
		
		private var popup:ProgressPopUp;
		
		private function runProgress():void
		{
			popup = ProgressPopUp(PopUpManager.createPopUp(view, ProgressPopUp, true));
		}
		
		private function endProgress():void
		{
			popup.closePopUp();		
		}
		
		public function reopenObjectView( objTabIndex:int, selTab:int) : void
		{			
			var countChilds:uint = view.tabNavigator.length;
			var objView:ObjectView = view.tabNavigator.getChildAt( countChilds - 1 ) as ObjectView;
			view.tabNavigator.removeChild( objView );
			view.tabNavigator.addChildAt( objView, objTabIndex );
						
			view.tabNavigator.selectedChild = objView;
			objView.tabNavigator.selectedIndex = selTab;
		}

		/**
		 * remove:
		 *  - ObjectViewMediator
		 *  - ObjectView
		 *  - objTypeVO
		 **/
		public function removeObjectView( objView:ObjectView, objTypeVO:ObjectTypeVO = null, id:String = null ) : void
		{				
			if (objTypeVO)
				facade.removeMediator( "ObjectViewMediator" + objTypeVO.id );
			else if (id)
				facade.removeMediator( "ObjectViewMediator" + id );
			
			view.tabNavigator.removeChild(objView);
		}

		override public function listNotificationInterests():Array 
		{			
			return [ApplicationMediator.END_PROGRESS,
					ApplicationMediator.OBJECT_ALREADY_OPEN,
					ApplicationMediator.OBJECT_COMPLIT, 
					ApplicationMediator.REOPEN_TAB,
					ApplicationMediator.RUN_PROGRESS,					 
					ObjectViewMediator.CLOSE_OBJECT_TYPE_VIEW ];
		}

		override public function handleNotification( note:INotification ):void 
		{
			switch ( note.getName() ) 
			{				
				case ApplicationMediator.OBJECT_COMPLIT:
				{
					newObjectView(note.getBody() as ObjectTypeVO);
					break;	
				}
				
				case ApplicationMediator.REOPEN_TAB:
				{
					reopenObjectView(note.getBody()["ViewInd"] as int, note.getBody()["SelectTab"] as int);
					break;	
				}
					
				case ApplicationMediator.OBJECT_ALREADY_OPEN:
				{
					var toSelectedOjectName:String = note.getBody() as String;
					view.tabNavigator.selectedChild = view.tabNavigator.getChildByName( toSelectedOjectName) as ObjectView;
					break;	
				}
					
				case ObjectViewMediator.CLOSE_OBJECT_TYPE_VIEW:
				{
					removeObjectView(note.getBody()["objView"], note.getBody()["objVO"], note.getBody()["id"]);
					break;	
				}
					
				case ApplicationMediator.RUN_PROGRESS:
				{
					runProgress();
					break;	
				}
					
				case ApplicationMediator.END_PROGRESS:
				{
					endProgress();
					break;	
				}
			}
		}
		
		private function objViewRemoved( event: ChildExistenceChangedEvent ):void
		{				
			var objView:ObjectView = event.relatedObject as ObjectView;
			if (objView)
				objView.dispatchEvent( new Event(ObjectViewMediator.OBJECT_TYPE_VIEW_REMOVED));
		}

		protected function get view():TypeEditor
		{
			return viewComponent as TypeEditor
		}
	}
}