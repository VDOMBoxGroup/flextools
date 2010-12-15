/*
	Class ResoursesProxy is a wrapper over the Resourses
 */
package net.vdombox.object_editor.model.proxy.componentsProxy
{	
	import org.puremvc.as3.interfaces.*;
    import org.puremvc.as3.patterns.proxy.Proxy;
   
    public class ResoursesProxy extends Proxy implements IProxy
    {
		public static const NAME:String = "ResoursesProxy";

		public function ResoursesProxy ( data:Object = null ) 
        {
            super ( NAME, data );
        }
	}
}