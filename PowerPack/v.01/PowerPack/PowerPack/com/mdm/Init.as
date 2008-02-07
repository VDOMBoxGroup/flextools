package PowerPack.com.mdm
{
	import mdm.*;
	import flash.events.EventDispatcher;
	import mx.utils.StringUtil;
	import mx.core.Application;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import mx.controls.Alert;
	
	public class Init extends EventDispatcher
	{
        // Define a static variable.
        private static var application:Object;
        
        private static var classInitialised:Boolean = initalise();
       	public static function get initialised():Boolean
	    {	    	
	        return classInitialised;
	    }
        
        public static function check():void
        {
			if(!initialised)
			{
				throw new MDMError();
			}
        }
        
        // Define a static method.
        private static function initalise():Boolean 
        {        	
        	application = mx.core.Application.application;
        	if(!application)
        	{
        		throw new MDMError(null, 1);
        	}	
			mdm.Application.init(DisplayObject(application), mdmInit); 
			return false;
        }
		    
	   	private static function mdmInit():void
       	{       		
       		var appFileName:String = mdm.Application.filename;
       		
       		if(appFileName && StringUtil.trim(appFileName).length>0)
       		{
       			classInitialised = true;
       		}
       		
       		mdm.Application.enableExitHandler();

			mdm.FileExplorer.init();			           	
			
			mdm.Application.onAppExit = function():void{				
				mx.core.Application(application).dispatchEvent(new Event("applicationExiting"));
			}
	       	
	       	mdm.Menu.Context.menuType = "function";
	       	//GraphCanvas.generateContextMenu();
	       	//GraphNode.generateContextMenu();
	    	//GraphArrow.generateContextMenu();
       	}
        
		//--------------------------------------------------------------------------   
				
		
	}
}