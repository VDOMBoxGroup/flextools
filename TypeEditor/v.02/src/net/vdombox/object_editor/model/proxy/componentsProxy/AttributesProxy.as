/*
	Class AtributesProxy is a wrapper over the Atributes
 */
package net.vdombox.object_editor.model.proxy.componentsProxy
{
	import net.vdombox.object_editor.model.vo.AttributeVO;
	import net.vdombox.object_editor.model.vo.ObjectTypeVO;
	
	import org.puremvc.as3.interfaces.IProxy;
	import org.puremvc.as3.patterns.proxy.Proxy;
   
    public class AttributesProxy extends Proxy implements IProxy
    {
		public static const NAME:String = "AttributesProxy";

		public function AttributesProxy ( data:Object = null ) 
        {
            super ( NAME, data );
        }
		
		public function createXML( objTypeVO: ObjectTypeVO ):void
		{		
		/*	var languagesXML: XML = objTypeXML.Languages[0];
			var languagesVO: LanguagesVO = new LanguagesVO();
			var	langEN:XML = languagesXML.Language.(@Code == "en_US")[0];
			
			for each ( var data : XML in objTypeXML.descendants("Attribute"))  //xml.descendants("Attributes") )
			{
				var atrib:AttributeVO = new AttributeVO;
//				atrib.label			= data.Name;
				atrib.name			= data.Name;
				atrib.displayName	= data.DisplayName;
				atrib.defaultValue	= data.DefaultValue;
				atrib.visible		= data.Visible.toString() == "1";
				atrib.help			= data.Help;
				atrib.interfaceType	= data.InterfaceType;//uint
				atrib.codeInterface	= data.CodeInterface;
				atrib.colorgroup	= data.Colorgroup;
				atrib.errorValidationMessage		= data.ErrorValidationMessage;
				atrib.regularExpressionValidation	= data.RegularExpressionValidation;
				
				objTypeVO.attributes.addItem({label:atrib.name, data:atrib});	
			}	*/		
		}		
	}
}