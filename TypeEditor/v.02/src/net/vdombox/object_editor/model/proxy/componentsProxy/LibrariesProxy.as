/*
	Class LibrariesProxy is a wrapper over the Libraries
 */
package net.vdombox.object_editor.model.proxy.componentsProxy
{
	import mx.collections.ArrayCollection;
	
	import net.vdombox.object_editor.model.vo.LibraryVO;
	
	import org.puremvc.as3.interfaces.*;
	import org.puremvc.as3.patterns.proxy.Proxy;
   
    public class LibrariesProxy extends Proxy implements IProxy
    {
		public static const NAME:String = "LibrariesProxy";

		public function LibrariesProxy ( data:Object = null ) 
        {
            super ( NAME, data );
        }
		
		public function createXML( librariesVO: ArrayCollection ):XML
		{		
			var librariesXML:XML = new XML("<Libraries/>");		
			
			for each(var obj:Object in librariesVO )
			{	
				var libVO:LibraryVO = obj.data;
				var libXML:XML = new XML("<Library/>");
				libXML.@Target = libVO.target;
//				libXML		   = libVO.text;
				
				libXML.appendChild(XML("\n"+"<![CDATA[" + libVO.text +"]]>"+"\n") );
				librariesXML.appendChild(libXML);
			}
			return librariesXML;
		}	
			
		public function createFromXML(objTypeXML:XML):ArrayCollection
		{
			var librariesCollection:ArrayCollection = new ArrayCollection();
			
			for each ( var libXML : XML in objTypeXML.descendants("Library") )
			{
				var libVO:LibraryVO = new LibraryVO;
				
				libVO.target = libXML.@Target;
				libVO.text	 = libXML.toString();
								
				librariesCollection.addItem({label:libVO.target, data:libVO});	
			}			
			return librariesCollection;
		}
	}
}